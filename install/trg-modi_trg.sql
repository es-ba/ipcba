CREATE OR REPLACE FUNCTION cvp.modi_trg()
  RETURNS trigger AS
$BODY$
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
  /*
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
      INSERT INTO his.relinf SELECT vUsuario,vOpe,* FROM cvp.relinf WHERE periodo=OLD.periodo AND informante=OLD.informante and visita=OLD.visita;
    --else
      --RAISE EXCEPTION 'Auditoria de tabla % no contemplada', tg_table_name ;
    end if;
  end if;
  */
  if TG_OP='DELETE' then
    RETURN OLD;
  else
    NEW.modi_usu:=vUsuario;
    NEW.modi_fec:=CURRENT_TIMESTAMP(3);
    NEW.modi_ope:=vOpe;
    RETURN NEW;
  end if;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER RelTar_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON RelTar
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();

CREATE TRIGGER RelInf_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON RelInf
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();

CREATE TRIGGER novpre_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON novpre
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();

CREATE TRIGGER novdelobs_modi_trg 
  BEFORE INSERT OR DELETE OR UPDATE 
  ON novdelobs 
  FOR EACH ROW 
  EXECUTE PROCEDURE modi_trg();

CREATE TRIGGER novdelvis_modi_trg 
  BEFORE INSERT OR DELETE OR UPDATE 
  ON novdelvis 
  FOR EACH ROW 
  EXECUTE PROCEDURE modi_trg();
/*  
CREATE TRIGGER relenc_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relenc
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();
*/
CREATE TRIGGER relmon_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relmon
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();

CREATE TRIGGER NovProd_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON NovProd
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();
  
CREATE TRIGGER relsup_modi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relsup
  FOR EACH ROW
  EXECUTE PROCEDURE modi_trg();
