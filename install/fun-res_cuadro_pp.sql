--res_cuadro_pp
CREATE OR REPLACE FUNCTION cvp.res_cuadro_pp(parametro1 text, p_periodo text, pdesde text, pempalmedesde boolean, 
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text)
  RETURNS SETOF res_mat2 
  language plpgsql
  AS
$BODY$
declare

    vAnchoNumeros text:='100';
    v_periodo_desde text:=pdesde;

begin
  return query select /*0::bigint,*/
                  'anchos'::text,
                  'auto'::text,
                  'auto'::text,
                  'auto'::text,
                  null::text,
                  vAnchoNumeros;

  return query select /*1::bigint,*/
                      'E1111'::text,
                      'Código de producto'::text,
                      'Descripción'::text,
                      'Unidad de medida'::text,
                      null::text,
                      'Precio relevado'::text;
  return query select /*row_number() over (order by q.ordenpor)+100,*/
                      q.formato_renglon, 
                      q.producto, q.nombreproducto, q.unidadmedidaabreviada, q.nombreperiodo, q.promprod
                 from 
                 (
                 select 
                    'D11Cn'::text as formato_renglon,
                    c.producto::text,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    devolver_mes_anio(periodo) as nombreperiodo,
                    replace(round(promDiv::numeric,2)::text,'.',p_separador) as promprod
                    /*,c.producto as ordenpor*/
                 from productos p inner join calDiv c on p.producto=c.producto and c.division='0'
                 inner join calculos_def cd on c.calculo = cd.calculo
                 where cd.principal and p."cluster" is distinct from 3
                   and periodo between v_periodo_desde and p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
                 order by c.producto, c.periodo
                ) as q
               ;
end;
$BODY$;
--test
--SELECT * from cvp.res_cuadro_pp(' ', 'a2022m04', 'a2022m01', true, false , 'a2022m02', ',');
