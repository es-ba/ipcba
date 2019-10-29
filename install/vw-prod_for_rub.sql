CREATE OR REPLACE VIEW prod_for_rub AS
SELECT producto, nombreproducto, split_part(formularios,'|',1) as formulario1, 
       case when split_part(formularios,'|',2)='' then null else split_part(formularios,'|',2) end as formulario2, 
       case when split_part(formularios,'|',3)='' then null else split_part(formularios,'|',3) end as formulario3,
       split_part(rubros,'|',1) as rubro1,case when split_part(rubros,'|',2)='' then null else split_part(rubros,'|',2) end as rubro2, 
       case when split_part(rubros,'|',3)='' then null else split_part(rubros,'|',3) end as rubro3,
       formula, estacional, 
       imputacon, cantperaltaauto, cantperbajaauto, cantporunidcons, 
       unidadmedidaporunidcons, esexternohabitual, tipocalculo, cantobs, 
       unidadmedidaabreviada, codigo_ccba, porc_adv_inf, porc_adv_sup
  FROM (
    SELECT producto, nombreproducto, string_agg(formulario||':'||nombreformulario,'|') as formularios, 
           string_agg(rubros,'|') as rubros,
           formula, estacional, imputacon, cantperaltaauto, 
           cantperbajaauto, cantporunidcons, unidadmedidaporunidcons, esexternohabitual, 
           tipocalculo, cantobs, unidadmedidaabreviada, codigo_ccba, porc_adv_inf, 
          porc_adv_sup 
      FROM  (
            SELECT producto, nombreproducto, formulario, nombreformulario,
                   string_agg(rubro||':'||nombrerubro,'; ') as rubros,
                   formula, estacional, imputacon, cantperaltaauto, 
                   cantperbajaauto, cantporunidcons, unidadmedidaporunidcons, esexternohabitual, 
                   tipocalculo, cantobs, unidadmedidaabreviada, codigo_ccba, porc_adv_inf, 
                   porc_adv_sup 
              FROM (SELECT p.producto, p.nombreproducto, fp.formulario, f.nombreformulario, rf.rubro, r.nombrerubro,
                         p.formula, p.estacional, p.imputacon, p.cantperaltaauto, 
                         p.cantperbajaauto, pa.cantporunidcons, p.unidadmedidaporunidcons, p.esexternohabitual, 
                         p.tipocalculo, p.cantobs, p.unidadmedidaabreviada, p.codigo_ccba, p.porc_adv_inf, p.porc_adv_sup 
                      FROM cvp.productos p
                      LEFT JOIN cvp.prodagr pa ON p.producto = pa.producto and pa.agrupacion = 'A'
                      LEFT JOIN cvp.forprod fp ON p.producto = fp.producto --pk verificada
                      LEFT JOIN (select distinct r.formulario,i.rubro  
                                   from cvp.relvis r 
                                   inner join cvp.informantes i ON r.informante = i.informante
                                   --vigentes al último periodo cerrado:
                                   inner join (SELECT max(periodo) AS per
                                                FROM cvp.periodos
                                                WHERE ingresando = 'N') p ON r.periodo = p.per
                                 /*union
                                 select formulario, rubro from cvp.rubfor*/) rf ON fp.formulario = rf.formulario
                      LEFT JOIN cvp.formularios f ON fp.formulario = f.formulario --pk verificada
                      LEFT JOIN cvp.rubros r ON rf.rubro = r.rubro --pk verificada
                      WHERE f.activo = 'S'
                      ORDER BY p.producto, fp.formulario, rf.rubro
                   ) as d 
              GROUP BY producto, nombreproducto, formulario, nombreformulario, formula, estacional, imputacon, cantperaltaauto, 
                   cantperbajaauto, cantporunidcons, unidadmedidaporunidcons, esexternohabitual, 
                   tipocalculo, cantobs, unidadmedidaabreviada, codigo_ccba, porc_adv_inf, 
                   porc_adv_sup
              ORDER BY producto
            ) as s
    GROUP BY producto, nombreproducto, formula, estacional, imputacon, cantperaltaauto, 
             cantperbajaauto, cantporunidcons, unidadmedidaporunidcons, esexternohabitual, 
             tipocalculo, cantobs, unidadmedidaabreviada, codigo_ccba, porc_adv_inf, 
             porc_adv_sup
    ORDER BY producto
        ) as X;

GRANT SELECT ON TABLE prod_for_rub TO cvp_usuarios;
