set search_path = cvp;
ALTER TABLE prodatr ADD COLUMN visible cvp.sino_dom NOT NULL DEFAULT 'S';

CREATE OR REPLACE FUNCTION hisc_prodatr_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','producto','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.producto),new.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','atributo','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.atributo),new.atributo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','valornormal','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.valornormal),new.valornormal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','orden','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.orden),new.orden);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','normalizable','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.normalizable),new.normalizable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','tiponormalizacion','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.tiponormalizacion),new.tiponormalizacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','alterable','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.alterable),new.alterable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','prioridad','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.prioridad),new.prioridad);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','operacion','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.operacion),new.operacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','rangodesde','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.rangodesde),new.rangodesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','rangohasta','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.rangohasta),new.rangohasta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','modi_usu','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','prodatr','modi_fec','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','modi_ope','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','prodatr','orden_calculo_especial','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.orden_calculo_especial),new.orden_calculo_especial);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','tipo_promedio','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.tipo_promedio),new.tipo_promedio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','esprincipal','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.esprincipal),new.esprincipal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','visiblenombreatributo','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.visiblenombreatributo),new.visiblenombreatributo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','otraunidaddemedida','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.otraunidaddemedida),new.otraunidaddemedida);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','opciones','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.opciones),new.opciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','validaropciones','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.validaropciones),new.validaropciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','prodatr','visible','I',new.producto||'|'||new.atributo,new.producto,new.atributo,'I:'||comun.a_texto(new.visible),new.visible);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.producto IS DISTINCT FROM old.producto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','producto','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
            END IF;    
            IF new.atributo IS DISTINCT FROM old.atributo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','atributo','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.atributo)||'->'||comun.a_texto(new.atributo),old.atributo,new.atributo);
            END IF;    
            IF new.valornormal IS DISTINCT FROM old.valornormal THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','valornormal','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.valornormal)||'->'||comun.a_texto(new.valornormal),old.valornormal,new.valornormal);
            END IF;    
            IF new.orden IS DISTINCT FROM old.orden THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','orden','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.orden)||'->'||comun.a_texto(new.orden),old.orden,new.orden);
            END IF;    
            IF new.normalizable IS DISTINCT FROM old.normalizable THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','normalizable','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.normalizable)||'->'||comun.a_texto(new.normalizable),old.normalizable,new.normalizable);
            END IF;    
            IF new.tiponormalizacion IS DISTINCT FROM old.tiponormalizacion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','tiponormalizacion','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.tiponormalizacion)||'->'||comun.a_texto(new.tiponormalizacion),old.tiponormalizacion,new.tiponormalizacion);
            END IF;    
            IF new.alterable IS DISTINCT FROM old.alterable THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','alterable','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.alterable)||'->'||comun.a_texto(new.alterable),old.alterable,new.alterable);
            END IF;    
            IF new.prioridad IS DISTINCT FROM old.prioridad THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','prioridad','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.prioridad)||'->'||comun.a_texto(new.prioridad),old.prioridad,new.prioridad);
            END IF;    
            IF new.operacion IS DISTINCT FROM old.operacion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','operacion','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.operacion)||'->'||comun.a_texto(new.operacion),old.operacion,new.operacion);
            END IF;    
            IF new.rangodesde IS DISTINCT FROM old.rangodesde THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','rangodesde','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.rangodesde)||'->'||comun.a_texto(new.rangodesde),old.rangodesde,new.rangodesde);
            END IF;    
            IF new.rangohasta IS DISTINCT FROM old.rangohasta THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','rangohasta','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.rangohasta)||'->'||comun.a_texto(new.rangohasta),old.rangohasta,new.rangohasta);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','modi_usu','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','prodatr','modi_fec','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','modi_ope','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;            
            IF new.orden_calculo_especial IS DISTINCT FROM old.orden_calculo_especial THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','prodatr','orden_calculo_especial','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.orden_calculo_especial)||'->'||comun.a_texto(new.orden_calculo_especial),old.orden_calculo_especial,new.orden_calculo_especial);
            END IF;
            IF new.tipo_promedio IS DISTINCT FROM old.tipo_promedio THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','tipo_promedio','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.tipo_promedio)||'->'||comun.a_texto(new.tipo_promedio),old.tipo_promedio,new.tipo_promedio);
            END IF;
            IF new.esprincipal IS DISTINCT FROM old.esprincipal THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','esprincipal','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.esprincipal)||'->'||comun.a_texto(new.esprincipal),old.esprincipal,new.esprincipal);
            END IF;    
            IF new.visiblenombreatributo IS DISTINCT FROM old.visiblenombreatributo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','visiblenombreatributo','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.visiblenombreatributo)||'->'||comun.a_texto(new.visiblenombreatributo),old.visiblenombreatributo,new.visiblenombreatributo);
            END IF;    
            IF new.otraunidaddemedida IS DISTINCT FROM old.otraunidaddemedida THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','otraunidaddemedida','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.otraunidaddemedida)||'->'||comun.a_texto(new.otraunidaddemedida),old.otraunidaddemedida,new.otraunidaddemedida);
            END IF;    
            IF new.opciones IS DISTINCT FROM old.opciones THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','opciones','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.opciones)||'->'||comun.a_texto(new.opciones),old.opciones,new.opciones);
            END IF;    
            IF new.validaropciones IS DISTINCT FROM old.validaropciones THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','validaropciones','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.validaropciones)||'->'||comun.a_texto(new.validaropciones),old.validaropciones,new.validaropciones);
            END IF;    
            IF new.visible IS DISTINCT FROM old.visible THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','prodatr','visible','U',new.producto||'|'||new.atributo,new.producto,new.atributo,comun.A_TEXTO(old.visible)||'->'||comun.a_texto(new.visible),old.visible,new.visible);
            END IF;    
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','producto','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.producto),old.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','atributo','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.atributo),old.atributo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','valornormal','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.valornormal),old.valornormal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','orden','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.orden),old.orden);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','normalizable','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.normalizable),old.normalizable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','tiponormalizacion','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.tiponormalizacion),old.tiponormalizacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','alterable','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.alterable),old.alterable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','prioridad','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.prioridad),old.prioridad);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','operacion','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.operacion),old.operacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','rangodesde','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.rangodesde),old.rangodesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','rangohasta','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.rangohasta),old.rangohasta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','modi_usu','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','prodatr','modi_fec','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','modi_ope','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','prodatr','orden_calculo_especial','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.orden_calculo_especial),old.orden_calculo_especial);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','tipo_promedio','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.tipo_promedio),old.tipo_promedio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','esprincipal','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.esprincipal),old.esprincipal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','visiblenombreatributo','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.visiblenombreatributo),old.visiblenombreatributo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','otraunidaddemedida','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.otraunidaddemedida),old.otraunidaddemedida);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','opciones','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.opciones),old.opciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','validaropciones','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.validaropciones),old.validaropciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','prodatr','visible','D',old.producto||'|'||old.atributo,old.producto,old.atributo,'D:'||comun.a_texto(old.visible),old.visible);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
$BODY$;

--generar panel sin pisar las asignaciones de reemplazos de encuestador
CREATE OR REPLACE FUNCTION cvp.generar_panel(
	pperiodo text,
	ppanel integer,
	pfechasalida date,
	pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  f_hoy date= current_date;
BEGIN
  /*
   V190117
      genera el encuestador a partir de la tabla reltar
   V161201
      genera el encuestador a partir de la tabla relenc (si no hay relenc, entonces en tareas)
   V100730
      con borrado previo al insert por considerar re-generacion   
   V100726
      genera también las altas manuales. 
   V100527
      genera con última visita periodo anterior, única razon en relvis (informante-formulario)
   V100515
      genera el encuestador a partir de la tabla tareas
   V100508
      sin generar informantes con cierre definitivo en visita 1 del periodo anterior
     V080924
      sin generar de baja
  */
  if pFechaSalida is null then
    RAISE EXCEPTION 'no se puede generar un panel sin fecha de salida';
  end if;
  insert into cvp.bitacora (que) values ('nueva generacion panel '||pPeriodo||' p:'||pPanel||' g:'||pFechaGeneracionPanel);

  DELETE FROM cvp.relvis rd USING
    (SELECT r.periodo, r.informante, r.formulario, r.visita
      FROM cvp.relvis r
         LEFT JOIN cvp.informantes i ON r.informante = i.informante
         LEFT JOIN cvp.periodos p ON r.periodo=p.periodo
         LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior
                                    AND r_1.informante = r.informante 
                                    AND r_1.formulario = r.formulario
                                    AND r_1.visita = r.visita          
 
         --LEFT JOIN cvp.relvis r_1 ON r_1.periodo = r.periodo_1
         --                           AND r_1.informante = r.informante 
         --                           AND r_1.formulario = r.formulario
         --                           AND r_1.visita = r.visita_1          
         LEFT JOIN cvp.razones z ON r_1.razon = z.razon
         LEFT JOIN (SELECT distinct periodo, informante, visita, formulario, 'S' hayprecios 
                      FROM cvp.relpre) pr ON pr.periodo = r.periodo
                        AND pr.informante = r.informante
                        AND pr.visita = r.visita 
                        AND pr.formulario = r.formulario 
       WHERE r.periodo = Pperiodo
         AND r.panel= pPanel
         --AltaManualPeriodo no es el periodo actual
         AND (i.AltaManualPeriodo IS DISTINCT FROM Pperiodo OR NOT EXISTS (SELECT 1 FROM cvp.forinf fi WHERE fi.informante=r.informante AND fi.formulario=r.formulario))
         --periodo anterior sin visita en relvis o con cierre definitivo  
         AND (r_1.periodo IS NULL OR COALESCE(z.escierredefinitivoinf,'N')='S' OR COALESCE(z.escierredefinitivofor,'N')='S')
         -- periodo actual sin razon ingresada y sin precios
         AND r.razon IS NULL AND COALESCE(hayprecios,'N') = 'N') d
  WHERE rd.periodo = d.periodo and rd.informante = d.informante and rd.formulario = d.formulario and rd.visita = d.visita ;
  --08/01/19: todas las tareas a reltar en el momento de la generación del panel (hasta ahora se insertaban en el momento de preparar la supervisión):
  --14/02/19: las tareas que tuvieron por lo menos una respuesta positiva (o nula) el periodo anterior
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador, modalidad)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.reltar x_1  ON x_1.periodo = cvp.moverperiodos(p.periodo, -1) AND x_1.panel = p.panel and x_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad
        HAVING string_agg(COALESCE(z.escierredefinitivoinf,'N'),'') like '%N%' AND string_agg(COALESCE(z.escierredefinitivofor,'N'),'') like'%N%'
        ORDER BY p.periodo, p.panel, t.tarea;
  --11/08/2020: tareas nuevas (agregadas a pantar)
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador)
      SELECT pperiodo as periodo, t.panel, t.tarea, a.encuestador
        FROM cvp.pantar t   
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          LEFT JOIN cvp.reltar x ON x.periodo= pperiodo AND x.panel=t.panel AND x.tarea= t.tarea --pk verificada
        WHERE t.panel= ppanel AND a.activa = 'S' --tareas activas
		      AND t.activa = 'S' --paneles-tarea activas
              AND x.periodo IS NULL
        ORDER BY t.panel, t.tarea;

  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT p.periodo, r_1.informante, 1, r_1.formulario, r_1.panel, r_1.tarea, pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.relvis r_1 INNER JOIN cvp.periodos p ON r_1.periodo=p.periodoanterior
        INNER JOIN cvp.formularios f ON f.formulario=r_1.formulario
        --INNER JOIN cvp.tareas t ON t.tarea=r_1.tarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=r_1.panel and e.tarea=r_1.tarea
        LEFT JOIN (SELECT periodo, informante, formulario, max(visita) AS maxvisita
                     FROM cvp.relvis
                     WHERE panel = pPanel
                     GROUP BY  periodo, informante, formulario) v ON v.periodo=r_1.periodo and v.informante = r_1.informante and v.formulario = r_1.formulario
        LEFT JOIN cvp.razones z ON r_1.razon = z.razon         
        LEFT JOIN cvp.relvis r ON r.periodo=p.periodo AND r.informante=r_1.informante AND r.visita=1 AND r.formulario=r_1.formulario 
      WHERE p.periodo=pPeriodo
        AND r_1.panel=pPanel
        AND r_1.visita=maxvisita
        AND COALESCE(z.escierredefinitivoinf,'N')='N'
        AND COALESCE(z.escierredefinitivofor,'N')='N'
        AND f.activo='S'
        AND r.periodo IS NULL;
  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT i.altaManualPeriodo, i.informante, 1, fi.formulario, i.altaManualPanel, i.altaManualTarea, 
           pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.informantes i 
        INNER JOIN cvp.forinf fi ON i.informante=fi.informante 
        INNER JOIN cvp.formularios f ON f.formulario=fi.formulario
        INNER JOIN cvp.periodos p ON p.periodo=i.altaManualPeriodo
        --INNER JOIN cvp.tareas t ON t.tarea=i.altaManualTarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=i.altaManualPanel and e.tarea=i.altaManualTarea
        LEFT JOIN cvp.relvis r ON r.periodo=i.altaManualPeriodo AND r.informante=i.informante AND r.visita=1 AND r.formulario=fi.formulario 
      WHERE p.periodo=pPeriodo
        AND r.periodo IS NULL
        AND f.activo='S'
        AND fi.altaManualPeriodo=pPeriodo
        AND i.altaManualPeriodo=pPeriodo
        AND i.altaManualPanel=pPanel;
		
  INSERT INTO cvp.relinf(periodo, informante, visita)
    SELECT DISTINCT v.periodo, v.informante, v.visita
      FROM cvp.relvis v
      LEFT JOIN cvp.relinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

  RETURN NULL;
END
$BODY$;
