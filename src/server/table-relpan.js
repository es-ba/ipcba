"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='analista' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpan',
        title:'paneles',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                 , typeName:'text'   , nullable:false, allow:{update:puedeEditar}},
            {name:'panel'                   , typeName:'integer', nullable:false, allow:{update:puedeEditar}},
            {name:'fechasalida'             , typeName:'date'                   , allow:{update:puedeEditar}},
            {name: "generar"                , typeName: "bigint", editable:false, clientSide:'generarPanel'},
            {name:'fechageneracionpanel'    , typeName:'timestamp'              , allow:{update:puedeEditar}},
            {name:'periodoparapanelrotativo', typeName:'text'                   , allow:{update:puedeEditar}},
            {name:'generacionsupervisiones' , typeName:'timestamp'              , allow:{update:puedeEditar}},
            {name:'fechasalidadesde'        , typeName:'date'                   , allow:{update:puedeEditar}},
            {name:'fechasalidahasta'        , typeName:'date'                   , allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','panel'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
        ],
       detailTables:[
            {table:'relpantar', abr:'TAR', label:'TAREAS', fields:['periodo','panel']},
        ]
    },context);
}
