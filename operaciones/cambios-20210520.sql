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
      /*Blanquear de reltar al cerrar el periodo*/
      UPDATE cvp.reltar 
         SET vencimiento_sincronizacion  = null,
             vencimiento_sincronizacion2 = null,
             archivo_manifiesto          = null,
             archivo_cache               = null,
             archivo_hdr                 = null,
             archivo_estructura          = null
      WHERE periodo = NEW.periodo;      


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