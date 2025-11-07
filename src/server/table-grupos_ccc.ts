'use strict';

import { TableDefinition } from 'backend-plus';

export const grupos_ccc = (): TableDefinition => {
  return {
    editable: false,
    name: 'grupos_ccc',
    schema: 'ccc',
    fields: [
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'grupo', typeName: 'text', nullable: false },
      { name: 'nombregrupo', typeName: 'text' },
      { name: 'grupopadre', typeName: 'text' },
      { name: 'ponderador', typeName: 'double' },
      { name: 'nivel', typeName: 'integer' },
      { name: 'esproducto', typeName: 'text', defaultValue: 'N' },
    ],
    primaryKey: ['agrupacion', 'grupo'],
    foreignKeys: [
      { references: 'agrupaciones_ccc', fields: ['agrupacion'] },
      { references: 'grupos_ccc', fields: ['agrupacion', { source: 'grupopadre', target: 'grupo' }], alias: 'agp' },
    ],
    constraints: [
      { constraintType: 'check', consName: 'texto invalido en nombreagrupacion de tabla grupos', expr: `comun.cadena_valida(nombregrupo, 'castellano'::text)` },
      { constraintType: 'check', consName: 'Si esproducto=S => nombregrupo nulo', expr: `NOT esproducto = 'S'::text OR nombregrupo IS NULL` }
    ],
  };
}
