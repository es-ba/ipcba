CREATE VIEW control_ingresados_calculo AS
SELECT p.periodo, p.producto, o.nombreproducto, p.informante, i.nombreinformante, p.observacion, i.tipoinformante, pd.divisionesdelproducto, 
   case when not(i.tipoinformante is distinct from pd.divisionesdelproducto) then date_trunc('second',i.modi_fec) else null end as fechamodificacioninformante 
  FROM 
    (SELECT distinct periodo, producto, informante, observacion, modi_fec
       FROM cvp.relpre 
       WHERE precionormalizado is not null) as p --los candidatos a ir a calobs
    INNER JOIN cvp.productos o on p.producto = o.producto --pk verificada
    INNER JOIN cvp.informantes i on p.informante = i.informante --pk verificada
    INNER JOIN cvp.calculos a on p.periodo = a.periodo and a.calculo = 0 --pk verificada 
    LEFT JOIN (SELECT producto, string_agg(division, ',' ORDER BY division) as divisionesdelproducto 
                 FROM cvp.proddiv 
                 GROUP BY producto) pd on p.producto = pd.producto
    LEFT JOIN (SELECT * FROM cvp.calobs WHERE calculo = 0) c 
                 on c.periodo = p.periodo and c.producto = p.producto and c.informante = p.informante and c.observacion = p.observacion
    WHERE c.division is null AND p.modi_fec < a.fechacalculo
    ORDER BY p.periodo, p.producto, p.informante, p.observacion;

GRANT SELECT ON TABLE control_ingresados_calculo TO cvp_usuarios;