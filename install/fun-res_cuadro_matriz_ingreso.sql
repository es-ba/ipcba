--res_cuadro_matriz_ingreso
CREATE OR REPLACE FUNCTION res_cuadro_matriz_ingreso(parametro1 text, p_periodo text, p_hogar text, p_periododesde text, p_separador text)
  returns setof cvp.res_mat
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
                      'Mes'::text, 
                      'Estrato'::text, 
                      null::text,
                      null::text;

  return query  SELECT formato_renglon, lateral1, lateral2, cabezal1, celda from (
                SELECT v_formato_renglon::text as formato_renglon, x.orden, v.periodo,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as lateral1,
                  X.nombre as lateral2,
                  'Mínimo' as cabezal1,
                  CASE WHEN nombre = 'En situación de indigencia'           THEN '0'||p_separador||'00'::text
                       WHEN nombre = 'En situación de pobreza no indigente' THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'No pobres vulnerables'                THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio frágil'                  THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio - "Clase media"'         THEN replace(round((1.25*round(v.valorhoggru::numeric,2))::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sectores acomodados'                  THEN replace(round((4*   round(v.valorhoggru::numeric,2))::numeric,2)::text,'.',p_separador) end as celda
                  FROM 
                    (SELECT 1 as orden, 'En situación de indigencia'           AS nombre,	'D1' as grupominimo,	'D1' as grupomaximo UNION
                    SELECT  2 as orden, 'En situación de pobreza no indigente' AS nombre,	'D1' as grupominimo,	'D5' as grupomaximo UNION
                    SELECT  3 as orden, 'No pobres vulnerables'                AS nombre, 	'D5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  4 as orden, 'Sector medio frágil'                  AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  5 as orden, 'Sector medio - "Clase media"'         AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  6 as orden, 'Sectores acomodados'                  AS nombre, 	'A5' as grupominimo,	'A5' as grupomaximo) as X
                    left join valorizacion_canasta_cuadros v  on X.grupominimo = v.grupo 
                    left join valorizacion_canasta_cuadros v1 on v.periodo = v1.periodo /*and v.agrupacion = v1.agrupacion*/ and X.grupomaximo = v1.grupo
                               and v.calculo = v1.calculo and v.hogar = v1.hogar
				    join calculos_def cd on v.calculo = cd.calculo
                  WHERE v.agrupacion in ('A','D') 
                        and v.grupo in ('A1','A5', 'D1', 'D5')
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                Union
                SELECT v_formato_renglon::text as formato_renglon, x.orden, v.periodo,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as lateral1,
                  X.nombre as lateral2,
                  'Máximo' as cabezal1,
                  CASE WHEN nombre = 'En situación de indigencia'           THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'En situación de pobreza no indigente' THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'No pobres vulnerables'                THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio frágil'                  THEN replace(round(((1.25*round(v1.valorhoggru::numeric,2))-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio - "Clase media"'         THEN replace(round(((4*   round(v1.valorhoggru::numeric,2))-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sectores acomodados'                  THEN 'Mas'::text end as celda
                  FROM 
                    (SELECT 1 as orden, 'En situación de indigencia'           AS nombre,	'D1' as grupominimo,	'D1' as grupomaximo UNION
                    SELECT  2 as orden, 'En situación de pobreza no indigente' AS nombre,	'D1' as grupominimo,	'D5' as grupomaximo UNION
                    SELECT  3 as orden, 'No pobres vulnerables'                AS nombre, 	'D5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  4 as orden, 'Sector medio frágil'                  AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  5 as orden, 'Sector medio - "Clase media"'         AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  6 as orden, 'Sectores acomodados'                  AS nombre, 	'A5' as grupominimo,	'A5' as grupomaximo) as X
                    left join valorizacion_canasta_cuadros v  on X.grupominimo = v.grupo
                    join calculos_def cd on v.calculo = cd.calculo					
                    left join valorizacion_canasta_cuadros v1 on v.periodo = v1.periodo /*and v.agrupacion = v1.agrupacion*/ and X.grupomaximo = v1.grupo
                               and v.calculo = v1.calculo and v.hogar = v1.hogar
                  WHERE v.agrupacion in ('A','D') 
                        and v.grupo in ('A1','A5', 'D1', 'D5')
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                  ) resp
                  ORDER BY periodo, orden, cabezal1 desc;
end;
$BODY$;

--test
--SELECT * from res_cuadro_matriz_ingreso('Listado de Valorización de la Canasta', 'a2022m05'::text, 'Hogar 1', 'a2022m01'::text, '.');  
--SELECT * from res_cuadro_matriz_ingreso('Listado de Valorización de la Canasta', 'a2022m05'::text, 'Hogar 1', 'a2022m01'::text, '.');
