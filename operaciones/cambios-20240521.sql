set search_path = cvp;
-- Table: cvp.calles

-- DROP TABLE IF EXISTS cvp.calles;

CREATE TABLE IF NOT EXISTS cvp.calles
(
    calle integer NOT NULL,
    nombrecalle text NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    CONSTRAINT calles_pkey PRIMARY KEY (calle),
    CONSTRAINT "texto invalido en nombrecalle de tabla calles" CHECK (comun.cadena_valida(nombrecalle, 'castellano'::text))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS cvp.calles
    OWNER to cvpowner;

GRANT INSERT, DELETE, UPDATE ON TABLE cvp.calles TO cvp_administrador;

GRANT SELECT ON TABLE cvp.calles TO cvp_usuarios;

GRANT ALL ON TABLE cvp.calles TO cvpowner;

CREATE TRIGGER calles_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.calles
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();

-- FUNCTION: cvp.hisc_calles_trg()

-- DROP FUNCTION IF EXISTS cvp.hisc_calles_trg();

CREATE OR REPLACE FUNCTION cvp.hisc_calles_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','calles','calle','I',new.calle,new.calle,'I:'||comun.a_texto(new.calle),new.calle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
                     VALUES ('cvp','calles','nombrecalle','I',new.calle,new.calle,'I:'||comun.a_texto(new.nombrecalle),new.nombrecalle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','calles','modi_usu','I',new.calle,new.calle,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_datetime)
                     VALUES ('cvp','calles','modi_fec','I',new.calle,new.calle,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','calles','modi_ope','I',new.calle,new.calle,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                
      END IF;
      IF v_operacion='U' THEN
            
            IF new.calle IS DISTINCT FROM old.calle THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','calles','calle','U',new.calle,new.calle,comun.A_TEXTO(old.calle)||'->'||comun.a_texto(new.calle),old.calle,new.calle);
            END IF;    
            IF new.nombrecalle IS DISTINCT FROM old.nombrecalle THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                     VALUES ('cvp','calles','nombrecalle','U',new.calle,new.calle,comun.A_TEXTO(old.nombrecalle)||'->'||comun.a_texto(new.nombrecalle),old.nombrecalle,new.nombrecalle);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','calles','modi_usu','U',new.calle,new.calle,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','calles','modi_fec','U',new.calle,new.calle,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','calles','modi_ope','U',new.calle,new.calle,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;          
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','calles','calle','D',old.calle,old.calle,'D:'||comun.a_texto(old.calle),old.calle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
                     VALUES ('cvp','calles','nombrecalle','D',old.nombrecalle,old.nombrecalle,'D:'||comun.a_texto(old.nombrecalle),old.nombrecalle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','calles','modi_usu','D',old.calle,old.calle,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime)
                     VALUES ('cvp','calles','modi_fec','D',old.calle,old.calle,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','calles','modi_ope','D',old.calle,old.calle,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     
$BODY$;

-- Trigger: hisc_trg

-- DROP TRIGGER IF EXISTS hisc_trg ON cvp.calles;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.calles
    FOR EACH ROW
    EXECUTE FUNCTION cvp.hisc_calles_trg();

ALTER FUNCTION cvp.hisc_calles_trg()
    OWNER TO cvpowner;