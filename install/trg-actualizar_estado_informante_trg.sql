-- UTF8:Sí 
CREATE OR REPLACE FUNCTION actualizar_estado_informante_trg()
  RETURNS trigger LANGUAGE plpgsql VOLATILE SECURITY DEFINER AS
$BODY$

DECLARE
 vescierredefinitivoinf cvp.razones.escierredefinitivoinf%type;
 vcierre text;
 vestado text;
 vexiste integer;

BEGIN
IF OLD.razon IS DISTINCT FROM NEW.razon THEN
    SELECT escierredefinitivoinf INTO vescierredefinitivoinf
      FROM  cvp.razones 
      WHERE razon=NEW.razon;
      
    SELECT 1, string_agg(distinct coalesce(escierredefinitivoinf,'N'),'|') INTO vexiste, vcierre
      FROM cvp.relvis r left join cvp.razones z using(razon)
      WHERE periodo = NEW.periodo AND informante = NEW.informante AND formulario <> NEW.formulario and ultima_visita
      GROUP BY informante;

    IF vescierredefinitivoinf='S' THEN
       IF vexiste = 1 THEN
         IF vcierre IS DISTINCT FROM 'S' THEN
           vestado = 'Activo';
         ELSE
           vestado = 'Inactivo';
         END IF;
       ELSE
         vestado = 'Inactivo';
       END IF;
    ELSE
       vestado = 'Activo';
    END IF;
    UPDATE cvp.informantes SET estado = vestado WHERE informante = new.informante and estado is distinct from vestado;
END IF;
RETURN NEW;

END;
$BODY$;

CREATE TRIGGER relvis_actualiza_estado_informante_trg
  BEFORE UPDATE
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE actualizar_estado_informante_trg();