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

CREATE OR REPLACE FUNCTION verificar_cargado_dm()
    RETURNS trigger
    LANGUAGE 'plpgsql' VOLATILE
AS $BODY$
DECLARE
vtabla       varchar(100);
vcambiatoken boolean;
BEGIN
vtabla= TG_TABLE_NAME;
CASE
    WHEN vtabla='relvis' THEN
        vcambiatoken = TG_OP = 'UPDATE' AND new.token_relevamiento IS DISTINCT FROM old.token_relevamiento;
		IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(vcambiatoken, old.periodo, old.panel, old.tarea, old.informante);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.panel, new.tarea, new.informante)<>(old.periodo, old.panel, old.tarea, old.informante) THEN
            perform cvp.controlar_estado_carga(vcambiatoken, new.periodo, new.panel, new.tarea, new.informante);
        END IF;
    WHEN vtabla='relpre' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, old.periodo, null, null, old.informante, old.visita, old.formulario);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.formulario)<>(old.periodo, old.formulario) THEN
            perform cvp.controlar_estado_carga(false, new.periodo, null, null, new.informante, new.visita, new.formulario);
        END IF;
    WHEN vtabla='relatr' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, old.periodo, null, null, old.informante, old.visita, null, old.producto, old.observacion);
        END IF;
        IF TG_OP = 'INSERT' THEN
            perform cvp.controlar_estado_carga(false, new.periodo, null, null, new.informante, new.visita, null, new.producto, new.observacion);
        END IF;
END CASE;
IF TG_OP='DELETE' THEN
   RETURN OLD;
ELSE  
   RETURN NEW;
END IF;
END;
$BODY$;