CREATE OR REPLACE FUNCTION cambio_panel_tarea_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vgenerado integer:=null;
 vmaxperiododesde character varying(11);
 vmaxrazon integer;
 vexistetar integer:=null;
 vexisteinf integer:=null;
 vexistevis integer:=null;
 vencuestador character varying(10):=NULL;
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
		--el panel del que me quiero mover debe ser el último generado y no debe tener formularios ingresados
		SELECT maxperiodo, maxrazon INTO vmaxperiododesde, vmaxrazon
		FROM (SELECT MAX(periodo) maxperiodo FROM cvp.relvis WHERE panel = old.panel) v,
		LATERAL (SELECT MAX(razon) maxrazon FROM cvp.relvis WHERE periodo = maxperiodo AND panel = old.panel) r;       
		IF new.periodo is distinct from vmaxperiododesde THEN
			RAISE EXCEPTION '% No es el último periodo generado para el panel: %',new.periodo, old.panel;
			RETURN NULL;
		ELSE
			IF vmaxrazon is not null THEN
				RAISE EXCEPTION 'Hay formularios ingresados en el periodo: % panel: %',new.periodo, old.panel;
				RETURN NULL;
			ELSE
				--agregar la nueva tarea en reltar, si no existe 
				SELECT 1 INTO vexistetar
				FROM cvp.reltar 
				WHERE periodo = new.periodo and panel = new.panel and tarea = new.tarea;
				IF vexistetar is distinct from 1 THEN
					SELECT encuestador INTO vencuestador
					FROM cvp.tareas
					WHERE tarea = new.tarea AND activa='S';
					IF vencuestador is distinct from null THEN
						INSERT INTO cvp.reltar (periodo,panel,tarea,encuestador) VALUES (new.periodo,new.panel,new.tarea,vencuestador);
					ELSE
						RAISE EXCEPTION 'La tarea % no existe o no está activa',new.tarea;
						RETURN NULL;
					END IF;
				END IF;
				--agregar la nueva tarea en relinf, si no existe
				SELECT 1 INTO vexisteinf
				FROM cvp.relinf 
				WHERE periodo = new.periodo and panel = new.panel and tarea = new.tarea and informante = new.informante and visita = new.visita;
				--raise notice 'vexisteinf %', vexisteinf;
				IF vexisteinf is distinct from 1 THEN
					INSERT INTO cvp.relinf (periodo,informante,visita,panel,tarea) 
					values (new.periodo,new.informante,new.visita,new.panel,new.tarea);
				END IF;
				--borrar la vieja tarea de relinf, si deja de existir
				SELECT distinct 1 INTO vexistevis
				FROM cvp.relvis
				WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and panel = old.panel and tarea = old.tarea
				and formulario <> new.formulario;
				--raise notice 'vexistevis %', vexistevis;
				IF vexistevis is distinct from 1 THEN
					DELETE FROM cvp.relinf
					WHERE periodo = new.periodo and informante = new.informante and visita = new.visita and panel = old.panel and tarea = old.tarea;
				END IF;
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