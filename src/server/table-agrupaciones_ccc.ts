'use strict'

import { TableDefinition, TableContext } from "backend-plus";

export const agrupaciones_ccc = (context: TableContext): TableDefinition => {
  let puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='admin';
  return {
    editable: puedeEditar,
    name: 'agrupaciones_ccc',
    schema: 'ccc',
    fields: [
      { name: 'agrupacion', typeName: 'text', nullable: false },
      { name: 'nombreagrupacion', typeName: 'text', nullable: false, isName: true, title: 'nombre agrupacion' },
      { name: 'paravarioshogares', typeName: 'boolean', defaultDbValue: 'false', title: 'para varios hogares' },
      { name: 'calcular_junto_grupo', typeName: 'text', nullable: false },
      { name: 'valoriza', typeName: 'boolean', defaultDbValue: 'false' },
      { name: 'tipo_agrupacion', typeName: 'text', nullable: true },
    ],
    constraints: [
      { constraintType: 'check', consName: 'texto invalido en nombreagrupacion de tabla agrupaciones', expr: `comun.cadena_valida(nombreagrupacion, 'castellano'::text)` }
    ],
    primaryKey: ['agrupacion'],
  }
}