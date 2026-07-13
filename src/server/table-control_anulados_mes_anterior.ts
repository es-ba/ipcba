"use strict";

import { Context, TableDefinition } from "backend-plus";

export function control_anulados_mes_anterior(context: Context): TableDefinition {
    const puedeEditar = context.user.usu_rol === 'programador' || context.user.usu_rol === 'analista' || context.user.usu_rol === 'coordinador' || context.user.usu_rol === 'recepcionista';
    const serverConfig = context.be.config?.server as any;
    const baseLink: string = serverConfig?.['base-link'] ?? '';
    const baseUrl: string = serverConfig?.['base-url'] ?? '';
    return {
        name: 'control_anulados_mes_anterior',
        tableName: 'relpre',
        allow: {
            insert: false,
            delete: false,
            update: puedeEditar,
        },
        fields: [
            {name: 'periodo'                      , typeName: 'text'    , allow: {update: false}},
            {name: 'producto'                     , typeName: 'text'    , allow: {update: false}},
            {name: 'informante'                   , typeName: 'integer' , allow: {update: false}},
            {name: 'formulario'                   , typeName: 'integer' , allow: {update: false}},
            {name: 'visita'                       , typeName: 'integer' , allow: {update: false}},
            {name: 'observacion'                  , typeName: 'integer' , allow: {update: false}},
            {name: 'precio'                       , typeName: 'decimal' , allow: {update: false}},
            {name: 'tipoprecio'                   , typeName: 'text'    , allow: {update: false}},
            {name: 'cambio'                       , typeName: 'text'    , allow: {update: false}},
            {name: 'excluido'                     , typeName: 'text'    , allow: {update: false}, inTable: false},
            {name: 'cantidadperiodossinprecio'    , typeName: 'integer' , allow: {update: false}, title: 'cantidad periodo sin precio', inTable: false},
            {name: 'precioanterior'               , typeName: 'decimal' , allow: {update: false}, title: 'precio anterior'},
            {name: 'tipoprecioanterior'           , typeName: 'text'    , allow: {update: false}, title: 'tipo precio anterior'},
            {name: 'masdatos'                     , typeName: 'text'    , allow: {update: false}, title: 'mas datos'},
            {name: 'comentariosrelpre'            , typeName: 'text'    , allow: {update: false}, title: 'comentarios relpre'},
            {name: 'esvisiblecomentarioendm'      , typeName: 'boolean' , allow: {update: false}, title: 'es visible comentario en dm', inTable: true},
            {name: 'comentariosanterior'          , typeName: 'text'    , allow: {update: false}, title: 'comentarios anterior'},
            {name: 'precionormalizado'            , typeName: 'decimal' , allow: {update: false}, title: 'precio normalizado'},
            {name: 'agregarvisita'                , typeName: 'boolean' , allow: {update: false}, serverSide:true, inTable:false, clientSide: 'agregar_visita', title: 'agregar Visita'},
            {name: 'panel_ant'                    , typeName: 'integer' , allow: {update: false}, title: 'Panel (mes ant)'},
            {name: 'tarea_ant'                    , typeName: 'integer' , allow: {update: false}, title: 'Tarea (mes ant)'},
            {name: 'responsable'                  , typeName: 'text'    , allow: {update: false}, title: 'Responsable (mes ant)'},
            {name: 'relpre'                       , typeName: 'text'    , allow: {update: false}, title: 'link a relpre'},
            {name: 'panel'                        , typeName: 'integer' , allow: {update: false}},
            {name: 'tarea'                        , typeName: 'integer' , allow: {update: false}},
            {name: 'recepcionista'                , typeName: 'text'    , allow: {update: false}},
            {name: 'revisados'                    , typeName: 'text' , allow: {update: puedeEditar}},
        ],
        primaryKey: ['periodo', 'producto', 'informante', 'observacion', 'visita'],
        foreignKeys: [
            {references: 'informantes', fields: ['informante']},
            {references: 'productos'  , fields: ['producto'], displayFields: ['nombreproducto']},
            {references: 'relvis'     , fields: ['periodo', 'informante', 'visita', 'formulario']},
        ],
        detailTables: [
            {table: 'relpre', fields: ['periodo', 'producto', 'observacion', 'informante', 'visita'], abr: 'R', label: 'relpre'},
        ],
        sql: {
            from: `(
                SELECT
                p_act.periodo, r_ant.producto, r_ant.informante, r_ant.observacion, r_ant.visita, r_ant.formulario,
                r_ant.precio, r_ant.tipoprecio, r_ant.cambio,
                r_ant.precio_1 as precioanterior, r_ant.tipoprecio_1 as tipoprecioanterior,
                r_ant.comentariosrelpre, r_ant.comentariosrelpre_1 as comentariosanterior,
                r_ant.precionormalizado, r_ant.esvisiblecomentarioendm,
                CASE WHEN r_ant.precio_1 > 0 and r_ant.precio_1 <> r_ant.precio THEN round((r_ant.precio/r_ant.precio_1*100-100)::decimal,1)::TEXT||'%'
                    ELSE NULL
                END AS masdatos,
                CASE WHEN c.antiguedadexcluido>0 and r_ant.precio>0 THEN 'x' ELSE null END as excluido,
                v_ant.panel as panel_ant, v_ant.tarea as tarea_ant,
                COALESCE(g.responsable, gp.responsable) as responsable,
                v_act.panel as panel,
                v_act.tarea as tarea,
                per.username as recepcionista,
                '${baseLink}${baseUrl}/menu#w=table&table=relpre&ff={%22periodo%22:%22' || p_act.periodo || '%22,%22informante%22:' || r_ant.informante || ',%22producto%22:%22' || r_ant.producto || '%22,%22observacion%22:' || r_ant.observacion || '}' as relpre,
                r_act.revisados,
                CASE WHEN distanciaperiodos(r_ant.periodo,re.ultimoperiodoconprecio)-1>0 THEN distanciaperiodos(r_ant.periodo,re.ultimoperiodoconprecio)-1
                ELSE NULL
                END cantidadperiodossinprecio,
                case when r_act.ultima_visita is true then null else true end as agregarvisita
                FROM relpre_1 r_ant
                INNER JOIN periodos p_act ON r_ant.periodo = p_act.periodoanterior
                INNER JOIN relvis v_ant ON r_ant.periodo = v_ant.periodo AND r_ant.informante = v_ant.informante AND r_ant.visita = v_ant.visita AND r_ant.formulario = v_ant.formulario
                LEFT JOIN relpre r_act ON r_act.periodo = p_act.periodo
                    AND r_ant.producto = r_act.producto
                    AND r_ant.informante = r_act.informante
                    AND r_ant.observacion = r_act.observacion
                    AND r_ant.visita = r_act.visita
                LEFT JOIN relvis v_act ON r_act.periodo = v_act.periodo AND r_act.informante = v_act.informante AND r_act.visita = v_act.visita AND r_act.formulario = v_act.formulario
                LEFT JOIN personal per ON v_act.recepcionista = per.persona
                LEFT JOIN grupos g ON g.agrupacion = 'F' AND g.grupo = r_ant.producto
                LEFT JOIN grupos gp ON g.agrupacion = gp.agrupacion AND g.grupopadre = gp.grupo
                left join (select cobs.* from calobs cobs join calculos_def cdef on cobs.calculo = cdef.calculo where cdef.principal) c on r_ant.periodo = c.periodo and r_ant.producto = c.producto and r_ant.informante = c.informante and r_ant.observacion = c.observacion
                left join control_sinprecio s on r_ant.periodo =s.periodo and r_ant.informante = s.informante and r_ant.visita = s.visita and r_ant.observacion = s.observacion and r_ant.producto = s.producto,
                lateral (select max(periodo) ultimoperiodoconprecio
                            from relpre
                            where precio is not null and r_ant.informante = informante and r_ant.producto = producto and r_ant.observacion = observacion and r_ant.visita = visita
                            and periodo < p_act.periodo
                        ) re
                WHERE r_ant.tipoprecio IN ('A', 'M')
            )`
        },
        sortColumns: [{column: 'panel'}, {column: 'tarea'}]
    };
}
