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
