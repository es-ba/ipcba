CREATE OR REPLACE VIEW revisor AS 
SELECT * FROM (
SELECT c.producto, c.division, c.informante, c.observacion
 , case when avg(case when pe.nroperiodo=1 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=1 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||
   replace(avg(case when pe.nroperiodo=1 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=1 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=1 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=1 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo1_pr
 , max(case when pe.nroperiodo=1 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=1 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2016m10' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo1_tipo
 , coalesce (string_agg(case when pe.nroperiodo=1 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=1 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=1 then v.encuestador::text||':'||per.apellido else null end) as periodo1_enc
 , replace((case when avg(case when pe.nroperiodo=1 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then round((avg(case when pe.nroperiodo=2 and c.antiguedadIncluido>0 then c.promObs else null end)
        / avg(case when pe.nroperiodo=1 and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
   else null end)::text,'.','.') as periodo1_var
   
   
 , case when avg(case when pe.nroperiodo=2 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=2 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||replace(avg(case when pe.nroperiodo=2 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=2 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=2 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=2 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo2_pr
 , max(case when pe.nroperiodo=2 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=2 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2016m11' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo2_tipo
 , coalesce (string_agg(case when pe.nroperiodo=2 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=2 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=2 then v.encuestador::text||':'||per.apellido else null end) as periodo2_enc
 , replace((case when avg(case when pe.nroperiodo=2 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then round((avg(case when pe.nroperiodo=3 and c.antiguedadIncluido>0 then c.promObs else null end)
        / avg(case when pe.nroperiodo=2 and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
   else null end)::text,'.','.') as periodo2_var
   
   
 , case when avg(case when pe.nroperiodo=3 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=3 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||replace(avg(case when pe.nroperiodo=3 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=3 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=3 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=3 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo3_pr
 , max(case when pe.nroperiodo=3 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=3 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2016m12' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo3_tipo
 , coalesce (string_agg(case when pe.nroperiodo=3 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=3 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=3 then v.encuestador::text||':'||per.apellido else null end) as periodo3_enc
 , replace((case when avg(case when pe.nroperiodo=3 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then round((avg(case when pe.nroperiodo=4 and c.antiguedadIncluido>0 then c.promObs else null end)
        / avg(case when pe.nroperiodo=3 and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
   else null end)::text,'.','.') as periodo3_var
   
   
 , case when avg(case when pe.nroperiodo=4 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=4 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||replace(avg(case when pe.nroperiodo=4 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=4 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=4 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=4 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo4_pr
 , max(case when pe.nroperiodo=4 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=4 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2017m01' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo4_tipo
 , coalesce (string_agg(case when pe.nroperiodo=4 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=4 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=4 then v.encuestador::text||':'||per.apellido else null end) as periodo4_enc
 , replace((case when avg(case when pe.nroperiodo=4 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then round((avg(case when pe.nroperiodo=5 and c.antiguedadIncluido>0 then c.promObs else null end)
        / avg(case when pe.nroperiodo=4 and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
   else null end)::text,'.','.') as periodo4_var
   
   
 , case when avg(case when pe.nroperiodo=5 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=5 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||replace(avg(case when pe.nroperiodo=5 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=5 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=5 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=5 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo5_pr
 , max(case when pe.nroperiodo=5 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=5 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2017m02' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo5_tipo
 , coalesce (string_agg(case when pe.nroperiodo=5 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=5 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=5 then v.encuestador::text||':'||per.apellido else null end) as periodo5_enc
 , replace((case when avg(case when pe.nroperiodo=5 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then round((avg(case when pe.nroperiodo=6 and c.antiguedadIncluido>0 then c.promObs else null end)
        / avg(case when pe.nroperiodo=5 and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
   else null end)::text,'.','.') as periodo5_var
   
   
 , case when avg(case when pe.nroperiodo=6 and c.antiguedadIncluido>0 then c.promObs else null end)>0 
   then max(case when pe.nroperiodo=6 and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)||replace(avg(case when pe.nroperiodo=6 and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','.') 
   else max(case when pe.nroperiodo=6 and c.antiguedadexcluido>0 then 'X '     else '' end)||
      max(case when pe.nroperiodo=6 then substr(o.estado,1,1)||' ' else '' end)||
      string_agg(case when pe.nroperiodo=6 and c.antiguedadexcluido>0 then 
      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
      ,'.','.') else null end,';' ORDER BY r.visita) end as periodo6_pr
 , max(case when pe.nroperiodo=6 then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
   || coalesce(string_agg(case when pe.nroperiodo=6 then coalesce(r.tipoprecio,'')
   || coalesce(','||r.cambio,'') 
   || case when r.tipoprecio ='M' then coalesce(' '||comun.a_texto(bp.precio),'') 
   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end
   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end 
 else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end , 
';' ORDER BY r.visita),'') /*|| case  when  min(pr.periodo)='a2017m03' and  min(pr.periodo ) is not null then ',®' else ' ' end */ as  periodo6_tipo
 , coalesce (string_agg(case when pe.nroperiodo=6 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') 
||CASE WHEN coalesce (string_agg(case when pe.nroperiodo=6 then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END 
||min(case when pe.nroperiodo=6 then v.encuestador::text||':'||per.apellido else null end) as periodo6_enc
 FROM
    cvp.calobs c
    LEFT JOIN (SELECT row_number() OVER (order by periodo)::integer as nroperiodo, * FROM (SELECT periodo FROM cvp.calculos WHERE calculo = 0 ORDER BY periodo desc LIMIT 6) p) pe 
    on c.periodo = pe.periodo
    LEFT JOIN cvp.relpre r on r.informante=c.informante and r.producto=c.producto and r.periodo=c.periodo 
         and r.observacion=c.observacion 
    LEFT JOIN cvp.relvis v on v.informante=r.informante and v.periodo=r.periodo and v.visita=r.visita and v.formulario=r.formulario 
    --LEFT JOIN cvp.prerep pr on pr.informante=c.informante and pr.producto=c.producto and pr.periodo=c.periodo 
    LEFT JOIN cvp.blapre bp on r.informante=bp.informante and r.producto=bp.producto and r.periodo=bp.periodo and r.observacion=bp.observacion and r.visita = bp.visita 
    LEFT JOIN (SELECT periodo, producto, informante, observacion, visita, string_agg(valor,',' ORDER BY atributo) as valores 
               FROM cvp.blaatr 
               WHERE Valor Is Not Null
               GROUP BY periodo, producto, informante, observacion, visita) ba 
               on r.informante=ba.informante and r.producto=ba.producto and r.periodo=ba.periodo and r.observacion=ba.observacion and r.visita = ba.visita 
    LEFT JOIN (SELECT x.periodo, x.producto, x.informante, x.observacion, x.visita, string_agg(coalesce(x.valor,'')||coalesce(a.unidaddemedida,''),';' ORDER BY x.atributo) as valorprincipal
                 FROM cvp.relatr x LEFT JOIN cvp.prodatr y ON x.producto = y.producto AND x.atributo = y.atributo
                 LEFT JOIN cvp.atributos a ON y.atributo = a.atributo
                 WHERE y.esprincipal = 'S'
                 GROUP BY x.periodo, x.producto, x.informante, x.observacion, x.visita) pat
               on r.informante=pat.informante and r.producto=pat.producto and r.periodo=pat.periodo and r.observacion=pat.observacion and r.visita = pat.visita 
    LEFT JOIN cvp.personal per ON v.encuestador = per.persona 
    LEFT JOIN cvp.novobs o ON c.periodo = o.periodo and c.calculo = o.calculo and c.producto = o.producto and c.informante = o.informante and c.observacion = o.observacion 
       , cvp.revisor_parametros rr 
 WHERE c.calculo=0
       AND (rr.versionExigida <= 'V170111' and rr.versionBase>= 'V130417') 
 GROUP BY c.producto, c.division, c.informante, c.observacion
) as X 
 ORDER BY 1,2,3,4;

GRANT SELECT ON TABLE revisor TO cvp_usuarios;
GRANT SELECT ON TABLE revisor TO cvp_recepcionista;
