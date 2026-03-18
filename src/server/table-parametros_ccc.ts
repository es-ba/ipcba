"use strict"

import { TableDefinition } from "backend-plus";

export function parametros_ccc():TableDefinition{
    return {
        editable: false,
        name: 'parametros_ccc',
        fields: [
            {name:'parametro', typeName:'integer', generatedAs: 'INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1'},
            {name:'nombreparametro', typeName:'text', title: 'nombre parametro'},
            {name:'perfil_edad', typeName:'integer'},
            {name:'ambientes', typeName:'integer'},
            {name:'miembros', typeName:'integer'},
            {name:'es_jefe', typeName:'boolean'},
            {name:'monto_promedio_may_18', typeName:'double'},
            {name:'horas_diarias', typeName:'integer'},
            {name:'es_promedio', typeName:'boolean'},
            {name:'coeficiente', typeName:'double', nullable: false},
        ],
        primaryKey: ['parametro'],
        foreignKeys: [
            { references: 'parametros_propiedades', fields: ['nombreparametro'] },
            { references: 'perfiles_edad', fields: ['perfil_edad'] },
        ],
    }
}
