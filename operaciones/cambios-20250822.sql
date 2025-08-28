ALTER TABLE cvp.informantes ADD COLUMN longitud DOUBLE PRECISION;
ALTER TABLE cvp.informantes ADD COLUMN latitud DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION cvp.hisc_informantes_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN

      IF v_operacion='I' THEN

                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','informante','I',new.informante,new.informante,'I:'||comun.a_texto(new.informante),new.informante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','nombreinformante','I',new.informante,new.informante,'I:'||comun.a_texto(new.nombreinformante),new.nombreinformante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','nombrecalle','I',new.informante,new.informante,'I:'||comun.a_texto(new.nombrecalle),new.nombrecalle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','tipoinformante','I',new.informante,new.informante,'I:'||comun.a_texto(new.tipoinformante),new.tipoinformante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','rubroclanae','I',new.informante,new.informante,'I:'||comun.a_texto(new.rubroclanae),new.rubroclanae);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','cadena','I',new.informante,new.informante,'I:'||comun.a_texto(new.cadena),new.cadena);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','direccion','I',new.informante,new.informante,'I:'||comun.a_texto(new.direccion),new.direccion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','modi_usu','I',new.informante,new.informante,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_datetime)
                     VALUES ('cvp','informantes','modi_fec','I',new.informante,new.informante,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','modi_ope','I',new.informante,new.informante,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','altamanualperiodo','I',new.informante,new.informante,'I:'||comun.a_texto(new.altamanualperiodo),new.altamanualperiodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','altamanualpanel','I',new.informante,new.informante,'I:'||comun.a_texto(new.altamanualpanel),new.altamanualpanel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','altamanualtarea','I',new.informante,new.informante,'I:'||comun.a_texto(new.altamanualtarea),new.altamanualtarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_datetime)
                     VALUES ('cvp','informantes','altamanualconfirmar','I',new.informante,new.informante,'I:'||comun.a_texto(new.altamanualconfirmar),new.altamanualconfirmar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','razonsocial','I',new.informante,new.informante,'I:'||comun.a_texto(new.razonsocial),new.razonsocial);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','altura','I',new.informante,new.informante,'I:'||comun.a_texto(new.altura),new.altura);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','piso','I',new.informante,new.informante,'I:'||comun.a_texto(new.piso),new.piso);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','departamento','I',new.informante,new.informante,'I:'||comun.a_texto(new.departamento),new.departamento);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','cuit','I',new.informante,new.informante,'I:'||comun.a_texto(new.cuit),new.cuit);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','naecba','I',new.informante,new.informante,'I:'||comun.a_texto(new.naecba),new.naecba);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','totalpers','I',new.informante,new.informante,'I:'||comun.a_texto(new.totalpers),new.totalpers);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','cp','I',new.informante,new.informante,'I:'||comun.a_texto(new.cp),new.cp);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','distrito','I',new.informante,new.informante,'I:'||comun.a_texto(new.distrito),new.distrito);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','fraccion_ant','I',new.informante,new.informante,'I:'||comun.a_texto(new.fraccion_ant),new.fraccion_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','radio_ant','I',new.informante,new.informante,'I:'||comun.a_texto(new.radio_ant),new.radio_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','manzana_ant','I',new.informante,new.informante,'I:'||comun.a_texto(new.manzana_ant),new.manzana_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','lado','I',new.informante,new.informante,'I:'||comun.a_texto(new.lado),new.lado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','obs_listador','I',new.informante,new.informante,'I:'||comun.a_texto(new.obs_listador),new.obs_listador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','nr_listador','I',new.informante,new.informante,'I:'||comun.a_texto(new.nr_listador),new.nr_listador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_datetime)
                     VALUES ('cvp','informantes','fecha_listado','I',new.informante,new.informante,'I:'||comun.a_texto(new.fecha_listado),new.fecha_listado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','grupo_listado','I',new.informante,new.informante,'I:'||comun.a_texto(new.grupo_listado),new.grupo_listado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','conjuntomuestral','I',new.informante,new.informante,'I:'||comun.a_texto(new.conjuntomuestral),new.conjuntomuestral);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','rubro','I',new.informante,new.informante,'I:'||comun.a_texto(new.rubro),new.rubro);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','ordenhdr','I',new.informante,new.informante,'I:'||comun.a_texto(new.ordenhdr),new.ordenhdr);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','cue','I',new.informante,new.informante,'I:'||comun.a_texto(new.cue),new.cue);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','idlocal','I',new.informante,new.informante,'I:'||comun.a_texto(new.idlocal),new.idlocal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','muestra','I',new.informante,new.informante,'I:'||comun.a_texto(new.muestra),new.muestra);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','contacto','I',new.informante,new.informante,'I:'||comun.a_texto(new.contacto),new.contacto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','telcontacto','I',new.informante,new.informante,'I:'||comun.a_texto(new.telcontacto),new.telcontacto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','barrio','I',new.informante,new.informante,'I:'||comun.a_texto(new.barrio),new.barrio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','comuna','I',new.informante,new.informante,'I:'||comun.a_texto(new.comuna),new.comuna);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','fraccion','I',new.informante,new.informante,'I:'||comun.a_texto(new.fraccion),new.fraccion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','radio','I',new.informante,new.informante,'I:'||comun.a_texto(new.radio),new.radio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','manzana','I',new.informante,new.informante,'I:'||comun.a_texto(new.manzana),new.manzana);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','depto','I',new.informante,new.informante,'I:'||comun.a_texto(new.depto),new.depto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','pc_anio','I',new.informante,new.informante,'I:'||comun.a_texto(new.pc_anio),new.pc_anio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','web','I',new.informante,new.informante,'I:'||comun.a_texto(new.web),new.web);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','email','I',new.informante,new.informante,'I:'||comun.a_texto(new.email),new.email);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_bool)
                     VALUES ('cvp','informantes','habilitar_prioritario','I',new.informante,new.informante,'I:'||comun.a_texto(new.habilitar_prioritario),new.habilitar_prioritario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','grupo_prioridad','I',new.informante,new.informante,'I:'||comun.a_texto(new.grupo_prioridad),new.grupo_prioridad);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','cluster','I',new.informante,new.informante,'I:'||comun.a_texto(new."cluster"),new."cluster");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','calle','I',new.informante,new.informante,'I:'||comun.a_texto(new."calle"),new."calle");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
                     VALUES ('cvp','informantes','provincia','I',new.informante,new.informante,'I:'||comun.a_texto(new."provincia"),new."provincia");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','circunselectoral','I',new.informante,new.informante,'I:'||comun.a_texto(new."circunselectoral"),new."circunselectoral");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','longitud','I',new.informante,new.informante,'I:'||comun.a_texto(new.longitud),new.longitud);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
                     VALUES ('cvp','informantes','latitud','I',new.informante,new.informante,'I:'||comun.a_texto(new.latitud),new.latitud);
      END IF;
      IF v_operacion='U' THEN

            IF new.informante IS DISTINCT FROM old.informante THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','informante','U',new.informante,new.informante,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
            END IF;
            IF new.nombreinformante IS DISTINCT FROM old.nombreinformante THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','nombreinformante','U',new.informante,new.informante,comun.A_TEXTO(old.nombreinformante)||'->'||comun.a_texto(new.nombreinformante),old.nombreinformante,new.nombreinformante);
            END IF;
            IF new.nombrecalle IS DISTINCT FROM old.nombrecalle THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','nombrecalle','U',new.informante,new.informante,comun.A_TEXTO(old.nombrecalle)||'->'||comun.a_texto(new.nombrecalle),old.nombrecalle,new.nombrecalle);
            END IF;
            IF new.tipoinformante IS DISTINCT FROM old.tipoinformante THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','tipoinformante','U',new.informante,new.informante,comun.A_TEXTO(old.tipoinformante)||'->'||comun.a_texto(new.tipoinformante),old.tipoinformante,new.tipoinformante);
            END IF;
            IF new.rubroclanae IS DISTINCT FROM old.rubroclanae THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','rubroclanae','U',new.informante,new.informante,comun.A_TEXTO(old.rubroclanae)||'->'||comun.a_texto(new.rubroclanae),old.rubroclanae,new.rubroclanae);
            END IF;
            IF new.cadena IS DISTINCT FROM old.cadena THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','cadena','U',new.informante,new.informante,comun.A_TEXTO(old.cadena)||'->'||comun.a_texto(new.cadena),old.cadena,new.cadena);
            END IF;
            IF new.direccion IS DISTINCT FROM old.direccion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','direccion','U',new.informante,new.informante,comun.A_TEXTO(old.direccion)||'->'||comun.a_texto(new.direccion),old.direccion,new.direccion);
            END IF;
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','modi_usu','U',new.informante,new.informante,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','informantes','modi_fec','U',new.informante,new.informante,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','modi_ope','U',new.informante,new.informante,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;
            IF new.altamanualperiodo IS DISTINCT FROM old.altamanualperiodo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','altamanualperiodo','U',new.informante,new.informante,comun.A_TEXTO(old.altamanualperiodo)||'->'||comun.a_texto(new.altamanualperiodo),old.altamanualperiodo,new.altamanualperiodo);
            END IF;
            IF new.altamanualpanel IS DISTINCT FROM old.altamanualpanel THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','altamanualpanel','U',new.informante,new.informante,comun.A_TEXTO(old.altamanualpanel)||'->'||comun.a_texto(new.altamanualpanel),old.altamanualpanel,new.altamanualpanel);
            END IF;
            IF new.altamanualtarea IS DISTINCT FROM old.altamanualtarea THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','altamanualtarea','U',new.informante,new.informante,comun.A_TEXTO(old.altamanualtarea)||'->'||comun.a_texto(new.altamanualtarea),old.altamanualtarea,new.altamanualtarea);
            END IF;
            IF new.altamanualconfirmar IS DISTINCT FROM old.altamanualconfirmar THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','informantes','altamanualconfirmar','U',new.informante,new.informante,comun.A_TEXTO(old.altamanualconfirmar)||'->'||comun.a_texto(new.altamanualconfirmar),old.altamanualconfirmar,new.altamanualconfirmar);
            END IF;
            IF new.razonsocial IS DISTINCT FROM old.razonsocial THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','razonsocial','U',new.informante,new.informante,comun.A_TEXTO(old.razonsocial)||'->'||comun.a_texto(new.razonsocial),old.razonsocial,new.razonsocial);
            END IF;
            IF new.altura IS DISTINCT FROM old.altura THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','altura','U',new.informante,new.informante,comun.A_TEXTO(old.altura)||'->'||comun.a_texto(new.altura),old.altura,new.altura);
            END IF;
            IF new.piso IS DISTINCT FROM old.piso THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','piso','U',new.informante,new.informante,comun.A_TEXTO(old.piso)||'->'||comun.a_texto(new.piso),old.piso,new.piso);
            END IF;
            IF new.departamento IS DISTINCT FROM old.departamento THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','departamento','U',new.informante,new.informante,comun.A_TEXTO(old.departamento)||'->'||comun.a_texto(new.departamento),old.departamento,new.departamento);
            END IF;
            IF new.cuit IS DISTINCT FROM old.cuit THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','cuit','U',new.informante,new.informante,comun.A_TEXTO(old.cuit)||'->'||comun.a_texto(new.cuit),old.cuit,new.cuit);
            END IF;
            IF new.naecba IS DISTINCT FROM old.naecba THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','naecba','U',new.informante,new.informante,comun.A_TEXTO(old.naecba)||'->'||comun.a_texto(new.naecba),old.naecba,new.naecba);
            END IF;
            IF new.totalpers IS DISTINCT FROM old.totalpers THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','totalpers','U',new.informante,new.informante,comun.A_TEXTO(old.totalpers)||'->'||comun.a_texto(new.totalpers),old.totalpers,new.totalpers);
            END IF;

            IF new.cp IS DISTINCT FROM old.cp THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','cp','U',new.informante,new.informante,comun.A_TEXTO(old.cp)||'->'||comun.a_texto(new.cp),old.cp,new.cp);
            END IF;
            IF new.distrito IS DISTINCT FROM old.distrito THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','distrito','U',new.informante,new.informante,comun.A_TEXTO(old.distrito)||'->'||comun.a_texto(new.distrito),old.distrito,new.distrito);
            END IF;
            IF new.fraccion_ant IS DISTINCT FROM old.fraccion_ant THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','fraccion_ant','U',new.informante,new.informante,comun.A_TEXTO(old.fraccion_ant)||'->'||comun.a_texto(new.fraccion_ant),old.fraccion_ant,new.fraccion_ant);
            END IF;
            IF new.radio_ant IS DISTINCT FROM old.radio_ant THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','radio_ant','U',new.informante,new.informante,comun.A_TEXTO(old.radio_ant)||'->'||comun.a_texto(new.radio_ant),old.radio_ant,new.radio_ant);
            END IF;
            IF new.manzana_ant IS DISTINCT FROM old.manzana_ant THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','manzana_ant','U',new.informante,new.informante,comun.A_TEXTO(old.manzana_ant)||'->'||comun.a_texto(new.manzana_ant),old.manzana_ant,new.manzana_ant);
            END IF;
            IF new.lado IS DISTINCT FROM old.lado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','lado','U',new.informante,new.informante,comun.A_TEXTO(old.lado)||'->'||comun.a_texto(new.lado),old.lado,new.lado);
            END IF;
            IF new.obs_listador IS DISTINCT FROM old.obs_listador THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','obs_listador','U',new.informante,new.informante,comun.A_TEXTO(old.obs_listador)||'->'||comun.a_texto(new.obs_listador),old.obs_listador,new.obs_listador);
            END IF;
            IF new.nr_listador IS DISTINCT FROM old.nr_listador THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','nr_listador','U',new.informante,new.informante,comun.A_TEXTO(old.nr_listador)||'->'||comun.a_texto(new.nr_listador),old.nr_listador,new.nr_listador);
            END IF;
            IF new.fecha_listado IS DISTINCT FROM old.fecha_listado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','informantes','fecha_listado','U',new.informante,new.informante,comun.A_TEXTO(old.fecha_listado)||'->'||comun.a_texto(new.fecha_listado),old.fecha_listado,new.fecha_listado);
            END IF;
            IF new.grupo_listado IS DISTINCT FROM old.grupo_listado THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','grupo_listado','U',new.informante,new.informante,comun.A_TEXTO(old.grupo_listado)||'->'||comun.a_texto(new.grupo_listado),old.grupo_listado,new.grupo_listado);
            END IF;
            IF new.conjuntomuestral IS DISTINCT FROM old.conjuntomuestral THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','conjuntomuestral','U',new.informante,new.informante,comun.A_TEXTO(old.conjuntomuestral)||'->'||comun.a_texto(new.conjuntomuestral),old.conjuntomuestral,new.conjuntomuestral);
            END IF;
            IF new.rubro IS DISTINCT FROM old.rubro THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','rubro','U',new.informante,new.informante,comun.A_TEXTO(old.rubro)||'->'||comun.a_texto(new.rubro),old.rubro,new.rubro);
            END IF;
            IF new.ordenhdr IS DISTINCT FROM old.ordenhdr THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','ordenhdr','U',new.informante,new.informante,comun.A_TEXTO(old.ordenhdr)||'->'||comun.a_texto(new.ordenhdr),old.ordenhdr,new.ordenhdr);
            END IF;
            IF new.cue IS DISTINCT FROM old.cue THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','cue','U',new.informante,new.informante,comun.A_TEXTO(old.cue)||'->'||comun.a_texto(new.cue),old.cue,new.cue);
            END IF;
            IF new.idlocal IS DISTINCT FROM old.idlocal THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','idlocal','U',new.informante,new.informante,comun.A_TEXTO(old.idlocal)||'->'||comun.a_texto(new.idlocal),old.idlocal,new.idlocal);
            END IF;
            IF new.muestra IS DISTINCT FROM old.muestra THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','muestra','U',new.informante,new.informante,comun.A_TEXTO(old.muestra)||'->'||comun.a_texto(new.muestra),old.muestra,new.muestra);
            END IF;
            IF new.contacto IS DISTINCT FROM old.contacto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','contacto','U',new.informante,new.informante,comun.A_TEXTO(old.contacto)||'->'||comun.a_texto(new.contacto),old.contacto,new.contacto);
            END IF;
            IF new.telcontacto IS DISTINCT FROM old.telcontacto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','telcontacto','U',new.informante,new.informante,comun.A_TEXTO(old.telcontacto)||'->'||comun.a_texto(new.telcontacto),old.telcontacto,new.telcontacto);
            END IF;
            IF new.barrio IS DISTINCT FROM old.barrio THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','barrio','U',new.informante,new.informante,comun.A_TEXTO(old.barrio)||'->'||comun.a_texto(new.barrio),old.barrio,new.barrio);
            END IF;
            IF new.comuna IS DISTINCT FROM old.comuna THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','comuna','U',new.informante,new.informante,comun.A_TEXTO(old.comuna)||'->'||comun.a_texto(new.comuna),old.comuna,new.comuna);
            END IF;
            IF new.fraccion IS DISTINCT FROM old.fraccion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','fraccion','U',new.informante,new.informante,comun.A_TEXTO(old.fraccion)||'->'||comun.a_texto(new.fraccion),old.fraccion,new.fraccion);
            END IF;
            IF new.radio IS DISTINCT FROM old.radio THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','radio','U',new.informante,new.informante,comun.A_TEXTO(old.radio)||'->'||comun.a_texto(new.radio),old.radio,new.radio);
            END IF;
            IF new.manzana IS DISTINCT FROM old.manzana THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','manzana','U',new.informante,new.informante,comun.A_TEXTO(old.manzana)||'->'||comun.a_texto(new.manzana),old.manzana,new.manzana);
            END IF;
            IF new.depto IS DISTINCT FROM old.depto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','depto','U',new.informante,new.informante,comun.A_TEXTO(old.depto)||'->'||comun.a_texto(new.depto),old.depto,new.depto);
            END IF;
            IF new.pc_anio IS DISTINCT FROM old.pc_anio THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','pc_anio','U',new.informante,new.informante,comun.A_TEXTO(old.pc_anio)||'->'||comun.a_texto(new.pc_anio),old.pc_anio,new.pc_anio);
            END IF;
            IF new.web IS DISTINCT FROM old.web THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','web','U',new.informante,new.informante,comun.A_TEXTO(old.web)||'->'||comun.a_texto(new.web),old.web,new.web);
            END IF;
            IF new.email IS DISTINCT FROM old.email THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','email','U',new.informante,new.informante,comun.A_TEXTO(old.email)||'->'||comun.a_texto(new.email),old.email,new.email);
            END IF;
            IF new.habilitar_prioritario IS DISTINCT FROM old.habilitar_prioritario THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_bool,new_bool)
                     VALUES ('cvp','informantes','habilitar_prioritario','U',new.informante,new.informante,comun.A_TEXTO(old.habilitar_prioritario)||'->'||comun.a_texto(new.habilitar_prioritario),old.habilitar_prioritario,new.habilitar_prioritario);
            END IF;
            IF new.grupo_prioridad IS DISTINCT FROM old.grupo_prioridad THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','grupo_prioridad','U',new.informante,new.informante,comun.A_TEXTO(old.grupo_prioridad)||'->'||comun.a_texto(new.grupo_prioridad),old.grupo_prioridad,new.grupo_prioridad);
            END IF;
            IF new."cluster" IS DISTINCT FROM old."cluster" THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','cluster','U',new.informante,new.informante,comun.A_TEXTO(old."cluster")||'->'||comun.a_texto(new."cluster"),old."cluster",new."cluster");
            END IF;
            IF new.calle IS DISTINCT FROM old.calle THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','calle','U',new.informante,new.informante,comun.A_TEXTO(old.calle)||'->'||comun.a_texto(new.calle),old.calle,new.calle);
            END IF;
            IF new.provincia IS DISTINCT FROM old.provincia THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                     VALUES ('cvp','informantes','provincia','U',new.informante,new.informante,comun.A_TEXTO(old.provincia)||'->'||comun.a_texto(new.provincia),old.provincia,new.provincia);
            END IF;
            IF new.circunselectoral IS DISTINCT FROM old.circunselectoral THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','circunselectoral','U',new.informante,new.informante,comun.A_TEXTO(old.circunselectoral)||'->'||comun.a_texto(new.circunselectoral),old.circunselectoral,new.circunselectoral);
            END IF;
            IF new.longitud IS DISTINCT FROM old.longitud THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','longitud','U',new.informante,new.informante,comun.A_TEXTO(old.longitud)||'->'||comun.a_texto(new.longitud),old.longitud,new.longitud);
            END IF;
            IF new.latitud IS DISTINCT FROM old.latitud THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                     VALUES ('cvp','informantes','latitud','U',new.informante,new.informante,comun.A_TEXTO(old.latitud)||'->'||comun.a_texto(new.latitud),old.latitud,new.latitud);
            END IF;
      END IF;
      IF v_operacion='D' THEN

                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','informante','D',old.informante,old.informante,'D:'||comun.a_texto(old.informante),old.informante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','nombreinformante','D',old.informante,old.informante,'D:'||comun.a_texto(old.nombreinformante),old.nombreinformante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','nombrecalle','D',old.informante,old.informante,'D:'||comun.a_texto(old.nombrecalle),old.nombrecalle);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','tipoinformante','D',old.informante,old.informante,'D:'||comun.a_texto(old.tipoinformante),old.tipoinformante);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','rubroclanae','D',old.informante,old.informante,'D:'||comun.a_texto(old.rubroclanae),old.rubroclanae);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','cadena','D',old.informante,old.informante,'D:'||comun.a_texto(old.cadena),old.cadena);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','direccion','D',old.informante,old.informante,'D:'||comun.a_texto(old.direccion),old.direccion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','modi_usu','D',old.informante,old.informante,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime)
                     VALUES ('cvp','informantes','modi_fec','D',old.informante,old.informante,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','modi_ope','D',old.informante,old.informante,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','altamanualperiodo','D',old.informante,old.informante,'D:'||comun.a_texto(old.altamanualperiodo),old.altamanualperiodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','altamanualpanel','D',old.informante,old.informante,'D:'||comun.a_texto(old.altamanualpanel),old.altamanualpanel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','altamanualtarea','D',old.informante,old.informante,'D:'||comun.a_texto(old.altamanualtarea),old.altamanualtarea);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime)
                     VALUES ('cvp','informantes','altamanualconfirmar','D',old.informante,old.informante,'D:'||comun.a_texto(old.altamanualconfirmar),old.altamanualconfirmar);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','razonsocial','D',old.informante,old.informante,'D:'||comun.a_texto(old.razonsocial),old.razonsocial);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','altura','D',old.informante,old.informante,'D:'||comun.a_texto(old.altura),old.altura);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','piso','D',old.informante,old.informante,'D:'||comun.a_texto(old.piso),old.piso);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','departamento','D',old.informante,old.informante,'D:'||comun.a_texto(old.departamento),old.departamento);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','cuit','D',old.informante,old.informante,'D:'||comun.a_texto(old.cuit),old.cuit);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','naecba','D',old.informante,old.informante,'D:'||comun.a_texto(old.naecba),old.naecba);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','totalpers','D',old.informante,old.informante,'D:'||comun.a_texto(old.totalpers),old.totalpers);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','cp','D',old.informante,old.informante,'D:'||comun.a_texto(old.cp),old.cp);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','distrito','D',old.informante,old.informante,'D:'||comun.a_texto(old.distrito),old.distrito);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','fraccion_ant','D',old.informante,old.informante,'D:'||comun.a_texto(old.fraccion_ant),old.fraccion_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','radio_ant','D',old.informante,old.informante,'D:'||comun.a_texto(old.radio_ant),old.radio_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','manzana_ant','D',old.informante,old.informante,'D:'||comun.a_texto(old.manzana_ant),old.manzana_ant);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','lado','D',old.informante,old.informante,'D:'||comun.a_texto(old.lado),old.lado);
               INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','obs_listador','D',old.informante,old.informante,'D:'||comun.a_texto(old.obs_listador),old.obs_listador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','nr_listador','D',old.informante,old.informante,'D:'||comun.a_texto(old.nr_listador),old.nr_listador);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_datetime)
                     VALUES ('cvp','informantes','fecha_listado','D',old.informante,old.informante,'D:'||comun.a_texto(old.fecha_listado),old.fecha_listado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','grupo_listado','D',old.informante,old.informante,'D:'||comun.a_texto(old.grupo_listado),old.grupo_listado);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','conjuntomuestral','D',old.informante,old.informante,'D:'||comun.a_texto(old.conjuntomuestral),old.conjuntomuestral);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','rubro','D',old.informante,old.informante,'D:'||comun.a_texto(old.rubro),old.rubro);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','ordenhdr','D',old.informante,old.informante,'D:'||comun.a_texto(old.ordenhdr),old.ordenhdr);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','cue','D',old.informante,old.informante,'D:'||comun.a_texto(old.cue),old.cue);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','idlocal','D',old.informante,old.informante,'D:'||comun.a_texto(old.idlocal),old.idlocal);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','muestra','D',old.informante,old.informante,'D:'||comun.a_texto(old.muestra),old.muestra);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','contacto','D',old.informante,old.informante,'D:'||comun.a_texto(old.contacto),old.contacto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','telcontacto','D',old.informante,old.informante,'D:'||comun.a_texto(old.telcontacto),old.telcontacto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','barrio','D',old.informante,old.informante,'D:'||comun.a_texto(old.barrio),old.barrio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','comuna','D',old.informante,old.informante,'D:'||comun.a_texto(old.comuna),old.comuna);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','fraccion','D',old.informante,old.informante,'D:'||comun.a_texto(old.fraccion),old.fraccion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','radio','D',old.informante,old.informante,'D:'||comun.a_texto(old.radio),old.radio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','manzana','D',old.informante,old.informante,'D:'||comun.a_texto(old.manzana),old.manzana);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','depto','D',old.informante,old.informante,'D:'||comun.a_texto(old.depto),old.depto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','pc_anio','D',old.informante,old.informante,'D:'||comun.a_texto(old.pc_anio),old.pc_anio);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','web','D',old.informante,old.informante,'D:'||comun.a_texto(old.web),old.web);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','email','D',old.informante,old.informante,'D:'||comun.a_texto(old.email),old.email);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_bool)
                     VALUES ('cvp','informantes','habilitar_prioritario','D',old.informante,old.informante,'D:'||comun.a_texto(old.habilitar_prioritario),old.habilitar_prioritario);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','grupo_prioridad','D',old.informante,old.informante,'D:'||comun.a_texto(old.grupo_prioridad),old.grupo_prioridad);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','cluster','D',old.informante,old.informante,'D:'||comun.a_texto(old."cluster"),old."cluster");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','calle','D',old.informante,old.informante,'D:'||comun.a_texto(old."calle"),old."calle");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
                     VALUES ('cvp','informantes','provincia','D',old.informante,old.informante,'D:'||comun.a_texto(old."provincia"),old."provincia");
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','circunselectoral','D',old.informante,old.informante,'D:'||comun.a_texto(old."circunselectoral"),old."circunselectoral");
                insert INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','longitud','D',old.informante,old.informante,'D:'||comun.a_texto(old.longitud),old.longitud);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
                     VALUES ('cvp','informantes','latitud','D',old.informante,old.informante,'D:'||comun.a_texto(old.latitud),old.latitud);
      END IF;

        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;
        END IF;
      END;

$BODY$;

CREATE OR REPLACE FUNCTION cvp.generar_direccion_informante_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
vnombrecalle   character varying(100);
vparadireccion character varying(100);
BEGIN
SELECT nombrecalle INTO vnombrecalle
  FROM cvp.calles
  WHERE calle = NEW.calle;
vparadireccion := COALESCE(vnombrecalle, NEW.nombrecalle);
IF TG_OP = 'INSERT' THEN
  --NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  NEW.direccion := TRIM(vparadireccion||' '||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  ELSIF TG_OP = 'UPDATE' THEN
   IF NEW.CALLE IS DISTINCT FROM OLD.calle
     OR COALESCE(vparadireccion,'') <> COALESCE(OLD.nombrecalle,'')
     OR COALESCE(NEW.altura,'') <> COALESCE(OLD.altura,'')
     OR COALESCE(NEW.piso,'') <> COALESCE(OLD.piso,'')
     OR COALESCE(NEW.departamento,'') <> COALESCE(OLD.departamento,'') THEN
     --NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
     NEW.direccion := TRIM(vparadireccion||' '||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
   END IF;
END IF;
RETURN NEW;
END;
$BODY$;