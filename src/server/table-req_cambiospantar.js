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
        ],
        primaryKey:['id_requerimiento','periodo','informante','panel','tarea'],
        foreignKeys:[
            {references:'requerimientos', fields:['id_requerimiento']},
        ],
    },context);
}