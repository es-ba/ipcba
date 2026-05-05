set search_path=cvp;

alter table fechas add column visible_ingreso cvp.sino_dom default 'S';

/*
-- Para ocultar las fechas que no tienen panel asociado, se puede usar la siguiente consulta para identificar esas fechas:

SELECT f.*
FROM fechas f
WHERE NOT EXISTS (
    SELECT 1 FROM relpan rp WHERE rp.fechasalida = f.fecha AND rp.panel IS NOT NULL
);

-- Luego, para actualizar la columna visible_ingreso a 'N' para esas fechas, se puede ejecutar la siguiente consulta:

UPDATE fechas f
SET visible_ingreso = 'N'
WHERE not EXISTS (
    SELECT 1
    FROM relpan rp
    WHERE rp.fechasalida = f.fecha and rp.panel is not null
);


*/