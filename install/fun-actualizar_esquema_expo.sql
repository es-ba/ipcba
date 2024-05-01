set search_path = expo;
CREATE OR REPLACE FUNCTION actualizar_esquema_expo(
    pperiodo text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN 
    DELETE FROM expo.tb_imp_indices;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=2;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=1;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=0;
    DELETE FROM expo.tb_imp_columnas;
    DELETE FROM expo.tb_imp_periodos;
    DELETE FROM expo.tb_imp_parametros;
    
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Periodo_Actual','Periodo a partir del cual se realiza la importacion',pperiodo);
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Cantidad_Maxima_Perfiles','Cantidad máxima de perfiles que puede cargar un usuario normal(los Tutores no tienen máximo)',5);
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Momento_Exportacion_Origen','Momento de Exportacion de la base IPCBA',to_char(clock_timestamp(),'yyyy-mm-dd HH24:MI:ss'));
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Momento_Exportacion_Destino','Momento Exportacion a MySql tuinflacion',null);
    INSERT INTO expo.tb_imp_periodos(periodo, anio, mes)
        SELECT c.periodo, p.ano, p.mes
          FROM cvp.calculos c join cvp.periodos p on c.periodo=p.periodo 
          JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
          WHERE cd.principal and c.abierto='N' and c.periodo <= pperiodo
          ORDER by c.periodo desc
          LIMIT 13;
    -- solo las columnas correspondientes al periodo pperiodo      
    INSERT INTO expo.tb_imp_columnas(periodo, columna, periodo_denominador, texto_columna)
        SELECT periodo, columna, periodo_denominador, texto_columna
            FROM (
                  SELECT periodo, 1 as columna, 
                         cvp.periodo_mes_anterior(periodo) as periodo_denominador,
                         'Respecto del mes anterior' as texto_columna
                    FROM cvp.calculos
                    WHERE abierto='N' and periodo =pperiodo 
                  UNION
                    SELECT periodo, 2 as columna, cvp.periodo_diciembre_anterior(periodo) as periodo_denominador,'Acumulado Anual' as texto_columna
                      FROM cvp.calculos
                      WHERE abierto='N' and periodo =pperiodo and 
                            substr(periodo,7,2) not in ('01','12') 
                  UNION
                    SELECT periodo, 
                           case when substr(periodo,7,2) in ('01','12') then 2  else 3 end as columna,
                           cvp.periodo_igual_mes_anno_anterior(periodo) as periodo_denominador,
                           'Variacion Interanual' as texto_columna
                      FROM cvp.calculos
                      WHERE abierto='N' and periodo =pperiodo 
                  ORDER BY periodo, columna ) as tt ;   
    INSERT INTO expo.tb_imp_rubros(rubro, nombre_rubro,explicacion_rubro,nivel,rubro_padre,aparece_en_resultados)
          select replace(grupo, 'Z','R') rubro,
                 overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1) as nombre_rubro,
                 explicaciongrupo as explicacion_rubro,nivel,
                 replace(grupopadre,'Z','R') as rubro_padre, 1 as aparece_en_resultados
              from cvp.grupos
              where agrupacion= 'Z' and nivel<=1
              order by nivel, grupo;
    INSERT INTO expo.tb_imp_indices(periodo,rubro,indice)
            select c.periodo, replace(c.grupo, 'Z','R') rubro, c.indiceredondeado indice
                from cvp.calgru c join cvp.grupos g on c.grupo=g.grupo and c.agrupacion= g.agrupacion
                      join cvp.calculos a on a.periodo=c.periodo AND a.calculo= c.calculo
                      join cvp.calculos_def cd on a.calculo = cd.calculo 
                where g.agrupacion='Z' and cd.principal and g.nivel<=1 and 
                      a.abierto='N' and (c.periodo=pperiodo or
                                         c.periodo in (select x.periodo_denominador from expo.tb_imp_columnas x where x.periodo=pperiodo))
            order by periodo, rubro ;                     
END
$BODY$;