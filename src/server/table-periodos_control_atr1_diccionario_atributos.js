"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_control_atr1_diccionario_atributos',
        tableName:'periodos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
        ],
        detailTables:[
            {table: 'relpre_control_atr1_diccionario_atributos' , fields:['periodo'], abr:'DA' , label: 'Control (atr1) diccionario de atributos'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
