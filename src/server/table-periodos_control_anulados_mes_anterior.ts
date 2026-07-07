"use strict";

import { TableDefinition } from "backend-plus";

export function periodos_control_anulados_mes_anterior(): TableDefinition {
    return {
        editable: false,
        name: 'periodos_control_anulados_mes_anterior',
        tableName: 'periodos',
        allow: {
            insert: false,
            delete: false,
            update: false,
        },
        fields: [
            {name: 'periodo', typeName: 'text', nullable: false},
        ],
        primaryKey: ['periodo'],
        detailTables: [
            {table: 'control_anulados_mes_anterior', fields: ['periodo'], abr: 'CA', label: 'Control anulados mes anterior'},
        ],
        sortColumns: [{column: 'periodo', order: -1}],
        sql: {
            isTable: false,
        }
    };
}
