"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='migracion' || context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'divisiones',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'division'                    , typeName:'text'      , nullable:false, allow:{update:puedeEditar}},
            {name:'nombre_division'             , typeName:'text'      , isName:true   , allow:{update:puedeEditar}},
            {name:'incluye_supermercados'       , typeName:'boolean'                   , allow:{update:puedeEditar}},
            {name:'incluye_tradicionales'       , typeName:'boolean'                   , allow:{update:puedeEditar}},
            {name:'tipoinformante'              , typeName:'text'                      , allow:{update:puedeEditar}},
            {name:'sindividir'                  , typeName:'boolean'                   , allow:{update:puedeEditar}},
            {name:'otradivision'                , typeName:'text'                      , allow:{update:puedeEditar}},
        ],
        primaryKey:['division'],
        constraints:[
            {constraintType:'unique', fields:['sindividir']},
            {constraintType:'unique', fields:['incluye_supermercados','incluye_tradicionales']},
            {constraintType:'unique', fields:['division','incluye_supermercados','incluye_tradicionales']}
        ]
    },context);
}