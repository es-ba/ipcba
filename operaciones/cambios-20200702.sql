set search_path = cvp;

CREATE or replace FUNCTION cvp.blanquear_precios_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  v_precio double precision;
  v_cambio character varying(1);
BEGIN
if new.confirma is distinct from old.confirma then
    if new.confirma then 
        SELECT precio, cambio INTO v_precio, v_cambio
        FROM cvp.relpre
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
        UPDATE cvp.relpre SET 
        precio     = CASE WHEN v_precio is not null then null else v_precio END, 
        tipoprecio = 'M'
        WHERE periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and visita = new.visita;
    else
        UPDATE cvp.relpre SET precio = precioblanqueado, tipoprecio = tipoprecioblanqueado, --cambio = cambioblanqueado,
               comentariosrelpre = comentariosrelpreblanqueado
        FROM (SELECT precio precioblanqueado, tipoprecio tipoprecioblanqueado, --cambio cambioblanqueado, 
              comentariosrelpre comentariosrelpreblanqueado
              FROM cvp.blapre
              WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita) b 
        WHERE periodo=new.periodo AND producto=new.producto AND observacion=new.observacion AND informante=new.informante AND visita=new.visita;
    end if;
end if;
RETURN NEW;
END;
$BODY$;
---------------------------------------------------------------------------------
CREATE or replace FUNCTION cvp.permitir_actualizar_valor_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  valterable  cvp.prodatr.alterable%type;
  vvalor_1 cvp.relatr.valor%type;
  vvaloresvalidos record;
  vvalido boolean;
  vhayquevalidar boolean;
  vpuedecambiaratributos cvp.tipopre.puedecambiaratributos%type;
  
BEGIN
  IF OLD.valor IS DISTINCT FROM NEW.valor THEN
      SELECT coalesce(t.puedecambiaratributos,false) INTO vpuedecambiaratributos
      FROM cvp.relpre r 
      LEFT JOIN cvp.tipopre t on r.tipoprecio = t.tipoprecio
      WHERE r.periodo=NEW.periodo AND r.informante=NEW.informante AND r.visita=NEW.visita AND r.producto=NEW.producto AND
            r.observacion=NEW.observacion;
      IF not vpuedecambiaratributos THEN
        RAISE EXCEPTION 'No es posible modificar el valor del atributo si el tipo de precio no lo permite';
        RETURN NULL;
      ELSE
        SELECT alterable INTO valterable
        FROM cvp.prodatr
        WHERE producto = NEW.producto AND atributo = NEW.atributo;
        IF valterable = 'N' THEN
          SELECT r_1.valor_1 INTO vvalor_1
          FROM cvp.relatr_1 r_1
          WHERE r_1.periodo=NEW.periodo AND 
                r_1.producto=NEW.producto AND
                r_1.observacion=NEW.observacion AND 
                r_1.informante=NEW.informante AND
                r_1.visita=NEW.visita AND 
                r_1.atributo=NEW.atributo;
           IF vvalor_1 IS NOT NULL THEN
             RAISE EXCEPTION 'Atributo no alterable no se puede modificar';
             RETURN NULL;
           ELSE
             vvalido := false;
             vhayquevalidar := false;
             FOR vvaloresvalidos IN
               SELECT valor 
               FROM cvp.valvalatr 
               WHERE producto = NEW.producto and atributo = NEW.atributo
             LOOP
               vhayquevalidar := true;
               IF vvaloresvalidos.valor = NEW.valor THEN
                vvalido := true;
               END IF;                
             END LOOP;
             IF vhayquevalidar AND NOT vvalido THEN
               RAISE EXCEPTION 'El valor ingresado no es válido para este atributo';
               RETURN NULL;
             END IF;
           END IF;
        END IF;
      END IF;
  END IF;
  
  RETURN NEW;
END;
$BODY$;
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cvp.controlar_actualizacion_datos_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$  
DECLARE
 vpositivoinf  cvp.razones.espositivoinformante%type; 
 vpositivoform cvp.razones.espositivoformulario%type;
 vrazon        cvp.razones.razon%type;
 
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

ALTER FUNCTION cvp.calcular_precionormaliz_cambio_relatr_trg()
    OWNER TO cvpowner;