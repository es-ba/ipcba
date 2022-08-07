set search_path = cvp;
ALTER TABLE cuadros ADD COLUMN activo cvp.sino_dom default 'S';

--res_cuadro_up
create or replace function res_cuadro_up(parametro1 text, p_periodo text, parametro4 text, pPonercodigos boolean, p_separador text) 
  returns setof res_col4
  language plpgsql
as
$BODY$
declare

    vAnchoNumeros text:='100';

begin
  return query select 0::bigint,'anchos'::text,
       'auto'::text,
       'auto'::text,'auto'::text,vAnchoNumeros;

  return query select 1::bigint,case when pPonerCodigos then 'ULLLR'::text else 'U2.LR'::text end, 
                 case when pPonerCodigos then 'Código de Producto'::text else 'Descripción'::text end,
                 case when pPonerCodigos then 'Descripción'::text else null end, 'Unidad de medida'::text, 'Precio medio'::text;
  return query select row_number() over (order by q.grupopadre, q.orden, q.producto)+100,
                    q.formato_renglon, q.producto, q.nombreproducto, q.unidadmedidaabreviada, q.promprod
                 from 
                 (
                 select 
                    --'D111n'::text
                    --as formato_renglon,
                    case when pPonerCodigos then 'D111n' else 'D.21n' end as formato_renglon,
                    grupopadre,
                    case when pPonerCodigos then producto::text else null end as producto,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    replace(round(promprod::numeric,2)::text,'.',p_separador) as promprod,
                    grupopadre||producto::text as ordenpor, coalesce(cg.orden, 0) as orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 left join cuagru cg on p.agrupacion = cg.agrupacion and p.producto = cg.grupo and cg.cuadro = CASE WHEN parametro4 = 'C1' THEN '7' ELSE '6' END
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_Periodo
               
                 union
                 select distinct --row_number() over (ordenpor)+100, 
                    'G.2..' as formato_renglon, 
                    grupopadre, 
                    'Q0000000' as producto,
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada, 
                    null as promprod,
                    grupopadre||'Q0000000'::text as ordenpor, 0 AS orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_periodo
                ) as q
               ;
end;
$BODY$;

--res_cuadro_matriz_up
create or replace function res_cuadro_matriz_up(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, pdesde text, porden text, p_separador text) 
  returns setof res_mat2
  language plpgsql
as
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text:=pdesde; --'a2013m01';
    v_formato_renglon text:=case when pPonerCodigos then 'DW11n'::text else 'D.W2n'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E1111'::text else 'E1.21'::text end;
    v_formato_renglon_padres text:=case when pPonerCodigos then 'GW11n'::text else 'G.W2n'::text end;
    
begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      'auto'::text,
                      null::text,
                      vAnchoNumeros;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      case when pPonerCodigos then 'Producto'::text else 'Descripción'::text end,
                      case when pPonerCodigos then 'Descripción'::text else null end,
                      'Unidad de medida'::text,
                      null::text,
                      null::text;
  return query select formato_renglon, producto, nombreproducto, unidadmedidaabreviada, nombreperiodo, promprod from (
                select case when porden = 'desc' then row_number() over (order by periodo desc , q.grupopadre, q.orden, q.producto)+100 
                         else row_number() over (order by periodo, q.grupopadre, q.orden, q.producto)+100 end,
                    q.formato_renglon, q.producto, q.nombreproducto, q.unidadmedidaabreviada,
                    devolver_mes_anio(periodo) as nombreperiodo, q.promprod
                 from 
                 (select * from
                 (
                 select 
                    v_formato_renglon::text as formato_renglon,
                    p.grupopadre,
                    case when pPonerCodigos then producto::text else null end as producto,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    periodo,
                    replace(round(promprod::numeric,2)::text,'.',p_separador) as promprod,
                    /*periodo||*/p.grupopadre||producto::text as ordenpor, coalesce(cg.orden, 0) as orden
                 from preciosmedios_albs_var p
                      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo
                      left join cuagru cg on p.agrupacion = cg.agrupacion and p.producto = cg.grupo and cg.cuadro = CASE WHEN parametro4 = 'C1' THEN '7h' 
                                                                                                                         WHEN parametro4 = 'C2' THEN '6h'
                                                                                                                         WHEN parametro4 = 'E1' THEN '7hApp'
                                                                                                                         ELSE '6hApp' END
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal and coalesce(u.nivel,1) = 1
                   and periodo between v_periodo_desde and p_Periodo
               
                 union
                 select distinct  
                    v_formato_renglon_padres::text as formato_renglon,
                    p.grupopadre, 
                    'Q0000000' as producto, 
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada,
                    periodo,
                    null as promprod,
                    /*periodo||*/p.grupopadre||'Q0000000'::text as ordenpor, 0 as orden
                 from preciosmedios_albs_var p
                      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo 
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal
                   and periodo between v_periodo_desde and p_Periodo
                ) as d order by d.grupopadre, d.orden, d.producto, periodo) as q) as x
               ;
end;
$BODY$;

-------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION comun.cadena_valida(
    p_cadena text,
    p_version text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$
DECLARE
  /*
  select comun.cadena_valida(entrada, version)=resultado as ok, entrada, version, resultado as esperado, comun.cadena_valida(entrada, version) as recibido
    from (
      select 'Mauro01' as entrada, 'codigo' as version, true as resultado
      union select '/xñz1', 'codigo', false
      union select '/xñz1', 'castellano', true
      union select '/xñz1', 'formula', false 
      union select '{"pepe":"\\esto;",[]}', 'formula', false
      union select '{"pepe":"\\esto;",[]}', 'json', true
      union select 'a<99-', 'formula', true
      union select 'a<99-', 'codigo', false) x
    where comun.cadena_valida(entrada, version) is distinct from resultado 
  
  */
  caracteres_permitidos_codigo text:='A-Za-z0-9_';
  caracteres_permitidos_extendido text:='-'||caracteres_permitidos_codigo||' ,/*+().$@!#:%';
  caracteres_permitidos_castellano text:=caracteres_permitidos_extendido||'ÁÉÍÓÚÜÑñáéíóúüçÇ¿¡?!';
  caracteres_permitidos_formula text:=caracteres_permitidos_extendido||'<>=';
  caracteres_permitidos_castellano_formula text:=caracteres_permitidos_castellano||'<>=';
  caracteres_permitidos_json text:=caracteres_permitidos_formula||'{}"\[\]\\|&^~'';';
  caracteres_permitidos_amplio text:=caracteres_permitidos_castellano_formula||'{}"\[\]\\|&^~'';º³¹';
  caracteres_permitidos text;
  explicar boolean:=false;
  largo integer;
  expresion_regular text;
  v_juego_caracteres text:=p_version;
BEGIN
  if p_version like 'explicar%' then
    explicar:=true;
    v_juego_caracteres:=substr(p_version,length('explicar ')+1);
  end if;
  if v_juego_caracteres='cualquiera' then
    return true;
  end if;
  caracteres_permitidos:=case v_juego_caracteres
    when 'codigo' then caracteres_permitidos_codigo
    when 'extendido' then caracteres_permitidos_extendido
    when 'castellano' then caracteres_permitidos_castellano
    when 'formula' then caracteres_permitidos_formula
    when 'json' then caracteres_permitidos_json
    when 'castellano y formula' then caracteres_permitidos_castellano_formula
    when 'amplio' then caracteres_permitidos_amplio
  end;
  if caracteres_permitidos is null then
    raise exception 'Parametro invalido para p_version "%"',p_version;
  end if;
  expresion_regular:='^['||caracteres_permitidos||']*$';
  if explicar then
    largo := char_length(p_cadena);
    for i IN 1..largo LOOP
      if not (substr(p_cadena,i,1) ~ expresion_regular) THEN
        raise exception 'El caracter % es invalido (%)', substr(p_cadena,i,1), ascii(substr(p_cadena,i,1));
      END IF;
    END LOOP;
  end if;
  return p_cadena ~ expresion_regular;
END;
$BODY$;

set search_path = cvp;

ALTER TABLE cuadros
    DROP CONSTRAINT "texto invalido en parametro1 de tabla cuadros";
ALTER TABLE cuadros
    ADD CONSTRAINT "texto invalido en parametro1 de tabla cuadros" CHECK (comun.cadena_valida(parametro1::text, 'amplio'::text));
