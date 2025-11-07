"use strict"

import { TableDefinition } from "backend-plus";

export const prodperagr = (): TableDefinition => {
  return {
    editable: false,
    name: 'prodperagr',
    schema: 'ccc',
    fields: [
      { name: 'producto', typeName: 'text', nullable: false },
      { name: 'perfil', typeName: 'integer', nullable: false },
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'peso_neto', typeName: 'double' },
      { name: 'cantidad_ajuste', typeName: 'double' },
      { name: 'calorias', typeName: 'double' }
    ],
    primaryKey: ['producto', 'perfil', 'agrupacion'],
    foreignKeys: [
      { references: 'productos_ccc', fields: ['producto'] },
      { references: 'perfiles', fields: ['perfil'] },
      { references: 'agrupaciones_ccc', fields: ['agrupacion'] }
    ],
  }
}