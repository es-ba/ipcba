set search_path = cvp;
-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_Rellenar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vPeriodo_1 Text;
  vCalculo_1 integer;
  vgrupo_raiz  Text;
BEGIN

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_Rellenar','comenzo');  

SELECT periodoanterior, calculoanterior, cd.grupo_raiz INTO vPeriodo_1, vCalculo_1, vgrupo_raiz
  FROM Calculos c, Calculos_def cd
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.calculo= cd.calculo;
INSERT INTO CalObs(periodo, calculo, producto, informante, observacion, division, PromObs, 
                   ImpObs, AntiguedadConPrecio, AntiguedadSinPrecio, Muestra)
  (SELECT          pPeriodo, pCalculo, a.producto, a.informante, a.observacion, CASE WHEN otrotipoinformante is null then case when pd.sindividir then '0' else pd.division end else a.division end as division, NULL,
                   'B',NULL,NULL, i.Muestra
     FROM CalObs a
     LEFT JOIN CalObs b ON b.periodo = pPeriodo AND b.calculo=pCalculo AND b.informante = a.informante 
       AND b.producto = a.producto AND b.observacion=a.observacion 
     JOIN Informantes i  ON a.informante=i.informante
     join tipoinf ti on i.tipoinformante = ti.tipoinformante
     inner join (select producto, division, tipoinformante, sindividir 
                    from proddiv
                   union
                   select producto, divisionhibrido as division, tipoinformante, null as sindividir  
                    from productos, tipoinf 
                   where divisionhibrido is not null and otrotipoinformante is null) pd on pd.producto=a.producto and (pd.tipoinformante=i.tipoinformante or pd.sindividir)
     WHERE b.periodo IS NULL AND a.periodo=vPeriodo_1 AND a.calculo=vCalculo_1
        AND (a.AntiguedadConPrecio >0 OR a.AntiguedadIncluido >0) 
   );

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_Rellenar','finalizo');  
END;
$$;
