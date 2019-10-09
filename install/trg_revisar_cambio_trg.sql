CREATE OR REPLACE FUNCTION revisar_cambio_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vcambios integer;
BEGIN
vcambios := 0;
SELECT count(*) INTO vcambios
  FROM cvp.relatr_1 
  WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion 
        and informante = new.informante and visita = new.visita and valor IS DISTINCT FROM valor_1;
if vcambios > 0 then
  UPDATE cvp.relpre SET cambio = 'C'
    WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
end if;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER novpre_cambio_trg
  AFTER INSERT
  ON novpre
  FOR EACH ROW
  EXECUTE PROCEDURE revisar_cambio_trg();
