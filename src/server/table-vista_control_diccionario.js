"use strict";

module.exports = function(context){
    var puedeEditar = false; /*context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';*/
    return context.be.tableDefAdapt({
        name:'vista_control_diccionario',
        //title:'Control del diccionario Valores de Atributos',
        editable:puedeEditar,
        isTable: false,
        fields:[
            {name:'periodo'     , typeName:'text'    },
            {name:'producto'    , typeName:'text'    },
            {name:'atributo'    , typeName:'integer' },
            {name:'valor'       , typeName:'text'    },
            {name:'cantidad'    , typeName:'integer' },
        ],
        primaryKey:['periodo', 'producto', 'atributo', 'valor'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'atributos', fields:['atributo']},
        ],
        /*
        sql: {
            from:`(select r.periodo, r.producto, r.atributo, a.nombreatributo, r.valor, count(*) cantidad
                  from relatr r inner join productos p on r.producto = p.producto 
                  inner join atributos a on r.atributo = a.atributo
                  left join dicprodatr d on r.producto = d.producto and r.atributo = d.atributo and 
                             comun.cadena_normalizar(d.origen) = comun.cadena_normalizar(r.valor)
                  where r.atributo = 13 and d.destino is null and r.periodo >= '` + context.be.internalData.filterUltimoPeriodo + `'
                  group by r.periodo, r.producto, p.nombreproducto, r.atributo, a.nombreatributo, r.valor
                  order by r.periodo, r.producto, p.nombreproducto, r.atributo, a.nombreatributo, r.valor)`
        }
        */
        sql: {
            from:`(select r.periodo, r.producto, r.atributo, a.nombreatributo, r.valor, count(*) cantidad
                  from relatr r inner join productos p on r.producto = p.producto 
                  inner join atributos a on r.atributo = a.atributo
                  where r.atributo = 13 and r.periodo >= '` + context.be.internalData.filterUltimoPeriodo + `'
                  group by r.periodo, r.producto, p.nombreproducto, r.atributo, a.nombreatributo, r.valor
                  order by r.periodo, r.producto, p.nombreproducto, r.atributo, a.nombreatributo, r.valor)`
        }
    },context);
}