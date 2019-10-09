CREATE OR REPLACE FUNCTION agrupaciones_fijas_trg() RETURNS TRIGGER
  LANGUAGE plpgsql AS
$BODY$
DECLARE 
  v_agrupacion text;
  v_tipo text;
BEGIN
  IF tg_op='UPDATE' OR tg_op='DELETE' THEN
    v_agrupacion:=old.agrupacion;
    SELECT tipo_agrupacion INTO v_tipo
      FROM cvp.agrupaciones
      WHERE agrupacion=v_agrupacion;
    IF v_tipo = 'GENERAL' THEN
      -- ok;
    ELSE
        RAISE 'La agrupación % no puede recibir un % en la tabla %', v_agrupacion, tg_op, tg_table_name;
    END IF;
  END IF;
  IF tg_op='UPDATE' OR tg_op='INSERT' THEN
    v_agrupacion:=new.agrupacion;
    IF TG_TABLE_NAME='agrupaciones' THEN
      IF new.tipo_agrupacion = 'GENERAL' THEN
        -- ok;
      ELSE
        RAISE 'La agrupación % no puede recibir un % en la tabla %', v_agrupacion, tg_op, tg_table_name;
      END IF;
    ELSE
    SELECT tipo_agrupacion INTO v_tipo
      FROM cvp.agrupaciones
      WHERE agrupacion=v_agrupacion;
    IF v_tipo = 'GENERAL' THEN
      -- ok;
    ELSE
      RAISE 'La agrupación % no puede recibir un % en la tabla %', v_agrupacion, tg_op, tg_table_name;
    END IF;
  END IF;
  END IF;
  IF TG_OP='DELETE' THEN
     RETURN OLD;
  ELSE   
     RETURN NEW;
  END IF;
END;
$BODY$;

CREATE TRIGGER agrupaciones_fijas_trg 
  BEFORE INSERT OR UPDATE OR DELETE ON agrupaciones
  FOR EACH ROW
  EXECUTE PROCEDURE agrupaciones_fijas_trg();

CREATE TRIGGER agrupaciones_fijas_trg 
  BEFORE INSERT OR UPDATE OR DELETE ON grupos
  FOR EACH ROW
  EXECUTE PROCEDURE agrupaciones_fijas_trg();
