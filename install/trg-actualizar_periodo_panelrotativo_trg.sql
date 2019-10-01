-- UTF8:Sí
CREATE FUNCTION actualizar_periodo_panelrotativo_trg()
  RETURNS trigger LANGUAGE plpgsql VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE  
   vposinf cvp.razones.espositivoinformante%type;
   vposform cvp.razones.espositivoformulario%type;
BEGIN
  SELECT espositivoinformante, espositivoformulario INTO vposinf, vposform
    FROM  cvp.razones 
    WHERE razon=NEW.razon;   
    IF (vposinf='S' AND vposform='S') THEN
      UPDATE cvp.relpan SET periodoparapanelrotativo=new.periodo
      WHERE  panel=new.panel AND periodo=new.periodo ;
    END IF;
  RETURN NEW;
END;
$BODY$;

CREATE TRIGGER relvis_actualiza_periodo_panelrotativo
    BEFORE UPDATE 
    ON relvis
    FOR EACH ROW
    EXECUTE PROCEDURE actualizar_periodo_panelrotativo_trg();
