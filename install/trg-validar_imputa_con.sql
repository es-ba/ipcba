CREATE OR REPLACE FUNCTION validar_imputacon_trg()
  RETURNS trigger AS
$BODY$
DECLARE
vhay INTEGER;

BEGIN
IF tg_op = 'INSERT' THEN  
 IF new.imputacon is not null THEN
   SELECT 1 INTO vhay
      FROM cvp.grupos g JOIN cvp.calculos_def c on c.calculo=0
      WHERE g.grupo=new.imputacon AND g.esproducto='N' AND g.agrupacion=c.agrupacionPrincipal;

   IF vhay IS NULL THEN
     RAISE EXCEPTION 'Imputacon % no es un Grupo valido ', new.imputacon;
     RETURN NULL;
   END IF; 
 END IF;
END IF;
IF tg_op = 'UPDATE' THEN  
 IF new.imputacon is distinct from old.imputacon THEN
   SELECT 1 INTO vhay
      FROM cvp.grupos g JOIN cvp.calculos_def c on c.calculo=0
      WHERE g.grupo=new.imputacon AND g.esproducto='N' AND g.agrupacion=c.agrupacionPrincipal;

   IF vhay IS NULL THEN
     RAISE EXCEPTION 'Imputacon % no es un Grupo valido ', new.imputacon;
     RETURN NULL;
   END IF; 
 END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER productos_imputacon_trg
  BEFORE INSERT OR UPDATE
  ON productos
  FOR EACH ROW
  EXECUTE PROCEDURE validar_imputacon_trg();
