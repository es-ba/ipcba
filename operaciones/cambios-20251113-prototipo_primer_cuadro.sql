set search_path = ccc;
set role cvpowner;
CREATE TABLE IF NOT EXISTS cuadros as
select * from cvp.cuadros where cuadro = '7';
UPDATE cuadros
	SET cuadro='1', 
	descripcion='Tabla de equivalencias y unidad consumidora según tipo de canasta alimentaria para varones y mujeres y rango de edades', 
	funcion='ccc_cuadro_up', 
	parametro1='Tabla de equivalencias', 
	grupo='G1', 
	encabezado='Cuadro 1||| IPCBA. Tabla de equivalencias y unidad consumidora según tipo de canasta alimentaria para varones y mujeres y rango de edades', 
	empalmedesde = false
	WHERE cuadro='7';

CREATE TABLE IF NOT EXISTS cuadros_funciones as
select * from cvp.cuadros_funciones where funcion = 'res_cuadro_up';
update cuadros_funciones set funcion = 'ccc_cuadro_up' where funcion = 'res_cuadro_up';

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
					 replace (round(c.valorgru::decimal,2)::text,'.',p_separador) valor, 
                     replace (round((c.valorgru * 30)::decimal, 2)::text,'.',p_separador) valor_mensual                    
				 from perfiles p
                 left join calgruper c on p.perfil = c.perfil
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

--test
SELECT * from ccc_cuadro_up(null, 'a2025m04'::text, 'G1', false, false , 'a2022m02','.');  
--SELECT * from ccc_cuadro_up(null, 'a2025m05'::text, 'G1', false, false , 'a2022m02','.');  

