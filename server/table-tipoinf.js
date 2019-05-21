"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'tipoinf',
        title:'Tipoinf',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'tipoinformante'         , typeName:'text' , nullable:false, allow:{update:puedeEditar}},
            {name:'otrotipoinformante'     , typeName:'text' , nullable:false, allow:{update:puedeEditar}},
            {name:'nombretipoinformante'   , typeName:'text' , isName:true   , allow:{update:puedeEditar}},
        ],
        primaryKey:['tipoinformante']
    });
}