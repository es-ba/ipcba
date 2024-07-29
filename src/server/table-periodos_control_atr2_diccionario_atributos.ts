"use strict";

import { TableDefinition } from "backend-plus";

export const periodos_control_atr2_diccionario_atributos = ():TableDefinition =>{
    return {
        name:'periodos_control_atr2_diccionario_atributos',
        tableName:'periodos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'relpre_control_atr2_diccionario_atributos' , fields:['periodo'], abr:'DA' , label: 'Control (atr2) diccionario de atributos'},
        ],
        sortColumns: [
            {
                column: 'periodo',
                order: -1
            }
        ],
        sql:{
            isTable: false,
        }
    };
}
