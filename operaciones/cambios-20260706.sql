ALTER TABLE cvp.relpre ADD COLUMN revisados text;
ALTER TABLE his.relpre ADD COLUMN revisados text;

CREATE OR REPLACE FUNCTION cvp.hisc_relpre_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$

  DECLARE
    v_operacion text:=substr(TG_OP,1,1);
  BEGIN

  IF v_operacion='I' THEN

        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','periodo','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.periodo),new.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','producto','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.producto),new.producto);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
             VALUES ('cvp','relpre','observacion','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.observacion),new.observacion);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
             VALUES ('cvp','relpre','informante','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.informante),new.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
             VALUES ('cvp','relpre','formulario','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.formulario),new.formulario);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
             VALUES ('cvp','relpre','precio','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.precio),new.precio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','tipoprecio','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.tipoprecio),new.tipoprecio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_number)
             VALUES ('cvp','relpre','visita','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.visita),new.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','modi_usu','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_datetime)
             VALUES ('cvp','relpre','modi_fec','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','modi_ope','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','comentariosrelpre','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.comentariosrelpre),new.comentariosrelpre);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','cambio','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.cambio),new.cambio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_bool)
             VALUES ('cvp','relpre','ultima_visita','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.ultima_visita),new.ultima_visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','observaciones','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.observaciones),new.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_bool)
             VALUES ('cvp','relpre','esvisiblecomentarioendm','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.esvisiblecomentarioendm),new.esvisiblecomentarioendm);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,new_text)
             VALUES ('cvp','relpre','revisados','I',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,'I:'||comun.a_texto(new.revisados),new.revisados);
  END IF;
  IF v_operacion='U' THEN

        IF new.periodo IS DISTINCT FROM old.periodo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','periodo','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
        END IF;
        IF new.producto IS DISTINCT FROM old.producto THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','producto','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
        END IF;
        IF new.observacion IS DISTINCT FROM old.observacion THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
                 VALUES ('cvp','relpre','observacion','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.observacion)||'->'||comun.a_texto(new.observacion),old.observacion,new.observacion);
        END IF;
        IF new.informante IS DISTINCT FROM old.informante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
                 VALUES ('cvp','relpre','informante','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
        END IF;
        IF new.formulario IS DISTINCT FROM old.formulario THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
                 VALUES ('cvp','relpre','formulario','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.formulario)||'->'||comun.a_texto(new.formulario),old.formulario,new.formulario);
        END IF;
        IF new.precio IS DISTINCT FROM old.precio THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
                 VALUES ('cvp','relpre','precio','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.precio)||'->'||comun.a_texto(new.precio),old.precio,new.precio);
        END IF;
        IF new.tipoprecio IS DISTINCT FROM old.tipoprecio THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','tipoprecio','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.tipoprecio)||'->'||comun.a_texto(new.tipoprecio),old.tipoprecio,new.tipoprecio);
        END IF;
        IF new.visita IS DISTINCT FROM old.visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number,new_number)
                 VALUES ('cvp','relpre','visita','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
        END IF;
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','modi_usu','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','relpre','modi_fec','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','modi_ope','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.comentariosrelpre IS DISTINCT FROM old.comentariosrelpre THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','comentariosrelpre','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.comentariosrelpre)||'->'||comun.a_texto(new.comentariosrelpre),old.comentariosrelpre,new.comentariosrelpre);
        END IF;
        IF new.cambio IS DISTINCT FROM old.cambio THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','cambio','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.cambio)||'->'||comun.a_texto(new.cambio),old.cambio,new.cambio);
        END IF;
        IF new.ultima_visita IS DISTINCT FROM old.ultima_visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_bool,new_bool)
                 VALUES ('cvp','relpre','ultima_visita','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.ultima_visita)||'->'||comun.a_texto(new.ultima_visita),old.ultima_visita,new.ultima_visita);
        END IF;
        IF new.observaciones IS DISTINCT FROM old.observaciones THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','observaciones','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.observaciones)||'->'||comun.a_texto(new.observaciones),old.observaciones,new.observaciones);
        END IF;
        IF new.esvisiblecomentarioendm IS DISTINCT FROM old.esvisiblecomentarioendm THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_bool,new_bool)
                 VALUES ('cvp','relpre','esvisiblecomentarioendm','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.esvisiblecomentarioendm)||'->'||comun.a_texto(new.esvisiblecomentarioendm),old.esvisiblecomentarioendm,new.esvisiblecomentarioendm);
        END IF;
        IF new.revisados IS DISTINCT FROM old.revisados THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text,new_text)
                 VALUES ('cvp','relpre','revisados','U',new.periodo||'|'||new.producto||'|'||new.observacion||'|'||new.informante||'|'||new.visita,new.periodo,new.producto,new.observacion,new.informante,new.visita,comun.A_TEXTO(old.revisados)||'->'||comun.a_texto(new.revisados),old.revisados,new.revisados);
        END IF;
  END IF;
  IF v_operacion='D' THEN

        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','periodo','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.periodo),old.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','producto','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.producto),old.producto);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
             VALUES ('cvp','relpre','observacion','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.observacion),old.observacion);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
             VALUES ('cvp','relpre','informante','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.informante),old.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
             VALUES ('cvp','relpre','formulario','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.formulario),old.formulario);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
             VALUES ('cvp','relpre','precio','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.precio),old.precio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','tipoprecio','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.tipoprecio),old.tipoprecio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_number)
             VALUES ('cvp','relpre','visita','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.visita),old.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','modi_usu','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_datetime)
             VALUES ('cvp','relpre','modi_fec','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','modi_ope','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','comentariosrelpre','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.comentariosrelpre),old.comentariosrelpre);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','cambio','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.cambio),old.cambio);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_bool)
             VALUES ('cvp','relpre','ultima_visita','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.ultima_visita),old.ultima_visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','observaciones','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.observaciones),old.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_bool)
             VALUES ('cvp','relpre','esvisiblecomentarioendm','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.esvisiblecomentarioendm),old.esvisiblecomentarioendm);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_number_3,pk_number_4,pk_number_5,change_value,old_text)
             VALUES ('cvp','relpre','revisados','D',old.periodo||'|'||old.producto||'|'||old.observacion||'|'||old.informante||'|'||old.visita,old.periodo,old.producto,old.observacion,old.informante,old.visita,'D:'||comun.a_texto(old.revisados),old.revisados);
  END IF;

  IF v_operacion<>'D' THEN
      RETURN new;
  ELSE
      RETURN old;
  END IF;
  END;
$BODY$;