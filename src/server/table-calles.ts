"use strict"

import { Context, TableDefinition } from "backend-plus";

export const calles = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return {
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        name: 'calles',
        fields: [
            {name:'calle'      , typeName:'integer', nullable:false, allow:{update:puedeEditar}},
            {name:'nombrecalle', typeName:'text'   , nullable:false, allow:{update:puedeEditar} , isName:true},
        ],
        primaryKey: ['calle'],
        constraints:[
            {constraintType:'check', consName:"texto invalido en nombrecalle de tabla calles", expr:"comun.cadena_valida(nombrecalle, 'castellano')"}
        ]
    }
}
