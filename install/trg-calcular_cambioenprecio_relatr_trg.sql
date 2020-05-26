CREATE OR REPLACE FUNCTION cvp.calcular_cambioenprecio_relatr_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE 
  vcambio cvp.relpre.cambio%type;
BEGIN
 SELECT case when count(*)=0 THEN NULL ELSE 'C' END INTO vcambio
    FROM cvp.relatr_1 a
    JOIN cvp.atributos t using (atributo)
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND  a.producto=NEW.producto AND a.observacion=NEW.observacion and a.valor <> a.valor_1
        AND not t.es_vigencia; 

    UPDATE cvp.relpre  
      SET cambio=vcambio
      WHERE periodo=NEW.periodo AND informante=NEW.informante 
        AND visita=NEW.visita AND producto=NEW.producto AND observacion=NEW.observacion;     
  RETURN NULL;
 
END;
$BODY$;

CREATE TRIGGER relatr_calcula_cambio_precio_trg
    AFTER UPDATE OR INSERT
    ON cvp.relatr
    FOR EACH ROW
    EXECUTE PROCEDURE cvp.calcular_cambioenprecio_relatr_trg();