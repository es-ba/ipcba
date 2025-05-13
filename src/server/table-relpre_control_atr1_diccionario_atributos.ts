"use strict";
import { Context, TableDefinition } from "backend-plus";
export const relpre_control_atr1_diccionario_atributos = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' /*|| context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion'|| context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor'*/;
    return {
        name:'relpre_control_atr1_diccionario_atributos',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , allow:{update:false}                   },
            {name:'panel'                        , typeName:'integer' , allow:{update:false}                   },
            {name:'tarea'                        , typeName:'integer' , allow:{update:false}                   },
            {name:'producto'                     , typeName:'text'    , allow:{update:false}                   },
            {name:'informante'                   , typeName:'integer' , allow:{update:false}      , title:'inf'},
            {name:'recepcionista'                , typeName:'text'    , allow:{update:false}                   },
            {name:'formulario'                   , typeName:'integer' , allow:{update:false}      , title:'for'},
            {name:'visita'                       , typeName:'integer' , allow:{update:false}      , title:'vis'},
            {name:'observacion'                  , typeName:'integer' , allow:{update:false}      , title:'obs'},
            {name:'valor'                        , typeName:'text'    , allow:{update:false}                   },
            {name:'comentariosrelpre'            , typeName:'text'    , allow:{update:puedeEditar}             },
            {name:'esvisiblecomentarioendm'      , typeName:'boolean' , allow:{update:puedeEditar}, title:'Ver'},
        ],
        primaryKey:['periodo','producto','informante','visita','observacion'],
        foreignKeys:[
            {references:'productos'  , fields:['producto']                                                     },
            {references:'informantes', fields:['informante']                                                   },
            {references:'personal'   , fields:[{source:'recepcionista', target:'persona'  }], alias:'perrec'   },
        ],
        sql:{
            isTable: false,
            from:`(select a.periodo, vis.panel, vis.tarea, a.producto, a.informante, pre.formulario, a.visita, a.observacion,
            string_agg (concat(a.atributo,' (',at.nombreatributo,'): ',a.valor),';') as valor, pre.comentariosrelpre, pre.esvisiblecomentarioendm, vis.recepcionista
                  from relpre pre
                  join relatr a on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                  join atributos at on a.atributo = at.atributo
                  join prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo
                  join productos o on a.producto = o.producto
                  join relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario
                  left join prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor and p.activo
                  left join tipopre t on pre.tipoprecio = t.tipoprecio
                  where coalesce(pa.validaropciones, true) and p.valor is null and t.activo ='S' and t.espositivo = 'S'
                  group by a.periodo, vis.panel, vis.tarea, a.producto, a.informante, pre.formulario, a.visita, a.observacion,
                  pre.comentariosrelpre, pre.esvisiblecomentarioendm, vis.recepcionista)`,
            },
    };
}