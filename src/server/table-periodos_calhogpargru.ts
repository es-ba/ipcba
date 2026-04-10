"use strict"

import { TableDefinition } from "backend-plus";

export function periodos_calhogpargru():TableDefinition{
    return {
        editable: false,
        name: 'periodos_calhogpargru',
        tableName: 'periodos',
        fields:[
            {name:'periodo', typeName:'text', nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'calhogpargru' , fields:['periodo'], abr:'chpg' , label: 'Calculo Hogar Agrupacion Grupo'},
        ],
        sortColumns:[{column:'periodo', order:-1}]
    }
}