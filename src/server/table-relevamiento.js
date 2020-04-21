"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'relevamiento',
        editable:false,
        fields:[
            {name:'periodo'         , typeName:'text'    },
            {name:'panel'           , typeName:'integer' },
            {name:'tarea'           , typeName:'integer' },
            {name:'informante'      , typeName:'integer' },
            {name:'visita'          , typeName:'integer' }, 
            {name:'nombreinformante', typeName:'text'    },
            {name:'direccion'       , typeName:'text'    },
            {name:'encuestador'     , typeName:'text', visible:false },
            {name:'abrir'           , typeName: 'text', clientSide:'abrir'},
        ],
        primaryKey:['periodo', 'panel', 'tarea', 'informante','visita'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'}],
        sql:{
            isTable: false,
            from: `(select periodo, panel, tarea, rv.informante, rv.visita, i.nombreinformante, i.direccion,  rt.encuestador
                from relvis rv 
                    inner join periodos p using (periodo)
                    inner join relpan rp using (periodo, panel)
                    inner join reltar rt using (periodo, panel, tarea)
                    inner join personal per on rt.encuestador = per.persona
                    inner join informantes i on rv.informante = i.informante 
                where p.ingresando = 'S' and 
                      rp.fechasalida = current_date and
                      per.username = '${context.user.usu_usu}'
                group by periodo, panel, tarea, rv.informante, rv.visita, i.nombreinformante, i.direccion, rt.encuestador)`
        },
    },context);
}