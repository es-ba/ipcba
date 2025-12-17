"use strict"

import { TableDefinition } from "backend-plus";

export function periodos_calprodperagr():TableDefinition{
    return {
        editable: false,
        name: 'periodos_calprodperagr',
        tableName: 'periodos',
        fields:[
            {name:'periodo', typeName:'text', nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table: 'calprodperagr' , fields:['periodo'], abr:'CPPA' , label: 'Calculo Producto Perfil Agrupacion'},
        ],
        sortColumns:[{column:'periodo', order:-1}],
    }
}