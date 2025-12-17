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
    sql: {
      from: `(select p.producto as producto, case when esproducto_ipc then cp.nombreproducto else p.nombreproducto end as nombreproducto,
              p.unidad_normal, p.cantidad, p.factor_correccion, p.unidad_de_medida, p.esproducto_ipc
              from ccc.productos_ccc p
              left join cvp.productos cp on p.producto = cp.producto)`,
    }
  }
}