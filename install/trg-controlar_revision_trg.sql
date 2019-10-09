
CREATE FUNCTION controlar_revision_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF OLD.revisado IS DISTINCT FROM NEW.revisado and NEW.calculo > 0 /*es una copia del calculo*/ THEN
   RAISE EXCEPTION ' No es posible modificar el valor de revisado en una copia del cálculo';
   RETURN NULL;
END IF;
RETURN NEW;
END;
$$;

CREATE TRIGGER calprodresp_controlar_revision_trg 
  BEFORE UPDATE ON calprodresp 
  FOR EACH ROW EXECUTE PROCEDURE controlar_revision_trg();