set search_path = ccc;
set role cvpowner;
drop table IF EXISTS cuadros_ccc cascade;
drop table IF EXISTS cuadros_funciones_ccc cascade;

ALTER TABLE perfiles drop COLUMN if exists equivalente;
ALTER TABLE perfiles ADD COLUMN equivalente boolean;
UPDATE perfiles set equivalente = true where unidcons = 1;

CREATE TABLE IF NOT EXISTS cuadros_ccc as
select * from cvp.cuadros where cuadro = '7';
UPDATE cuadros_ccc
    SET cuadro='1',
    descripcion='Tabla de equivalencias y unidad consumidora según tipo de canasta alimentaria para varones y mujeres y rango de edades',
    funcion='ccc_cuadro_up',
    parametro1='Tabla de equivalencias',
    grupo='G01',
    encabezado='Cuadro 1||| IPCBA. Tabla de equivalencias y unidad consumidora según tipo de canasta alimentaria para varones y mujeres y rango de edades',
    empalmedesde = false
    WHERE cuadro='7';

CREATE TABLE IF NOT EXISTS cuadros_funciones_ccc as
select * from cvp.cuadros_funciones where funcion = 'res_cuadro_up';
update cuadros_funciones_ccc set funcion = 'ccc_cuadro_up' where funcion = 'res_cuadro_up';

do $SQL_ENANCE$
 begin
 PERFORM enance_table('cuadros_ccc','cuadro');
 PERFORM enance_table('cuadros_funciones_ccc','agrupacion, funcion');
 end
$SQL_ENANCE$;

alter table cuadros_ccc add CONSTRAINT cuadros_ccc_pkey PRIMARY KEY (cuadro);
alter table cuadros_ccc add CONSTRAINT "texto invalido en descripcion de tabla cuadros_ccc" CHECK (comun.cadena_valida(descripcion::text, 'amplio'::text));
alter table cuadros_ccc add CONSTRAINT "texto invalido en parametro1 de tabla cuadros_ccc" CHECK (comun.cadena_valida(parametro1::text, 'amplio'::text));
alter table cuadros_ccc add CONSTRAINT "texto invalido en pie de tabla cuadros_ccc" CHECK (comun.cadena_valida(pie::text, 'amplio'::text));

ALTER TABLE cuadros_funciones_ccc add CONSTRAINT cuadros_funciones_ccc_pkey PRIMARY KEY (funcion);

ALTER TABLE cuadros_ccc add CONSTRAINT cuadros_ccc_cuadros_funciones_ccc_fkey FOREIGN KEY (funcion) REFERENCES cuadros_funciones_ccc(funcion);

drop TYPE IF EXISTS res_col7 cascade;
CREATE TYPE res_col7 AS (
    renglon bigint,
    formato_renglon text,
    columna1 text,
    columna2 text,
    columna3 text,
    columna4 text,
    columna5 text,
    columna6 text,
    columna7 text
);

--ccc_cuadro_up
DROP FUNCTION if exists ccc_cuadro_up(text,text,text,boolean,boolean,text,text);
create or replace function ccc_cuadro_up(parametro1 text, p_periodo text, parametro4 text, pempalmedesde boolean,
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text)
  returns setof res_col7
  language plpgsql
as
$BODY$
declare

    vAnchoNumeros text:='100';

begin
  return query select 0::bigint,'anchos'::text,
       'auto'::text,'auto'::text,'auto'::text,'auto'::text,'auto'::text,
       vAnchoNumeros, vAnchoNumeros;
  return query select 1::bigint, 'U2.LR'::text, 'Tipo_CA'::text, 'Tipo_género'::text, 'Edad'::text,
   'Energía (kcal)'::text, 'Unidad Consumidora'::text, 'Valorización diaria ($)'::text, 'Valorización mensual ($)'::text;
  return query select row_number() over (order by q.perfil)+100, formato_renglon
               , q.tipo, q.genero, q.edad, q.energia, q.unidcons, q.valor, q.valor_mensual
                 from
                 (
                 select
                    'D.21n' as formato_renglon, p.perfil, p.tipo, p.genero, p.edad,
                    replace (round(p.energia::decimal,2)::text,'.',p_separador) energia,
                    replace (round(p.unidcons::decimal,2)::text,'.',p_separador) unidcons,
                    replace (round((c.valorgru*p.unidcons)::decimal,2)::text,'.',p_separador) valor,
                    replace (round(((c.valorgru*p.unidcons) * 30)::decimal, 2)::text,'.',p_separador) valor_mensual
                 from (select pe.perfil as perfil_equivalente, pp.*
                        from perfiles pe join perfiles pp on pe.equivalente and pe.tipo = pp.tipo) p
                 left join calgruper c on p.perfil_equivalente = c.perfil
                 join cvp.calculos_def cd on c.calculo = cd.calculo
                 where grupo = parametro4
                   and cd.principal
                   and periodo=p_Periodo
                   --and ((pempalmehasta and periodo <= pperiodoempalme) or
                   --     (pempalmedesde and periodo >  pperiodoempalme))
                ) as q
               ;
end;
$BODY$;

GRANT SELECT ON TABLE cuadros_ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE cuadros_funciones_ccc TO cvp_administrador, ccc_analista;

--test
SELECT * from ccc_cuadro_up(null, 'a2025m04'::text, 'G01', false, false , 'a2022m02','.');
--SELECT * from ccc_cuadro_up(null, 'a2025m05'::text, 'G01', false, false , 'a2022m02','.');

---------------------------------------------------------------------------------------------------------------------
set search_path = ccc, cvp;
INSERT INTO cuadros_funciones_ccc
select * from cvp.cuadros_funciones where funcion = 'res_cuadro_matriz_hogar';
update cuadros_funciones_ccc set funcion = 'ccc_cuadro_matriz_hogar' where funcion = 'res_cuadro_matriz_hogar';

INSERT INTO cuadros_ccc
SELECT cuadro, descripcion, 'ccc_cuadro_matriz_hogar' as funcion,
    'Valorización de las Canastas de Consumo según las tipologías de hogares.' as parametro1,
    periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, agrupacion2, 16 as hogares,
    pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta
    FROM cvp.cuadros
    where cuadro = 'H1';

--ccc_cuadro_matriz_hogar
--UTF8=Sí

create or replace function ccc_cuadro_matriz_hogar(parametro1 text, p_periodo text, parametro4 text, p_cuadro text, parametro6 integer, p_separador text)
  returns setof res_mat
  language plpgsql
as
$BODY$
declare
    v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
    v_formato_renglon_cabezal text:='E111'; -- idem
begin
  return query select 'anchos'::text as formato_renglon,
    'auto'::text,
    'auto'::text,
    null::text,
    100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
    'Valorización'::text,
    'Código'::text,
    null::text,
    null::text;
  return query SELECT v_formato_renglon::text as formato_renglon,
    g.nombregrupo::text as lateral1,
    h.grupo::text as lateral2,
    null::text as cabezal1,
    jsonb_object_agg(
        h.hogar,
        replace(round(h.valorhoggru::numeric,2)::text, '.', p_separador)
        ORDER BY replace(replace(h.hogar,'5b','5.1'),'Hogar CCC ','')::numeric
    )::text as celda
    FROM CalHogGru_CCC h
    LEFT JOIN grupos_ccc g on h.agrupacion = g.agrupacion and h.grupo = g.grupo
    JOIN calculos_def cd on h.calculo = cd.calculo
    WHERE h.agrupacion = parametro4
      and cd.principal
      and h.periodo = p_periodo
      and replace(replace(h.hogar,'5b','5.1'),'Hogar CCC ','')::numeric < parametro6
      and g.nivel = 2
    GROUP BY v_formato_renglon, g.nombregrupo, h.grupo
    ORDER BY h.grupo;
end;
$BODY$;

--test
SELECT * from ccc_cuadro_matriz_hogar('Listado de Valorización de la Canasta', 'a2025m05'::text, 'G'::text, 'H1', 16, ',');
