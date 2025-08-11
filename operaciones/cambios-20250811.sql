CREATE OR REPLACE FUNCTION cvp.hisc_relpantarinf_trg()
RETURNS trigger
LANGUAGE 'plpgsql'
VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  v_operacion text:=substr(TG_OP,1,1);
BEGIN
  IF v_operacion='I' THEN
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','periodo','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||new.periodo,new.periodo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
      VALUES ('cvp','relpantarinf','informante','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.informante),new.informante);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
      VALUES ('cvp','relpantarinf','visita','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.visita),new.visita);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
      VALUES ('cvp','relpantarinf','panel','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.panel),new.panel);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
      VALUES ('cvp','relpantarinf','tarea','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.tarea),new.tarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','observaciones','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.observaciones),new.observaciones);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','modi_usu','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_datetime)
      VALUES ('cvp','relpantarinf','modi_fec','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','modi_ope','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_datetime)
      VALUES ('cvp','relpantarinf','fechasalidadesde','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.fechasalidadesde),new.fechasalidadesde);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_datetime)
      VALUES ('cvp','relpantarinf','fechasalidahasta','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.fechasalidahasta),new.fechasalidahasta);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','observaciones_campo','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.observaciones_campo),new.observaciones_campo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','codobservaciones','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.codobservaciones),new.codobservaciones);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','recuperos','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.recuperos),new.recuperos);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_datetime)
      VALUES ('cvp','relpantarinf','fecha_backup','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.fecha_backup),new.fecha_backup);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','token_relevamiento_backup','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.token_relevamiento_backup),new.token_relevamiento_backup);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
      VALUES ('cvp','relpantarinf','encuestador_backup','I',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,'I:'||comun.a_texto(new.encuestador_backup),new.encuestador_backup);
  END IF;
  IF v_operacion='U' THEN
    IF new.periodo IS DISTINCT FROM old.periodo THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','periodo','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
    END IF;
    IF new.informante IS DISTINCT FROM old.informante THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
        VALUES ('cvp','relpantarinf','informante','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
    END IF;
    IF new.visita IS DISTINCT FROM old.visita THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
        VALUES ('cvp','relpantarinf','visita','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
    END IF;
    IF new.panel IS DISTINCT FROM old.panel THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
        VALUES ('cvp','relpantarinf','panel','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.panel)||'->'||comun.a_texto(new.panel),old.panel,new.panel);
    END IF;
    IF new.tarea IS DISTINCT FROM old.tarea THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
        VALUES ('cvp','relpantarinf','tarea','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.tarea)||'->'||comun.a_texto(new.tarea),old.tarea,new.tarea);
    END IF;
    IF new.observaciones IS DISTINCT FROM old.observaciones THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','observaciones','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,old.observaciones||'->'||new.observaciones,old.observaciones,new.observaciones);
    END IF;
    IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','modi_usu','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
    END IF;
    IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime,new_datetime)
        VALUES ('cvp','relpantarinf','modi_fec','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
    END IF;
    IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','modi_ope','U',new.periodo||'|'||new.informante||'|'||new.visita'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
    END IF;
    IF new.fechasalidadesde IS DISTINCT FROM old.fechasalidadesde THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime,new_datetime)
        VALUES ('cvp','relpantarinf','fechasalidadesde','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.fechasalidadesde)||'->'||comun.a_texto(new.fechasalidadesde),old.fechasalidadesde,new.fechasalidadesde);
    END IF;
    IF new.fechasalidahasta IS DISTINCT FROM old.fechasalidahasta THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime,new_datetime)
        VALUES ('cvp','relpantarinf','fechasalidahasta','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.fechasalidahasta)||'->'||comun.a_texto(new.fechasalidahasta),old.fechasalidahasta,new.fechasalidahasta);
    END IF;
    IF new.observaciones_campo IS DISTINCT FROM old.observaciones_campo THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','observaciones_campo','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.observaciones_campo)||'->'||comun.a_texto(new.observaciones_campo),old.observaciones_campo,new.observaciones_campo);
    END IF;
    IF new.codobservaciones IS DISTINCT FROM old.codobservaciones THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','codobservaciones','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.codobservaciones)||'->'||comun.a_texto(new.codobservaciones),old.codobservaciones,new.codobservaciones);
    END IF;
    IF new.recuperos IS DISTINCT FROM old.recuperos THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','recuperos','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.recuperos)||'->'||comun.a_texto(new.recuperos),old.recuperos,new.recuperos);
    END IF;
    IF new.fecha_backup IS DISTINCT FROM old.fecha_backup THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime,new_datetime)
        VALUES ('cvp','relpantarinf','fecha_backup','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.fecha_backup)||'->'||comun.a_texto(new.fecha_backup),old.fecha_backup,new.fecha_backup);
    END IF;
    IF new.token_relevamiento_backup IS DISTINCT FROM old.token_relevamiento_backup THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','token_relevamiento_backup','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.token_relevamiento_backup)||'->'||comun.a_texto(new.token_relevamiento_backup),old.token_relevamiento_backup,new.token_relevamiento_backup);
    END IF;
    IF new.encuestador_backup IS DISTINCT FROM old.encuestador_backup THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
        VALUES ('cvp','relpantarinf','encuestador_backup','U',new.periodo||'|'||new.informante||'|'||new.visita||'|'||new.panel||'|'||new.tarea,new.periodo,new.informante,new.visita,new.panel,new.tarea,comun.A_TEXTO(old.encuestador_backup)||'->'||comun.a_texto(new.encuestador_backup),old.encuestador_backup,new.encuestador_backup);
    END IF;
  END IF;
  IF v_operacion='D' THEN
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','periodo','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.periodo),old.periodo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
      VALUES ('cvp','relpantarinf','informante','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.informante),old.informante);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
      VALUES ('cvp','relpantarinf','visita','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.visita),old.visita);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
      VALUES ('cvp','relpantarinf','panel','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.panel),old.panel);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
      VALUES ('cvp','relpantarinf','tarea','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.tarea),old.tarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','observaciones','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.observaciones),old.observaciones);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','modi_usu','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime)
      VALUES ('cvp','relpantarinf','modi_fec','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','modi_ope','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime)
      VALUES ('cvp','relpantarinf','fechasalidadesde','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.fechasalidadesde),old.fechasalidadesde);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime)
      VALUES ('cvp','relpantarinf','fechasalidahasta','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.fechasalidahasta),old.fechasalidahasta);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','observaciones_campo','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.observaciones_campo),old.observaciones_campo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','codobservaciones','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.codobservaciones),old.codobservaciones);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','recuperos','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.recuperos),old.recuperos);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime)
      VALUES ('cvp','relpantarinf','fecha_backup','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.fecha_backup),old.fecha_backup);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','token_relevamiento_backup','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.token_relevamiento_backup),old.token_relevamiento_backup);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
      VALUES ('cvp','relpantarinf','encuestador_backup','D',old.periodo||'|'||old.informante||'|'||old.visita||'|'||old.panel||'|'||old.tarea,old.periodo,old.informante,old.visita,old.panel,old.tarea,'D:'||comun.a_texto(old.encuestador_backup),old.encuestador_backup);
    END IF;

    IF v_operacion<>'D' THEN
      RETURN new;
    ELSE
      RETURN old;
    END IF;
  END;

$BODY$;