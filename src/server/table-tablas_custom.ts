"use strict"

import { Context, TableDefinition } from "backend-plus";

export const tablas_custom = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='programador';
    return {
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        name: 'tablas_custom',
        fields: [
            {name:'tabla'        , typeName:'text'      , defaultDbValue: 'false', nullable:false, allow:{update:puedeEditar}},
            {name:'exportable'   , typeName:'boolean'   , defaultDbValue: 'false', allow:{update:puedeEditar}},
            {name:'grilla_pesada', typeName:'boolean'   , defaultDbValue: 'false', allow:{update:puedeEditar}},
        ],
        primaryKey: ['tabla'],
    }
}