set search_path =cvp;
set role cvpowner;

CREATE TABLE relpantarinf
(
    periodo character varying(11) COLLATE pg_catalog."default" NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    observaciones text COLLATE pg_catalog."default",
    modi_usu character varying(30) COLLATE pg_catalog."default",
    modi_fec timestamp without time zone,
    modi_ope character varying(1) COLLATE pg_catalog."default",
    fechasalidadesde date,
    fechasalidahasta date,
    observaciones_campo text COLLATE pg_catalog."default",
    codobservaciones text COLLATE pg_catalog."default",
    recuperos text COLLATE pg_catalog."default",
    PRIMARY KEY (periodo, informante, visita, panel, tarea),
    FOREIGN KEY (informante) REFERENCES cvp.informantes (informante),
    FOREIGN KEY (periodo) REFERENCES cvp.periodos (periodo)
)
TABLESPACE pg_default;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE relpantarinf TO cvp_administrador;

GRANT UPDATE, SELECT, DELETE, INSERT ON TABLE relpantarinf TO cvp_recepcionista;

CREATE TABLE his.relpantarinf AS 
SELECT hr.nue_usu, hr.nue_ope, r.* FROM his.relinf hr join relpantarinf r 
on hr.periodo = r.periodo and hr.informante = r.informante and r.visita = hr.visita 
WHERE FALSE;

GRANT SELECT ON TABLE his.relpantarinf TO cvp_administrador;

CREATE OR REPLACE FUNCTION hisc_relpantarinf_trg()
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
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;
------------------------------------------------------------------------------------------
CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON relpantarinf
    FOR EACH ROW
    EXECUTE FUNCTION hisc_relpantarinf_trg();
------------------------------------------------------------------------------------------
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
   V230705
      genera filas para relpantarinf
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
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador, modalidad, visiblepararelevamiento)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.reltar x_1  ON x_1.periodo = cvp.moverperiodos(p.periodo, -1) AND x_1.panel = p.panel and x_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
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

  INSERT INTO cvp.relpantarinf(periodo, informante, visita, panel, tarea)
    SELECT DISTINCT v.periodo, v.informante, v.visita, v.panel, v.tarea
      FROM cvp.relvis v
      LEFT JOIN cvp.relpantarinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita and v.panel = i.panel and v.tarea = i.tarea 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

  RETURN NULL;
END
$BODY$;
------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION modi_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  -- V090122
  vOpe VARCHAR(1);
  vUsuario VARCHAR(30);
BEGIN
  vUsuario:=SESSION_USER;
  if TG_OP='DELETE' then
    vOpe:='D';
  elsif TG_OP='INSERT' then
    vOpe:='I';
  elsif TG_OP='UPDATE' then
    vOpe:='U';
  else
    RAISE EXCEPTION 'operacion desconocida';
  end if;

  if 'con historico'='sin historico' then
    execute 'insert into ' || tg_table_schema || '.his_' || tg_table_name || 
      ' select *, ''' || user || ''', ''' || vOpe || ''' ' || 
      ' from ' || tg_table_schema || '.' || tg_table_name || 
      ' where ctid=' || old.ctid || '::tid'; 
  end if;

  if TG_OP<>'INSERT' then
    if tg_table_name='relpan' then
      INSERT INTO his.relpan SELECT vUsuario,vOpe,* FROM cvp.relpan WHERE periodo=OLD.periodo AND panel=old.panel;
    elsif tg_table_name='relvis' then
      INSERT INTO his.relvis SELECT vUsuario,vOpe,* FROM cvp.relvis WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita AND formulario=OLD.formulario;
    elsif tg_table_name='relpre' then
      INSERT INTO his.relpre SELECT vUsuario,vOpe,* FROM cvp.relpre WHERE periodo=OLD.periodo AND producto=OLD.producto AND observacion=OLD.observacion AND informante=OLD.informante AND visita=OLD.visita;
    elsif tg_table_name='relatr' then
      INSERT INTO his.relatr SELECT vUsuario,vOpe,* FROM cvp.relatr WHERE periodo=OLD.periodo AND producto=OLD.producto AND observacion=OLD.observacion AND informante=OLD.informante AND visita=OLD.visita and atributo=OLD.atributo;
    elsif tg_table_name='novobs' then
      INSERT INTO his.novObs SELECT vUsuario,vOpe,* FROM cvp.novObs WHERE periodo=OLD.periodo AND calculo=OLD.calculo AND producto=OLD.producto AND informante=OLD.informante AND observacion=OLD.observacion;
    elsif tg_table_name='novprod' then
      INSERT INTO his.novProd SELECT vUsuario,vOpe,* FROM cvp.novProd WHERE periodo=OLD.periodo AND calculo=OLD.calculo AND producto=OLD.producto ;
    elsif tg_table_name='novpre' then
      INSERT INTO his.novPre SELECT vUsuario,vOpe,* FROM cvp.novPre WHERE periodo=OLD.periodo AND producto=OLD.producto AND informante=OLD.informante AND observacion=OLD.observacion AND visita=OLD.visita;
    elsif tg_table_name='relsup' then
      INSERT INTO his.relsup SELECT vUsuario,vOpe,* FROM cvp.relsup WHERE periodo=OLD.periodo AND panel=old.panel AND supervisor=old.supervisor;  
    elsif tg_table_name='reltar' then
      INSERT INTO his.reltar SELECT vUsuario,vOpe,* FROM cvp.reltar WHERE periodo=OLD.periodo AND panel=old.panel AND tarea=old.tarea;
    elsif tg_table_name='relmon' then
      INSERT INTO his.relmon SELECT vUsuario,vOpe,* FROM cvp.relmon WHERE periodo=OLD.periodo AND moneda=OLD.moneda; 
    elsif tg_table_name='relenc' then
      INSERT INTO his.relenc SELECT vUsuario,vOpe,* FROM cvp.relenc WHERE periodo=OLD.periodo AND panel=OLD.panel AND tarea=OLD.tarea; 
    elsif tg_table_name='prerep' then
      INSERT INTO his.prerep SELECT vUsuario,vOpe,* FROM cvp.prerep WHERE periodo=OLD.periodo AND producto=OLD.producto AND informante=OLD.informante; 
    elsif tg_table_name='relinf' then
      INSERT INTO his.relinf SELECT vUsuario,vOpe,periodo, informante, visita, observaciones, modi_usu, modi_fec, modi_ope, null as panel, null as tarea, fechasalidadesde, fechasalidahasta FROM cvp.relinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita;
    elsif tg_table_name='relpantarinf' then
      INSERT INTO his.relpantarinf SELECT vUsuario,vOpe,* FROM cvp.relpantarinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita and panel=OLD.panel and tarea=OLD.tarea;
    --else
      --RAISE EXCEPTION 'Auditoria de tabla % no contemplada', tg_table_name ;
    end if;
  end if;
 
  if TG_OP='DELETE' then
    RETURN OLD;
  else
    NEW.modi_usu:=vUsuario;
    NEW.modi_fec:=CURRENT_TIMESTAMP(3);
    NEW.modi_ope:=vOpe;
    RETURN NEW;
  end if;
END;
$BODY$;

CREATE TRIGGER relpantarinf_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relpantarinf
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();

INSERT INTO relpantarinf 
(periodo, informante, visita, panel, tarea, observaciones, fechasalidadesde, fechasalidahasta, observaciones_campo, codobservaciones, recuperos)
SELECT DISTINCT r.periodo, r.informante, r.visita, v.panel, v.tarea, r.observaciones, r.fechasalidadesde, r.fechasalidahasta, r.observaciones_campo, r.codobservaciones, r.recuperos
FROM relinf r 
     JOIN relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita
     JOIN (SELECT * FROM periodos ORDER BY periodo desc limit 2) p on r.periodo = p.periodo ;

----------------------------------------------------------------------------
CREATE TRIGGER relpantarinf_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relpantarinf
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();
-----------------------------------------------------------------------------
CREATE OR REPLACE VIEW control_hojas_ruta AS
SELECT v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, 
    v.encuestador, COALESCE(p.apellido, null)::text AS nombreencuestador,
    v.recepcionista, COALESCE(s.apellido, null)::text AS nombrerecepcionista, 
    v.ingresador, COALESCE(n.apellido, null)::text AS nombreingresador,
    v.supervisor, COALESCE(r.apellido, null)::text AS nombresupervisor, 
    v.formulario, f.nombreformulario, f.operativo, v.razon, r_1.razon as razonanterior, v.visita, i.nombreinformante, i.direccion, 
    i.conjuntomuestral, i.ordenhdr, ri.observaciones, ri.observaciones_campo, ri.fechasalidahasta, rt.modalidad, rt_1.modalidad modalidad_ant,
    i.telcontacto, i.web, i.email, ri.codobservaciones
   FROM cvp.relvis v
   JOIN cvp.informantes i ON v.informante = i.informante
   JOIN cvp.formularios f ON v.formulario = f.formulario
   LEFT JOIN cvp.relpantarinf ri ON v.periodo = ri.periodo AND v.informante = ri.informante AND v.visita = ri.visita and v.panel = ri.panel and v.tarea = ri.tarea
   LEFT JOIN cvp.reltar rt ON v.periodo = rt.periodo AND v.panel = rt.panel AND v.tarea = rt.tarea
   LEFT JOIN cvp.personal p ON v.encuestador = p.persona
   LEFT JOIN cvp.personal s ON v.recepcionista = s.persona
   LEFT JOIN cvp.personal n ON v.ingresador = n.persona
   LEFT JOIN cvp.personal r ON v.supervisor = r.persona
   LEFT JOIN cvp.periodos o ON v.periodo = o.periodo
   LEFT JOIN cvp.relvis r_1 ON r_1.periodo=
        CASE
          WHEN v.visita > 1 THEN v.periodo
          ELSE o.periodoanterior
        END AND (r_1.ultima_visita = true AND v.visita = 1 OR v.visita > 1 AND r_1.visita = (v.visita - 1)) 
        AND r_1.informante = v.informante AND r_1.formulario = v.formulario
   LEFT JOIN cvp.reltar rt_1 ON r_1.periodo = rt_1.periodo AND r_1.panel = rt_1.panel AND r_1.tarea = rt_1.tarea
   order by v.periodo, v.panel, v.tarea, v.informante, v.formulario;
-----------------------------------------------------------------------------------
CREATE OR REPLACE view control_sinvariacion AS
SELECT periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, 
recepcionista, precionormalizado, SUM(cantprecio) as cantprecios, tipoprecio, comentariosrelpre, formulario, direccion, telcontacto, web, modalidad
FROM (SELECT p.periodo, p.informante, i.nombreinformante, i.tipoinformante, p.producto, prod.nombreproducto, p.visita, p.observacion, 
        v.panel, v.tarea, v.recepcionista, p.precionormalizado, pant.periodo as periodo_ant,
        CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado END AS precioparacontar, 
        CASE WHEN pant.precionormalizado = (CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado end)
                  and pant.periodo <= p.periodo
        THEN 1 ELSE 0 END AS cantprecio, p.tipoprecio, p.comentariosrelpre, p.formulario, i.direccion, i.telcontacto, i.web, t.modalidad
      FROM cvp.relpre p
      JOIN cvp.relvis v ON p.periodo = v.periodo AND p.informante = v.informante AND p.visita = v.visita AND p.formulario = v.formulario
      JOIN cvp.reltar t ON p.periodo = t.periodo AND v.panel = t.panel AND v.tarea = t.tarea
      JOIN (SELECT periodo, cvp.moverperiodos(periodo, -3) as perreferencia
         FROM cvp.periodos 
         WHERE ingresando = 'S' OR periodo = (SELECT MAX(periodo) FROM cvp.periodos WHERE ingresando = 'N')) per ON p.periodo = per.periodo
      JOIN cvp.relpre pant ON p.informante =pant.informante AND p.producto = pant.producto AND p.visita = pant.visita AND p.observacion = pant.observacion
                      AND (p.precionormalizado = pant.precionormalizado OR pant.precionormalizado is null OR
                      (pant.precionormalizado <> p.precionormalizado AND pant.periodo between per.perreferencia AND p.periodo))
      JOIN cvp.informantes i ON p.informante = i.informante
      JOIN cvp.productos prod ON p.producto = prod.producto
      WHERE p.precionormalizado is not null) q 
GROUP BY periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre, formulario, direccion, telcontacto, web, modalidad
HAVING MIN(precioparacontar)=MAX(precioparacontar) AND SUM(cantprecio) >= 4
ORDER BY periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre, formulario, direccion, telcontacto, web, modalidad;
