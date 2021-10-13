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
            {name:'inconsistente'                , typeName:'text', allow:{update:false}}
        ],
        primaryKey:['periodo','producto','informante','visita','observacion','atributo'],
        hiddenColumns:['inconsistente'],
        detailTables:[
            {table:'relpre', abr:'PRE', label:'precio', fields:['periodo','producto','informante','visita','observacion'], refreshParent: true},
        ],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'atributos', fields:['atributo']},
            {references:'informantes', fields:['informante']},
        ],
        filterColumns:[
            {column:'inconsistente', operator:'=' , value:'S'}
        ],
        sql:{
            isTable: false,
            from:`(select a.periodo,vis.panel, vis.tarea, a.producto, a.atributo , a.informante, pre.formulario, a.visita, a.observacion, a.valor, pre.comentariosrelpre,
                    pre.esvisiblecomentarioendm, case when p.valor is null then 'S' else 'N' end as inconsistente
                    from cvp.relatr a
                    join cvp.prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo 
                    join cvp.relpre pre on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                    join cvp.relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                    left join cvp.prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                    left join cvp.tipopre t on pre.tipoprecio = t.tipoprecio
                    where coalesce(pa.validaropciones, true) and t.activo ='S' and t.espositivo = 'S')`,
            },
    },context);
}