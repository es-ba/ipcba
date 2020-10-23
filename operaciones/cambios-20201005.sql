set search_path = cvp;
alter table parametros add column solo_cluster integer;
alter table grupos add column "cluster" integer;

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
END IF;

  IF v_operacion<>'D' THEN
    RETURN new;
  ELSE
    RETURN old;  
  END IF;
END;
$BODY$;

CREATE OR REPLACE FUNCTION hisc_grupos_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
  DECLARE
    v_operacion text:=substr(TG_OP,1,1);
  BEGIN
    
  IF v_operacion='I' THEN  
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','agrupacion','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.agrupacion),new.agrupacion);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','grupo','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.grupo),new.grupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','nombregrupo','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.nombregrupo),new.nombregrupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','grupopadre','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.grupopadre),new.grupopadre);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_number)
                 VALUES ('cvp','grupos','ponderador','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.ponderador),new.ponderador);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_number)
                 VALUES ('cvp','grupos','nivel','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.nivel),new.nivel);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','esproducto','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.esproducto),new.esproducto);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','modi_usu','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_datetime)
                 VALUES ('cvp','grupos','modi_fec','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','modi_ope','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','nombrecanasta','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.nombrecanasta),new.nombrecanasta);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','agrupacionorigen','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.agrupacionorigen),new.agrupacionorigen);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','detallarcanasta','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.detallarcanasta),new.detallarcanasta);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','explicaciongrupo','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.explicaciongrupo),new.explicaciongrupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_text)
                 VALUES ('cvp','grupos','responsable','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new.responsable),new.responsable);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,new_number)
                 VALUES ('cvp','grupos','cluster','I',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,'I:'||comun.a_texto(new."cluster"),new."cluster");
  END IF;
  IF v_operacion='U' THEN     
        IF new.agrupacion IS DISTINCT FROM old.agrupacion THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','agrupacion','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.agrupacion)||'->'||comun.a_texto(new.agrupacion),old.agrupacion,new.agrupacion);
        END IF;    
        IF new.grupo IS DISTINCT FROM old.grupo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','grupo','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.grupo)||'->'||comun.a_texto(new.grupo),old.grupo,new.grupo);
        END IF;    
        IF new.nombregrupo IS DISTINCT FROM old.nombregrupo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','nombregrupo','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.nombregrupo)||'->'||comun.a_texto(new.nombregrupo),old.nombregrupo,new.nombregrupo);
        END IF;    
        IF new.grupopadre IS DISTINCT FROM old.grupopadre THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','grupopadre','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.grupopadre)||'->'||comun.a_texto(new.grupopadre),old.grupopadre,new.grupopadre);
        END IF;    
        IF new.ponderador IS DISTINCT FROM old.ponderador THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number,new_number)
                 VALUES ('cvp','grupos','ponderador','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.ponderador)||'->'||comun.a_texto(new.ponderador),old.ponderador,new.ponderador);
        END IF;    
        IF new.nivel IS DISTINCT FROM old.nivel THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number,new_number)
                 VALUES ('cvp','grupos','nivel','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.nivel)||'->'||comun.a_texto(new.nivel),old.nivel,new.nivel);
        END IF;    
        IF new.esproducto IS DISTINCT FROM old.esproducto THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','esproducto','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.esproducto)||'->'||comun.a_texto(new.esproducto),old.esproducto,new.esproducto);
        END IF;    
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','modi_usu','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','grupos','modi_fec','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','modi_ope','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.nombrecanasta IS DISTINCT FROM old.nombrecanasta THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','nombrecanasta','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.nombrecanasta)||'->'||comun.a_texto(new.nombrecanasta),old.nombrecanasta,new.nombrecanasta);
        END IF;
        IF new.agrupacionorigen IS DISTINCT FROM old.agrupacionorigen THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','agrupacionorigen','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.agrupacionorigen)||'->'||comun.a_texto(new.agrupacionorigen),old.agrupacionorigen,new.agrupacionorigen);
        END IF;    
        IF new.detallarcanasta IS DISTINCT FROM old.detallarcanasta THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','detallarcanasta','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.detallarcanasta)||'->'||comun.a_texto(new.detallarcanasta),old.detallarcanasta,new.detallarcanasta);
        END IF;    
        IF new.explicaciongrupo IS DISTINCT FROM old.explicaciongrupo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','explicaciongrupo','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.explicaciongrupo)||'->'||comun.a_texto(new.explicaciongrupo),old.explicaciongrupo,new.explicaciongrupo);
        END IF;    
        IF new.responsable IS DISTINCT FROM old.responsable THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text,new_text)
                 VALUES ('cvp','grupos','responsable','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old.responsable)||'->'||comun.a_texto(new.responsable),old.responsable,new.responsable);
        END IF;    
        IF new."cluster" IS DISTINCT FROM old."cluster" THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number,new_number)
                 VALUES ('cvp','grupos','cluster','U',new.agrupacion||'|'||new.grupo,new.agrupacion,new.grupo,comun.A_TEXTO(old."cluster")||'->'||comun.a_texto(new."cluster"),old."cluster",new."cluster");
        END IF;    
  END IF;
  IF v_operacion='D' THEN 
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','agrupacion','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.agrupacion),old.agrupacion);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','grupo','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.grupo),old.grupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','nombregrupo','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.nombregrupo),old.nombregrupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','grupopadre','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.grupopadre),old.grupopadre);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number)
                 VALUES ('cvp','grupos','ponderador','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.ponderador),old.ponderador);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number)
                 VALUES ('cvp','grupos','nivel','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.nivel),old.nivel);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','esproducto','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.esproducto),old.esproducto);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','modi_usu','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_datetime)
                 VALUES ('cvp','grupos','modi_fec','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','modi_ope','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','nombrecanasta','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.nombrecanasta),old.nombrecanasta);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','agrupacionorigen','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.agrupacionorigen),old.agrupacionorigen);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','detallarcanasta','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.detallarcanasta),old.detallarcanasta);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','explicaciongrupo','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.explicaciongrupo),old.explicaciongrupo);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_text)
                 VALUES ('cvp','grupos','responsable','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old.responsable),old.responsable);
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,change_value,old_number)
                 VALUES ('cvp','grupos','cluster','D',old.agrupacion||'|'||old.grupo,old.agrupacion,old.grupo,'D:'||comun.a_texto(old."cluster"),old."cluster");
  END IF;
  
    IF v_operacion<>'D' THEN
      RETURN new;
    ELSE
      RETURN old;  
    END IF;
  END;
$BODY$;

CREATE OR REPLACE VIEW calgru_vw AS
select c.periodo, c.calculo, c.agrupacion, c.grupo
       , COALESCE(g.nombregrupo,p.nombreproducto) AS nombre 
       , c.variacion, c.impgru, c.grupopadre, c.nivel, c.esproducto, c.ponderador, c.indice, c.indiceprel
       , c.incidencia, c.indiceredondeado, c.incidenciaredondeada
       , (c.indice - cb.indice) * c.ponderador / pb.indice * 100 as incidenciainteranual --con todos los decimales
       , case when c.nivel = 0 then
               round(((round(c.indice::decimal,2) - round(cb.indice::decimal,2)) * c.ponderador / round(pb.indice::decimal,2) * 100)::decimal,1) -- a un decimal para nivel 0
              when c.nivel = 1 then
               round(((round(c.indice::decimal,2) - round(cb.indice::decimal,2)) * c.ponderador / round(pb.indice::decimal,2) * 100)::decimal,2) -- a dos decimales para nivel 1
              else null
       end as incidenciainteranualredondeada
       , (c.indice - ca.indice) * c.ponderador / pa.indice * 100 as incidenciaacumuladaanual --con todos los decimales
       , round( 
       case when (c.nivel in (0,1) ) then
              (round(c.indice::decimal,2) - round(ca.indice::decimal,2)) * c.ponderador / round(pa.indice::decimal,2) * 100
            else null
       end::decimal,2)::double precision as incidenciaacumuladaanualredondeada  -- a dos decimales para niveles 0 y 1
       , CASE WHEN cb.IndiceRedondeado=0 THEN null ELSE round((c.IndiceRedondeado::decimal/cb.IndiceRedondeado::decimal*100-100)::numeric,1) END as variacioninteranualredondeada
       , CASE WHEN cb.Indice=0 THEN null ELSE (c.Indice::decimal/cb.Indice::decimal*100-100)::decimal END as variacioninteranual
       , CASE WHEN c_3.Indice=0 THEN null ELSE (c.Indice::decimal/c_3.Indice::decimal*100-100) END as variaciontrimestral
       , CASE WHEN ca.indiceRedondeado=0 THEN null ELSE round((c.indiceRedondeado/ca.indiceRedondeado*100-100)::numeric,1) END as variacionacumuladaanualredondeada
       , CASE WHEN ca.indice=0 THEN null ELSE c.indice/ca.indice*100-100 END as variacionacumuladaanual,
       c.ponderadorimplicito, 'Z'||substr(c.grupo,2) as ordenpor,
       CASE WHEN gg.grupo IS NOT NULL THEN TRUE ELSE FALSE END AS publicado, pr.responsable, coalesce(g."cluster", p."cluster") as "cluster"
   from calgru c
     left join calgru cb on  cb.agrupacion=c.agrupacion and cb.grupo=c.grupo and ((c.calculo=0 and cb.calculo=c.calculo) or (c.calculo>0 and cb.calculo=0))  
                         and cb.periodo =periodo_igual_mes_anno_anterior(c.periodo)
     left join calgru c_3 on c_3.agrupacion=c.agrupacion and c_3.grupo=c.grupo and ((c.calculo=0 and c_3.calculo=c.calculo) or (c.calculo>0 and c_3.calculo=0)) 
                          and c_3.periodo =moverperiodos(c.periodo,-3) --pk verificada
     left join calgru pb on  ((c.calculo=0 and pb.calculo=c.calculo) or (c.calculo>0 and pb.calculo=0)) AND pb.agrupacion=c.agrupacion  AND pb.periodo=periodo_igual_mes_anno_anterior(c.periodo) 
                         AND  pb.nivel = 0
     left join calgru pa on  ((c.calculo=0 and pa.calculo=c.calculo) or (c.calculo>0 and pa.calculo=0)) AND pa.agrupacion=c.agrupacion  AND 
                             pa.periodo=(('a' || (substr(c.periodo, 2, 4)::integer - 1)) ||'m12') AND  pa.nivel = 0
     left join calgru ca on ca.agrupacion=c.agrupacion AND ca.grupo=c.grupo AND ((c.calculo=0 and ca.calculo=c.calculo) or (c.calculo>0 and ca.calculo=0)) 
                         AND ca.periodo =(('a' || (substr(c.periodo, 2, 4)::integer - 1)) ||'m12')
     inner join agrupaciones a on  a.agrupacion=c.agrupacion
     LEFT JOIN grupos g on c.agrupacion = g.agrupacion and c.grupo = g.grupo --pk verificada    
     LEFT JOIN productos p on c.grupo = p.producto --pk verificada
     LEFT JOIN (SELECT grupo FROM gru_grupos WHERE agrupacion = 'C' and grupo_padre in ('C1','C2') and esproducto = 'S') gg ON c.grupo = gg.grupo     
     LEFT JOIN cvp.calProdResp pr on c.periodo = pr.periodo and c.calculo = pr.calculo and c.grupo = pr.producto
  where 
     a.tipo_agrupacion='INDICE';

CREATE OR REPLACE VIEW precios_porcentaje_positivos_y_anulados as
select v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario as formulario, count(*) preciospotenciales,
sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivos, sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END) as anulados,
((sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END)+sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END))*100/count(*))::text||'%' as porcentaje,
sum(a.atributospotenciales) atributospotenciales, sum(a.atributospositivos) atributospositivos, 
CASE WHEN sum(a.atributospotenciales)>0 THEN round((sum(a.atributospositivos)/sum(a.atributospotenciales)*100))::text||'%' ELSE '0%' END as porcatributos, 
i.rubro||':'||u.nombrerubro as rubro, v.encuestador, per.nombre||' '||per.apellido as encuestadornombre, coalesce(par.solo_cluster,pp."cluster") as "cluster"
from cvp.relvis v
  inner join cvp.relpre r on v.periodo = r.periodo and v.informante = r.informante and v.formulario = r.formulario and v.visita = r.visita
  inner join cvp.productos pp on r.producto = pp.producto
  inner join cvp.parametros par on unicoregistro
  left join cvp.personal per on v.encuestador = per.persona
  left join cvp.tareas ta on v.tarea = ta.tarea
  left join cvp.formularios f on v.formulario = f.formulario   
  left join cvp.tipopre t on r.tipoprecio = t.tipoprecio
  left join cvp.informantes i on v.informante = i.informante
  left join cvp.rubros u on i.rubro = u.rubro,
  lateral (select pro.producto, count(distinct pa.atributo) atributospotenciales, CASE WHEN t.espositivo = 'S' THEN count(distinct pa.atributo) ELSE 0 END as atributospositivos
           from cvp.productos pro left join cvp.prodatr pa on pro.producto = pa.producto
           where r.producto = pro.producto
           group by pro.producto) a
group by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario, i.rubro||':'||u.nombrerubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(par.solo_cluster,pp."cluster")
order by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario||':'||f.nombreformulario, i.rubro||':'||u.nombrerubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(par.solo_cluster,pp."cluster");

GRANT update ON TABLE parametros TO cvp_administrador;

--optimizacion de la vista control_rangos:
CREATE OR REPLACE VIEW control_rangos as
select periodo, producto, nombreproducto, informante, tipoinformante, observacion, visita, panel, tarea, encuestador, recepcionista, nombrerecep, 
   formulario, precionormalizado, comentariosrelpre, observaciones, tipoprecio, cambio, impobs, precioant, tipoprecioant, antiguedadsinprecioant, 
   variac, promvar, desvvar, promrotativo, desvprot, razon_impobs_ant, repregunta
   from (select v.periodo,
           v.producto,
           p.nombreproducto,
           v.informante,
           i.tipoinformante,
           v.observacion,
           v.visita,
           vi.panel,
           vi.tarea,
           (vi.encuestador || ':') || pe.apellido AS encuestador,
           vi.recepcionista,
           pc.apellido AS nombrerecep,
           v.formulario,
           v.precionormalizado,
           v.comentariosrelpre,
           v.observaciones,
           v.tipoprecio,
           v.cambio,
           c2.impobs,
           COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
           v.tipoprecio_1 AS tipoprecioant,
           co.antiguedadsinprecio AS antiguedadsinprecioant,
           v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100 AS variac,
           avg   (v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as promvar,
           stddev(v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs) * 100 - 100) over (partition by v.periodo, v.producto)  as desvvar,
           avgprot.promrotativo,
           avgprot.desvprot,
           (vi2.razon::text || ':'::text) || COALESCE(co.impobs, ' '::character varying)::text AS razon_impobs_ant,
           CASE WHEN pr.periodo IS NOT NULL THEN 'R'
           ELSE NULL
           END AS repregunta,
           tamannodesvvar,
           tamannodesvpre
           FROM cvp.relpre_1 v
           LEFT JOIN cvp.calobs co ON co.periodo = v.periodo_1 AND co.calculo = 0 AND co.producto = v.producto AND co.informante = v.informante AND co.observacion = v.observacion
                JOIN cvp.productos p on v.producto = p.producto
                JOIN cvp.informantes i on v.informante = i.informante
                JOIN cvp.relvis vi on v.periodo = vi.periodo and v.informante = vi.informante and v.visita = vi.visita and v.formulario = vi.formulario 
                LEFT JOIN cvp.personal pe on vi.encuestador = pe.persona
                LEFT JOIN cvp.personal pc on vi.recepcionista = pc.persona
                LEFT JOIN cvp.calobs c2 ON c2.periodo::text = v.periodo::text AND c2.calculo = 0 AND c2.producto::text = v.producto::text AND c2.informante = v.informante AND c2.observacion = v.observacion
                JOIN cvp.panel_promrotativo avgprot ON v.periodo = avgprot.periodo AND v.producto = avgprot.producto
                JOIN cvp.parametros ON parametros.unicoregistro = true
                LEFT JOIN cvp.prerep pr ON v.periodo = pr.periodo AND v.informante = pr.informante AND v.producto = pr.producto
                LEFT JOIN cvp.relvis vi2 ON v.informante = vi2.informante AND v.periodo_1 = vi2.periodo AND v.visita = vi2.visita AND v.formulario = vi2.formulario
        ) Q
WHERE ((precionormalizado / precioant * 100 - 100) > (promvar + tamannodesvvar * desvvar) OR 
       (precionormalizado / precioant * 100 - 100) IS DISTINCT FROM 0 AND 
       (precionormalizado / precioant * 100 - 100) < (promvar - tamannodesvvar * desvvar) OR 
       precionormalizado > (promrotativo + tamannodesvpre * desvprot) OR 
       precionormalizado < (promrotativo - tamannodesvpre * desvprot)
      );
	  
CREATE OR REPLACE VIEW cvp.freccambio_nivel0 AS
SELECT distinct cvp.devolver_mes_anio(periodo) Periodonombre, 
    periodo, 
    substr(x.grupo,1,2) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster")/ COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT o.periodo, g.grupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
            WHEN o.promobs > o1.promobs THEN 'Subió' 
            ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 ON o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg ON o.producto = gg.grupo
        LEFT JOIN cvp.grupos g ON gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p ON o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE o.calculo = 0 AND g.agrupacion = 'Z' AND g.nivel = 0 AND o.impobs = 'R' AND o1.impobs = 'R'
        --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo not in 
        ('Z0411',
        'Z0431',
        'Z0432',
        'Z0441',
        'Z0442',
        'Z0533',
        'Z0551',
        'Z0552',
        'Z0562',
        'Z0611',
        'Z0621',
        'Z0622',
        'Z0623',
        'Z0711',
        'Z0721',
        'Z0722',
        'Z0723',
        'Z0811',
        'Z0821',
        'Z0822',
        'Z0831',
        'Z0832',
        'Z0833',
        'Z0912',
        'Z0914',
        'Z0915',
        'Z0923',
        'Z0942',
        'Z0951',
        'Z1012',
        'Z1121',
        'Z1212',
        'Z1261'
        )
      ) as x
      LEFT JOIN cvp.grupos u ON substr(x.grupo,1,2) = u.grupo  
    WHERE cantobs > 6 and periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;

CREATE OR REPLACE VIEW cvp.frecCambio_Nivel1 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    substr(x.grupo,1,3) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster") AS cantobsporgrupo, 
    ROUND(COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster")/COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster")::decimal*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
            WHEN o.promobs > o1.promobs THEN 'Subió' 
            ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg on o.producto = gg.grupo
        LEFT JOIN cvp.grupos g on gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p on o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE o.calculo = 0 AND  g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs = 'R' AND o1.impobs = 'R'
        --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo not in 
        ('Z0411',
         'Z0431',
         'Z0432',
         'Z0441',
         'Z0442',
         'Z0533',
         'Z0551',
         'Z0552',
         'Z0562',
         'Z0611',
         'Z0621',
         'Z0622',
         'Z0623',
         'Z0711',
         'Z0721',
         'Z0722',
         'Z0723',
         'Z0811',
         'Z0821',
         'Z0822',
         'Z0831',
         'Z0832',
         'Z0833',
         'Z0912',
         'Z0914',
         'Z0915',
         'Z0923',
         'Z0942',
         'Z0951',
         'Z1012',
         'Z1121',
         'Z1212',
         'Z1261'
        )  
      ) as x
    LEFT JOIN cvp.grupos u ON substr(x.grupo,1,3) = u.grupo
    WHERE cantobs > 6 and periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;

CREATE OR REPLACE VIEW cvp.frecCambio_Nivel3 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
    COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, g.nombregrupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
             WHEN o.promobs > o1.promobs THEN 'Subió' 
        ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg on o.producto = gg.grupo
        LEFT JOIN cvp.grupos g on gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p on o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE /*o.periodo >= 'a2012m07' AND o.periodo <= 'a2017m09' AND */ 
        o.calculo = 0 AND g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs = 'R' AND o1.impobs = 'R'
          --A Pedido de Mariana excluimos los siguientes grupos:
        AND g.grupo NOT IN 
          ('Z0411',
           'Z0431',
           'Z0432',
           'Z0441',
           'Z0442',
           'Z0533',
           'Z0551',
           'Z0552',
           'Z0562',
           'Z0611',
           'Z0621',
           'Z0622',
           'Z0623',
           'Z0711',
           'Z0721',
           'Z0722',
           'Z0723',
           'Z0811',
           'Z0821',
           'Z0822',
           'Z0831',
           'Z0832',
           'Z0833',
           'Z0912',
           'Z0914',
           'Z0915',
           'Z0923',
           'Z0942',
           'Z0951',
           'Z1012',
           'Z1121',
           'Z1212',
           'Z1261'
          )
     ) AS X
WHERE cantobs > 6 and periodo >= 'a2017m01'
ORDER BY "cluster", periodo, grupo, nombregrupo, estado;

CREATE OR REPLACE VIEW frecCambio_resto AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, periodo, grupo, nombregrupo, estado, 
EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
round((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
, x."cluster"
FROM (

SELECT
  o.periodo, g.grupo, g.nombregrupo, 
  CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
       WHEN o.promobs > o1.promobs THEN 'Subió' 
       ELSE 'Igual' 
       END as estado,
  o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
  COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs,
  coalesce(par.solo_cluster, p."cluster") as "cluster",
  gg.grupo_padre
  FROM cvp.calobs o
    LEFT JOIN cvp.calculos c ON o.periodo = c.periodo and o.calculo = c.calculo
    LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior and o1.calculo = c.calculoanterior and 
      o.producto = o1.producto and o.informante = o1.informante and o.observacion = o1.observacion
    LEFT JOIN cvp.productos p on o.producto = p.producto
    LEFT JOIN cvp.gru_grupos gu on gu.agrupacion = 'R' and gu.esproducto = 'S' and gu.grupo = o.producto and length(gu.grupo_padre) = 2
    LEFT JOIN cvp.grupos g on gu.grupo_padre = g.grupo and gu.agrupacion = g.agrupacion
    LEFT JOIN cvp.gru_grupos gg on gg.agrupacion = 'Z' and gg.esproducto = 'S' and gg.grupo = o.producto and length(gg.grupo_padre) = 5  --los niveles 3 para poder excluirlos
    LEFT JOIN cvp.parametros par ON unicoregistro
WHERE o.calculo = 0 and g.grupo ='R3' and o.impobs = 'R' and o1.impobs = 'R'
  --Excluimos los siguientes grupos:
  and gg.grupo_padre not in 
  ('Z0411',
   'Z0431',
   'Z0432',
   'Z0441',
   'Z0442',
   'Z0533',
   'Z0551',
   'Z0552',
   'Z0562',
   'Z0611',
   'Z0621',
   'Z0622',
   'Z0623',
   'Z0711',
   'Z0721',
   'Z0722',
   'Z0723',
   'Z0811',
   'Z0821',
   'Z0822',
   'Z0831',
   'Z0832',
   'Z0833',
   'Z0912',
   'Z0914',
   'Z0915',
   'Z0923',
   'Z0942',
   'Z0951',
   'Z1012',
   'Z1121',
   'Z1212',
   'Z1261'
  )
  ) as X
WHERE cantobs > 6 and periodo >= 'a2017m01'
order by "cluster", periodo, grupo, nombregrupo, estado;

CREATE OR REPLACE VIEW cvp.frecCambio_restorest AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, periodo, grupo, nombregrupo, estado, 
EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/
EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
round((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
, x."cluster"
FROM (

SELECT
  o.periodo, g.grupo, g.nombregrupo, 
  CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
       WHEN o.promobs > o1.promobs THEN 'Subió' 
       ELSE 'Igual' 
       END as estado,
  o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
  COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs,
  coalesce(par.solo_cluster, p."cluster") as "cluster",
  gg.grupo_padre
  FROM cvp.calobs o
    LEFT JOIN cvp.calculos c ON o.periodo = c.periodo and o.calculo = c.calculo
    LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior and o1.calculo = c.calculoanterior and 
      o.producto = o1.producto and o.informante = o1.informante and o.observacion = o1.observacion
    LEFT JOIN cvp.productos p on o.producto = p.producto
    LEFT JOIN cvp.gru_grupos gu on gu.agrupacion = 'R' and gu.esproducto = 'S' and gu.grupo = o.producto and length(gu.grupo_padre) = 2
    LEFT JOIN cvp.grupos g on gu.grupo_padre = g.grupo and gu.agrupacion = g.agrupacion
    LEFT JOIN cvp.gru_grupos gg on gg.agrupacion = 'Z' and gg.esproducto = 'S' and gg.grupo = o.producto and length(gg.grupo_padre) = 5  --los niveles 3 para poder excluirlos
    LEFT JOIN cvp.parametros par ON unicoregistro
  WHERE o.calculo = 0 and g.grupo ='R3' and o.impobs = 'R' and o1.impobs = 'R'
  --A Pedido de Mariana excluimos los siguientes grupos:
  and gg.grupo_padre not in 
  ('Z0411',
   'Z0431',
   'Z0432',
   'Z0441',
   'Z0442',
   'Z0533',
   'Z0551',
   'Z0552',
   'Z0562',
   'Z0611',
   'Z0621',
   'Z0622',
   'Z0623',
   'Z0711',
   'Z0721',
   'Z0722',
   'Z0723',
   'Z0811',
   'Z0821',
   'Z0822',
   'Z0831',
   'Z0832',
   'Z0833',
   'Z0912',
   'Z0914',
   'Z0915',
   'Z0923',
   'Z0942',
   'Z0951',
   'Z1012',
   'Z1121',
   'Z1212',
   'Z1261',
   'Z0631',
   'Z1011'
  )
  ) as X
WHERE cantobs > 6 and periodo >= 'a2017m01'
order by "cluster", periodo, grupo, nombregrupo, estado;
