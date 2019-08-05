"use strict";

var changing = require('best-globals').changing;
var definnerCalculo = require('../server/table-calculos.js');

module.exports = function(context){
    var defNewElement = definnerCalculo(context);
    defNewElement=changing(defNewElement,{
        name:'calculos_novobs_recep',
        //title:'novobs_recep',
        tableName:'calculos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'calculo'                      , typeName:'integer' , nullable:false},
        ],
        detailTables:[
            {table: 'novobs_recep' , fields:['periodo', 'calculo'], abr:'NO' , label: 'Novobs_recep'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
