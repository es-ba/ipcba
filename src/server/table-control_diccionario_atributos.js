"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_diccionario_atributos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'   },
            {name:'panel'                        , typeName:'integer'},
            {name:'tarea'                        , typeName:'integer'},
            {name:'producto'                     , typeName:'text'   },
            {name:'nombreproducto'               , typeName:'text'   },
            {name:'atributo'                     , typeName:'integer'},
            {name:'nombreatributo'               , typeName:'text'   },
            {name:'informante'                   , typeName:'integer', title:'inf'},
            {name:'formulario'                   , typeName:'integer', title:'for'},
            {name:'visita'                       , typeName:'integer', title:'vis' },
            {name:'observacion'                  , typeName:'integer', title:'obs' },
            {name:'valor'                        , typeName:'text'   },
        ],
        primaryKey:['periodo','producto','informante','visita','observacion'],
        sql:{
            isTable: false,
            from:`(select a.periodo,vis.panel, vis.tarea, a.producto, o.nombreproducto, a.atributo, at.nombreatributo, a.informante, pre.formulario, a.visita, a.observacion, a.valor  
                    from cvp.relatr a
                    join cvp.atributos at on a.atributo = at.atributo
                    join cvp.prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo 
                    join cvp.productos o on a.producto = o.producto
                    join cvp.relpre pre on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                    join cvp.relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                    left join cvp.prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                    left join cvp.tipopre t on pre.tipoprecio = t.tipoprecio
                    where pa.validaropciones and p.valor is null and t.activo ='S' and t.espositivo = 'S')`,
            /*
                from:`(select a.periodo, vis.panel, vis.tarea, a.producto, o.nombreproducto, pre.formulario, a.informante, a.visita, a.observacion, a.valor marca   
                    from cvp.relatr a 
                    left join cvp.prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                    left join cvp.productos o on a.producto = o.producto
                    left join cvp.atributos t on a.atributo = t.atributo
                    left join cvp.relpre pre on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                    left join cvp.relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                    where a.producto in (select distinct producto from cvp.prodatrval) and a.atributo = 13 and a.valor is distinct from p.valor)`,
            */
            },
    },context);
}