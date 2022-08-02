--res_cuadro_vc
CREATE OR REPLACE FUNCTION cvp.res_cuadro_vc(
    parametro1 text,
    p_periodo text,
    parametro3 integer,
    parametro4 text,
    pponercodigos boolean,
    p_cuadro text,
    pdesde text, 
    p_separador text)
  RETURNS SETOF cvp.res_mat 
  language plpgsql
AS
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text := pdesde;
begin
  
  return query select /*0::bigint,*/ 'anchos'::text,'auto'::text,'auto'::text, null::text, vAnchoNumeros;
  return query select /*1::bigint,*/ case when pPonerCodigos then'ULLR'::text else 'U2.R' end, 
                                 case when pPonerCodigos then 'Código'::text else 'Descripción'::text end,  
                                 case when pPonerCodigos then 'Descripción'::text else null end, null::text, 'Valorgru'::text;
  return query select /*row_number() over (order by c.grupo, c.periodo)+100,*/ 
                      case when pPonerCodigos then 'D11n'::text else 'D.2n'::text end as formato_renglon,
                      case when pPonerCodigos then c.grupo::text /*substr(c.grupo,2)::text*/ else null end as grupo,
                      g.nombregrupo::text, devolver_mes_anio(c.periodo) as nombreperiodo,
                      --replace(round(c.valorgru::numeric,2)::text, '.',p_separador) as valorgru
                      replace(round((CASE WHEN p_cuadro = 'X1' then c.valorgru ELSE c.valorgrupromedio END)::numeric,2)::text, '.',p_separador) as valorgru
                 from calGru_promedios c inner join calculos_def cd on c.calculo = cd.calculo inner join cvp.grupos g on c.agrupacion=g.agrupacion and c.grupo=g.grupo
                 where periodo between v_periodo_desde and p_Periodo
                   and cd.principal
                   and c.agrupacion=parametro4
                   and (c.nivel=parametro3 and c.grupopadre in ('A31','A32','A51','D31','D51')
                       or c.nivel=parametro3-1 and c.grupo not in ('A31','A32','A51','D31','D51'))
                 order by c.grupo, c.periodo;
end;
$BODY$;

--test
--Invocacion cuadro Cuadro X1. Exportación valores de canasta para CEDEM
--SELECT * from cvp.res_cuadro_vc(null, 'a2022m05'::text, 3, 'A', true,'X1','a2013m01',',');
--SELECT * from cvp.res_cuadro_vc(null, 'a2022m05'::text, 3, 'A', true,'X2','a2013m01',',');