CREATE OR REPLACE FUNCTION controlar_actualizacion_datos_trg()
  RETURNS trigger AS
$BODY$  
DECLARE
 vpositivoinf  cvp.razones.espositivoinformante%type; 
 vpositivoform cvp.razones.espositivoformulario%type;
 vrazon        cvp.razones.razon%type;
 vcantidadatributosgenerados integer; --en el periodo siguiente
 
BEGIN
  IF TG_TABLE_NAME= 'relpre' THEN
    SELECT razon INTO vrazon
      FROM cvp.relvis
      WHERE periodo=NEW.periodo AND informante=NEW.informante AND visita=NEW.visita AND formulario=NEW.formulario;
  
    IF vrazon is NOT NULL THEN
      SELECT espositivoinformante, espositivoformulario INTO vpositivoinf, vpositivoform
          FROM cvp.razones
          WHERE razon=vrazon;
    END IF;
    IF (OLD.precio IS DISTINCT FROM NEW.precio) OR (OLD.tipoprecio IS DISTINCT FROM NEW.tipoprecio) OR (OLD.cambio IS DISTINCT FROM NEW.cambio) OR ( OLD.comentariosrelpre IS DISTINCT FROM NEW.comentariosrelpre )THEN
         IF vpositivoinf='N' OR vpositivoform='N' OR  vrazon is NULL  THEN
             RAISE EXCEPTION ' No es posible modificar los campos de precios cuando el valor de Razon No es Positivo';
             RETURN NULL;
         END IF;
    END IF;
    IF OLD.cambio IS DISTINCT FROM NEW.cambio THEN
       SELECT COUNT(*) into vcantidadatributosgenerados
       FROM cvp.relatr a
       WHERE a.periodo    =cvp.moverperiodos(NEW.periodo,1) AND 
          a.producto   =NEW.producto AND
          a.observacion=NEW.observacion AND 
          a.informante =NEW.informante AND
          a.visita     =NEW.visita;
       IF vcantidadatributosgenerados>0 THEN
         RAISE EXCEPTION 'Ya has sido generados los atributos del periodo siguiente; periodo %, producto % observacion % informante%, visita%, atributo % ', NEW.periodo, NEW.producto, NEW.observacion, NEW.informante, NEW.visita, NEW.atributo;
         RETURN NULL;
       END IF;
    END IF;	
  ELSIF TG_TABLE_NAME= 'relatr' THEN
    SELECT razon INTO vrazon
      FROM cvp.relvis v 
        inner join cvp.relpre p ON v.periodo=p.periodo and v.informante=p.informante and v.visita=p.visita and p.formulario=v.formulario --PK:controlada (de relvis)
      WHERE p.periodo=NEW.periodo AND p.informante=NEW.informante AND p.visita=NEW.visita 
        AND p.producto=NEW.producto AND p.observacion=NEW.observacion; --PK:contolada (de relpre)
    IF vrazon is NOT NULL THEN
      SELECT espositivoinformante, espositivoformulario INTO vpositivoinf, vpositivoform
        FROM cvp.razones
        WHERE razon=vrazon;
    END IF;  
   
    IF OLD.valor IS DISTINCT FROM NEW.valor THEN
      IF vpositivoinf='N' OR vpositivoform='N' OR vrazon is NULL  THEN
        RAISE EXCEPTION ' No es posible modificar atributos cuando el valor de Razon No es Positivo';
        RETURN NULL;
      END IF; 
    END IF;
            
  END IF;
  RETURN NEW;
END;
$BODY$;
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relatr_act_datos_trg 
  BEFORE UPDATE ON relatr 
  FOR EACH ROW EXECUTE PROCEDURE controlar_actualizacion_datos_trg();

CREATE TRIGGER relpre_act_datos_trg 
  BEFORE UPDATE ON relpre 
  FOR EACH ROW EXECUTE PROCEDURE controlar_actualizacion_datos_trg();