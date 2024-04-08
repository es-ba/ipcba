"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'fechas',
        allow:{
            update:puedeEditar,
        },
        fields:[
            {name:'fecha'                      , typeName:'date' , allow:{update:false}},
            {name:'visible_planificacion'      , typeName:'text' , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'seleccionada_planificacion' , typeName:'text' , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'panel'                      , typeName:'text' , allow:{update:false}},
        ],
        primaryKey:['fecha'],
        sql:{
            isTable: true,
            from:`(select f.*, string_agg(rp.panel::text,',') panel
                     from fechas f left join relpan rp on f.fecha = rp.fechasalida
                     left join periodos p on rp.periodo = p.periodo 
                     where rp.panel is not null and ingresando = 'S'
                     group by fecha, visible_planificacion, seleccionada_planificacion
                   )`
        }

    },context);
}