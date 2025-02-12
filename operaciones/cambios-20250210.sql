SET SEARCH_PATH = cvp;

ALTER TABLE blapre ADD COLUMN registrablanqueo_usu character varying(30);

CREATE OR REPLACE FUNCTION adm_blanqueo_precios_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vblanqueonew  cvp.tipopre.registrablanqueo%type;
  vblanqueoold  cvp.tipopre.registrablanqueo%type;
  vUsuario VARCHAR(30);
BEGIN
  vUsuario:=SESSION_USER;
  SELECT registrablanqueo INTO vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT registrablanqueo INTO vblanqueoold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;
  
  IF OLD.tipoprecio is distinct from NEW.tipoprecio THEN
    IF vblanqueonew and not vblanqueoold THEN
        INSERT INTO cvp.blapre(
            periodo, producto, observacion, informante, formulario, precio, 
            tipoprecio, visita, modi_usu, modi_fec, modi_ope, comentariosrelpre, 
            cambio, precionormalizado, especificacion, ultima_visita, registrablanqueo_usu)
        VALUES (OLD.periodo, OLD.producto, OLD.observacion, OLD.informante, OLD.formulario, OLD.precio, 
            OLD.tipoprecio, OLD.visita, OLD.modi_usu, OLD.modi_fec, OLD.modi_ope, OLD.comentariosrelpre, 
            OLD.cambio, OLD.precionormalizado, OLD.especificacion, OLD.ultima_visita, vUsuario);
        --
        INSERT INTO cvp.blaatr 
            SELECT * FROM cvp.relatr 
            WHERE periodo=NEW.periodo AND 
               producto=NEW.producto AND
               observacion=NEW.observacion AND 
               informante=NEW.informante AND
               visita=NEW.visita;  
    END IF;
    IF not vblanqueonew and vblanqueoold THEN
        DELETE FROM cvp.blaatr 
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
        DELETE FROM cvp.blapre
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
    END IF;
  END IF;
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;