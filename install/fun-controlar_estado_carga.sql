CREATE OR REPLACE FUNCTION controlar_estado_carga(
    p_cambia_token boolean, p_periodo text, p_panel integer, p_tarea integer,
    p_informante integer DEFAULT null, p_visita integer DEFAULT null, p_formulario integer DEFAULT null, p_producto text DEFAULT null, p_observacion integer DEFAULT null
) returns void
    language plpgsql
AS
$BODY$
DECLARE
    vformulario integer:=p_formulario;
    vpanel integer:=p_panel;
    vtarea integer:=p_tarea;
    vpermitido  boolean;
    vtoken text;
    vcargado text;
    vdescargado text;
BEGIN
    IF vpanel IS NULL or vtarea IS NULL THEN
        IF vformulario IS NULL THEN
            SELECT formulario
                into vformulario
                FROM cvp.relpre
                WHERE periodo = p_periodo AND informante = p_informante AND visita = p_visita
                    AND producto = p_producto AND observacion = p_observacion;
        END IF;
        SELECT panel, tarea
            into vpanel, vtarea
            FROM cvp.relvis
            WHERE periodo = p_periodo AND informante = p_informante AND visita = p_visita AND formulario = vformulario;
    END IF;
    SELECT cargado IS NULL AND descargado IS NULL
            OR cargado IS NOT NULL AND descargado IS NOT NULL AND cargado < descargado
            OR cargado IS NULL AND descargado IS NOT NULL,
            CASE WHEN cargado IS NULL THEN 'No cargado aún...' ELSE 'Cargado a DM el '||to_char(cargado,'DD/MM/YY hh24:mm:ss') END,
            CASE WHEN descargado IS NULL THEN 'No descargado aún...' ELSE 'Descargado de DM el '||to_char(descargado,'DD/MM/YY hh24:mm:ss') END
        INTO vpermitido, vcargado, vdescargado
        FROM cvp.reltar
        WHERE periodo = p_periodo AND panel = vpanel AND tarea = vtarea;
    IF NOT vpermitido THEN
        RAISE EXCEPTION 'No se permite modificar el periodo %, panel %, tarea %. %, %', p_periodo, vpanel, vtarea, vcargado, vdescargado;
    END IF;
    IF NOT p_cambia_token THEN
        SELECT token_relevamiento INTO vtoken
            FROM cvp.relvis
            WHERE periodo = p_periodo AND panel = vpanel AND tarea = vtarea and informante = p_informante;
        IF vtoken IS NOT NULL THEN
            RAISE EXCEPTION 'No se permite modificar el periodo %, panel %, tarea %, informante % ya que tiene token de relevamiento ', p_periodo, vpanel, vtarea, p_informante;
        END IF;
    END IF;
    RETURN;
END;
$BODY$;