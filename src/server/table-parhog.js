"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'parhog',
        //title:'Parhog',
        editable:puedeEditar,
        fields:[
            {name:'parametro'           , typeName:'text' , nullable:false},
            {name:'nombreparametro'     , typeName:'text' , nullable:false, isName:true},
        ],
        primaryKey:['parametro'],
    });
}