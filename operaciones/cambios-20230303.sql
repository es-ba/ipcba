set search_path = cvp;
ALTER TABLE tokens ADD COLUMN tokentype text;
ALTER TABLE tokens ADD COLUMN due timestamp without time zone;
ALTER TABLE tokens ADD COLUMN "info" jsonb;

DROP TRIGGER reltar_abi_trg ON reltar;
CREATE TRIGGER reltar_abi_trg
  BEFORE INSERT OR DELETE OR UPDATE OF supervisor, encuestador, realizada, resultado, observaciones, puntos, cargado, descargado, id_instalacion
  , fechasalidadesde, fechasalidahasta, modalidad, visiblepararelevamiento
  ON reltar
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

