--CALCULO DE LAS CANASTAS AISTADAS DEL CALCULO PRINCIPAL
set search_path = cvp;
set role cvpowner;

ALTER TABLE calculos ADD COLUMN fechacalculo_ccc timestamp without time zone; --fecha en que se calculó la canasta aislada del calculo principal 
ALTER TABLE calculos ADD COLUMN abierto_ccc cvp.sino_dom DEFAULT 'S'; 
--historico:
do $SQL_ENANCE$
 begin
 PERFORM ccc.enance_table('calculos','periodo,calculo');
 end
$SQL_ENANCE$;
--agrego nueva forma de registrar los cambios, deshabilito la forma anterior
ALTER TABLE calculos DISABLE TRIGGER hisc_trg;

----------------------------------------------------
CREATE OR REPLACE FUNCTION verificar_lanzamiento_calculo_ccc()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
DECLARE
  dummy text;
BEGIN
  if TG_OP='UPDATE' then
    if OLD.fechacalculo_ccc is null and NEW.fechacalculo_ccc is not null
       or OLD.fechacalculo_ccc<>NEW.fechacalculo_ccc
    then
       dummy:=ccc.CalcularCCCUnPeriodo(new.periodo,new.calculo); 
    end if;
  end if;
  RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER calculos_ccc_lan_trg
    BEFORE INSERT OR UPDATE 
    ON calculos
    FOR EACH ROW
    EXECUTE FUNCTION verificar_lanzamiento_calculo_ccc();
----------------------------------------------------
CREATE OR REPLACE FUNCTION ccc.verificar_abierto_ccc()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    vabierto_ccc varchar(1);
    vPeriodo varchar(20);
    vtabla      varchar(100);
BEGIN
    vtabla= TG_TABLE_NAME;
    IF TG_OP='DELETE' THEN
       vPeriodo:=OLD.Periodo;
    ELSE
       vPeriodo:=NEW.Periodo;
    END IF;
    SELECT abierto_ccc INTO vabierto_ccc
      FROM cvp.calculos c 
      JOIN cvp.calculos_def cd ON c.calculo = cd.calculo
      WHERE c.periodo = vPeriodo and principal;
    IF vabierto_ccc = 'N' then
        RAISE EXCEPTION 'Calculo de Canasta Cerrado. Actualizacion no permitida en tabla %',vtabla;
        RETURN NULL;
    END IF;    
    if TG_OP='DELETE' then
       RETURN OLD;
    ELSE   
       RETURN NEW;
    END IF;
END;
$BODY$;

set search_path = ccc;

CREATE OR REPLACE TRIGGER novservdom_abi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON ccc.novservdom
    FOR EACH ROW
    EXECUTE FUNCTION ccc.verificar_abierto_ccc();
------------------------------------------------------------------
set search_path = cvp;

UPDATE calculos c SET abierto_ccc = cc.abierto
FROM calculos cc 
WHERE c.calculo = cc.calculo and c.periodo = cc.periodo;

-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION validar_abrir_cerrar_calculo_ccc_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vPeriodo_1  text;  
  vCalculo_1  integer;
  vAbierto_1  character varying(1);
  vrecsig     record;

BEGIN

IF OLD.abierto_ccc IS DISTINCT FROM NEW.abierto_ccc AND NEW.abierto_ccc='N' THEN
      SELECT periodoanterior, calculoanterior INTO vPeriodo_1, vCalculo_1
        FROM cvp.Calculos
        WHERE periodo=NEW.periodo AND calculo=NEW.calculo ;
      IF (vPeriodo_1 IS NULL AND vCalculo_1 IS NULL) OR (vPeriodo_1=NEW.periodo AND vCalculo_1=NEW.calculo) THEN -- periodo inicial
        vAbierto_1='N';
      ELSE 
        SELECT abierto_ccc INTO vAbierto_1
          FROM cvp.Calculos
          WHERE periodo=vPeriodo_1 AND calculo=vCalculo_1;
      END IF;
      IF vAbierto_1 ='S' THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo ccc si no esta cerrado el anterior';
      END IF;
      IF NEW.abierto='S'  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo ccc si no esta cerrado el calculo ipc correspondinete';
      END IF;
END IF;
IF OLD.abierto_ccc IS DISTINCT FROM NEW.abierto_ccc AND NEW.abierto_ccc='S' THEN 
      FOR vrecsig in
        SELECT periodo, calculo, abierto_ccc 
          FROM cvp.Calculos
          WHERE periodoanterior=NEW.Periodo AND calculoanterior=NEW.Calculo 
            AND (periodoanterior<>Periodo OR calculoanterior<>Calculo)
      LOOP
          IF vrecsig.abierto_ccc='N' THEN
            RAISE EXCEPTION 'ERROR no se puede reabrir porque el siguiente periodo "%" esta cerrado', vrecsig.periodo;
          END IF;
      END LOOP;   
END IF;
RETURN NEW;
END;

$BODY$
  LANGUAGE plpgsql;
  
ALTER FUNCTION validar_abrir_cerrar_calculo_ccc_trg()
    OWNER TO cvpowner;

CREATE TRIGGER calculos_controlar_abrir_cerrar_calculo_ccc_trg 
   BEFORE UPDATE 
   ON calculos 
   FOR EACH ROW EXECUTE PROCEDURE validar_abrir_cerrar_calculo_ccc_trg();
