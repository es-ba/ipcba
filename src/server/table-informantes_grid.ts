"use strict";

import { Context, TableDefinition } from "backend-plus";
import { informantes } from "./table-informantes";

export const informantes_grid = (context:Context):TableDefinition => {
    let def = informantes(context);
    def.name = 'informantes_grid';
    def.tableName = 'informantes';
    const insertIndex = def.fields.findIndex(f => f.name === 'nombreinformante') + 1;
    def.fields.splice(insertIndex, 0, {name:'estado', typeName:'text', allow:{import:false, update:false}, inTable: false} as any);
    def.sql = {
        from: `(select i.*, ie.estado
                   from informantes i left join informantes_estado ie on i.informante = ie.informante
                )`,
        isTable: true
    };
    return def;
}
