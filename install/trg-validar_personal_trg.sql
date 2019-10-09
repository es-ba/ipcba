CREATE OR REPLACE FUNCTION validar_personal_trg()
  RETURNS trigger AS
$BODY$
/*
   V110407 Por parámetro del sistema se puede relajar el hecho de que sea Ingresador como Labor
   V100506
*/
DECLARE
 vlabor cvp.personal.labor%type;
 vSoloIngresaIngresador cvp.parametros.SoloIngresaIngresador%type;
BEGIN
  IF TG_OP='UPDATE' OR TG_OP='INSERT' THEN
    IF NEW.encuestador IS NOT NULL THEN
      vlabor:=cvp.recupera_labor(NEW.encuestador,'E');
      IF vlabor IS NULL THEN 
        RAISE EXCEPTION 'El código ingresado no pertenece a un Encuestador o no está activo';
        RETURN NULL;
      END IF;   
    END IF;
    IF NEW.supervisor IS NOT NULL THEN
      vlabor:=cvp.recupera_labor(NEW.supervisor,'S');
      IF vlabor IS NULL THEN 
        RAISE EXCEPTION 'El código ingresado no pertenece a un Supervisor o no está activo';
        RETURN NULL;
      END IF;   
    END IF;
    IF NEW.recepcionista IS NOT NULL THEN
      vlabor:=cvp.recupera_labor(NEW.recepcionista,'R');
      IF vlabor IS NULL THEN 
        RAISE EXCEPTION 'El código ingresado no pertenece a un Recepcionista o no está activo';
        RETURN NULL;
      END IF;   
    END IF;
    IF NEW.ingresador IS NOT NULL THEN --Ver porque el código se pone automáticamente
      SELECT SoloIngresaIngresador INTO vSoloIngresaIngresador
        FROM Parametros
        WHERE unicoregistro;
      IF vSoloIngresaIngresador='S' THEN
        vlabor:=cvp.recupera_labor(NEW.ingresador,'I');
        IF vlabor IS NULL THEN 
          RAISE EXCEPTION 'El código ingresado no pertenece a un Ingresador o no está activo';
          RETURN NULL;
        END IF;
      END IF;   
    END IF; 
  END IF ; 
  RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_personal_trg 
   BEFORE INSERT OR UPDATE 
   ON relvis 
   FOR EACH ROW EXECUTE PROCEDURE validar_personal_trg();
