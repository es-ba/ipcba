"use strict"

import { TableDefinition } from "backend-plus";

export function grupos_b1112():TableDefinition{
    return {
        editable: false,
        name: 'grupos_b1112',
        fields: [
            {name:'agrupacion', typeName:'text', nullable: false},
            {name:'grupo', typeName:'text', nullable: false},
            {name:'nombregrupo', typeName:'text'},
            {name:'grupopadre', typeName:'text'},
            {name:'ponderador', typeName:'double'},
            {name:'nivel', typeName:'integer'},
            {name:'esproducto', typeName:'text'},
            {name:'modi_usu', typeName:'text'},
            {name:'modi_fec', typeName:'timestamp'},
            {name:'modi_ope', typeName:'text'},
            {name:'nombrecanasta', typeName:'text'},
            {name:'agrupacionorigen', typeName:'text'},
            {name:'detallarcanasta', typeName:'text'},
            {name:'explicaciongrupo', typeName:'text'},
            {name:'responsable', typeName:'text'},
            {name:'cluster', typeName:'integer'},
        ],
        primaryKey: ['agrupacion','grupo'],
    }
}
