CREATE OR REPLACE FUNCTION cambios_razon_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vposinfnew cvp.razones.espositivoinformante%type;
 vposformnew cvp.razones.espositivoformulario%type;
 vposinfold cvp.razones.espositivoinformante%type;
 vposformold cvp.razones.espositivoformulario%type;
 vcantvisitapos integer;
 vcantprecios integer;
 vconjmuestral cvp.informantes.conjuntomuestral%type;
 vinformantespos text;
BEGIN
--IF OLD.razon <> -1 THEN
IF OLD.razon IS NOT NULL  THEN
    SELECT espositivoinformante, espositivoformulario INTO vposinfold, vposformold
         FROM  cvp.razones 
         WHERE razon=OLD.razon;
    IF  NEW.razon IS NOT NULL THEN
        SELECT espositivoinformante, espositivoformulario INTO vposinfnew, vposformnew
             FROM  cvp.razones 
             WHERE razon=NEW.razon;
    END IF;        
    --Caso de respuesta positiva a  negativa o nula
    IF (vposinfold='S' AND vposformold='S') AND (vposinfnew='N' OR vposformnew='N' OR NEW.razon IS NULL) THEN --OR POR LA RAZON 11
        SELECT count(*) INTO vcantprecios
            FROM cvp.relpre
            WHERE periodo=  NEW.periodo AND
                 informante=NEW.informante AND
                 visita=    NEW.visita AND
                 formulario=NEW.formulario AND
                 (precio IS NOT NULL OR
                 tipoprecio IS NOT NULL OR cambio='C') ;
        IF vcantprecios <> 0 THEN
            RAISE EXCEPTION 'Hay informacion en precios, no es posible modificar Razon';
            RETURN NULL;
        END IF;
    END IF;
    --Caso de respuesta negativa a positiva
    IF (vposinfold='N' OR vposformold='N') AND (vposinfnew='S' AND vposformnew='S' AND NEW.razon IS NOT NULL) THEN
        SELECT conjuntomuestral INTO vconjmuestral
            FROM  cvp.informantes 
            WHERE informante=NEW.informante;  
             
        SELECT count(*),
               string_agg( distinct c.informante::text,',') razones_posit         
           INTO vcantvisitapos, vinformantespos
           FROM cvp.relvis c, cvp.informantes i, cvp.razones r
           WHERE c.periodo=NEW.periodo AND
                 c.visita=NEW.visita AND  --observo para todos los formularios
                 c.informante=i.informante  AND
                 i.conjuntomuestral=vconjmuestral AND
                 c.razon=r.razon AND
                 c.informante <>NEW.informante AND
                 (r.escierredefinitivoinf='N' OR --or por la razon 11
                 r.escierredefinitivofor='N') ;

        IF vcantvisitapos <> 0 THEN
            RAISE EXCEPTION 'Ya existe mas de una visita con razon positiva ó negativa temporaria para el mismo conjunto muestral %  informantes: %', vconjmuestral, vinformantespos;
            RETURN NULL;
        END IF;
    END IF;   
END IF;
--END IF; 
RETURN NEW;

END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_cambios_razon_trg 
   BEFORE UPDATE 
   ON relvis 
   FOR EACH ROW EXECUTE PROCEDURE cambios_razon_trg();