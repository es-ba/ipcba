SET SEARCH_PATH = cvp;

ALTER TABLE licencias ADD COLUMN modi_usu character varying(30);
ALTER TABLE licencias ADD COLUMN modi_fec timestamp without time zone;
ALTER TABLE licencias ADD COLUMN modi_ope character varying(1);

CREATE OR REPLACE TRIGGER licencias_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.licencias
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();

CREATE OR REPLACE FUNCTION cvp.hisc_licencias_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
   DECLARE
     v_operacion text:=substr(TG_OP,1,1);
   BEGIN
        
      IF v_operacion='I' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','persona','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.persona),new.persona);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','fechadesde','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.fechadesde),new.fechadesde);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','fechahasta','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.fechahasta),new.fechahasta);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','motivo','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.motivo),new.motivo);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','modi_usu','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_datetime)
               VALUES ('cvp','licencias','modi_fec','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','modi_ope','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
      END IF;
      IF v_operacion='U' THEN
          IF new.persona IS DISTINCT FROM old.persona THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','persona','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.persona)||'->'||comun.a_texto(new.persona),old.persona,new.persona);
          END IF;
          IF new.fechadesde IS DISTINCT FROM old.fechadesde THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','fechadesde','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.fechadesde)||'->'||comun.a_texto(new.fechadesde),old.fechadesde,new.fechadesde);
          END IF;
          IF new.fechahasta IS DISTINCT FROM old.fechahasta THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','fechahasta','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.fechahasta)||'->'||comun.a_texto(new.fechahasta),old.fechahasta,new.fechahasta);
          END IF;
          IF new.motivo IS DISTINCT FROM old.motivo THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','motivo','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.motivo)||'->'||comun.a_texto(new.motivo),old.motivo,new.motivo);
          END IF;
          IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','modi_usu','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
          END IF;    
          IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_datetime)
                   VALUES ('cvp','licencias','modi_fec','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
          END IF;    
          IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','modi_ope','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
          END IF;    
      END IF;
      IF v_operacion='D' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','persona','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.persona),old.persona);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','fechadesde','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.fechadesde),old.fechadesde);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','fechahasta','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.fechahasta),old.fechahasta);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','motivo','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.motivo),old.motivo);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','modi_usu','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_datetime)
               VALUES ('cvp','licencias','modi_fec','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','modi_ope','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;  
      END IF;
   END;
$BODY$;

ALTER FUNCTION cvp.hisc_licencias_trg()
    OWNER TO cvpowner;
