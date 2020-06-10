"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo';
    return context.be.tableDefAdapt({
        name:'relpantar',
        tableName:'reltar',
        title:'relpantar',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },        
        fields:[
            {name:'periodo'               , typeName:'text'       , allow:{update:false}},
            {name:'panel'                 , typeName:'integer'    , allow:{update:false}},
            {name:'tarea'                 , typeName:'integer'    , allow:{update:false}},
            {name:'recepcionista'         , typeName:'text'       , allow:{update:false}, title:'rec.t'},
            {name:'verificado'            , typeName:'text'       , allow:{update:false}, title:'ver.r'},
            {name:'encuestador_titular'   , typeName:'text'       , allow:{update:false}, title:'enc.t'},
            {name:'titular'               , typeName:'text'       , allow:{update:false}},
            {name:'encuestador'           , typeName:'text'       , allow:{update:puedeEditar}, title:'enc.r'},
            {name:'suplente'              , typeName:'text'       , allow:{update:false}},
            {name:'sobrecargado'          , typeName:'integer'    , allow:{update:false}},
            {name:'fechasalidadesde'      , typeName:'date'       , allow:{update:puedeEditar}},
            {name:'fechasalidahasta'      , typeName:'date'       , allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','panel','tarea'],
        detailTables:[
            {table:'relvis', abr:'VIS', label:'visitas', fields:['periodo','panel','tarea']},
            {table:'hdrexportarefectivossinprecio', abr:'ESP', label:'efectivos sin precio', fields:['periodo','panel','tarea']},
            {table:'relinf_fechassalida', abr:'INF', label:'informantes', fields:['periodo','panel','tarea']},
        ],        
        sql:{
            from:`(select rt.periodo, rt.panel, rt.tarea, t.recepcionista, CASE WHEN verif like '%N%' THEN ' ' ELSE '✓' END verificado, 
                          t.encuestador encuestador_titular, te.nombre||' '||te.apellido as titular, rt.encuestador, 
                          case when rt.encuestador=t.encuestador then null else nullif(concat_ws(' ', tre.nombre, tre.apellido),'') end as suplente,
                          nullif(nullif((select count(*) from reltar x where x.periodo=rt.periodo and x.panel=rt.panel and x.encuestador=rt.encuestador),1),0) as sobrecargado,
                          rt.fechasalidadesde, rt.fechasalidahasta
                     from reltar rt
                       left join tareas t on rt.tarea = t.tarea
                       left join personal te on t.encuestador = te.persona
                       left join personal tre on rt.encuestador = tre.persona,
                       lateral (SELECT string_agg (verificado_rec,'') verif
                                       FROM cvp.relvis v
                                       WHERE rt.periodo = v.periodo and rt.panel = v.panel and rt.tarea = v.tarea
                                       GROUP BY periodo, panel, tarea) vis
                     where t.activa = 'S'
                )`
        }            
    },context);
}