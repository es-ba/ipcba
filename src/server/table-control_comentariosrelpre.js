"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'control_comentariosrelpre',
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
            {name:'visita'                       ,typeName:'integer', allow:{update:false}},
            {name:'panel'                        ,typeName:'integer', allow:{update:false}},
            {name:'tarea'                        ,typeName:'integer', allow:{update:false}},
            {name:'recepcionista'                ,typeName:'text'   , allow:{update:false}, title:'rec'},
            {name:'nombrerecepcionista'          ,typeName:'text'   , allow:{update:false}},
            {name:'producto'                     ,typeName:'text'   , allow:{update:false}},
            {name:'nombreproducto'               ,typeName:'text'   , allow:{update:false}},
            {name:'observacion'                  ,typeName:'integer', allow:{update:false}, title:'obs'},
            {name:'tipoprecio'                   ,typeName:'text'   , allow:{update:false}, title:'TP'},
            {name:'esvisiblecomentarioendm'      ,typeName:'boolean', title:'Ver', allow:{update:puedeEditar}},
            {name:'comentariosrelpre'            ,typeName:'text'   , allow:{update:puedeEditar}, width:500},
        ],
        primaryKey:['periodo','informante','producto','visita','observacion'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'}],        
        sql:{
            from:`(SELECT r.periodo, r.informante, r.visita, v.panel, v.tarea, v.recepcionista,
                   (pr.nombre::text || ' '::text) || pr.apellido::text AS nombrerecepcionista,
                   r.producto, p.nombreproducto, r.observacion, r.tipoprecio, r.esvisiblecomentarioendm, r.comentariosrelpre
                   FROM cvp.relpre r
                   LEFT JOIN cvp.relvis v ON r.periodo::text = v.periodo::text AND r.informante = v.informante AND r.formulario = v.formulario AND r.visita = v.visita
                   LEFT JOIN cvp.personal pr ON v.recepcionista::text = pr.persona::text
                   LEFT JOIN cvp.productos p ON r.producto::text = p.producto::text
                   WHERE r.comentariosrelpre IS NOT NULL AND r.comentariosrelpre::text <> ''::text AND r.comentariosrelpre::text <> ' '::text)`
        }        
    },context);
}