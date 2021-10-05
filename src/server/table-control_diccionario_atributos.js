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
            {name:'informante'                   , typeName:'integer', title:'inf', allow:{update:false}},
            {name:'formulario'                   , typeName:'integer', title:'for', allow:{update:false}},
            {name:'visita'                       , typeName:'integer', title:'vis', allow:{update:false}},
            {name:'observacion'                  , typeName:'integer', title:'obs', allow:{update:false}},
            {name:'comentariosrelpre'            , typeName:'text'   , allow:{update:false}},
            {name:'esvisiblecomentarioendm'      , typeName:'boolean', title:'Ver', allow:{update:false}},
            {name:'atributo'                     , typeName:'integer', allow:{update:false}},
            {name:'valor'                        , typeName:'text'   , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'valido_1'                     , typeName:'text'   , allow:{update:false}},
            {name:'otroatributo'                 , typeName:'integer', allow:{update:false}},
            {name:'valores'                      , typeName:'text'   , allow:{update:false}},
            {name:'valido_2'                     , typeName:'text'   , allow:{update:false}},
            {name:'inconsistente'                , typeName:'text'   , allow:{update:false}},
        ],
        primaryKey:['periodo','producto','informante','visita','observacion','atributo'],
        hiddenColumns:['inconsistente'],
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
        filterColumns:[
            {column:'inconsistente', operator:'=' , value:'S'}
        ],
        sql:{
            isTable: false,
            from:
            `(select periodo, panel, tarea, informante, formulario, producto, observacion, visita, comentariosrelpre, esvisiblecomentarioendm, val_valor valido_1, val_valor_2 valido_2
                , min(case when prioridad in (1, 3) then atributo end) atributo, min(case when prioridad in (1, 3) then valor end) valor, max(case when prioridad = 2 then atributo end) otroatributo
                , string_agg (atributo::text,', ' order by prioridad) as atributos, string_agg (valor,', ' order by prioridad) as valores, count (distinct atributo) cantatributos,
                case when val_valor is null then 'S'
                     when regexp_match(string_agg (valor,', ' order by prioridad), val_valor) is not null and count (distinct atributo) > 1 then 'S'
                     when regexp_match(string_agg (valor,', ' order by prioridad), val_valor) is not null and count (distinct atributo) = 1 then 'N'
                     when regexp_match(string_agg (valor,', ' order by prioridad), val_valor) is null then 'N'
                     else null end as inconsistente
                from (select a.periodo, vis.panel, vis.tarea, 
                        a.informante, pre.formulario, a.producto, 
                        a.observacion, a.visita, a.atributo, a.valor, pre.comentariosrelpre, pre.esvisiblecomentarioendm,
                        case when p.producto   is null then po.producto   else p.producto   end as val_producto, 
                        case when p.atributo   is null then po.atributo   else p.atributo   end as val_atributo, 
                        case when p.valor      is null then po.valor      else p.valor      end as val_valor, 
                        case when p.atributo_2 is null then po.atributo_2 else p.atributo_2 end as val_atributo_2, 
                        case when p.valor_2    is null then po.valor_2    else p.valor_2    end as val_valor_2,
                        case when p.producto  is not null and p.atributo  is not null and p.valor is not null  then 1
                             when po.producto is not null and po.atributo is not null and po.valor is not null then 2
                             else 3 end as prioridad 
                        from cvp.relatr a
                        join cvp.prodatr pa on a.producto =  pa.producto and a.atributo = pa.atributo  
                        join cvp.relpre pre on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                        join cvp.relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                        left join cvp.tipopre t on pre.tipoprecio = t.tipoprecio
                        left join cvp.prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                        left join cvp.prodatrval po on a.producto = po.producto and a.atributo = po.atributo_2 and regexp_match(po.valor_2, a.valor) is null
                        where (coalesce(pa.validaropciones, true) or po.atributo_2 is not null) and a.valor is not null /*si el a.valor es nulo, lo voy a validar o no?*/ and t.activo ='S' and t.espositivo = 'S'
                        order by a.periodo, vis.panel, vis.tarea, 
                             a.informante, pre.formulario, a.producto, 
                             a.observacion, a.visita, a.atributo, pre.comentariosrelpre, pre.esvisiblecomentarioendm	
                     ) G group by periodo, panel, tarea, informante, formulario, producto, observacion, visita, comentariosrelpre, esvisiblecomentarioendm, val_valor, val_valor_2	
            )`,
            },
    },context);
}