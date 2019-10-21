"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'proddiv',
        //title:'proddiv',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'producto'                    , typeName:'text'    , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'division'                    , typeName:'text'    , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'ponderadordiv'               , typeName:'decimal' , allow:{update:puedeEditarMigracion}},
            {name:'incluye_supermercados'       , typeName:'boolean' , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'incluye_tradicionales'       , typeName:'boolean' , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'umbralpriimp'                , typeName:'integer' , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'umbraldescarte'              , typeName:'integer' , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'umbralbajaauto'              , typeName:'integer' , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'tipoinformante'              , typeName:'text'    , allow:{update:puedeEditarMigracion}},
            {name:'sindividir'                  , typeName:'boolean' , allow:{update:puedeEditarMigracion}},
        ],
        primaryKey:['producto','division'],
        foreignKeys:[
            {references:'productos' , fields:['producto']},
            {references:'divisiones', fields:['division']},
        ],
        constraints:[
            {constraintType:'unique', fields:['producto', 'sindividir']},
            {constraintType:'unique', fields:['producto','incluye_supermercados']},
            {constraintType:'unique', fields:['producto','incluye_tradicionales']}
        ]
    },context);
}