CREATE OR REPLACE FUNCTION generar_visitas_reemplazo_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vcantvisitapos integer;
  vformularios RECORD;
  vconjuntomuestral integer;
  vcantvisitaningr integer;
BEGIN
  
  IF NEW.informantereemplazante IS DISTINCT FROM OLD.informantereemplazante  AND NEW.informantereemplazante IS NOT NULL THEN
    SELECT conjuntomuestral into vconjuntomuestral
      FROM cvp.informantes
      WHERE informante=NEW.informante;
    SELECT count(*) INTO vcantvisitapos
      FROM cvp.relvis c, cvp.informantes i, cvp.razones r
         WHERE c.periodo=NEW.periodo AND
            c.visita=NEW.visita AND  --observo para todos los formularios
            c.informante=i.informante  AND
            i.conjuntomuestral=vconjuntomuestral AND
            c.razon=r.razon AND
            (r.escierredefinitivoinf='N' OR --or por la razon 11
            r.escierredefinitivofor='N') ;
    IF vcantvisitapos <> 0 THEN
       RAISE EXCEPTION 'Ya existe una o mas visitas con razon positiva ó negativa temporaria para el mismo conjunto muestral';
       RETURN NULL;
    ELSE
      SELECT count(*) INTO vcantvisitaningr
        FROM cvp.relvis c, cvp.informantes i
        WHERE c.periodo=NEW.periodo AND
              c.visita=NEW.visita AND  --observo para todos los formularios
              c.informante=i.informante  AND
              i.conjuntomuestral=vconjuntomuestral AND
              c.razon IS NULL;
      IF vcantvisitaningr <> 0 THEN
        RAISE EXCEPTION 'Ya existe una o más visitas sin ingresar para el mismo conjunto muestral';
        RETURN NULL;
      ELSE
        FOR vformularios IN
          SELECT formulario
            FROM cvp.forinf
            WHERE informante=NEW.informante
        LOOP    
          INSERT INTO cvp.relvis(periodo, informante , visita, formulario, panel, tarea)
          VALUES( NEW.periodo, NEW.informantereemplazante, NEW.visita, NEW.formulario, NEW.panel, NEW.tarea); 
        END LOOP;  
       --'Se insertara la visita';
      END IF;  
    END IF;
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_genera_reemplazante 
  BEFORE UPDATE ON relvis 
  FOR EACH ROW EXECUTE PROCEDURE generar_visitas_reemplazo_trg();
