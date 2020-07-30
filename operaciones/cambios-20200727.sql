set search_path = cvp;
--optimizar la vista
CREATE OR REPLACE VIEW cvp.control_sinvariacion AS
SELECT periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, 
recepcionista, precionormalizado, SUM(cantprecio) as cantprecios, tipoprecio, comentariosrelpre
FROM (SELECT p.periodo, p.informante, i.nombreinformante, i.tipoinformante, p.producto, prod.nombreproducto, p.visita, p.observacion, 
      v.panel, v.tarea, v.recepcionista, p.precionormalizado, pant.periodo as periodo_ant,
      CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado END AS precioparacontar, 
        CASE WHEN pant.precionormalizado = (CASE WHEN pant.precionormalizado IS NULL THEN p.precionormalizado ELSE pant.precionormalizado end)
                  and pant.periodo <= p.periodo		
      THEN 1 ELSE 0 END AS cantprecio, p.tipoprecio, p.comentariosrelpre
      FROM cvp.relpre p
      JOIN (SELECT periodo, cvp.moverperiodos(periodo, -5) as perreferencia
              FROM cvp.periodos 
              WHERE ingresando = 'S' OR periodo = (SELECT MAX(periodo) FROM cvp.periodos WHERE ingresando = 'N')) per ON p.periodo = per.periodo
      JOIN cvp.relpre pant ON p.informante =pant.informante AND p.producto = pant.producto AND p.visita = pant.visita AND p.observacion = pant.observacion
                           AND (p.precionormalizado = pant.precionormalizado OR pant.precionormalizado is null OR
                         (pant.precionormalizado <> p.precionormalizado AND pant.periodo between per.perreferencia AND p.periodo))
      JOIN cvp.relvis v ON p.periodo = v.periodo AND p.informante = v.informante AND p.visita = v.visita AND p.formulario = v.formulario
      JOIN cvp.informantes i ON p.informante = i.informante
      JOIN cvp.productos prod ON p.producto = prod.producto
      WHERE p.precionormalizado is not null) q 
GROUP BY periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre
HAVING MIN(precioparacontar)=MAX(precioparacontar) AND SUM(cantprecio) >= 6
ORDER BY periodo, informante, nombreinformante, tipoinformante, producto, nombreproducto, visita, observacion, panel, tarea, recepcionista, precionormalizado,
tipoprecio, comentariosrelpre;

ALTER TABLE cvp.control_sinvariacion
    OWNER TO cvpowner;

--no permitir blancos de más en los valores válidos de los atributos
ALTER TABLE cvp.prodatrval
    ADD CONSTRAINT "blancos extra en valor tabla prodatrval" CHECK (not (valor is distinct from trim(regexp_replace(valor, ' {2,}',' ','g'))));

--Ya no descarta en una división si pudo imputar por OID
-- UTF8:Sí
CREATE OR REPLACE FUNCTION CalObs_SegImp(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE    
  vEmpezo  time:=clock_timestamp();
  vTermino time; 
  vPeriodo_1 Text;
  vCalculo_1 integer;
  v_agrupacion varchar(10);
  vPromPriImpAct double precision;
  vrec record;
  vCantIncluidosTipo integer;
  vumbraldescartetipo integer;
  vproducto varchar(11);
  vstrproductos   varchar(1000);
  vImpDiv varchar(100);
  vDescartedefinitivoSegImp boolean;
BEGIN
execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','comenzo');

SELECT periodoanterior, calculoanterior, cd.agrupacionprincipal, descarteDefinitivoSegImp INTO vPeriodo_1, vCalculo_1, v_agrupacion, vDescarteDefinitivoSegImp
  FROM Calculos c INNER JOIN Calculos_def cd ON c.calculo=cd.calculo
  WHERE c.periodo=pPeriodo AND c.calculo=pCalculo;

FOR vrec IN
  SELECT c.periodo,c.calculo,c.producto, c.observacion, c.informante, c.division, c.promobs, c0.promobs as promobsant,
         p.CantIncluidos , p.imputacon, p.ImpProd
    FROM CalObs c JOIN CalObs c0 ON c.periodo=pPeriodo AND c.calculo=pCalculo
                            AND c0.periodo=vPeriodo_1 AND c0.calculo=vCalculo_1
                            AND c.producto=c0.producto
                            AND c.informante=c0.informante
                            AND c.observacion=c0.observacion
                            AND c.division=c0.division
                           --AND c.antiguedadincluido >0
                            AND (c.AntiguedadIncluido >0 OR c.AntiguedadExcluido=1)
                   JOIN CalProd p  ON  c.periodo=p.periodo AND c.calculo=p.calculo 
                                   AND c.producto=p.producto 
  LOOP
    SELECT CASE WHEN vDescarteDefinitivoSegImp THEN t.CantRealesIncluidos ELSE t.CantIncluidos END, t.umbraldescarte, t.ImpDiv, t.PromPriImpAct
       INTO vCantIncluidosTipo, vumbraldescartetipo, vImpDiv, vPromPriImpAct
      FROM CalDiv t
      WHERE vrec.periodo=t.periodo AND vrec.calculo=t.calculo 
        AND vrec.producto=t.producto AND vrec.division=t.division;
    
    IF (vrec.promObs is null OR vCantIncluidosTipo <vumbraldescartetipo AND vPromPriImpAct is null OR vImpDiv='BII') AND vrec.promobsant>0 THEN
          UPDATE CalObs c 
            SET PromObs=CASE WHEN g0.Indice=0 THEN 0 ELSE vrec.promobsant*g.IndicePrel/g0.Indice END,
                 ImpObs=CASE WHEN vImpDiv='BII' THEN vImpDiv||'-'||g.ImpGru WHEN g0.Indice=0 THEN 'A0' ELSE COALESCE(g.ImpGru,'AGV') END
            FROM  CalGru g ,
                  CalGru g0  
            WHERE  c.periodo=pPeriodo AND c.calculo=pCalculo
              AND c.producto=vrec.producto
              AND c.informante=vrec.informante
              AND c.observacion=vrec.observacion
              AND c.division=vrec.division
              AND g.agrupacion=v_agrupacion AND g.grupo=vrec.imputacon 
              AND c.periodo=g.periodo AND c.calculo=g.calculo
              AND g0.agrupacion=v_agrupacion AND g0.grupo=vrec.imputacon 
              AND g0.periodo=vPeriodo_1 AND g0.calculo= vCalculo_1 ;
    END IF;
    IF vCantIncluidosTipo <vumbraldescartetipo THEN
      UPDATE Caldiv 
        SET cantrealesdescartados= vCantIncluidosTipo,
            cantrealesincluidos= 0
        WHERE vrec.periodo=periodo AND vrec.calculo=calculo 
          AND vrec.producto=producto AND vrec.division=division;
    END IF;
  END LOOP;
  
  vstrproductos='';  
  FOR vproducto IN
    SELECT DISTINCT producto 
       FROM CalObs
       WHERE periodo= pPeriodo AND impObs='A0'
       ORDER BY producto
  LOOP
     vstrproductos= comun.concato_add(vstrproductos, vproducto); 
  END LOOP;     
  vstrproductos= comun.concato_fin(vstrproductos);
  IF LENGTH(vstrproductos) >0 THEN
     execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','error'
             ,pmensaje:='Productos a imputar con informacion insuficiente del grupo con el que se imputa, reveer imputacon de : '||vstrproductos); 
  END IF;

execute Cal_Mensajes(pPeriodo, pCalculo,'CalObs_SegImp','finalizo');
  
END;
$$;
