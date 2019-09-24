CREATE TYPE cvp.extpre AS (
	periodo text,
	producto text,
	nombreproducto text,
	precios text,
	informantes text
);

CREATE TYPE cvp.extvar AS (
	periodo text,
	producto text,
	nombreproducto text,
	variaciones text,
	informantes text
);

CREATE TYPE cvp.relatr_tipico_type AS (
	valor text,
	frecuencia bigint,
	frec_ant bigint,
	obs text
);

CREATE TYPE cvp.res_col10 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text,
	columna4 text,
	columna5 text,
	columna6 text,
	columna7 text,
	columna8 text,
	columna9 text,
	columna10 text
);

CREATE TYPE cvp.res_col3 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text
);

CREATE TYPE cvp.res_col4 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text,
	columna4 text
);

CREATE TYPE cvp.res_col6 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text,
	columna4 text,
	columna5 text,
	columna6 text
);

CREATE TYPE cvp.res_col8 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text,
	columna4 text,
	columna5 text,
	columna6 text,
	columna7 text,
	columna8 text
);

CREATE TYPE cvp.res_col9 AS (
	renglon bigint,
	formato_renglon text,
	columna1 text,
	columna2 text,
	columna3 text,
	columna4 text,
	columna5 text,
	columna6 text,
	columna7 text,
	columna8 text,
	columna9 text
);

CREATE TYPE cvp.res_mat AS (
	formato_renglon text,
	lateral1 text,
	lateral2 text,
	cabezal1 text,
	celda text
);

CREATE TYPE cvp.res_mat2 AS (
	formato_renglon text,
	lateral1 text,
	lateral2 text,
	lateral3 text,
	cabezal1 text,
	celda text
);
