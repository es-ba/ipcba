"use strict";
var getSqlPlanificacion = require("./planificacion").getSqlPlanificacion;

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador'|| context.user.usu_rol ==='jefe_campo';
    //console.log("url___: ", context.be.config.server["base-url"]);
    //console.log("sql desde la grilla: ",getSqlPlanificacion({usuario:context.user.usu_usu,url_plan:context.be.config.server["base-url"]}));
    return context.be.tableDefAdapt({
        name:'reltar_planificacion',
        tableName:'reltar',
        title:'reltar_planificacion',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },        
        fields:[ 
            {name:'periodo'               , typeName:'text'       , allow:{update:false}},
            {name:'fechasalida'           , typeName:'date'       , allow:{update:false}},
            {name:'panel'                 , typeName:'integer'    , allow:{update:false}},
            {name:'tarea'                 , typeName:'integer'    , allow:{update:false}},
            {name:'encuestador_titular'   , typeName:'text'       , allow:{update:false}, title:'enc.t'},
            {name:'titular'               , typeName:'text'       , allow:{update:false}},
            {name:'encuestador'           , typeName:'text'       , allow:{update:puedeEditar}, title:'enc.r'},
            {name:'suplente'              , typeName:'text'       , allow:{update:false}},
            {name:'fechasalidadesde'      , typeName:'date'       , allow:{update:puedeEditar}},
            {name:'fechasalidahasta'      , typeName:'date'       , allow:{update:puedeEditar}},
            {name:'modalidad'             , typeName:'text'       , allow:{update:false}},
            {name:'consulta'              , typeName:'text'       , allow:{update:false}},
            {name:'submodalidad'          , typeName:'text'       , allow:{update:false}},
            {name:'direcciones'           , typeName:'text'       , allow:{update:false}},
            {name:'compartido'            , typeName:'text'       , allow:{update:false}},
            {name:'visible'               , typeName:'text'       , allow:{update:false}},
            {name:'minfechaplanificada'   , typeName:'date'       , allow:{update:false}},
            {name:'maxfechaplanificada'   , typeName:'date'       , allow:{update:false}},
            {name:'sobrecargado'          , typeName:'integer'    , allow:{update:false}},
            {name:'supervisor'            , typeName:'text'       , allow:{update:false}},
            {name:'observaciones'         , typeName:'text'       , allow:{update:puedeEditar}},
            {name:'url_plan'              , typeName:'text'       , allow:{update:false}, clientSide:'mostrarBotonPlanificacion', serverSide:true,},
            {name:'minfechavisible'       , typeName:'date'       , allow:{update:false}},
            {name:'maxfechavisible'       , typeName:'date'       , allow:{update:false}},
        ],
        primaryKey:['periodo','panel','tarea'],
        sql:{
            from: getSqlPlanificacion({usuario:context.user.usu_usu,url_plan:context.be.config.server["base-url"]})
        }
    },context);
}