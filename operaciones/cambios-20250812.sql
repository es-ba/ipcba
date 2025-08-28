ALTER TABLE cvp.calles ADD COLUMN alturadesde INTEGER;
ALTER TABLE cvp.calles ADD COLUMN alturahasta INTEGER;

CREATE OR REPLACE FUNCTION cvp.hisc_calles_trg()
RETURNS trigger
LANGUAGE 'plpgsql'
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
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
      VALUES ('cvp','calles','alturadesde','I',new.calle,new.calle,'I:'||comun.a_texto(new.alturadesde),new.alturadesde);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
      VALUES ('cvp','calles','alturahasta','I',new.calle,new.calle,'I:'||comun.a_texto(new.alturahasta),new.alturahasta);
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
    IF new.alturadesde IS DISTINCT FROM old.alturadesde THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
        VALUES ('cvp','calles','alturadesde','U',new.calle,new.calle,comun.A_TEXTO(old.alturadesde)||'->'||comun.a_texto(new.alturadesde),old.alturadesde,new.alturadesde);
    END IF;
    IF new.alturahasta IS DISTINCT FROM old.alturahasta THEN
      INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
        VALUES ('cvp','calles','alturahasta','U',new.calle,new.calle,comun.A_TEXTO(old.alturahasta)||'->'||comun.a_texto(new.alturahasta),old.alturahasta,new.alturahasta);
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
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
      VALUES ('cvp','calles','alturadesde','D',old.calle,old.calle,'D:'||comun.a_texto(old.alturadesde),old.alturadesde);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
      VALUES ('cvp','calles','alturahasta','D',old.calle,old.calle,'D:'||comun.a_texto(old.alturahasta),old.alturahasta);
  END IF;
  IF v_operacion<>'D' THEN
    RETURN new;
  ELSE
    RETURN old;
  END IF;
END;
$BODY$;
