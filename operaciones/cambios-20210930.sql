set search_path = cvp;
ALTER TABLE reltar ADD COLUMN modalidad text;
ALTER TABLE his.reltar ADD COLUMN modalidad text;

CREATE OR REPLACE FUNCTION hisc_reltar_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','periodo','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||new.periodo,new.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','RelTar','panel','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.panel),new.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','RelTar','tarea','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.tarea),new.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','supervisor','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.supervisor),new.supervisor);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','encuestador','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.encuestador),new.encuestador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','realizada','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.realizada),new.realizada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','resultado','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.resultado),new.resultado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','observaciones','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.observaciones),new.observaciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','RelTar','puntos','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.puntos),new.puntos);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','modi_usu','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','modi_fec','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','modi_ope','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','cargado','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.cargado),new.cargado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.vencimiento_sincronizacion),new.vencimiento_sincronizacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','descargado','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.descargado),new.descargado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','id_instalacion','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.id_instalacion),new.id_instalacion);

                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion2','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.vencimiento_sincronizacion2),new.vencimiento_sincronizacion2);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','archivo_manifiesto','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.archivo_manifiesto),new.archivo_manifiesto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','archivo_estructura','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.archivo_estructura),new.archivo_estructura);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','archivo_hdr','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.archivo_hdr),new.archivo_hdr);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','fechasalidadesde','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.fechasalidadesde),new.fechasalidadesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','RelTar','fechasalidahasta','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.fechasalidahasta),new.fechasalidahasta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','RelTar','modalidad','I',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,'I:'||comun.a_texto(new.modalidad),new.modalidad);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.periodo IS DISTINCT FROM old.periodo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','periodo','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
            END IF;    
            IF new.panel IS DISTINCT FROM old.panel THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','RelTar','panel','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.panel)||'->'||comun.a_texto(new.panel),old.panel,new.panel);
            END IF;    
            IF new.tarea IS DISTINCT FROM old.tarea THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','RelTar','tarea','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.tarea)||'->'||comun.a_texto(new.tarea),old.tarea,new.tarea);
            END IF;    
            IF new.supervisor IS DISTINCT FROM old.supervisor THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','supervisor','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.supervisor)||'->'||comun.a_texto(new.supervisor),old.supervisor,new.supervisor);
            END IF;    
            IF new.encuestador IS DISTINCT FROM old.encuestador THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','encuestador','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.encuestador)||'->'||comun.a_texto(new.encuestador),old.encuestador,new.encuestador);
            END IF;    
            
            IF new.realizada IS DISTINCT FROM old.realizada THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','realizada','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.realizada)||'->'||comun.a_texto(new.realizada),old.realizada,new.realizada);
            END IF;    
            IF new.resultado IS DISTINCT FROM old.resultado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','resultado','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.resultado||'->'||new.resultado
                     ,old.resultado,new.resultado);
            END IF;    
            IF new.observaciones IS DISTINCT FROM old.observaciones THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','observaciones','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.observaciones||'->'||new.observaciones,old.observaciones,new.observaciones);
            END IF;    
            IF new.puntos IS DISTINCT FROM old.puntos THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','RelTar','puntos','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.puntos)||'->'||comun.a_texto(new.puntos),old.puntos,new.puntos);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','modi_usu','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','modi_fec','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','modi_ope','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;
            IF new.cargado IS DISTINCT FROM old.cargado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','cargado','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.cargado)||'->'||comun.a_texto(new.cargado),old.cargado,new.cargado);
            END IF;    
            IF new.vencimiento_sincronizacion IS DISTINCT FROM old.vencimiento_sincronizacion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.vencimiento_sincronizacion)||'->'||comun.a_texto(new.vencimiento_sincronizacion),old.vencimiento_sincronizacion,new.vencimiento_sincronizacion);
            END IF;    
            IF new.descargado IS DISTINCT FROM old.descargado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','descargado','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.descargado)||'->'||comun.a_texto(new.descargado),old.descargado,new.descargado);
            END IF;    
            IF new.id_instalacion IS DISTINCT FROM old.id_instalacion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','id_instalacion','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.id_instalacion||'->'||new.id_instalacion,old.id_instalacion,new.id_instalacion);
            END IF;
                
            IF new.vencimiento_sincronizacion2 IS DISTINCT FROM old.vencimiento_sincronizacion2 THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion2','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.vencimiento_sincronizacion2)||'->'||comun.a_texto(new.vencimiento_sincronizacion2),old.vencimiento_sincronizacion2,new.vencimiento_sincronizacion2);
            END IF;          
            IF new.archivo_manifiesto IS DISTINCT FROM old.archivo_manifiesto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','archivo_manifiesto','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.archivo_manifiesto||'->'||new.archivo_manifiesto
                     ,old.archivo_manifiesto,new.archivo_manifiesto);
            END IF;    
            IF new.archivo_estructura IS DISTINCT FROM old.archivo_estructura THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','archivo_estructura','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.archivo_estructura||'->'||new.archivo_estructura
                     ,old.archivo_estructura,new.archivo_estructura);
            END IF;    
            IF new.archivo_hdr IS DISTINCT FROM old.archivo_hdr THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','archivo_hdr','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.archivo_hdr||'->'||new.archivo_hdr
                     ,old.archivo_hdr,new.archivo_hdr);
            END IF;    
            IF new.fechasalidadesde IS DISTINCT FROM old.fechasalidadesde THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','fechasalidadesde','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.fechasalidadesde)||'->'||comun.a_texto(new.fechasalidadesde),old.fechasalidadesde,new.fechasalidadesde);
            END IF;    
            IF new.fechasalidahasta IS DISTINCT FROM old.fechasalidahasta THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','RelTar','fechasalidahasta','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,comun.A_TEXTO(old.fechasalidahasta)||'->'||comun.a_texto(new.fechasalidahasta),old.fechasalidahasta,new.fechasalidahasta);
            END IF;    
            IF new.modalidad IS DISTINCT FROM old.modalidad THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','RelTar','modalidad','U',new.periodo||'|'||new.panel||'|'||new.tarea,new.periodo,new.panel,new.tarea,old.modalidad||'->'||new.modalidad
                     ,old.modalidad,new.modalidad);
            END IF;    
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','periodo','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.periodo),old.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
                     VALUES ('cvp','RelTar','panel','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.panel),old.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
                     VALUES ('cvp','RelTar','tarea','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.tarea),old.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','supervisor','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.supervisor),old.supervisor);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','encuestador','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.encuestador),old.encuestador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','realizada','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||old.realizada,old.realizada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','resultado','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.resultado),old.resultado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','observaciones','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||old.observaciones,old.observaciones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','puntos','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||old.puntos,old.puntos);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','modi_usu','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','modi_fec','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','modi_ope','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','cargado','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.cargado),old.cargado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.vencimiento_sincronizacion),old.vencimiento_sincronizacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','descargado','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.descargado),old.descargado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','id_instalacion','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||old.id_instalacion,old.id_instalacion);

                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','vencimiento_sincronizacion2','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.vencimiento_sincronizacion2),old.vencimiento_sincronizacion2);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','archivo_manifiesto','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.archivo_manifiesto),old.archivo_manifiesto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','archivo_estructura','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.archivo_estructura),old.archivo_estructura);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','archivo_hdr','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.archivo_hdr),old.archivo_hdr);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','fechasalidadesde','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.fechasalidadesde),old.fechasalidadesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','RelTar','fechasalidahasta','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.fechasalidahasta),old.fechasalidahasta);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','RelTar','modalidad','D',old.periodo||'|'||old.panel||'|'||old.tarea,old.periodo,old.panel,old.tarea,'D:'||comun.a_texto(old.modalidad),old.modalidad);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;

UPDATE reltar t set modalidad = q.modalidad 
from (select per.periodo, p.panel, p.tarea, p.modalidad 
       from pantar p 
       join reltar r on p.panel = r.panel and p.tarea = r.tarea
	   left join (select min(periodo) periodo from periodos where ingresando = 'S') per on true) q
where t.panel = q.panel and t.tarea = q.tarea and t.periodo = q.periodo;	   

UPDATE reltar t set modalidad = q.modalidad 
from (select per.periodo, p.panel, p.tarea, p.modalidad 
       from pantar p 
       join reltar r on p.panel = r.panel and p.tarea = r.tarea
	   left join (select max(periodo) periodo from periodos where ingresando = 'S') per on true) q
where t.panel = q.panel and t.tarea = q.tarea and t.periodo = q.periodo;

DROP VIEW hdrexportar;
DROP VIEW hdrexportarteorica;
ALTER TABLE pantar drop column modalidad;

CREATE OR REPLACE FUNCTION hisc_pantar_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','pantar','panel','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.panel),new.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','pantar','tarea','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.tarea),new.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','pantar','grupozonal','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.grupozonal),new.grupozonal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','pantar','panel2009','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.panel2009),new.panel2009);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','pantar','tamannosupervision','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.tamannosupervision),new.tamannosupervision);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','pantar','activa','I',new.panel||'|'||new.tarea,new.panel,new.tarea,'I:'||comun.a_texto(new.activa),new.activa);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.panel IS DISTINCT FROM old.panel THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','pantar','panel','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.panel)||'->'||comun.a_texto(new.panel),old.panel,new.panel);
            END IF;    
            IF new.tarea IS DISTINCT FROM old.tarea THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','pantar','tarea','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.tarea)||'->'||comun.a_texto(new.tarea),old.tarea,new.tarea);
            END IF;    
            IF new.grupozonal IS DISTINCT FROM old.grupozonal THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','pantar','grupozonal','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.grupozonal)||'->'||comun.a_texto(new.grupozonal),old.grupozonal,new.grupozonal);
            END IF;    
            IF new.panel2009 IS DISTINCT FROM old.panel2009 THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','pantar','panel2009','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.panel2009)||'->'||comun.a_texto(new.panel2009),old.panel2009,new.panel2009);
            END IF;
            IF new.tamannosupervision IS DISTINCT FROM old.tamannosupervision THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','pantar','tamannosupervision','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.tamannosupervision)||'->'||comun.a_texto(new.tamannosupervision),old.tamannosupervision,new.tamannosupervision);
            END IF;
            IF new.activa IS DISTINCT FROM old.activa THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','pantar','activa','U',new.panel||'|'||new.tarea,new.panel,new.tarea,comun.A_TEXTO(old.activa)||'->'||comun.a_texto(new.activa),old.activa,new.activa);
            END IF;    
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','pantar','panel','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.panel),old.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','pantar','tarea','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.tarea),old.tarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','pantar','grupozonal','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.grupozonal),old.grupozonal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','pantar','panel2009','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.panel2009),old.panel2009);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','pantar','tamannosupervision','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.tamannosupervision),old.tamannosupervision);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','pantar','activa','D',old.panel||'|'||old.tarea,old.panel,old.tarea,'D:'||comun.a_texto(old.activa),old.activa);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
$BODY$;

CREATE OR REPLACE FUNCTION cvp.generar_panel(
	pperiodo text,
	ppanel integer,
	pfechasalida date,
	pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
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

  --Si se modifica el encuestador de una tarea, hay que volver a generar el panel que aún no haya salido,
  --se cambiarán los encuestadores de los paneles siguientes para las tareas correspondientes
  UPDATE cvp.reltar r SET encuestador= s.encuestador
        FROM (SELECT p.periodo, p.panel, t.tarea, a.encuestador 
                FROM cvp.relpan p 
                  INNER JOIN cvp.pantar t ON p.panel= t.panel  
                  INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
                  LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
                  WHERE p.periodo=pperiodo AND p.panel= ppanel AND p.fechasalida > f_hoy AND a.activa = 'S' AND   --tareas activas
                        x.periodo IS NOT NULL
              ) as s
        WHERE r.periodo=s.periodo AND r.panel= s.panel and r.tarea=s.tarea AND s.encuestador IS DISTINCT FROM r.encuestador ;

  RETURN NULL;
END
$BODY$;

CREATE OR REPLACE VIEW hdrexportar AS 
 SELECT c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante as ti, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista,
   c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor,
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon, 
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|'::text) AS formularios, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
    c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, 
    a.maxperiodoinformado, a.minperiodoinformado, a.periodoalta, pta.modalidad
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
      LEFT JOIN cvp.reltar pta on c.periodo = pta.periodo and c.panel = pta.panel and c.tarea = pta.tarea
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, 
    c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, 
    a.minperiodoinformado, a.periodoalta, pta.modalidad;

GRANT SELECT ON TABLE hdrexportar TO cvp_usuarios;

CREATE OR REPLACE VIEW hdrexportarteorica AS 
 SELECT c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante as ti, t.encuestador||':'||p.nombre||' '||p.apellido as encuestador,
   COALESCE(string_agg(distinct c.encuestador||':'||c.nombreencuestador, '|'::text),null) as encuestadores, 
   COALESCE(string_agg(distinct c.recepcionista||':'||c.nombrerecepcionista, '|'::text),null) as recepcionistas, 
   COALESCE(string_agg(distinct c.ingresador||':'||c.nombreingresador, '|'::text),null) as ingresadores, 
   COALESCE(string_agg(distinct c.supervisor||':'||c.nombresupervisor, '|'::text),null) as supervisores, 
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon,
   string_agg(c.formulario::text || ' '::text || c.nombreformulario::text, chr(10) order by c.formulario) AS formularioshdr,
   lpad(' '::text, count(*)::integer, chr(10)) AS espacio,   
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|') AS formularios, 
   i.contacto::text contacto, 
   c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
   pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.tareas t on c.tarea = t.tarea
   LEFT JOIN cvp.personal p on p.persona = t.encuestador 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
   LEFT JOIN (SELECT informante, visita, string_agg(distinct panel::text,',' order by panel::text) as panelreferencia, string_agg(distinct tarea::text,',' order by tarea::text) as tareareferencia
                FROM cvp.relvis v 
                JOIN cvp.parametros par ON unicoregistro AND v.periodo = par.periodoReferenciaParaPanelTarea
                GROUP BY informante, visita) pt ON c.informante = pt.informante AND c.visita = pt.visita
    LEFT JOIN cvp.reltar pta on c.periodo = pta.periodo and c.panel = pta.panel and c.tarea = pta.tarea  
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    i.contacto, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
    pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad;

GRANT SELECT ON TABLE hdrexportarteorica TO cvp_usuarios;