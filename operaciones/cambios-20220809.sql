set search_path = cvp;
CREATE OR REPLACE VIEW cvp.frecCambio_Nivel3 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))/EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster") AS cantobsporestado, 
    COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, grupo, nombregrupo, estado, x."cluster")/ COUNT(grupo) OVER (PARTITION BY periodo, grupo, nombregrupo, x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, g.nombregrupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
             WHEN o.promobs > o1.promobs THEN 'Subió' 
        ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        join cvp.calculos_def cd on o.calculo = cd.calculo
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg on o.producto = gg.grupo
        LEFT JOIN cvp.grupos g on gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p on o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE /*o.periodo >= 'a2012m07' AND o.periodo <= 'a2017m09' AND */ 
        cd.principal AND g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs like 'R%' AND o1.impobs like 'R%'
     ) AS X
WHERE periodo >= 'a2017m01'
ORDER BY "cluster", periodo, grupo, nombregrupo, estado;
-----------------------------------
CREATE OR REPLACE VIEW cvp.frecCambio_Nivel1 AS
SELECT distinct cvp.devolver_mes_anio(periodo) PeriodoNombre, 
    periodo, 
    substr(x.grupo,1,3) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster") AS cantobsporgrupo, 
    ROUND(COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,3), estado, x."cluster")/COUNT(substr(x.grupo,1,3)) OVER (PARTITION BY periodo, substr(x.grupo,1,3), x."cluster")::decimal*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT
        o.periodo, g.grupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
            WHEN o.promobs > o1.promobs THEN 'Subió' 
            ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        join cvp.calculos_def cd on o.calculo = cd.calculo
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 on o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg on o.producto = gg.grupo
        LEFT JOIN cvp.grupos g on gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p on o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE cd.principal AND  g.agrupacion = 'Z' AND g.nivel = 3 AND o.impobs like 'R%' AND o1.impobs like 'R%'  
      ) as x
    LEFT JOIN cvp.grupos u ON substr(x.grupo,1,3) = u.grupo
    WHERE periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;
------------------------------------------------------------------------------
CREATE OR REPLACE VIEW cvp.freccambio_nivel0 AS
SELECT distinct cvp.devolver_mes_anio(periodo) Periodonombre, 
    periodo, 
    substr(x.grupo,1,2) grupo, 
    nombregrupo, 
    estado, 
    EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobs,
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster")) as promgeoobsant,
    ROUND((EXP(AVG(LN(promobs)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))/
    EXP(AVG(LN(promobsant)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), nombregrupo, estado, x."cluster"))*100-100)::NUMERIC,1) as variacion,
    COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster") AS cantobsporestado, 
    COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster") AS cantobsporgrupo, 
    ROUND((COUNT(producto) OVER (PARTITION BY periodo, substr(x.grupo,1,2), estado, x."cluster")/ COUNT(substr(x.grupo,1,2)) OVER (PARTITION BY periodo, substr(x.grupo,1,2), x."cluster")::decimal)*100,2) AS porcobs 
    , x."cluster"
FROM (SELECT o.periodo, g.grupo, 
        CASE WHEN o.promobs < o1.promobs THEN 'Bajó' 
            WHEN o.promobs > o1.promobs THEN 'Subió' 
            ELSE 'Igual' 
        END as estado,
        o.producto, p.nombreproducto, o.informante, o.observacion, o.division, o.promobs, o.impobs, o1.promobs as promobsant, o1.impobs as impobsant, 
        coalesce(par.solo_cluster, p."cluster") as "cluster",
        COUNT(o.producto) OVER (PARTITION BY o.periodo, o.producto, coalesce(par.solo_cluster, p."cluster")) AS cantobs
        FROM cvp.calobs o
        JOIN cvp.calculos_def cd on o.calculo = cd.calculo 
        LEFT JOIN cvp.calculos c ON o.periodo = c.periodo AND o.calculo = c.calculo
        LEFT JOIN cvp.calobs o1 ON o1.periodo = c.periodoanterior AND o1.calculo = c.calculoanterior AND o.producto = o1.producto AND o.informante = o1.informante AND o.observacion = o1.observacion
        LEFT JOIN cvp.gru_grupos gg ON o.producto = gg.grupo
        LEFT JOIN cvp.grupos g ON gg.grupo_padre = g.grupo AND gg.agrupacion = g.agrupacion
        LEFT JOIN cvp.productos p ON o.producto = p.producto
        LEFT JOIN cvp.parametros par ON unicoregistro
        WHERE cd.principal AND g.agrupacion = 'Z' AND g.nivel = 0 AND o.impobs like 'R%' AND o1.impobs like 'R%'
      ) as x
      LEFT JOIN cvp.grupos u ON substr(x.grupo,1,2) = u.grupo  
    WHERE periodo >= 'a2017m01'
    ORDER BY "cluster", periodo, grupo, nombregrupo, estado;
------
--res_cuadro_matriz_canasta
CREATE OR REPLACE FUNCTION res_cuadro_matriz_canasta(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, p_hogar text, p_periododesde text, p_separador text)
  returns setof cvp.res_mat
  language plpgsql
as
$BODY$
declare
    v_formato_renglon text:=case when pPonerCodigos then 'DW1n'::text else 'D.Wn'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E111'::text else 'E1.1'::text end;
    v_linea_alimentaria text:=case when parametro4 = 'B' then 'CA' when parametro4 = 'D' then 'LI' else '' end;
    v_linea_total text:=case when parametro4 = 'B' then 'CT' when parametro4 = 'D' then 'LP' else '' end;
    v_basica text:=case when parametro4 <> 'B' then 'Básica ' else '' end;

begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      null::text,
                      100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      case when pPonerCodigos then 'Cód'::text else 'Componentes de las diferentes canastas'::text end,
                      case when pPonerCodigos then 'Componentes de las diferentes canastas'::text else null end,
                      null::text,
                      null::text;
  return query  SELECT v_formato_renglon::text as formato_renglon,
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                  ELSE v.nombregrupo END ::text as lateral2,
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                    join calculos_def cd on v.calculo = cd.calculo
				  WHERE v.agrupacion = parametro4 /*B*/
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta '||v_basica||'alimentaria ('||v_linea_alimentaria||')**'::text as lateral2,
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round((v.valorhoggru::numeric/30),2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                    join calculos_def cd on v.calculo = cd.calculo 
				  WHERE v.agrupacion = parametro4 /*B*/
                    and cd.principal
                    and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                    and v.hogar = p_hogar --tiene que ser parametro
                    and v.grupo in ('B1','D1') --es la canasta alimentaria
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta '||v_basica||'total ('||v_linea_total||')**'::text as lateral2,
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round((v.valorhoggru::numeric/30),2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                          join calculos_def cd on v.calculo = cd.calculo
						  WHERE v.agrupacion = parametro4 /*B*/
                            and cd.principal
                            and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                            and v.hogar = p_hogar --tiene que ser parametro
                            and v.grupo in ('B4','D5') --es la canasta total
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;
-----------------------------------
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
                  devolver_mes_anio(v.periodo) as lateral1,
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
                  devolver_mes_anio(v.periodo) as lateral1,
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

	