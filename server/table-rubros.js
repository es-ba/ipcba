"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'rubros',
        title:'Rubros',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'rubro'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'nombrerubro'            , typeName:'text'    , nullable:false, isName:true, allow:{update:puedeEditar}},
            {name:'tipoinformante'         , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'despacho'               , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'grupozonal'             , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'telefonico'             , typeName:'text'    , default:'N', defaultValue:'N', allow:{update:puedeEditar}},
        ],
        primaryKey:['rubro'],
        foreignKeys:[
            {references:'tipoinf', fields:[
                {source:'tipoinformante'  , target:'tipoinformante'     },
            ]},
        ]
    },context);
}