"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-relpan.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'paneles_relpre_control_rangos_analisis',
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
            {table: 'relpre_control_rangos_analisis' , fields:['periodo','panel'], abr:'CRA' , label: 'Control rangos comentarios'},
        ],
    });
    defNewElement.sql={
                        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
