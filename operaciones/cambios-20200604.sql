set search_path = cvp;

ALTER TABLE novprod ADD COLUMN tipoexterno character varying(1);
ALTER TABLE novprod ADD CONSTRAINT "TipoexternoNovProd: D(Definitivo) o P(Provisorio)" CHECK (tipoexterno::text = ANY (ARRAY['P'::character varying::text, 'D'::character varying::text]));

ALTER TABLE his.novprod ADD COLUMN tipoexterno character varying(1);


CREATE OR REPLACE FUNCTION hisc_novprod_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','NovProd','periodo','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.periodo),new.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','NovProd','calculo','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.calculo),new.calculo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','NovProd','producto','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.producto),new.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','NovProd','promedioext','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.promedioext),new.promedioext);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','NovProd','modi_usu','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
                     VALUES ('cvp','NovProd','modi_fec','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','NovProd','modi_ope','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
                     VALUES ('cvp','NovProd','variacion','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.variacion),new.variacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
                     VALUES ('cvp','NovProd','tipoexterno','I',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,'I:'||comun.a_texto(new.tipoexterno),new.tipoexterno);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.periodo IS DISTINCT FROM old.periodo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','NovProd','periodo','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
            END IF;    
            IF new.calculo IS DISTINCT FROM old.calculo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','NovProd','calculo','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.calculo)||'->'||comun.a_texto(new.calculo),old.calculo,new.calculo);
            END IF;    
            IF new.producto IS DISTINCT FROM old.producto THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','NovProd','producto','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
            END IF;    
            IF new.promedioext IS DISTINCT FROM old.promedioext THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','NovProd','promedioext','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.promedioext)||'->'||comun.a_texto(new.promedioext),old.promedioext,new.promedioext);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','NovProd','modi_usu','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','NovProd','modi_fec','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','NovProd','modi_ope','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;
            IF new.variacion IS DISTINCT FROM old.variacion THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                     VALUES ('cvp','NovProd','variacion','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.variacion)||'->'||comun.a_texto(new.variacion),old.variacion,new.variacion);
            END IF;    
            IF new.tipoexterno IS DISTINCT FROM old.tipoexterno THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                     VALUES ('cvp','NovProd','tipoexterno','U',new.periodo||'|'||new.calculo||'|'||new.producto,new.periodo,new.calculo,new.producto,comun.A_TEXTO(old.tipoexterno)||'->'||comun.a_texto(new.tipoexterno),old.tipoexterno,new.tipoexterno);
            END IF;
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','NovProd','periodo','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.periodo),old.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
                     VALUES ('cvp','NovProd','calculo','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.calculo),old.calculo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','NovProd','producto','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.producto),old.producto);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
                     VALUES ('cvp','NovProd','promedioext','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.promedioext),old.promedioext);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','NovProd','modi_usu','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
                     VALUES ('cvp','NovProd','modi_fec','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','NovProd','modi_ope','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
                     VALUES ('cvp','NovProd','variacion','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.variacion),old.variacion);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
                     VALUES ('cvp','NovProd','tipoexterno','D',old.periodo||'|'||old.calculo||'|'||old.producto,old.periodo,old.calculo,old.producto,'D:'||comun.a_texto(old.tipoexterno),old.tipoexterno);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;


CREATE OR REPLACE FUNCTION validar_abrir_cerrar_calculo_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
  vPeriodo_1  text;  
  vCalculo_1  integer;
  vAbierto_1  character varying(1);
  vIngresando character varying(1); 
  vrecsig     record;
  vesadministrador integer;
  vescoordinacion integer;
  vhayprovisorios integer;
  vNOestantodosextdef integer;
  vestimacion integer;

BEGIN

SELECT 1 INTO vesadministrador
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_administrador' ; 
SELECT 1 INTO vescoordinacion
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_coordinacion' ;    

IF OLD.abierto IS DISTINCT FROM NEW.abierto AND NEW.abierto='N' THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
      SELECT periodoanterior, calculoanterior, estimacion INTO vPeriodo_1, vCalculo_1, vestimacion
        FROM cvp.Calculos
        WHERE periodo=NEW.periodo AND calculo=NEW.calculo ;
      IF (vPeriodo_1 IS NULL AND vCalculo_1 IS NULL) OR (vPeriodo_1=NEW.periodo AND vCalculo_1=NEW.calculo) THEN -- periodo inicial
        vAbierto_1='N';
      ELSE 
        SELECT abierto INTO vAbierto_1
          FROM cvp.Calculos
          WHERE periodo=vPeriodo_1 AND calculo=vCalculo_1;
      END IF;
      SELECT ingresando INTO vIngresando
        FROM cvp.Periodos
        WHERE periodo=NEW.Periodo;
      SELECT DISTINCT 1 INTO vhayProvisorios
        FROM cvp.caldiv c 
        INNER JOIN cvp.novprod n ON c.producto = n.producto and c.calculo = n.calculo and c.periodo = n.periodo
        INNER JOIN cvp.productos p ON c.producto = p.producto
        WHERE c.periodo=NEW.periodo AND c.calculo=NEW.calculo AND coalesce(n.tipoexterno, p.tipoexterno) is distinct from 'D' AND c.division = '0';
      SELECT DISTINCT 1 INTO vNOestantodosextdef 
        FROM cvp.productos p LEFT JOIN cvp.novprod n ON p.producto = n.producto AND n.periodo = NEW.periodo AND n.calculo = NEW.calculo
        WHERE p.tipoexterno = 'D' and n.periodo is null;        
    --Si vAbierto_1 ='N' AND vIngresando='N' seria correcto permitir cerrar calculo
      IF vAbierto_1 ='S' THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si no esta cerrado el anterior';
      END IF;
      IF vIngresando='S'  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si no esta cerrado el periodo correspondinete';
      END IF;
      IF vhayProvisorios=1  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si hay externos provisorios el periodo correspondinete';
      END IF;
      IF vNOestantodosextdef=1 THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si NO están todos los externos habituales el periodo correspondinete';
      END IF;
      IF vestimacion>0  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo con una estimación distinta de 0';
      END IF;
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
--Si vAbiertosig ='S' seria correcto abrir calculo
IF OLD.abierto IS DISTINCT FROM NEW.abierto AND NEW.abierto='S' THEN 
  IF vescoordinacion=1 THEN
      FOR vrecsig in
        SELECT periodo, calculo, abierto 
          FROM cvp.Calculos
          WHERE periodoanterior=NEW.Periodo AND calculoanterior=NEW.Calculo 
            AND (periodoanterior<>Periodo OR calculoanterior<>Calculo)
      LOOP
          IF vrecsig.abierto='N' THEN
            RAISE EXCEPTION 'ERROR no se puede reabrir porque el siguiente periodo "%" esta cerrado', vrecsig.periodo;
          END IF;
      END LOOP;   
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
RETURN NEW;
END;
$BODY$;



