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
            {name:'nombreinformante'     ,typeName:'text'   }, 
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'formulario'           ,typeName:'integer'},
            {name:'producto'             ,typeName:'text'   }, 
            {name:'visita'               ,typeName:'integer'},
            {name:'observacion'          ,typeName:'integer'},
            {name:'tipoprecio'           ,typeName:'text'   },
        ],
        primaryKey:['periodo', 'producto', 'observacion', 'informante', 'visita'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'},{column:'formulario'},{column:'producto'},{column:'observacion'}],
        foreignKeys:[
            {references:'formularios', fields:['formulario'] },
            {references:'productos'  , fields:['producto']   },
        ],
        sql:{from:`(select v.periodo, v.informante, i.nombreinformante, v.panel, v.tarea, v.formulario, r.producto, v.visita, r.observacion, r.tipoprecio
            from relvis v
            left join informantes i on v.informante = i.informante
            left join relinf ri on v.periodo = ri.periodo and v.informante = ri.informante and v.visita = ri.visita
            left join reltar rt on v.periodo = rt.periodo and v.panel = rt.panel and v.panel = rt.tarea
            left join relpan rp on v.periodo = rp.periodo and v.panel = rp.panel
            left join razones z on v.razon = z.razon
            left join relpre r on v.periodo = r.periodo and v.informante = r.informante and v.visita = r.visita and v.formulario= r.formulario
            left join tipopre t on r.tipoprecio = t.tipoprecio
            where coalesce(z.espositivoformulario, 'N') = 'S' and coalesce(t.inconsistente, true) and
            not (current_timestamp between COALESCE(ri.fechasalidadesde, rt.fechasalidadesde, rp.fechasalidadesde, rp.fechasalida)+interval '9 hours'  
            and COALESCE(ri.fechasalidahasta, rt.fechasalidahasta, rp.fechasalidahasta, rp.fechasalida) +interval '24 hours'))`
            },
    },context);
}