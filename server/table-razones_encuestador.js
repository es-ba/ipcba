"use strict";

var changing = require('best-globals').changing;
var definnerPeriodo = require('../server/table-razones.js');

module.exports = function(context){
    var defNewElement = definnerPeriodo(context);
    defNewElement=changing(defNewElement,{
        name:'razones_encuestador',
        policy:'web',
        dbOrigin:'view',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
    });
    defNewElement.sql={
        where: `visibleparaencuestador='S'`
    };
    return context.be.tableDefAdapt(defNewElement, context);
}