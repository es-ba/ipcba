set search_path = cvp;
--drop index idx_relvis_maxperiodo_seguro
CREATE INDEX idx_relvis_maxperiodo_seguro ON cvp.relvis (periodo, informante, visita, formulario, razon);
