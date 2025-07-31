ALTER TABLE cvp.relpantarinf ADD COLUMN token_relevamiento_backup text;
ALTER TABLE cvp.relpantarinf ADD COLUMN encuestador_backup text;
ALTER TABLE cvp.relpantarinf ADD COLUMN fecha_backup timestamp;
ALTER TABLE cvp.relpantarinf ADD COLUMN backup jsonb;
ALTER TABLE his.relpantarinf ADD COLUMN token_relevamiento_backup text;
ALTER TABLE his.relpantarinf ADD COLUMN encuestador_backup text;
ALTER TABLE his.relpantarinf ADD COLUMN fecha_backup timestamp;
ALTER TABLE his.reltar DROP COLUMN backup;

CREATE OR REPLACE FUNCTION cvp.modi_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
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
      INSERT INTO his.reltar SELECT vUsuario,vOpe,periodo,panel,tarea,supervisor,encuestador,realizada,resultado,observaciones,puntos,modi_usu,modi_fec,modi_ope,cargado,descargado,vencimiento_sincronizacion,id_instalacion,vencimiento_sincronizacion2,archivo_manifiesto,archivo_estructura,archivo_hdr,datos_descarga,fechasalidadesde,fechasalidahasta,archivo_cache,modalidad,fecha_backup,visiblepararelevamiento FROM cvp.reltar WHERE periodo=OLD.periodo AND panel=old.panel AND tarea=old.tarea;
    elsif tg_table_name='relmon' then
      INSERT INTO his.relmon SELECT vUsuario,vOpe,* FROM cvp.relmon WHERE periodo=OLD.periodo AND moneda=OLD.moneda;
    elsif tg_table_name='relenc' then
      INSERT INTO his.relenc SELECT vUsuario,vOpe,* FROM cvp.relenc WHERE periodo=OLD.periodo AND panel=OLD.panel AND tarea=OLD.tarea;
    elsif tg_table_name='prerep' then
      INSERT INTO his.prerep SELECT vUsuario,vOpe,* FROM cvp.prerep WHERE periodo=OLD.periodo AND producto=OLD.producto AND informante=OLD.informante;
    elsif tg_table_name='relinf' then
      INSERT INTO his.relinf SELECT vUsuario,vOpe,periodo, informante, visita, observaciones, modi_usu, modi_fec, modi_ope, null as panel, null as tarea, fechasalidadesde, fechasalidahasta FROM cvp.relinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita;
    elsif tg_table_name='relpantarinf' then
      INSERT INTO his.relpantarinf SELECT vUsuario,vOpe,periodo,informante,visita,panel,tarea,observaciones,modi_usu,modi_fec,modi_ope,fechasalidadesde,fechasalidahasta,observaciones_campo,codobservaciones,recuperos,token_relevamiento_backup,encuestador_backup,fecha_backup FROM cvp.relpantarinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita and panel=OLD.panel and tarea=OLD.tarea;
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
