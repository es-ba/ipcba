"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relpre_control_rangos_atrnorm',
        title:'atributos normalizables',
        editable:false,
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'informante'                   , typeName:'integer' },
            {name:'producto'                     , typeName:'text'    },
            {name:'visita'                       , typeName:'integer' },
            {name:'observacion'                  , typeName:'integer' },
            {name:'atrnormalizables'             , typeName:'text'    },
        ],
        primaryKey:['periodo','informante','producto','visita','observacion'],
        sql:{
            from:`(select r.periodo, r.informante, r.producto, r.visita, r.observacion, 
                   string_agg(a.nombreatributo||'('||a.unidaddemedida||')'||':'||r.valor, '; ') atrnormalizables
                   from relatr r
                   left join prodatr pa on r.producto = pa.producto and r.atributo = pa.atributo 
                   left join atributos a on pa.atributo = a.atributo
                   where pa.normalizable = 'S' 
                   group by r.periodo, r.informante, r.producto, r.visita, r.observacion)`
        }
    },context);
}