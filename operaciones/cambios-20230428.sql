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

vcondicionVersionOk := $$       AND (rr.versionExigida <= '$$ || vversionCliente || $$' and rr.versionBase>= '$$ || vversionBaseConsiderada || $$') $$;
------------------------------------------------------------------------------------------------------------------
vSqlDeleteType := $$drop table if exists revisorFilas cascade;$$;
raise notice 'sentencia deletetype: %', vsqlDeleteType;
EXECUTE vSqlDeleteType;
------------------------------------------------------------------------------------------------------------------
vSqlType := $$CREATE TEMP TABLE revisorFilas (division text, informante integer, observacion integer$$;
for vciclo in
   SELECT periodo, periodo = pperiododesde AS soyelprimero 
     FROM periodos
     WHERE periodo between pperiododesde and pperiodohasta
     ORDER BY periodo
Loop
  If (pProceso = 'MatrizV' Or pProceso = 'MatrizVPT') And not vciclo.soyelprimero Then
    vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_var text';
  end if;
  vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_pr text';
  vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_tipo text';
  vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_panel integer';
  vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_tarea text';
  vSqlType :=  vSqlType ||', '|| vciclo.periodo || '_enc text';
end loop;
vSqlType :=  vSqlType ||', '|| moverperiodos(pperiodohasta,1) || '_var text';
vSqlType :=  vSqlType ||',maxperiodoinformado text';
vSqlType :=  vSqlType ||',maxperiodoconprecio text';
vSqlType := vSqlType || $$);$$;
raise notice 'sentencia type: %', vsqlType;
EXECUTE vSqlType;
------------------------------------------------------------------------------------------------------------------
vSqlOwner := $$ALTER TABLE revisorFilas OWNER TO cvpowner; GRANT SELECT ON TABLE revisorFilas TO cvp_usuarios;$$;
raise notice 'sentencia owner: %', vSqlOwner;
EXECUTE vSqlOwner;

------------------------------------------------------------------------------------------------------------------
vSqlInsert := $$INSERT INTO revisorFilas SELECT * FROM ($$;
--Primera parte, agrega información del producto (calobs)
vSqlInsert := vSqlInsert ||$$ SELECT c.division||'-'||coalesce(i.nombreinformante,'') as division, c.informante, c.observacion$$;
for vciclo in
   SELECT periodo, periodoanterior, periodo = pperiododesde AS soyelprimero 
     FROM periodos
     WHERE periodo between pperiododesde and pperiodohasta /*and moverperiodos(pperiodohasta,1)*/
     ORDER BY periodo
Loop
  vActual   := vciclo.periodo;
  vAnterior := vciclo.periodoanterior;
  If (pProceso = 'MatrizV' Or pProceso = 'MatrizVPT') And not vciclo.soyelprimero Then
    vSqlInsert := vSqlInsert || $$ , replace((case when avg(case when c.periodo='$$ || vAnterior || $$' and c.antiguedadIncluido>0 then c.promObs else null end)>0 $$;
    vSqlInsert := vSqlInsert || $$   then round((avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)$$;
    vSqlInsert := vSqlInsert || $$        / avg(case when c.periodo='$$ || vAnterior || $$' and c.antiguedadIncluido>0 then c.promObs else null end)*100-100)::numeric,1)$$;
    vSqlInsert := vSqlInsert || $$   else null end)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_var';
  End If;

  vSqlInsert := vSqlInsert || $$ , case when avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)>0 $$;
  vSqlInsert := vSqlInsert || $$   then max(case when c.periodo='$$ || vActual || $$' and substr(o.estado,1,1) = 'B' then o.estado||'Manual ' else '' end)$$;
  vSqlInsert := vSqlInsert || $$||replace(avg(case when c.periodo='$$ || vActual || $$' and c.antiguedadIncluido>0 then c.promObs else null end)::text,'.','$$ || pSeparadorDecimal || $$') $$;
  vSqlInsert := vSqlInsert || $$   else max(case when c.periodo='$$ || vActual || $$' and c.antiguedadexcluido>0 then 'X '     else '' end)||$$;
  vSqlInsert := vSqlInsert || $$      max(case when c.periodo='$$ || vActual || $$' then coalesce(substr(o.estado,1,1)||' ','') else '' end)||$$;
  vSqlInsert := vSqlInsert || $$      string_agg(case when c.periodo='$$ || vActual || $$' and c.antiguedadexcluido>0 then $$;
  vSqlInsert := vSqlInsert || $$      replace(substr(comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)),1,strpos( comun.a_texto(ROUND(r.precionormalizado::NUMERIC,6)) , '.')+6)::text $$;
  vSqlInsert := vSqlInsert || $$      ,'.','$$ || pSeparadorDecimal || $$') else null end,';' ORDER BY r.visita) end as $$ || vActual || $$_pr$$;
  vSqlInsert := vSqlInsert || $$ , max(case when c.periodo='$$ || vActual || $$' then case when c.antiguedadIncluido>0 then coalesce(c.impObs,'')||':' else 'X:' end else null end)$$;
  vSqlInsert := vSqlInsert || $$   || coalesce(string_agg(case when c.periodo='$$ || vActual || $$' then coalesce(r.tipoprecio,'')$$;
  vSqlInsert := vSqlInsert || $$   || coalesce(','||r.cambio,'') $$;
  --agregar los atributos y precios de los tipoprecio = M
  vSqlInsert := vSqlInsert || $$   || case when r.tipoprecio in ('M','A') then coalesce(' '||comun.a_texto(bp.precio),'') $$;
  vSqlInsert := vSqlInsert || $$   || coalesce(' '||bp.tipoprecio,'') || coalesce(' '||ba.valores,'') ELSE '' end$$;
  --fin agregar los atributos y precios de los tipoprecio = M
  vSqlInsert := vSqlInsert || $$   || case when pat.valorprincipal is not null then ' '||pat.valorprincipal else '' end $$;
  vSqlInsert := vSqlInsert || $$ else null end||case when o.estado is not null then ' '||o.estado||'Manual ' else '' end||$$;
  vSqlInsert := vSqlInsert || $$ case when ((z.escierredefinitivoinf = 'S' or z.escierredefinitivofor = 'S') or v.informante is null and c.promobs is not null and vv.informante is null) then ' '||'| Inactivo ' else ''::text end, $$;
  vSqlInsert := vSqlInsert || $$';' ORDER BY r.visita),'') || case  when  min(pr.periodo)='$$ || vActual || $$' and  min(pr.periodo ) is not null then ',®' else ' ' end as  $$ || vActual || $$_tipo$$;

  If pProceso = 'MatrizVPT' Then
      vSqlInsert := vSqlInsert || $$ , min(case when c.periodo='$$ || vActual || $$' then v.panel else null end) as $$ || vActual || $$_panel$$;
      vSqlInsert := vSqlInsert || $$ , min(case when c.periodo='$$ || vActual || $$' then concat(v.tarea,case when tar.modalidad is not null then '/'||tar.modalidad else null end) else null end) as $$ || vActual || $$_tarea$$;
  End If;
  vSqlInsert := vSqlInsert || $$ , coalesce (string_agg(case when c.periodo = '$$ || vActual || $$' then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'') $$;
  vSqlInsert := vSqlInsert || $$||CASE WHEN coalesce (string_agg(case when c.periodo = '$$ || vActual || $$' then r.comentariosrelpre else null end, ';' ORDER BY r.visita),'')<>'' THEN '/' ELSE '' END $$;
  vSqlInsert := vSqlInsert || $$||min(case when c.periodo='$$ || vActual || $$' then (case when v.recepcionista is null then '' else v.recepcionista end)::text else null end)||'/'$$;
  vSqlInsert := vSqlInsert || $$||min(case when c.periodo='$$ || vActual || $$' then v.encuestador::text||':'||per.apellido else null end) as $$ || vActual || $$_enc$$;
end loop;

If pProceso = 'MatrizVPT' Then
    --Agregar la variacion interanual del último periodo
    vSqlInsert := vSqlInsert || $$ , replace((case when avg(case when varint.periodo=cvp.moverperiodos('$$ || pperiodohasta || $$',-12) and varint.antiguedadIncluido>0 then varint.promObs else null end)>0 $$;
    vSqlInsert := vSqlInsert || $$   then round((avg(case when c.periodo='$$ || pperiodohasta || $$' and c.antiguedadIncluido>0 then c.promObs else null end)$$;
    vSqlInsert := vSqlInsert || $$        / avg(case when varint.periodo=cvp.moverperiodos('$$ || pperiodohasta || $$',-12) and varint.antiguedadIncluido>0 then varint.promObs else null end)*100-100)::numeric,1)$$;
    vSqlInsert := vSqlInsert || $$   else null end)::text,'.','$$ || pSeparadorDecimal || $$')::numeric as $$ || vActual || $$_var$$;
   --fin Agregar la variacion interanual del último periodo
Else
    vSqlInsert := vSqlInsert || $$,   null::numeric as $$ || vActual || $$_var$$;
End If;
vSqlInsert := vSqlInsert || $$ , min(case when c.periodo='$$ || pperiodohasta || $$' then pmax.maxperiodoinformado else null end) as maxperiodoinformado$$;
vSqlInsert := vSqlInsert || $$ , min(case when c.periodo='$$ || pperiodohasta || $$' then cur.maxperiodoconprecio else null end) as maxperiodoconprecio$$;
vSqlInsert := vSqlInsert || $$ FROM cvp.calobs c $$;
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.relpre r on r.informante=c.informante and r.producto=c.producto and r.periodo=c.periodo $$;
vSqlInsert := vSqlInsert || $$         and r.observacion=c.observacion $$;
    vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.relvis v on v.informante=r.informante and v.periodo=r.periodo and v.visita=r.visita and v.formulario=r.formulario $$;
vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT * FROM cvp.prerep WHERE periodo>='$$ || pPeriodoDesde || $$' and periodo <='$$ || pperiodohasta || $$') pr $$;
vSqlInsert := vSqlInsert || $$    on pr.informante=c.informante and pr.producto=c.producto and pr.periodo=c.periodo $$;

--agregar los atributos y precios de los tipoprecio = M
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.blapre bp on r.informante=bp.informante and r.producto=bp.producto and r.periodo=bp.periodo and r.observacion=bp.observacion and r.visita = bp.visita $$;
vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT periodo, producto, informante, observacion, visita, string_agg(valor,',' ORDER BY atributo) as valores $$;
vSqlInsert := vSqlInsert || $$               FROM cvp.blaatr $$;
vSqlInsert := vSqlInsert || $$               WHERE Valor Is Not Null$$;
vSqlInsert := vSqlInsert || $$               GROUP BY periodo, producto, informante, observacion, visita) ba $$;
vSqlInsert := vSqlInsert || $$               on r.informante=ba.informante and r.producto=ba.producto and r.periodo=ba.periodo and r.observacion=ba.observacion and r.visita = ba.visita $$;
--fin agregar los atributos y precios de los tipoprecio = M
--agregar el valor del atributo principal y atributo marca
vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT x.periodo, x.producto, x.informante, x.observacion, x.visita, string_agg(CASE WHEN y.esprincipal= 'S' THEN CONCAT(x.valor,a.unidaddemedida) $$;
vSqlInsert := vSqlInsert || $$                 WHEN a.nombreatributo = 'Marca' THEN x.valor ELSE NULL END,';' ORDER BY a.atributo) as valorprincipal $$;
vSqlInsert := vSqlInsert || $$                 FROM cvp.relatr x LEFT JOIN cvp.prodatr y ON x.producto = y.producto AND x.atributo = y.atributo $$;
vSqlInsert := vSqlInsert || $$                 LEFT JOIN cvp.atributos a ON y.atributo = a.atributo $$;
vSqlInsert := vSqlInsert || $$                 GROUP BY x.periodo, x.producto, x.informante, x.observacion, x.visita) pat$$;
vSqlInsert := vSqlInsert || $$               on r.informante=pat.informante and r.producto=pat.producto and r.periodo=pat.periodo and r.observacion=pat.observacion and r.visita = pat.visita $$;
--fin agregar el valor del atributo principal y atributo marca
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.personal per ON v.encuestador = per.persona $$;
--agregar las altas/bajas manuales
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.novobs o ON c.periodo = o.periodo and c.calculo = o.calculo and c.producto = o.producto and c.informante = o.informante and c.observacion = o.observacion $$;
--agregar los informantes Inactivos
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.razones z ON v.razon = z.razon $$;
--para ver si está pendiente de ingreso, si es así no hay que poner la leyenda $$Inactivo$$
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.forprod fp ON c.producto = fp.producto $$;
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.formularios formu ON formu.formulario = fp.formulario $$;
--para agregar el nombreinformante
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.informantes i ON c.informante = i.informante $$;
--fin para agregar el nombreinformante
vSqlInsert := vSqlInsert || $$    JOIN cvp.forinf fi ON fp.formulario = fi.formulario and c.informante = fi.informante $$;
vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.relvis vv on c.periodo = vv.periodo and fi.informante = vv.informante and fi.formulario = vv.formulario and vv.ultima_visita $$;
If pProceso = 'MatrizVPT' Then
    --Agregar la variacion interanual del último periodo
    vSqlInsert := vSqlInsert || $$    LEFT JOIN cvp.calobs varint on cvp.moverperiodos(c.periodo,-12) = varint.periodo and c.calculo = varint.calculo and c.producto = varint.producto $$;
    vSqlInsert := vSqlInsert || $$     and c.informante = varint.informante and c.observacion = varint.observacion $$;
    --fin Agregar la variacion interanual del último periodo
End If;
    --Agregar el último periodo informado
    vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT informante, max(periodo) maxperiodoinformado FROM cvp.relvis WHERE razon = 1 GROUP BY informante) pmax on c.informante = pmax.informante $$;
    --fin Agregar el último periodo informado
If pProceso = 'MatrizVPT' Then
    --Agregar modalidad
    vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT periodo, panel, tarea, modalidad from cvp.reltar where modalidad is not null) tar on c.periodo = tar.periodo and vv.panel = tar.panel and vv.tarea = tar.tarea $$;
    --fin Agregar modalidad
End If;
--Agregar el último periodo con precio real
vSqlInsert := vSqlInsert || $$    LEFT JOIN (SELECT calculo, producto, informante, observacion, max (periodo) maxperiodoconprecio from cvp.calobs where calculo = $$ || vCalculo || $$ and impobs like 'R%' and periodo <'$$ || pperiodohasta || $$' group by calculo, producto, informante, observacion) cur $$;
vSqlInsert := vSqlInsert || $$    on c.calculo = cur.calculo and c.producto = cur.producto and c.informante = cur.informante and c.observacion = cur.observacion $$;
--fin Agregar el último periodo con precio real
vSqlInsert := vSqlInsert || $$       , cvp.revisor_parametros rr $$;
vSqlInsert := vSqlInsert || $$ WHERE c.producto='$$ || pProducto || $$' and c.calculo= $$ || vCalculo || $$ and formu.activo = 'S'$$;
vSqlInsert := vSqlInsert || vcondicionVersionOk;
vSqlInsert := vSqlInsert || $$ GROUP BY c.division, c.informante, c.observacion, i.nombreinformante$$;

vSqlInsert := vSqlInsert ||') as X ';
vSqlInsert := vSqlInsert ||' ORDER BY 1,2,3';

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
