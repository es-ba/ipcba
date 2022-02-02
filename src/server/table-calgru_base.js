"use strict";

var changing = require('best-globals').changing;
var definnerCalgruVw = require('../server/table-calgru_vw.js');

module.exports = function(context){
    var defNewElement = definnerCalgruVw(context);
    defNewElement=changing(defNewElement,{
        name:'calgru_base',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
    });
    defNewElement.sql={
        from:`(select * from cvp.calgru_vw where calculo in (20,-20))`
    };
    defNewElement.filterColumns=[
        {column:'agrupacion', operator:'=' , value:context.be.internalData.filterAgrupacion},
    ];
    return context.be.tableDefAdapt(defNewElement, context);
}
