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
            {name:'informante'                   ,typeName:'integer', allow:{update:false}},
            {name:'nombreinformante'             ,typeName:'text'   , allow:{update:false}},
            {name:'tipoinformante'               ,typeName:'text'   , allow:{update:false}},
            {name:'producto'                     ,typeName:'text'   , allow:{update:false}},
            {name:'nombreproducto'               ,typeName:'text'   , allow:{update:false}},
            {name:'visita'                       ,typeName:'integer', allow:{update:false}},
            {name:'observacion'                  ,typeName:'integer', allow:{update:false}},
            {name:'panel'                        ,typeName:'integer', allow:{update:false}},
            {name:'tarea'                        ,typeName:'integer', allow:{update:false}},
            {name:'recepcionista'                ,typeName:'text'   , allow:{update:false}},
            {name:'precionormalizado'            ,typeName:'decimal', allow:{update:false}},
            {name:'cantprecios'                  ,title:'cantperiodosconigualprecio',typeName:'integer', allow:{update:false}},
            {name:'tipoprecio'                   ,typeName:'text'   , allow:{update:false}}, 
            {name:'comentariosrelpre'            ,typeName:'text'   , allow:{update:puedeEditar}},
            {name:'esvisiblecomentarioendm'      ,typeName:'boolean', title:'Ver', allow:{update:puedeEditar}}
        ],
        primaryKey:['periodo','producto','informante','observacion','visita'],
        sql:{
            from:`(SELECT cv.periodo, cv.informante, cv.nombreinformante, cv.tipoinformante, cv.producto, cv.nombreproducto, cv.visita, cv.observacion, cv.panel, cv.tarea, cv.recepcionista,
                cv.precionormalizado, cv.cantprecios, cv.tipoprecio, rp.comentariosrelpre, rp.esvisiblecomentarioendm 
                FROM relpre rp 
                INNER JOIN control_sinvariacion cv on cv.periodo = rp.periodo and cv.informante = rp.informante and cv.producto = rp.producto and 
                cv.visita = rp.visita and cv.observacion = rp.observacion
                INNER JOIN tareas t on cv.tarea = t.tarea
                WHERE t.activa = 'S' and t.operativo = 'C')`
            },
    });
}