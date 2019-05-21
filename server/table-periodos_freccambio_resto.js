"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_freccambio_resto',
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
            {table: 'freccambio_resto' , fields:['periodo'], abr:'FCRG' , label: 'Frecuencia de cambio Resto General'},
        ],
    });
    defNewElement.sql={
                        isTable: false
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
