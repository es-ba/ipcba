"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'muestras',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'muestra'                      , typeName:'integer'    , nullable:false, allow:{update:puedeEditar}},
            {name:'descripcion'                  , typeName:'text'                       , allow:{update:puedeEditar}},
            {name:'alta_inmediata_hasta_periodo' , typeName:'text'                       , allow:{update:puedeEditar}},
        ],
        primaryKey:['muestra'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'alta_inmediata_hasta_periodo'  , target:'periodo'     },
            ]},
        ]

    },context);
}