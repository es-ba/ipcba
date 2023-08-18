set search_path = cvp;

ALTER TABLE IF EXISTS cuadros
    DROP CONSTRAINT "texto invalido en descripcion de tabla cuadros";
ALTER TABLE IF EXISTS cuadros
    ADD CONSTRAINT "texto invalido en descripcion de tabla cuadros" CHECK (comun.cadena_valida(descripcion::text, 'amplio'::text));

--select * from cuadros
insert into cuadros_funciones 
select 'res_cuadro_ie' as funcion, usa_parametro1, usa_periodo, usa_nivel, usa_grupo, usa_agrupacion, 
usa_ponercodigos, usa_agrupacion2, usa_cuadro, usa_hogares, usa_cantdecimales, usa_desde, usa_orden
from cuadros_funciones
where funcion = 'res_cuadro_ivebs';

INSERT INTO cuadros(
    cuadro, descripcion, funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
    agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo)
    VALUES ('11', 'Índice mensual empalmado con la serie anterior (base julio 2011 - junio 2012 = 100)', 'res_cuadro_ie', 
            'Mes', 'periodo_desde', 0, null, 'Z', 'IPCBA (base 2021 = 100).Nivel General. Índice mensual empalmado con la serie anterior (base julio 2011 - junio 2012 = 100).|||Ciudad de Buenos Aires.',
            'Fuente: Dirección General de Estadística y Censos (Ministerio de Hacienda y Finanzas GCBA).', null, null, null, 
            '¹ Base 2021 = 100.', null, null, null, null, 'S');

CREATE OR REPLACE FUNCTION res_cuadro_ie(
    parametro1 text,      --nada
    p_periodo_hasta text, --periodo hasta
    parametro3 integer,   --nivel
    parametro4 text,      ---agrupacion
    p_periodo_desde text, --periodo desde
    p_separador text)     ---separador
    RETURNS SETOF cvp.res_col3 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text;
begin
  
  v_periodo_desde := p_periodo_desde;
  return query select 0::bigint,'anchos'::text      ,'auto'::text,'auto'::text,vAnchoNumeros;
  return query select 1::bigint, 'U5.0.'::text,'Mes'::text, null::text,'Indice¹'::text;
  return query select 2::bigint, 'P..RR'::text, null::text,null::text, 'Nivel General'::text;
  return query select row_number() over (order by c.periodo)+100, 
                 'D11nn'::text as formato_renglon,
                 cvp.devolver_mes_anio(c.periodo),''::text,
                 --replace(round(c.indiceRedondeado::numeric,2)::text,'.',p_separador)::text
                 replace(c.indiceRedondeado::text,'.',p_separador)::text
                 from calgru_empalme c 
                 join grupos g on c.agrupacion = g.agrupacion and c.grupo = g.grupo
                 join calculos_def cd on c.calculo = cd.calculo
                 --join calculos ca  on ca.periodo=c.periodo and ca.calculo=c.calculo --pk verificada
                 where c.agrupacion=parametro4 and cd.principal and c.periodo <= p_periodo_hasta and c.periodo >= v_periodo_desde 
                 and g.nivel=parametro3;
end;
$BODY$;

ALTER FUNCTION res_cuadro_ie(text, text, integer, text, text, text)
    OWNER TO cvpowner;

--SELECT * from cvp.res_cuadro_ie('Mes', 'a2022m05'::text, 0, 'Z'::text, 'a2012m07'::text,',');  --cuadro 11