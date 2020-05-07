"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'precios_porcentaje_positivos_y_anulados',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'informante'           ,typeName:'integer'},
            {name:'rubro'                ,typeName:'text'   },
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'encuestador'          ,typeName:'text'   },
            {name:'encuestadornombre'    ,typeName:'text'   },
            {name:'operativo'            ,typeName:'text'   },
            {name:'formulario'           ,typeName:'text'   },
            {name:'preciospotenciales'   ,typeName:'integer'},
            {name:'positivos'            ,typeName:'integer'},
            {name:'anulados'             ,typeName:'integer'},
            {name:'porcentaje'           ,typeName:'text'   },            
            {name:'atributospotenciales' ,typeName:'integer'},
            {name:'atributospositivos'   ,typeName:'integer'},
            {name:'porcatributos'        ,typeName:'text'   },            
        ],
        primaryKey:['periodo','informante'],
    });
}