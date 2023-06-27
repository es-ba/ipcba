set search_path = cvp;

CREATE OR REPLACE FUNCTION revisorResumenPreparar(pperiododesde text, pperiodohasta text, pProducto text, pProceso text)
RETURNS void AS
$BODY$
DECLARE
vSqlDeleteType text;
vSqlType text;
vSqlOwner text;
vSqlDrop text;
vSqlCreate text;
vSqlInsert text;
vSqlInsert2 text;
vSqlInsert3 text;
vSqlInsert4 text;
vciclo RECORD;
vActual text;
vAnterior text;
pSeparadorDecimal text := '.';
vversionCliente text := 'V230310';
vversionBaseConsiderada text := 'V130417';
vcondicionVersionOk text;
vCalculo integer := (select calculo from calculos_def where principal);
varrcant         text[];
varrnom          text[];
varrprom         text[];

BEGIN
set search_path = cvp;
vSqlDrop := $$drop function if exists cvp.revisorResumenCrear();$$;
raise notice 'sentencia drop: %', vsqlDrop;
EXECUTE vSqlDrop;

vcondicionVersionOk := $$ AND (rr.versionExigida <= '$$ || vversionCliente || $$' and rr.versionBase>= '$$ || vversionBaseConsiderada || $$') $$;
------------------------------------------------------------------------------------------------------------------
vSqlDeleteType := $$drop table if exists revisorResumen cascade;$$;
raise notice 'sentencia deletetype: %', vsqlDeleteType;
EXECUTE vSqlDeleteType;
------------------------------------------------------------------------------------------------------------------
vSqlType := $$CREATE TEMP TABLE revisorResumen (nombre text, division text, renglon integer$$;
for vciclo in
   SELECT periodo, periodo = pperiododesde AS soyelprimero, periodo = pperiodohasta AS soyelultimo, case when periodo = pperiodohasta then moverperiodos(periodo,1) else null end as siguiente 
     FROM periodos
     WHERE periodo between pperiododesde and pperiodohasta
     ORDER BY periodo
Loop
  If (pProceso = 'MatrizV' Or pProceso = 'MatrizVPT') And not vciclo.soyelprimero Then
    vSqlType:=vSqlType ||', '|| vciclo.periodo || '_var text';
  end if;
  vSqlType:=vSqlType||', '|| vciclo.periodo||'_pr text, '||vciclo.periodo||'_n text, '||vciclo.periodo||'_panel integer, '||vciclo.periodo||'_tarea text, '||vciclo.periodo ||'_enc text';
  if vciclo.soyelultimo then  
    --vSqlType :=  vSqlType ||', '|| vciclo.siguiente || '_var text);';
    vSqlType :=  vSqlType ||');';
  end if;
end loop;
raise notice 'sentencia type: %', vsqlType;
EXECUTE vSqlType;
------------------------------------------------------------------------------------------------------------------
vSqlOwner := $$ALTER TABLE revisorResumen OWNER TO cvpowner; GRANT SELECT ON TABLE revisorResumen TO cvp_usuarios;$$;
raise notice 'sentencia owner: %', vSqlOwner;
EXECUTE vSqlOwner;

------------------------------------------------------------------------------------------------------------------
vSqlInsert := $$INSERT INTO revisorResumen 
                 SELECT * FROM (
                    SELECT  'Varinteranual indice ponderador' as nombre, null::text as division, 1 as renglon$$;

vSqlInsert2 := $$INSERT INTO revisorResumen 
                 SELECT * FROM (
                    SELECT  'Variación acumulada anual redondeada' as nombre, null::text as division, 2 as renglon$$;

vSqlInsert3 := $$INSERT INTO revisorResumen 
                 SELECT * FROM (
                    SELECT  'Variación mensual/incidencia mensual' as nombre, null::text as division, 3 as renglon$$;
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
    vSqlInsert ||$$, replace(avg(case when c.periodo='$$ || vActual || $$' then case when cb.indice=0 then null
                                  else round( (c.indice/cb.indice*100-100)::numeric,1) end else null end)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_var';

    vSqlInsert2 := 
    vSqlInsert2 ||$$, replace(avg(case when c.periodo='$$ || vActual || $$' then c.variacionacumuladaanualredondeada else null end)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_var';
  
    vSqlInsert3 := 
    vSqlInsert3 ||$$, replace(avg(case when c.periodo='$$ || vActual || $$' then case when cb.indice=0 then null
                                  else round( (round(c.indice::numeric,2)/round(cb.indice::numeric,2)*100-100)::numeric,1) end else null end)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_var';
  End If;
  vSqlInsert := 
  vSqlInsert || $$, replace( round((avg(case when c.periodo='$$ || vActual || $$' then c.indice else null end))::numeric,2)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_pr'||
                $$, replace(round(avg( case when c.periodo='$$ || vActual || $$' then c.ponderador else null end )::numeric,6)::text,'.','$$ || pSeparadorDecimal || $$') as $$ || vActual || '_ponderador';

  vSqlInsert2 := 
  vSqlInsert2 || $$ , null::integer as $$ || vActual || '_pr'||$$, null::integer as $$ || vActual || '_ponderador';

  vSqlInsert3 := 
  vSqlInsert3 || $$ , null::integer as $$ || vActual || '_pr'||
                 $$, round((avg(case when c.periodo='$$ || vActual || $$' then c.incidencia else null end))::numeric,8)::text as $$ || vActual || '_ponderador';
  If pProceso = 'MatrizVPT' Then
     vSqlInsert := 
     vSqlInsert || $$ , null::integer as $$ || vActual || '_panel'||$$, null::integer as $$ || vActual || '_tarea';

     vSqlInsert2 := 
     vSqlInsert2 || $$ , null::integer as $$ || vActual || '_panel'||$$, null::integer as $$ || vActual || '_tarea';

     vSqlInsert3 := 
     vSqlInsert3 || $$ , null::integer as $$ || vActual || '_panel'||$$, null::integer as $$ || vActual || '_tarea';
  End If;
  vSqlInsert := vSqlInsert || $$, null::text as $$ || vActual || '_enc';
  vSqlInsert2 := vSqlInsert2 || $$, null::text as $$ || vActual || '_enc';
  vSqlInsert3 := vSqlInsert3 || $$, null::text as $$ || vActual || '_enc';
end loop;
  vSqlInsert := vSqlInsert || $$  FROM cvp.calgru  c
                                  LEFT JOIN cvp.calgru cb on cb.agrupacion=c.agrupacion and cb.grupo=c.grupo and cb.calculo=c.calculo and cb.periodo =cvp.periodo_igual_mes_anno_anterior(c.periodo)
                                  , cvp.revisor_parametros rr  
                                  WHERE c.grupo = 'Q0111111' and c.calculo= $$ || vCalculo || $$ and c.agrupacion='Z'$$ ||vcondicionversionok||
                               $$ GROUP BY c.grupo, c.agrupacion
                                 ) as X$$;
vSqlInsert := replace(replace(replace(vsqlInsert, $$'a2022m01'$$, quote_literal(pperiododesde)), $$'a2022m02'$$, quote_literal(pperiodohasta)), $$'Q0111111'$$, quote_literal(pproducto));
raise notice 'sentencia Insert: %', vsqlInsert;

vSqlInsert2 := vSqlInsert2 || $$  FROM cvp.calgru_vw  c
                                  , cvp.revisor_parametros rr  
                                  WHERE c.grupo = 'Q0111111' and c.calculo= $$ || vCalculo || $$ and c.agrupacion='Z'$$ ||vcondicionversionok||
                               $$ GROUP BY c.grupo, c.agrupacion
                                 ) as X$$;

vSqlInsert2 := replace(replace(replace(vsqlInsert2, $$'a2022m01'$$, quote_literal(pperiododesde)), $$'a2022m02'$$, quote_literal(pperiodohasta)), $$'Q0111111'$$, quote_literal(pproducto));
raise notice 'sentencia Insert 2: %', vsqlInsert2;

vSqlInsert3 := vSqlInsert3 || $$  FROM cvp.calgru c
                                  LEFT JOIN cvp.calgru cb on cb.agrupacion=c.agrupacion and cb.grupo=c.grupo and cb.calculo=c.calculo and cb.periodo =cvp.periodo_mes_anterior(c.periodo) 
                                  , cvp.revisor_parametros rr  
                                  WHERE c.grupo = 'Q0111111' and c.calculo= $$ || vCalculo || $$ and c.agrupacion='Z'$$ ||vcondicionversionok||
                               $$ GROUP BY c.grupo, c.agrupacion
                                 ) as X$$;

vSqlInsert3 := replace(replace(replace(vsqlInsert3, $$'a2022m01'$$, quote_literal(pperiododesde)), $$'a2022m02'$$, quote_literal(pperiodohasta)), $$'Q0111111'$$, quote_literal(pproducto));
raise notice 'sentencia Insert 3: %', vsqlInsert3;

varrcant := '{"impdiv", "cantincluidos", "cantrealesincluidos", "cantrealesexcluidos", "cantpriimp", "cantimputados", "cantimputadosinactivos", "cantAltas", "cantBajas", 
                   " ", " ", " ", "umbralpriimp", "umbraldescarte", "umbralbajaauto", " "}';
varrnom := '{"division", "Incluidos en el cálculo", "Reales incluidos en el cálculo", "Reales excluidos del cálculo", "Primera imputación", "Imputados", "Imputados inactivos", 
                 "Altas", "Bajas", "Variación reales sin cambio", "Variación sin altas/bajas", "Variación sin imp. ext.", "Umbral primera imputación", "Umbral de descarte",
                 "Umbral de baja automática", "Ponderadordiv"}';
varrprom := '{"promdiv", "promdiv", "promrealesincluidos", "promrealesexcluidos", "prompriimpact", "promimputados", "promimputadosinactivos", "promAltas", "promBajas", 
                  "promrealessincambio", "promsinaltasbajas", "promsinimpext", " ", " ", " ", "ponderadordiv"}';

vSqlInsert4 := 'INSERT INTO revisorResumen SELECT * FROM (';

for vind in array_lower(varrcant, 1)..array_upper(varrcant, 1) loop
  --raise notice 'Cant elemento nro: %, valor: % quote % valor %', vind, varrcant[vind],quote_literal(varrcant[vind]) = ' ', varrcant[vind] = ' ';
  --raise notice 'Nom  elemento nro: %, valor: % quote % valor %', vind, varrnom[vind], quote_literal(varrnom[vind]) = ' ', varrnom[vind]= ' ';
  --raise notice 'Prom elemento nro: %, valor: % quote % valor %', vind, varrprom[vind],quote_literal(varrprom[vind]) = ' ',varrprom[vind]= ' ';
  vSqlInsert4 := vSqlInsert4 || 'SELECT ' || case when vind = 1 then varrnom[vind] || $$|| ' (precios promedio sin redondear)'$$ else quote_literal(varrnom[vind]) end || ' as nombre, division as division, ' || vind || ' as renglon';
  for vciclo in
     SELECT periodo, periodoanterior, periodo = pperiododesde AS soyelprimero 
       FROM periodos
       WHERE periodo between pperiododesde and pperiodohasta
       ORDER BY periodo
  Loop
    vActual   := vciclo.periodo;
    vAnterior := vciclo.periodoanterior;
    If pProceso <> 'Matriz' And not vciclo.soyelprimero Then
      CASE WHEN varrnom[vind] = 'Ponderadordiv' Or
         varrnom[vind] = 'Reales excluidos del cálculo' Or
         varrnom[vind] = 'Imputados' Or
         varrnom[vind] = 'Imputados inactivos' Or
         varrnom[vind] = 'Altas' Or
         varrnom[vind] = 'Bajas' THEN
                vSqlInsert4 := vSqlInsert4 ||$$, null:: text as $$ || vActual || '_var';
         WHEN varrnom[vind] = 'Primera imputación' THEN
                vSqlInsert4 := vSqlInsert4 || $$, replace( case when avg(case when periodo='$$ || vActual || $$' then prompriimpant else null end)>0 
                                         then round((avg(case when periodo='$$ || vActual || $$' then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '0' else varrprom[vind] end ||$$ else null end)
                                         / avg(case when periodo='$$ || vActual || $$' then prompriimpant else null end)*100-100)::numeric,1)
                                         else null end ::text,'.', '$$ || pseparadordecimal || $$')  as $$  || vActual || '_var';
         WHEN varrnom[vind] = 'Variación reales sin cambio' THEN
                 vSqlInsert4 := vSqlInsert4 || $$, replace( case when avg(case when periodo='$$ || vActual || $$' then promrealessincambioant else null end)>0 
                                         then round((avg(case when periodo='$$ || vActual || $$' then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '0' else varrprom[vind] end ||$$ else null end)
                                         / avg(case when periodo='$$ || vActual || $$'  then promrealessincambioant else null end)*100-100)::numeric,1)
                                         else null end ::text,'.', '$$ || pseparadordecimal || $$')  as $$ || vActual || '_var';
         WHEN varrnom[vind] = 'Variación sin altas/bajas' THEN
                 vSqlInsert4 := vSqlInsert4 || $$, replace( case when avg(case when periodo='$$ || vActual || $$' then promsinaltasbajasant else null end)>0 
                                         then round((avg(case when periodo='$$ || vActual || $$' then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '0' else varrprom[vind] end ||$$ else null end)
                                           / avg(case when periodo='$$ || vActual || $$'  then promsinaltasbajasant else null end)*100-100)::numeric,1)
                                         else null end ::text,'.', '$$ || pseparadordecimal || $$')  as $$ || vActual || '_var';
         WHEN varrnom[vind] = 'Variación sin imp. ext.' THEN
                 vSqlInsert4 := vSqlInsert4 || $$, replace(avg(case when periodo='$$ || vActual || $$' then varsinimpext else null end)::text
                                                  ,'.','$$ || pseparadordecimal || $$') as $$ || vActual || '_var';
         ELSE
          vSqlInsert4 := vSqlInsert4 || $$, replace( case when avg(case when periodo='$$ || vAnterior || $$' then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '0' else varrprom[vind] end ||$$ else null end)>0 
                                                     then round((avg(case when periodo='$$ || vActual || $$' then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '0' else varrprom[vind] end ||$$ else null end)
                                                     / avg(case when periodo='$$ || vAnterior || $$'  then $$||case when /*quote_literal(*/varrprom[vind]/*)*/ = ' ' then '1' else varrprom[vind] end ||$$ else null end)*100-100)::numeric,1)
                                                     else null end ::text ,'.', '$$ || pseparadordecimal || $$')  as $$ || vActual || '_var';
         END case;
    END IF;
    vSqlInsert4 := vSqlInsert4 || CASE WHEN /*quote_literal(*/varrprom[vind]/*)*/ = ' ' 
                                    THEN $$ , null::text $$
                                    ELSE $$ , replace(round((avg(case when periodo='$$ || vActual || $$' then $$ ||varrprom[vind]|| $$ else null end))::numeric,2)::text,'.','$$ || pseparadordecimal || $$')$$ END || ' as '|| vActual || '_pr';
    vSqlInsert4 := vSqlInsert4 || CASE WHEN /*quote_literal(*/varrcant[vind]/*)*/ = ' ' 
                                    THEN $$ , null::text $$
                                    ELSE $$ , MAX(case when periodo='$$ || vActual || $$' then COALESCE($$ ||varrcant[vind]||$$::TEXT,'') else null end)::text $$ END || ' as '|| vActual || '_n';
    If pProceso = 'MatrizVPT' Then
      vSqlInsert4 := 
      vSqlInsert4 || $$ , null::integer as $$ || vActual || '_panel'||$$, null::integer as $$ || vActual || '_tarea';
    End If;
    vSqlInsert4 := vSqlInsert4 || $$, null::text as $$ || vActual || '_enc';
  end loop;
  If varrnom[vind] = 'Variación sin imp. ext.' Then
     vSqlInsert4 := vSqlInsert4 || $$ FROM cvp.calDiv_vw $$;
  Else
     vSqlInsert4 := vSqlInsert4 || $$ FROM cvp.calDiv $$;
  End If;
  vSqlInsert4 := vSqlInsert4 || $$, cvp.revisor_parametros rr  
                    WHERE producto = 'Q0111111' and calculo= $$ || vCalculo || vcondicionversionok ||
                    $$ GROUP BY division$$;
  if vind < array_upper(varrcant, 1) then
     vSqlInsert4 := vSqlInsert4 || ' UNION ';
  end if;
end loop;
    
vSqlInsert4 := vSqlInsert4 ||') as X ';
vSqlInsert4 := vSqlInsert4 ||'ORDER BY division, renglon';

vSqlInsert4 := replace(replace(replace(vsqlInsert4, $$'a2022m01'$$, quote_literal(pperiododesde)), $$'a2022m02'$$, quote_literal(pperiodohasta)), $$'Q0111111'$$, quote_literal(pproducto));
raise notice 'sentencia Insert 4: %', vsqlInsert4;

EXECUTE vSqlInsert;
EXECUTE vSqlInsert2;
EXECUTE vSqlInsert3;
EXECUTE vSqlInsert4;

vSqlCreate := $$CREATE or replace FUNCTION revisorResumenCrear() RETURNS SETOF revisorResumen AS $CUERPO$
   set search_path = cvp; 
   SELECT * FROM revisorResumen;
$CUERPO$ LANGUAGE SQL;$$;
raise notice 'sentencia create: %', vsqlCreate;
EXECUTE vSqlCreate;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION revisorResumenPreparar(text,text,text,text) OWNER TO cvpowner;

--test
select revisorResumenPreparar('a2023m01', 'a2023m02', 'Q0111381', 'MatrizVPT');
select * from revisorresumencrear()
