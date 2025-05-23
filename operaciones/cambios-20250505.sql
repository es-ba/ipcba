set search_path = cvp;
set role cvpowner;

ALTER TABLE prodatrval
RENAME TO prodatrval_edit;

DROP TRIGGER prodatrval_modi_trg ON prodatrval_edit;

CREATE TRIGGER prodatrval_edit_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.prodatrval_edit
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();

DROP TRIGGER hisc_trg ON prodatrval_edit;

alter table prodatrval_edit add column activo boolean;

ALTER TABLE prodatrval_edit DISABLE TRIGGER prodatrval_edit_modi_trg;

UPDATE
    prodatrval_edit
SET
    activo = true;

ALTER TABLE prodatrval_edit ENABLE TRIGGER prodatrval_edit_modi_trg;

CREATE VIEW prodatrval AS
SELECT producto, atributo, valor, orden, atributo_2, valor_2, modi_usu usuario, modi_fec::date fecha
FROM prodatrval_edit
where activo;
GRANT SELECT ON TABLE prodatrval TO cvp_usuarios;
GRANT ALL ON TABLE prodatrval TO cvpowner;

CREATE OR REPLACE FUNCTION hisc_prodatrval_edit_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
      v_operacion text:=substr(TG_OP,1,1);
BEGIN
      IF v_operacion='I' THEN
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval_edit','producto','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.producto),new.producto);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval_edit','atributo','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo),new.atributo);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval_edit','valor','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor),new.valor);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval_edit','orden','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.orden),new.orden);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval_edit','atributo_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo_2),new.atributo_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval_edit','valor_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor_2),new.valor_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval_edit','modi_usu','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
              VALUES ('cvp','prodatrval_edit','modi_fec','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval_edit','modi_ope','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_bool)
              VALUES ('cvp','prodatrval_edit','activo','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.activo),new.activo);
      END IF;
      IF v_operacion='U' THEN
        IF new.producto IS DISTINCT FROM old.producto THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval_edit','producto','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
        END IF;
        IF new.atributo IS DISTINCT FROM old.atributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval_edit','atributo','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo)||'->'||comun.a_texto(new.atributo),old.atributo,new.atributo);
        END IF;
        IF new.valor IS DISTINCT FROM old.valor THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval_edit','valor','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor)||'->'||comun.a_texto(new.valor),old.valor,new.valor);
        END IF;
        IF new.orden IS DISTINCT FROM old.orden THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval_edit','orden','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.orden)||'->'||comun.a_texto(new.orden),old.orden,new.orden);
        END IF;
        IF new.atributo_2 IS DISTINCT FROM old.atributo_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval_edit','atributo_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo_2)||'->'||comun.a_texto(new.atributo_2),old.atributo_2,new.atributo_2);
        END IF;
        IF new.valor_2 IS DISTINCT FROM old.valor_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval_edit','valor_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor_2)||'->'||comun.a_texto(new.valor_2),old.valor_2,new.valor_2);
        END IF;
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval_edit','modi_usu','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','prodatrval_edit','modi_fec','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval_edit','modi_ope','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.activo IS DISTINCT FROM old.activo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_bool,new_bool)
                 VALUES ('cvp','prodatrval_edit','activo','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.activo)||'->'||comun.a_texto(new.activo),old.activo,new.activo);
        END IF;
      END IF;
      IF v_operacion='D' THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval_edit','producto','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.producto),old.producto);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval_edit','atributo','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo),old.atributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval_edit','valor','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor),old.valor);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval_edit','orden','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.orden),old.orden);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval_edit','atributo_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo_2),old.atributo_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval_edit','valor_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor_2),old.valor_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval_edit','modi_usu','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
             VALUES ('cvp','prodatrval_edit','modi_fec','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval_edit','modi_ope','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_bool)
             VALUES ('cvp','prodatrval_edit','activo','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.activo),old.activo);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;
      END IF;
END;
$BODY$;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.prodatrval_edit
    FOR EACH ROW
    EXECUTE FUNCTION cvp.hisc_prodatrval_edit_trg();