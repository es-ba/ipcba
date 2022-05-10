CREATE OR REPLACE VIEW matrizperiodos6 AS
SELECT p.periodo as periodo6, CASE WHEN p.periodo='a2010m01' THEN NULL ELSE a.periodo END as periodo5,
       CASE WHEN p.periodo<='a2010m02' THEN NULL ELSE b.periodo END as periodo4,
       CASE WHEN p.periodo<='a2010m03' THEN NULL ELSE c.periodo END as periodo3,
       CASE WHEN p.periodo<='a2010m04' THEN NULL ELSE d.periodo END as periodo2,
       CASE WHEN p.periodo<='a2010m05' THEN NULL ELSE e.periodo END as periodo1
      FROM calculos p
        join calculos_def cd on p.calculo = cd.calculo 
        left join (select s.* from calculos s join calculos_def df1 on s.calculo = df1.calculo where df1.principal) a on a.periodo = p.periodoanterior
        left join (select t.* from calculos t join calculos_def df2 on t.calculo = df2.calculo where df2.principal) b on b.periodo = a.periodoanterior
        left join (select u.* from calculos u join calculos_def df3 on u.calculo = df3.calculo where df3.principal) c on c.periodo = b.periodoanterior
        left join (select v.* from calculos v join calculos_def df4 on v.calculo = df4.calculo where df4.principal) d on d.periodo = c.periodoanterior
        left join (select w.* from calculos w join calculos_def df5 on w.calculo = df5.calculo where df5.principal) e on e.periodo = d.periodoanterior
       where cd.principal; 

GRANT SELECT ON TABLE matrizperiodos6 TO cvp_administrador;