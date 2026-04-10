"use strict"

import { TableDefinition } from "backend-plus";

export function periodos_novservdom():TableDefinition{
    return {
        editable: false,
        name: 'periodos_novservdom',
        tableName: 'periodos',
        fields:[
            {name:'periodo', typeName:'text', nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'novservdom' , fields:['periodo'], abr:'nsd' , label: 'Novedades Servicio Domestico'},
        ],
        sortColumns:[{column:'periodo', order:-1}]
    }
}