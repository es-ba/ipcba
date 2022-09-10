--empalme 
--Paso 1: macheo, prefijo b1112: base 2011-2012
SET search_path = cvp;
CREATE TABLE empalme_b1112 AS SELECT agrupacion AS agrupacion_b1112, grupo grupo_b1112, agrupacion, grupo FROM calgru WHERE FALSE;
ALTER TABLE empalme_b1112 ADD PRIMARY KEY (agrupacion_b1112, grupo_b1112, agrupacion, grupo);
ALTER TABLE empalme_b1112 OWNER TO cvpowner;

--Paso 2 tabla calculos de la base 2011-2012
CREATE TABLE calculos_b1112 AS SELECT * FROM calculos;
ALTER TABLE calculos_b1112 ADD PRIMARY KEY (periodo, calculo);
   --agrego calculo principal de la base 2021
ALTER TABLE calculos_b1112 ADD COLUMN calculoprincipal_b21 integer;
ALTER TABLE calculos_b1112 OWNER TO cvpowner;

GRANT SELECT ON TABLE calculos_b1112 TO cvp_administrador;

--Paso 3 agrego el parametro periodo_empalme
ALTER TABLE parametros ADD COLUMN periodo_empalme character varying(11);
  --agregar histórico de parametros:
CREATE OR REPLACE FUNCTION hisc_parametros_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE
  v_operacion text:=substr(TG_OP,1,1);
BEGIN
  
IF v_operacion='I' THEN 
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_bool)
         VALUES ('cvp','parametros','unicoregistro','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.unicoregistro),new.unicoregistro);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','nombreaplicacion','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.nombreaplicacion),new.nombreaplicacion);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','titulo','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.titulo),new.titulo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','archivologo','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.archivologo),new.archivologo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','tamannodesvpre','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.tamannodesvpre),new.tamannodesvpre);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','tamannodesvvar','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.tamannodesvvar),new.tamannodesvvar);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','codigo','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.codigo),new.codigo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','formularionumeracionglobal','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.formularionumeracionglobal),new.formularionumeracionglobal);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','estructuraversioncommit','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.estructuraversioncommit),new.estructuraversioncommit);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','soloingresaingresador','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.soloingresaingresador),new.soloingresaingresador);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','pb_desde','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.pb_desde),new.pb_desde);     
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','pb_hasta','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.pb_hasta),new.pb_hasta);          
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','ph_desde','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.ph_desde),new.ph_desde);     
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','sup_aleat_prob1','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.sup_aleat_prob1),new.sup_aleat_prob1);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','sup_aleat_prob2','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.sup_aleat_prob2),new.sup_aleat_prob2);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','sup_aleat_prob_per','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.sup_aleat_prob_per),new.sup_aleat_prob_per);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','sup_aleat_prob_pantar','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.sup_aleat_prob_pantar),new.sup_aleat_prob_pantar);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','diferencia_horaria_tolerancia_ipad','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.diferencia_horaria_tolerancia_ipad),new.diferencia_horaria_tolerancia_ipad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','diferencia_horaria_advertencia_ipad','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.diferencia_horaria_advertencia_ipad),new.diferencia_horaria_advertencia_ipad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','puedeagregarvisita','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.puedeagregarvisita),new.puedeagregarvisita);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_bool)
         VALUES ('cvp','parametros','permitir_cualquier_cambio_panel_tarea','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.permitir_cualquier_cambio_panel_tarea),new.permitir_cualquier_cambio_panel_tarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','periodoreferenciaparapaneltarea','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.periodoreferenciaparapaneltarea),new.periodoreferenciaparapaneltarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','periodoreferenciaparapreciospositivos','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.periodoreferenciaparapreciospositivos),new.periodoreferenciaparapreciospositivos);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','solo_cluster','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.solo_cluster),new.solo_cluster);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','umbraligualdad','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.umbraligualdad),new.umbraligualdad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','periodo_empalme','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.periodo_empalme),new.periodo_empalme);
END IF;
IF v_operacion='U' THEN    
    IF new.unicoregistro IS DISTINCT FROM old.unicoregistro THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool,new_bool)
             VALUES ('cvp','parametros','unicoregistro','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.unicoregistro)||'->'||comun.a_texto(new.unicoregistro),old.unicoregistro,new.unicoregistro);
    END IF;    
    IF new.nombreaplicacion IS DISTINCT FROM old.nombreaplicacion THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','nombreaplicacion','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.nombreaplicacion)||'->'||comun.a_texto(new.nombreaplicacion),old.nombreaplicacion,new.nombreaplicacion);
    END IF;    
    IF new.titulo IS DISTINCT FROM old.titulo THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','titulo','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.titulo)||'->'||comun.a_texto(new.titulo),old.titulo,new.titulo);
    END IF;    
    IF new.archivologo IS DISTINCT FROM old.archivologo THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','archivologo','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.archivologo)||'->'||comun.a_texto(new.archivologo),old.archivologo,new.archivologo);
    END IF;    
    IF new.tamannodesvpre IS DISTINCT FROM old.tamannodesvpre THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','tamannodesvpre','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.tamannodesvpre)||'->'||comun.a_texto(new.tamannodesvpre),old.tamannodesvpre,new.tamannodesvpre);
    END IF;    
    IF new.tamannodesvvar IS DISTINCT FROM old.tamannodesvvar THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','tamannodesvvar','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.tamannodesvvar)||'->'||comun.a_texto(new.tamannodesvvar),old.tamannodesvvar,new.tamannodesvvar);
    END IF;    
    IF new.codigo IS DISTINCT FROM old.codigo THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','codigo','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.codigo)||'->'||comun.a_texto(new.codigo),old.codigo,new.codigo);
    END IF;
    IF new.formularionumeracionglobal IS DISTINCT FROM old.formularionumeracionglobal THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','formularionumeracionglobal','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.formularionumeracionglobal)||'->'||comun.a_texto(new.formularionumeracionglobal),old.formularionumeracionglobal,new.formularionumeracionglobal);
    END IF;    
    IF new.estructuraversioncommit IS DISTINCT FROM old.estructuraversioncommit THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','estructuraversioncommit','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.estructuraversioncommit)||'->'||comun.a_texto(new.estructuraversioncommit),old.estructuraversioncommit,new.estructuraversioncommit);
    END IF;    
    IF new.soloingresaingresador IS DISTINCT FROM old.soloingresaingresador THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','soloingresaingresador','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.soloingresaingresador)||'->'||comun.a_texto(new.soloingresaingresador),old.soloingresaingresador,new.soloingresaingresador);
    END IF;    
    IF new.pb_desde IS DISTINCT FROM old.pb_desde THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','pb_desde','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.pb_desde)||'->'||comun.a_texto(new.pb_desde),old.pb_desde,new.pb_desde);
    END IF;
    IF new.pb_hasta IS DISTINCT FROM old.pb_hasta THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','pb_hasta','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.pb_hasta)||'->'||comun.a_texto(new.pb_hasta),old.pb_hasta,new.pb_hasta);
    END IF;
    IF new.ph_desde IS DISTINCT FROM old.ph_desde THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','ph_desde','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.ph_desde)||'->'||comun.a_texto(new.ph_desde),old.ph_desde,new.ph_desde);
    END IF;
    IF new.sup_aleat_prob1 IS DISTINCT FROM old.sup_aleat_prob1 THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','sup_aleat_prob1','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.sup_aleat_prob1)||'->'||comun.a_texto(new.sup_aleat_prob1),old.sup_aleat_prob1,new.sup_aleat_prob1);
    END IF;    
    IF new.sup_aleat_prob2 IS DISTINCT FROM old.sup_aleat_prob2 THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','sup_aleat_prob2','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.sup_aleat_prob2)||'->'||comun.a_texto(new.sup_aleat_prob2),old.sup_aleat_prob2,new.sup_aleat_prob2);
    END IF;    
    IF new.sup_aleat_prob_per IS DISTINCT FROM old.sup_aleat_prob_per THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','sup_aleat_prob_per','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.sup_aleat_prob_per)||'->'||comun.a_texto(new.sup_aleat_prob_per),old.sup_aleat_prob_per,new.sup_aleat_prob_per);
    END IF;    
    IF new.sup_aleat_prob_pantar IS DISTINCT FROM old.sup_aleat_prob_pantar THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','sup_aleat_prob_pantar','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.sup_aleat_prob_pantar)||'->'||comun.a_texto(new.sup_aleat_prob_pantar),old.sup_aleat_prob_pantar,new.sup_aleat_prob_pantar);
    END IF;    
    IF new.diferencia_horaria_tolerancia_ipad IS DISTINCT FROM old.diferencia_horaria_tolerancia_ipad THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','diferencia_horaria_tolerancia_ipad','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.diferencia_horaria_tolerancia_ipad)||'->'||comun.a_texto(new.diferencia_horaria_tolerancia_ipad),old.diferencia_horaria_tolerancia_ipad,new.diferencia_horaria_tolerancia_ipad);
    END IF;    
    IF new.diferencia_horaria_advertencia_ipad IS DISTINCT FROM old.diferencia_horaria_advertencia_ipad THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','diferencia_horaria_advertencia_ipad','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.diferencia_horaria_advertencia_ipad)||'->'||comun.a_texto(new.diferencia_horaria_advertencia_ipad),old.diferencia_horaria_advertencia_ipad,new.diferencia_horaria_advertencia_ipad);
    END IF;    
    IF new.puedeagregarvisita IS DISTINCT FROM old.puedeagregarvisita THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','puedeagregarvisita','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.puedeagregarvisita)||'->'||comun.a_texto(new.puedeagregarvisita),old.puedeagregarvisita,new.puedeagregarvisita);
    END IF;    
    IF new.permitir_cualquier_cambio_panel_tarea IS DISTINCT FROM old.permitir_cualquier_cambio_panel_tarea THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool,new_bool)
             VALUES ('cvp','parametros','permitir_cualquier_cambio_panel_tarea','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.permitir_cualquier_cambio_panel_tarea)||'->'||comun.a_texto(new.permitir_cualquier_cambio_panel_tarea),old.permitir_cualquier_cambio_panel_tarea,new.permitir_cualquier_cambio_panel_tarea);
    END IF;    
    IF new.periodoreferenciaparapaneltarea IS DISTINCT FROM old.periodoreferenciaparapaneltarea THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','periodoreferenciaparapaneltarea','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.periodoreferenciaparapaneltarea)||'->'||comun.a_texto(new.periodoreferenciaparapaneltarea),old.periodoreferenciaparapaneltarea,new.periodoreferenciaparapaneltarea);
    END IF;    
    IF new.periodoreferenciaparapreciospositivos IS DISTINCT FROM old.periodoreferenciaparapreciospositivos THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','periodoreferenciaparapreciospositivos','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.periodoreferenciaparapreciospositivos)||'->'||comun.a_texto(new.periodoreferenciaparapreciospositivos),old.periodoreferenciaparapreciospositivos,new.periodoreferenciaparapreciospositivos);
    END IF;    
    IF new.solo_cluster IS DISTINCT FROM old.solo_cluster THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','solo_cluster','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.solo_cluster)||'->'||comun.a_texto(new.solo_cluster),old.solo_cluster,new.solo_cluster);
    END IF;    
    IF new.umbraligualdad IS DISTINCT FROM old.umbraligualdad THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','umbraligualdad','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.umbraligualdad)||'->'||comun.a_texto(new.umbraligualdad),old.umbraligualdad,new.umbraligualdad);
    END IF;    
    IF new.periodo_empalme IS DISTINCT FROM old.periodo_empalme THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','periodo_empalme','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.periodo_empalme)||'->'||comun.a_texto(new.periodo_empalme),old.periodo_empalme,new.periodo_empalme);
    END IF;    
END IF;
IF v_operacion='D' THEN  
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool)
         VALUES ('cvp','parametros','unicoregistro','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.unicoregistro),old.unicoregistro);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','nombreaplicacion','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.nombreaplicacion),old.nombreaplicacion);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','titulo','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.titulo),old.titulo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','archivologo','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.archivologo),old.archivologo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','tamannodesvpre','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.tamannodesvpre),old.tamannodesvpre);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','tamannodesvvar','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.tamannodesvvar),old.tamannodesvvar);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','codigo','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.codigo),old.codigo);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','formularionumeracionglobal','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.formularionumeracionglobal),old.formularionumeracionglobal);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','estructuraversioncommit','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.estructuraversioncommit),old.estructuraversioncommit);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','soloingresaingresador','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.soloingresaingresador),old.soloingresaingresador);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','pb_desde','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.pb_desde),old.pb_desde);          
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','pb_hasta','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.pb_hasta),old.pb_hasta);     
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','ph_desde','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.ph_desde),old.ph_desde);          
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','sup_aleat_prob1','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.sup_aleat_prob1),old.sup_aleat_prob1);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','sup_aleat_prob2','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.sup_aleat_prob2),old.sup_aleat_prob2);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','sup_aleat_prob_per','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.sup_aleat_prob_per),old.sup_aleat_prob_per);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','sup_aleat_prob_pantar','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.sup_aleat_prob_pantar),old.sup_aleat_prob_pantar);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','diferencia_horaria_tolerancia_ipad','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.diferencia_horaria_tolerancia_ipad),old.diferencia_horaria_tolerancia_ipad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','diferencia_horaria_advertencia_ipad','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.diferencia_horaria_advertencia_ipad),old.diferencia_horaria_advertencia_ipad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','puedeagregarvisita','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.puedeagregarvisita),old.puedeagregarvisita);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool)
         VALUES ('cvp','parametros','permitir_cualquier_cambio_panel_tarea','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.permitir_cualquier_cambio_panel_tarea),old.permitir_cualquier_cambio_panel_tarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','periodoreferenciaparapaneltarea','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.periodoreferenciaparapaneltarea),old.periodoreferenciaparapaneltarea);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','periodoreferenciaparapreciospositivos','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.periodoreferenciaparapreciospositivos),old.periodoreferenciaparapreciospositivos);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','solo_cluster','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.solo_cluster),old.solo_cluster);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','umbraligualdad','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.umbraligualdad),old.umbraligualdad);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','periodo_empalme','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.periodo_empalme),old.periodo_empalme);
END IF;

  IF v_operacion<>'D' THEN
    RETURN new;
  ELSE
    RETURN old;  
  END IF;
END;
$BODY$;
  
--Paso 4:
--creo la tabla para los índices empalmados
DROP TABLE IF EXISTS calgru_b1112_b21;
CREATE TABLE calgru_b1112_b21 AS SELECT periodo, calculo, agrupacion, grupo, indice, indiceredondeado FROM calgru WHERE FALSE;
ALTER TABLE calgru_b1112_b21 OWNER TO cvpowner;
ALTER TABLE calgru_b1112_b21 ADD PRIMARY KEY (periodo, calculo, agrupacion, grupo);
ALTER TABLE calgru_b1112_b21 ADD FOREIGN KEY (calculo) REFERENCES calculos_def (calculo);
ALTER TABLE calgru_b1112_b21 ADD FOREIGN KEY (agrupacion, grupo) REFERENCES grupos (agrupacion, grupo);
GRANT SELECT ON TABLE calgru_b1112_b21 TO cvp_administrador;

--paso 5:
--agrega los indices empalmados a los registros de los indices actuales:
CREATE OR REPLACE VIEW calgru_empalme AS --pk: periodo, calculo, agrupacion, grupo verificada
SELECT *
  FROM (SELECT c.periodo, c.calculo, c.agrupacion, c.grupo, c.indice, c.indiceredondeado 
	      FROM calgru c 
	      JOIN parametros p ON unicoregistro
		  JOIN calculos_def cd ON c.calculo = cd.calculo
	      WHERE cd.principal AND c.periodo > periodo_empalme
	    UNION 
	    SELECT c.periodo, c.calculo, c.agrupacion, c.grupo, c.indice, c.indiceredondeado
	      FROM calgru_b1112_b21 c 
	   ) Q;

--paso 6: 
--vista para calcular las variaciones
CREATE OR REPLACE VIEW calgru_b1112_b21_vw AS
SELECT ce.*, 
   --coalesce(c.periodoanterior, cb.periodoanterior) as periodoanterior, coalesce(c.calculoanterior, cb.calculoprincipal_b21) as calculoanterior,
   --ce_a.indice indiceanterior , ce_a.indiceredondeado indiceredondeadoanterior,
  CASE WHEN ce_a.Indiceredondeado=0 THEN NULL ELSE ROUND((ce.Indiceredondeado/ce_a.Indiceredondeado*100-100)::decimal,1) END AS variacion
  FROM calgru_empalme ce
  JOIN parametros p ON unicoregistro
  LEFT JOIN calculos c ON ce.periodo = c.periodo and ce.calculo = c.calculo and c.periodo > p.periodo_empalme
  LEFT JOIN calculos_b1112 cb ON ce.periodo = cb.periodo and ce.calculo = cb.calculoprincipal_b21 and cb.periodo <= p.periodo_empalme
  LEFT JOIN calgru_empalme ce_a ON ce_a.periodo = coalesce(c.periodoanterior, cb.periodoanterior)
             and ce_a.calculo = coalesce(c.calculoanterior, cb.calculoprincipal_b21) and ce_a.agrupacion = ce.agrupacion and ce_a.grupo = ce.grupo;

GRANT SELECT ON TABLE calgru_b1112_b21_vw TO cvp_administrador;
