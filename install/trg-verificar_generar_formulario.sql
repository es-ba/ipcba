CREATE OR REPLACE FUNCTION verificar_generar_formulario()
  RETURNS trigger AS
$BODY$
DECLARE
  -- V080923
  -- Modif: V100707
  dummy text;
BEGIN
  IF TG_OP='UPDATE' THEN
    IF (OLD.razon IS DISTINCT FROM NEW.razon OR NEW.preciosgenerados) AND NEW.visita = 1 THEN
       NEW.fechageneracion:= current_timestamp(3);
       dummy:=cvp.generar_formulario(new.periodo,new.informante,new.formulario,new.fechageneracion); 
	   NEW.preciosgenerados:= true;
    END IF;
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_gen_trg 
   BEFORE UPDATE 
   ON relvis 
   FOR EACH ROW EXECUTE PROCEDURE verificar_generar_formulario();
