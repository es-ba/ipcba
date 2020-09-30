set search_path = cvp;
ALTER TABLE productos ADD COLUMN "cluster" integer;

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
        END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;

