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

CREATE TRIGGER periodos_controlar_habilitado_trg
    BEFORE UPDATE
    ON periodos
    FOR EACH ROW
    EXECUTE PROCEDURE validar_habilitado_trg();
    
