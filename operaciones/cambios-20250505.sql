set search_path = cvp;
alter table prodatrval add column valido boolean;

ALTER TABLE prodatrval DISABLE TRIGGER prodatrval_modi_trg;
ALTER TABLE prodatrval DISABLE TRIGGER hisc_trg;

UPDATE
    prodatrval
SET
    valido = true;

ALTER TABLE prodatrval ENABLE TRIGGER prodatrval_modi_trg;
ALTER TABLE prodatrval ENABLE TRIGGER hisc_trg;

CREATE OR REPLACE FUNCTION hisc_prodatrval_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
      v_operacion text:=substr(TG_OP,1,1);
BEGIN
      IF v_operacion='I' THEN
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','producto','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.producto),new.producto);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','atributo','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo),new.atributo);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','valor','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor),new.valor);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','orden','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.orden),new.orden);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','atributo_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo_2),new.atributo_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','valor_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor_2),new.valor_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','modi_usu','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
              VALUES ('cvp','prodatrval','modi_fec','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','modi_ope','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_bool)
              VALUES ('cvp','prodatrval','valido','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valido),new.valido);
      END IF;
      IF v_operacion='U' THEN
        IF new.producto IS DISTINCT FROM old.producto THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','producto','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
        END IF;
        IF new.atributo IS DISTINCT FROM old.atributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','atributo','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo)||'->'||comun.a_texto(new.atributo),old.atributo,new.atributo);
        END IF;
        IF new.valor IS DISTINCT FROM old.valor THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','valor','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor)||'->'||comun.a_texto(new.valor),old.valor,new.valor);
        END IF;
        IF new.orden IS DISTINCT FROM old.orden THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','orden','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.orden)||'->'||comun.a_texto(new.orden),old.orden,new.orden);
        END IF;    
        IF new.atributo_2 IS DISTINCT FROM old.atributo_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','atributo_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo_2)||'->'||comun.a_texto(new.atributo_2),old.atributo_2,new.atributo_2);
        END IF;    
        IF new.valor_2 IS DISTINCT FROM old.valor_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','valor_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor_2)||'->'||comun.a_texto(new.valor_2),old.valor_2,new.valor_2);
        END IF;
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','modi_usu','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','prodatrval','modi_fec','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','modi_ope','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.valido IS DISTINCT FROM old.valido THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_bool,new_bool)
                 VALUES ('cvp','prodatrval','valido','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valido)||'->'||comun.a_texto(new.valido),old.valido,new.valido);
        END IF;
      END IF;
      IF v_operacion='D' THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','producto','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.producto),old.producto);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','atributo','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo),old.atributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','valor','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor),old.valor);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','orden','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.orden),old.orden);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','atributo_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo_2),old.atributo_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','valor_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor_2),old.valor_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','modi_usu','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
             VALUES ('cvp','prodatrval','modi_fec','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','modi_ope','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_bool)
             VALUES ('cvp','prodatrval','valido','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valido),old.valido);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;  
      END IF;
END;
$BODY$;