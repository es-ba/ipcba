"use strict";

import { Context, TableDefinition } from "backend-plus";

export const control_verificar_precio = (context:Context):TableDefinition =>{
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista';
    return {
        name:'control_verificar_precio',
        tableName: 'relpre',
        editable: puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      ,typeName:'text'   , allow:{update:false}},
            {name:'informante'                   ,typeName:'integer', allow:{update:false}},
            {name:'panel'                        ,typeName:'integer', allow:{update:false}},
            {name:'tarea'                        ,typeName:'integer', allow:{update:false}},
            {name:'formulario'                   ,typeName:'integer', allow:{update:false}},
            {name:'producto'                     ,typeName:'text'   , allow:{update:false}},
            {name:'nombreproducto'               ,typeName:'text'   , allow:{update:false}},
            {name:'visita'                       ,typeName:'integer', allow:{update:false}},
            {name:'observacion'                  ,typeName:'integer', allow:{update:false}},
            {name:'precionormalizado'            ,typeName:'decimal', allow:{update:false}},
            {name:'tipoprecio'                   ,typeName:'text'   , allow:{update:false}},
            {name:'precionormalizadoant'         ,typeName:'decimal', allow:{update:false}},
            {name:'variacion'                    ,typeName:'decimal', allow:{update:false}},
            {name:'comentariosrelpre'            ,typeName:'text'   , allow:{update:puedeEditar}},
            {name:'esvisiblecomentarioendm'      ,typeName:'boolean', allow:{update:false}},
            {name:'tipoprecioant'                ,typeName:'text'   , allow:{update:false}},
            {name:'comentariosrelpreant'         ,typeName:'text'   , allow:{update:false}},
            {name:'periodoant'                   ,typeName:'text'   , allow:{update:false}},
            {name:'cantperiodosconigualprecioant',typeName:'integer', allow:{update:false}},

        ],
        refrescable:true,
        primaryKey:['periodo','informante','producto','visita','observacion'],
        sql:{
          from:`(SELECT rv.panel, rv.tarea, cv.periodo as periodoant, cv.producto, cv.nombreproducto, cv.informante, rp.formulario, cv.visita, cv.observacion, cv.precionormalizado as precionormalizadoant,
                  cv.tipoprecio as tipoprecioant, cv.comentariosrelpre as comentariosrelpreant, rp.periodo, rp.precionormalizado, rp.tipoprecio,
                  case when cv.precionormalizado is not null and rp.precionormalizado is not null and cv.precionormalizado is distinct from rp.precionormalizado then
                  round((rp.precionormalizado/cv.precionormalizado*100-100)::decimal,2) else null end variacion, rp.comentariosrelpre, cv.cantprecios as cantperiodosconigualprecioant, rp.esvisiblecomentarioendm
                  FROM relpre rp
                  INNER JOIN relvis rv on rp.periodo = rv.periodo and rp.informante = rv.informante and rp.visita = rv.visita and rp.formulario = rv.formulario
                  INNER JOIN control_sinvariacion cv on cv.periodo = cvp.moverperiodos(rp.periodo,-1) and cv.informante = rp.informante and cv.producto = rp.producto and
                  cv.visita = rp.visita and cv.observacion = rp.observacion
                  INNER JOIN tareas t on cv.tarea = t.tarea
                  WHERE t.activa = 'S' and t.operativo = 'C')`
        }
    }
}