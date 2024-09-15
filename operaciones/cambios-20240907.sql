set search_path = cvp;
ALTER TABLE novpre
ALTER COLUMN confirma DROP DEFAULT;

ALTER TABLE his.novpre
ALTER COLUMN confirma DROP DEFAULT;

CREATE OR REPLACE FUNCTION blanquear_precios_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  v_precio double precision;
  v_cambio character varying(1);
BEGIN
if TG_OP='UPDATE' AND new.confirma is distinct from old.confirma OR TG_OP='INSERT' then
    if new.confirma then 
        SELECT precio, cambio INTO v_precio, v_cambio
        FROM cvp.relpre
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
        UPDATE cvp.relpre SET 
        precio     = CASE WHEN v_precio is not null then null else v_precio END, 
        tipoprecio = 'M' 
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
    else
        UPDATE cvp.relpre SET precio = precioblanqueado, tipoprecio = tipoprecioblanqueado,
               comentariosrelpre = comentariosrelpreblanqueado
        FROM (SELECT precio precioblanqueado, tipoprecio tipoprecioblanqueado, 
              comentariosrelpre comentariosrelpreblanqueado
              FROM cvp.blapre
              WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita) b 
        WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita;
    end if;
end if;
RETURN NEW;
END;
$BODY$;

DROP TRIGGER novpre_blanquea_trg ON novpre;

CREATE TRIGGER novpre_blanquea_trg
  BEFORE INSERT OR UPDATE
  ON novpre
  FOR EACH ROW EXECUTE PROCEDURE blanquear_precios_trg();
  
GRANT INSERT, SELECT, UPDATE ON TABLE cvp.fechas TO cvp_recepcionista;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE cvp.licencias TO cvp_recepcionista;