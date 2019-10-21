"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_variaciones_maximas_vw',
        //title:'variaciones maximas vw',
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
            {table: 'variaciones_maximas_vw' , fields:['periodo'], abr:'VMax' , label: 'Variaciones máximas vw'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
