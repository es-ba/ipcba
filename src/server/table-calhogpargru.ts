"use strict"

import { TableDefinition } from "backend-plus";

export function calhogpargru(): TableDefinition {
  return {
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
      { references: 'hogares_ccc', fields: ['hogar'], displayFields: ['nombrehogar','orden'], alias: 'hog' },
    ],
    sql: {
      from: `
        (select ch.periodo, ch.calculo, ch.hogar, g.agrupacion, g.grupo, g.grupopadre, gp.nombregrupo as nombre_grupopadre,
        ch.cantidad, ch.coefhoggru, ch.monto_may_18, ch.valorhoggru
        from calhogpargru ch
        inner join grupos_ccc g on g.agrupacion = ch.agrupacion and g.grupo = ch.grupo
        left join grupos_ccc gp on gp.agrupacion = g.agrupacion and gp.grupo = g.grupopadre)
      `,
    }
  }
}