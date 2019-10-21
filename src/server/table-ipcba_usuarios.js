"use strict";

module.exports = function(context){
    var admin=context.user.rol==='programador';
    return context.be.tableDefAdapt({
        name: "usuarios",
        title:'usuarios del sistema',
        editable:admin,
        fields:[
            {name:'usu_usu'         , typeName:'text'      },
            {name:'usu_rol'         , typeName:'text'      },
            {name:'usu_clave'       , typeName:'text'      },
            {name:'usu_activo'      , typeName:'boolean'   },
            {name:'usu_interno'     , typeName:'text'      },
            {name:'usu_mail'        , typeName:'text'      },
        ],
        primaryKey: ['usu_usu'],
    });
}
