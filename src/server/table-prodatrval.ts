"use strict";

import { TableDefinition } from "backend-plus";

export const prodatrval = ():TableDefinition => {
    return {
        name:'prodatrval',
        editable:false,
        //dbOrigin:'view',
        fields:[
            {name:'producto'                  , typeName:'text'     },
            {name:'atributo'                  , typeName:'integer'  },
            {name:'valor'                     , typeName:'text'     , postInput:'upperSpanish'},
            {name:'orden'                     , typeName:'integer'  },
            {name:'atributo_2'                , typeName:'integer'  },
            {name:'valor_2'                   , typeName:'text'     , postInput:'upperSpanish'},
            {name:'usuario'                   , typeName:'text'     , allow:{update:false}    },
            {name:'fecha'                     , typeName:'date'     , allow:{update:false}    },
        ],
        primaryKey:['producto','atributo','valor'],
        sql:{
            isTable: false,
            from:`(SELECT producto, atributo, valor, orden, atributo_2, valor_2, activo, modi_usu usuario, modi_fec::date fecha
                    FROM prodatrval_edit where activo)`,
        },
    };
}