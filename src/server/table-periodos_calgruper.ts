"use strict"

import { TableDefinition } from "backend-plus";

export function periodos_calgruper():TableDefinition{
    return {
        editable: false,
        name: 'periodos_calgruper',
        tableName: 'periodos',
        fields:[
            {name:'periodo', typeName:'text', nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'calgruper' , fields:['periodo'], abr:'CGP' , label: 'Calculo Grupo Perfil'},
        ],
        sortColumns:[{column:'periodo', order:-1}]
    }
}