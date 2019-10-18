CREATE OR REPLACE VIEW canasta_producto AS
select c.periodo, c.calculo, c.agrupacion, c.grupo as producto, p.nombreProducto, c.valorgru as valorProd, c.grupoPadre
      , g.grupo_padre as grupoParametro, string_agg(ph.parametro,', ') as parametro, string_agg(o.nombreparametro,', ') as nombreparametro
      , hp.hogar, CASE WHEN MIN(COALESCE(ABS(hp.CoefHogPar)))>0 THEN EXP(SUM(LN(NULLIF(hp.CoefHogPar,0)))) ELSE 0 END AS CoefHogGru
      , c.valorgru*CASE WHEN MIN(COALESCE(ABS(hp.CoefHogPar)))>0 THEN EXP(SUM(LN(NULLIF(hp.CoefHogPar,0)))) ELSE 0 END as valorHogProd
      , substr(c.grupo,2,2) as divisionCanasta
      , Agrupo1, Agrupo2, Agrupo3, Agrupo4 --ancestros de la rama A
      , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4 --ancestros de la rama B
   from cvp.calgru c 
     left join cvp.gru_grupos g on c.agrupacion = g.agrupacion and c.grupo = g.grupo
     left join cvp.productos p on c.grupo = p.producto
     left join cvp.prodagr ag on c.agrupacion = ag.agrupacion and p.producto = ag.producto 
     join cvp.parhoggru ph on c.agrupacion = ph.agrupacion and grupo_padre = ph.grupo
     left join cvp.hogparAgr hp on ph.parametro = hp.parametro and ph.agrupacion = hp.agrupacion
     left join cvp.parhog o on ph.parametro = o.parametro
     left join (select g.agrupacion, g.grupo as Agrupo0, g4.grupo as Agrupo4, g3.grupo as Agrupo3, g2.grupo as Agrupo2, g1.grupo as Agrupo1
                  from cvp.grupos g
                  inner join cvp.grupos g4 on g.grupopadre=g4.grupo and g.agrupacion = g4.agrupacion and g4.agrupacion in ('A','D')
                  inner join cvp.grupos g3 on g4.grupopadre=g3.grupo and g.agrupacion = g4.agrupacion and g3.agrupacion in ('A','D')
                  inner join cvp.grupos g2 on g3.grupopadre=g2.grupo and g.agrupacion = g4.agrupacion and g2.agrupacion in ('A','D')
                  inner join cvp.grupos g1 on g2.grupopadre=g1.grupo and g.agrupacion = g4.agrupacion and g1.agrupacion in ('A','D')
                  where g.agrupacion in ('A','D') and g.nivel=5
               ) as A on c.grupo = Agrupo0 AND c.agrupacion = A.agrupacion 
     left join (select g.grupo as Bgrupo0, g4.grupo as Bgrupo4, g3.grupo as Bgrupo3, g2.grupo as Bgrupo2, g1.grupo as Bgrupo1
                  from cvp.grupos g
                  inner join cvp.grupos g4 on g.grupopadre=g4.grupo and g4.agrupacion='B'
                  inner join cvp.grupos g3 on g4.grupopadre=g3.grupo and g3.agrupacion='B'
                  inner join cvp.grupos g2 on g3.grupopadre=g2.grupo and g2.agrupacion='B'
                  inner join cvp.grupos g1 on g2.grupopadre=g1.grupo and g1.agrupacion='B'
                  where g.agrupacion='B'and g.nivel=4
                ) as B on grupo_padre = Bgrupo0
   where c.calculo = 0 and c.agrupacion in ('A','D') and g.esproducto = 'S' and ag.cantporunidcons >0 and valorgru is not null 
         --and hp.hogar = 'Hogar 5b' and c.periodo = 'a2014m06' 
   group by c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar
            , Agrupo1, Agrupo2, Agrupo3, Agrupo4
            , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4 
   order by c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar
            , Agrupo1, Agrupo2, Agrupo3, Agrupo4
            , Bgrupo0, Bgrupo1, Bgrupo2, Bgrupo3, Bgrupo4;

GRANT SELECT ON TABLE canasta_Producto TO cvp_administrador;
