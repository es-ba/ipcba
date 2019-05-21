"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'especificaciones',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'producto'                  , typeName:'text'   , nullable:false            , allow:{update:puedeEditar}},
            {name:'especificacion'            , typeName:'integer', nullable:false            , allow:{update:puedeEditar}},
            {name:'nombreespecificacion'      , typeName:'text'   , isName:true               , allow:{update:puedeEditar}},
            {name:'tamannonormal'             , typeName:'decimal'                            , allow:{update:puedeEditar}},
            {name:'ponderadoresp'             , typeName:'decimal', nullable:false , default:1, allow:{update:puedeEditar}},
            {name:'envase'                    , typeName:'text'                               , allow:{update:puedeEditar}},
            {name:'excluir'                   , typeName:'text'                               , allow:{update:puedeEditar}},
            {name:'cantidad'                  , typeName:'decimal'                            , allow:{update:puedeEditar}},
            {name:'unidaddemedida'            , typeName:'text'                               , allow:{update:puedeEditar}},
            {name:'pesovolumenporunidad'      , typeName:'decimal'                            , allow:{update:puedeEditar}},
            {name:'destacada'                 , typeName:'boolean'                            , allow:{update:puedeEditar}},
            {name:'mostrar_cant_um'           , typeName:'text'                               , allow:{update:puedeEditar}},
        ],
        primaryKey:['producto','especificacion'],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'unidades', fields:[
                {source:'unidaddemedida'  , target:'unidad'     },
            ]},
        ],
        
    },context);
}