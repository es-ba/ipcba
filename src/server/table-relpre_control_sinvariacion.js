"use strict";
module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'relpre_control_sinvariacion',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      ,typeName:'text'   , allow:{update:false}},
            {name:'panel'                        ,typeName:'integer', allow:{update:false}},
            {name:'tarea'                        ,typeName:'integer', allow:{update:false}},
            {name:'informante'                   ,typeName:'integer', allow:{update:false}},
            {name:'formulario'                   ,typeName:'integer', allow:{update:false}},
            {name:'producto'                     ,typeName:'text'   , allow:{update:false}},
            {name:'visita'                       ,typeName:'integer', allow:{update:false}},
            {name:'observacion'                  ,typeName:'integer', allow:{update:false}},
            {name:'precionormalizado'            ,typeName:'decimal', allow:{update:false}},
            {name:'tipoprecio'                   ,typeName:'text'   , allow:{update:false}}, 
            {name:'modalidad'                    ,typeName:'text'   , allow:{update:false}}, 
            {name:'nombreinformante'             ,typeName:'text'   , allow:{update:false}}, 
            {name:'direccion'                    ,typeName:'text'   , allow:{update:false}}, 
            {name:'telcontacto'                  ,typeName:'text'   , allow:{update:false}}, 
            {name:'web'                          ,typeName:'text'   , allow:{update:false}}, 
            {name:'comentariosrelpre'            ,typeName:'text'   , allow:{update:puedeEditar}},
            {name:'esvisiblecomentarioendm'      ,typeName:'boolean', title:'Ver', allow:{update:puedeEditar}},
            {name:'cantprecios'                  ,title:'cantperiodosconigualprecio',typeName:'integer', allow:{update:false}},
        ],
        primaryKey:['periodo','producto','informante','observacion','visita'],
        hiddenColumns:['visita','productos__cluster'],
        foreignKeys:[
            {references:'productos'  , fields:['producto']},
        ],        
        sql:{
            from:`(SELECT cv.periodo, cv.informante, cv.nombreinformante, cv.producto, cv.visita, cv.observacion, cv.panel, cv.tarea,
                cv.precionormalizado, cv.cantprecios, cv.tipoprecio, rp.comentariosrelpre, rp.esvisiblecomentarioendm,
                cv.direccion, cv.telcontacto, cv.web, cv.modalidad, cv.formulario 
                FROM relpre rp 
                LEFT JOIN control_sinvariacion cv on cv.periodo = rp.periodo and cv.informante = rp.informante and cv.producto = rp.producto and 
                cv.visita = rp.visita and cv.observacion = rp.observacion
                LEFT JOIN tareas t on cv.tarea = t.tarea
                WHERE t.activa = 'S' and t.operativo = 'C')`
            },
    },context);
}