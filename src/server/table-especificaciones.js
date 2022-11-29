"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista'|| context.user.usu_rol ==='recepcionista'|| context.user.usu_rol ==='supervisor';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'especificaciones',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditar||puedeEditarMigracion,
            delete:puedeEditar||puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'producto'                  , typeName:'text'   , nullable:false            , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'especificacion'            , typeName:'integer', nullable:false            , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'nombreespecificacion'      , typeName:'text'   , isName:true               , allow:{update:puedeEditar||puedeEditarMigracion}, inTable:true},
            {name:'tamannonormal'             , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'ponderadoresp'             , typeName:'decimal', nullable:false, default:1, defaultValue:1, allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'envase'                    , typeName:'text'                               , allow:{update:puedeEditar||puedeEditarMigracion}, inTable:true},
            {name:'excluir'                   , typeName:'text'                               , allow:{update:puedeEditar||puedeEditarMigracion}, inTable:true},
            {name:'cantidad'                  , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'unidaddemedida'            , typeName:'text'                               , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'pesovolumenporunidad'      , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'destacada'                 , typeName:'boolean'                            , allow:{update:puedeEditar||puedeEditarMigracion}, inTable:true},
            {name:'mostrar_cant_um'           , typeName:'text'                               , allow:{update:puedeEditarMigracion}, inTable:true},
            {name:'especificacioncompleta'    , typeName:'text'                               , allow:{select:puedeEditarMigracion||puedeEditar}, inTable:false},
            {name:'observaciones'             , typeName:'text'                               , allow:{update:puedeEditarMigracion||puedeEditar}, inTable:true},
        ],
        primaryKey:['producto','especificacion'],
        foreignKeys:[
            {references:'productos', fields:['producto'], onUpdate:'cascade'},
            {references:'unidades', fields:[
                {source:'unidaddemedida'  , target:'unidad'     },
            ]},
        ],

        sql:{
            from:`(select e.*, ec.especificacioncompleta
                    from especificaciones e left join (select distinct producto,especificacioncompleta from paraimpresionformulariosenblanco) ec
                    on e.producto = ec.producto
                )`,
            isTable: true,
        }   
    },context);
}