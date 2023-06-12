set search_path = cvp;

alter table relinf add column recuperos text;

ALTER TABLE his.relinf ADD COLUMN recuperos text;

CREATE OR REPLACE FUNCTION cvp.hisc_relinf_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','periodo','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||new.periodo,new.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','informante','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.informante),new.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','visita','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.visita),new.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','observaciones','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.observaciones),new.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_usu','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','modi_fec','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_ope','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','fechasalidadesde','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.fechasalidadesde),new.fechasalidadesde);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','fechasalidahasta','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.fechasalidahasta),new.fechasalidahasta);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','observaciones_campo','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.observaciones_campo),new.observaciones_campo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','codobservaciones','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.codobservaciones),new.codobservaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','recuperos','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.recuperos),new.recuperos);
      END IF;
      IF v_operacion='U' THEN          
        IF new.periodo IS DISTINCT FROM old.periodo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','periodo','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
        END IF;    
        IF new.informante IS DISTINCT FROM old.informante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','informante','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
        END IF;    
        IF new.visita IS DISTINCT FROM old.visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','visita','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
        END IF;    
        IF new.observaciones IS DISTINCT FROM old.observaciones THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','observaciones','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,old.observaciones||'->'||new.observaciones,old.observaciones,new.observaciones);
        END IF;    
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_usu','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','modi_fec','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_ope','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.fechasalidadesde IS DISTINCT FROM old.fechasalidadesde THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','fechasalidadesde','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.fechasalidadesde)||'->'||comun.a_texto(new.fechasalidadesde),old.fechasalidadesde,new.fechasalidadesde);
        END IF;    
        IF new.fechasalidahasta IS DISTINCT FROM old.fechasalidahasta THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','fechasalidahasta','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.fechasalidahasta)||'->'||comun.a_texto(new.fechasalidahasta),old.fechasalidahasta,new.fechasalidahasta);
        END IF;    
        IF new.observaciones_campo IS DISTINCT FROM old.observaciones_campo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','observaciones_campo','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.observaciones_campo)||'->'||comun.a_texto(new.observaciones_campo),old.observaciones_campo,new.observaciones_campo);
        END IF;    
        IF new.codobservaciones IS DISTINCT FROM old.codobservaciones THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','codobservaciones','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.codobservaciones)||'->'||comun.a_texto(new.codobservaciones),old.codobservaciones,new.codobservaciones);
        END IF;    
        IF new.recuperos IS DISTINCT FROM old.recuperos THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','recuperos','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.recuperos)||'->'||comun.a_texto(new.recuperos),old.recuperos,new.recuperos);
        END IF;    
      END IF;
      IF v_operacion='D' THEN        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','periodo','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.periodo),old.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','informante','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.informante),old.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','visita','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.visita),old.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','observaciones','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||old.observaciones,old.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_usu','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','modi_fec','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_ope','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','fechasalidadesde','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.fechasalidadesde),old.fechasalidadesde);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','fechasalidahasta','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.fechasalidahasta),old.fechasalidahasta);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','observaciones_campo','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.observaciones_campo),old.observaciones_campo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','codobservaciones','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.codobservaciones),old.codobservaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','recuperos','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.recuperos),old.recuperos);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     
$BODY$;