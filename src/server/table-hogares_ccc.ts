"use strict"

import { TableDefinition } from "backend-plus";

export function hogares_ccc():TableDefinition{
    return {
        editable: false,
        name: 'hogares_ccc',
        fields: [
            {name:'hogar', typeName:'text', nullable: false},
            {name:'nombrehogar', typeName:'text', isName: true, title: 'nombre hogar'},
        ],
        primaryKey: ['hogar'],
        constraints: [
           { constraintType: 'check', consName: 'texto invalido en nombrehogar de tabla hogares_ccc', expr: `comun.cadena_valida(nombrehogar, 'castellano'::text)` }
        ],
    }
}