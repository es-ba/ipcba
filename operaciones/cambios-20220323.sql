set search_path =cvp;
CREATE OR REPLACE FUNCTION Cal_PerBase_Prop(pCalculo Integer, pPeriodoDesde text, pPeriodoHasta text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vPeriodo_Solo_para_CalMensajes varchar(11);
  vRec record;
  vagrup_valorizar_indexar record;
  vRecSec record;
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
    ORDER BY c.periodo
  LOOP
    EXECUTE CalGru_Indexar(vRec.periodo, vRec.calculo);
    EXECUTE CalGru_Info(vRec.periodo, vRec.calculo);
  END LOOP;
  ---agrupaciones secundarias
  for vagrup_valorizar_indexar IN
     select agrupacion, valoriza, case when agrupacion='A' then true else false end AS actcalprod
       from agrupaciones
       where calcular_junto_grupo='Z'
       order by agrupacion
  loop
    FOR vRecSec IN
      SELECT c.periodo, c.calculo
        FROM Calculos c
        WHERE c.calculo=pCalculo 
      ORDER BY c.periodo
    LOOP
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_Canasta_Valorizar(vRecSec.periodo, vRecSec.calculo, vagrup_valorizar_indexar.agrupacion, vagrup_valorizar_indexar.actcalprod); 
      else   
        execute CalGru_Indexar_Otro(vRecSec.periodo, vRecSec.calculo, vagrup_valorizar_indexar.agrupacion); 
        execute CalGru_Info_Otro(vRecSec.periodo, vRecSec.calculo, vagrup_valorizar_indexar.agrupacion); 
      end if;  
    END LOOP;
  end loop;
  ---fin agrupaciones secundarias
  
  EXECUTE Cal_Mensajes(vPeriodo_Solo_para_CalMensajes, pCalculo, 'Cal_PerBase_Prop', pTipo:='finalizo');
END;
$$;

ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en nombreinformante" CHECK (nombreinformante<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en direccion"        CHECK (direccion<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en nombrecalle"      CHECK (nombrecalle<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en altura"           CHECK (altura<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en piso"             CHECK (piso<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en departamento"     CHECK (departamento<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en cp"               CHECK (cp<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en contacto"         CHECK (contacto<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en telcontacto"      CHECK (telcontacto<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en web"              CHECK (web<>'');
ALTER TABLE informantes ADD CONSTRAINT "cadena vacia en email"            CHECK (email<>'');
