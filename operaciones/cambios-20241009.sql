set search_path = cvp;
/*
select *, valor_2 ~ '^([0-9]+(\.[0-9]+)?(\;[0-9]+(\.[0-9]+)?)*)$'
	from prodatrval
	where not (valor_2 ~ '^([0-9]+(\.[0-9]+)?(\;[0-9]+(\.[0-9]+)?)*)$');
*/
ALTER TABLE IF EXISTS cvp.prodatrval
    DROP CONSTRAINT "texto invalido en valor de tabla relatr";

ALTER TABLE IF EXISTS cvp.prodatrval
    ADD CONSTRAINT "texto invalido en valor de tabla relatr" CHECK (comun.cadena_valida(valor, 'amplio'::text));

ALTER TABLE IF EXISTS cvp.prodatrval
    DROP CONSTRAINT "texto invalido en valor_2 de tabla relatr";

ALTER TABLE IF EXISTS cvp.prodatrval
    ADD CONSTRAINT "texto invalido en valor_2 de tabla prodatrval" CHECK (valor_2 ~ '^([0-9]+(\.[0-9]+)?(\;[0-9]+(\.[0-9]+)?)*)$');
