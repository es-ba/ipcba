CREATE FUNCTION controlar_existencia_visita_1_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
 vHay INTEGER; 
BEGIN
  IF new.visita > 1 THEN
    IF TG_TABLE_NAME= 'relvis' THEN
      SELECT 1 INTO vHay
        FROM cvp.relvis 
        WHERE periodo=new.periodo
          AND informante=new.informante
          AND formulario=new.formulario
          AND visita=new.visita-1;
      IF vHay is null THEN
        RAISE EXCEPTION 'Se quiere insertar la visita % y NO hay datos de la visita inmediata anterior % , en la tabla %: % i% f%'
          ,new.visita, new.visita-1,tg_table_name,new.periodo,new.informante,new.formulario;
        RETURN NULL;
      END IF;       
    ELSIF TG_TABLE_NAME= 'relpre' THEN
      SELECT 1 into vHay
        FROM cvp.relpre
        WHERE periodo=new.periodo
          AND informante=new.informante
          AND producto=new.producto
          AND observacion=new.observacion
          AND visita=new.visita-1;
      IF vHay is null THEN
        RAISE EXCEPTION 'Se quiere insertar la visita % y NO hay datos de la visita inmediata anterior % , en la tabla %: % i% % obs %'
          ,new.visita, new.visita-1,tg_table_name,new.periodo,new.informante,new.producto,new.observacion;
        RETURN NULL;
      END IF;       
    ELSIF TG_TABLE_NAME= 'relatr' THEN
      SELECT 1 into vHay
        FROM cvp.relatr
        WHERE periodo=new.periodo
          AND informante=new.informante
          AND producto=new.producto
          AND observacion=new.observacion
          AND atributo=new.atributo
          AND visita=new.visita-1;
      IF vHay is null THEN
        RAISE EXCEPTION 'Se quiere insertar la visita % y NO hay datos de la visita inmediata anterior % , en la tabla %: % i% % obs % atr %'
          ,new.visita, new.visita-1,tg_table_name,new.periodo,new.informante,new.producto,new.observacion,new.atributo;
        RETURN NULL;
      END IF;       
    END IF;
  END IF;
  RETURN NEW;
END;$$;

CREATE TRIGGER relatr_existe_visita_1_trg 
  BEFORE INSERT ON relatr 
  FOR EACH ROW EXECUTE PROCEDURE controlar_existencia_visita_1_trg();

CREATE TRIGGER relpre_existe_visita_1_trg 
  BEFORE INSERT ON relpre 
  FOR EACH ROW EXECUTE PROCEDURE controlar_existencia_visita_1_trg();

CREATE TRIGGER relvis_existe_visita_1_trg 
  BEFORE INSERT ON relvis 
  FOR EACH ROW EXECUTE PROCEDURE controlar_existencia_visita_1_trg();
