"use strict"

import { Context, TableDefinition } from "backend-plus";

export const provincias = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return {
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        name: 'provincias',
        fields: [
            {name:'provincia'      , typeName:'text'   , nullable:false, allow:{update:puedeEditar}},
            {name:'nombreprovincia', typeName:'text'   , nullable:false, allow:{update:puedeEditar} , isName:true},
        ],
        primaryKey: ['provincia'],
        constraints:[
            {constraintType:'check', consName:"texto invalido en provincia de tabla provincias", expr:"comun.cadena_valida(provincia, 'codigo')"},
            {constraintType:'check', consName:"texto invalido en nombreprovincia de tabla provincias", expr:"comun.cadena_valida(nombreprovincia, 'castellano')"}
        ]
    }
}