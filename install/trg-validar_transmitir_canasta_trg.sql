CREATE OR REPLACE FUNCTION validar_transmitir_canasta_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vesadministrador integer;
  vescoordinacion integer;
  vcalculoppal integer;
  vabiertosiguiente character varying(1):= null;
BEGIN

SELECT CASE WHEN usu_rol = 'analista' THEN 1 END, CASE WHEN usu_rol in ('coordinador','programador') THEN 1 END INTO vesadministrador, vescoordinacion
  FROM ipcba.usuarios
  WHERE usu_usu=current_user; 

SELECT calculo INTO vcalculoppal
  FROM cvp.calculos_def 
  WHERE principal;

SELECT abierto INTO vabiertosiguiente
  FROM cvp.calculos 
  WHERE periodo = cvp.moverperiodos(NEW.periodo,1) AND calculo = vcalculoppal;
  
IF OLD.transmitir_canastas IS DISTINCT FROM NEW.transmitir_canastas AND NEW.transmitir_canastas='N' THEN
   NEW.fechatransmitircanastas = null;
END IF;

IF OLD.transmitir_canastas IS DISTINCT FROM NEW.transmitir_canastas AND NEW.transmitir_canastas='S' THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
    IF NEW.abierto = 'N' THEN
        IF NEW.calculo <> vcalculoppal THEN
            RAISE EXCEPTION 'ERROR No se pueden transmitir canastas para cálculos provisorios';
        ELSE
            IF vabiertosiguiente = 'N' THEN
                NEW.fechatransmitircanastas = CURRENT_TIMESTAMP(3);
            ELSE
                RAISE EXCEPTION 'ERROR No se pueden transmitir canastas si el cálculo siguiente no está cerrado';
            END IF;
        END IF;
    ELSE
     RAISE EXCEPTION 'ERROR No se pueden transmitir canastas porque aún no se cerró el cálculo';
    END IF;
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY INVOKER;
  
CREATE TRIGGER calculos_controlar_transmitir_canastas_trg
  BEFORE UPDATE
  ON calculos
  FOR EACH ROW
  EXECUTE PROCEDURE validar_transmitir_canasta_trg();

