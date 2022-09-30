"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-relpan.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'paneles_unificacion_valores_atributos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
        fields:[
            {name:'periodo'                 , typeName:'text'   , nullable:false},
            {name:'panel'                   , typeName:'integer', nullable:false},
            {name:'fechasalida'             , typeName:'date'},
            {name:'fechageneracionpanel'    , typeName:'timestamp'},
        ],
        detailTables:[
            {table: 'unificacion_valores_atributos' , fields:['periodo','panel'], abr:'UVA' , label: 'Unificación valores atributos'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
