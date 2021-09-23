set search_path = cvp;
ALTER TABLE prodatrval ADD COLUMN atributo_2 integer;
ALTER TABLE prodatrval ADD COLUMN valor_2 text;

ALTER TABLE prodatrval
    ADD CONSTRAINT "blancos extra en valor_2 tabla prodatrval" CHECK (NOT valor_2 IS DISTINCT FROM btrim(regexp_replace(valor_2, ' {2,}'::text, ' '::text, 'g'::text)));
ALTER TABLE prodatrval
    ADD CONSTRAINT "no se puede poner el sombrero en el atributo_2" CHECK (valor_2 !~~ '%~%'::text);
ALTER TABLE prodatrval
    ADD CONSTRAINT "texto invalido en valor_2 de tabla relatr" CHECK (comun.cadena_valida(valor_2, 'amplio'::text));
ALTER TABLE prodatrval ADD FOREIGN KEY (producto, atributo_2) REFERENCES prodatr (producto, atributo);

CREATE INDEX ON prodatrval (producto, atributo_2, valor_2);
