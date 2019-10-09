CREATE OR REPLACE FUNCTION Cal_PerBase_Prop(pCalculo Integer, pPeriodoDesde text, pPeriodoHasta text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vPeriodo_Solo_para_CalMensajes varchar(11);
  vRec record;
BEGIN
  if pPeriodoDesde is not null then 
      vPeriodo_Solo_para_CalMensajes:=pPeriodoDesde;
  else
      SELECT min(periodo) INTO vPeriodo_Solo_para_CalMensajes
        FROM Calculos
        WHERE esperiodobase='S'
          AND calculo=pCalculo;
  end if;
  EXECUTE Cal_Mensajes(vPeriodo_Solo_para_CalMensajes, pCalculo, 'Cal_PerBase_Prop', pTipo:='comenzo'); 
  UPDATE CalProd cp
    SET indice=indice*100/suma_indices_del_producto*cantidad_meses
    FROM Calculos c,
        (SELECT b.producto, sum(b.indice) as suma_indices_del_producto, count(b.indice) as cantidad_meses
           FROM CalProd b INNER JOIN Calculos cb ON b.periodo=cb.periodo AND b.calculo=cb.calculo 
           WHERE cb.calculo=pCalculo AND b.periodo between pPeriodoDesde and pPeriodoHasta  
           GROUP BY b.producto) base
    WHERE c.calculo=pCalculo 
      AND cp.periodo=c.periodo AND cp.calculo=c.calculo
      AND base.producto=cp.producto;
  FOR vRec IN
    SELECT c.periodo, c.calculo
      FROM Calculos c
      WHERE c.calculo=pCalculo 
  LOOP
    EXECUTE CalGru_Indexar(vRec.periodo, vRec.calculo);
  END LOOP;
  EXECUTE Cal_Mensajes(vPeriodo_Solo_para_CalMensajes, pCalculo, 'Cal_PerBase_Prop', pTipo:='finalizo');
END;
$$;