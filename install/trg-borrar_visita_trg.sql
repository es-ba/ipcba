CREATE OR REPLACE FUNCTION borrar_visita_trg()
  RETURNS trigger AS
$BODY$
DECLARE
vhaymasvisitas INTEGER;
BEGIN
if new.confirma is distinct from old.confirma AND new.confirma then
  --No tiene que haber otra visita mayor
  SELECT distinct 1 INTO vhaymasvisitas
   FROM cvp.relvis a
     WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita>NEW.visita AND a.formulario=NEW.formulario; 
  IF vhaymasvisitas = 1 THEN
    RAISE EXCEPTION 'Se quiere borrar una visita que no es la última: per % inf % for % vis %',new.periodo,new.informante,new.formulario,new.visita;
  ELSE
    DELETE FROM cvp.relatr
        WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and producto in 
        (SELECT producto FROM cvp.relpre WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and formulario = new.formulario);
    DELETE FROM cvp.relpre
        WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and formulario = new.formulario;
    UPDATE cvp.relpre set ultima_visita = true
        WHERE periodo = new.periodo and informante = new.informante and visita = new.visita-1 and formulario = new.formulario;
    DELETE FROM cvp.relvis
        WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and formulario = new.formulario;
    UPDATE cvp.relvis set ultima_visita = true
        WHERE periodo = new.periodo and informante = new.informante and visita = new.visita-1 and formulario = new.formulario;
  END IF;
end if;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER novdelvis_borrar_trg 
  BEFORE UPDATE ON novdelvis 
  FOR EACH ROW EXECUTE PROCEDURE borrar_visita_trg();