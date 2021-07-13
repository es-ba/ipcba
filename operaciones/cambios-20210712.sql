set search_path = cvp;

--sólo va a borrar de blapre y blaatr si es que se recuperan (o sea cuando se revierte el blanqueo) en trigger relpre_restaurar_atributos_blanqueados_trg
CREATE OR REPLACE FUNCTION adm_blanqueo_precios_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vblanqueonew  cvp.tipopre.registrablanqueo%type;
  vblanqueoold  cvp.tipopre.registrablanqueo%type;
BEGIN
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
            cambio, precionormalizado, especificacion, ultima_visita)
        VALUES (OLD.periodo, OLD.producto, OLD.observacion, OLD.informante, OLD.formulario, OLD.precio, 
            OLD.tipoprecio, OLD.visita, OLD.modi_usu, OLD.modi_fec, OLD.modi_ope, OLD.comentariosrelpre, 
            OLD.cambio, OLD.precionormalizado, OLD.especificacion, OLD.ultima_visita);
        --
        INSERT INTO cvp.blaatr 
            SELECT * FROM cvp.relatr 
            WHERE periodo=NEW.periodo AND 
               producto=NEW.producto AND
               observacion=NEW.observacion AND 
               informante=NEW.informante AND
               visita=NEW.visita;  
    END IF;
	/*
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
	*/
  END IF;
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  
CREATE OR REPLACE FUNCTION restaurar_atributos_blanqueados_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vatributosblanqueados RECORD;
  vblanqueonew               cvp.tipopre.registrablanqueo%type;
  vblanqueoold               cvp.tipopre.registrablanqueo%type;
BEGIN
  SELECT registrablanqueo INTO vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT registrablanqueo INTO vblanqueoold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;
  --
  IF vblanqueoold AND NOT vblanqueonew THEN
    --INSERT INTO cvp.relpresemaforo (periodo,informante,visita,producto,observacion)
    --  VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
    FOR vatributosblanqueados IN 
      SELECT b.atributo, b.valor as valorblanqueado
      FROM cvp.blaatr b
            WHERE b.periodo=NEW.periodo AND 
                  b.producto=NEW.producto AND
                  b.observacion=NEW.observacion AND 
                  b.informante=NEW.informante AND
                  b.visita=NEW.visita 
   	
    LOOP
        UPDATE cvp.relatr 
          SET valor=vatributosblanqueados.valorblanqueado
          WHERE periodo=NEW.periodo AND 
                producto=NEW.producto AND
                observacion=NEW.observacion AND 
                informante=NEW.informante AND
                visita=NEW.visita AND
                atributo=vatributosblanqueados.atributo AND 
				valor IS DISTINCT FROM vatributosblanqueados.valorblanqueado;
    END LOOP;
	--Borrado en blapre y blaatr
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
  --
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER relpre_restaurar_atributos_blanqueados_trg
    AFTER UPDATE OF tipoprecio
    ON cvp.relpre
    FOR EACH ROW
    EXECUTE PROCEDURE cvp.restaurar_atributos_blanqueados_trg();    