set search_path = cvp;

CREATE OR REPLACE FUNCTION cambio_panel_tarea_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vgenerado integer:=null;
 vmaxperiododesde character varying(11);
 vmaxrazon integer;
 vpermitido boolean;
 vconflicto integer;
 vpanel integer;
 vtarea integer;
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
        SELECT maxperiodo, maxrazon, permitir_cualquier_cambio_panel_tarea INTO vmaxperiododesde, vmaxrazon, vpermitido
        FROM (SELECT MAX(periodo) maxperiodo FROM cvp.relvis WHERE panel = old.panel) v
        INNER JOIN cvp.parametros ON unicoregistro,
        LATERAL (SELECT MAX(razon) maxrazon FROM cvp.relvis WHERE periodo = maxperiodo AND panel = old.panel) r;
        --el panel del que me quiero mover puede tener (o no) formularios ingresados dependiendo de parametos.permitir_cualquier_cambio_panel_tarea
        IF vmaxrazon is not null AND NOT vpermitido THEN
            RAISE EXCEPTION 'Hay formularios ingresados en el periodo: % panel: %',new.periodo, old.panel;
            RETURN NULL;
        END IF;
        IF new.periodo IS DISTINCT FROM vmaxperiododesde THEN ----el panel del que me quiero mover NO es el último generado (hay que ver si hay conflicto con el siguiente)
            SELECT 1, ro.panel ,ro.tarea  INTO vconflicto, vpanel, vtarea
            FROM cvp.relvis r
            LEFT JOIN cvp.relvis ro ON r.informante = ro.informante and r.visita = ro.visita and r.formulario = ro.formulario
            WHERE r.periodo = new.periodo AND ro.periodo = vmaxperiododesde AND r.informante = old.informante AND r.formulario = old.formulario AND r.visita = old.visita AND
              (new.panel IS DISTINCT FROM ro.panel OR new.tarea IS DISTINCT FROM ro.tarea);
            IF vconflicto = 1 THEN --el panel-tarea del último periodo generado no coincide con el cambio para el periodo actual
                RAISE EXCEPTION 'Periodo % ya generado. Debe cambiar panel % - tarea % a panel % - tarea % en periodo %, Informante % formulario % visita % antes', vmaxperiododesde, vpanel, vtarea, new.panel, new.tarea, vmaxperiododesde, old.informante, old.formulario, old.visita;
                RETURN NULL;
            END IF;
        END IF;
    END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
