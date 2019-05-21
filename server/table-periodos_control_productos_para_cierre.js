"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-periodos.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'periodos_control_productos_para_cierre',
        //title:'control productos para cierre',
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
            {table: 'control_productos_para_cierre' , fields:['periodo'], abr:'CP' , label: 'Control productos p/cierre'},
        ],
    });
    defNewElement.sql={
                        isTable: false
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
