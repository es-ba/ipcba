"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin' || context.user.usu_rol ==='programador';
    return context.be.tableDefAdapt({
        name:'relpan',
        title:'paneles',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                 , typeName:'text'   , nullable:false},
            {name:'panel'                   , typeName:'integer', nullable:false},
            {name:'fechasalida'             , typeName:'date'},
            {name: "generar"                , typeName: "bigint"  , editable:false, clientSide:'generarPanel'},
            {name:'fechageneracionpanel'    , typeName:'timestamp'},
            {name:'periodoparapanelrotativo', typeName:'text', allow:{select:false}},
            {name:'generacionsupervisiones' , typeName:'timestamp'},
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
