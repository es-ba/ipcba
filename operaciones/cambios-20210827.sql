set search_path = cvp;
set role cvpowner;

CREATE OR REPLACE FUNCTION cvp.verificar_generar_ins_formulario()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE
  dummy text;
BEGIN
  IF NEW.preciosgenerados AND NEW.visita = 1 THEN
     NEW.fechageneracion:= current_timestamp(3);
     dummy:=cvp.generar_formulario(new.periodo,new.informante,new.formulario,new.fechageneracion); 
  END IF;
  UPDATE cvp.relvis SET preciosgenerados = false
  WHERE periodo = NEW.periodo AND informante = NEW.informante AND visita = NEW.visita AND formulario = NEW.formulario; 
  RETURN NEW;
END;
$BODY$;

CREATE TRIGGER relvis_gen_ins_trg
    AFTER INSERT 
    ON cvp.relvis
    FOR EACH ROW
    EXECUTE FUNCTION cvp.verificar_generar_ins_formulario();
