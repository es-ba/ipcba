CREATE OR REPLACE FUNCTION verificar_lanzamiento_calculo() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  -- V080907
  dummy text;
BEGIN
  if TG_OP='UPDATE' then
    if OLD.fechacalculo is null and NEW.fechacalculo is not null
       or OLD.fechacalculo<>NEW.fechacalculo
    then
       dummy:=cvp.CalcularUnPeriodo(new.periodo,new.calculo); 
    end if;
  end if;
  RETURN NEW;
END;
$$;

CREATE TRIGGER calculos_lan_trg 
   BEFORE INSERT OR UPDATE 
   ON calculos 
   FOR EACH ROW EXECUTE PROCEDURE verificar_lanzamiento_calculo();
