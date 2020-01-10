"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_verificar_precio',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'panel'                        ,typeName:'integer'}, 
            {name:'tarea'                        ,typeName:'integer'},
            {name:'periodoant'                   ,typeName:'text'   },
            {name:'producto'                     ,typeName:'text'   },
            {name:'informante'                   ,typeName:'integer'},
            {name:'formulario'                   ,typeName:'integer'},
            {name:'visita'                       ,typeName:'integer'},
            {name:'observacion'                  ,typeName:'integer'},
            {name:'precionormalizadoant'         ,typeName:'decimal'},
            {name:'tipoprecioant'                ,typeName:'text'   },
            {name:'comentariosrelpreant'         ,typeName:'text'   },
            {name:'periodo'                      ,typeName:'text'   },
            {name:'precionormalizado'            ,typeName:'decimal'},
            {name:'tipoprecio'                   ,typeName:'text'   },
            {name:'variacion'                    ,typeName:'decimal'},
            {name:'comentariosrelpre'            ,typeName:'text'   },
            {name:'cantperiodosconigualprecio'   ,typeName:'integer'},
 
        ],
        primaryKey:['periodo','informante','producto','visita','observacion'],
        sql:{
         from:`(SELECT cv.panel, cv.tarea, cv.periodo as periodoant, cv.producto, cv.informante, rp.formulario, cv.visita, cv.observacion, cv.precionormalizado as precionormalizadoant,
                  cv.tipoprecio as tipoprecioant, cv.comentariosrelpre as comentariosrelpreant, rp.periodo, rp.precionormalizado, rp.tipoprecio, 
                  case when cv.precionormalizado is not null and rp.precionormalizado is not null and cv.precionormalizado is distinct from rp.precionormalizado then
                  round((rp.precionormalizado/cv.precionormalizado*100-100)::decimal,2) else null end variacion, rp.comentariosrelpre, cv.cantprecios as cantperiodosconigualprecio 
                  FROM relpre rp 
                  INNER JOIN control_sinvariacion cv on cv.periodo = cvp.moverperiodos(rp.periodo,-1) and cv.informante = rp.informante and cv.producto = rp.producto and 
                  cv.visita = rp.visita and cv.observacion = rp.observacion
                  INNER JOIN tareas t on cv.tarea = t.tarea
                  WHERE t.activa = 'S' and t.operativo = 'C')`
        }
    });
}