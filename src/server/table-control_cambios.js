"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'control_cambios',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'modalidad'            ,typeName:'text'},
            {name:'informante'           ,typeName:'integer'},
            {name:'formulario'           ,typeName:'integer'},
            {name:'cambio'               ,typeName:'text'   },            
            {name:'producto'             ,typeName:'text'   }, 
            {name:'observacion'          ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'precio'               ,typeName:'decimal'},
            {name:'tipoprecio'           ,typeName:'text'   },
            {name:'precionormalizado'    ,typeName:'decimal'},
            {name:'precio_1'             ,typeName:'decimal'},
            {name:'tipoprecio_1'         ,typeName:'text'   },
            {name:'precionormalizado_1'  ,typeName:'decimal'},
            {name:'promobs_1'            ,typeName:'decimal'},
            {name:'masdatos'             ,typeName:'text'   },
            {name:'valor'                ,typeName:'text'   },
            {name:'valor_1'              ,typeName:'text'   },
            {name:'comentariosrelpre'    ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','producto','observacion','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante'] },
            {references:'formularios', fields:['formulario'] },
            {references:'productos'  , fields:['producto']   },
        ],
        sql:{from:
            `(SELECT periodo, panel, tarea, modalidad, informante, formulario, cambio, producto, observacion, visita, 
            precio, tipoprecio, precionormalizado, precio_1, tipoprecio_1, precionormalizado_1, promobs_1, masdatos, comentariosrelpre,
            string_agg(concat(atributo,'(',nombreatributo,')',':',valor), chr(10)) as valor,
            string_agg(concat(atributo,'(',nombreatributo,')',':',valor_1), chr(10)) as valor_1
            FROM (SELECT p.*, r_1.precio precio_1, r_1.tipoprecio tipoprecio_1, r_1.precionormalizado precionormalizado_1, c_1.promobs promobs_1, a_1.valor as valor_1,
                    CASE WHEN r_1.precio > 0 and r_1.precio <> p.precio 
                         THEN round((p.precio/r_1.precio*100-100)::decimal,1)::TEXT||'%' 
                         ELSE CASE WHEN c_1.promobs > 0 and c_1.promobs <> p.precionormalizado and r_1.precio is null 
                              THEN round((p.precionormalizado/c_1.promobs*100-100)::decimal,1)::TEXT||'%' 
                              ELSE NULL 
                              END 
                    END AS masdatos
                  FROM (SELECT r.periodo, v.panel, v.tarea, rt.modalidad, r.informante, r.formulario, 
                          r.cambio, r.producto, r.observacion, r.visita, 
                          r.precio, r.tipoprecio, r.precionormalizado, t.atributo, t.nombreatributo, a.valor, r.comentariosrelpre
                        FROM relpre r
                        JOIN relvis v ON r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
                        JOIN reltar rt ON r.periodo = rt.periodo and v.panel= rt.panel and v.tarea = rt.tarea
                        JOIN relatr a on r.periodo = a.periodo and  r.informante = a.informante  and  r.producto = a.producto 
                             and r.visita = a.visita and r.observacion = a.observacion
                        JOIN atributos t ON  a.atributo = t.atributo
                        WHERE r.cambio = 'C' and t.es_vigencia is null
                       ) p 
                  JOIN periodos per ON p.periodo = per.periodo
                  LEFT JOIN (SELECT c.* 
                             FROM calobs c JOIN calculos_def cd on c.calculo = cd.calculo 
                             WHERE principal) c_1 on per.periodoanterior = c_1.periodo and p.producto = c_1.producto and 
                             p.observacion = c_1.observacion and p.informante = c_1.informante
                  LEFT JOIN relpre r_1 ON r_1.periodo =
                    CASE
                        WHEN p.visita > 1 THEN p.periodo
                        ELSE per.periodoanterior
                    END AND (r_1.ultima_visita = true AND p.visita = 1 OR p.visita > 1 AND r_1.visita = (p.visita - 1)) 
                      AND r_1.informante = p.informante AND r_1.producto = p.producto AND r_1.observacion = p.observacion
                  LEFT JOIN relatr a_1 on a_1.periodo = r_1.periodo and a_1.informante = r_1.informante and 
                        r_1.visita = a_1.visita and r_1.observacion = a_1.observacion and r_1.producto = a_1.producto and p.atributo = a_1.atributo
                  WHERE p.valor is distinct from a_1.valor
                 ) Q
            GROUP BY periodo, panel, tarea, modalidad, informante, formulario, cambio, producto, observacion, visita, 
            precio, tipoprecio, precionormalizado, precio_1, tipoprecio_1, precionormalizado_1, promobs_1, masdatos, comentariosrelpre
            ORDER BY periodo, panel, tarea, modalidad, informante, formulario, cambio, producto, observacion, visita, 
            precio, tipoprecio, precionormalizado, precio_1, tipoprecio_1, precionormalizado_1, promobs_1, masdatos, comentariosrelpre)`
            },
    },context);
}