-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalDiv_Rellenar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vrec Record;
  vdivexiste boolean:=false;
  vdivision Text;
  vpadre Text;
  vponderadoratr Double precision;
BEGIN

EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Rellenar','comenzo');

FOR vrec IN
   SELECT  a.periodo, a.calculo, a.producto, a.division, max(orden_calculo_especial) maxorden
     FROM Calobs a
     JOIN Prodatr p ON a.producto=p.producto 
     WHERE a.periodo=pPeriodo AND a.calculo=pCalculo 
       AND p.orden_calculo_especial IS NOT NULL
       GROUP BY a.periodo, a.calculo, a.producto, a.division
       ORDER BY a.periodo, a.calculo, a.producto, a.division DESC
LOOP
  vPadre:=vrec.division; -- En el primer renglón del ciclo vPadre es el padre de la iteración anterior o sea la división actual
  FOR i IN REVERSE vrec.maxorden..0 LOOP
    vDivExiste:=false;  
    vDivision:=vPadre;  
    vPadre:=coalesce(sin_el_ultimo(vDivision,'~'),'0');
    IF i IS DISTINCT FROM 0 THEN  
      SELECT ponderadoratr INTO vponderadoratr
        FROM Valvalatr v 
        JOIN Prodatr p ON v.producto=p.producto AND v.atributo=p.atributo
        WHERE v.producto=vrec.producto AND v.valor=split_part(vdivision,'~',i);
    ELSE
      vponderadoratr:=null; 
      vdivision:='0';
      vPadre:=null;
    END IF; 
    SELECT true INTO vdivexiste
      FROM CalDiv c
      WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.producto=vrec.producto AND c.division=vDivision;
    IF vdivexiste IS NOT TRUE THEN
      INSERT INTO CalDiv(periodo, calculo, producto, division, profundidad, divisionPadre, PonderadorDiv, raiz)
        VALUES          (vrec.periodo, vrec.calculo, vrec.producto, vdivision, i, vpadre, vponderadoratr, nullif(i=0,false));
    END IF;
  END LOOP;
  FOR i IN 1..vrec.maxorden LOOP
    UPDATE CalDiv c SET tipo_promedio=p.tipo_promedio
      FROM Prodatr p
      WHERE c.periodo=pPeriodo AND c.calculo=pCalculo AND c.producto=p.producto
        AND c.producto=vrec.producto AND p.orden_calculo_especial=i AND c.profundidad=i-1;
  END LOOP; 
  UPDATE CalDiv c
    SET UmbralPriImp  = CASE WHEN l.estimacion = 0 THEN p.UmbralPriImp   ELSE e.UmbralPriImp END,
        UmbralDescarte= CASE WHEN l.estimacion = 0 THEN p.UmbralDescarte ELSE e.UmbralDescarte END,
        UmbralBajaAuto= CASE WHEN l.estimacion = 0 THEN p.UmbralBajaAuto ELSE e.UmbralBajaAuto END
    FROM ProdDiv p
       LEFT JOIN Calculos l ON l.periodo = pPeriodo and l.calculo = pCalculo --pk verificada
       LEFT JOIN ProdDivEstimac e ON p.producto = e.producto and p.division = e.division and l.estimacion = e.estimacion -- pk verificada
    WHERE c.UmbralPriImp is null
      AND c.periodo=pPeriodo
      AND c.calculo=pCalculo
      AND p.producto=c.producto
      AND p.division=c.division;
END LOOP;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalDiv_Rellenar','finalizo');     
END;
$$;