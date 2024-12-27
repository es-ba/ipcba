SET SEARCH_PATH = cvp;

ALTER TABLE prodatrval ADD COLUMN modi_usu character varying(30);
ALTER TABLE prodatrval ADD COLUMN modi_fec timestamp without time zone;
ALTER TABLE prodatrval ADD COLUMN modi_ope character varying(1);

CREATE OR REPLACE TRIGGER prodatrval_modi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.prodatrval
    FOR EACH ROW
    EXECUTE FUNCTION cvp.modi_trg();
    
CREATE OR REPLACE FUNCTION hisc_prodatrval_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
      v_operacion text:=substr(TG_OP,1,1);
BEGIN
      IF v_operacion='I' THEN
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','producto','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.producto),new.producto);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','atributo','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo),new.atributo);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','valor','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor),new.valor);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','orden','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.orden),new.orden);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_number)
              VALUES ('cvp','prodatrval','atributo_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.atributo_2),new.atributo_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','valor_2','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.valor_2),new.valor_2);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','modi_usu','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_datetime)
              VALUES ('cvp','prodatrval','modi_fec','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
         INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,new_text)
              VALUES ('cvp','prodatrval','modi_ope','I',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
      END IF;
      IF v_operacion='U' THEN
        IF new.producto IS DISTINCT FROM old.producto THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','producto','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.producto)||'->'||comun.a_texto(new.producto),old.producto,new.producto);
        END IF;
        IF new.atributo IS DISTINCT FROM old.atributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','atributo','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo)||'->'||comun.a_texto(new.atributo),old.atributo,new.atributo);
        END IF;
        IF new.valor IS DISTINCT FROM old.valor THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','valor','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor)||'->'||comun.a_texto(new.valor),old.valor,new.valor);
        END IF;
        IF new.orden IS DISTINCT FROM old.orden THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','orden','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.orden)||'->'||comun.a_texto(new.orden),old.orden,new.orden);
        END IF;    
        IF new.atributo_2 IS DISTINCT FROM old.atributo_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number,new_number)
                 VALUES ('cvp','prodatrval','atributo_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.atributo_2)||'->'||comun.a_texto(new.atributo_2),old.atributo_2,new.atributo_2);
        END IF;    
        IF new.valor_2 IS DISTINCT FROM old.valor_2 THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','valor_2','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.atributo,new.valor,comun.A_TEXTO(old.valor_2)||'->'||comun.a_texto(new.valor_2),old.valor_2,new.valor_2);
        END IF;
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','modi_usu','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.valor,new.atributo,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','prodatrval','modi_fec','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.valor,new.atributo,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text,new_text)
                 VALUES ('cvp','prodatrval','modi_ope','U',new.producto||'|'||new.atributo||'|'||new.valor,new.producto,new.valor,new.atributo,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
      END IF;
      IF v_operacion='D' THEN
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','producto','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.producto),old.producto);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','atributo','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo),old.atributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','valor','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor),old.valor);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','orden','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.orden),old.orden);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_number)
             VALUES ('cvp','prodatrval','atributo_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.atributo_2),old.atributo_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','valor_2','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.valor_2),old.valor_2);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','modi_usu','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_datetime)
             VALUES ('cvp','prodatrval','modi_fec','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_text_3,change_value,old_text)
             VALUES ('cvp','prodatrval','modi_ope','D',old.producto||'|'||old.atributo||'|'||old.valor,old.producto,old.atributo,old.valor,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;  
      END IF;
END;
$BODY$;

ALTER FUNCTION hisc_prodatrval_trg()
    OWNER TO cvpowner;

CREATE OR REPLACE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON cvp.prodatrval
    FOR EACH ROW
    EXECUTE FUNCTION cvp.hisc_prodatrval_trg();

create or replace view informantesaltasbajas as
SELECT x.periodoanterior, x.informante, x.visita, x.rubro, x.nombrerubro, x.formulario, x.nombreformulario, x.panelanterior, x.tareaanterior, x.razonanterior,
x.nombrerazonanterior,x.periodo,x.panel,x.tarea,x.razon, x.nombrerazon, x.tipo, x.distrito, x.fraccion_ant, x.comuna, x.fraccion, x.radio, x.manzana, x.depto, x.barrio, ca.cantformactivos 
FROM (
SELECT r_1.periodo periodoanterior, r_1.informante informanteanterior, i.rubro, ru.nombrerubro, r_1.formulario formularioanterior, f.nombreformulario, r_1.visita visitaanterior, 
       r_1.panel panelanterior, r_1.tarea tareaanterior, r_1.razon razonanterior, zr_1.nombrerazon nombrerazonanterior,
       r.periodo, r.informante, r.formulario, r.visita, r.panel, r.tarea, r.razon, zr.nombrerazon,
       CASE WHEN r_1.periodo is null AND r.periodo is not null AND (zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S') THEN 'Alta-Baja en '||r.periodo
            WHEN zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S' THEN 'Baja en '||r.periodo 
            WHEN r_1.periodo is null AND r.periodo is not null THEN 'Alta'
            WHEN zr_1.escierredefinitivoinf = 'S' or zr_1.escierredefinitivofor = 'S' THEN 'Baja en '||r_1.periodo
            WHEN r_1.razon is null THEN 'No ingresado '||r_1.periodo
            WHEN r.razon is null THEN 'No ingresado '||r.periodo
            ELSE 'Continuo' END as tipo, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio
  FROM cvp.relvis r 
  LEFT JOIN cvp.periodos p ON p.periodo = r.periodo 
  LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior AND r.informante = r_1.informante AND r.formulario = r_1.formulario AND r.visita = r_1.visita
  LEFT JOIN cvp.razones zr ON r.razon = zr.razon 
  LEFT JOIN cvp.razones zr_1 ON r_1.razon = zr_1.razon
  LEFT JOIN cvp.informantes i ON r.informante = i.informante   
  LEFT JOIN cvp.rubros ru ON i.rubro = ru.rubro
  LEFT JOIN cvp.formularios f ON r.formulario = f.formulario  
UNION
SELECT r_1.periodo periodoanterior, r_1.informante informanteanterior, i.rubro, ru.nombrerubro, r_1.formulario formularioanterior, f.nombreformulario, r_1.visita visitaanterior, 
       r_1.panel panelanterior, r_1.tarea tareaanterior, r_1.razon razONanterior, zr_1.nombrerazon nombrerazONanterior,
       r.periodo, r.informante, r.formulario, r.visita, r.panel, r.tarea, r.razon, zr.nombrerazon,
       CASE WHEN zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S' THEN 'Baja en '||r.periodo
            WHEN r_1.periodo is null AND r.periodo is not null THEN 'Alta'
            WHEN zr_1.escierredefinitivoinf = 'S' or zr_1.escierredefinitivofor = 'S' THEN 'Baja en '||r_1.periodo 
            WHEN r_1.razon is null THEN 'No ingresado '||r_1.periodo
            WHEN r.razon is null THEN 'No ingresado '||r.periodo
            ELSE 'Continuo' END as tipo, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio
  FROM cvp.relvis r_1 
  LEFT JOIN cvp.periodos p ON p.periodoanterior = r_1.periodo 
  LEFT JOIN cvp.relvis r ON r.periodo = p.periodo AND r.informante = r_1.informante AND r.formulario = r_1.formulario AND r.visita = r_1.visita
  LEFT JOIN cvp.razones zr ON r.razon = zr.razon 
  LEFT JOIN cvp.razones zr_1 ON r_1.razon = zr_1.razon 
  LEFT JOIN cvp.informantes i ON r.informante = i.informante   
  LEFT JOIN cvp.rubros ru ON i.rubro = ru.rubro
  LEFT JOIN cvp.formularios f ON r_1.formulario = f.formulario  
) as X 
LEFT JOIN (SELECT periodo, informante, visita, count(*)::integer cantformactivos 
             FROM cvp.relvis v 
             LEFT JOIN cvp.razones s ON v.razon = s.razon 
             WHERE not (s.escierredefinitivoinf = 'S' or s.escierredefinitivofor = 'S')
             GROUP BY periodo, informante, visita) ca ON X.periodo = ca.periodo AND X.informante = ca.informante AND X.visita = ca.visita
WHERE tipo <> 'Continuo' and tipo <> ('No ingresado '||x.periodo)::text and x.visita = 1
ORDER BY periodoanterior, informanteanterior, visitaanterior, formularioanterior;

DROP VIEW IF EXISTS informantesrazon;
CREATE OR REPLACE VIEW informantesrazon AS
  SELECT COALESCE(q.periodo, b.periodo) periodo, COALESCE(q.razones, b.razones) razon, 
      COALESCE(q.nombresrazones, b.nombresrazones) nombrerazon, informantes cantinformantes, formularios cantformularios
    FROM (
      SELECT periodo, razones, nombresrazones, COUNT(*) informantes 
        FROM (
          SELECT periodo, informante, STRING_AGG(razon::text, '~' ORDER BY razon) razones, 
              STRING_AGG(nombrerazon::text, '~' ORDER BY razon) nombresrazones 
            FROM (
              SELECT DISTINCT r.periodo, r.informante, r.razon, z.nombrerazon
                FROM relvis r 
                JOIN razones z ON r.razon = z.razon
                WHERE r.visita = 1
            ) x
        GROUP BY periodo, informante
        ) w
      GROUP BY 1,2,3
      ) q
    FULL OUTER JOIN (
      SELECT periodo, razon::text AS razones, nombrerazon AS nombresrazones, COUNT(DISTINCT (informante, formulario)) formularios 
        FROM (
          SELECT r.periodo, r.informante, r.formulario, r.razon, z.nombrerazon
            FROM relvis r 
            JOIN razones z ON r.razon = z.razon
            WHERE r.visita = 1
        ) x
      GROUP BY 1,2,3
      ) b ON q.periodo = b.periodo AND q.razones = b.razones AND q.nombresrazones = b.nombresrazones
  ORDER BY 1,split_part(COALESCE(q.razones,b.razones),'~',1)::integer, 
    CASE WHEN split_part(COALESCE(q.razones,b.razones),'~',2) = '' 
      THEN NULL ELSE split_part(COALESCE(q.razones,b.razones),'~',2) 
    END ::integer NULLS FIRST, COALESCE(q.nombresrazones, b.nombresrazones);

GRANT SELECT ON TABLE informantesrazon TO cvp_usuarios;
GRANT SELECT ON TABLE informantesrazon TO cvp_recepcionista;