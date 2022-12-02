"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relinf_observaciones',
        tableName: 'relinf',
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
            {name:'visita'                 , typeName:'integer'                 , allow:{update:false}, inTable:false},
            {name:'direccion'              , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'formularios'            , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'contacto'               , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'maxperiodoinformado'    , typeName:'text'                    , allow:{update:false}, inTable:false},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'observaciones_campo'    , typeName:'text'                    , allow:{update:false}, inTable:true},
        ],
        primaryKey:['periodo','informante','visita'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            from:`(select r.periodo, max(CASE WHEN h.pos = 1 THEN h.panel END) AS panel , max(CASE WHEN h.pos = 1 THEN h.tarea END) AS tarea, 
                       r.informante, string_agg (h.razon,'/' order by panel, tarea) as razon, r.visita, h.direccion, 
                       CASE WHEN min(h.pos) <> max(h.pos) THEN 
                         string_agg ('Panel '||h.panel||' , '||'Tarea '||h.tarea||':'||chr(10)||h.formularioshdr,chr(10) ORDER BY panel,tarea) 
                       ELSE
                         string_agg (h.formularioshdr,chr(10) ORDER BY panel,tarea)
                       END as formularios, h.contacto, h.ordenhdr,
                       CASE WHEN min(h.pos) <> max(h.pos) THEN 
                         string_agg ('Panel '||h.panel||' , '||'Tarea '||h.tarea||':'||chr(10)||h.maxperiodoinformado,chr(10) ORDER BY panel,tarea) 
                       ELSE
                         string_agg (h.maxperiodoinformado,chr(10) ORDER BY panel,tarea)
                       END as maxperiodoinformado, r.observaciones, r.observaciones_campo
                   from relinf r 
                   left join (SELECT periodo, informante, visita, direccion, contacto, ordenhdr, panel, tarea, maxperiodoinformado, razon, formularioshdr, 
                                row_number() OVER (PARTITION BY periodo, informante, visita) as pos
                              from hdrexportarteorica 
                              group by periodo, informante, visita, direccion, contacto, ordenhdr, panel, tarea, maxperiodoinformado, razon, formularioshdr
                              order by periodo, informante, visita, direccion, contacto, ordenhdr, panel, tarea, maxperiodoinformado, razon, formularioshdr) h 
                              on r.periodo = h.periodo and r.informante = h.informante and r.visita = h.visita
                    group by r.periodo, r.informante, r.visita, h.direccion, h.contacto, h.ordenhdr
                )`,
            },
    },context);
}