"use strict"

import { TableDefinition } from "backend-plus";

export const calgruper = (): TableDefinition => {
  return {
    editable: true,
    name: 'calgruper',
    schema: 'ccc',
    fields: [
      { name: 'periodo', typeName: 'text', nullable: false },
      { name: 'calculo', typeName: 'integer', nullable: false },
      { name: 'grupo', typeName: 'text', nullable: false },
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'perfil', typeName: 'integer', nullable: false },
      { name: 'variacion', typeName: 'double' },
      { name: 'valorgru', typeName: 'double' },
      { name: 'ponderador', typeName: 'double' },
      { name: 'grupopadre', typeName: 'text' },
      { name: 'nivel', typeName: 'integer' },
      { name: 'esproducto', typeName: 'text', defaultValue: 'N' }
    ],
    primaryKey: ['periodo', 'calculo', 'grupo', 'agrupacion', 'perfil'],
    foreignKeys: [
      { references: 'periodos', fields: ['periodo'] },
      { references: 'calculos', fields: ['periodo', 'calculo'] },
      { references: 'grupos_ccc', fields: ['agrupacion', 'grupo'] },
      { references: 'agrupaciones_ccc', fields: ['agrupacion'] },
      { references: 'perfiles', fields: ['perfil'] },
      { references: 'calculos_def', fields: ['calculo'] }
    ],
  }
}