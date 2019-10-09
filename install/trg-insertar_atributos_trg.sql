CREATE OR REPLACE FUNCTION insertar_atributos_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vHay INTEGER; 
  vvisitaAnterior INTEGER;
BEGIN
IF new.visita>1 and NEW.ultima_visita = TRUE THEN
    vvisitaAnterior = new.visita -1;

    insert into cvp.relatr(periodo, producto, observacion, informante, visita, atributo, valor, validar_con_valvalatr)
     select r.periodo, r.producto, r.observacion, r.informante, new.visita, r.atributo,
              CASE WHEN a.Es_Vigencia THEN 0::text ELSE r.valor END, r.validar_con_valvalatr 
     from cvp.relatr r
          inner join cvp.atributos a on r.atributo = a.atributo
     where periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and
         visita = vvisitaAnterior; 

END IF;
  
  RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relpre_inserta_atributos_trg
  AFTER INSERT
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE insertar_atributos_trg();