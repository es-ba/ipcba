"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_generacion_formularios',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   }, 
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'informante'                   ,typeName:'integer'},
            {name:'formulario'                   ,typeName:'integer'},
            {name:'visita'                       ,typeName:'integer'},
            {name:'razonant'                     ,typeName:'integer'},
            {name:'razon'                        ,typeName:'integer'},
            {name:'descripcion'                  ,typeName:'text'   },
            {name:'panelactual'                  ,typeName:'integer'},
            {name:'tareaactual'                  ,typeName:'integer'},
        ],
        primaryKey:['periodo','informante','formulario','visita'],
        foreignKeys:[
            {references:'formularios', fields:['formulario']},
            {references:'informantes', fields:['informante']},
        ],
        sql:{
            isTable: false,
        },
    },context);
}