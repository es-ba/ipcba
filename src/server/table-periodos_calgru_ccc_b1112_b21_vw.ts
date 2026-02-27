"use strict"

import { TableDefinition } from "backend-plus";

export function periodos_calgru_ccc_b1112_b21_vw():TableDefinition{
    return {
        editable: false,
        name: 'periodos_calgru_ccc_b1112_b21_vw',
        tableName: 'periodos',
        fields:[
            {name:'periodo', typeName:'text', nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'calgru_ccc_b1112_b21_vw' , fields:['periodo'], abr:'emp' , label: 'empalme'},
        ],
        sortColumns:[{column:'periodo', order:-1}]
    }
}