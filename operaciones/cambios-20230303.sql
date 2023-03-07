set search_path = cvp;
ALTER TABLE tokens ADD COLUMN tokentype text;
ALTER TABLE tokens ADD COLUMN due timestamp without time zone;
ALTER TABLE tokens ADD COLUMN "info" jsonb;

CREATE TRIGGER reltar_abi_trg
  BEFORE INSERT OR UPDATE OF supervisor, encuestador, realizada, resultado, observaciones, puntos, cargado, descargado,
                             fechasalidadesde, fechasalidahasta, modalidad, visiblepararelevamiento OR DELETE
  ON reltar
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

