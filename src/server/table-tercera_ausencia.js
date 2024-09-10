"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'tercera_ausencia',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'informante'           ,typeName:'integer'},
            {name:'formulario'           ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'masinfo'              ,typeName:'text'   },
        ],
        primaryKey:['periodo', 'informante', 'formulario', 'visita'],
        sql:{
            from:`(select r.periodo, r.informante, r.formulario, r.visita, string_agg(rant.periodo||':'||r.razon||'('||z.nombrerazon||')','  ' order by rant.periodo) as masinfo
                    from relvis r 
                    join relvis rant on r.informante = rant.informante and r.formulario = rant.formulario and r.visita = rant.visita 
                    and rant.periodo between moverperiodos(r.periodo, -2) and r.periodo
                    join razones z on rant.razon = z.razon 
                    where z.escierretemporalfor = 'S'
                    group by r.periodo, r.informante, r.formulario, r.visita
                    having count(*) >= 3
                )`
        },
    },context);
}