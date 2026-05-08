"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='jefe_recepcion';
    return context.be.tableDefAdapt({
        name:'fechas',
        allow:{
            update:puedeEditar,
        },
        fields:[
            {name:'fecha'                      , typeName:'date' , allow:{update:false}},
            {name:'visible_planificacion'      , typeName:'text' , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'seleccionada_planificacion' , typeName:'text' , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'visible_ingreso'            , typeName:'text' , allow:{update:puedeEditar}, postInput:'upperSpanish', defaultdbValue:'S'},
            {name:'panel'                      , typeName:'text' , allow:{update:false}},
        ],
        primaryKey:['fecha'],
        filterColumns:[
            {column:'visible_ingreso', operator:'=', value:'S'},
        ],
        //refrescable: true,
        //selfRefresh: true,
        sql:{
            isTable: true,
            from:`(SELECT f.*, string_agg(rp.panel::text, ',') AS panel
                FROM periodos p
                INNER JOIN fechas f ON p.periodo = TO_CHAR(f.fecha, '"a"YYYY"m"MM')
                LEFT JOIN relpan rp ON f.fecha = rp.fechasalida AND rp.periodo = p.periodo
                WHERE p.ingresando = 'S'
                GROUP BY f.fecha, f.visible_planificacion, f.seleccionada_planificacion, f.visible_ingreso
                ORDER BY f.fecha DESC)`,
        }

    },context);
}