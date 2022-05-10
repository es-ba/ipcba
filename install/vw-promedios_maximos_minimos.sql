CREATE OR REPLACE VIEW promedios_maximos_minimos AS 
 SELECT v.periodo, v.producto, f.nombreproducto, n.tipoinformante, r.despacho, v.observacion,
   round(EXP(AVG(LN(v.precionormalizado)))::DECIMAL,2) avgp, 
   round(MIN(v.precionormalizado)::DECIMAL,2) minp,  round(MAX(v.precionormalizado)::DECIMAL,2) maxp,
   round((EXP(AVG(LN((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs)))))*100 -100)::DECIMAL,1) as avgv, 
   round(MIN((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs))*100 -100)::DECIMAL,1) as minv,   
   round(MAX((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs))*100 -100)::DECIMAL,1) as maxv,
   SUM( CASE WHEN ta.espositivo='S'  THEN 1
             ELSE 0
             END) as cantreales,
   SUM( CASE WHEN ta.espositivo='N'  THEN 1
             ELSE 0
             END) as cantnegativos, 
   SUM(CASE WHEN coalesce(v.cambio,'0')='C'  THEN 1
            ELSE 0
            END)  as cantcambios,       
   COUNT(*) cantcasos,   
   SUM( CASE WHEN 
             (SELECT ta.espositivo
                FROM cvp.relvis vi
                WHERE ta.tipoprecio=coalesce(v.tipoprecio,'0') --si comento esta condicion tarda mas 
                AND vi.informantereemplazante is not null
                AND v.informante=vi.informantereemplazante
                AND v.periodo=vi.periodo
                AND v.visita=vi.visita )='S'   THEN 1
            ELSE 0
            END) as cantreemplazos,  
    SUM( CASE WHEN v.tipoprecio is null   THEN 1
             ELSE 0
             END) as cantnulos 
   FROM cvp.relpre_1 v
   JOIN cvp.productos f ON v.producto = f.producto
   JOIN cvp.informantes n ON v.informante = n.informante
   JOIN cvp.rubros r ON n.rubro=r.rubro 
   LEFT JOIN cvp.tipopre ta ON ta.tipoprecio=coalesce(v.tipoprecio,'0')
   LEFT JOIN (select c.* from cvp.CalObs c join cvp.calculos_def cd on c.calculo = cd.calculo where cd.principal) co 
                           ON v.periodo_1 = co.periodo  AND v.informante = co.informante 
                           AND v.producto = co.producto AND v.observacion = co.observacion 
   GROUP BY v.periodo,v.producto,f.nombreproducto,n.tipoinformante,r.despacho, v.observacion
   ORDER BY v.periodo,v.producto,n.tipoinformante,r.despacho,v.observacion; --confirmar si se agrega observacion al orden
   
GRANT SELECT ON TABLE promedios_maximos_minimos TO cvp_usuarios;
