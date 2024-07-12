"use strict";
import { Context, TableDefinition } from "backend-plus";
export const relpre_control_atr2_diccionario_atributos = (context:Context):TableDefinition => {
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    return {
        name:'relpre_control_atr2_diccionario_atributos',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'   , allow:{update:false}},
            {name:'panel'                        , typeName:'integer', allow:{update:false}},
            {name:'tarea'                        , typeName:'integer', allow:{update:false}},
            {name:'producto'                     , typeName:'text'   , allow:{update:false}},
            {name:'informante'                   , typeName:'integer', title:'inf', allow:{update:false}},
            {name:'recepcionista'                , typeName:'text'    , allow:{update:false}            },
            {name:'formulario'                   , typeName:'integer', title:'for', allow:{update:false}},
            {name:'visita'                       , typeName:'integer', title:'vis', allow:{update:false}},
            {name:'observacion'                  , typeName:'integer', title:'obs', allow:{update:false}},
            {name:'atributo'                     , typeName:'integer', allow:{update:false}},
            {name:'valor'                        , typeName:'text'   , allow:{update:false}},
            {name:'atributo_2'                   , typeName:'integer', allow:{update:false}},
            {name:'valor_2'                      , typeName:'text'   , allow:{update:false}},
            {name:'valido_2'                     , typeName:'text'   , allow:{update:false}},
            {name:'comentariosrelpre'            ,typeName:'text'    , allow:{update:puedeEditar}},
            {name:'esvisiblecomentarioendm'      ,typeName:'boolean' , title:'Ver', allow:{update:puedeEditar}}
        ],
        primaryKey:['periodo','producto','informante','visita','observacion'],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'atributos', fields:['atributo']},
            {references:'atributos', fields:[{source:'atributo_2', target:'atributo'}], alias:'atr'},
            {references:'informantes', fields:['informante']},
            {references:'personal'   , fields:[{source:'recepcionista', target:'persona'  }], alias:'perrec'   },
        ],
        sql:{
            isTable: false,
            from:`(select a.periodo, vis.panel, vis.tarea, a.producto, a.informante, vis.recepcionista, pre.formulario, a.visita, a.observacion, 
                   a.atributo, a.valor, aa.atributo atributo_2, aa.valor valor_2, p.valor_2 valido_2, pre.comentariosrelpre, pre.esvisiblecomentarioendm  
                         from relpre pre
                         join relatr a on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                         join prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo 
                         join productos o on a.producto = o.producto
                         join relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                         left join prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                         left join tipopre t on pre.tipoprecio = t.tipoprecio
                         left join relatr aa on a.periodo = aa.periodo and a.informante = aa.informante and a.producto = aa.producto and a.observacion = aa.observacion 
                                            and a.visita = aa.visita and aa.atributo = p.atributo_2  
                         where coalesce(pa.validaropciones, true) and p.valor is not null and t.activo ='S' and t.espositivo = 'S' and p.atributo_2 is not null and aa.periodo is not null
                         and case when p.valor_2 ~ aa.valor then 1 else 0 end = 0)`,
            },
    };
}