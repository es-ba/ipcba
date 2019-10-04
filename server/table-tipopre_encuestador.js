"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-tipopre.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'tipopre_encuestador',
        policy:'web',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
    });
    defNewElement.sql={
        isTable: false,
        where: `visibleparaencuestador='S'`,    
        orderBy:['orden']
    };
    defNewElement.sortColumns=[
        {column:'orden'}
    ];
    return context.be.tableDefAdapt(defNewElement, context);
}