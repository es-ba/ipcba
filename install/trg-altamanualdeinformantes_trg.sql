CREATE OR REPLACE FUNCTION altamanualdeinformantes_trg()
  RETURNS trigger AS
$BODY$
begin
  IF NEW.AltaManualConfirmar is distinct from OLD.AltaManualConfirmar then
    DELETE FROM cvp.relvis rd USING
    (SELECT r.periodo, r.informante, r.formulario, r.visita
      FROM cvp.relvis r
         LEFT JOIN cvp.informantes i ON r.informante = i.informante
         LEFT JOIN cvp.periodos p ON r.periodo=p.periodo 
         LEFT JOIN (SELECT periodo, informante, formulario, max(visita) AS maxvisita
                    FROM cvp.relvis
                    WHERE panel = NEW.AltaManualPanel --Parámetro
                    GROUP BY  periodo, informante, formulario) v ON v.periodo=p.periodoanterior 
                                                                   AND v.informante = r.informante 
                                                                   AND v.formulario = r.formulario
         LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior
                                    AND r_1.informante = r.informante 
                                    AND r_1.formulario = r.formulario
                                    AND r_1.visita = maxvisita          
         LEFT JOIN cvp.razones z ON r_1.razon = z.razon
         LEFT JOIN (SELECT distinct periodo, informante, visita, formulario, 'S' hayprecios 
                      FROM cvp.relpre) pr ON pr.periodo = r.periodo
                        AND pr.informante = r.informante
                        AND pr.visita = r.visita 
                        AND pr.formulario = r.formulario 
       WHERE r.periodo = NEW.AltaManualPeriodo --Parámetro
         AND r.informante = NEW.informante --Parámetro 
         AND r.panel= NEW.AltaManualPanel --Parámetro
         AND r.tarea= NEW.AltaManualTarea --Parámetro
         --AltaManualPeriodo es el periodo actual
         AND coalesce(i.AltaManualPeriodo,'a0000m00') = NEW.AltaManualPeriodo --Parámetro
         --periodo anterior sin visita en relvis o visita anterior con cierre definitivo  
         AND (maxvisita IS NULL OR COALESCE(z.escierredefinitivoinf,'N')='S' OR COALESCE(z.escierredefinitivofor,'N')='S')
         -- periodo actual sin razon ingresada y sin precios
         AND r.razon IS NULL AND COALESCE(hayprecios,'N') = 'N') d
     WHERE rd.periodo = d.periodo and rd.informante = d.informante and rd.formulario = d.formulario and rd.visita = d.visita;

    insert into cvp.relvis (periodo, visita, informante, formulario, 
                            panel, tarea, FechaSalida, Encuestador, ultima_visita)
      select new.altamanualperiodo, 1, new.informante, fi.formulario, new.altamanualPanel, new.AltaManualTarea, 
             (select p.FechaSalida 
                from cvp.RelPan p
                where p.periodo=new.AltaManualPeriodo and p.panel=new.AltaManualPanel) as fecha,
             (select t.Encuestador
                from cvp.Tareas t
                where t.tarea=new.AltaManualTarea) as encuestador, true
                from cvp.ForInf fi
                where fi.informante=new.informante and fi.altamanualperiodo = new.altamanualperiodo
                AND NOT EXISTS (SELECT * FROM cvp.relvis v
                                 WHERE v.periodo = new.altamanualperiodo AND v.visita = 1 AND v.informante= new.informante 
                                 AND v.formulario=fi.formulario);
    IF NEW.estado = 'No usado' 
      THEN NEW.estado = 'Nuevo';
    END IF;
  end if;
  return new;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER altamanualdeinformantes_trg
    BEFORE UPDATE 
    ON informantes
    FOR EACH ROW
    EXECUTE PROCEDURE altamanualdeinformantes_trg();