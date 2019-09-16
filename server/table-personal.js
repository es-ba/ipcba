"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'personal',
        //title:'Personal',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'persona'           , typeName:'text'    , nullable:false              , allow:{update:puedeEditar}},
            {name:'labor'             , typeName:'text'    , nullable:false              , allow:{update:puedeEditar}},
            {name:'nombre'            , typeName:'text'    , isName:true                 , allow:{update:puedeEditar}},
            {name:'apellido'          , typeName:'text'    , isName:true                 , allow:{update:puedeEditar}},
            {name:'username'          , typeName:'text'                                  , allow:{update:puedeEditar}},
            {name:'activo'            , typeName:'text'    , nullable:false, default:'S', defaultValue:'S', allow:{update:puedeEditar}},
            {name:'super_labor'       , typeName:'text'    , default:'N', defaultValue:'N'                , allow:{update:puedeEditar}},
            {name:'id_instalacion'    , typeName:'integer'                               , allow:{update:false      }},
            {name:'ipad'              , typeName:'text'    , editable:false              , allow:{update:puedeEditar}},
        ],
        primaryKey:['persona'],
        foreignKeys:[
            {references:'instalaciones', fields:['id_instalacion']},
        ],
        constraints:[
            {constraintType:'unique', fields:['username']},
        ]
    },context);
}