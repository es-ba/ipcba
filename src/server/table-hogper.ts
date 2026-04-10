"use strict"

import { TableDefinition } from "backend-plus";

export function hogper():TableDefinition{
    return {
        editable: true,
        name: 'hogper',
        fields: [
            {name:'hogar', typeName:'text', nullable: false},
            {name:'perfil', typeName:'integer', nullable: false},
            {name:'perfil_equivalente', typeName:'integer'},
            {name:'cantidad', typeName:'integer'},
        ],
        primaryKey: ['hogar', 'perfil'],
        foreignKeys: [
            {references: 'hogares_ccc', fields: ['hogar']},
            {references: 'perfiles', fields: ['perfil']},
            {references: 'perfiles', fields: [{source: 'perfil_equivalente', target: 'perfil'}], alias: 'hpe'},
        ],
    }
}