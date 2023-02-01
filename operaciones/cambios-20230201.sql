set search_path = cvp;
ALTER TABLE atributos ADD COLUMN separador text;

CREATE OR REPLACE FUNCTION cvp.hisc_atributos_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$

  DECLARE
    v_operacion text:=substr(TG_OP,1,1);
  BEGIN
    
  IF v_operacion='I' THEN
    
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_number)
             VALUES ('cvp','atributos','atributo','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.atributo),new.atributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','nombreatributo','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.nombreatributo),new.nombreatributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','tipodato','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.tipodato),new.tipodato);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','abratributo','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.abratributo),new.abratributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','escantidad','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.escantidad),new.escantidad);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','unidaddemedida','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.unidaddemedida),new.unidaddemedida);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_bool)
             VALUES ('cvp','atributos','es_vigencia','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.es_vigencia),new.es_vigencia);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','valorinicial','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.valorinicial),new.valorinicial);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','visible','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.visible),new.visible);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,new_text)
             VALUES ('cvp','atributos','separador','I',new.atributo,new.atributo,'I:'||comun.a_texto(new.separador),new.separador);

  END IF;
  IF v_operacion='U' THEN
        
        IF new.atributo IS DISTINCT FROM old.atributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number,new_number)
                 VALUES ('cvp','atributos','atributo','U',new.atributo,new.atributo,comun.A_TEXTO(old.atributo)||'->'||comun.a_texto(new.atributo),old.atributo,new.atributo);
        END IF;    
        IF new.nombreatributo IS DISTINCT FROM old.nombreatributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','nombreatributo','U',new.atributo,new.atributo,comun.A_TEXTO(old.nombreatributo)||'->'||comun.a_texto(new.nombreatributo),old.nombreatributo,new.nombreatributo);
        END IF;    
        IF new.tipodato IS DISTINCT FROM old.tipodato THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','tipodato','U',new.atributo,new.atributo,comun.A_TEXTO(old.tipodato)||'->'||comun.a_texto(new.tipodato),old.tipodato,new.tipodato);
        END IF;    
        IF new.abratributo IS DISTINCT FROM old.abratributo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','abratributo','U',new.atributo,new.atributo,comun.A_TEXTO(old.abratributo)||'->'||comun.a_texto(new.abratributo),old.abratributo,new.abratributo);
        END IF;    
        IF new.escantidad IS DISTINCT FROM old.escantidad THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','escantidad','U',new.atributo,new.atributo,comun.A_TEXTO(old.escantidad)||'->'||comun.a_texto(new.escantidad),old.escantidad,new.escantidad);
        END IF;    
        IF new.unidaddemedida IS DISTINCT FROM old.unidaddemedida THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','unidaddemedida','U',new.atributo,new.atributo,comun.A_TEXTO(old.unidaddemedida)||'->'||comun.a_texto(new.unidaddemedida),old.unidaddemedida,new.unidaddemedida);
        END IF;
        IF new.es_vigencia IS DISTINCT FROM old.es_vigencia THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_bool,new_bool)
                 VALUES ('cvp','atributos','es_vigencia','U',new.atributo,new.atributo,comun.A_TEXTO(old.es_vigencia)||'->'||comun.a_texto(new.es_vigencia),old.es_vigencia,new.es_vigencia);
        END IF;
        IF new.valorinicial IS DISTINCT FROM old.valorinicial THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','valorinicial','U',new.atributo,new.atributo,comun.A_TEXTO(old.valorinicial)||'->'||comun.a_texto(new.valorinicial),old.valorinicial,new.valorinicial);
        END IF;    
        IF new.visible IS DISTINCT FROM old.visible THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','visible','U',new.atributo,new.atributo,comun.A_TEXTO(old.visible)||'->'||comun.a_texto(new.visible),old.visible,new.visible);
        END IF;    
        IF new.separador IS DISTINCT FROM old.separador THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text,new_text)
                 VALUES ('cvp','atributos','separador','U',new.atributo,new.atributo,comun.A_TEXTO(old.separador)||'->'||comun.a_texto(new.separador),old.separador,new.separador);
        END IF;    

  END IF;
  IF v_operacion='D' THEN
    
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_number)
             VALUES ('cvp','atributos','atributo','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.atributo),old.atributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','nombreatributo','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.nombreatributo),old.nombreatributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','tipodato','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.tipodato),old.tipodato);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','abratributo','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.abratributo),old.abratributo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','escantidad','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.escantidad),old.escantidad);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','unidaddemedida','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.unidaddemedida),old.unidaddemedida);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','es_vigencia','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.es_vigencia),old.es_vigencia);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','valorinicial','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.valorinicial),old.valorinicial);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','visible','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.visible),old.visible);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_number_1,change_value,old_text)
             VALUES ('cvp','atributos','separador','D',old.atributo,old.atributo,'D:'||comun.a_texto(old.separador),old.separador);
  END IF;
  
  IF v_operacion<>'D' THEN
      RETURN new;
  ELSE
      RETURN old;  
  END IF;
  END;
$BODY$;

---------------------------------------------------------------
UPDATE atributos set separador = 'y/o ' where atributo = 245;
---------------------------------------------------------------
CREATE OR REPLACE VIEW ParaImpresionFormulariosEnBlanco AS
  SELECT f.formulario, fo.producto, fo.ordenimpresion as orden, fo.observacion, 
        f.nombreformulario,
        e.tamannonormal, coalesce(p.nombreparaformulario,p.nombreproducto) nombreproducto, 
        substr(fo.producto,2)::varchar(8) AS codigo_producto, p.cantobs, f.soloparatipo, f.despacho,
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
            COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
            ||COALESCE(
                NULLIF(TRIM(
                    COALESCE(trim(e.envase)||' ','')||
                    CASE WHEN e.mostrar_cant_um='N' THEN ''
                    ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '. '
            , '') 
            ||string_agg(
               CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
                  CASE WHEN t.visiblenombreatributo = 'S' THEN concat(a.separador,a.nombreatributo)||' ' ELSE '' END||
                  'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')
                  ||CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN ' ó '||t.valornormal||' '||a.unidaddemedida ELSE '' END||'. '
                ELSE ''
               END,'' ORDER BY t.orden)
            ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '') AS EspecificacionCompleta
            , fo.dependedeldespacho
            , e.destacada 
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
    FROM cvp.formularios f 
      INNER JOIN cvp.forobs fo ON f.formulario=fo.formulario
      INNER JOIN cvp.forprod fp ON fo.formulario = fp.formulario AND fo.producto = fp.producto
      INNER JOIN cvp.especificaciones e ON fo.producto=e.producto AND fo.especificacion=e.especificacion
      INNER JOIN cvp.productos p ON e.producto=p.producto
      LEFT JOIN cvp.prodatr t ON fo.producto = t.producto
      LEFT JOIN cvp.atributos a ON a.atributo = t.atributo
    GROUP BY f.formulario, fo.producto, fo.ordenimpresion, fo.observacion, 
        f.nombreformulario, e.nombreespecificacion, 
        e.tamannonormal, coalesce(p.nombreparaformulario,p.nombreproducto), 
        p.cantobs, f.soloparatipo, f.despacho,
        e.envase, e.cantidad, e.unidaddemedida, e.excluir, fo.dependedeldespacho, e.destacada, e.mostrar_cant_um
    ORDER BY f.formulario, fo.ordenimpresion, fo.observacion;
----------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ParaImpresionFormulariosPrecios AS 
 SELECT v.periodo, v.panel, v.tarea, i.direccion, i.ordenhdr, v.informante, v.formulario, f.nombreformulario, v.fechasalida, v.razon, 
        v.fechageneracion, v.visita, v.ultimavisita, fo.producto, fo.ordenimpresion as orden, 
        coalesce(d.nombreparaformulario,d.nombreproducto) nombreproducto, fo.observacion, p.precio, p.tipoprecio, e.nombreespecificacion, 
        substr(fo.producto, 2) AS codigo_producto, i.tipoinformante, NULLIF(v.razon, 1) AS razonimpresa, f.orden as ordenFormulario,  
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
        COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
        ||COALESCE(
            NULLIF(TRIM(
                COALESCE(trim(e.envase)||' ','')||
                CASE WHEN e.mostrar_cant_um='N' THEN ''
                     ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') 
                     END),'')|| '. '
        , '') 
        ||string_agg(
           CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
              CASE WHEN t.visiblenombreatributo = 'S' THEN 
                   concat(a.separador,a.nombreatributo)||' ' 
                   ELSE '' 
                   END||'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')||
              CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN 
                   ' ó '||t.valornormal||' '||a.unidaddemedida 
                   ELSE '' 
                   END||
              CASE WHEN t.otraunidaddemedida IS NOT NULL THEN
                   '/'||t.otraunidaddemedida||'.'
                   ELSE ''
                   END||' '
              ELSE ''
              END,'' ORDER BY t.orden)
        ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '') AS EspecificacionCompleta,
        CASE WHEN prP.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaP,
        CASE WHEN prPmas1.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas1,
        CASE WHEN prPmas2.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas2,
        CASE WHEN prPmas3.periodo IS NOT NULL THEN 'R'
        END as IndicacionRepreguntaPmas3,
        e.destacada,
        rub.rubro
        --ESPECIFICACIÓN: Si cambia ParaImpresionFormulariosPrecios debe cambiar ParaImpresionFormulariosEnBlanco
   FROM cvp.relvis v
      JOIN cvp.periodos per ON per.periodo=v.periodo
      JOIN cvp.formularios f ON v.formulario = f.formulario
      JOIN cvp.informantes i ON v.informante = i.informante
      JOIN cvp.rubros rub ON rub.rubro=i.rubro
      JOIN cvp.forobsinf fo ON fo.formulario=v.formulario and fo.informante = i.informante
      JOIN cvp.productos d ON fo.producto = d.producto
      JOIN cvp.especificaciones e ON fo.producto = e.producto AND fo.especificacion = e.especificacion
      LEFT JOIN cvp.relpre p
       ON 1=p.visita 
        AND per.periodoanterior = p.periodo
        AND v.informante = p.informante 
        AND fo.producto = p.producto
        AND fo.observacion = p.observacion
      LEFT JOIN cvp.prodatr t ON fo.producto = t.producto 
      LEFT JOIN cvp.atributos a ON a.atributo = t.atributo
      LEFT JOIN cvp.prerep prP ON per.periodo = prP.periodo 
        AND d.producto = prP.producto 
        AND i.informante = prP.informante
      LEFT JOIN cvp.prerep prPmas1 ON cvp.MoverPeriodos(per.periodo,1) = prPmas1.periodo 
        AND d.producto = prPmas1.producto 
        AND i.informante = prPmas1.informante
      LEFT JOIN cvp.prerep prPmas2 ON cvp.MoverPeriodos(per.periodo,2) = prPmas2.periodo 
        AND d.producto = prPmas2.producto 
        AND i.informante = prPmas2.informante
      LEFT JOIN cvp.prerep prPmas3 ON cvp.MoverPeriodos(per.periodo,3) = prPmas3.periodo 
        AND d.producto = prPmas3.producto 
        AND i.informante = prPmas3.informante
      WHERE (fo.dependedeldespacho = 'N' or rub.despacho = 'A' OR fo.observacion = 1)
  GROUP BY v.periodo, v.panel, v.tarea, i.direccion, i.ordenhdr, v.informante, v.formulario, f.nombreformulario, v.fechasalida, v.razon, 
        v.fechageneracion, v.visita, v.ultimavisita, fo.producto, fo.ordenimpresion, coalesce(d.nombreparaformulario,d.nombreproducto), fo.observacion, p.precio, p.tipoprecio, 
        e.nombreespecificacion, i.tipoinformante, e.envase, e.excluir, e.cantidad, e.unidaddemedida, prP.periodo
        , prPmas1.periodo, prPmas2.periodo, prPmas3.periodo, f.orden, e.destacada, rub.rubro, e.mostrar_cant_um
  ORDER BY v.periodo, v.panel, v.tarea, i.ordenhdr, i.direccion, v.informante, f.orden, fo.ordenimpresion, fo.observacion;
