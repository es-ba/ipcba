CREATE OR REPLACE FUNCTION calcularprerep(
    parperiodo text,
    parlote integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$
declare
PTopeHasta text;
v_relpre RECORD;
cantreg integer;
xproducto character varying(8);
periodo_inicio character varying(8);
ParPeriodoAnterior character varying(8);

PanelDesde integer;
PanelHasta integer;
PeriodoReferente character varying(8);

begin

periodo_inicio := 'a2010m08'; --considerar antiguedad a partir de agosto 2010

--Topes para los paneles según ParLote
CASE 
  WHEN ParLote = 1 THEN
    PanelDesde := 1;
    PanelHasta := 10;
  WHEN ParLote = 2 THEN
    PanelDesde := 11;
    PanelHasta := 20;
  END case;

--6 periodos para atrás de ParPeriodo
PTopeHasta := cvp.MoverPeriodos(ParPeriodo,-6);
--raise notice '6 periodos para atras del parametro  % ', PTopeHasta; 

--Maximo periodo con garantía de paneles generados para ParLote
SELECT max(periodo) INTO PeriodoReferente
  from cvp.Periodos
  where periodo <= ParPeriodo and cvp.TestPanelesGenerados(periodo,PanelDesde,PanelHasta) = 'S';

--raise notice 'periodo referencia  % ', PeriodoReferente; 

SELECT periodoanterior INTO ParPeriodoAnterior
    from cvp.periodos
    where periodo = PeriodoReferente;

--raise notice 'periodo anterior   % ', ParPeriodoAnterior; 

DROP TABLE IF EXISTS cvp.Temp_Candidatos;

CREATE TABLE cvp.Temp_Candidatos
(
 periodo character varying(11) NOT NULL,
 producto character varying(8) NOT NULL,
 informante integer,
 antiguedad integer,
 LimiteR integer,
 CantRep integer,
 PRIMARY KEY (periodo, producto, informante)
);
ALTER TABLE cvp.Temp_Candidatos OWNER TO cvpowner;
GRANT ALL ON TABLE cvp.Temp_Candidatos TO cvpowner;

insert into cvp.Temp_Candidatos
    select B.periodo, B.producto, B.informante, B.antiguedad, coalesce(C.limiteR,0) as limiteR, coalesce(CANT.cantR,0) as cantRep
    from
      (select A.periodo, A.informante, A.producto, A.antiguedad from
      (
      select v.periodo, v.informante, p.producto, 
      min(cvp.DiferenciaEntrePeriodosParaR(periodo_inicio, v.informante, p.periodo, v.periodo)) antiguedad
        from (SELECT DISTINCT periodo, informante, visita, panel, tarea FROM cvp.relvis) v 
             --28/01/2020: en relvis, independientemente del formulario, porque pudo haber cambiado a través del tiempo  
          inner join cvp.relpre p on v.periodo > p.periodo 
                                   and v.informante = p.informante 
                                   and v.visita = p.visita 
                                   --and v.formulario = p.formulario 
                                   and p.cambio = 'C'
          inner join cvp.productos d on p.producto = d.producto 
          where v.periodo = ParPeriodoAnterior --PeriodoReferente
              and PanelDesde <= v.panel and v.panel <= PanelHasta
              and d.serepregunta
        group by v.periodo, v.informante, p.producto
        order by v.periodo, v.informante, p.producto      
      ) as A
      left join (select distinct informante, producto 
                  from cvp.PreRep PR 
                  where PTopeHasta <= periodo and periodo <= ParPeriodo) as PR on A.informante = PR.informante 
                                                                                 and A.producto = PR.producto
          where
            PR.informante is null and PR.producto is null --No tiene R en los 6 peridos anteriores
          and A.antiguedad >= 6 --Hace 6 o más meses que no tiene C
      ) as B 
      left join (select r.periodo, r.producto, round(count(*)*0.05) as limiteR
                   from (SELECT DISTINCT periodo, informante, visita, panel, tarea FROM cvp.relvis) v 
                         --28/01/2020:  en relvis, independientemente del formulario, porque pudo haber cambiado a través del tiempo  
                   inner join cvp.relpre r on v.periodo = r.periodo 
                                            and v.informante = r.informante 
                                            and v.visita = r.visita
                                            --and v.formulario = r.formulario
                   inner join cvp.tipopre t 
                     on r.tipoprecio = t.tipoprecio
                   where PanelDesde <= v.panel and v.panel <= PanelHasta and
                        t.espositivo = 'S' and r.periodo = ParPeriodoAnterior 
                   group by r.periodo, r.producto
                   order by r.periodo, r.producto) as C 
          on B.producto = C.producto
      left join (select periodo, producto, count(*) as cantR
                   from cvp.prerep
                   where periodo = ParPeriodo
                   group by periodo, producto) as CANT 
                on --B.periodo = CANT.periodo and 
                B.producto = CANT.producto
      order by periodo, producto, informante;

DROP TABLE IF EXISTS cvp.Temp_Sorteo;

CREATE TABLE cvp.Temp_Sorteo
(
 periodo character varying(11) NOT NULL,
 producto character varying(8) NOT NULL,
 MinInfo integer,
 MaxInfo integer,
 num_sorteado double precision,
 PRIMARY KEY (periodo, producto)
);
ALTER TABLE cvp.Temp_Sorteo OWNER TO cvpowner;
GRANT ALL ON TABLE cvp.Temp_Sorteo TO cvpowner;

perform setseed(('0.'||replace(replace(ParPeriodo,'a',''),'m',''))::float8);

INSERT INTO cvp.Temp_Sorteo
  select periodo, producto, min(informante) MinInfo, max(informante) MaxInfo, 
    random()*(max(informante)-min(informante))+ min(informante) as num_sorteado  
    from cvp.Temp_Candidatos
    where cantRep < LimiteR
    group by periodo, producto;

xproducto := '        ';
FOR v_relpre IN
select C.periodo, C.informante, C.producto, C.LimiteR, C.CantRep
  from cvp.Temp_Candidatos C, cvp.Temp_Sorteo S
  where C.periodo = S.periodo and C.producto = S.producto and C.cantRep < C.LimiteR
  ORDER BY C.periodo, C.producto, C.antiguedad desc, C.informante<S.num_sorteado, C.informante
    LOOP
      --raise notice 'Voy por periodo % informante % producto % ', v_relpre.periodo, v_relpre.informante, v_relpre.producto; 
      if xproducto <> v_relpre.producto then
         cantreg := v_relpre.CantRep; 
      end if;
      if cantreg < v_relpre.limiteR then
          --INSERT INTO cvp.PreRep (periodo, informante, producto) VALUES (v_relpre.periodo, v_relpre.informante, v_relpre.producto);
          INSERT INTO cvp.PreRep (periodo, informante, producto) 
            VALUES (ParPeriodo, v_relpre.informante, v_relpre.producto);
          cantreg = cantreg +1;
      end if;
      xproducto := v_relpre.producto;       
    END LOOP;

DROP TABLE IF EXISTS cvp.Temp_Sorteo;
DROP TABLE IF EXISTS cvp.Temp_Candidatos;

end;

$BODY$;