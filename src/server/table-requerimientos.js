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
        ],
        primaryKey:['id_requerimiento'],
        sortColumns:[{column:'id_requerimiento', order:-1}],
        detailTables:[
            {table:'req_cambiospantar', abr:'CPT', label:'cambios pantar', fields:['id_requerimiento']},
        ],
    },context);
}