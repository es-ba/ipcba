"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'hogares',
        editable:puedeEditar,
        fields:[
            {name:'hogar'                   , typeName:'text'    , nullable:false},
            {name:'nombrehogar'             , typeName:'text'    , nullable:false, isName:true   },
        ],
        primaryKey:['hogar']
    },context);
}