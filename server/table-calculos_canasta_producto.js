"use strict";

var changing = require('best-globals').changing;
var definnerCalculo = require('../server/table-calculos.js');

module.exports = function(context){
    var defNewElement = definnerCalculo(context);
    defNewElement=changing(defNewElement,{
        name:'calculos_canasta_producto',
        title:'canasta_producto',
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
            {table: 'canasta_producto' , fields:['periodo', 'calculo'], abr:'CP' , label: 'Canasta productos'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
