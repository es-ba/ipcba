set search_path = cvp;
ALTER TABLE tipoinf ALTER COLUMN otrotipoinformante DROP NOT NULL;

--select * from tipoinf;
INSERT INTO tipoinf (tipoinformante, otrotipoinformante, nombretipoinformante) VALUES ('H', null, 'Híbrido');

ALTER TABLE productos ADD COLUMN divisionhibrido character varying(1);

--divisionhibrido tiene que ser S ó T
--divisionhibrido tiene que ser null en productos sindividir

CREATE OR REPLACE FUNCTION validar_divisionhibrido_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
vhay_ti INTEGER;
vhay_pd INTEGER;

BEGIN
 IF new.divisionhibrido is not null THEN
   SELECT 1 INTO vhay_ti
      FROM cvp.tipoinf
      WHERE tipoinformante=new.divisionhibrido AND otrotipoinformante is not null;

   IF vhay_ti IS NULL THEN
     RAISE EXCEPTION 'Division para híbrido % no es una división valida ', new.divisionhibrido;
     RETURN NULL;
   END IF; 
   SELECT 1 INTO vhay_pd
      FROM cvp.proddiv
      WHERE producto=new.producto AND sindividir;

   IF vhay_pd = 1 THEN
     RAISE EXCEPTION 'El producto % es sin dividir, no puede asigarse una división ', new.producto;
     RETURN NULL;
   END IF; 
 END IF;
RETURN NEW;

END;
$BODY$;

ALTER FUNCTION validar_divisionhibrido_trg() OWNER TO cvpowner;

CREATE TRIGGER productos_divisionhibrido_trg
    BEFORE INSERT OR UPDATE 
    ON productos
    FOR EACH ROW
    EXECUTE FUNCTION cvp.validar_divisionhibrido_trg();

CREATE OR REPLACE FUNCTION hisc_productos_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','producto','I',new.producto,new.producto,'I:'||comun.a_texto(new.producto),new.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','nombreproducto','I',new.producto,new.producto,'I:'||comun.a_texto(new.nombreproducto),new.nombreproducto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','formula','I',new.producto,new.producto,'I:'||comun.a_texto(new.formula),new.formula);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','estacional','I',new.producto,new.producto,'I:'||comun.a_texto(new.estacional),new.estacional);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','imputacon','I',new.producto,new.producto,'I:'||comun.a_texto(new.imputacon),new.imputacon);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','cantperaltaauto','I',new.producto,new.producto,'I:'||comun.a_texto(new.cantperaltaauto),new.cantperaltaauto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','cantperbajaauto','I',new.producto,new.producto,'I:'||comun.a_texto(new.cantperbajaauto),new.cantperbajaauto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','unidadmedidaporunidcons','I',new.producto,new.producto,'I:'||comun.a_texto(new.unidadmedidaporunidcons),new.unidadmedidaporunidcons);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','esexternohabitual','I',new.producto,new.producto,'I:'||comun.a_texto(new.esexternohabitual),new.esexternohabitual);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','tipocalculo','I',new.producto,new.producto,'I:'||comun.a_texto(new.tipocalculo),new.tipocalculo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','cantobs','I',new.producto,new.producto,'I:'||comun.a_texto(new.cantobs),new.cantobs);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','unidadmedidaabreviada','I',new.producto,new.producto,'I:'||comun.a_texto(new.unidadmedidaabreviada),new.unidadmedidaabreviada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','codigo_ccba','I',new.producto,new.producto,'I:'||comun.a_texto(new.codigo_ccba),new.codigo_ccba);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','porc_adv_inf','I',new.producto,new.producto,'I:'||comun.a_texto(new.porc_adv_inf),new.porc_adv_inf);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','porc_adv_sup','I',new.producto,new.producto,'I:'||comun.a_texto(new.porc_adv_sup),new.porc_adv_sup);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','tipoexterno','I',new.producto,new.producto,'I:'||comun.a_texto(new.tipoexterno),new.tipoexterno);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','nombreparaformulario','I',new.producto,new.producto,'I:'||comun.a_texto(new.nombreparaformulario),new.nombreparaformulario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_bool)
                     VALUES ('cvp','productos','serepregunta','I',new.producto,new.producto,'I:'||comun.a_texto(new.serepregunta),new.serepregunta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','nombreparapublicar','I',new.producto,new.producto,'I:'||comun.a_texto(new.nombreparapublicar),new.nombreparapublicar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','calculo_desvios','I',new.producto,new.producto,'I:'||comun.a_texto(new.calculo_desvios),new.calculo_desvios);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_bool)
                     VALUES ('cvp','productos','excluir_control_precios_maxmin','I',new.producto,new.producto,'I:'||comun.a_texto(new.excluir_control_precios_maxmin),new.excluir_control_precios_maxmin);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_bool)
                     VALUES ('cvp','productos','controlar_precios_sin_normalizar','I',new.producto,new.producto,'I:'||comun.a_texto(new.controlar_precios_sin_normalizar),new.controlar_precios_sin_normalizar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','prioritario','I',new.producto,new.producto,'I:'||comun.a_texto(new.prioritario),new.prioritario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','cluster','I',new.producto,new.producto,'I:'||comun.a_texto(new."cluster"),new."cluster");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','productos','divisionhibrido','I',new.producto,new.producto,'I:'||comun.a_texto(new.divisionhibrido),new.divisionhibrido);
	  END IF;
      IF v_operacion='U' THEN
            IF new.producto IS DISTINCT FROM old.producto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','producto','U',new.producto,new.producto,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
            END IF;    
            IF new.nombreproducto IS DISTINCT FROM old.nombreproducto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','nombreproducto','U',new.producto,new.producto,comun.A_TEXTO(old.nombreproducto)||'->'||comun.a_texto(new.nombreproducto),old.nombreproducto,new.nombreproducto);
            END IF;    
            IF new.formula IS DISTINCT FROM old.formula THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','formula','U',new.producto,new.producto,comun.A_TEXTO(old.formula)||'->'||comun.a_texto(new.formula),old.formula,new.formula);
            END IF;    
            IF new.estacional IS DISTINCT FROM old.estacional THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','estacional','U',new.producto,new.producto,comun.A_TEXTO(old.estacional)||'->'||comun.a_texto(new.estacional),old.estacional,new.estacional);
            END IF;    
            IF new.imputacon IS DISTINCT FROM old.imputacon THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','imputacon','U',new.producto,new.producto,comun.A_TEXTO(old.imputacon)||'->'||comun.a_texto(new.imputacon),old.imputacon,new.imputacon);
            END IF;
            IF new.cantperaltaauto IS DISTINCT FROM old.cantperaltaauto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','cantperaltaauto','U',new.producto,new.producto,comun.A_TEXTO(old.cantperaltaauto)||'->'||comun.a_texto(new.cantperaltaauto),old.cantperaltaauto,new.cantperaltaauto);
            END IF;
            IF new.cantperbajaauto IS DISTINCT FROM old.cantperbajaauto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','cantperbajaauto','U',new.producto,new.producto,comun.A_TEXTO(old.cantperbajaauto)||'->'||comun.a_texto(new.cantperbajaauto),old.cantperbajaauto,new.cantperbajaauto);
            END IF;
            IF new.unidadmedidaporunidcons IS DISTINCT FROM old.unidadmedidaporunidcons THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','unidadmedidaporunidcons','U',new.producto,new.producto,comun.A_TEXTO(old.unidadmedidaporunidcons)||'->'||comun.a_texto(new.unidadmedidaporunidcons),old.unidadmedidaporunidcons,new.unidadmedidaporunidcons);
            END IF;
            IF new.esexternohabitual IS DISTINCT FROM old.esexternohabitual THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','esexternohabitual','U',new.producto,new.producto,comun.A_TEXTO(old.esexternohabitual)||'->'||comun.a_texto(new.esexternohabitual),old.esexternohabitual,new.esexternohabitual);
            END IF;
            IF new.tipocalculo IS DISTINCT FROM old.tipocalculo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','tipocalculo','U',new.producto,new.producto,comun.A_TEXTO(old.tipocalculo)||'->'||comun.a_texto(new.tipocalculo),old.tipocalculo,new.tipocalculo);
            END IF;
            IF new.cantobs IS DISTINCT FROM old.cantobs THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','cantobs','U',new.producto,new.producto,comun.A_TEXTO(old.cantobs)||'->'||comun.a_texto(new.cantobs),old.cantobs,new.cantobs);
            END IF;
            IF new.unidadmedidaabreviada IS DISTINCT FROM old.unidadmedidaabreviada THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','unidadmedidaabreviada','U',new.producto,new.producto,comun.A_TEXTO(old.unidadmedidaabreviada)||'->'||comun.a_texto(new.unidadmedidaabreviada),old.unidadmedidaabreviada,new.unidadmedidaabreviada);
            END IF;
            IF new.codigo_ccba IS DISTINCT FROM old.codigo_ccba THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','codigo_ccba','U',new.producto,new.producto,comun.A_TEXTO(old.codigo_ccba)||'->'||comun.a_texto(new.codigo_ccba),old.codigo_ccba,new.codigo_ccba);
            END IF;
            IF new.porc_adv_inf IS DISTINCT FROM old.porc_adv_inf THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','porc_adv_inf','U',new.producto,new.producto,comun.A_TEXTO(old.porc_adv_inf)||'->'||comun.a_texto(new.porc_adv_inf),old.porc_adv_inf,new.porc_adv_inf);
            END IF;
            IF new.porc_adv_sup IS DISTINCT FROM old.porc_adv_sup THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','porc_adv_sup','U',new.producto,new.producto,comun.A_TEXTO(old.porc_adv_sup)||'->'||comun.a_texto(new.porc_adv_sup),old.porc_adv_sup,new.porc_adv_sup);
            END IF;
            IF new.tipoexterno IS DISTINCT FROM old.tipoexterno THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','tipoexterno','U',new.producto,new.producto,comun.A_TEXTO(old.tipoexterno)||'->'||comun.a_texto(new.tipoexterno),old.tipoexterno,new.tipoexterno);
            END IF;
            IF new.nombreparaformulario IS DISTINCT FROM old.nombreparaformulario THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','nombreparaformulario','U',new.producto,new.producto,comun.A_TEXTO(old.nombreparaformulario)||'->'||comun.a_texto(new.nombreparaformulario),old.nombreparaformulario,new.nombreparaformulario);
            END IF;
            IF new.serepregunta IS DISTINCT FROM old.serepregunta THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','productos','serepregunta','U',new.producto,new.producto,comun.A_TEXTO(old.serepregunta)||'->'||comun.a_texto(new.serepregunta),old.serepregunta,new.serepregunta);
            END IF;
            IF new.nombreparapublicar IS DISTINCT FROM old.nombreparapublicar THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','nombreparapublicar','U',new.producto,new.producto,comun.A_TEXTO(old.nombreparapublicar)||'->'||comun.a_texto(new.nombreparapublicar),old.nombreparapublicar,new.nombreparapublicar);
            END IF;
            IF new.calculo_desvios IS DISTINCT FROM old.calculo_desvios THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','calculo_desvios','U',new.producto,new.producto,comun.A_TEXTO(old.calculo_desvios)||'->'||comun.a_texto(new.calculo_desvios),old.calculo_desvios,new.calculo_desvios);
            END IF;
            IF new.excluir_control_precios_maxmin IS DISTINCT FROM old.excluir_control_precios_maxmin THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','productos','excluir_control_precios_maxmin','U',new.producto,new.producto,comun.A_TEXTO(old.excluir_control_precios_maxmin)||'->'||comun.a_texto(new.excluir_control_precios_maxmin),old.excluir_control_precios_maxmin,new.excluir_control_precios_maxmin);
            END IF;
            IF new.controlar_precios_sin_normalizar IS DISTINCT FROM old.controlar_precios_sin_normalizar THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','productos','controlar_precios_sin_normalizar','U',new.producto,new.producto,comun.A_TEXTO(old.controlar_precios_sin_normalizar)||'->'||comun.a_texto(new.controlar_precios_sin_normalizar),old.controlar_precios_sin_normalizar,new.controlar_precios_sin_normalizar);
            END IF;
            IF new.prioritario IS DISTINCT FROM old.prioritario THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','prioritario','U',new.producto,new.producto,comun.A_TEXTO(old.prioritario)||'->'||comun.a_texto(new.prioritario),old.prioritario,new.prioritario);
            END IF;
            IF new."cluster" IS DISTINCT FROM old."cluster" THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','cluster','U',new.producto,new.producto,comun.A_TEXTO(old."cluster")||'->'||comun.a_texto(new."cluster"),old."cluster",new."cluster");
            END IF;
            IF new.divisionhibrido IS DISTINCT FROM old.divisionhibrido THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','productos','divisionhibrido','U',new.producto,new.producto,comun.A_TEXTO(old.divisionhibrido)||'->'||comun.a_texto(new.divisionhibrido),old.divisionhibrido,new.divisionhibrido);
            END IF;
      END IF;
      IF v_operacion='D' THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','producto','D',old.producto,old.producto,'D:'||comun.a_texto(old.producto),old.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','nombreproducto','D',old.producto,old.producto,'D:'||comun.a_texto(old.nombreproducto),old.nombreproducto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','formula','D',old.producto,old.producto,'D:'||comun.a_texto(old.formula),old.formula);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','estacional','D',old.producto,old.producto,'D:'||comun.a_texto(old.estacional),old.estacional);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','imputacon','D',old.producto,old.producto,'D:'||comun.a_texto(old.imputacon),old.imputacon);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','cantperaltaauto','D',old.producto,old.producto,'D:'||comun.a_texto(old.cantperaltaauto),old.cantperaltaauto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','cantperbajaauto','D',old.producto,old.producto,'D:'||comun.a_texto(old.cantperbajaauto),old.cantperbajaauto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','unidadmedidaporunidcons','D',old.producto,old.producto,'D:'||comun.a_texto(old.unidadmedidaporunidcons),old.unidadmedidaporunidcons);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','esexternohabitual','D',old.producto,old.producto,'D:'||comun.a_texto(old.esexternohabitual),old.esexternohabitual);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','tipocalculo','D',old.producto,old.producto,'D:'||comun.a_texto(old.tipocalculo),old.tipocalculo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','productos','cantobs','D',old.producto,old.producto,'D:'||comun.a_texto(old.cantobs),old.cantobs);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','unidadmedidaabreviada','D',old.producto,old.producto,'D:'||comun.a_texto(old.unidadmedidaabreviada),old.unidadmedidaabreviada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','codigo_ccba','D',old.producto,old.producto,'D:'||comun.a_texto(old.codigo_ccba),old.codigo_ccba);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','productos','porc_adv_inf','D',old.producto,old.producto,'D:'||comun.a_texto(old.porc_adv_inf),old.porc_adv_inf);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','productos','porc_adv_sup','D',old.producto,old.producto,'D:'||comun.a_texto(old.porc_adv_sup),old.porc_adv_sup);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','tipoexterno','D',old.producto,old.producto,'D:'||comun.a_texto(old.tipoexterno),old.tipoexterno);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','nombreparaformulario','D',old.producto,old.producto,'D:'||comun.a_texto(old.nombreparaformulario),old.nombreparaformulario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool)
                     VALUES ('cvp','productos','serepregunta','D',old.producto,old.producto,'D:'||comun.a_texto(old.serepregunta),old.serepregunta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','nombreparapublicar','D',old.producto,old.producto,'D:'||comun.a_texto(old.nombreparapublicar),old.nombreparapublicar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','calculo_desvios','D',old.producto,old.producto,'D:'||comun.a_texto(old.calculo_desvios),old.calculo_desvios);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool)
                     VALUES ('cvp','productos','excluir_control_precios_maxmin','D',old.producto,old.producto,'D:'||comun.a_texto(old.excluir_control_precios_maxmin),old.excluir_control_precios_maxmin);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool)
                     VALUES ('cvp','productos','controlar_precios_sin_normalizar','D',old.producto,old.producto,'D:'||comun.a_texto(old.controlar_precios_sin_normalizar),old.controlar_precios_sin_normalizar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','productos','prioritario','D',old.producto,old.producto,'D:'||comun.a_texto(old.prioritario),old.prioritario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','cluster','prioritario','D',old.producto,old.producto,'D:'||comun.a_texto(old."cluster"),old."cluster");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','productos','divisionhibrido','D',old.producto,old.producto,'D:'||comun.a_texto(old.divisionhibrido),old.divisionhibrido);
        END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;
	 
-- Function: CalObs_promedio(text, integer)
CREATE OR REPLACE FUNCTION CalObs_promedio(pperiodo text, pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vpr_AtrAgrpV1 RECORD;
hayDistintas INTEGER;
vmaxpanel INTEGER;
   
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_promedio', pTipo:='comenzo');
  SELECT MAX(panel) INTO vmaxpanel FROM relpan WHERE periodo = pperiodo;
  INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, 
                   PromObs, ImpObs, muestra)
    (SELECT        r.periodo, pcalculo, r.producto, r.informante, r.observacion, 
                   COALESCE(max(de.divisionespecial), case when pd.sindividir then '0' else pd.division end), 
                   CASE WHEN v.es_vigencia is null THEN 
                          AVG(r.precionormalizado) 
                        WHEN v.es_vigencia THEN 
                          SUM(r.precionormalizado*v.nvalor)/SUM(v.nvalor) 
                   END,
                   CASE WHEN max(de.divisionespecial)<>min(de.divisionespecial) -- <> implica not null para ambos. 
                            THEN 'ERROR' -- ESTO NO APARECE SE FILTRA EN EL HAVING y se inserta el error ahí.
                        WHEN COUNT(case when r.tipoprecio = 'I' then 1 else null end) = 1 THEN 'IRM' --Imputacion Registrada Manualmente
                        WHEN max(de.divisionespecial) IS NOT NULL THEN 'RA' 
                        ELSE 'R' 
                   END, 
                   i.muestra
       FROM RelPre r
         LEFT JOIN 
           (SELECT ra.periodo,ra.producto,ra.observacion,ra.informante,ra.visita,ra.valor::decimal as nvalor,a.es_vigencia 
              FROM RelAtr ra 
              JOIN Atributos a ON ra.atributo = a.atributo
              WHERE a.es_vigencia = true) v -- busca, si existe, el único atributo vigencia
            ON r.periodo = v.periodo AND r.producto = v.producto AND r.observacion = v.observacion 
                AND r.informante = v.informante AND r.visita = v.visita
         LEFT JOIN
             (SELECT rla.periodo, rla.producto, rla.observacion, rla.informante, rla.visita, string_agg(rla.valor,'~' order by pa.orden_calculo_especial) divisionEspecial
                 FROM RelAtr rla JOIN ProdAtr pa ON rla.producto = pa.producto AND rla.atributo = pa.atributo 
                 WHERE pa.orden_calculo_especial IS NOT NULL 
                 GROUP BY rla.periodo, rla.producto, rla.observacion, rla.informante, rla.visita) de
               ON r.periodo = de.periodo AND r.producto = de.producto AND r.observacion = de.observacion AND r.informante = de.informante AND r.visita=de.visita
       JOIN Informantes i ON r.informante=i.informante 
       inner join (select producto, division, tipoinformante, sindividir 
                    from proddiv
                   union
                   select producto, divisionhibrido as division, tipoinformante, null as sindividir  
                    from productos, tipoinf 
                   where divisionhibrido is not null and otrotipoinformante is null) pd on pd.producto=r.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
       inner join Calculos c on c.periodo=r.Periodo and c.calculo=pCalculo 
       inner join Calculos_def cd on cd.calculo=c.calculo
       INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto 
       --LEFT JOIN CalBase_Prod cbp ON cbp.calculo=c.calculo AND cbp.producto=r.producto  --Pk verificada
       LEFT JOIN CalBase_Obs  cbo ON cbo.calculo=COALESCE(cd.rellenante_de,cd.calculo) AND cbo.producto=r.producto AND cbo.informante=r.informante AND cbo.observacion=r.observacion, --Pk verificada
       LATERAL (SELECT * FROM relvis WHERE panel <= COALESCE(c.hasta_panel,vmaxpanel) AND periodo = r.periodo AND informante = r.informante AND visita = r.visita AND formulario = r.formulario) vis  
       WHERE (r.periodo=pperiodo AND r.PrecioNormalizado is not null )  
         AND ( c.esperiodobase='N'
             --OR  ( c.esperiodobase='S' AND cbo.incluido AND c.periodo<c.periodoanterior)
             OR  ( c.esperiodobase='S' AND cbo.incluido AND cbo.periodo_aparicion is not null AND c.periodo >= cbo.periodo_aparicion 
                  AND (c.periodo <=cbo.periodo_anterior_baja or cbo.periodo_anterior_baja is null)
                  ) 
              )
       GROUP BY r.periodo, pcalculo, r.producto, r.informante, r.observacion, v.es_vigencia, pd.division, i.muestra, pd.sindividir
       HAVING
            CASE WHEN max(de.divisionespecial)<>min(de.divisionespecial) 
               THEN Cal_Mensajes(r.Periodo, pCalculo, 'CalObs_promedio', pTipo:='error', 
                    pmensaje:= 'ERROR: No coinciden los valores de los atributos en las visitas de '||r.periodo||' c'||pCalculo||' '||r.producto||' obs '||r.observacion||' inf '||r.informante,
                    pProducto:=r.producto, pdivision:=min(de.divisionespecial), pinformante:=r.informante,
                    pobservacion:= r.observacion)
               ELSE 'OK' 
            END='OK'
    );
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalObs_promedio', pTipo:='finalizo');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
 
 
CREATE OR REPLACE FUNCTION CalObs_Rellenar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vPeriodo_1 Text;
  vCalculo_1 integer;
  vgrupo_raiz  Text;
BEGIN

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_Rellenar','comenzo');  

SELECT periodoanterior, calculoanterior, cd.grupo_raiz INTO vPeriodo_1, vCalculo_1, vgrupo_raiz
  FROM Calculos c, Calculos_def cd
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.calculo= cd.calculo;
INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, PromObs, 
                   ImpObs, AntiguedadConPrecio, AntiguedadSinPrecio, Muestra)
  (SELECT          pPeriodo, pCalculo, a.producto, a.informante, a.observacion, CASE WHEN otrotipoinformante is null then pd.division else a.division end as division, NULL,
                   'B',NULL,NULL, i.Muestra
     FROM CalObs a
     LEFT JOIN CalObs b ON b.periodo = pPeriodo AND b.calculo=pCalculo AND b.informante = a.informante 
       AND b.producto = a.producto AND b.observacion=a.observacion 
     JOIN Informantes i  ON a.informante=i.informante
	 join tipoinf ti on i.tipoinformante = ti.tipoinformante
     inner join (select producto, division, tipoinformante, sindividir 
                    from proddiv
                   union
                   select producto, divisionhibrido as division, tipoinformante, null as sindividir  
                    from productos, tipoinf 
                   where divisionhibrido is not null and otrotipoinformante is null) pd on pd.producto=a.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
     WHERE b.periodo IS NULL AND a.periodo=vPeriodo_1 AND a.calculo=vCalculo_1
        AND (a.AntiguedadConPrecio >0 OR a.AntiguedadIncluido >0) 
   );

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_Rellenar','finalizo');  
END;
$$;
