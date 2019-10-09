CREATE OR REPLACE FUNCTION borrar_precios_trg()
  RETURNS trigger AS
$BODY$
DECLARE
vesultimavisita INTEGER;
BEGIN
if new.confirma is distinct from old.confirma AND new.confirma then
  --No tiene que haber otra visita mayor con la misma observacion
  SELECT 1 INTO vesultimavisita
   FROM cvp.relpre a
     WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
       AND a.producto=NEW.producto AND a.observacion=NEW.observacion and a.ultima_visita; 
  IF vesultimavisita = 1 THEN
    DELETE FROM cvp.relatr
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
    DELETE FROM cvp.relpre
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
    UPDATE cvp.relpre set ultima_visita = true
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita-1;
  ELSE
    RAISE EXCEPTION 'Se quiere borrar una observación que no corresponde a la última visita: % per % inf % prod % obs %'
          ,new.visita,new.periodo,new.informante,new.producto,new.observacion;
  END IF;
end if;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER novdelobs_borrar_trg 
  BEFORE UPDATE ON novdelobs 
  FOR EACH ROW EXECUTE PROCEDURE borrar_precios_trg();