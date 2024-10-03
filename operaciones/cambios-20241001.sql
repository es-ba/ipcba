set search_path = cvp;
-- Table: cvp.tablas_custom

-- DROP TABLE IF EXISTS cvp.tablas_custom;

CREATE TABLE IF NOT EXISTS cvp.tablas_custom
(
    tabla text NOT NULL,
    exportable boolean default false,
    grilla_pesada boolean default false,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    CONSTRAINT tablas_custom_pkey PRIMARY KEY (tabla)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS cvp.tablas_custom
    OWNER to cvpowner;

GRANT INSERT, DELETE, UPDATE ON TABLE cvp.tablas_custom TO cvp_administrador;

GRANT SELECT ON TABLE cvp.tablas_custom TO cvp_usuarios;

GRANT ALL ON TABLE cvp.tablas_custom TO cvpowner;

CREATE TRIGGER tablas_custom_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.tablas_custom
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();

-- FUNCTION: cvp.hisc_tablas_custom_trg()

-- DROP FUNCTION IF EXISTS cvp.hisc_tablas_custom_trg();

CREATE OR REPLACE FUNCTION cvp.hisc_tablas_custom_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','tablas_custom','tabla','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.tabla),new.tabla);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_bool)
                     VALUES ('cvp','tablas_custom','exportable','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.exportable),new.exportable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_bool)
                     VALUES ('cvp','tablas_custom','grilla_pesada','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.grilla_pesada),new.grilla_pesada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','tablas_custom','modi_usu','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_datetime)
                     VALUES ('cvp','tablas_custom','modi_fec','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','tablas_custom','modi_ope','I',new.tabla,new.tabla,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                
      END IF;
      IF v_operacion='U' THEN
            
            IF new.tabla IS DISTINCT FROM old.tabla THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','tablas_custom','tabla','U',new.tabla,new.tabla,comun.A_TEXTO(old.tabla)||'->'||comun.a_texto(new.tabla),old.tabla,new.tabla);
            END IF;    
            IF new.exportable IS DISTINCT FROM old.exportable THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','tablas_custom','exportable','U',new.tabla,new.tabla,comun.A_TEXTO(old.exportable)||'->'||comun.a_texto(new.exportable),old.exportable,new.exportable);
            END IF;    
            IF new.grilla_pesada IS DISTINCT FROM old.grilla_pesada THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','tablas_custom','grilla_pesada','U',new.tabla,new.tabla,comun.A_TEXTO(old.grilla_pesada)||'->'||comun.a_texto(new.grilla_pesada),old.grilla_pesada,new.grilla_pesada);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','tablas_custom','modi_usu','U',new.tabla,new.tabla,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','tablas_custom','modi_fec','U',new.tabla,new.tabla,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','tablas_custom','modi_ope','U',new.tabla,new.tabla,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;          
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','tablas_custom','tabla','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.tabla),old.tabla);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool)
                     VALUES ('cvp','tablas_custom','exportable','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.exportable),old.exportable);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_bool)
                     VALUES ('cvp','tablas_custom','grilla_pesada','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.grilla_pesada),old.grilla_pesada);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','tablas_custom','modi_usu','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_datetime)
                     VALUES ('cvp','tablas_custom','modi_fec','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','tablas_custom','modi_ope','D',old.tabla,old.tabla,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     
$BODY$;

-- Trigger: hisc_trg

-- DROP TRIGGER IF EXISTS hisc_trg ON cvp.tablas_custom;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.tablas_custom
    FOR EACH ROW
    EXECUTE FUNCTION cvp.hisc_tablas_custom_trg();

ALTER FUNCTION cvp.hisc_tablas_custom_trg()
    OWNER TO cvpowner;