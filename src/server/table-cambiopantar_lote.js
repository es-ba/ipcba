"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'cambiopantar_lote',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'id_lote'       , typeName:'integer'  , sequence:{name: 'secuencia_cambiopantar_lote', firstValue: 1}, nullable:true, editable:false },
            {name:'fecha_lote'    , typeName:'date'     , allow:{update:puedeEditar}},
            {name:'fechaprocesado', typeName:'timestamp', allow:{update:false}},
            {name:'cantorigen'    , typeName:'integer'  , allow:{update:false}},
            {name:'cantdestino'   , typeName:'integer'  , allow:{update:false}},
            {name: "proceder"     , typeName: "bigint"  , editable:false, clientSide:'procederCambioPT'},
        ],
        primaryKey:['id_lote'],
        sortColumns:[{column:'id_lote', order:-1}],
        detailTables:[
            {table:'cambiopantar_det', abr:'CPT', label:'cambios pantar', fields:['id_lote'], refreshParent: true},
        ],
        sql:{
            isTable: true,
            from:`(select r.*, c.cantorigen, c.cantdestino from cambiopantar_lote r,
                   lateral (select sum(case when rc.panel = rv.panel and rc.tarea = rv.tarea then 1 else null end) cantorigen,
                            sum(case when rc.panel_nuevo = rv.panel and rc.tarea_nueva = rv.tarea then 1 else null end) cantdestino
                            from cambiopantar_det rc 
                            left join relvis rv on rc.periodo = rv.periodo and rc.informante = rv.informante 
                            where r.id_lote = rc.id_lote) c
                   )`
        }
    },context);
}