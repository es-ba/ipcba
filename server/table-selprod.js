"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'selprod',
        title:'selprod',
        editable:puedeEditar,
        fields:[
            {name:'producto'                    , typeName:'text'   , nullable:false},
            {name:'sel_nro'                     , typeName:'integer', nullable:false},
            {name:'descripcion'                 , typeName:'text'      },
            {name:'rubro'                       , typeName:'text'      },
            {name:'proveedor'                   , typeName:'text'      },
            {name:'cantidad'                    , typeName:'text'      },
            {name:'observaciones'               , typeName:'text'      },
            {name:'especificacion'              , typeName:'text'      },
            {name:'valordesde'                  , typeName:'decimal'    },
            {name:'valorhasta'                  , typeName:'decimal'    },
            {name:'excluir'                     , typeName:'text'      },
        ],
        primaryKey:['producto','sel_nro'],
        foreignKeys:[
            {references:'productos', fields:[
                {source:'producto'      , target:'producto'   },
            ]},
        ]
    });
}