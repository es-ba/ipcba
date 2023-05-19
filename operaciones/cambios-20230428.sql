set search_path = cvp;

CREATE OR REPLACE FUNCTION revisorFilasPreparar(pperiododesde text, pperiodohasta text, pProducto text, pProceso text)
RETURNS void AS
$BODY$
DECLARE
vSqlDeleteType text;
vSqlType text;
vSqlOwner text;
vSqlDrop text;
vSqlCreate text;
vSqlInsert text;
vciclo RECORD;
vActual text;
vAnterior text;
pSeparadorDecimal text := '.';
vversionCliente text := 'V230310';
vversionBaseConsiderada text := 'V130417';
vcondicionVersionOk text;
vCalculo integer := (select calculo from calculos_def where principal);
--pProducto text := 'Q0114611';
BEGIN
set search_path = cvp;
vSqlDrop := $$drop function if exists cvp.revisorFilasCrear();$$;
raise notice 'sentencia drop: %', vsqlDrop;
EXECUTE vSqlDrop;

vcondicionVersionOk := $$ AND (rr.versionExigida <= '$$ || vversionCliente || $$' and rr.versionBase>= '$$ || vversionBaseConsiderada || $$') $$;
------------------------------------------------------------------------------------------------------------------
vSqlDeleteType := $$drop table if exists revisorFilas cascade;$$;
raise notice 'sentencia deletetype: %', vsqlDeleteType;
EXECUTE vSqlDeleteType;
------------------------------------------------------------------------------------------------------------------
vSqlType := $$CREATE TEMP TABLE revisorFilas (division text, informante integer, observacion integer$$;
for vciclo in
   SELECT periodo, periodo = pperiododesde AS soyelprimero, periodo = pperiodohasta AS soyelultimo, case when periodo = pperiodohasta then moverperiodos(periodo,1) else null end as siguiente 
     FROM periodos
     WHERE periodo between pperiododesde and pperiodohasta
     ORDER BY periodo
Loop
  If (pProceso = 'MatrizV' Or pProceso = 'MatrizVPT') And not vciclo.soyelprimero Then
    vSqlType:=vSqlType ||', '|| vciclo.periodo || '_var text';
  end if;
  vSqlType:=vSqlType||', '|| vciclo.periodo||'_pr text, '||vciclo.periodo||'_tipo text, '||vciclo.periodo||'_panel integer, '||vciclo.periodo||'_tarea text, '||vciclo.periodo ||'_enc text';
  if vciclo.soyelultimo then  
    vSqlType :=  vSqlType ||', '|| vciclo.siguiente || '_var text, maxperiodoinformado text, maxperiodoconprecio text);';
  end if;
end loop;
raise notice 'sentencia type: %', vsqlType;
EXECUTE vSqlType;
------------------------------------------------------------------------------------------------------------------
vSqlOwner := $$ALTER TABLE revisorFilas OWNER TO cvpowner; GRANT SELECT ON TABLE revisorFilas TO cvp_usuarios;$$;
raise notice 'sentencia owner: %', vSqlOwner;
EXECUTE vSqlOwner;

------------------------------------------------------------------------------------------------------------------
vSqlInsert := $$INSERT INTO revisorFilas 
                 SELECT * FROM (
                    --Primera parte, agrega información del producto (calobs)
                    SELECT c.division||'-'||coalesce(i.nombreinformante,'') as division, c.informante, c.observacion$$;
for vciclo in
   SELECT periodo, periodoanterior, periodo = pperiododesde AS soyelprimero 
     FROM periodos
     WHERE periodo between pperiododesde and pperiodohasta
     ORDER BY periodo
Loop
  vActual   := vciclo.periodo;
  vAnterior := vciclo.periodoanterior;
  If (pProceso = 'MatrizV' Or pProceso = 'MatrizVPT') And not vciclo.soyelprimero Then
    vSqlInsert := 
    vSqlInsert ||$$,replace((case when avg(case when c.periodo='$$ || vAnterior || $$' and c.antiguedadIncluido>0 then c.promObs else null end)>0
                               then round((avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)
                                        / avg(case when c.periodo='$$ || vAnterior || $$' and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)
                               else null end)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_var';
  End If;
  vSqlInsert := 
  vSqlInsert || $$,case when avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)>0
                     then max(case when c.periodo='$$ || vActual || $$' and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)
                     ||replace(avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','$$ || pSeparadorDecimal || $$')
                   else max(case when c.periodo='$$ || vActual || $$' and c.antiguedadexcluido>0 then 'X ' else '' end)||
                        max(case when c.periodo='$$ || vActual || $$' then coalesce(substr(o.estado,1,1)||' ','') else '' end)||
                        string_agg(case when c.periodo='$$ || vActual || $$' and c.antiguedadexcluido>0 then 
                                    replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,
                                                   strpos(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text 
                                            ,'.','$$ || pSeparadorDecimal || $$') 
                                    else null end,';' ORDER BY r.visita) end as $$ || vActual || '_pr'|| 
               $$, max(case when c.periodo='$$ || vActual || $$' then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)
                   || coalesce(string_agg(case when c.periodo='$$ || vActual || $$' then coalesce(r.tipoprecio,'')|| coalesce(','||r.cambio,'')
                                               --agregar los atributos y precios de los tipoprecio = M
                                               || case when r.tipoprecio in ('M','A') then 
                                                   coalesce(' '||comun.a_texto(bp.precio),'')||coalesce(' '||bp.tipoprecio,'')||coalesce(' '||ba.valores,'') 
                                                   else '' end
                                               || case when pat.valorprincipal is not null then ' '||pat.valorprincipal 
                                                   else '' end 
                                           else null end
                                           ||case when o.estado is not null then ' '||o.estado||'Manual ' 
                                              else '' end
                                           ||case when ((z.escierredefinitivoinf = 'S' or z.escierredefinitivofor = 'S') or v.informante is null and c.promobs is not null 
                                              and vv.informante is null) then ' '||'| Inactivo ' 
                                              else ''::text end,';' ORDER BY r.visita),'') 
                                           || case when min(pr.periodo)='$$ || vActual || $$' and min(pr.periodo ) is not null then ',®' 
                                               else ' ' end as  $$ || vActual || '_tipo';
  If pProceso = 'MatrizVPT' Then
      vSqlInsert := 
      vSqlInsert || $$ , min(case when c.periodo='$$ || vActual || $$' then v.panel else null end) as $$ || vActual || '_panel'||
                    $$ , min(case when c.periodo='$$ || vActual || $$' then 
                              concat(v.tarea,case when tar.modalidad is not null then 
                                              '/'||tar.modalidad else null end) 
                              else null end) as $$ || vActual || '_tarea';
  End If;
  vSqlInsert := 
  vSqlInsert || $$, coalesce(string_agg(case when c.periodo = '$$ || vActual || $$' then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')
             ||CASE WHEN coalesce(string_agg(case when c.periodo = '$$ || vActual || $$' then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' then '/' else '' end
             ||min(case when c.periodo='$$ || vActual || $$' then (case when v.recepcionista is null then '' else v.recepcionista end)::text else null end)||'/'
             ||min(case when c.periodo='$$ || vActual || $$' then v.encuestador::text||':'||per.apellido else null end) as $$ || vActual || '_enc';
end loop;
If pProceso = 'MatrizVPT' Then
    --Agregar la variacion interanual del último periodo
    vSqlInsert := 
    vSqlInsert || $$,replace((case when avg(case when varint.periodo=cvp.moverperiodos('a2022m02',-12) and varint.antiguedadIncluido>0 
                                             then varint.promObs else null end)>0
                               then round((avg(case when c.periodo='a2022m02' and c.antiguedadIncluido>0 then c.promObs else null end)
                                          / avg(case when varint.periodo=cvp.moverperiodos('a2022m02',-12) and varint.antiguedadIncluido>0 
                                                 then varint.promObs else null end)*100-100)::numeric,1)
                               else null end)::text,'.','$$ || pSeparadorDecimal || $$')::numeric as $$ || vActual || '_var';
Else
    vSqlInsert := vSqlInsert || $$,   null::numeric as $$ || vActual || '_var';
End If;
vSqlInsert := 
vSqlInsert || $$ , min(case when c.periodo='a2022m02' then pmax.maxperiodoinformado else null end) as maxperiodoinformado
, min(case when c.periodo='a2022m02' then cur.maxperiodoconprecio else null end) as maxperiodoconprecio
FROM cvp.calobs c 
   LEFT JOIN cvp.relpre r on r.informante=c.informante and r.producto=c.producto and r.periodo=c.periodo and r.observacion=c.observacion
   LEFT JOIN cvp.relvis v on v.informante=r.informante and v.periodo=r.periodo and v.visita=r.visita and v.formulario=r.formulario
   LEFT JOIN (SELECT * FROM cvp.prerep WHERE periodo>='a2022m01' and periodo <='a2022m02') pr
             on pr.informante=c.informante and pr.producto=c.producto and pr.periodo=c.periodo
   --agregar los atributos y precios de los tipoprecio = M
   LEFT JOIN cvp.blapre bp on r.informante=bp.informante and r.producto=bp.producto and r.periodo=bp.periodo and r.observacion=bp.observacion and r.visita = bp.visita
   LEFT JOIN (SELECT periodo, producto, informante, observacion, visita, string_agg(valor,',' ORDER BY atributo) as valores
              FROM cvp.blaatr
              WHERE Valor Is Not Null
              GROUP BY periodo, producto, informante, observacion, visita) ba
              on r.informante=ba.informante and r.producto=ba.producto and r.periodo=ba.periodo and r.observacion=ba.observacion and r.visita = ba.visita
   --agregar el valor del atributo principal y atributo marca
   LEFT JOIN (SELECT x.periodo, x.producto, x.informante, x.observacion, x.visita, 
               string_agg(CASE WHEN y.esprincipal= 'S' THEN CONCAT(x.valor,a.unidaddemedida)
                           WHEN a.nombreatributo = 'Marca' THEN x.valor 
                           ELSE NULL END,';' ORDER BY a.atributo) as valorprincipal
              FROM cvp.relatr x 
              LEFT JOIN cvp.prodatr y ON x.producto = y.producto AND x.atributo = y.atributo
              LEFT JOIN cvp.atributos a ON y.atributo = a.atributo
              GROUP BY x.periodo, x.producto, x.informante, x.observacion, x.visita) pat
              on r.informante=pat.informante and r.producto=pat.producto and r.periodo=pat.periodo and r.observacion=pat.observacion and r.visita = pat.visita
   LEFT JOIN cvp.personal per ON v.encuestador = per.persona
   --agregar las altas/bajas manuales
   LEFT JOIN cvp.novobs o ON c.periodo = o.periodo and c.calculo = o.calculo and c.producto = o.producto and c.informante = o.informante and c.observacion = o.observacion
   --agregar los informantes Inactivos
   LEFT JOIN cvp.razones z ON v.razon = z.razon
   --para ver si está pendiente de ingreso, si es así no hay que poner la leyenda Inactivo
   LEFT JOIN cvp.forprod fp ON c.producto = fp.producto
   LEFT JOIN cvp.formularios formu ON formu.formulario = fp.formulario
   --para agregar el nombreinformante
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   JOIN cvp.forinf fi ON fp.formulario = fi.formulario and c.informante = fi.informante
   LEFT JOIN cvp.relvis vv on c.periodo = vv.periodo and fi.informante = vv.informante and fi.formulario = vv.formulario and vv.ultima_visita$$;

If pProceso = 'MatrizVPT' Then
    --Agregar la variacion interanual del último periodo
    vSqlInsert := 
    vSqlInsert || $$ LEFT JOIN cvp.calobs varint on cvp.moverperiodos(c.periodo,-12) = varint.periodo and c.calculo = varint.calculo and c.producto = varint.producto
                                                 and c.informante = varint.informante and c.observacion = varint.observacion $$;
End If;
--Agregar el último periodo informado
vSqlInsert := vSqlInsert || $$LEFT JOIN (SELECT informante, max(periodo) maxperiodoinformado FROM cvp.relvis WHERE razon = 1 GROUP BY informante) pmax on c.informante = pmax.informante $$;
If pProceso = 'MatrizVPT' Then
    --Agregar modalidad
    vSqlInsert := vSqlInsert || $$LEFT JOIN (SELECT periodo, panel, tarea, modalidad from cvp.reltar where modalidad is not null) tar on c.periodo = tar.periodo and vv.panel = tar.panel and vv.tarea = tar.tarea $$;
End If;
--Agregar el último periodo con precio real
vSqlInsert := 
vSqlInsert ||$$LEFT JOIN (SELECT calculo, producto, informante, observacion, max (periodo) maxperiodoconprecio 
                           from cvp.calobs 
                           where calculo = $$ || vCalculo || $$ and impobs like 'R%' and periodo <'a2022m02' 
                           group by calculo, producto, informante, observacion) cur
                           on c.calculo = cur.calculo and c.producto = cur.producto and c.informante = cur.informante and c.observacion = cur.observacion
               , cvp.revisor_parametros rr
               WHERE c.producto = 'Q0111111' and c.calculo= $$ || vCalculo || $$ and formu.activo = 'S' $$ || vcondicionVersionOk
            ||$$GROUP BY c.division, c.informante, c.observacion, i.nombreinformante) as X ORDER BY 1,2,3$$;

vSqlInsert := replace(replace(replace(vsqlInsert, $$'a2022m01'$$, quote_literal(pperiododesde)), $$'a2022m02'$$, quote_literal(pperiodohasta)), $$'Q0111111'$$, quote_literal(pproducto));
raise notice 'sentencia Insert: %', vsqlInsert;

EXECUTE vSqlInsert;

vSqlCreate := $$CREATE or replace FUNCTION revisorFilasCrear() RETURNS SETOF revisorFilas AS $CUERPO$
   set search_path = cvp; 
   SELECT * FROM revisorFilas;
$CUERPO$ LANGUAGE SQL;$$;
raise notice 'sentencia create: %', vsqlCreate;
EXECUTE vSqlCreate;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION revisorFilasPreparar(text,text,text,text) OWNER TO cvpowner;
