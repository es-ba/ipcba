'use strict'

import { TableDefinition } from 'backend-plus';

export const calprodperagr = (): TableDefinition => {
  return {
    editable: false,
    name: 'calprodperagr',
    schema: 'ccc',
    fields: [
      { name: 'periodo', typeName: 'text', nullable: false },
      { name: 'calculo', typeName: 'integer', nullable: false },
      { name: 'producto', typeName: 'text', nullable: false },
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'perfil', typeName: 'integer', nullable: false },
      { name: 'peso_neto', typeName: 'double' },
      { name: 'cantidad_ajuste', typeName: 'double' },
      { name: 'calorias', typeName: 'double', title: 'calorías diarias' },
      { name: 'cantidad_canasta', typeName: 'double', title: 'cantidad diaria canasta' },
      { name: 'peso_bruto', typeName: 'double' },
      { name: 'valorprod', typeName: 'double' }
    ],
    primaryKey: ['periodo', 'calculo', 'producto', 'agrupacion'],
    foreignKeys: [
      { references: 'agrupaciones_ccc', fields: ['agrupacion'] },
      { references: 'calculos_def', fields: ['calculo'] },
      { references: 'perfiles', fields: ['perfil'] },
      { references: 'periodos', fields: ['periodo'] },
      { references: 'calculos', fields: ['periodo', 'calculo'] },
      { references: 'productos_ccc', fields: ['producto'] },
    ],
  }
}