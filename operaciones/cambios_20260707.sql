set search_path = cvp;
GRANT cvp_usuarios TO hvontschirnhaus;
GRANT cvp_usuarios TO pseivach;

SET role cvpowner;

CREATE OR REPLACE FUNCTION verificar_ingresando()
  RETURNS trigger AS
$BODY$
DECLARE
    vIngresando varchar(1);
    vPeriodo varchar(20);
    vCerrarIngresoCampoHastaPanel integer;
    vpanel      INTEGER;
    vformulario INTEGER;
    vtabla      varchar(100);
    vinformante integer;
    vvisita     integer;
    vproducto   text;
    vobservacion integer;
    vatributo   integer;
    voperativo  text;
    vesadministrador integer;
    vescoordinacion integer;
    vhabilitado character varying(1);
    vconpermiso boolean;
    vverificado_rec character varying(1);
BEGIN
    SELECT 1 INTO vesadministrador
    FROM ipcba.usuarios
    WHERE usu_usu = current_user and usu_rol in
    ('migracion','analista','programador','coordinador','ccc_analista');
    
    SELECT 1 INTO vescoordinacion
    FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
    WHERE a.roleid=p.oid AND p.rolname='cvp_coordinacion' ;    
    IF vesadministrador=1 OR vescoordinacion=1 THEN 
       vconpermiso = true; 
    ELSE 
       vconpermiso = false; 
    END IF;    
    vtabla= TG_TABLE_NAME;
    IF TG_OP='DELETE' THEN
       vPeriodo:=OLD.Periodo;
    ELSE
       vPeriodo:=NEW.Periodo;
    END IF;
    SELECT Ingresando, CerrarIngresoCampoHastaPanel, habilitado 
            INTO vIngresando, vCerrarIngresoCampoHastaPanel, vhabilitado
        FROM cvp.periodos where Periodo=vPeriodo;
    --RAISE EXCEPTION 'Vconpermiso %',vconpermiso;
    IF vIngresando = 'N' OR (vhabilitado = 'N' and not vconpermiso) then
        RAISE EXCEPTION 'Periodo Cerrado. Actualizacion no permitida en tabla %',vtabla;
        RETURN NULL;
    ELSE
        CASE vtabla
           WHEN 'relvis' THEN
               IF TG_OP= 'DELETE' THEN
                   vformulario= old.formulario;   
                   vpanel= old.panel;   
               ELSE
                   vformulario=new.formulario;
                   vpanel= new.panel;   
               END IF;
           WHEN 'relpre' THEN
               IF TG_OP= 'DELETE' THEN
                   vformulario = OLD.formulario;  
                   vperiodo= OLD.periodo;
                   vinformante= OLD.informante;
                   vvisita= OLD.visita;
               ELSE    
                   vformulario=new.formulario;
                   vperiodo= NEW.periodo;
                   vinformante= NEW.informante;
                   vvisita= NEW.visita;
               END IF;
               SELECT panel INTO  vpanel
                  FROM cvp.relvis rv 
                  WHERE  rv.periodo=vperiodo AND
                                    rv.informante=vinformante AND
                                    rv.visita=vvisita AND
                                    rv.formulario=vformulario;
           WHEN 'relatr' THEN
                IF TG_OP='DELETE' then
                   vperiodo= OLD.periodo;
                   vproducto= OLD.producto;
                   vobservacion= OLD.observacion;
                   vinformante= OLD.informante;
                   vvisita= OLD.visita;
                   vatributo= OLD.atributo;
                ELSE   
                   vperiodo= NEW.periodo;
                   vproducto= NEW.producto;
                   vobservacion= NEW.observacion;
                   vinformante= NEW.informante;
                   vvisita= NEW.visita;
                   vatributo= NEW.atributo;
                END IF;              
               SELECT  rv.formulario, rv.panel
                  INTO  vformulario  , vpanel
                  FROM cvp.relatr ra 
                    JOIN cvp.relpre rp ON ra.periodo=rp.periodo AND
                                       ra.producto=rp.producto AND
                                       ra.observacion=rp.observacion AND
                                       ra.informante=rp.informante AND
                                       ra.visita=rp.visita
                    JOIN cvp.relvis rv ON ra.periodo=rv.periodo AND
                                          ra.informante=rv.informante AND
                                          ra.visita=rv.visita AND
                                          rp.formulario=rv.formulario
                  WHERE ra.periodo=vperiodo and ra.producto=vproducto and
                        ra.observacion=vobservacion and ra.informante=vinformante and
                        ra.visita=vvisita and ra.atributo=vatributo ;                    
           ELSE
               vformulario=null;   
               vpanel= null;   
        END CASE;   
        IF vpanel IS NOT NULL AND vformulario IS NOT NULL  THEN
            SELECT operativo INTO voperativo FROM cvp.formularios where formulario=vformulario;
            IF vIngresando='S' AND voperativo='C' AND vpanel <=vCerrarIngresoCampoHastaPanel THEN 
               RAISE EXCEPTION 'El panel % esta cerrado para ingreso de campo', vpanel;
               RETURN NULL;
            END IF;
        END IF;
        /* Se puede editar la encuesta después de verificar la recepción, comento esta parte
        IF vtabla = 'relvis' THEN
            IF TG_OP in ('UPDATE','DELETE') then
                IF NEW.verificado_rec = OLD.verificado_rec AND NEW.verificado_rec ='S' THEN
                    RAISE EXCEPTION 'Se ha verificado la recepción para periodo % informante % visita % formulario %', NEW.periodo, NEW.informante, NEW.visita, NEW.formulario;
                    RETURN NULL;
                END IF;
            END IF;
        ELSE
            IF vperiodo IS NOT NULL AND vinformante IS NOT NULL AND vvisita IS NOT NULL AND vformulario IS NOT NULL THEN
                SELECT verificado_rec INTO vverificado_rec 
                FROM cvp.relvis WHERE 
                periodo = vperiodo AND
                informante = vinformante AND
                visita = vvisita AND
                formulario = vformulario;
                IF vverificado_rec='S' THEN 
                    RAISE EXCEPTION 'Se ha verificado la recepción para periodo % informante % visita % formulario %', vperiodo, vinformante, vvisita, vformulario;
                    RETURN NULL;
                END IF;
            END IF;
        END IF;
        */
    END IF;    
    if TG_OP='DELETE' then
       RETURN OLD;
    ELSE   
       RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

set search_path = ccc, cvp;

--evita la edición de la tabla con el periodo cerrado
CREATE OR REPLACE TRIGGER novservdom_abi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON novservdom
    FOR EACH ROW
    EXECUTE FUNCTION cvp.verificar_ingresando();

ALTER TABLE calhogpargru ADD COLUMN variacion double precision;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('calhogpargru','periodo,calculo,hogar,agrupacion,grupo');
 end
$SQL_ENANCE$;

CREATE OR REPLACE FUNCTION Cal_CCC_Variacion(pPeriodo TEXT, pCalculo INTEGER, pAgrupacion TEXT) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$      
 
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='comenzo');
 
  UPDATE CalGruPer c
    SET variacion=CASE WHEN c0.valorgru=0 THEN null ELSE round((c.valorgru/c0.valorgru*100-100)::decimal,1) END
    FROM CalGruPer c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.perfil = c.perfil; --Pk verificada
  
  UPDATE calhogpargru c
    SET variacion=CASE WHEN c0.valorhoggru=0 THEN null ELSE round((c.valorhoggru/c0.valorhoggru*100-100)::decimal,1) END
    FROM calhogpargru c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.hogar = c.hogar; --Pk verificada

  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='finalizo');
END;  
$$;

------------------
CREATE OR REPLACE FUNCTION Cal_CCC_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion Text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
vindice double precision;
vparavariosHogares BOOLEAN;
BEGIN
SET search_path = ccc, cvp, comun, public;  --porque se corre suelto
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='comenzo');
SELECT indice INTO vindice
  FROM CalGru
  WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion='Z' and nivel=0 ;
IF vindice is null THEN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='error', pMensaje:='No está calculado el Indice para el nivel Z0', pAgrupacion:=pAgrupacion);
ELSE
  SELECT paravarioshogares INTO vparavariosHogares
    FROM agrupaciones_ccc
    WHERE agrupacion=pAgrupacion;

  EXECUTE CalProd_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);  --valoriza productos de ccc

  --EXECUTE Cal_Canasta_Borrar(pPeriodo, pCalculo, pAgrupacion);  ya se borró en Cal_CCC_Borrar, falta ver más adelante las tablas de hogares

  EXECUTE CalGru_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);

  IF vparavariosHogares THEN      ---- falta ver más adelante las tablas de hogares
    EXECUTE CalHog_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);
  --  EXECUTE CalHog_Subtotalizar(pPeriodo, pCalculo, pAgrupacion);
  END IF;
  
  EXECUTE Cal_CCC_Variacion(pPeriodo, pCalculo, pAgrupacion);

END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Valorizar', pTipo:='finalizo');
END;
$$;
--------------------------
CREATE or replace FUNCTION calProd_CCC_valorizar(pperiodo text, pcalculo integer, pAgrupacion text default null) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vcalprod RECORD;

BEGIN
set search_path = ccc, cvp;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='comenzo');

FOR vcalprod IN
  SELECT a.periodo, a.calculo, a.producto, a.agrupacion, a.perfil, a.peso_neto, a.calorias, p.factor_correccion, p.cantidad, c.promedioredondeado, a.cantidad_ajuste
    FROM CalDiv c
    INNER JOIN CalProdPerAgr a ON c.periodo = a.periodo and c.calculo = a.calculo and c.producto = a.producto
    INNER JOIN productos_ccc p ON a.producto = p.producto
    WHERE c.division = '0' and c.periodo=pPeriodo AND c.calculo=pCalculo AND a.agrupacion = pAgrupacion
LOOP
   --Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;
 UPDATE CalProdPerAgr
   SET peso_bruto       = vcalprod.peso_neto * vcalprod.factor_correccion
   , cantidad_canasta = coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad
   , valorProd        = 30*vcalprod.PromedioRedondeado * (coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad)
   WHERE periodo = vcalprod.periodo AND calculo = vcalprod.calculo AND producto = vcalprod.producto AND agrupacion = vcalprod.agrupacion AND perfil = vcalprod.perfil;
END LOOP;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='finalizo', pagrupacion:=pagrupacion);
END;
$$;

------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS calcularcccunperiodo(text, integer);
CREATE OR REPLACE FUNCTION CalcularCCCUnPeriodo(pPeriodo text, pCalculo integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
as
$BODY$
declare
   vEmpezo     time;
   vTermino    time;
   vEmpezo1    time;
   vTermino1   time;
  vError text; -- periodo anterior del cálculo
  vagrup_valorizar_indexar record;

begin
  vEmpezo:=clock_timestamp();
  set search_path = ccc, cvp, comun, public;
  Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalcularCCCUnPeriodo', pTipo:='comenzo');
  execute Cal_CCC_Borrar(pPeriodo, pCalculo);
  execute Cal_CCC_Copiar(pPeriodo, pCalculo);

  analyze cvp.CalGru;
  vTermino1:=clock_timestamp();
  
  if pCalculo=20 then
    for vagrup_valorizar_indexar IN
       select agrupacion, valoriza --, case when agrupacion='A' then true else false end AS actcalprod
         from agrupaciones_ccc
         where calcular_junto_grupo='Z'
         order by agrupacion
    loop
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_CCC_Valorizar(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion/*, vagrup_valorizar_indexar.actcalprod*/);
      end if;
    end loop;
  end if;

  vTermino:=clock_timestamp();
  Raise Notice '%', 'CALCULO CCC COMPLETO: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalcularCCCUnPeriodo', pTipo:='finalizo');
end;
$BODY$;

--------------------------
CREATE OR REPLACE FUNCTION cvp.CalcularUnPeriodo(
    pPeriodo text,
    pCalculo integer)
    RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
as
$BODY$
declare
   vEmpezo     time;  
   vTermino    time;  
   vEmpezo1    time;  
   vTermino1   time;  
  vError text; -- periodo anterior del cálculo
  vPeriodo_1 text;
  vEsPeriodobase text;
  vRellenante_de integer;
  v_para_rellenado_de_base boolean;
  vagrup_valorizar_indexar record;
  
begin
  vEmpezo:=clock_timestamp(); 
  set search_path = cvp, comun, public;
  Raise Notice '--------------- COMIENZA UN CÁLCULO % %',pPeriodo,pCalculo;  
  select Calculo_ControlarAbierto(pPeriodo, pCalculo) into vError;
  select PeriodoAnterior, EsPeriodoBase, para_rellenado_de_base, Rellenante_de
    into vPeriodo_1, vEsPeriodobase, v_para_rellenado_de_base, vRellenante_de
    from calculos c inner join calculos_def cd on c.calculo=cd.calculo
    where c.periodo=pPeriodo
      and c.calculo=pCalculo;
  if vError is not null then
      return vError;
  end if;
  execute Calculo_Borrar(pPeriodo, pCalculo);
  execute Cal_Copiar(pPeriodo, pCalculo);
  execute CalObs_Promedio(pPeriodo, pCalculo);
  -- execute CalObs_ImpPerBase(pPeriodo, pCalculo); 
  execute CalObs_Rellenar(pPeriodo, pCalculo);
  execute CalDiv_Rellenar(pPeriodo, pCalculo); 
  execute CalDiv_Contar(pPeriodo, pCalculo); 
  if vEsPeriodobase='S' and vRellenante_de is not null then
    update CalProd set CantPerAltaAuto=0, CantPerBajaAuto=999 where periodo=pPeriodo and calculo=pCalculo;
    -- update CalDiv set UmbralPriImp=0, UmbralDescarte=0 where periodo=pPeriodo and calculo=pCalculo;
  end if;
  --if pPeriodo=vPeriodo_1 then
  --optimizar la ejecución de cálculos en forma concurrente
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalObs;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalObs: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalProd;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalProd: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalDiv;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalDiv: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  vEmpezo1:=clock_timestamp(); 
  analyze cvp.CalGru;
  vTermino1:=clock_timestamp();  
  Raise Notice '%', 'analyze CalGru: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  --end if;
  if v_para_rellenado_de_base or pPeriodo=vPeriodo_1 then
      vEmpezo1:=clock_timestamp(); 
      update CalObs set AntiguedadIncluido=1, AntiguedadExcluido=null
          , AntiguedadConPrecio=CASE WHEN PromObs IS NULL THEN NULL ELSE 1 END
          , AntiguedadSinPrecio=CASE WHEN PromObs IS NULL THEN 1 ELSE NULL END
          , SinDatosEstacional=CASE WHEN PromObs IS NULL THEN 100 ELSE NULL END
        where periodo=pPeriodo and calculo=pCalculo;
      vTermino1:=clock_timestamp();  
      Raise Notice '%', 'update: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);  
  else
      execute CalObs_AltasyBajas(pPeriodo, pCalculo);
  end if;  
  execute CalDiv_PromPriImp(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  execute CalDiv_Bajar(pPeriodo, pCalculo);
  execute CalObs_PriImp(pPeriodo, pCalculo);
  execute CalDiv_PromSegImp(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  if pPeriodo=vPeriodo_1 and v_para_rellenado_de_base then
    update CalProd set indice=100, indicePrel=100 where calculo=pCalculo and periodo=pPeriodo;
    update CalGru set indice=100, indicePrel=100 where calculo=pCalculo and periodo=pPeriodo;
  else
    execute CalProd_Indexar(pPeriodo, pCalculo);
  end if;
  -- execute CalProd_Valorizar(pPeriodo, pCalculo);
  execute CalGru_SegImp(pPeriodo, pCalculo);
  execute CalObs_SegImp_PerBase(pPeriodo, pCalculo);
  execute CalObs_SegImp(pPeriodo, pCalculo);
  execute CalDiv_PromFinal(pPeriodo, pCalculo);
  execute CalDiv_Subir(pPeriodo, pCalculo);
  execute CalProd_Indexar(pPeriodo, pCalculo);
  -- execute CalProd_Valorizar(pPeriodo, pCalculo);
  execute CalGru_Indexar(pPeriodo, pCalculo);
  -- execute CalGru_Valorizar(pPeriodo, pCalculo);
  execute CalGru_Info(pPeriodo, pCalculo);
   
  if pCalculo= 20 and vEsPeriodobase = 'N' /*0*/ then
    for vagrup_valorizar_indexar IN
       select agrupacion, valoriza, case when agrupacion='A' then true else false end AS actcalprod
         from agrupaciones
         where calcular_junto_grupo='Z'
         order by agrupacion
    loop
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_Canasta_Valorizar(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion, vagrup_valorizar_indexar.actcalprod); 
      else   
        execute CalGru_Indexar_Otro(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion); 
        execute CalGru_Info_Otro(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion); 
      end if;  
    end loop;    
  
  end if;
  execute ccc.CalcularCCCUnPeriodo(pPeriodo, pCalculo);
  execute Cal_Control(pPeriodo, pCalculo);
  vTermino:=clock_timestamp();  
  Raise Notice '%', 'CALCULO COMPLETO: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);  
  return 'Calculo completo en '||(vTermino - vEmpezo);
end;
$BODY$;
-------------------
--calculo tradicional y cálculo de canasta juntos, julio 2026
update cvp.calculos set fechacalculo = current_timestamp::timestamp without time zone
where periodo = 'a2026m08' and calculo = 20;
--------------
