CREATE OR REPLACE FUNCTION correr_normalizacion_moneda_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vprodmoneda record;
BEGIN 
 FOR vprodmoneda IN
   SELECT producto, atributo
     FROM cvp.prodatr
     WHERE tiponormalizacion='Moneda'
 LOOP    
   UPDATE cvp.relatr ra SET valor=valor
     FROM cvp.relpre p 
     LEFT JOIN cvp.tipopre t ON p.tipoprecio = t.tipoprecio 
     WHERE ra.periodo=NEW.periodo AND ra.producto=vprodmoneda.producto AND ra.atributo=vprodmoneda.atributo
       and p.periodo = ra.periodo and p.producto = ra.producto and p.observacion = ra.observacion and p.informante = ra.informante and p.visita = ra.visita 
       and not t.registrablanqueo;  
 END LOOP;   
 RETURN NEW;
END;  
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relmon_normaliza_moneda_trg
  AFTER UPDATE
  ON relmon
  FOR EACH ROW
  EXECUTE PROCEDURE correr_normalizacion_moneda_trg();