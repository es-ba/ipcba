CREATE OR REPLACE VIEW matrizperiodos6 AS
SELECT p.periodo as periodo6, CASE WHEN p.periodo='a2010m01' THEN NULL ELSE a.periodo END as periodo5, 
       CASE WHEN p.periodo<='a2010m02' THEN NULL ELSE b.periodo END as periodo4,
       CASE WHEN p.periodo<='a2010m03' THEN NULL ELSE c.periodo END as periodo3,
       CASE WHEN p.periodo<='a2010m04' THEN NULL ELSE d.periodo END as periodo2, 
       CASE WHEN p.periodo<='a2010m05' THEN NULL ELSE e.periodo END as periodo1
      FROM calculos p
        left join calculos a on a.periodo = p.periodoanterior and a.calculo=0 
        left join calculos b on b.periodo = a.periodoanterior and b.calculo=0 
        left join calculos c on c.periodo = b.periodoanterior and c.calculo=0 
        left join calculos d on d.periodo = c.periodoanterior and d.calculo=0 
        left join calculos e on e.periodo = d.periodoanterior and e.calculo=0
       where p.calculo=0; 

GRANT SELECT ON TABLE matrizperiodos6 TO cvp_administrador;