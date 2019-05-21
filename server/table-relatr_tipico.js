"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relatr_tipico',
        title:'valores típicos',
        editable:false,
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'producto'                     , typeName:'text'    },
            {name:'atributo'                     , typeName:'integer' },
            {name:'valor'                        , typeName:'text'    },
            {name:'frecuencia'                   , typeName:'bigint'  },
            {name:'obs'                          , typeName:'text'    },
        ],
        primaryKey:['periodo','producto','atributo','valor'],
        sortColumns:[{column:'valor'}],
        sql:{
            from:`(
                select ra.periodo, ra.producto, ra.atributo, ra.valor, count(*) as frecuencia,
                       case when a.escantidad='S' then 
                          case when (ra.valor::double precision > pa.rangohasta AND pa.normalizable = 'S' and pa.tiponormalizacion = 'Normal' AND ra.valor::double precision <> pa.valornormal) or 
                                    (ra.valor::double precision < pa.rangodesde AND pa.normalizable = 'S' and pa.tiponormalizacion = 'Normal' AND ra.valor::double precision <> pa.valornormal) then '✘ fuera de rango' else null end
                       else null end as obs
                  from relatr ra inner join prodatr pa on pa.atributo=ra.atributo and pa.producto=ra.producto
                       inner join atributos a on a.atributo=ra.atributo
                  group by ra.periodo, ra.producto, ra.atributo, ra.valor, pa.rangodesde, pa.rangohasta, pa.normalizable, pa.tiponormalizacion, pa.valornormal, a.escantidad
                  )`
        }
    },context);
}