"use strict"

import { TableDefinition } from "backend-plus";

export function gruemp():TableDefinition{
    return {
        editable: false,
        name: 'gruemp',
        fields: [
            {name:'agrupacion_b1112', typeName:'text'},
            {name:'grupo_b1112', typeName:'text'},
            {name:'agrupacion_b21', typeName:'text'},
            {name:'grupo_b21', typeName:'text'},
            {name:'agrupacion', typeName:'text'},
            {name:'grupo', typeName:'text'},
        ],
        primaryKey: ['agrupacion_b1112','grupo_b1112','agrupacion_b21','grupo_b21','agrupacion','grupo'],
        foreignKeys: [
          { references: 'empalme_ccc_b1112', fields: ['agrupacion_b1112','grupo_b1112','agrupacion_b21','grupo_b21'] },
          { references: 'grupos_ccc', fields: ['agrupacion','grupo'] },
        ],
    }
}