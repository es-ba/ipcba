set search_path = cvp;
CREATE OR REPLACE FUNCTION validar_imputacon_trg() RETURNS trigger
    LANGUAGE 'plpgsql' SECURITY DEFINER
AS $BODY$
DECLARE
vhay INTEGER;

BEGIN
IF tg_op = 'INSERT' THEN  
 IF new.imputacon is not null THEN
   SELECT 1 INTO vhay
      FROM cvp.grupos g JOIN cvp.calculos_def c on c.principal
      WHERE g.grupo=new.imputacon AND g.esproducto='N' AND g.agrupacion=c.agrupacionPrincipal;

   IF vhay IS NULL THEN
     RAISE EXCEPTION 'Imputacon % no es un Grupo valido ', new.imputacon;
     RETURN NULL;
   END IF; 
 END IF;
END IF;
IF tg_op = 'UPDATE' THEN  
 IF new.imputacon is distinct from old.imputacon and new.imputacon is not null THEN
   SELECT 1 INTO vhay
      FROM cvp.grupos g JOIN cvp.calculos_def c on c.principal
      WHERE g.grupo=new.imputacon AND g.esproducto='N' AND g.agrupacion=c.agrupacionPrincipal;

   IF vhay IS NULL THEN
     RAISE EXCEPTION 'Imputacon % no es un Grupo valido ', new.imputacon;
     RETURN NULL;
   END IF; 
 END IF;
END IF;
RETURN NEW;

END;
$BODY$;
