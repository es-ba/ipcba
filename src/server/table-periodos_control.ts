"use strict";
import { TableDefinition } from "backend-plus";
export const periodos_control_diccionario_atributos_val = (param_name:string, param_table:string, param_label:string):TableDefinition =>{
    return {
        name:param_name,
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
            {table: param_table , fields:['periodo'], abr:'DA' , label: param_label},
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