import { Context, TableDefinition } from "backend-plus";
import { personal } from './table-personal.js';

export const personal_supervisores = (context: Context): TableDefinition => {
  let def = personal(context);
  def.name = 'personal_supervisores';
  def.sql = def.sql || {};
  def.sql.where = (def.sql.where ? def.sql.where + " and " : "") + "labor = 'S' and activo = 'S'";
  return def;
};
