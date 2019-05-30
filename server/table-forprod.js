"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'forprod',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },        
        fields:[
            {name:'formulario'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'producto'                    , typeName:'text'    , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'orden'                       , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'ordenimpresion'              , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
        ],
        primaryKey:['formulario','producto'],
        foreignKeys:[
            {references:'formularios', fields:['formulario']},
            {references:'productos'  , fields:['producto']},
        ],
        detailTables:[
            {table:'formularios', abr:'DET', label:'formularios', fields:['formulario']},
            {table:'prodespecificacioncompleta', abr:'ECO', label:'Especificacion Completa', fields:['formulario','producto']},
        ],

    },context);
}