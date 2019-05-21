"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_freccambio_restorest',
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
            {table: 'freccambio_restorest' , fields:['periodo'], abr:'FCRR' , label: 'Frecuencia de cambio Resto Restricto'},
        ],
    });
    defNewElement.sql={
                        isTable: false
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
