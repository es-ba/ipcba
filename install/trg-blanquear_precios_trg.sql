CREATE OR REPLACE FUNCTION blanquear_precios_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  v_precio double precision;
  v_cambio character varying(1);
BEGIN
if new.confirma is distinct from old.confirma then
    if new.confirma then 
        SELECT precio, cambio INTO v_precio, v_cambio
        FROM cvp.relpre
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
        UPDATE cvp.relpre SET 
        precio     = CASE WHEN v_precio is not null then null else v_precio END, 
        tipoprecio = 'M', 
        cambio     = CASE WHEN v_cambio is not null then null else v_cambio END
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
    else
        UPDATE cvp.relpre SET precio = precioblanqueado, tipoprecio = tipoprecioblanqueado, cambio = cambioblanqueado,
               comentariosrelpre = comentariosrelpreblanqueado
        FROM (SELECT precio precioblanqueado, tipoprecio tipoprecioblanqueado, cambio cambioblanqueado, comentariosrelpre comentariosrelpreblanqueado
              FROM cvp.blapre
              WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita) b 
        WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita;
    end if;
end if;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER novpre_blanquea_trg
  BEFORE UPDATE
  ON novpre
  FOR EACH ROW EXECUTE PROCEDURE blanquear_precios_trg();