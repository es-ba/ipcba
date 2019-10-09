
CREATE FUNCTION verificar_generar_panel() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  dummy text;
BEGIN
  if TG_OP='UPDATE' then
    if OLD.fechageneracionpanel is null and NEW.fechageneracionpanel is not null
       or OLD.fechageneracionpanel<>NEW.fechageneracionpanel
    then
       dummy:=cvp.generar_panel(new.periodo,new.panel,new.fechasalida,new.fechageneracionpanel); 
    end if;
  end if;
  RETURN NEW;
END;
$$;

CREATE TRIGGER relpan_gen_trg 
   BEFORE INSERT OR UPDATE 
   ON relpan 
   FOR EACH ROW EXECUTE PROCEDURE verificar_generar_panel();
