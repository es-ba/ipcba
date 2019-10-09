"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relinf',
        title: 'hoja de ruta',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false, allow:{update:false}, inTable:true},
            {name:'panel'                  , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'tarea'                  , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'informante'             , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'razon'                  , typeName:'text'                    , allow:{update:false}, inTable:false},
            //{name:'nombreinformante'       , typeName:'text'                  , allow:{update:false}},
            {name:'visita'                 , typeName:'integer'                 , allow:{update:false}, inTable:false},
            {name:'direccion'              , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'formularios'            , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'contacto'               , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'maxperiodoinformado'    , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
        ],
        primaryKey:['periodo','informante','panel','tarea'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            from:`(select r.periodo, r.panel, r.tarea, r.informante, h.razon, h.visita, h.direccion,
                  h.formularioshdr as formularios, h.contacto, h.ordenhdr, h.maxperiodoinformado, r.observaciones
                from relinf r 
                left join hdrexportarteorica h on r.periodo = h.periodo and r.informante = h.informante and r.visita = h.visita
				and r.panel = h.panel and r.tarea = h.tarea)
                `,
            isTable: true,
            },
    },context);
}