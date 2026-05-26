-- Índices creados para optimizar la grilla del Gabinete (relvis) y la grilla de Informantes
CREATE INDEX relvis_per_pan_tar_idx ON cvp.relvis (periodo, panel, tarea);
CREATE INDEX relvis_informante_idx ON cvp.relvis (informante);
