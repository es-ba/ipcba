"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'relinf_observaciones',
        tableName: 'relpantarinf',
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
            {name:'visita'                 , typeName:'integer'                 , allow:{update:false}, inTable:true},
            {name:'direccion'              , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'formularios'            , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'contacto'               , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'telcontacto'            , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'web'                    , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'email'                  , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'maxperiodoinformado'    , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'modalidad'              , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'codobservaciones'       , typeName:'text'                    , allow:{update:puedeEditar}, title:'cod', postInput:'upperSpanish', inTable:true},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'observaciones_campo'    , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'recuperos'              , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
        ],
        primaryKey:['periodo','informante','visita','panel','tarea'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        hiddenColumns:['cluster'],
        sql:{
            from:`(select r.periodo, r.panel , r.tarea, r.informante, h.razon, r.visita, h.direccion, h.formularioshdr formularios, h.contacto, 
                        h.telcontacto, h.web, h.email, h.ordenhdr, h.maxperiodoinformado, h.modalidad, r.observaciones, r.observaciones_campo, r.codobservaciones, r.recuperos
                   from relpantarinf r 
                       left join hdrexportarteorica h 
                       on r.periodo = h.periodo and r.informante = h.informante and r.visita = h.visita and r.panel = h.panel and r.tarea = h.tarea
                )`,
            },
    },context);
}