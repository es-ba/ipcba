"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'canasta_producto',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              ,typeName:'text'   },
            {name:'calculo'              ,typeName:'integer'},
            {name:'agrupacion'           ,typeName:'text'   },
            {name:'producto'             ,typeName:'text'   },
            {name:'nombreproducto'       ,typeName:'text'   },
            {name:'valorprod'            ,typeName:'decimal' },
            {name:'grupopadre'           ,typeName:'text'   },
            {name:'grupoparametro'       ,typeName:'text'   },
            {name:'parametro'            ,typeName:'text'   },
            {name:'nombreparametro'      ,typeName:'text'   },
            {name:'hogar'                ,typeName:'text'   },
            {name:'coefhoggru'           ,typeName:'decimal' },
            {name:'valorhogprod'         ,typeName:'decimal' },
            {name:'divisioncanasta'      ,typeName:'text'   },
            {name:'agrupo1'              ,typeName:'text'   },
            {name:'agrupo2'              ,typeName:'text'   },
            {name:'agrupo3'              ,typeName:'text'   },
            {name:'agrupo4'              ,typeName:'text'   },
            {name:'bgrupo0'              ,typeName:'text'   },
            {name:'bgrupo1'              ,typeName:'text'   },
            {name:'bgrupo2'              ,typeName:'text'   },
            {name:'bgrupo3'              ,typeName:'text'   },
            {name:'bgrupo4'              ,typeName:'text'   },
        ],
        primaryKey:['periodo','calculo','agrupacion','producto','hogar','parametro'],
    });
}