set search_path = cvp;
ALTER TABLE productos  ADD COLUMN coefajuste double precision;
ALTER TABLE CalProdAgr ADD COLUMN coefajuste double precision;

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
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_number)
                     VALUES ('cvp','productos','coefajuste','I',new.producto,new.producto,'I:'||comun.a_texto(new.coefajuste),new.coefajuste);
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
            IF new.coefajuste IS DISTINCT FROM old.coefajuste THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number,new_number)
                     VALUES ('cvp','productos','coefajuste','U',new.producto,new.producto,comun.A_TEXTO(old.coefajuste)||'->'||comun.a_texto(new.coefajuste),old.coefajuste,new.coefajuste);
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
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_number)
                     VALUES ('cvp','productos','coefajuste','D',old.producto,old.producto,'D:'||comun.a_texto(old.coefajuste),old.coefajuste);
        END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;

------------------------------------------------------------------------------------------------------------------
CREATE or replace FUNCTION cal_copiar_CalProdAgr(pperiodo text, pcalculo integer, pAgrupacion text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vr_prod RECORD; 
  vr_prodAtr RECORD;
  vvalor DOUBLE PRECISION;
  vunidad CHARACTER VARYING(41); 
BEGIN
  INSERT INTO CalProdAgr(periodo, calculo, producto, agrupacion, CantPorUnidCons,
                       Cantidad, UnidadDeMedida, PesoVolumenPorUnidad, UnidadMedidaPorUnidCons, CoefAjuste)
  (SELECT           pPeriodo, pCalculo, pa.producto, pa.agrupacion, pa.CantPorUnidCons,
                    e.Cantidad, e.UnidadDeMedida, PesoVolumenPorUnidad, UnidadMedidaPorUnidCons, p.CoefAjuste                     
     FROM Productos p INNER JOIN Especificaciones e ON p.producto=e.producto AND e.especificacion=1                    
        INNER JOIN ProdAgr pa on p.producto = pa.producto
        INNER JOIN agrupaciones a ON pa.agrupacion = a.agrupacion 
        INNER JOIN Calculos c ON pCalculo=c.calculo AND pPeriodo=c.Periodo
        INNER JOIN Calculos_def d ON pCalculo = d.calculo  
        INNER JOIN Grupos g ON g.Agrupacion=d.AgrupacionPrincipal AND g.Grupo=pa.Producto 
        INNER JOIN Gru_Prod gp ON g.agrupacion = gp.agrupacion AND d.grupo_raiz = gp.grupo_padre AND pa.producto = gp.producto
     WHERE a.valoriza
       AND (pAgrupacion is null or pAgrupacion=pa.agrupacion)
  ); 
  FOR vr_prod IN
    SELECT g.agrupacion, p.producto, count(pa.producto) AS cantnormalizables,
           min(a.unidaddemedida) AS minUnidad,max(a.unidaddemedida) as MaxUnidad, sum(pa.valorNormal) as sumValorNormal
      FROM Productos p 
         JOIN ProdAtr pa ON  pa.producto=p.producto and pa.normalizable='S' and pa.tiponormalizacion in ('Normal')
         JOIN atributos a ON a.atributo=pa.atributo
         INNER JOIN Calculos c ON pCalculo=c.calculo AND pPeriodo=c.Periodo
         INNER JOIN Calculos_def d ON pCalculo = d.calculo  
         INNER JOIN Grupos g ON g.Grupo=p.Producto
         INNER JOIN Gru_Prod gp ON g.agrupacion = gp.agrupacion AND coalesce(pAgrupacion, d.agrupacionprincipal)= gp.grupo_padre AND p.producto = gp.producto 
      WHERE (pAgrupacion is null or pAgrupacion=g.agrupacion)
      GROUP BY g.agrupacion, p.producto
  LOOP 
    IF vr_prod.cantNormalizables=1 THEN 
        UPDATE calprodAgr
           set Cantidad= vr_prod.sumValorNormal, UnidaddeMedida= vr_prod.minUnidad
           WHERE periodo=pPeriodo AND calculo= pCalculo AND producto= vr_prod.producto AND (pAgrupacion is null or pAgrupacion=agrupacion);     
    ELSE
        vvalor=1;
        vUnidad:=NULL;
        FOR vr_prodatr IN 
          SELECT pa.valorNormal, a.UnidadDeMedida
            FROM ProdAtr pa INNER JOIN Atributos a ON pa.atributo=a.atributo
            WHERE pa.producto= vr_prod.producto and pa.normalizable='S' and pa.tiponormalizacion in ('Normal')
        ORDER BY a.UnidadDeMedida, pa.prioridad, pa.atributo
        LOOP  
          vvalor:=vvalor * vr_prodatr.valorNormal;
          IF vr_prodatr.UnidadDeMedida<>'u' THEN
            IF vUnidad IS NULL THEN
                vUnidad:='';
            ELSE
                vUnidad:=vUnidad||'.';
            END IF;
            vUnidad:=vUnidad||vr_prodatr.UnidadDeMedida;
          END IF;
        END LOOP;
        IF vUnidad IS NULL THEN
        vUnidad:='u';
        END IF;
        UPDATE calprodAgr
           set Cantidad= vvalor, UnidaddeMedida= vunidad
           WHERE periodo=pPeriodo AND calculo= pCalculo AND producto= vr_prod.producto AND (pAgrupacion is null or pAgrupacion=agrupacion);
    END IF;           
  END LOOP;
END;
$$;
---------------------------------------------------------------------------------------------------------------------
CREATE or replace FUNCTION cal_control(pperiodo text, pcalculo integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
--  vEmpezo  time:=clock_timestamp();
--  vTermino time; 
  vPeriodo_1 Text;
  vCalculo_1 integer;
  vPeriodoexiste Text;
  vrecactual record;
  vrecanterior record;
  vreccampos record;
  vnivelant integer;
  vsumanivelant double precision;
  vEsPeriodobase Text;
  vgrupo_raiz Text;
BEGIN
--perform VoyPor('Cal_Control');
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='comenzo');

  SELECT c.periodoanterior, c.calculoanterior, c.EsPeriodobase, cd.grupo_raiz  
    INTO vPeriodo_1, vCalculo_1, vEsPeriodobase,  vgrupo_raiz
    FROM Calculos c, Calculos_def cd    
    WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.calculo= cd.calculo;
    
  IF vEsPeriodobase='N' THEN 
   --Debe existir el cálculo del periodo anterior
    SELECT periodo INTO vPeriodoexiste
      FROM Calculos
      WHERE periodo=vPeriodo_1 AND calculo=vCalculo_1;
    IF vPeriodoexiste IS NULL THEN
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', pmensaje:='No existe el calculo anterior ('||vPeriodo_1||', '|| vCalculo_1|| ')');
    END IF;
     --La canasta actual debe ser la misma que la usada en el cálculo anterior
    FOR vrecactual IN
      SELECT p.periodo,p.calculo,p.producto
        FROM CalProd p                               
        LEFT JOIN CalProd p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 
        JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND p.producto=gp.producto
        WHERE p0.producto IS NULL  AND p.periodo=pPeriodo AND p.calculo=pCalculo
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. Hay un producto sobrante "%"',vrecactual.producto;        
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', pmensaje:='ERROR en el calculo. Hay un producto sobrante "'|| vrecactual.producto|| '"', 
                           pProducto:=vrecactual.producto);
    END LOOP;
    FOR vrecanterior IN
      SELECT p0.periodo,p0.calculo,p0.producto
        FROM CalProd p0 
        LEFT JOIN CalProd p ON p.producto=p0.producto  AND p.periodo=pPeriodo AND p.calculo=pCalculo 
        JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND p0.producto=gp.producto
        WHERE p.producto IS NULL AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. Hay un producto faltante "%"',vrecanterior.producto;        
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', pmensaje:='ERROR en el calculo. Hay un producto faltante "'|| vrecanterior.producto|| '"', 
                           pProducto:=vrecanterior.producto);
    END LOOP;
    --Cal_Control existen registros y campos del t-1
    --Campos que difieren de un mes a otro
    FOR vreccampos IN
      SELECT p.periodo,p.calculo,p.producto,p.agrupacion,
             p.CantPorUnidCons,p0.CantPorUnidCons as CantPorUnidConsant
        FROM CalProdAgr p 
        JOIN CalProdAgr p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 AND p.agrupacion = p0.agrupacion      
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
          AND p.CantPorUnidCons is distinct from p0.CantPorUnidCons

    LOOP
      IF vreccampos.CantPorUnidCons is distinct from vreccampos.CantPorUnidConsant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "cantporunidcons" en el producto "%"', vreccampos.producto;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "cantporunidcons" en el producto "'||vreccampos.producto||'" y agrupacion "'||vreccampos.agrupacion||'"', 
            pProducto:=vreccampos.producto,pAgrupacion:=vreccampos.agrupacion);
      END IF;
    END LOOP;
    FOR vreccampos IN
      SELECT p.periodo,p.calculo,p.producto,
             p.UnidadMedidaPorUnidCons,p0.UnidadMedidaPorUnidCons as UnidadMedidaPorUnidConsant,
             p.PesoVolumenPorUnidad,p0.PesoVolumenPorUnidad as PesoVolumenPorUnidadant ,
             p.Cantidad,p0.Cantidad as Cantidadant, p.UnidadDeMedida,p0.UnidadDeMedida as UnidadDeMedidaant, p.CoefAjuste, p0.CoefAjuste as CoefAjusteant
        FROM CalProdAgr p 
        JOIN CalProdAgr p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 AND p0.agrupacion=p.agrupacion      
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
          AND ( p.UnidadMedidaPorUnidCons is distinct from p0.UnidadMedidaPorUnidCons
          OR    p.PesoVolumenPorUnidad is distinct from p0.PesoVolumenPorUnidad
          OR    p.Cantidad is distinct from p0.Cantidad
          OR    p.UnidadDeMedida is distinct from p0.UnidadDeMedida
		  OR    P.CoefAjuste is distinct from p0.CoefAjuste)

    LOOP
      IF vreccampos.UnidadMedidaPorUnidCons is distinct from vreccampos.UnidadMedidaPorUnidConsant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "unidadmedidaporunidcons" en el producto "%"', vreccampos.producto;        
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "unidadmedidaporunidcons" en el producto "'||vreccampos.producto||'"', 
            pProducto:=vreccampos.producto);
      END IF;
      IF vreccampos.PesoVolumenPorUnidad is distinct from vreccampos.PesoVolumenPorUnidadant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "pesovolumenporunidad" en el producto "%"', vreccampos.producto;        
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "pesovolumenporunidad" en el producto "'||vreccampos.producto||'"', 
            pProducto:=vreccampos.producto);
      END IF;
      --van instrucciones que siguen faltarian casos de prueba 
      IF vreccampos.Cantidad  is distinct from vreccampos.Cantidadant THEN
        --Raise Notice 'Diferencia % y %',vreccampos.Cantidad,vreccampos.Cantidadant;
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "cantidad" en el producto "%", %, actual "%" anterior "%"', vreccampos.producto, pperiodo, vreccampos.Cantidad, vreccampos.Cantidadant;    
      END IF;
      IF vreccampos.UnidadDeMedida  is distinct from vreccampos.UnidadDeMedidaant THEN
        --Raise Notice 'Diferencia % y %',vreccampos.UnidadDeMedida,vreccampos.UnidadDeMedidaant;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='log', 
            pmensaje:='Diferencia '||vreccampos.UnidadDeMedida||' y '||vreccampos.UnidadDeMedidaant);
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "unidadDeMedida" en el producto "%"', vreccampos.producto;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "unidadDeMedida" en el producto "'||vreccampos.producto||'"', 
            pProducto:=vreccampos.producto);
      END IF; 
      IF vreccampos.CoefAjuste is distinct from vreccampos.CoefAjusteant THEN
        RAISE NOTICE 'ADVERTENCIA en el calculo. No coincide el parametro "CoefAjuste" en el producto "%"', vreccampos.producto;        
        --EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
        --    pmensaje:='ERROR en el calculo. No coincide el parametro "pesovolumenporunidad" en el producto "'||vreccampos.producto||'"', 
        --    pProducto:=vreccampos.producto);
      END IF;
    END LOOP;
      --    
    FOR vreccampos IN 
      SELECT p.periodo,p.calculo,p.producto,p.PonderadorDiv,p.division,p0.ponderadorDiv as ponderadorDiv_ant
        FROM CalDiv p 
        FULL OUTER JOIN CalDiv p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 
                                  AND p.division=p0.division
        JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND p.producto=gp.producto                          
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
          AND ( p.ponderadorDiv is distinct from p0.ponderadorDiv)
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "ponderadordiv" en el producto "%" division "%" antes % ahora %', vreccampos.producto, vreccampos.division, vreccampos.ponderadorDiv_ant,vreccampos.ponderadorDiv;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "ponderadordiv" en el producto "'||vreccampos.producto||'" division "'||vreccampos.division||'" antes '||vreccampos.ponderadorDiv_ant||' ahora '||vreccampos.ponderadorDiv, 
            pProducto:=vreccampos.producto, pDivision:=vreccampos.division);
    END LOOP;  
    --Campos que difieren de un mes a otro: tablas CalGru, CalHogGru
    --van instrucciones que siguen faltarian casos de prueba

    FOR vreccampos IN 
      SELECT p.periodo,p.calculo,p.grupo,p.GrupoPadre, p0.GrupoPadre as GrupoPadreant,
             p.Nivel, p0.Nivel as Nivelant,
             p.EsProducto, p0.EsProducto as EsProductoant,
             p.agrupacion
        FROM CalGru p 
        JOIN Agrupaciones a ON  a.agrupacion=p.agrupacion  --pk verificada
        JOIN Calculos_def cd ON p.calculo=cd.calculo       --pk verificada
        JOIN Calculos c ON p.periodo=c.periodo AND p.calculo=c.calculo   --pk verificada
        JOIN CalGru p0 ON p.agrupacion=p0.agrupacion AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 
                          AND p.grupo=p0.grupo   --pk verificada                     
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
          AND (p.agrupacion=cd.agrupacionprincipal or a.calcular_junto_grupo= cd.agrupacionPrincipal)
          AND ( p.Grupopadre is distinct from p0.GrupoPadre
          OR    p.Nivel is distinct from p0.Nivel
          OR    p.EsProducto is distinct from p0.EsProducto )
    LOOP
      IF vreccampos.GrupoPadre is distinct from vreccampos.GrupoPadreant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "GrupoPadre" en el grupo "%"', vreccampos.grupo;        
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "GrupoPadre" en el grupo "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);
      END IF;
      IF vreccampos.Nivel is distinct from vreccampos.Nivelant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "Nivel" en el grupo "%"', vreccampos.grupo;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "Nivel" en el grupo "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);

      END IF;
      IF vreccampos.EsProducto is distinct from vreccampos.EsProductoant THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "EsProducto" en el grupo "%"', vreccampos.grupo;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "EsProducto" en el grupo "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);
      END IF;
    END LOOP;  
    FOR vreccampos IN 
      SELECT p.periodo,p.calculo,p.grupo,p.CoefHogGru, p.agrupacion, p.hogar
        FROM CalHogGru p 
        JOIN Agrupaciones a ON  a.agrupacion=p.agrupacion  --pk verificada
        JOIN Calculos_def cd ON p.calculo=cd.calculo --pk verificada
        JOIN Calculos c ON p.periodo=c.periodo AND p.calculo=c.calculo  --pk verificada
        JOIN CalHogGru p0 ON p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 
                          AND p.hogar=p0.hogar AND p.agrupacion=p0.agrupacion 
                          AND p.grupo=p0.grupo --pk verificada
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo
          AND a.calcular_junto_grupo=cd.agrupacionprincipal
          AND ( p.coefhoggru is distinct from p0.coefhoggru)
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. No coincide el parametro "coefhoggru" en el grupo "%"', vreccampos.grupo;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. No coincide el parametro "coefhoggru" en el grupo "'||vreccampos.grupo||'"  Hogar '|| vreccampos.hogar, 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);
    END LOOP; 

    --Cal_Control estructura mes actual Grupos 
    --Falta el grupo padre --cambiado
    FOR vreccampos IN 
      SELECT ca.grupo, ca.grupopadre, ca.agrupacion
        FROM CalGru ca
        WHERE ca.periodo=pPeriodo AND ca.calculo=pCalculo AND ca.nivel is distinct from 0 
          AND ca.grupopadre NOT IN ( SELECT cb.grupo
                                       FROM CalGru cb    -- pk verificada
                                       WHERE ca.grupopadre=cb.grupo AND ca.agrupacion=cb.agrupacion
                                         AND ca.periodo=cb.periodo AND ca.calculo=cb.calculo)
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. Falta el grupo "%" padre de  "%"', vreccampos.grupopadre, vreccampos.grupo;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. Falta el grupo "'||vreccampos.grupopadre||'" padre de "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);
      
    END LOOP;
    --Los campos grupopadre deben ser prefijos de grupo
    FOR vreccampos IN 
      SELECT g.grupo, g.grupopadre
        FROM CalGru g, Calculos c, Calculos_def cd 
        WHERE ( (SUBSTR(g.grupo, 1, NIVEL+1) is distinct from g.grupopadre AND g.esproducto='N' AND g.nivel is distinct from 0 AND g.nivel is distinct from 1) 
           OR   (g.nivel =1 and SUBSTR(g.grupo,1,NIVEL) is distinct from g.grupopadre) )
          AND g.periodo=pPeriodo AND g.calculo=pCalculo AND g.periodo=c.periodo AND g.calculo=c.calculo
          AND g.calculo=cd.calculo AND g.agrupacion=cd.agrupacionprincipal
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. El campo grupopadre "%" no es prefijo del grupo "%"', vreccampos.grupopadre, vreccampos.grupo;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El campo grupopadre "'||vreccampos.grupopadre||'" no es prefijo del grupo "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo);
    END LOOP;
    --len(GrupoPadre)=len(Grupo) -1
    FOR vreccampos IN 
      SELECT g.grupo,g.grupopadre
        FROM CalGru g, Calculos c, Calculos_def cd 
        WHERE ( (length(g.grupopadre) is distinct from length(g.grupo)-1 AND g.esproducto='N'  AND g.nivel >1)
           OR   (length(g.grupopadre) is distinct from length(g.grupo)-2 AND g.esproducto='N'  AND g.nivel =1 ) )
          AND g.periodo=pPeriodo AND g.calculo=pCalculo AND g.periodo=c.periodo AND g.calculo=c.calculo 
          AND g.calculo=cd.calculo AND g.agrupacion=cd.agrupacionprincipal      
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. La longitud del campo grupopadre "%" debe ser igual a la longitud del grupo -1 "%"', vreccampos.grupopadre, vreccampos.grupo;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. La longitud del campo grupopadre "'||vreccampos.grupopadre||'" debe ser igual a la longitud del grupo -1 "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo);
    END LOOP;
    --Nivel=len(grupo)-2
    FOR vreccampos IN 
      SELECT g.grupo,g.nivel
        FROM CalGru g, Calculos c, Calculos_def cd 
        WHERE g.nivel is distinct from length(g.grupo)-2  AND g.esproducto='N' AND g.nivel >0
          AND g.periodo=pPeriodo AND g.calculo=pCalculo AND g.periodo=c.periodo AND g.calculo=c.calculo 
          AND g.calculo=cd.calculo AND g.agrupacion=cd.agrupacionprincipal      
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. La longitud del campo nivel "%" debe ser igual a la longitud del grupo -2 "%"', vreccampos.nivel, vreccampos.grupo;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. La longitud del campo nivel "'||vreccampos.nivel||'" debe ser igual a la longitud del grupo -1 "'||vreccampos.grupo||'"', 
            pGrupo:=vreccampos.grupo);
    END LOOP;
    --El ValorGru de Calgru del grupo padre debe ser mayor o igual a cada uno de sus hijos
    FOR vreccampos IN 
      SELECT ca.valorgru, ca.grupo,cb.grupo as grupohijo, cb.valorgru as valorgruhijo, cb.agrupacion
        FROM CalGru ca, Calculos c, CalGru cb, Calculos_def cd , Agrupaciones a
        WHERE ca.periodo=pPeriodo AND ca.calculo=pCalculo AND  ca.periodo=c.periodo AND ca.calculo=c.calculo --pk de c verificada
          AND cb.grupopadre=ca.grupo  AND ca.periodo=cb.periodo AND ca.calculo=cb.calculo AND ca.agrupacion=cb.agrupacion ----pk de ca verificada
          AND ca.valorgru < cb.valorgru
          AND ca.calculo=cd.calculo  -- pk verificada cd
          AND a.agrupacion= cb.agrupacion --pk verificada
          AND a.calcular_junto_grupo=cd.agrupacionPrincipal AND a.valoriza
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. El Valorgru(Calgru) del grupo padre "%"  Valorgru "%" debe ser mayor o igual a cada uno de sus hijos "%" valorgruhijo "%"', vreccampos.grupo, vreccampos.valorgru, vreccampos.grupohijo, vreccampos.valorgruhijo;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El Valorgru(Calgru) del grupo padre "'||vreccampos.grupo||'"  Valorgru "'||vreccampos.valorgru||'" debe ser mayor o igual a cada uno de sus hijos "'||vreccampos.grupohijo||'" valorgruhijo "'||vreccampos.valorgruhijo||'"', 
            pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);
    END LOOP; 
  /*    
    --La suma de los valores agrupados por nivel debe ser igual 
    --Comentado porque no se cumple para la agrupación B
    FOR vreccampos IN 
      SELECT ca.nivel, sum(valorgru) as sumanivel, ca.agrupacion
        FROM CalGru ca,  Calculos c, Calculos_def cd , Agrupaciones a
        WHERE ca.periodo=pPeriodo AND ca.calculo=pCalculo AND  ca.periodo=c.periodo AND ca.calculo=c.calculo   --pk verificada de c                    
          AND ca.calculo=cd.calculo  --pk verificada cd
          AND a.agrupacion= ca.agrupacion --pk verificada
          AND a.calcular_junto_grupo=cd.agrupacionPrincipal and a.valoriza 
        GROUP BY ca.nivel, ca.agrupacion
        ORDER BY ca.agrupacion, ca.nivel    
    LOOP
      IF vreccampos.nivel= 0 THEN --inicializo
        vnivelant=vreccampos.nivel;
        vsumanivelant=vreccampos.sumanivel;
      END IF;
      IF round(vsumanivelant::numeric,9)=round(vreccampos.sumanivel::numeric,9) THEN
        vnivelant=vreccampos.nivel;  
        vsumanivelant=vreccampos.sumanivel;
      ELSE 
        --RAISE EXCEPTION 'ERROR en el calculo. La suma de los valores agrupados "%" del nivel "%" debe ser igual a la suma de los valores agrupados "%" del nivel ant "%"', vreccampos.sumanivel, vreccampos.nivel, vsumanivelant, vnivelant;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pMensaje:='ERROR en el calculo. La suma de los valores agrupados "'||vreccampos.sumanivel||'" del nivel "'||vreccampos.nivel||'" debe ser igual a la suma de los valores agrupados "'||vsumanivelant||'" del nivel ant "'||vnivelant||'"',
            pAgrupacion:=vreccampos.agrupacion);
      END IF;  
    END LOOP;   
  */    
    --Completitud    
    --CalProdAgr 
    FOR vreccampos IN 
      SELECT p.periodo,p.calculo,p.producto, p.valorprod, p0.valorprod as valorprodant
        FROM CalProdAgr p 
          JOIN CalProdAgr p0 ON p.agrupacion = p0.agrupacion and p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1  --PK verificada
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo 
          AND ((p0.valorprod is null AND p.valorprod is not null) OR (p0.valorprod is not null AND p.valorprod is null)) 
    LOOP
      IF (vreccampos.valorprodant is null AND vreccampos.valorprod is not null) OR (vreccampos.valorprodant is not null AND vreccampos.valorprod is null) THEN
       -- RAISE EXCEPTION 'ERROR en el calculo. No coincide el valor de valorprod, en cuanto a nulidad: "%" en el producto "%"', vreccampos.valorprod, --vreccampos.producto; 
          EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
              pmensaje:='ERROR en el calculo. No coincide el valor de valorprod, en cuanto a nulidad: "' ||coalesce(vreccampos.valorprod::text,'nulo')|| '" en el producto "'|| vreccampos.producto ||'"', 
              pProducto:=vreccampos.producto);       
      END IF;
    END LOOP;
    --CalProd 
    FOR vreccampos IN 
      SELECT p.periodo, p.calculo, p.producto, p.promprod, p0.promprod as promprodant
        FROM CalProd p 
          JOIN CalProd p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1  --PK verificada
        WHERE p.periodo=pPeriodo AND p.calculo=pCalculo 
          AND ((p0.promprod is null AND p.promprod is not null)  OR (p0.promprod is not null AND p.promprod is null))
    LOOP
      IF (vreccampos.promprodant is null AND vreccampos.promprod is not null)  OR (vreccampos.promprodant is not null AND vreccampos.promprod is null) THEN
        --RAISE EXCEPTION 'ERROR en el calculo. No coincide el valor de promprod, en cuanto a nulidad: "%" en el producto "%"', vreccampos.promprod , --vreccampos.producto; 
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
              pmensaje:='ERROR en el calculo. No coincide el valor de promprod, en cuanto a nulidad: "' ||coalesce(vreccampos.promprod::text,'nulo')|| '" en el producto "'|| vreccampos.producto ||'"', 
              pProducto:=vreccampos.producto);               
      END IF;
    END LOOP;
    --CalGru 
    FOR vreccampos IN 
    SELECT p.periodo,p.calculo,p.grupo, p.valorgru, p0.valorgru as valorgruant, a.agrupacion
      FROM CalGru p 
        JOIN Agrupaciones a ON  a.agrupacion=p.agrupacion  --pk verificada
        JOIN Calculos_def cd ON  cd.calculo=p.calculo  --pk verificada
        JOIN Calculos c ON p.periodo=c.periodo AND p.calculo=c.calculo    --pk verificada
        JOIN CalGru p0 ON p.grupo=p0.grupo AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 AND p.agrupacion=p0.agrupacion  --pk verificada
      WHERE p.periodo=pPeriodo AND p.calculo=pCalculo 
           AND a.calcular_junto_grupo=cd.agrupacionprincipal AND a.valoriza
           AND ( (p0.valorGru is null AND p.valorGru is not null) OR (p0.valorGru is not null AND p.valorGru is null) ) 
    LOOP
      IF (vreccampos.valorgruant is null AND vreccampos.valorgru is not null) OR (vreccampos.valorgruant is not null AND vreccampos.valorgru is null) THEN
      --  RAISE EXCEPTION 'ERROR en el calculo. No coincide el valor de valorgru:, en cuanto a nulidad: "%" en el grupo "%"', vreccampos.valorgru, vreccampos.grupo;   
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
             pmensaje:='ERROR en el calculo. No coincide el valor de valorgru:, en cuanto a nulidad: "' ||coalesce(vreccampos.valorgru::text,'nulo')|| '" en el grupo "' || vreccampos.grupo||'"', 
             pGrupo:=vreccampos.grupo, pAgrupacion:=vreccampos.agrupacion);        
      END IF;
    END LOOP; 
                 
    --Cal_Control estructura mes actual Atributos

    FOR vreccampos IN 
    SELECT p.producto, p.atributo, p.valornormal, a.tipodato, a.escantidad, a.unidaddemedida 
      FROM Prodatr p, Atributos a, Calculos c, Gru_Prod gp
      WHERE p.atributo=a.atributo AND p.normalizable='S' AND c.periodo=pPeriodo AND c.calculo=pCalculo 
        AND ( tiponormalizacion='Normal' AND (p.valornormal IS NULL OR a.tipodato is distinct from 'N' OR a.escantidad is distinct from 'S' 
             OR unidaddemedida IS NULL) )
        AND gp.grupo_padre=vgrupo_raiz AND p.producto=gp.producto
    LOOP 
      IF vreccampos.tipodato is distinct from 'N' THEN
        --RAISE EXCEPTION 'ERROR en el calculo. El producto "%" normaliza con el atributo  "%" que no es numerico ', vreccampos.producto, vreccampos.atributo;        
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El producto "'||vreccampos.producto||'" normaliza con el atributo  "'||vreccampos.atributo||'" que no es numerico ', 
            pProducto:=vreccampos.producto);
      END IF;         
      IF vreccampos.escantidad is distinct from 'S' THEN
        --RAISE EXCEPTION 'ERROR en el calculo. El producto "%" normaliza con el atributo  "%" que no es cantidad ', vreccampos.producto, vreccampos.atributo;            
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El producto "'||vreccampos.producto||'" normaliza con el atributo  "'||vreccampos.atributo||'" que no es cantidad ', 
            pProducto:=vreccampos.producto);
      END IF;
      IF vreccampos.unidaddemedida IS NULL THEN
        --RAISE EXCEPTION 'ERROR en el calculo. El producto "%" normaliza con el atributo  "%" que no tiene unidad de medida especificada ', vreccampos.producto, vreccampos.atributo;        
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El producto "'||vreccampos.producto||'" normaliza con el atributo  "'||vreccampos.atributo||'" que no tiene unidad de medida especificada ', 
            pProducto:=vreccampos.producto);
      END IF;
      IF vreccampos.valornormal IS NULL  THEN
        --RAISE EXCEPTION 'ERROR en el calculo. El producto "%" normaliza con el atributo  "%" que no tiene valor normal ', vreccampos.producto, vreccampos.atributo;            
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El producto "'||vreccampos.producto||'" normaliza con el atributo  "'||vreccampos.atributo||'" que no tiene valor normal ', 
            pProducto:=vreccampos.producto);
      END IF;            
    END LOOP;

    --Cal_Control estructura mes actual Cal vs Fijas                

    DECLARE
      vProductoNoEsta text;
    BEGIN
      SELECT p.producto INTO vProductoNoEsta
        FROM Productos p LEFT JOIN CalProd c ON c.producto=p.producto AND c.Periodo=pPeriodo AND c.Calculo=pCalculo
        JOIN Gru_Prod gp ON gp.grupo_padre=vgrupo_raiz AND p.producto=gp.producto
        WHERE c.producto IS NULL
          AND pPeriodo >'a2012m06'
        ORDER BY p.producto
        LIMIT 1;
      IF vProductoNoEsta IS NOT NULL THEN
        --RAISE EXCEPTION 'ERROR en el calculo. El producto "%" no figura en los resultados', vProductoNoEsta;
        EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El producto "'||vProductoNoEsta||'" no figura en los resultados', pProducto:=vProductoNoEsta);
      END IF;
    END;
  END IF;

    --Cal_Control control en CalObs

    FOR vrecactual IN
      SELECT distinct p.informante, p0.muestra as muestra_anterior, p.muestra as muestra_actual
        FROM CalObs p 
        JOIN CalObs p0 ON p.producto=p0.producto AND p0.periodo=vPeriodo_1 AND p0.calculo=vCalculo_1 AND p0.informante=p.informante AND p0.observacion=p.observacion         
        WHERE p0.muestra<>p.muestra AND p.periodo=pPeriodo AND p.calculo=pCalculo
    LOOP
      --RAISE EXCEPTION 'ERROR en el calculo. El informante "%" cambio de muestra (estaba en %, esta en %)',
      --       vrecactual.informante, vrecactual.muestra_anterior, vrecactual.muestra_actual;
      EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='error', 
            pmensaje:='ERROR en el calculo. El informante "'||vrecactual.informante||'" cambio de muestra (estaba en '||vrecactual.muestra_anterior||', esta en '||vrecactual.muestra_actual||')');
    END LOOP;
--perform VoyPor('Cal_Control');

--vTermino:=clock_timestamp();
--RAISE NOTICE '%','Cal_Control: Empezo '||cast(vEmpezo as text)||' termino '||cast(vTermino as text)||' demoro '||(vTermino - vEmpezo);
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_Control', pTipo:='finalizo');

END;
$$;
----------------------------------------------------------------------------------------------------
-- UTF8:Sí 
CREATE or replace FUNCTION calprod_valorizar(pperiodo text, pcalculo integer, pAgrupacionEspecial text default null) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE  
  vcalprod RECORD;
 
BEGIN  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Valorizar', pTipo:='comenzo');

FOR vcalprod IN
  SELECT d.periodo, d.calculo, d.producto, a.agrupacion, a.cantporunidcons, u1.factor as factorucons, a.cantidad, u2.factor as factor
        , d.promdiv, d.PromedioRedondeado, a.pesovolumenporunidad, a.coefajuste 
    FROM CalDiv d
        JOIN CalProdAgr a ON d.periodo=a.periodo AND d.calculo=a.calculo AND d.producto=a.producto        
        JOIN Unidades u1 ON a.unidadmedidaporunidcons = u1.unidad 
        JOIN Unidades u2 ON a.unidaddemedida = u2.unidad  --PK verificada 
    WHERE d.periodo=pPeriodo AND d.calculo=pCalculo AND d.division='0'
      AND (a.agrupacion = pAgrupacionEspecial or pAgrupacionEspecial is null)
LOOP  
 UPDATE CalProdAgr SET  ValorProd 
   =(vcalprod.PromedioRedondeado*vcalprod.cantporunidcons*vcalprod.factorucons*COALESCE(vcalprod.coefajuste,1))/(vcalprod.cantidad*vcalprod.factor*COALESCE(vcalprod.pesovolumenporunidad,1))
   WHERE periodo = vcalprod.periodo AND calculo = vcalprod.calculo AND producto = vcalprod.producto AND agrupacion = vcalprod.agrupacion;  
END LOOP;
 
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_Valorizar', pTipo:='finalizo', pagrupacion:=pagrupacionespecial);
END;
$$;