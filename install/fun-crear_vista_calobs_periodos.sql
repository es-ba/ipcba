CREATE OR REPLACE FUNCTION crear_vista_calobs_periodos(pcalculo integer)
  RETURNS void AS
$BODY$
DECLARE
vSql text;
vSql_parte1 text;
vSql_parte2 text;
i integer;
vperiodos RECORD;

BEGIN
/* Consulta básica versión optimizada
SELECT division, informante, observacion,
         avg(case when periodo='a2012m03' then promObs else null end) as a2012m03_prom,
         max(case when periodo='a2012m03' then coalesce(impObs,'')||':' else null end) as a2012m03_sennal,
         avg(case when periodo='a2012m04' then promObs else null end) as a2012m04_prom,
         max(case when periodo='a2012m04' then coalesce(impObs,'')||':' else null end) as a2012m04_sennal
   FROM cvp.calobs c -- left join cvp.relpre r 
   WHERE producto='" & Producto & "'
   GROUP BY division, informante, observacion
   ORDER BY 1,2,3"))
*/

vSql := $$ DROP VIEW IF EXISTS CalObs_Periodos; $$;
EXECUTE vSql;

vSql_parte1 := $$ CREATE OR REPLACE VIEW CalObs_Periodos AS SELECT c.producto, c.informante, c.observacion$$;

vSql_parte2 := $$ FROM CalObs c 
                    LEFT JOIN RelPre r ON c.periodo = r.periodo AND c.producto = r.producto AND c.informante = r.informante
                                        AND c.observacion = r.observacion AND r.visita = 1
                  WHERE calculo = $$||pCalculo||$$
                  GROUP BY c.producto, c.informante, c.observacion
                  ORDER BY c.producto, c.informante, c.observacion $$;

i:= 0;
for vperiodos in
   SELECT DISTINCT periodo
     FROM CalObs_vw --vista con cálculos 0 y -1
     WHERE calculo = pCalculo
     ORDER BY periodo     
Loop
   i := i+1;
   --vSql_parte1 := vSql_parte1 ||$$, c$$||i||$$.promobs $$||vperiodos.periodo||$$_prom,
   
  vSql_parte1 := vSql_parte1 ||$$, ROUND(avg(case when c.periodo='$$||vperiodos.periodo||$$' then c.promObs else null end)::DECIMAL,2) as $$||vperiodos.periodo||$$_prom, 
    MAX(CASE WHEN c.periodo='$$||vperiodos.periodo||$$' THEN 
           CASE WHEN c.antiguedadexcluido>0 THEN 'X' ELSE '' END
           ||coalesce(c.impobs,'')||CASE WHEN r.tipoprecio IS NOT NULL THEN ':' ELSE '' END
           ||coalesce(r.tipoprecio,'')||CASE WHEN r.cambio IS NOT NULL THEN ',' ELSE '' END
           ||coalesce(r.cambio,'')
        ELSE NULL END) as $$||vperiodos.periodo||$$_imp$$;
end loop;

vSql := vSql_parte1||vSql_parte2||$$;$$;

EXECUTE vSql;

vSql := $$GRANT ALL ON TABLE CalObs_Periodos TO cvpowner;
          GRANT SELECT ON TABLE CalObs_Periodos TO cvp_administrador;$$;
          
EXECUTE vSql;

 END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

--SELECT crear_vista_calobs_periodos(0);