CREATE FUNCTION verificar_generar_periodo() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  dummy text;
  vperiodoanterior text;
  vexiste integer; 
BEGIN
  vperiodoanterior := cvp.moverperiodos(NEW.periodo,-1);
  SELECT 1 INTO vexiste
  FROM cvp.periodos
  WHERE periodo = vperiodoanterior;
  IF vexiste = 1 THEN
    NEW.periodoanterior:= vperiodoanterior;
  ELSE
    NEW.periodoanterior:= NULL;
  END IF;
  if TG_OP='UPDATE' then
    if OLD.fechageneracionperiodo is null and NEW.fechageneracionperiodo is not null
       or OLD.fechageneracionperiodo<>NEW.fechageneracionperiodo
    then
       dummy:=cvp.generar_periodo(new.periodo,new.fechageneracionperiodo); 
    end if;
  end if;
  RETURN NEW;
END;
$$;

CREATE TRIGGER periodos_gen_trg 
   BEFORE INSERT OR UPDATE 
   ON periodos 
   FOR EACH ROW EXECUTE PROCEDURE verificar_generar_periodo();