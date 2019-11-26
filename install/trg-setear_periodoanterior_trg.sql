CREATE OR REPLACE FUNCTION setear_periodoanterior_trg()
  RETURNS trigger AS
$BODY$
BEGIN
  NEW.periodoanterior:= cvp.moverperiodos(NEW.periodo,-1);
  NEW.ano:= substr(NEW.periodo,2,4);
  NEW.mes:= substr(NEW.periodo,7,2);
  NEW.ingresando:= 'S';
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER periodos_periodoanterior_trg
  BEFORE INSERT
  ON periodos
  FOR EACH ROW
  EXECUTE PROCEDURE setear_periodoanterior_trg();
