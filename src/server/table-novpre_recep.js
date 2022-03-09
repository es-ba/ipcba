"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador'|| context.user.usu_rol ==='recepcionista';
    return context.be.tableDefAdapt({
        name:'novpre_recep',
        //title:'Anulación de precios',
        tableName:'novpre',
        editable:puedeEditar,
        allow: {
            insert: false,
            delete: false,
            update: puedeEditar,
            import: false,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'informante'                       , typeName:'integer' , nullable:false , allow:{update:false}},
            {name:'observacion'                      , typeName:'integer' , nullable:false , allow:{update:false}},
            {name:'visita'                           , typeName:'integer' , nullable:false , allow:{update:false}},
            {name:'usuario'                          , typeName:'text'                     , allow:{update:false}},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}},
            {name:'formulario'                       , typeName:'integer'                  , allow:{update:false}},
            {name:'comentarios'                      , typeName:'text'                     , allow:{update:false}},
            {name:'comentarios_recep', title:'Recepcion', typeName:'text'                  , allow:{update:puedeEditar}},
        ],
        /*
        filterColumns:[
            {column:'periodo', operator:'=', value: context.be.internalData.filterUltimoPeriodo}
        ],
        */
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'relpre', fields:['periodo', 'producto', 'observacion', 'informante', 'visita']},            
            {references:'productos', fields:['producto']},            
            {references:'informantes', fields:['informante']},
            {references:'formularios', fields:['formulario']},            
            {references:'personal', fields:[
                {source:'recepcionista'  , target:'persona' },
            ], alias: 'rec'},        
            {references:'personal', fields:[
                {source:'encuestador'    , target:'persona' },
            ], alias: 'enc'},        
        ],
        sql:{
            from: `(select n.periodo, 
                           n.producto, 
                           n.informante, 
                           n.observacion, 
                           n.visita,
                           v.panel, 
                           v.tarea,
                           CASE WHEN n.modi_usu = 'cvpowner' or n.modi_usu = 'postgres' THEN n.usuario ELSE n.modi_usu END as usuario,
                           v.encuestador,
                           v.recepcionista,
                           v.formulario,
                           n.comentarios, 
                           n.comentarios_recep
                    from novpre n 
                         left join relpre r on r.periodo = n.periodo and r.informante = n.informante and r.observacion = n.observacion and r.producto = n.producto and r.visita = n.visita
                         left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita
                    where n.revisar_recep
            )`
        }  
    },context);
}