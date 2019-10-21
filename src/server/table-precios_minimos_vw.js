"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'precios_minimos_vw',
        //title:'precios minimos vw',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              ,typeName:'text'},
            {name:'producto'             ,typeName:'text'},
            {name:'nombreproducto'       ,typeName:'text'},
            {name:'precio1'              ,typeName:'text'},
            {name:'precio2'              ,typeName:'text'},
            {name:'precio3'              ,typeName:'text'},
            {name:'precio4'              ,typeName:'text'},
            {name:'precio5'              ,typeName:'text'},
            {name:'precio6'              ,typeName:'text'},
            {name:'precio7'              ,typeName:'text'},
            {name:'precio8'              ,typeName:'text'},
            {name:'precio9'              ,typeName:'text'},
            {name:'precio10'             ,typeName:'text'},
            {name:'informantes1'         ,typeName:'text'},
            {name:'informantes2'         ,typeName:'text'},
            {name:'informantes3'         ,typeName:'text'},
            {name:'informantes4'         ,typeName:'text'},
            {name:'informantes5'         ,typeName:'text'},
            {name:'informantes6'         ,typeName:'text'},
            {name:'informantes7'         ,typeName:'text'},
            {name:'informantes8'         ,typeName:'text'},
            {name:'informantes9'         ,typeName:'text'},
            {name:'informantes10'        ,typeName:'text'},
        ],
        primaryKey:['periodo','producto'],
    });
}

