"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'numeros',
        //title:'Numeros',
        editable:puedeEditar,
        fields:[
            {name:'numero'     , typeName:'integer' , nullable:false},
        ],
        primaryKey:['numero'],
    });
}