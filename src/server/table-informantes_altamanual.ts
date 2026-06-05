"use strict";

import { Context, TableDefinition } from "backend-plus";

export const informantes_altamanual = (context: Context): TableDefinition => {
  const puedeEditar = context.user.usu_rol === 'programador' || context.user.usu_rol === 'analista' || context.user.usu_rol === 'coordinador';
  const puedeEditarMigracion = context.user.usu_rol === 'programador' || context.user.usu_rol === 'migracion';
  return {
    name: 'informantes_altamanual',
    tableName: 'informantes',
    editable: puedeEditar,
    allow: {
      insert: puedeEditar,
      delete: false,
      update: puedeEditar,
    },
    fields: [
      { name: "generar", typeName: "bigint", editable: false, clientSide: 'altamanualgenerar' },
      { name: 'informante', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'nombreinformante', typeName: 'text', allow: { update: puedeEditar }, postInput: 'upperSpanish' },
      { name: 'periodo', typeName: 'text', title: 'UltimoPeriodo', editable: false },
      { name: 'ultimopanel', typeName: 'integer', title: 'UltimoPanel', editable: false },
      { name: 'ultimatarea', typeName: 'integer', title: 'UltimaTarea', editable: false },
      { name: 'altamanualperiodo', typeName: 'text', allow: { update: puedeEditar }, title: 'AltaEnPeriodo' },
      { name: 'altamanualpanel', typeName: 'integer', allow: { update: puedeEditar }, title: 'AltaEnPanel' },
      { name: 'altamanualtarea', typeName: 'integer', allow: { update: puedeEditar }, title: 'AltaEnTarea' },
      { name: 'masdeunpaneltarea', typeName: 'text', title: 'MasDeUnPanelTarea', editable: false },
      { name: 'estado', typeName: 'text', editable: false },
      { name: 'tipoinformante', typeName: 'text', allow: { update: puedeEditar }, title: 'TI', postInput: 'upperSpanish' },
      { name: 'rubro', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'provincia', typeName: 'text', allow: { update: puedeEditar || puedeEditarMigracion }, title: 'código provincia' },
      { name: 'direccion', typeName: 'text', editable: false },
      { name: 'calle', typeName: 'integer', allow: { update: puedeEditar }, postInput: 'upperSpanish' },
      { name: 'nombrecalle', typeName: 'text', allow: { update: puedeEditar || puedeEditarMigracion } },
      { name: 'altura', typeName: 'text', allow: { update: puedeEditar }, clientSide: 'control_altura', serverSide: true },
      { name: 'barrio', typeName: 'integer', allow: { update: puedeEditar || puedeEditarMigracion } },
      { name: 'circunselectoral', typeName: 'integer', allow: { update: puedeEditar || puedeEditarMigracion }, title: 'circunscripción electoral' },
      { name: 'comuna', typeName: 'integer', allow: { update: puedeEditar || puedeEditarMigracion } },
      { name: 'fraccion', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'radio', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'manzana', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'conjuntomuestral', typeName: 'integer', allow: { update: puedeEditar }, title: 'CM' },
      { name: 'contacto', typeName: 'text', allow: { update: puedeEditar } },
      { name: 'telcontacto', typeName: 'text', allow: { update: puedeEditar } },
      { name: 'web', typeName: 'text', allow: { update: puedeEditar } },
      { name: 'email', typeName: 'text', allow: { update: puedeEditar } },
      { name: 'cluster', typeName: 'integer', allow: { update: puedeEditar } },
      { name: 'altamanualconfirmar', typeName: 'timestamp', allow: { update: puedeEditar } },
      { name: 'cadena', typeName: 'text', allow: { update: puedeEditar } },
    ],
    primaryKey: ['informante'],
    hiddenColumns: ['altamanualconfirmar', 'calles__alturadesde', 'calles__alturahasta', 'distrito', 'fraccion', 'radio', 'manzana', 'cluster', 'conjuntomuestral'],
    detailTables: [
      { table: 'forinf', abr: 'FOR', label: 'formularios', fields: ['informante'] },
      { table: 'relvis', abr: 'VIS', label: 'visitas', fields: ['periodo', 'informante'] },
    ],
    foreignKeys: [
      { references: 'rubros', fields: ['rubro'] },
      { references: 'tipoinf', fields: ['tipoinformante'] },
      { references: 'calles', fields: ['calle'], displayFields: ['nombrecalle', 'alturadesde', 'alturahasta'] },
      { references: 'provincias', fields: ['provincia'], displayFields: ['nombreprovincia'] },
      { references: 'barrios', fields: ['barrio'], displayFields: ['nombrebarrio'] },
    ],
    sql: {
      from: `(select i.informante, nombreinformante, ei.estado, tipoinformante, calle, comuna, provincia, direccion, rubro, altamanualperiodo,
                altamanualpanel, case when cantpantar = 1 then r.panelselec else null end::integer as ultimopanel,
                altamanualtarea, case when cantpantar = 1 then r.tareaselec else null end::integer as ultimatarea,
                case when cantpantar > 1 then varias else null end as masdeunpaneltarea, nombrecalle, altura, distrito, fraccion, radio, manzana, contacto,
                telcontacto, web, email,  altamanualconfirmar, r.periodo, i.cadena, i.barrio, i.circunselectoral, cluster, conjuntomuestral
                from informantes i
                left join informantes_estado ei on i.informante = ei.informante
                left join (
                  select distinct on (informante)
                         periodo, informante, cantpantar, panelselec, tareaselec, varias
                  from (
                    select periodo, informante, count(distinct panel::text||tarea::text) cantpantar, max(panel) panelselec, max(tarea) tareaselec,
                      string_agg (distinct 'Panel: '||panel::text||' Tarea:'||tarea::text,chr(10) order by 'Panel: '||panel::text||' Tarea:'||tarea::text) varias
                    from relvis
                    group by periodo, informante
                  ) q
                  order by informante, periodo desc
                ) r on i.informante = r.informante)`
    }

  };
}