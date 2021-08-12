set search_path = cvp;
ALTER TABLE relvis ADD COLUMN codcomentarios TEXT;

ALTER TABLE his.relvis add column codcomentarios text;	

CREATE OR REPLACE FUNCTION cvp.hisc_relvis_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
	VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
  DECLARE
    v_operacion text:=substr(TG_OP,1,1);
  BEGIN
    
  IF v_operacion='I' THEN
    
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','periodo','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.periodo),new.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','informante','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.informante),new.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','formulario','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.formulario),new.formulario);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','panel','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.panel),new.panel);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','tarea','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.tarea),new.tarea);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_datetime)
             VALUES ('cvp','relvis','fechasalida','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.fechasalida),new.fechasalida);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_datetime)
             VALUES ('cvp','relvis','fechaingreso','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.fechaingreso),new.fechaingreso);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','ingresador','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.ingresador),new.ingresador);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','razon','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.razon),new.razon);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_datetime)
             VALUES ('cvp','relvis','fechageneracion','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.fechageneracion),new.fechageneracion);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','visita','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.visita),new.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','ultimavisita','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.ultimavisita),new.ultimavisita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','modi_usu','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_datetime)
             VALUES ('cvp','relvis','modi_fec','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','modi_ope','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','comentarios','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.comentarios),new.comentarios);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','encuestador','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.encuestador),new.encuestador);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','supervisor','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.supervisor),new.supervisor);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','recepcionista','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.recepcionista),new.recepcionista);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_number)
             VALUES ('cvp','relvis','informantereemplazante','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.informantereemplazante),new.informantereemplazante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_bool)
             VALUES ('cvp','relvis','ultima_visita','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.ultima_visita),new.ultima_visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','verificado_rec','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.verificado_rec),new.verificado_rec);
		INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_bool)
             VALUES ('cvp','relvis','preciosgenerados','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.preciosgenerados),new.preciosgenerados);
		INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','token_relevamiento','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.token_relevamiento),new.token_relevamiento);
		INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,new_text)
             VALUES ('cvp','relvis','codcomentarios','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,'I:'||comun.a_texto(new.codcomentarios),new.codcomentarios);
  END IF;
  IF v_operacion='U' THEN
        
        IF new.periodo IS DISTINCT FROM old.periodo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','periodo','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
        END IF;    
        IF new.informante IS DISTINCT FROM old.informante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','informante','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
        END IF;    
        IF new.formulario IS DISTINCT FROM old.formulario THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','formulario','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.formulario)||'->'||comun.a_texto(new.formulario),old.formulario,new.formulario);
        END IF;    
        IF new.panel IS DISTINCT FROM old.panel THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','panel','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.panel)||'->'||comun.a_texto(new.panel),old.panel,new.panel);
        END IF;    
        IF new.tarea IS DISTINCT FROM old.tarea THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','tarea','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.tarea)||'->'||comun.a_texto(new.tarea),old.tarea,new.tarea);
        END IF;    
        IF new.fechasalida IS DISTINCT FROM old.fechasalida THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','relvis','fechasalida','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.fechasalida)||'->'||comun.a_texto(new.fechasalida),old.fechasalida,new.fechasalida);
        END IF;    
        IF new.fechaingreso IS DISTINCT FROM old.fechaingreso THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','relvis','fechaingreso','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.fechaingreso)||'->'||comun.a_texto(new.fechaingreso),old.fechaingreso,new.fechaingreso);
        END IF;    
        IF new.ingresador IS DISTINCT FROM old.ingresador THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','ingresador','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.ingresador)||'->'||comun.a_texto(new.ingresador),old.ingresador,new.ingresador);
        END IF;    
        IF new.razon IS DISTINCT FROM old.razon THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','razon','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.razon)||'->'||comun.a_texto(new.razon),old.razon,new.razon);
        END IF;    
        IF new.fechageneracion IS DISTINCT FROM old.fechageneracion THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','relvis','fechageneracion','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.fechageneracion)||'->'||comun.a_texto(new.fechageneracion),old.fechageneracion,new.fechageneracion);
        END IF;    
        IF new.visita IS DISTINCT FROM old.visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','visita','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
        END IF;    
        IF new.ultimavisita IS DISTINCT FROM old.ultimavisita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','ultimavisita','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.ultimavisita)||'->'||comun.a_texto(new.ultimavisita),old.ultimavisita,new.ultimavisita);
        END IF;    
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','modi_usu','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','relvis','modi_fec','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','modi_ope','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;    
        IF new.comentarios IS DISTINCT FROM old.comentarios THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','comentarios','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.comentarios)||'->'||comun.a_texto(new.comentarios),old.comentarios,new.comentarios);
        END IF;    
        IF new.encuestador IS DISTINCT FROM old.encuestador THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','encuestador','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.encuestador)||'->'||comun.a_texto(new.encuestador),old.encuestador,new.encuestador);
        END IF;    
        IF new.supervisor IS DISTINCT FROM old.supervisor THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','supervisor','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.supervisor)||'->'||comun.a_texto(new.supervisor),old.supervisor,new.supervisor);
        END IF;    
        IF new.recepcionista IS DISTINCT FROM old.recepcionista THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','recepcionista','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.recepcionista)||'->'||comun.a_texto(new.recepcionista),old.recepcionista,new.recepcionista);
        END IF;    
        IF new.informantereemplazante IS DISTINCT FROM old.informantereemplazante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number,new_number)
                 VALUES ('cvp','relvis','informantereemplazante','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.informantereemplazante)||'->'||comun.a_texto(new.informantereemplazante),old.informantereemplazante,new.informantereemplazante);
        END IF;
        IF new.ultima_visita IS DISTINCT FROM old.ultima_visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_bool,new_bool)
                 VALUES ('cvp','relvis','ultima_visita','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.ultima_visita)||'->'||comun.a_texto(new.ultima_visita),old.ultima_visita,new.ultima_visita);
        END IF;
        IF new.verificado_rec IS DISTINCT FROM old.verificado_rec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','verificado_rec','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.verificado_rec)||'->'||comun.a_texto(new.verificado_rec),old.verificado_rec,new.verificado_rec);
        END IF;
		IF new.preciosgenerados IS DISTINCT FROM old.preciosgenerados THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_bool,new_bool)
                 VALUES ('cvp','relvis','preciosgenerados','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.preciosgenerados)||'->'||comun.a_texto(new.preciosgenerados),old.preciosgenerados,new.preciosgenerados);
        END IF;		
		IF new.token_relevamiento IS DISTINCT FROM old.token_relevamiento THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','token_relevamiento','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.token_relevamiento)||'->'||comun.a_texto(new.token_relevamiento),old.token_relevamiento,new.token_relevamiento);
        END IF;    
		IF new.codcomentarios IS DISTINCT FROM old.codcomentarios THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text,new_text)
                 VALUES ('cvp','relvis','codcomentarios','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.formulario,new.periodo,new.informante,new.visita,new.formulario,comun.A_TEXTO(old.codcomentarios)||'->'||comun.a_texto(new.codcomentarios),old.codcomentarios,new.codcomentarios);
        END IF;    
  END IF;
  IF v_operacion='D' THEN
    
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','periodo','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.periodo),old.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','informante','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.informante),old.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','formulario','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.formulario),old.formulario);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','panel','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.panel),old.panel);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','tarea','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.tarea),old.tarea);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime)
             VALUES ('cvp','relvis','fechasalida','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.fechasalida),old.fechasalida);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime)
             VALUES ('cvp','relvis','fechaingreso','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.fechaingreso),old.fechaingreso);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','ingresador','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.ingresador),old.ingresador);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','razon','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.razon),old.razon);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime)
             VALUES ('cvp','relvis','fechageneracion','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.fechageneracion),old.fechageneracion);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','visita','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.visita),old.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','ultimavisita','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.ultimavisita),old.ultimavisita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','modi_usu','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_datetime)
             VALUES ('cvp','relvis','modi_fec','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','modi_ope','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','comentarios','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.comentarios),old.comentarios);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','encuestador','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.encuestador),old.encuestador);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','supervisor','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.supervisor),old.supervisor);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','recepcionista','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.recepcionista),old.recepcionista);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_number)
             VALUES ('cvp','relvis','informantereemplazante','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.informantereemplazante),old.informantereemplazante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_bool)
             VALUES ('cvp','relvis','ultima_visita','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.ultima_visita),old.ultima_visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','verificado_rec','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.verificado_rec),old.verificado_rec);
	    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_bool)
             VALUES ('cvp','relvis','preciosgenerados','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.preciosgenerados),old.preciosgenerados);
		INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','token_relevamiento','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.token_relevamiento),old.token_relevamiento);
		INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,change_value,old_text)
             VALUES ('cvp','relvis','codcomentarios','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.formulario,old.periodo,old.informante,old.visita,old.formulario,'D:'||comun.a_texto(old.codcomentarios),old.codcomentarios);
  END IF;
  
  IF v_operacion<>'D' THEN
      RETURN new;
  ELSE
      RETURN old;  
  END IF;
  END;
$BODY$;