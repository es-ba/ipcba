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
