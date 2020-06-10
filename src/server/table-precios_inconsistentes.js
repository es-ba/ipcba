"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'precios_inconsistentes',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'informante'           ,typeName:'integer'},
            {name:'formulario'           ,typeName:'integer'},
            {name:'producto'             ,typeName:'text'   }, 
            {name:'visita'               ,typeName:'integer'},
            {name:'observacion'          ,typeName:'integer'},
            {name:'tipoprecio'           ,typeName:'text'   },
        ],
        primaryKey:['periodo', 'producto', 'observacion', 'informante', 'visita'],
        foreignKeys:[
            {references:'formularios', fields:['formulario'] },
            {references:'productos'  , fields:['producto']   },
        ],
        sql:{from:`(select v.periodo, v.informante, v.formulario, r.producto, v.visita, r.observacion, r.tipoprecio
            from relvis v
            left join razones z on v.razon = z.razon
            left join relpre r on v.periodo = r.periodo and v.informante = r.informante and v.visita = r.visita and v.formulario= r.formulario
            left join tipopre t on r.tipoprecio = t.tipoprecio
            where coalesce(z.espositivoformulario, 'N') = 'S' and coalesce(t.inconsistente, true))`
            },
    },context);
}