set search_path = cvp;

CREATE OR REPLACE FUNCTION validar_ingresando_trg()
    RETURNS trigger AS
$BODY$
DECLARE
  vPeriodo_1     text;  
  vingresando_1  character varying(1);
  vIngresando    character varying(1); 
  vabierto       character varying(1);
  vnpan        integer; 
  vnvis        integer; 
  vnvisnonula    integer; 
  vesadministrador integer;
  vescoordinacion integer;
  vAlgunasNoIngresadas text;
  vCantPreciosInconsistentes integer;
  vPreciosInconsistentes text;
  
BEGIN

SELECT 1 INTO vesadministrador
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_administrador' ; 
SELECT 1 INTO vescoordinacion
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_coordinacion' ;    
  
IF OLD.ingresando IS DISTINCT FROM NEW.ingresando THEN
  IF NEW.ingresando='N' AND (vesadministrador=1 OR vescoordinacion=1) THEN -- estoy cerrando
      SELECT periodo, ingresando INTO vPeriodo_1, vingresando_1
          FROM cvp.periodos
          WHERE periodo=(SELECT periodoanterior FROM cvp.periodos where periodo=NEW.periodo);
      IF NOT (vPeriodo_1 IS NULL OR vingresando_1='N')  THEN 
          RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" si no esta cerrado el periodo anterior "%"' ,new.periodo,vperiodo_1;
      END IF;
      SELECT COUNT(*) INTO vnpan FROM cvp.relpan WHERE periodo= NEW.periodo; 
      IF /*NOT vperiodo_1 IS NULL AND*/ vnpan  is distinct from 20 THEN
          RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" porque no se generaron todos los paneles. Hay "%" paneles' ,new.periodo,vnpan;
      END IF;
      SELECT count(*), count(CASE WHEN razon is not null THEN 1 ELSE null END)
          , substr(
             string_agg(
               CASE WHEN razon is null 
                    THEN 'i'||informante||' f'||formulario||' p'||panel||' t'||tarea||
                         case when visita>1 then ' VISITA:'||visita else '' end 
                    ELSE null 
               END ,', '),1,100) -- pongo un límite para que la excepción no sea muy larga.
          INTO vnvis, vnvisnonula, vAlgunasNoIngresadas
          FROM cvp.relvis WHERE periodo=NEW.periodo;
      IF vnvis <> vnvisnonula THEN
           RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" porque no estan todas las visitas ingresadas. Faltan ingresar % visitas. Por ejemplo % ' ,new.periodo, vnvis-vnvisnonula, vAlgunasNoIngresadas;
      END IF;
    
    SELECT count(*), substr(string_agg(
               CASE WHEN coalesce(inconsistente, true) 
                    THEN 'i'||v.informante||' p'||v.panel||' t'||v.tarea||' f'||v.formulario||' p'||p.producto||' v'||v.visita||' o'||p.observacion
                    ELSE null 
               END ,', '),1,100) -- pongo un límite para que la excepción no sea muy larga.
    INTO vCantPreciosInconsistentes, vPreciosInconsistentes
    FROM cvp.relvis v
    LEFT JOIN cvp.razones z using (razon)
    LEFT JOIN cvp.relpre p using (periodo, informante, visita, formulario)
    LEFT JOIN cvp.tipopre tp using (tipoprecio)
    WHERE periodo=NEW.periodo AND coalesce(espositivoformulario, 'S') = 'S' AND coalesce(inconsistente, true);
      IF vCantPreciosInconsistentes > 0 THEN
           RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" porque hay % registros de precios inconsistentes. Por ejemplo % ' ,new.periodo, vCantPreciosInconsistentes, vPreciosInconsistentes;
      END IF;
        
      NEW.fecha_cierre_ingreso=CURRENT_TIMESTAMP(3);
      /*Blanquear el vencimiento_sincronizacion al cerrar el periodo*/
      UPDATE cvp.reltar SET vencimiento_sincronizacion = null
      WHERE periodo = NEW.periodo AND vencimiento_sincronizacion IS NOT NULL;      


  ELSIF NEW.ingresando='S'  AND vescoordinacion=1 THEN -- abrir
      SELECT  abierto INTO vabierto
      FROM cvp.calculos
      WHERE periodo=NEW.Periodo AND calculo=0 ;
      IF vabierto='N' THEN
          RAISE EXCEPTION 'ERROR no se puede reabrir el periodo "%" porque el calculo esta cerrado', new.periodo;
      END IF; 
      SELECT periodo, ingresando INTO vperiodo_1, vingresando
          FROM cvp.periodos
          WHERE periodoanterior=NEW.Periodo ;
      IF vingresando='N' THEN
        RAISE EXCEPTION 'ERROR no se puede reabrir porque el siguiente periodo "%" esta cerrado', vperiodo_1;
      END IF;
  ELSE 
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;     
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY INVOKER;

CREATE OR REPLACE FUNCTION generar_formulario(
  pperiodo text,
  pinformante integer,
  pformulario integer,
  pfechageneracion timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
    
AS $BODY$
declare
  /* v100713
       genera los atributos según prodatr
     v100301
     la inclusión forzosa de nuevos productos verifica que eno esté presente el producto en el periodo anterior
       (esto para arreglar un posible problema con los productos que están en dos formularios asignados al mismo informante)
     v100224
     con inclusión forzosa de nuevos productos para determinado formulario (según forprod)
     v080924  
     con búsqueda de visita anterior
  */
  vcantidadpreciosgenerados integer;
  vvisita INTEGER := 1;
  vcantidadatributosgenerados integer;
  vcantidadatributosenformulario integer;
  
begin
  --raise notice 'pap 1';
  insert into cvp.bitacora (que) values ('nueva generacion '||pperiodo||' i:'||pinformante||' f:'||pformulario||' g:'||pfechageneracion);

  --raise notice 'pap 2-- Insercion en relpre';
    insert into cvp.relpre(periodo, producto, observacion, informante, visita, formulario, precio, tipoprecio, especificacion, ultima_visita)
      select pperiodo, f.producto, f.observacion, pinformante, vvisita, f.formulario, null, null, f.especificacion, true
        from cvp.forobsinf f
          inner join cvp.informantes i on f.informante = i.informante and i.informante=pinformante
          inner join cvp.rubros ru on i.rubro=ru.rubro
          left join cvp.relpre r 
            on r.informante=pinformante 
              and r.formulario=f.formulario 
              and r.producto=f.producto 
              and r.observacion=f.observacion
              and r.periodo=pperiodo
              and r.visita=vvisita
        where f.formulario=pformulario
          and --(ru.despacho='A' or f.observacion=1)
            (f.dependedeldespacho = 'N' or ru.despacho = 'A' OR f.observacion = 1)
            and r.periodo is null;
  -- verifico que se haya generado al menos algún precio
  --raise notice 'pap 3';
  select count(*)
    into vcantidadpreciosgenerados
    from cvp.relpre
    where periodo=pperiodo
      and informante=pinformante
      and formulario=pformulario
      and visita=vvisita;
  -- Debe ser una excepcion  
  IF vcantidadpreciosgenerados=0 THEN
    --raise Exception 'Error, No se generaron filas del formulario del periodo %, informante%, formulario%  sin registros en relpre', pperiodo, pinformante, pformulario;  
    raise Notice 'ADVERTENCIA, No se generaron filas del formulario del periodo %, informante%, formulario%  sin registros en relpre', pperiodo, pinformante, pformulario;  
    
  END IF;

  select count(*) into vcantidadatributosgenerados
    from cvp.relatr a
  left join cvp.periodos p on a.periodo = p.periodoanterior
    left join cvp.relpre r on
    a.periodo = r.periodo and 
    a.producto = r.producto and 
    a.observacion = r.observacion and 
    a.informante = r.informante and 
    a.visita = r.visita
    where p.periodo=pperiodo
      and a.informante=pinformante
      and r.formulario=pformulario
      and a.visita=vvisita;
    
  select count(*) into vcantidadatributosenformulario
  from cvp.prodatr pa
  left join cvp.forprod fp using (producto)
  where fp.formulario = pformulario;

  IF vcantidadatributosenformulario > 0 and vcantidadatributosgenerados=0 THEN
    raise Exception 'Error, No se generaron los atributos del periodo anterior; periodo %, informante%, formulario% ', pperiodo, pinformante, pformulario;
  END IF;
  
  --raise notice 'pap 4';
    insert into cvp.relatr (periodo , producto  , observacion     , informante , atributo  , valor, visita, validar_con_valvalatr)
      select                rp.periodo, rp.producto, rp.observacion, rp.informante, f.atributo,
                               CASE WHEN a.es_vigencia THEN 
                                 --1::text
                                 date_part('day'::text, ((((substr(cvp.moverperiodos(rp.periodo::text, 1), 2, 4) || '-'::text) || substr(cvp.moverperiodos(rp.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval)::text
                                 WHEN r_1.atributo IS NULL THEN a.valorInicial 
                                 ELSE r_1.valor END ,  rp.visita, vv.validar
      from cvp.prodatr f 
        inner join cvp.relpre rp
          on rp.producto=f.producto 
            and rp.informante=pinformante
            and rp.formulario=pformulario
            and rp.periodo=pperiodo
            and rp.visita=vvisita
        INNER JOIN cvp.atributos a ON a.atributo=f.atributo    
        left join cvp.relatr ra 
          on ra.informante=rp.informante 
            and ra.atributo=f.atributo
            and ra.producto=rp.producto 
            and ra.observacion=rp.observacion
            and ra.periodo=rp.periodo
            and ra.visita=rp.visita
        left join cvp.relpre p_1
          on p_1.informante=rp.informante 
            and p_1.producto=rp.producto 
            and p_1.observacion=rp.observacion
            and p_1.periodo= (SELECT MAX(periodo)
                                FROM cvp.relatr
                                WHERE periodo < rp.periodo
                                  AND producto = rp.producto AND observacion = rp.observacion 
                                  AND informante = rp.informante AND atributo=f.atributo)
            and p_1.ultima_visita=true
        left join cvp.relatr r_1 
          on r_1.informante=rp.informante 
            and r_1.atributo=f.atributo
            and r_1.producto=rp.producto 
            and r_1.observacion=rp.observacion
            and r_1.periodo=p_1.periodo
            and r_1.visita=p_1.visita
        LEFT JOIN cvp.ValValAtr vv ON f.producto = vv.producto
            AND f.atributo = vv.atributo
            AND r_1.valor = vv.valor
      where ra.periodo is null
        and rp.informante=pinformante
        and rp.formulario=pformulario
        and rp.periodo=pperiodo
        and rp.visita=vvisita;
  
  --raise notice 'pap 5';
  return null;
end
$BODY$;  

CREATE OR REPLACE FUNCTION restaurar_atributos_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vatributos RECORD;
  vpuedecambiaratributosnew  cvp.tipopre.puedecambiaratributos%type;
  vpuedecambiaratributosold  cvp.tipopre.puedecambiaratributos%type;
  vblanqueonew  cvp.tipopre.registrablanqueo%type;
  vblanqueoold  cvp.tipopre.registrablanqueo%type;
BEGIN
  SELECT puedecambiaratributos, registrablanqueo INTO vpuedecambiaratributosnew, vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT puedecambiaratributos, registrablanqueo INTO vpuedecambiaratributosold, vblanqueoold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;
  
  IF OLD.tipoprecio is distinct from NEW.tipoprecio THEN
    IF vblanqueonew and not vblanqueoold THEN
        INSERT INTO cvp.blapre(
            periodo, producto, observacion, informante, formulario, precio, 
            tipoprecio, visita, modi_usu, modi_fec, modi_ope, comentariosrelpre, 
            cambio, precionormalizado, especificacion, ultima_visita)
        VALUES (OLD.periodo, OLD.producto, OLD.observacion, OLD.informante, OLD.formulario, OLD.precio, 
            OLD.tipoprecio, OLD.visita, OLD.modi_usu, OLD.modi_fec, OLD.modi_ope, OLD.comentariosrelpre, 
            OLD.cambio, OLD.precionormalizado, OLD.especificacion, OLD.ultima_visita);
        --
        INSERT INTO cvp.blaatr 
            SELECT * FROM cvp.relatr 
            WHERE periodo=NEW.periodo AND 
               producto=NEW.producto AND
               observacion=NEW.observacion AND 
               informante=NEW.informante AND
               visita=NEW.visita;  
    END IF;
    IF not vblanqueonew and vblanqueoold THEN
        DELETE FROM cvp.blaatr 
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
        DELETE FROM cvp.blapre
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
    END IF;
  END IF;
  IF ((NEW.cambio IS NULL AND OLD.cambio ='C') OR (not vpuedecambiaratributosnew)) AND vblanqueonew IS NOT TRUE THEN
    /*IF NEW.cambio='C' THEN --este caso solo para la segunda condicion si hubiera C
       NEW.cambio:=NULL;     --lo saco porque se solapa con la validacion de tipoprecio valido
    END IF; */
    
    INSERT INTO cvp.relpresemaforo (periodo,informante,visita,producto,observacion)
      VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
    FOR vatributos IN 
      SELECT r_1.atributo,r_1.valor_1, r_1.valor
      FROM cvp.relatr_1 r_1
            WHERE r_1.periodo=NEW.periodo AND 
                  r_1.producto=NEW.producto AND
                  r_1.observacion=NEW.observacion AND 
                  r_1.informante=NEW.informante AND
                  r_1.visita=NEW.visita 
   	
    LOOP
      IF vatributos.valor_1 IS DISTINCT FROM vatributos.valor THEN
        UPDATE cvp.relatr 
          SET valor=vatributos.valor_1
          WHERE periodo=NEW.periodo AND 
                producto=NEW.producto AND
                observacion=NEW.observacion AND 
                informante=NEW.informante AND
                visita=NEW.visita AND
                atributo=vatributos.atributo ; --TOMAR VALOR DE ATRIBUTO
      END IF;   
    END LOOP;  
  END IF;
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  
CREATE OR REPLACE FUNCTION relpre_validacion_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vespositivo cvp.tipopre.espositivo%type;
  vactivo cvp.tipopre.activo%type;
  vregistrablanqueo cvp.tipopre.registrablanqueo%type;
  vpuedecambiaratributos cvp.tipopre.puedecambiaratributos%type;
BEGIN
  IF new.tipoprecio IS NULL AND new.precio IS NOT NULL THEN
    RAISE EXCEPTION 'TipoPrecio sin dato';
    RETURN NULL;
  ELSIF new.tipoprecio IS NULL and new.cambio is not null THEN
	RAISE EXCEPTION 'No puede quitar tipo de precio si hay cambios de atributos';
    RETURN NULL;
  ELSIF new.tipoprecio IS NOT NULL THEN
    SELECT espositivo, activo, registrablanqueo, puedecambiaratributos INTO vespositivo, vactivo, vregistrablanqueo, vpuedecambiaratributos
      FROM cvp.tipopre
      WHERE tipoprecio=new.tipoprecio;
    IF vactivo = 'N' THEN
      RAISE EXCEPTION 'Tipo de precio inválido';
      RETURN NULL;
    END IF;
    IF vespositivo='S' AND new.precio IS NULL  THEN
      RAISE EXCEPTION 'TipoPrecio indica que debe ingresar precio>0';
      RETURN NULL;
    ELSIF vespositivo='N' AND new.precio IS NOT NULL THEN 
      RAISE EXCEPTION 'TipoPrecio indica que precio debe quedar sin valor';
      RETURN NULL;
    END IF; 
    --IF vespositivo='N' AND new.cambio='C' and not vregistrablanqueo THEN
    --  RAISE EXCEPTION 'No puede haber C en Cambio cuando Tipoprecio no es positivo';
    --  RETURN NULL;
    --END IF;    
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION cvp.calcular_cambioenprecio_relatr_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE 
  vcambio cvp.relpre.cambio%type;
BEGIN
 SELECT case when count(*)=0 THEN NULL ELSE 'C' END INTO vcambio
    FROM cvp.relatr_1 a
    JOIN cvp.atributos t using (atributo)
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND  a.producto=NEW.producto AND a.observacion=NEW.observacion and a.valor is distinct from a.valor_1
        AND not coalesce(t.es_vigencia, false); 

    UPDATE cvp.relpre  
      SET cambio=vcambio
      WHERE periodo=NEW.periodo AND informante=NEW.informante 
        AND visita=NEW.visita AND producto=NEW.producto AND observacion=NEW.observacion;     
  RETURN NULL;
 
END;
$BODY$;

ALTER FUNCTION cvp.calcular_cambioenprecio_relatr_trg()
    OWNER TO cvpowner;
	
CREATE TRIGGER relatr_calcula_cambio_precio_trg
    AFTER UPDATE OR INSERT
    ON cvp.relatr
    FOR EACH ROW
    EXECUTE PROCEDURE cvp.calcular_cambioenprecio_relatr_trg();