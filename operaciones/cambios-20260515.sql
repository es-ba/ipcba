set search_path TO cvp;

CREATE INDEX idx_relvis_historial ON relvis (informante, formulario, razon, periodo);