set search_path = ccc;
SET role cvpowner;

CREATE TABLE IF NOT EXISTS tipos_tenencia
(
    tipo_tenencia text NOT NULL,
    descripcion text,
    PRIMARY KEY (tipo_tenencia),
    CONSTRAINT "texto invalido en descripcion de tabla tipos_tenencia" CHECK (comun.cadena_valida(descripcion::text, 'castellano'::text))
);

GRANT SELECT ON TABLE tipos_tenencia TO cvp_administrador, ccc_analista;

CREATE TABLE IF NOT EXISTS indicadores
(
    indicador text NOT NULL,
    descripcion text,
    PRIMARY KEY (indicador),
    CONSTRAINT "texto invalido en descripcion de tabla indicadores" CHECK (comun.cadena_valida(descripcion::text, 'castellano'::text))
);

GRANT SELECT ON TABLE indicadores TO cvp_administrador, ccc_analista;

ALTER TABLE hogares_ccc ADD COLUMN tipo_tenencia TEXT;
ALTER TABLE hogares_ccc ADD FOREIGN KEY (tipo_tenencia) REFERENCES tipos_tenencia (tipo_tenencia) ON UPDATE CASCADE;

ALTER TABLE nnyas ADD COLUMN tipo_tenencia TEXT;
ALTER TABLE nnyas ADD FOREIGN KEY (tipo_tenencia) REFERENCES tipos_tenencia (tipo_tenencia) ON UPDATE CASCADE;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('tipos_tenencia','tipo_tenencia');
 PERFORM enance_table('hogares_ccc','hogar');
 PERFORM enance_table('nnyas','nnya');
 PERFORM enance_table('indicadores','indicador');
 end
$SQL_ENANCE$;

