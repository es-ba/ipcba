set search_path = cvp;
--para parametrizar el periodo base:
ALTER TABLE parametros ADD COLUMN pb_supnormal character varying(11); 
ALTER TABLE parametros ADD COLUMN pb_habilitado boolean; 
ALTER TABLE parametros ADD COLUMN pb_calculo integer; 

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
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_text)
         VALUES ('cvp','parametros','pb_supnormal','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.pb_supnormal),new.pb_supnormal);     
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_bool)
         VALUES ('cvp','parametros','pb_habilitado','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.pb_habilitado),new.pb_habilitado);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,new_number)
         VALUES ('cvp','parametros','pb_calculo','I',new.unicoregistro,new.unicoregistro,'I:'||comun.a_texto(new.pb_calculo),new.pb_calculo);
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
    IF new.pb_supnormal IS DISTINCT FROM old.pb_supnormal THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text,new_text)
             VALUES ('cvp','parametros','pb_supnormal','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.pb_supnormal)||'->'||comun.a_texto(new.pb_supnormal),old.pb_supnormal,new.pb_supnormal);
    END IF;
    IF new.pb_habilitado IS DISTINCT FROM old.pb_habilitado THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool,new_bool)
             VALUES ('cvp','parametros','pb_habilitado','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.pb_habilitado)||'->'||comun.a_texto(new.pb_habilitado),old.pb_habilitado,new.pb_habilitado);
    END IF;    
    IF new.pb_calculo IS DISTINCT FROM old.pb_calculo THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number,new_number)
             VALUES ('cvp','parametros','pb_calculo','U',new.unicoregistro,new.unicoregistro,comun.A_TEXTO(old.pb_calculo)||'->'||comun.a_texto(new.pb_calculo),old.pb_calculo,new.pb_calculo);
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
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_text)
         VALUES ('cvp','parametros','pb_supnormal','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.pb_supnormal),old.pb_supnormal);          
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_bool)
         VALUES ('cvp','parametros','pb_habilitado','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.pb_habilitado),old.pb_habilitado);
    INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_bool_1,change_value,old_number)
         VALUES ('cvp','parametros','pb_calculo','D',old.unicoregistro,old.unicoregistro,'D:'||comun.a_texto(old.pb_calculo),old.pb_calculo);
END IF;

  IF v_operacion<>'D' THEN
    RETURN new;
  ELSE
    RETURN old;  
  END IF;
END;
$BODY$;
--el seteo del periodoanterior y calculoanterior en calculos depende de parametros.pb_calculo
CREATE OR REPLACE FUNCTION setear_periodo_calculo_anterior_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vperiodoanterior character varying(11):= null;
  vcalculoanterior integer:= null;
  vpbCalculo integer:=(select pb_calculo from parametros where unicoregistro);
BEGIN
if NEW.calculo is distinct from vpbcalculo then
  --vperiodoanterior := null;
  SELECT periodoanterior INTO vperiodoanterior
  FROM cvp.periodos
  WHERE periodo = NEW.periodo;
  IF vperiodoanterior IS NOT NULL THEN
    SELECT calculoanterior INTO vcalculoanterior
    FROM cvp.calculos
    WHERE periodo = vperiodoanterior AND calculo = NEW.calculo;
  --ELSE
  --   vcalculoanterior = null;
  END IF;
end if;
NEW.periodoanterior:= vperiodoanterior;
NEW.calculoanterior:= vcalculoanterior;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

INSERT INTO calculos_def(
     calculo, definicion, principal, agrupacionprincipal, basado_en_extraccion_calculo, basado_en_extraccion_muestra, 
     para_rellenado_de_base, grupo_raiz, rellenante_de)
select -20 as calculo, 
      'Auxiliar para imputación hacia atrás para calcular el cambio de periodo base' as definicion, 
     principal, agrupacionprincipal, basado_en_extraccion_calculo, basado_en_extraccion_muestra, 
     para_rellenado_de_base, grupo_raiz, rellenante_de
from calculos_def
where calculo = -1;

--nuevos códigos para las funciones del periodo base
CREATE OR REPLACE FUNCTION calbase_periodos(pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vSql text;
vreglas RECORD;
agrega text;
vhayreglas boolean := false;  
BEGIN   
  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='comenzo');

  DELETE FROM calbase_prod WHERE calculo = pCalculo;
  DELETE FROM calbase_div  WHERE calculo = pCalculo;
  DELETE FROM calbase_obs  WHERE calculo = pCalculo;

  INSERT INTO CalBase_Prod (calculo, producto, mes_inicio)
    (SELECT PCalculo, producto, max(hasta)
      FROM     
          (SELECT mp.producto, mp.minperiodo, pb.hasta 
             FROM
               (SELECT producto, min(periodo) AS minperiodo
                   FROM relpre
                   WHERE precionormalizado is not null
                   GROUP BY producto) AS mp
               CROSS JOIN pb_calculos_reglas pb
               INNER JOIN Calculos_def cd ON cd.calculo=Pcalculo  --PK verificada
               INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND mp.producto = gp.producto  --PK verificada
               WHERE pb.calculo = pCalculo AND pb.tipo_regla = 'mes inicio'
                 AND (mp.minperiodo >= hasta OR valor = 'ultima')) AS I
      GROUP BY PCalculo, producto);      
  INSERT INTO CalBase_Div  (calculo, producto, division, ultimo_mes_anterior_bajas)
    SELECT pCalculo, pd.producto, pd.division, 
       (select periodo 
          from (select periodo, row_number() over (order by periodo desc) as renglon
                  from RelPre p inner join Informantes i on p.informante=i.informante
                  where p.producto=c.producto
                    and p.precioNormalizado is not null
                    and (i.tipoInformante=pd.tipoInformante or pd.sinDividir)
                  group by periodo
                  having count(*)>umbralBajaAuto
               ) x
          where renglon=r.valor::integer+1
        ) 
    FROM pb_calculos_reglas r, 
         ProdDiv pd inner join CalBase_Prod c on c.producto=pd.producto
    WHERE c.calculo=pCalculo
      AND r.tipo_regla='meses baja';

vSql := $$INSERT INTO calbase_obs (calculo, producto, informante, observacion, periodo_aparicion, periodo_anterior_baja$$;
if vhayreglas then
  vSql := vSql|| $$, incluido$$; 
end if;
vSql := vSql||$$) 
            SELECT calculo, producto, informante, observacion, periodo_aparicion, 
                   case when max_periodo_anterior <= ultimo_mes_anterior_bajas then max_periodo_anterior else null end$$;
if vhayreglas then
  vSql := vSql|| $$, incluido$$; 
end if;
vSql := vSql||$$ FROM
                (SELECT $$||pCalculo||$$ as calculo, r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas, 
                       min(case when Precionormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as periodo_aparicion,
                       max(case when PrecioNormalizado is null then null when n.producto is not null and r.periodo <= n.hasta_periodo then null else periodo end) as max_periodo_anterior                     
                   $$;

for vreglas in
   SELECT num_regla, desde, hasta, valor
     FROM pb_calculos_reglas
     WHERE calculo = Pcalculo AND tipo_regla = 'inclusion'
     ORDER BY num_regla     
Loop
   vhayreglas := true;
   if vreglas.num_regla = 1 then
      agrega := ', ';
   else
      agrega := ' OR';
   end if;
   vSql := vSql ||agrega||$$ COUNT( CASE WHEN (n.producto IS null OR (n.producto IS NOT null AND r.periodo > n.hasta_periodo))  AND periodo BETWEEN '$$||vreglas.desde||$$' AND '$$||vreglas.hasta||$$' THEN precionormalizado ELSE NULL END) >= $$ ||vreglas.valor; 
end loop;

if vhayreglas then
  vsql := vSql||$$ as incluido $$;
end if;
vsql := vSql||$$
        FROM RelPre r 
          INNER JOIN Informantes i ON r.informante=i.informante -- PK verificada
          INNER JOIN ProdDiv pd ON pd.producto=r.producto AND (pd.TipoInformante=i.TipoInformante OR pd.sinDividir) -- UK verificada
          LEFT JOIN CalBase_Div d ON d.calculo = $$||pCalculo||$$ AND r.producto = d.producto AND d.Division=pd.Division -- PK verificada
          INNER JOIN Calculos_def cd ON cd.calculo=d.calculo  --PK verificada
          INNER JOIN Gru_Prod gp ON cd.grupo_raiz = gp.grupo_padre AND r.producto = gp.producto  --PK verificada
          LEFT JOIN Novobs_Base n ON r.producto=n.producto AND r.informante=n.informante AND r.observacion=n.observacion  --PK verificada de Novobs_base
        GROUP BY r.producto, r.informante, r.observacion, ultimo_mes_anterior_bajas) as CBO;$$; 
EXECUTE vSql;

  --EXECUTE Cal_Mensajes(null, pCalculo, 'CalBase_Periodos', pTipo:='finalizo');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cvp.periodobase(
    psolopreparar_nocalcular boolean DEFAULT false)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
declare
  vEmpezo     time;  
  vTermino    time;  
  vPeriodoLimiteInfPrehistoria text/*:='a2010m01'*/;
  vPeriodoLimiteInfBase text       /*:='a2011m07'*/;
  vPeriodoLimiteSupBase text       /*:='a2012m06'*/;
  vPeriodoLimiteSupNormal text     /*:='a2012m08'*/;
  vCorridoProp boolean:=false;
  vMaxPasos integer:=99;
  vPeriodo text;
  vPrimerPeriodo text:=(select min(periodo) from periodos);
  vpbCalculo integer:=(select pb_calculo from parametros where unicoregistro);
  vCalculo integer;
  vPeriodo_1 text;
  vCalculo_1 integer;
  vDummy text;
  vMaxLoop integer;
  vParaBorrarCalculo record;
  cParaBorrarCalculo cursor for
    select * 
      from Calculos, parametros 
      where unicoregistro and calculo in (0,vpbCalculo) and periodo between ph_desde and pb_supnormal
      order by case when calculo=0 then periodo else null end,
               case when calculo=vpbCalculo then periodo else null end desc;      
begin
  vEmpezo:=clock_timestamp(); 
  set search_path = cvp, comun, public;
  select ph_desde, pb_desde, pb_hasta, pb_supnormal
    into vPeriodoLimiteInfPrehistoria, vPeriodoLimiteInfBase, vPeriodoLimiteSupBase, vPeriodoLimiteSupNormal 
    from parametros
    where unicoregistro;
  for vParaBorrarCalculo in cParaBorrarCalculo loop
    execute Calculo_Borrar(vParaBorrarCalculo.periodo,vParaBorrarCalculo.calculo);
    DELETE FROM calprodresp      WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
    --DELETE FROM calhoggru        WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
    --DELETE FROM calhogsubtotales WHERE periodo = vParaBorrarCalculo.periodo and calculo = vParaBorrarCalculo.calculo;
  end loop;
  /* usamos los registros de la tabla calculo sin borrarlos:{
  update Calculos set periodoAnterior=null, calculoAnterior=null
    where (calculo in (0,vpbCalculo) or calculo > 0) and periodo >= vPeriodoLimiteInfPrehistoria;
  delete from Calculos where calculo in (0,vpbCalculo) and periodo >= vPeriodoLimiteInfPrehistoria;
  }*/
  delete from calculos 
    where calculo in (select pb_calculo from parametros where unicoregistro);

  if true then
    DELETE FROM pb_calculos_reglas;
    /* Por ahora, sin reglas {
    INSERT INTO pb_calculos_reglas (
    calculo,tipo_regla,num_regla,desde,hasta,valor
    ) VALUES (
    '0','mes inicio','1',null,'a2011m07','estricta'
    ),(
    '0','mes inicio','2',null,'a2010m01','ultima'
    ),(
    '0','inclusion','1','a2012m06','a2012m07','2'
    ),(
    '0','inclusion','2','a2012m05','a2012m06','2'
    ),(
    '0','inclusion','3','a2012m01','a2012m05','3'
    ),(
    '0','inclusion','4','a2010m01','a2012m05','6'
    ),(
    '0','meses baja','1',null,'a2012m07','3'
    );
    }*/
  end if;
  execute CalBase_Periodos(0);
  vPeriodo:=vPeriodoLimiteSupBase;
  vCalculo:=vpbCalculo;
  vPeriodo_1:=vPeriodo;
  vCalculo_1:=vCalculo;
  loop
    if (vPeriodo>vPeriodoLimiteSupBase or vPeriodo is null) and not vCorridoProp then
      execute Cal_PerBase_Prop(0,vPeriodoLimiteInfBase,vPeriodoLimiteSupBase);
      vCorridoProp:=true;
    end if;
  exit when vmaxPasos=0 or vCalculo=0 and vPeriodo>vPeriodoLimiteSupNormal;
     /* updateamos en lugar de borrar e insertar en calculos: {
     insert into Calculos (periodo , calculo , periodoAnterior, calculoAnterior, abierto, 
                          esPeriodoBase, pb_calculobase
                          )
      values             (vPeriodo, vCalculo, vPeriodo_1     , vCalculo_1     ,  'S'   , 
                          case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                          case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
                          );
    }*/
    raise notice 'vPeriodo: %    vcalculo: %     vPeriodo_1: %       vcalculo_1: %', vPeriodo, vcalculo, vperiodo_1, vcalculo_1;
    if vCalculo = vpbCalculo then
        insert into Calculos (periodo , calculo , periodoAnterior, calculoAnterior, abierto, 
                             esPeriodoBase, pb_calculobase
                             )
         values             (vPeriodo, vCalculo, vPeriodo_1     , vCalculo_1     ,  'S'   , 
                             case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                             case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
                             );
    else
       UPDATE calculos set periodoAnterior = vPeriodo_1, 
                            calculoAnterior = vCalculo_1, 
                                 abierto = 'S', 
                                 esPeriodoBase = case when vPeriodo>vPeriodoLimiteSupBase then 'N' else 'S' end, 
                                 pb_calculobase = case when vPeriodo<=vPeriodoLimiteSupBase and vCalculo=0 then -1 else null end
          WHERE periodo = vPeriodo AND  calculo = vCalculo;
     end if;
     if not pSoloPreparar_NoCalcular then
      select CalcularUnPeriodo(vPeriodo, vCalculo)
        into vDummy;
    end if;
    vMaxPasos:=vMaxPasos-1;
    vPeriodo_1:=vPeriodo;
    vCalculo_1:=vCalculo;
    if vCalculo=vpbCalculo then
      select periodoAnterior into vPeriodo
        from Periodos
        where periodo=vPeriodo;
      if vPeriodo is null or vPeriodo<vPeriodoLimiteInfPrehistoria then
        vPeriodo:=vPeriodo_1;
        vCalculo:=0;
      end if;
    else
      select periodo into vPeriodo 
        from Periodos
        where periodoAnterior=vPeriodo;
      if vPeriodo is null then
        vMaxPasos:=0; -- Fin
      end if;
    end if;
  end loop;
  vTermino:=clock_timestamp();  
  Raise Notice '%', 'PERIODO BASE: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);  
  return 'Periodo base finalizado'||(vTermino - vEmpezo);
exception
  when others then
    execute Cal_Mensajes(coalesce(vPeriodo,vPrimerPeriodo), coalesce(vCalculo,0), 'PeriodoBase', 'error', pMensaje:='ERROR DE EJECUCION ' || sqlstate || ': ' || sqlerrm);
    raise;
    RETURN 'Ejecuto con error ' || sqlstate || ': ' || sqlerrm;
end;
$BODY$;

/*
--parametros para el periodo base actual (-1) (en BD producción):{
UPDATE parametros SET pb_supnormal = 'a2012m08' WHERE unicoregistro;
UPDATE parametros SET pb_habilitado = false WHERE unicoregistro;
UPDATE parametros SET pb_calculo = -1 WHERE unicoregistro;
--}
--parametros para el periodo base actual (-20) (en BD cambio_base_db):{
update parametros set 
pb_supnormal = 'a2021m08',  --el último periodo abierto, hasta donde va a llegar al calcular
pb_habilitado = true,       --habilitar la ejecución
pb_desde = 'a2021m01',      --primer periodo del periodo base
pb_hasta = 'a2021m04',      --último periodo del periodo base
ph_desde = 'a2020m09',       --primer periodo de la historia, hasta dónde va a llegar la corrida hacia atrás
pb_calculo = -20            --código asignado al calculo del nuevo periodo base (hacia atrás, antes -1)
where unicoregistro;

--resguardo de las tablas calbase....
CREATE TABLE calbase_div_bkp AS SELECT * FROM calbase_div;
CREATE TABLE calbase_obs_bkp AS SELECT * FROM calbase_obs;
CREATE TABLE calbase_prod_bkp AS SELECT * FROM calbase_prod;
--abrir los calculos:
update calculos set abierto ='S' where periodo = 'a2021m07' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m06' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m05' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m04' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m03' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m02' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2021m01' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2020m12' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2020m11' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2020m10' and calculo = 0;
update calculos set abierto ='S' where periodo = 'a2020m09' and calculo = 0;
--}
*/
