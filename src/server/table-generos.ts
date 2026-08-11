"use strict"

import { TableDefinition } from "backend-plus";

export function generos():TableDefinition{
    return {
        editable: false,
        name: 'generos',
        fields: [
            {name:'genero', typeName:'text',},
        ],
        primaryKey: ['genero'],
        sql: {
          isTable: false,
          from: `(select distinct p.genero
                from ccc.perfiles p
                join ccc.nnyaper n on p.perfil = n.perfil)
                `,
        },
    }
}