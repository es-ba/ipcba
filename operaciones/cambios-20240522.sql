set search_path = cvp;

CREATE OR REPLACE FUNCTION validar_habilitado_trg()
    RETURNS trigger AS
$BODY$
DECLARE
  vPeriodo_1     text;  
  vIngresando    character varying(1); 
  vabierto       character varying(1);
  vesadministrador integer;
  vescoordinacion integer;
BEGIN

SELECT CASE WHEN usu_rol = 'analista' THEN 1 END, CASE WHEN usu_rol in ('coordinador','programador') THEN 1 END INTO vesadministrador, vescoordinacion
  FROM ipcba.usuarios
  WHERE usu_usu=current_user; 
  
IF OLD.habilitado IS DISTINCT FROM NEW.habilitado THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
    IF NEW.habilitado='S' THEN -- estoy abriendo la habilitación
      SELECT  abierto INTO vabierto
      FROM cvp.calculos c 
	  JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
      WHERE periodo=NEW.Periodo AND principal ;
      IF vabierto='N' THEN
          RAISE EXCEPTION 'ERROR no se puede habilitar el ingreso del periodo "%" porque el calculo esta cerrado', new.periodo;
      END IF; 
      SELECT periodo, ingresando INTO vperiodo_1, vingresando
          FROM cvp.periodos
          WHERE periodoanterior=NEW.Periodo ;
      IF vingresando='N' THEN
        RAISE EXCEPTION 'ERROR no se puede habilitar el ingreso porque el siguiente periodo "%" esta cerrado', vperiodo_1;
      END IF;
    END IF;
  ELSE 
   RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF; 
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql';

------------------------------------------
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

SELECT CASE WHEN usu_rol = 'analista' THEN 1 END, CASE WHEN usu_rol in ('coordinador','programador') THEN 1 END INTO vesadministrador, vescoordinacion
  FROM ipcba.usuarios
  WHERE usu_usu=current_user; 
  
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
      FROM cvp.calculos c 
	  JOIN cvp.calculos_def cd on c.calculo = cd.calculo      
	  WHERE periodo=NEW.Periodo AND principal ;
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
  LANGUAGE 'plpgsql';
  
---------------------------------------------------------------
CREATE OR REPLACE FUNCTION hisc_tareas_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','tareas','tarea','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.tarea),new.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','tareas','encuestador','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.encuestador),new.encuestador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','tareas','activa','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.activa),new.activa);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','tareas','periodobaja','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.periodobaja),new.periodobaja);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','tareas','operativo','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.operativo),new.operativo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','tareas','recepcionista','I',new.tarea,new.tarea,'I:'||comun.a_texto(new.recepcionista),new.recepcionista);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.tarea IS DISTINCT FROM old.tarea THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','tareas','tarea','U',new.tarea,new.tarea,comun.A_TEXTO(old.tarea)||'->'||comun.a_texto(new.tarea),old.tarea,new.tarea);
            END IF;    
            IF new.encuestador IS DISTINCT FROM old.encuestador THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','tareas','encuestador','U',new.tarea,new.tarea,comun.A_TEXTO(old.encuestador)||'->'||comun.a_texto(new.encuestador),old.encuestador,new.encuestador);
            END IF;
            IF new.activa IS DISTINCT FROM old.activa THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','tareas','activa','U',new.tarea,new.tarea,comun.A_TEXTO(old.activa)||'->'||comun.a_texto(new.activa),old.activa,new.activa);
            END IF;
            IF new.periodobaja IS DISTINCT FROM old.periodobaja THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','tareas','periodobaja','U',new.tarea,new.tarea,comun.A_TEXTO(old.periodobaja)||'->'||comun.a_texto(new.periodobaja),old.periodobaja,new.periodobaja);
            END IF;
            IF new.operativo IS DISTINCT FROM old.operativo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','tareas','operativo','U',new.tarea,new.tarea,comun.A_TEXTO(old.operativo)||'->'||comun.a_texto(new.operativo),old.operativo,new.operativo);
            END IF;
            IF new.recepcionista IS DISTINCT FROM old.recepcionista THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','tareas','recepcionista','U',new.tarea,new.tarea,comun.A_TEXTO(old.recepcionista)||'->'||comun.a_texto(new.recepcionista),old.recepcionista,new.recepcionista);
            END IF;
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','tareas','tarea','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.tarea),old.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','tareas','encuestador','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.encuestador),old.encuestador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','tareas','activa','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.activa),old.activa);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','tareas','periodobaja','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.periodobaja),old.periodobaja);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','tareas','operativo','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.operativo),old.operativo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','tareas','recepcionista','D',old.tarea,old.tarea,'D:'||comun.a_texto(old.recepcionista),old.recepcionista);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     
$BODY$;

ALTER FUNCTION hisc_tareas_trg()
    OWNER TO cvpowner;
  