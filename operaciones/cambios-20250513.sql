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
  vvisibles integer;
  vseleccionadas integer;
  vfechas_visibles text;
  vfechas_seleccionadas text;
  
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

      SELECT SUM(CASE WHEN visible_planificacion = 'S' THEN 1 END) as visibles,
        string_agg(CASE WHEN visible_planificacion = 'S' THEN fecha::text END,'; ' order by fecha) fechas_visibles,
        SUM(CASE WHEN seleccionada_planificacion = 'S' THEN 1 END) as seleccionadas,
        string_agg(CASE WHEN seleccionada_planificacion = 'S' THEN fecha::text END,'; ' order by fecha) fechas_seleccionadas
        INTO vvisibles, vfechas_visibles, vseleccionadas, vfechas_seleccionadas
        FROM cvp.fechas 
        WHERE (visible_planificacion = 'S' OR seleccionada_planificacion = 'S')
        AND fecha >= (substr(NEW.periodo,2,4)||'-'||substr(NEW.periodo,7,2)||'-01')::date --primer día de NEW.periodo
        AND fecha < (substr(cvp.moverperiodos(NEW.periodo,1),2,4)||'-'||substr(cvp.moverperiodos(NEW.periodo,1),7,2)||'-01')::date; --primer día del siguiente de NEW.periodo
      IF vvisibles > 0 THEN
           RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" porque hay % fechas visibles para planificación. Por ejemplo % ' , new.periodo, vvisibles, vfechas_visibles;
      END IF;
      IF vseleccionadas > 0 THEN
           RAISE EXCEPTION 'ERROR no se puede Cerrar el periodo "%" porque hay % fechas seleccionadas para planificación. Por ejemplo % ' , new.periodo, vseleccionadas, vfechas_seleccionadas;
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
