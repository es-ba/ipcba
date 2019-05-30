"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'unidades',
        title:'Unidades',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'unidad'                 , typeName:'text' , nullable:false, allow:{update:puedeEditar}},
            {name:'magnitud'               , typeName:'text' , nullable:false, allow:{update:puedeEditar}},
            {name:'factor'                 , typeName:'decimal'              , allow:{update:puedeEditar}},
            {name:'morfologia'             , typeName:'text'                 , allow:{update:puedeEditar}},
            {name:'abreviaturaestandar'    , typeName:'text'                 , allow:{update:puedeEditar}},
        ],
        primaryKey:['unidad'],
        foreignKeys:[
            {references:'magnitudes', fields:[
                {source:'magnitud'  , target:'magnitud'     },
            ]},
        ]
    },context);
}