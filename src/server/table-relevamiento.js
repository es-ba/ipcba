"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'relevamiento',
        editable:false,
        fields:[
            {name:'periodo'        , typeName:'text'    },
            {name:'informante'     , typeName:'integer' },
            {name:'visita'         , typeName:'integer' }, 
            {name:'panel'          , typeName:'integer' },
            {name:'tarea'          , typeName:'integer' },
            {name:'abrir'         , typeName: "text" , clientSide:'abrir'},
        ],
        primaryKey:['periodo', 'informante', 'visita'],
        sql:{
            isTable: false,
            from: `(select periodo, informante, rv.visita, panel, tarea
                from relvis rv 
                    inner join periodos p using (periodo)
                    inner join personal per on rv.encuestador = per.persona 
                where p.ingresando = 'S' and 
                      rv.fechasalida >= current_timestamp and
                      per.username = '${context.user.usu_usu}'
                group by periodo, informante, rv.visita, panel, tarea)`
        },
    },context);
}