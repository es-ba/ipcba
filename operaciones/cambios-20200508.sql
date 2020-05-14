set search_path = cvp;

ALTER TABLE relinf ADD COLUMN fechasalidadesde date;
ALTER TABLE relinf ADD COLUMN fechasalidahasta date;

ALTER TABLE his.relinf ADD COLUMN fechasalidadesde date;
ALTER TABLE his.relinf ADD COLUMN fechasalidahasta date;

CREATE OR REPLACE FUNCTION hisc_relinf_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','periodo','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||new.periodo,new.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','informante','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.informante),new.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','visita','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.visita),new.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','observaciones','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.observaciones),new.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_usu','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','modi_fec','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_ope','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','fechasalidadesde','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.fechasalidadesde),new.fechasalidadesde);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','fechasalidahasta','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.fechasalidahasta),new.fechasalidahasta);
      END IF;
      IF v_operacion='U' THEN          
        IF new.periodo IS DISTINCT FROM old.periodo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','periodo','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
        END IF;    
        IF new.informante IS DISTINCT FROM old.informante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','informante','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
        END IF;    
        IF new.visita IS DISTINCT FROM old.visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','visita','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
        END IF;    
        IF new.observaciones IS DISTINCT FROM old.observaciones THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','observaciones','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,old.observaciones||'->'||new.observaciones,old.observaciones,new.observaciones);
        END IF;    
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_usu','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','modi_fec','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_ope','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
        IF new.fechasalidadesde IS DISTINCT FROM old.fechasalidadesde THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','fechasalidadesde','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.fechasalidadesde)||'->'||comun.a_texto(new.fechasalidadesde),old.fechasalidadesde,new.fechasalidadesde);
        END IF;    
        IF new.fechasalidahasta IS DISTINCT FROM old.fechasalidahasta THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','fechasalidahasta','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.fechasalidahasta)||'->'||comun.a_texto(new.fechasalidahasta),old.fechasalidahasta,new.fechasalidahasta);
        END IF;    
      END IF;
      IF v_operacion='D' THEN        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','periodo','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.periodo),old.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','informante','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.informante),old.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','visita','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.visita),old.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','observaciones','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||old.observaciones,old.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_usu','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','modi_fec','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_ope','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','fechasalidadesde','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.fechasalidadesde),old.fechasalidadesde);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','fechasalidahasta','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.fechasalidahasta),old.fechasalidahasta);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;
----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cvp.modi_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  -- V090122
  vOpe VARCHAR(1);
  vUsuario VARCHAR(30);
BEGIN
  vUsuario:=SESSION_USER;
  if TG_OP='DELETE' then
    vOpe:='D';
  elsif TG_OP='INSERT' then
    vOpe:='I';
  elsif TG_OP='UPDATE' then
    vOpe:='U';
  else
    RAISE EXCEPTION 'operacion desconocida';
  end if;

  if 'con historico'='sin historico' then
    execute 'insert into ' || tg_table_schema || '.his_' || tg_table_name || 
      ' select *, ''' || user || ''', ''' || vOpe || ''' ' || 
      ' from ' || tg_table_schema || '.' || tg_table_name || 
      ' where ctid=' || old.ctid || '::tid'; 
  end if;

  if TG_OP<>'INSERT' then
    if tg_table_name='relpan' then
      INSERT INTO his.relpan SELECT vUsuario,vOpe,* FROM cvp.relpan WHERE periodo=OLD.periodo AND panel=old.panel;
    elsif tg_table_name='relvis' then
      INSERT INTO his.relvis SELECT vUsuario,vOpe,* FROM cvp.relvis WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita AND formulario=OLD.formulario;
    elsif tg_table_name='relpre' then
      INSERT INTO his.relpre SELECT vUsuario,vOpe,* FROM cvp.relpre WHERE periodo=OLD.periodo AND producto=OLD.producto AND observacion=OLD.observacion AND informante=OLD.informante AND visita=OLD.visita;
    elsif tg_table_name='relatr' then
      INSERT INTO his.relatr SELECT vUsuario,vOpe,* FROM cvp.relatr WHERE periodo=OLD.periodo AND producto=OLD.producto AND observacion=OLD.observacion AND informante=OLD.informante AND visita=OLD.visita and atributo=OLD.atributo;
    elsif tg_table_name='novobs' then
      INSERT INTO his.novObs SELECT vUsuario,vOpe,* FROM cvp.novObs WHERE periodo=OLD.periodo AND calculo=OLD.calculo AND producto=OLD.producto AND informante=OLD.informante AND observacion=OLD.observacion;
    elsif tg_table_name='novprod' then
      INSERT INTO his.novProd SELECT vUsuario,vOpe,* FROM cvp.novProd WHERE periodo=OLD.periodo AND calculo=OLD.calculo AND producto=OLD.producto ;
    elsif tg_table_name='novpre' then
      INSERT INTO his.novPre SELECT vUsuario,vOpe,* FROM cvp.novPre WHERE periodo=OLD.periodo AND producto=OLD.producto AND informante=OLD.informante AND observacion=OLD.observacion AND visita=OLD.visita;
    elsif tg_table_name='relsup' then
      INSERT INTO his.relsup SELECT vUsuario,vOpe,* FROM cvp.relsup WHERE periodo=OLD.periodo AND panel=old.panel AND supervisor=old.supervisor;  
    elsif tg_table_name='reltar' then
      INSERT INTO his.reltar SELECT vUsuario,vOpe,* FROM cvp.reltar WHERE periodo=OLD.periodo AND panel=old.panel AND tarea=old.tarea;
    elsif tg_table_name='relmon' then
      INSERT INTO his.relmon SELECT vUsuario,vOpe,* FROM cvp.relmon WHERE periodo=OLD.periodo AND moneda=OLD.moneda; 
    elsif tg_table_name='relenc' then
      INSERT INTO his.relenc SELECT vUsuario,vOpe,* FROM cvp.relenc WHERE periodo=OLD.periodo AND panel=OLD.panel AND tarea=OLD.tarea; 
    elsif tg_table_name='prerep' then
      INSERT INTO his.prerep SELECT vUsuario,vOpe,* FROM cvp.prerep WHERE periodo=OLD.periodo AND producto=OLD.producto AND informante=OLD.informante; 
    elsif tg_table_name='relinf' then
      INSERT INTO his.relinf SELECT vUsuario,vOpe,periodo, informante, visita, observaciones, modi_usu, modi_fec, modi_ope, null as panel, null as tarea, fechasalidadesde, fechasalidahasta FROM cvp.relinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita;
    --else
      --RAISE EXCEPTION 'Auditoria de tabla % no contemplada', tg_table_name ;
    end if;
  end if;
 
  if TG_OP='DELETE' then
    RETURN OLD;
  else
    NEW.modi_usu:=vUsuario;
    NEW.modi_fec:=CURRENT_TIMESTAMP(3);
    NEW.modi_ope:=vOpe;
    RETURN NEW;
  end if;
END;
$BODY$;
---------------------------------------------------
set search_path = cvp; 

CREATE OR REPLACE FUNCTION permitir_actualizar_valor_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  --vcambio  cvp.relpre.cambio%type;
  valterable  cvp.prodatr.alterable%type;
  vvalor_1 cvp.relatr.valor%type;
  vvaloresvalidos record;
  vvalido boolean;
  vhayquevalidar boolean;
  vespositivo cvp.tipopre.espositivo%type;
  
BEGIN
  IF OLD.valor IS DISTINCT FROM NEW.valor THEN
    --SELECT cambio INTO vcambio
    --  FROM cvp.relpre
    --  WHERE periodo=NEW.periodo AND informante=NEW.informante AND visita=NEW.visita AND producto=NEW.producto AND
    --        observacion=NEW.observacion;
    --IF vcambio IS DISTINCT FROM 'C' THEN
    --  RAISE EXCEPTION 'No es posible modificar el valor del atributo cuando el campo cambio es distinto de C';
    --  RETURN NULL;
    --ELSE
    SELECT coalesce(t.espositivo,'S') INTO vespositivo
      FROM cvp.relpre r 
	  LEFT JOIN cvp.tipopre t on r.tipoprecio = t.tipoprecio
      WHERE r.periodo=NEW.periodo AND r.informante=NEW.informante AND r.visita=NEW.visita AND r.producto=NEW.producto AND
            r.observacion=NEW.observacion;
    IF vespositivo='N' THEN
  	  RAISE EXCEPTION 'No es posible modificar el valor del atributo cuando el precio no es positivo';
      RETURN NULL;
    ELSE
      SELECT alterable INTO valterable
        FROM cvp.prodatr
        WHERE producto = NEW.producto AND atributo = NEW.atributo;
      IF valterable = 'N' THEN
        SELECT r_1.valor_1 INTO vvalor_1
          FROM cvp.relatr_1 r_1
          WHERE r_1.periodo=NEW.periodo AND 
                r_1.producto=NEW.producto AND
                r_1.observacion=NEW.observacion AND 
                r_1.informante=NEW.informante AND
                r_1.visita=NEW.visita AND 
                r_1.atributo=NEW.atributo;
         IF vvalor_1 IS NOT NULL THEN
           RAISE EXCEPTION 'Atributo no alterable no se puede modificar';
           RETURN NULL;
         ELSE
           vvalido := false;
           vhayquevalidar := false;
           FOR vvaloresvalidos IN
             SELECT valor 
               FROM cvp.valvalatr 
               WHERE producto = NEW.producto and atributo = NEW.atributo
           LOOP
             vhayquevalidar := true;
             IF vvaloresvalidos.valor = NEW.valor THEN
                vvalido := true;
             END IF;                
           END LOOP;
           IF vhayquevalidar AND NOT vvalido THEN
             RAISE EXCEPTION 'El valor ingresado no es válido para este atributo';
             RETURN NULL;
           END IF;
         END IF;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$BODY$;
	 
