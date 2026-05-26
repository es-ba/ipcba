"use strict"

import { TableDefinition, Context } from "backend-plus";

export function calhogpargru(_context: Context): TableDefinition {
  return{
    editable: false,
    name: 'calhogpargru',
    fields: [
      { name: 'periodo', typeName: 'text', nullable: false },
      { name: 'calculo', typeName: 'integer', nullable: false },
      { name: 'hogar', typeName: 'text', nullable: false },
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'grupo', typeName: 'text', nullable: false },
      { name: 'grupopadre', typeName: 'text', inTable: false },
      { name: 'nombre_grupopadre', typeName: 'text', inTable: false, title: 'nombre grupo padre' },
      { name: 'cantidad', typeName: 'integer' },
      { name: 'coefhoggru', typeName: 'double' },
      { name: 'monto_may_18', typeName: 'double' },
      { name: 'valorhoggru', typeName: 'double' },
    ],
    primaryKey: ['periodo', 'calculo', 'hogar', 'agrupacion', 'grupo'],
    foreignKeys: [
      { references: 'calculos', fields: ['periodo', 'calculo'] },
      { references: 'grupos_ccc', fields: ['agrupacion', 'grupo'], displayFields: ['nombregrupo', 'nivel'], alias: 'gru' },
      //{ references: 'hogares_ccc', fields: ['hogar'], displayFields: ['nombrehogar','orden'], alias: 'hog' },
    ],
    sql: {
      from: `
        (select ch.periodo, ch.calculo, ch.hogar, coalesce(ny.nombrennya, h.nombrehogar) nombrehogar, coalesce(n.orden, h.orden) orden, 
        g.agrupacion, g.grupo, g.nombregrupo, g.nivel, g.grupopadre, gp.nombregrupo as nombre_grupopadre,
        ch.cantidad, ch.coefhoggru, ch.monto_may_18, ch.valorhoggru
        from ccc.calhogpargru ch
        inner join ccc.grupos_ccc g on g.agrupacion = ch.agrupacion and g.grupo = ch.grupo
        left join ccc.hogares_ccc h on h.hogar = ch.hogar
        left join (select nnya, min(orden) as orden from ccc.nnyaper group by nnya order by 2) n on ch.hogar = n.nnya
        left join nnyas ny on ch.hogar = ny.nnya
        left join ccc.grupos_ccc gp on gp.agrupacion = g.agrupacion and gp.grupo = g.grupopadre)
      `,
    }
  }
}