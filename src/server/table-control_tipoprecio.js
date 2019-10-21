"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_tipoprecio',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   },
            {name:'producto'                     ,typeName:'text'   },
            {name:'nombreproducto'               ,typeName:'text'   },
            {name:'tipoinformante'               ,typeName:'text'   },
            {name:'rubro'                        ,typeName:'integer'},
            {name:'nombrerubro'                  ,typeName:'text'   },
            {name:'tipoprecio'                   ,typeName:'text'   },
            {name:'nombretipoprecio'             ,typeName:'text'   },
            {name:'cantidad'                     ,typeName:'integer'},
        ],
        primaryKey:['periodo','producto','tipoinformante','rubro','tipoprecio'],
        /*
        sql:{
            where:"periodo = 'a2017m02'" 
            //+context.be.db.quoteText(context.user.usuario)
        } 
        */        
    });
}

 