"use strict"

import { TableDefinition } from "backend-plus";

export function empalme_ccc_b1112():TableDefinition{
    return {
        editable: false,
        name: 'empalme_ccc_b1112',
        fields: [
            {name:'agrupacion_b1112', typeName:'text', nullable: false},
            {name:'grupo_b1112', typeName:'text', nullable: false},
            {name:'agrupacion_b21', typeName:'text', nullable: false},
            {name:'grupo_b21', typeName:'text', nullable: false},
            {name:'agrupamiento', typeName:'integer'},
        ],
        primaryKey: ['agrupacion_b1112','grupo_b1112','agrupacion_b21','grupo_b21'],
        foreignKeys: [
          { references: 'grupos_b1112', fields: [{source:'agrupacion_b1112', target:'agrupacion'}, {source:'grupo_b1112', target:'grupo'}] },
          { references: 'grupos', fields: [{source:'agrupacion_b21', target:'agrupacion'}, {source:'grupo_b21', target:'grupo'}] },
        ],
    }
}