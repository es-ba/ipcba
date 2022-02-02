"use strict";

var changing = require('best-globals').changing;
var definnerCalgruVw = require('../server/table-caldiv_vw.js');

module.exports = function(context){
    var defNewElement = definnerCalgruVw(context);
    defNewElement=changing(defNewElement,{
        name:'caldiv_base',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
    });
    defNewElement.sql={
        from:`(select * from cvp.caldiv_vw where calculo in (20,-20))`
    };
    defNewElement.filterColumns=[];
    return context.be.tableDefAdapt(defNewElement, context);
}
