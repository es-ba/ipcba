"use strict"

import { TableDefinition } from "backend-plus";

export function parametros_propiedades():TableDefinition{
    return {
        editable: false,
        name: 'parametros_propiedades',
        fields: [
            {name:'nombreparametro', typeName:'text', nullable: false, title: 'nombre parametro'},
            {name:'usa_perfil_edad', typeName:'boolean', nullable: false},
            {name:'usa_ambientes', typeName:'boolean', nullable: false},
            {name:'usa_miembros', typeName:'boolean', nullable: false},
            {name:'usa_es_jefe', typeName:'boolean', nullable: false},
            {name:'usa_monto_promedio_may_18', typeName:'boolean', nullable: false},
            {name:'usa_horas_diarias', typeName:'boolean', nullable: false},
            {name:'usa_es_promedio', typeName:'boolean', nullable: false},
        ],
        primaryKey: ['nombreparametro'],
    }
}