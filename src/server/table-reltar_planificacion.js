"use strict";
var getSqlPlanificacion = require("./planificacion").getSqlPlanificacion;

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    //console.log("sql desde la grilla: ",getSqlPlanificacion({usuario:context.user.usu_usu}));
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
            {name:'fechasalidadesde'      , typeName:'date'       , allow:{update:false}},
            {name:'fechasalidahasta'      , typeName:'date'       , allow:{update:false}},
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
            {name:'observaciones'         , typeName:'text'       , allow:{update:false}},
            {name:'url_plan'              , typeName:'text'       , allow:{update:false}, clientSide:'displayUrl', serverSide:true, width:600},
        ],
        primaryKey:['periodo','panel','tarea'],
        /*
        detailTables:[
            {table:'relvis', abr:'VIS', label:'visitas', fields:['periodo','panel','tarea']},
            {table:'relinf_fechassalida', abr:'INF', label:'informantes', fields:['periodo','panel','tarea']},
        ],
        */        
        sql:{
            from: getSqlPlanificacion({usuario:context.user.usu_usu})
        }
    },context);
}