"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'requerimientos',
        editable:false,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'id_requerimiento'   , typeName:'integer'  , nullable:false,  sequence:{name: 'secuencia_requerimientos', firstValue: 1}},
            {name:'fecha_requerimiento', typeName:'date'     , nullable:false                                                             },
            {name: "proceder"          , typeName: "bigint"  , editable:false, clientSide:'procederCambioPT'},
            {name:'cantorigen'         , typeName:'integer'  , allow:{update:false}},
            {name:'cantdestino'        , typeName:'integer'  , allow:{update:false}},
        ],
        primaryKey:['id_requerimiento'],
        sortColumns:[{column:'id_requerimiento', order:-1}],
        detailTables:[
            {table:'req_cambiospantar', abr:'CPT', label:'cambios pantar', fields:['id_requerimiento'], refreshParent: true},
        ],
        sql:{
            from:`(select r.*, c.cantorigen, c.cantdestino from requerimientos r,
                   lateral (select sum(case when rc.panel = rv.panel and rc.tarea = rv.tarea then 1 else null end) cantorigen,
                            sum(case when rc.panel_nuevo = rv.panel and rc.tarea_nueva = rv.tarea then 1 else null end) cantdestino
                            from req_cambiospantar rc 
                            left join relvis rv on rc.periodo = rv.periodo and rc.informante = rv.informante 
                            where r.id_requerimiento = rc.id_requerimiento) c
                   )`
        }

    },context);
}