"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'req_cambiospantar',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'id_requerimiento', typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'periodo'         , typeName:'text'     , nullable:false, allow:{update:puedeEditar}},
            {name:'informante'      , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'panel'           , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'tarea'           , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'panel_nuevo'     , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'tarea_nueva'     , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'cantorigen'      , typeName:'integer'                  , allow:{update:false}},
            {name:'cantdestino'     , typeName:'integer'                  , allow:{update:false}},
        ],
        primaryKey:['id_requerimiento','periodo','informante','panel','tarea'],
        foreignKeys:[
            {references:'requerimientos', fields:['id_requerimiento']},
        ],
        sql:{
            from:`(select cpt.*, c.cantorigen, c.cantdestino from req_cambiospantar cpt,
                   lateral (select sum(case when cpt.panel = rv.panel and cpt.tarea = rv.tarea then 1 else null end) cantorigen,
                            sum(case when cpt.panel_nuevo = rv.panel and cpt.tarea_nueva = rv.tarea then 1 else null end) cantdestino
                            from relvis rv 
                            where cpt.periodo = rv.periodo and cpt.informante = rv.informante) c
                   )`
        }
    },context);
}