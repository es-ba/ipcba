"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo';
    return context.be.tableDefAdapt({
        name:'control_diccionario_atributos',
        tableName:'relatr',
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
            {name:'atributo'                     , typeName:'integer', allow:{update:false}},
            {name:'informante'                   , typeName:'integer', title:'inf', allow:{update:false}},
            {name:'formulario'                   , typeName:'integer', title:'for', allow:{update:false}},
            {name:'visita'                       , typeName:'integer', title:'vis', allow:{update:false}},
            {name:'observacion'                  , typeName:'integer', title:'obs', allow:{update:false}},
            {name:'valor'                        , typeName:'text'   , allow:{update:true}, postInput:'upperSpanish'},
            {name:'comentariosrelpre'            , typeName:'text', allow:{update:false}},
            {name:'esvisiblecomentarioendm'      , typeName:'boolean', title:'Ver', allow:{update:false}},
            {name:'otroatributo'                 , typeName:'integer', allow:{update:false}},
            {name:'otrovalor'                    , typeName:'text', title:'novalido', allow:{update:false}},
            {name:'otrovalorvalidar'             , typeName:'text', title:'validos', allow:{update:false}}
        ],
        primaryKey:['periodo','producto','informante','visita','observacion','atributo'],
        detailTables:[
            {table:'relpre', abr:'PRE', label:'precio', fields:['periodo','producto','informante','visita','observacion'], refreshParent: true},
            {table:'relatr', abr:'ATR', label:'atributo', fields:['periodo','producto','informante','visita','observacion',{source:'otroatributo', target:'atributo'}], refreshParent: true},
        ],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'atributos', fields:['atributo']},
            {references:'atributos', fields:[{source:'otroatributo', target:'atributo'}], alias:'atr'},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            isTable: false,
            from:`(select a.periodo, vis.panel, vis.tarea, a.producto, a.informante, pre.formulario, a.visita, a.observacion, a.atributo, a.valor, pre.comentariosrelpre, 
                      pre.esvisiblecomentarioendm, p.valor vvalido, p.atributo_2 otroatributo, p.valor_2 otrovalorvalidar, aa.valor otrovalor
                      from cvp.relatr a
                      join cvp.prodatr pa on a.producto =  pa.producto and a.atributo = pa.atributo and coalesce(pa.validaropciones, true) 
                      join cvp.relpre pre on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                      join cvp.relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                      left join cvp.tipopre t on pre.tipoprecio = t.tipoprecio
                      left join cvp.prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                      left join cvp.relatr aa on a.periodo = aa.periodo and a.informante = aa.informante and 
                      a.producto = aa.producto and a.visita = aa.visita and a.observacion = aa.observacion
                      and p.atributo_2 = aa.atributo
                      where (p.valor is null or (p.atributo_2 is not null and regexp_match(p.valor_2, aa.valor) is null)) and t.activo ='S' and t.espositivo = 'S')`,
            },
    },context);
}