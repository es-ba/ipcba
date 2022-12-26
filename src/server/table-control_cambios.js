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
            {name:'informante'           ,typeName:'integer'},
            {name:'producto'             ,typeName:'text'   }, 
            {name:'observacion'          ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'formulario'           ,typeName:'integer'},
            {name:'precio'               ,typeName:'decimal'},
            {name:'tipoprecio'           ,typeName:'text'   },
            {name:'cambio'               ,typeName:'text'   },            
            {name:'precionormalizado'    ,typeName:'decimal'},
            {name:'precio_1'             ,typeName:'decimal'},
            {name:'tipoprecio_1'         ,typeName:'text'   },
            {name:'atributo'             ,typeName:'integer'},
            {name:'valor'                ,typeName:'text'   },
            {name:'valor_1'              ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','producto','observacion','visita','atributo'],
        foreignKeys:[
            {references:'informantes', fields:['informante'] },
            {references:'formularios', fields:['formulario'] },
            {references:'productos'  , fields:['producto']   },
            {references:'atributos'  , fields:['atributo']   },
        ],
        sql:{from:`(select r.periodo, r.informante, r.producto, r.observacion, r.visita, r.formulario, r.precio, r.tipoprecio, 
                      r.cambio,r.precionormalizado, r.precio_1, r.tipoprecio_1, a.atributo, a.valor, a.valor_1
                      from relpre_1 r
                      join relatr_1 a using(periodo, informante, producto, visita, observacion)
                      join atributos t using (atributo)
                      where t.es_vigencia is null and r.cambio = 'C' and a.valor is distinct from a.valor_1)`
            },
    },context);
}