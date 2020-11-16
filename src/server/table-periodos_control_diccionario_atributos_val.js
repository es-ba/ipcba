"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_control_diccionario_atributos_val',
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
            {table: 'control_diccionario_atributos' , fields:['periodo'], abr:'DA' , label: 'Control diccionario de atributos valor'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
