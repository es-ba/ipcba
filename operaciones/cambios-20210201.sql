set search_path = cvp;

DROP TABLE IF EXISTS cambiopantar_det CASCADE;

CREATE TABLE cambiopantar_det
(
    id_lote integer NOT NULL,
    periodo character varying(11) NOT NULL,
    informante integer NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    panel_nuevo integer NOT NULL,
    tarea_nueva integer NOT NULL,
    PRIMARY KEY (id_lote, periodo, informante, panel, tarea),
    FOREIGN KEY (id_lote) REFERENCES cambiopantar_lote (id_lote)
);

ALTER TABLE cambiopantar_det
    OWNER to cvpowner;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cambiopantar_det TO cvp_administrador;

CREATE OR REPLACE FUNCTION verificar_procesado_lote_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$

DECLARE
 vprocesado timestamp:=null;
 vid_lote integer:= null;
BEGIN
IF TG_OP = 'DELETE' THEN
 vid_lote = OLD.id_lote;
ELSE
 vid_lote = NEW.id_lote;
END IF;
SELECT fechaprocesado INTO vprocesado 
FROM cvp.cambiopantar_lote 
WHERE id_lote = vid_lote;  
IF vprocesado IS NOT NULL THEN
   RAISE EXCEPTION 'El lote ya fue procesado, no puede cambiar el detalle';
   RETURN NULL;
END IF;
if TG_OP='DELETE' then
   RETURN OLD;
ELSE   
   RETURN NEW;
END IF;
END;
$BODY$;

ALTER FUNCTION verificar_procesado_lote_trg()
    OWNER TO cvpowner;

CREATE TRIGGER cambiopantar_det_abm_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cambiopantar_det
    FOR EACH ROW
    EXECUTE PROCEDURE verificar_procesado_lote_trg();