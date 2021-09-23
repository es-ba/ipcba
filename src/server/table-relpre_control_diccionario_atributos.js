"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'relpre_control_diccionario_atributos',
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
            {name:'formulario'                   , typeName:'integer', title:'for', allow:{update:false}},
            {name:'visita'                       , typeName:'integer', title:'vis', allow:{update:false}},
            {name:'observacion'                  , typeName:'integer', title:'obs', allow:{update:false}},
            {name:'valor'                        , typeName:'text'   , allow:{update:false}},
            {name:'otrovalorvalidar'             , typeName:'text', title:'validos', allow:{update:false}},
            {name:'comentariosrelpre'            , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'esvisiblecomentarioendm'      , typeName:'boolean' , title:'Ver', allow:{update:puedeEditar}}
        ],
        primaryKey:['periodo','producto','informante','visita','observacion'],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'informantes', fields:['informante']},
        ],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributo', fields:['periodo','producto','informante','visita','observacion'], refreshParent: true},
        ],
        sql:{
            isTable: false,
            from:`(select periodo, panel, tarea, producto, informante, formulario, visita, observacion, comentariosrelpre, esvisiblecomentarioendm, 
                     string_agg (concat(q.atributo,' (',at.nombreatributo,'): ',q.valor, '; '||q.otroatributo||' ('||at2.nombreatributo||'): '||q.otrovalor) ,';') as valor,
                     string_agg (q.otrovalorvalidar,';') as otrovalorvalidar
                   from (select a.periodo, vis.panel, vis.tarea, a.producto, a.informante, pre.formulario, a.visita, a.observacion, a.atributo, a.valor, pre.comentariosrelpre, 
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
                           where (p.valor is null or (p.atributo_2 is not null and regexp_match(p.valor_2, aa.valor) is null)) and t.activo ='S' and t.espositivo = 'S'
                        ) q
                   left join cvp.atributos at on q.atributo = at.atributo
                   left join cvp.atributos at2 on q.otroatributo = at2.atributo
                   group by periodo, panel, tarea, producto, informante, formulario, visita, observacion, comentariosrelpre, esvisiblecomentarioendm)`,
            },
    },context);
}