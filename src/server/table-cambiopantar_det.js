"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='analista';
    return context.be.tableDefAdapt({
        name:'cambiopantar_det',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'id_lote'         , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'periodo'         , typeName:'text'     , nullable:false, allow:{update:puedeEditar}},
            {name:'informante'      , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'panel'           , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'tarea'           , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'panel_nuevo'     , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'tarea_nueva'     , typeName:'integer'  , nullable:false, allow:{update:puedeEditar}},
            {name:'cantorigen'      , typeName:'integer'                  , allow:{update:false}},
            {name:'cantdestino'     , typeName:'integer'                  , allow:{update:false}},
        ],
        primaryKey:['id_lote','periodo','informante','panel','tarea'],
        foreignKeys:[
            {references:'cambiopantar_lote', fields:['id_lote']},
        ],
        sql:{
            isTable: true,
            from:`(select cpt.*, c.cantorigen, c.cantdestino from cambiopantar_det cpt,
                   lateral (select sum(case when cpt.panel = rv.panel and cpt.tarea = rv.tarea then 1 else null end) cantorigen,
                            sum(case when cpt.panel_nuevo = rv.panel and cpt.tarea_nueva = rv.tarea then 1 else null end) cantdestino
                            from relvis rv 
                            where cpt.periodo = rv.periodo and cpt.informante = rv.informante) c
                   )`
        }
    },context);
}