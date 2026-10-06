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

UPDATE calculos c SET c.abierto_ccc = cc.abierto
FROM calculos cc 
WHERE c.calculo = cc.calculo and c.periodo = cc.periodo;