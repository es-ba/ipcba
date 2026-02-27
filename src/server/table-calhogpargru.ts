"use strict"

import { TableDefinition } from "backend-plus";

export function calhogpargru():TableDefinition{
    return {
        editable: false,
        name: 'calhogpargru',
        fields: [
            {name:'periodo', typeName:'text', nullable: false},
            {name:'calculo', typeName:'integer', nullable: false},
            {name:'hogar', typeName:'text', nullable: false},
            {name:'agrupacion', typeName:'text', nullable: false},
            {name:'grupo', typeName:'text', nullable: false},
            {name:'cantidad', typeName:'integer'},
            {name:'coefhoggru', typeName:'double'},
            {name:'monto_may_18', typeName:'double'},
            {name:'valorhoggru', typeName:'double'}
        ],
        primaryKey: ['periodo','calculo','hogar','agrupacion','grupo'],
        foreignKeys: [
          { references: 'calculos', fields: ['periodo','calculo'] },
          { references: 'grupos_ccc', fields: ['agrupacion','grupo'] },
          { references: 'hogares_ccc', fields: ['hogar'] },
        ],
    }
}