"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_vista_control_diccionario',
        //title:'vista control diccionario',
        tableName:'periodos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false                      },
        ],
        detailTables:[
            {table: 'vista_control_diccionario' , fields:['periodo'], abr:'VCD' , label: 'Vista control diccionario'},
        ],
    });
    defNewElement.sql={
                        isTable: false
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
