"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'relpre_1_sn',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodoactual'                ,typeName:'text'   }, 
            {name:'producto'                     ,typeName:'text'   },
            {name:'observacion'                  ,typeName:'integer'},
            {name:'informante'                   ,typeName:'integer'},
            {name:'formulario'                   ,typeName:'integer'},
            {name:'visita'                       ,typeName:'integer'},
            {name:'precio'                       ,typeName:'decimal'},
            {name:'tipoprecio'                   ,typeName:'text'   },
            {name:'cambio'                       ,typeName:'text'   },
            {name:'precionormalizado'            ,typeName:'decimal'},
            {name:'comentarios'                  ,typeName:'text'   },
            {name:'observaciones'                ,typeName:'text'   },
            {name:'periodo'                      ,typeName:'text'   },
            {name:'visita1'                      ,typeName:'integer'},
            {name:'precio1'                      ,typeName:'decimal'},
            {name:'tipoprecio1'                  ,typeName:'text'   },
            {name:'cambio1'                      ,typeName:'text'   },
            {name:'precionormalizado1'           ,typeName:'decimal'},
            {name:'comentarios1'                 ,typeName:'text'   },
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'encuestador'                  ,typeName:'text'   },
            {name:'encuestadornombre'            ,typeName:'text'   },
        ],
        primaryKey:['periodoactual','informante','producto','visita','observacion'],
        sql:{
         from:`(SELECT r.periodo as periodoactual, r.producto, r.observacion, r.informante, r.formulario, r.visita, r.precio, r.tipoprecio, r.cambio, 
                 r.precionormalizado, r.comentariosrelpre as comentarios, r.observaciones, r.periodo_1 as periodo, r.visita_1 as visita1,
                 r.precio_1 as precio1, r.tipoprecio_1 as tipoprecio1, r.cambio_1 as cambio1, r.precionormalizado_1 as precionormalizado1,
                 r.comentariosrelpre_1 as comentarios1, v.panel, v.tarea, v.encuestador, p.nombre||' '||p.apellido AS encuestadornombre
                 FROM relpre_1 r left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and 
                 r.visita = v.visita
                 left join personal p on v.encuestador = p.persona
                 where r.tipoprecio_1 in ('S','N'))`
        }
    });
}