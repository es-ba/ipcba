"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'variaciones_minimas_vw',
        title:'variaciones minimas vw',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              ,typeName:'text'  },
            {name:'producto'             ,typeName:'text'  },
            {name:'nombreproducto'       ,typeName:'text'  },
            {name:'variacion1'           ,typeName:'decimal'},
            {name:'variacion2'           ,typeName:'decimal'},
            {name:'variacion3'           ,typeName:'decimal'},
            {name:'variacion4'           ,typeName:'decimal'},
            {name:'variacion5'           ,typeName:'decimal'},
            {name:'variacion6'           ,typeName:'decimal'},
            {name:'variacion7'           ,typeName:'decimal'},
            {name:'variacion8'           ,typeName:'decimal'},
            {name:'variacion9'           ,typeName:'decimal'},
            {name:'variacion10'          ,typeName:'decimal'},
            {name:'informantes1'         ,typeName:'text'  },
            {name:'informantes2'         ,typeName:'text'  },
            {name:'informantes3'         ,typeName:'text'  },
            {name:'informantes4'         ,typeName:'text'  },
            {name:'informantes5'         ,typeName:'text'  },
            {name:'informantes6'         ,typeName:'text'  },
            {name:'informantes7'         ,typeName:'text'  },
            {name:'informantes8'         ,typeName:'text'  },
            {name:'informantes9'         ,typeName:'text'  },
            {name:'informantes10'        ,typeName:'text'  },
        ],
        primaryKey:['periodo','producto'],
    });
}

