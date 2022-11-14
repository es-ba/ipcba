set search_path = cvp;
--res_cuadro_ivebs
--UTF8=Sí
create or replace function res_cuadro_ivebs(parametro1 text, p_periodo_hasta text, parametro3 integer, parametro4 text, p_periodo_desde text, p_separador text) 
  returns setof res_col10
  language plpgsql
as
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text;
begin
  
  v_periodo_desde := p_periodo_desde;
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros, vAnchoNumeros, vAnchoNumeros;
  return query select 1::bigint, case when parametro4='S' then 'U5.7...7...'::text else 'U5.0...0...'::text end ,'Mes'::text, null::text,'Indice¹'::text,null::text, null::text, null::text,'Variación porcentual'::text,null::text, null::text, null::text;
  return query select 2::bigint, case when parametro4='S' then 'P..RRR.RRR.'::text else 'P..RRRRRRRR'::text end, null::text,null::text, 
               'Nivel General'::text, case when parametro4='S' then 'Bienes'::text  else 'Estacionales'::text end, 
                case when parametro4='S' then 'Servicios'::text else 'Regulados'::text end, 
                case when parametro4='S' then null::text  else 'Resto'::text end,
                'Nivel General'::text,
                case when parametro4='S' then 'Bienes'::text  else 'Estacionales'::text end, 
                case when parametro4='S' then 'Servicios'::text else 'Regulados'::text end, 
                case when parametro4='S' then null::text  else 'Resto'::text end;
  return query select row_number() over (order by c.periodo)+100, 
                 case when parametro4='S' then 'D11nnn.nnn.'::text  else 'D11nnnnnnnn'::text  end as formato_renglon,
                 --cvp.devolver_mes(c.periodo), case when p_periodo_hasta =c.periodo then substr(c.periodo,2,4)||'*' else substr(c.periodo,2,4) end, 
                 cvp.devolver_mes_anio(c.periodo),''::text, 
                 replace(round(c.indiceRedondeado::numeric,2)::text,'.',p_separador)::text, 
                 replace(round(b.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadobienes, 
                 replace(round(s.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadoserv,
                 case when parametro4='S' then null::text else  
                   replace(round(r.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  end as indiceRedondeadoresto,  
                 case when co.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((c.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,  
                 case when bo.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((b.indiceRedondeado/bo.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when so.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((s.indiceRedondeado/so.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when parametro4='S' then null::text else    
                 case when ro.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((r.indiceRedondeado/ro.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end  end 
                 from calgru c --nivel general
				 join calculos_def cd on c.calculo = cd.calculo
                 join calgru b on c.agrupacion=b.agrupacion and c.calculo=b.calculo and c.periodo=b.periodo  
                 join calgru s on c.agrupacion=s.agrupacion and c.calculo=s.calculo and c.periodo=s.periodo
                 join calgru r on c.agrupacion=r.agrupacion and c.calculo=r.calculo and c.periodo=r.periodo
                 join calculos ca  on ca.periodo=c.periodo and ca.calculo=c.calculo --pk verificada
                 left join calgru co on co.agrupacion=c.agrupacion and co.grupo=c.grupo and co.calculo=ca.calculoanterior and co.periodo=ca.periodoanterior 
                 left join calgru bo on bo.agrupacion=b.agrupacion and bo.grupo=b.grupo and bo.calculo=ca.calculoanterior and bo.periodo=ca.periodoanterior
                 left join calgru so on so.agrupacion=s.agrupacion and so.grupo=s.grupo and so.calculo=ca.calculoanterior and so.periodo=ca.periodoanterior 
                 left join calgru ro on ro.agrupacion=r.agrupacion and ro.grupo=r.grupo and ro.calculo=ca.calculoanterior and ro.periodo=ca.periodoanterior 
                 where c.agrupacion=parametro4 and cd.principal and c.periodo <= p_periodo_hasta and c.periodo >= v_periodo_desde and c.nivel=parametro3  
                   and b.grupo=parametro4||'1' 
                   and s.grupo=parametro4||'2'
                   and (case when c.agrupacion='S' then r.grupo='S1' else r.grupo='R3' end) ;    
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_ivebs('Mes', 'a2022m05'::text, 0, 'S'::text, 'a2022m01'::text,',');  --cuadro A1
