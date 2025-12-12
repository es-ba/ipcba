'use strict'

import { TableDefinition } from 'backend-plus';

export const productos_ccc = (): TableDefinition => {
  return {
    editable: false,
    name: 'productos_ccc',
    schema: 'ccc',
    fields: [
      { name: 'producto', typeName: 'text', nullable: false },
      { name: 'nombreproducto', typeName: 'text', isName: true },
      { name: 'unidad_normal', typeName: 'text' },
      { name: 'cantidad', typeName: 'double' },
      { name: 'factor_correccion', typeName: 'double' },
      { name: 'unidad_de_medida', typeName: 'text' },
      { name: 'esproducto_ipc', typeName: 'boolean', defaultValue: 'true' },
    ],
    primaryKey: ['producto'],
    foreignKeys: [
      { references: 'unidades', fields: [{ source: 'unidad_de_medida', target: 'unidad' }] },
    ],
  }
}