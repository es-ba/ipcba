CREATE OR REPLACE FUNCTION cambio_panel_tarea_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vgenerado integer:=null;
 vmaxperiododesde character varying(11);
 vmaxrazon integer;
 vpermitido boolean;
BEGIN
IF old.panel <> new.panel OR old.tarea <> new.tarea THEN --para que funcione al "importar" registros ya existentes
    --el panel al que me quiero mover debe estar generado
    SELECT distinct 1 INTO vgenerado
    FROM cvp.relvis 
    WHERE periodo = new.periodo and panel = new.panel;
    IF vgenerado is distinct from 1 THEN  
        RAISE EXCEPTION 'Falta generar el panel: % (periodo %)',new.panel, new.periodo;
        RETURN NULL;
    ELSE
        --el panel del que me quiero mover debe ser el último generado y puede tener (o no) formularios ingresados dependiendo de parametos.permitir_cualquier_cambio_panel_tarea
        SELECT maxperiodo, maxrazon, permitir_cualquier_cambio_panel_tarea INTO vmaxperiododesde, vmaxrazon, vpermitido
        FROM (SELECT MAX(periodo) maxperiodo FROM cvp.relvis WHERE panel = old.panel) v
        INNER JOIN cvp.parametros ON unicoregistro,
        LATERAL (SELECT MAX(razon) maxrazon FROM cvp.relvis WHERE periodo = maxperiodo AND panel = old.panel) r;
        IF new.periodo is distinct from vmaxperiododesde THEN
            RAISE EXCEPTION '% No es el último periodo generado para el panel: %',new.periodo, old.panel;
            RETURN NULL;
        ELSE
            IF vmaxrazon is not null AND NOT vpermitido THEN
                RAISE EXCEPTION 'Hay formularios ingresados en el periodo: % panel: %',new.periodo, old.panel;
                RETURN NULL;
            END IF;
        END IF;
    END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_cambio_panel_tarea_trg
  BEFORE UPDATE OF panel, tarea
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE cambio_panel_tarea_trg();