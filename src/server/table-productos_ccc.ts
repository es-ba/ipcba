'use strict'

import { TableDefinition } from 'backend-plus';

export const productos_ccc = (): TableDefinition => {
  return {
    editable: false,
    name: 'productos_ccc',
    schema: 'ccc',
    fields: [
      { name: 'producto', typeName: 'text', nullable: false },
      { name: 'unidad_normal', typeName: 'text', nullable: false },
      { name: 'cantidad', typeName: 'double' },
      { name: 'factor_correccion', typeName: 'double' },
      { name: 'unidad_de_medida', typeName: 'text' },
    ],
    primaryKey: ['producto'],
    foreignKeys: [
      { references: 'productos', fields: ['producto'] },
      { references: 'unidades', fields: [{ source: 'unidad_de_medida', target: 'unidad' }] },
    ],
  }
}