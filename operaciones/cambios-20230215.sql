set search_path = cvp;

CREATE OR REPLACE VIEW control_ajustes AS 
    SELECT per.periodo, rv.panel, rv.tarea, rp.informante, i.tipoinformante, rp.visita, rp.formulario, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',1) AS grupo_padre_1, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',2) AS nombregrupo_1, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',3) AS grupo_padre_2, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',4) AS nombregrupo_2, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',5) AS grupo_padre_3, 
        split_part(string_agg(gg_1.grupo_padre||'|'||g_1.nombregrupo,'|' ORDER BY g_1.nivel),'|',6) AS nombregrupo_3, 
        rp.producto, p.nombreproducto, rp.observacion, rp.precionormalizado, rp.tipoprecio, rp.cambio, rp.precionormalizado/rp_1.precionormalizado*100.0-100 AS variacion_1, 
        sign(rp.precionormalizado/rp_1.precionormalizado*100.0-100) AS varia_1, rp_1.precionormalizado AS precionormalizado_1, 
        rp_1.tipoprecio AS tipoprecio_1, rp_1.cambio AS cambio_1, rp_1.precionormalizado/rp_2.precionormalizado*100.0-100 AS variacion_2, 
        sign(rp_1.precionormalizado/rp_2.precionormalizado*100.0-100) AS varia_2, rp_2.precionormalizado AS precionormalizado_2, 
        rp_2.tipoprecio AS tipoprecio_2, rp_2.cambio AS cambio_2, coalesce(sign(rp.precionormalizado/rp_1.precionormalizado*100.0-100)::text,'N') || '_' || 
        coalesce(sign(rp_1.precionormalizado/rp_2.precionormalizado*100.0-100)::text,'N') AS varia_ambos
    FROM (SELECT periodo, periodoanterior, moverperiodos(periodoanterior,-1) AS periodoanterioranterior 
            FROM periodos) per 
        LEFT JOIN relpre rp ON per.periodo = rp.periodo
        LEFT JOIN relvis rv ON rv.periodo = rp.periodo AND rv.informante = rp.informante AND rv.visita = rp.visita AND rv.formulario = rp.formulario -- pk:ok!
        LEFT JOIN productos p using(producto) 
        LEFT JOIN informantes i ON rp.informante = i.informante 
        LEFT JOIN relpre rp_1 ON rp_1.periodo=per.periodoanterior AND rp_1.producto=rp.producto AND rp_1.observacion=rp.observacion AND rp_1.informante=rp.informante AND rp_1.visita=rp.visita -- pk:ok!
        LEFT JOIN relpre rp_2 ON rp_2.periodo=per.periodoanterioranterior AND rp_2.producto=rp.producto AND rp_2.observacion=rp.observacion AND rp_2.informante=rp.informante AND rp_2.visita=rp.visita -- pk:ok!
        LEFT JOIN gru_grupos gg_1 ON rp.producto = gg_1.grupo
        LEFT JOIN grupos g_1 ON gg_1.grupo_padre = g_1.grupo
    WHERE gg_1.agrupacion = 'Z' 
        AND gg_1.esproducto = 'S'
        AND g_1.nivel in (1,2,3)
    GROUP BY 1,2,3,4,5,6,7,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30;