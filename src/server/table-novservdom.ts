"use strict"

import {Context, TableDefinition } from "backend-plus";

export const novservdom = (context:Context):TableDefinition => {
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador'|| context.user.usu_rol ==='ccc_analista';
    return {
        editable:puedeEditar,
        allow: {
            insert: puedeEditar,
            delete: false,
            update: puedeEditar,
            import: puedeEditar,
        },
        name: 'novservdom',
        fields: [
            {name:'periodo', typeName:'text', nullable: false},
            {name:'producto', typeName:'text', nullable: false},
            {name:'horas_convenio', typeName:'integer', nullable: false},
            {name:'monto_hora_general', typeName:'double'},
            {name:'monto_hora_cuidado', typeName:'double'},
            {name:'monto_mes_cuidado', typeName:'double'},
            {name:'monto_mes_cuidado_valor_hora', typeName:'double', generatedAs: `
                CASE WHEN monto_mes_cuidado IS NULL THEN 0::double precision
                ELSE monto_mes_cuidado / horas_convenio::double precision END`
            },
            {name:'monto_hora_promedio', typeName:'double', generatedAs: `
                CASE WHEN ((monto_hora_general IS NULL) OR (monto_hora_cuidado IS NULL)) THEN (0)::double precision
                ELSE ((monto_hora_general + monto_hora_cuidado) / (2.0)::double precision) END`
            },
        ],
        primaryKey: ['periodo','producto'],
        foreignKeys: [
          { references: 'periodos', fields: ['periodo'] },
          { references: 'productos_ccc', fields: ['producto'] },
        ],
    }
}