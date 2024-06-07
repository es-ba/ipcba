set search_path = cvp;
-- Table: cvp.provincias

-- DROP TABLE IF EXISTS cvp.provincias;

CREATE TABLE IF NOT EXISTS cvp.provincias
(
    provincia text NOT NULL,
    nombreprovincia text NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    CONSTRAINT provincias_pkey PRIMARY KEY (provincia),
    CONSTRAINT "texto invalido en provincia de tabla provincias" CHECK (comun.cadena_valida(provincia, 'codigo'::text)),
    CONSTRAINT "texto invalido en nombreprovincia de tabla provincias" CHECK (comun.cadena_valida(nombreprovincia, 'castellano'::text))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS cvp.provincias
    OWNER to cvpowner;

GRANT INSERT, DELETE, UPDATE ON TABLE cvp.provincias TO cvp_administrador;

GRANT SELECT ON TABLE cvp.provincias TO cvp_usuarios;

GRANT ALL ON TABLE cvp.provincias TO cvpowner;

CREATE TRIGGER provincias_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.provincias
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();

-- FUNCTION: cvp.hisc_provincias_trg()

-- DROP FUNCTION IF EXISTS cvp.hisc_provincias_trg();

CREATE OR REPLACE FUNCTION cvp.hisc_provincias_trg()
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
                     VALUES ('cvp','provincias','provincia','I',new.provincia,new.provincia,'I:'||comun.a_texto(new.provincia),new.provincia);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','provincias','nombreprovincia','I',new.provincia,new.provincia,'I:'||comun.a_texto(new.nombreprovincia),new.nombreprovincia);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','provincias','modi_usu','I',new.provincia,new.provincia,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_datetime)
                     VALUES ('cvp','provincias','modi_fec','I',new.provincia,new.provincia,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','provincias','modi_ope','I',new.provincia,new.provincia,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                
      END IF;
      IF v_operacion='U' THEN
            
            IF new.provincia IS DISTINCT FROM old.provincia THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','provincias','provincia','U',new.provincia,new.provincia,comun.A_TEXTO(old.provincia)||'->'||comun.a_texto(new.provincia),old.provincia,new.provincia);
            END IF;    
            IF new.nombreprovincia IS DISTINCT FROM old.nombreprovincia THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','provincias','nombreprovincia','U',new.provincia,new.provincia,comun.A_TEXTO(old.nombreprovincia)||'->'||comun.a_texto(new.nombreprovincia),old.nombreprovincia,new.nombreprovincia);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','provincias','modi_usu','U',new.provincia,new.provincia,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','provincias','modi_fec','U',new.provincia,new.provincia,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','provincias','modi_ope','U',new.provincia,new.provincia,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;          
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','provincias','provincia','D',old.provincia,old.provincia,'D:'||comun.a_texto(old.provincia),old.provincia);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','provincias','nombreprovincia','D',old.nombreprovincia,old.nombreprovincia,'D:'||comun.a_texto(old.nombreprovincia),old.nombreprovincia);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','provincias','modi_usu','D',old.provincia,old.provincia,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_datetime)
                     VALUES ('cvp','provincias','modi_fec','D',old.provincia,old.provincia,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','provincias','modi_ope','D',old.provincia,old.provincia,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     
$BODY$;

-- Trigger: hisc_trg

-- DROP TRIGGER IF EXISTS hisc_trg ON cvp.provincias;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.provincias
    FOR EACH ROW
    EXECUTE FUNCTION cvp.hisc_provincias_trg();

ALTER FUNCTION cvp.hisc_provincias_trg()
    OWNER TO cvpowner;