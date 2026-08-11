"use strict"

import { TableDefinition } from "backend-plus";

export function indicadores():TableDefinition{
    return {
        editable: false,
        name: 'indicadores',
        fields: [
            {name:'indicador', typeName:'text'},
            {name:'descripcion', typeName:'text'},
            {name:'abreviatura', typeName:'text'},
        ],
        primaryKey: ['indicador'],
    }
}