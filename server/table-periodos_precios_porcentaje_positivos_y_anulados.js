"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_precios_porcentaje_positivos_y_anulados',
        //title:'periodos_precios_porcentaje_positivos_y_anulados',
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
            {table: 'precios_porcentaje_positivos_y_anulados' , fields:['periodo'], abr:'P' , label: 'porcentajes de positivos y anulados por formulario'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
