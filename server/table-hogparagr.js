"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'hogparagr',
        editable:puedeEditar,
        fields:[
            {name:'parametro'                    , typeName:'text'    , nullable:false},
            {name:'hogar'                        , typeName:'text'    , nullable:false},
            {name:'coefhogpar'                   , typeName:'decimal' , nullable:false},
            {name:'agrupacion'                   , typeName:'text'    , nullable:false},
        ],
        primaryKey:['parametro','hogar','agrupacion'],
        foreignKeys:[
            {references:'hogares', fields:['hogar']},
            {references:'parhog', fields:['parametro']},
            {references:'agrupaciones', fields:['agrupacion']},
        ]
    },context);
}