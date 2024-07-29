"use strict";

import { TableDefinition } from "backend-plus";

export const periodos_control_diccionario_atributos_val = ():TableDefinition =>{
    return {
        name:'periodos_control_diccionario_atributos_val',
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
            {table: 'control_diccionario_atributos' , fields:['periodo'], abr:'DA' , label: 'Control diccionario de atributos valor'},
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
