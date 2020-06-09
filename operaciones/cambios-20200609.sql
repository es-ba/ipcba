set search_path = cvp;

ALTER TABLE reltar ADD COLUMN fechasalidadesde date;
ALTER TABLE reltar ADD COLUMN fechasalidahasta date;

ALTER TABLE his.reltar ADD COLUMN fechasalidadesde date;
ALTER TABLE his.reltar ADD COLUMN fechasalidahasta date;

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
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;

