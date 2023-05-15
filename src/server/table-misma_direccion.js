"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'misma_direccion',
        title:'misma dirección',
        editable:false,
        fields:[
            {name:'informante'                   , typeName:'integer' },
            {name:'informanteenmismadireccion'   , typeName:'integer' },
            {name:'nombreinformante'             , typeName:'text'    },
            {name:'direccion'                    , typeName:'text'    },
            {name:'estado'                       , typeName:'text'    },
        ],
        primaryKey:['informante','informanteenmismadireccion'],
        sortColumns:[{column:'informanteenmismadireccion'}],
        sql:{
            from:`(select i.informante, i2.informante informanteenmismadireccion, i2.nombreinformante, i2.direccion, ei.estado
                    from infreemp i, informantes i2, informantes_estado ei
                    where i.direccionalternativa = i2.direccion and i.informante is distinct from i2.informante and i2.informante = ei.informante
                  )`
        }
    },context);
}