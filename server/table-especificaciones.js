"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista'|| context.user.usu_rol ==='recepcionista';
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
            {name:'producto'                  , typeName:'text'   , nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'especificacion'            , typeName:'integer', nullable:false            , allow:{update:puedeEditarMigracion}},
            {name:'nombreespecificacion'      , typeName:'text'   , isName:true               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'tamannonormal'             , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}},
            {name:'ponderadoresp'             , typeName:'decimal', nullable:false, default:1, defaultValue:1, allow:{update:puedeEditarMigracion}},
            {name:'envase'                    , typeName:'text'                               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'excluir'                   , typeName:'text'                               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'cantidad'                  , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}},
            {name:'unidaddemedida'            , typeName:'text'                               , allow:{update:puedeEditarMigracion}},
            {name:'pesovolumenporunidad'      , typeName:'decimal'                            , allow:{update:puedeEditarMigracion}},
            {name:'destacada'                 , typeName:'boolean'                            , allow:{update:puedeEditarMigracion}},
            {name:'mostrar_cant_um'           , typeName:'text'                               , allow:{update:puedeEditarMigracion}},
            {name:'observaciones'             , typeName:'text'                               , allow:{update:puedeEditarMigracion||puedeEditar}},
            {name:'especificacioncompleta'    , typeName:'text'                               , allow:{select:puedeEditarMigracion||puedeEditar}},
        ],
        primaryKey:['producto','especificacion'],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'unidades', fields:[
                {source:'unidaddemedida'  , target:'unidad'     },
            ]},
        ],

        sql:{
            from:`(select e.*, ec.especificacioncompleta
                    from especificaciones e left join (select distinct producto,especificacioncompleta from paraimpresionformulariosenblanco) ec
                    on e.producto = ec.producto
                )`
        }   
    },context);
}