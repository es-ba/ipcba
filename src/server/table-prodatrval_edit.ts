"use strict";

import { Context, TableDefinition } from "backend-plus";

export const prodatrval_edit = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista' /*|| context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion'*/;
    return {
        name:'prodatrval',
        tableName:'prodatrval_edit',
        policy:'web',
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'producto'                  , typeName:'text'     },
            {name:'atributo'                  , typeName:'integer'  },
            {name:'valor'                     , typeName:'text'     , postInput:'upperSpanish'},
            {name:'orden'                     , typeName:'integer'  },
            {name:'atributo_2'                , typeName:'integer'  },
            {name:'valor_2'                   , typeName:'text'     , postInput:'upperSpanish'},
            {name:'modi_usu'                  , typeName:'text'     , title:'usuario'    , allow:{update:false}    },
            {name:'modi_fec'                  , typeName:'timestamp', title:'fecha'     , allow:{update:false}    },
            {name:'activo'                    , typeName:'boolean'  },
        ],
        primaryKey:['producto','atributo','valor'],
        filterColumns:[
            {column:'activo', operator:'=', value:true}
        ],
        foreignKeys:[
            {references:'prodatr', fields:['producto','atributo']},
            {references:'prodatr', fields:[
                                           {source:'producto'     , target:'producto'},
                                           {source:'atributo_2'   , target:'atributo'}
                                          ], alias: 'pat'}
        ],
        softForeignKeys:[
            {references:'atributos', fields:['atributo']},
            {references:'atributos', fields:[{source:'atributo_2', target:'atributo'}], alias: 'at'},
            {references:'productos', fields:['producto']},
        ]
    };
}