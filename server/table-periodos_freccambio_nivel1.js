"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_freccambio_nivel1',
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
            {table: 'freccambio_nivel1' , fields:['periodo'], abr:'FCN1' , label: 'Frecuencia de cambio Nivel 1'},
        ],
    });
    defNewElement.sql={
                        isTable: false
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
