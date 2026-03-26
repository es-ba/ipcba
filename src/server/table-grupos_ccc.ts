'use strict';

import { TableDefinition, Context } from 'backend-plus';
import { productos_ccc } from "./table-productos_ccc";

export const grupos_ccc = (_context:Context): TableDefinition => {
  const productosTableDef = productos_ccc();
  const sqlProductos = productosTableDef.sql!.from;
  return {
    editable: false,
    name: 'grupos_ccc',
    schema: 'ccc',
    fields: [
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'grupo', typeName: 'text', nullable: false },
      { name: 'nombregrupo', typeName: 'text', isName: true, title: 'nombre grupo' },
      { name: 'grupopadre', typeName: 'text', title: 'grupo padre'},
      { name: 'ponderador', typeName: 'double' },
      { name: 'nivel', typeName: 'integer' },
      { name: 'esproducto', typeName: 'text', defaultValue: 'N', title: 'es producto' },
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
    sql: {
      from: `(select g.agrupacion, g.grupo, case when g.esproducto = 'S'::text then p.nombreproducto else g.nombregrupo end as nombregrupo, g.grupopadre, g.ponderador, g.nivel, g.esproducto
              from ccc.grupos_ccc g
              inner join ccc.agrupaciones_ccc a on a.agrupacion = g.agrupacion
              left join (${sqlProductos}) p on g.grupo = p.producto and g.esproducto = 'S'::text)
        `,
    }
  };
}
