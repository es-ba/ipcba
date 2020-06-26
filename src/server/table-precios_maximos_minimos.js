"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'precios_maximos_minimos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'analista'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'umabreviada'                      , typeName:'text'                     , allow:{update:false}},
            {name:'normaliza'                        , typeName:'text'                     , allow:{update:false}},
            {name:'normalizable'                     , typeName:'boolean'                  , allow:{update:false}},
            {name:'precio1'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex1'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio2'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex2'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio3'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex3'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio4'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex4'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio5'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex5'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio6'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex6'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio7'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex7'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio8'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex8'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio9'                          , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex9'                              , typeName:'text'                     , allow:{update:false}},
            {name:'precio10'                         , typeName:'decimal'                  , allow:{update:false}},
            {name:'ex10'                             , typeName:'text'                     , allow:{update:false}},
            {name:'varmin'                           , typeName:'decimal'                  , allow:{update:false}},
            {name:'varmax'                           , typeName:'decimal'                  , allow:{update:false}},
            {name:'informantes1'                     , typeName:'text'                     , allow:{update:false}},
            {name:'informantes2'                     , typeName:'text'                     , allow:{update:false}},
            {name:'informantes9'                     , typeName:'text'                     , allow:{update:false}},
            {name:'informantes10'                    , typeName:'text'                     , allow:{update:false}},
        ],
        primaryKey:['periodo','producto'],
        hiddenColumns:['normaliza'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from: `(SELECT periodo, producto, analista,
                max(CASE WHEN orden_precio_minimo = 1 THEN q.precio END) as precio1,
                max(CASE WHEN orden_precio_minimo = 1 THEN q.marca END) as ex1,
                max(CASE WHEN orden_precio_minimo = 2 THEN q.precio END) as precio2,
                max(CASE WHEN orden_precio_minimo = 2 THEN q.marca END) as ex2,
                max(CASE WHEN orden_precio_minimo = 3 THEN q.precio END) as precio3,
                max(CASE WHEN orden_precio_minimo = 3 THEN q.marca END) as ex3,
                max(CASE WHEN orden_precio_minimo = 4 THEN q.precio END) as precio4,
                max(CASE WHEN orden_precio_minimo = 4 THEN q.marca END) as ex4,
                max(CASE WHEN orden_precio_minimo = 5 THEN q.precio END) as precio5,
                max(CASE WHEN orden_precio_minimo = 5 THEN q.marca END) as ex5,
                umabreviada, normaliza, normalizable,
                max(CASE WHEN orden_precio_maximo = 5 THEN q.precio END) as precio6,
                max(CASE WHEN orden_precio_maximo = 5 THEN q.marca END) as ex6,
                max(CASE WHEN orden_precio_maximo = 4 THEN q.precio END) as precio7,
                max(CASE WHEN orden_precio_maximo = 4 THEN q.marca END) as ex7,
                max(CASE WHEN orden_precio_maximo = 3 THEN q.precio END) as precio8,
                max(CASE WHEN orden_precio_maximo = 3 THEN q.marca END) as ex8,
                max(CASE WHEN orden_precio_maximo = 2 THEN q.precio END) as precio9,
                max(CASE WHEN orden_precio_maximo = 2 THEN q.marca END) as ex9,
                max(CASE WHEN orden_precio_maximo = 1 THEN q.precio END) as precio10,
                max(CASE WHEN orden_precio_maximo = 1 THEN q.marca END) as ex10,
                CASE WHEN max(CASE WHEN orden_precio_minimo = 1 THEN q.precio END)>0 THEN
                      round((max(CASE WHEN orden_precio_minimo = 2 THEN q.precio END)
                           /max(CASE WHEN orden_precio_minimo = 1 THEN q.precio END))::decimal*100-100,2) ELSE null END as varmin,
                CASE WHEN max(CASE WHEN orden_precio_maximo = 2 THEN q.precio END)>0 THEN
                      round((max(CASE WHEN orden_precio_maximo = 1 THEN q.precio END)
                           /max(CASE WHEN orden_precio_maximo = 2 THEN q.precio END))::decimal*100-100,2) ELSE null END as varmax,
                string_agg(CASE WHEN orden_precio_minimo = 1 THEN q.informante::text||'('||q.observacion||')'||'('||q.tipoprecio||')p:'||q.panel||' t:'||q.tarea END, '|' order by q.informante,q.observacion) AS informantes1,
                string_agg(CASE WHEN orden_precio_minimo = 2 THEN q.informante::text||'('||q.observacion||')'||'('||q.tipoprecio||')p:'||q.panel||' t:'||q.tarea END, '|' order by q.informante,q.observacion) AS informantes2,
                string_agg(CASE WHEN orden_precio_maximo = 2 THEN q.informante::text||'('||q.observacion||')'||'('||q.tipoprecio||')p:'||q.panel||' t:'||q.tarea END, '|' order by q.informante,q.observacion) AS informantes9,
                string_agg(CASE WHEN orden_precio_maximo = 1 THEN q.informante::text||'('||q.observacion||')'||'('||q.tipoprecio||')p:'||q.panel||' t:'||q.tarea END, '|' order by q.informante,q.observacion) AS informantes10
              FROM (
                SELECT e.periodo, e.producto, cp.responsable as analista, o.nombreproducto, o.unidadmedidaabreviada as umabreviada,
                normaliza,
                pa.producto is not null as normalizable, 
                CASE WHEN o.controlar_precios_sin_normalizar THEN precio ELSE round(precionormalizado::decimal,2) END as precio, 
                CASE WHEN antiguedadexcluido is NOT NULL THEN 'X' ELSE null END as marca,
                e.informante, e.observacion, e.tipoprecio, v.panel, v.tarea,
                dense_rank() 
                OVER (PARTITION BY e.periodo, e.producto, o.nombreproducto  
                       ORDER BY CASE WHEN o.controlar_precios_sin_normalizar THEN precio ELSE round(precionormalizado::decimal,2) END, 
                                CASE WHEN antiguedadexcluido is NOT NULL THEN 'X' ELSE null END)
                as orden_precio_minimo,
                dense_rank() 
                OVER (PARTITION BY e.periodo, e.producto, o.nombreproducto  
                       ORDER BY (CASE WHEN o.controlar_precios_sin_normalizar THEN precio ELSE round(precionormalizado::decimal,2) END, 
                           CASE WHEN antiguedadexcluido is NOT NULL THEN 'X' ELSE null END) desc) 
                as orden_precio_maximo
                FROM calprodresp cp
                INNER JOIN relpre e ON cp.periodo = e.periodo and cp.producto = e.producto
                INNER JOIN productos o on e.producto = o.producto
                INNER JOIN relvis v on e.periodo = v.periodo and e.informante = v.informante and e.visita = v.visita and e.formulario = v.formulario
                LEFT JOIN (SELECT producto, string_agg(distinct concat_ws(' ', valornormal, unidaddemedida),' ') normaliza FROM prodatr
                            LEFT JOIN atributos using(atributo) WHERE normalizable = 'S' GROUP BY producto) pa on e.producto = pa.producto
                LEFT JOIN calculos a on e.periodo = a.periodo and cp.calculo = a.calculo
                LEFT JOIN calobs c on e.periodo = c.periodo and c.calculo = a.calculo and e.producto = c.producto and e.informante = c.informante and e.observacion = c.observacion
                WHERE e.precionormalizado is not null and not(c.division is null AND e.modi_fec < a.fechacalculo)
                      and cp.calculo = 0
                ) q
                group by periodo, producto, analista, umabreviada, normaliza, normalizable
                order by periodo, producto, analista, umabreviada, normaliza, normalizable
            )`,
            isTable: false,
        }    
    },context);
}