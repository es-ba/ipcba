"use strict"

import { TableDefinition } from "backend-plus";

export function novservdom():TableDefinition{
    return {
        editable: false,
        name: 'novservdom',
        fields: [
            {name:'periodo', typeName:'text', nullable: false},
            {name:'monto_hora_general', typeName:'double'},
            {name:'monto_hora_cuidado', typeName:'double'},
            {name:'monto_mes_cuidado', typeName:'double'},
            {name:'monto_hora_promedio', typeName:'double', generatedAs: `
                CASE WHEN ((monto_hora_general IS NULL) OR (monto_hora_cuidado IS NULL)) THEN (0)::double precision
                ELSE ((monto_hora_general + monto_hora_cuidado) / (2.0)::double precision) END`
            },
        ],
        primaryKey: ['periodo'],
        foreignKeys: [
          { references: 'periodos', fields: ['periodo'] },
        ],
    }
}