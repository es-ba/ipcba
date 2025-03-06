"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='jefe_recepcion';
    return context.be.tableDefAdapt({
        name:'licencias',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'persona'      , typeName:'text' , allow:{update:puedeEditar}},
            {name:'fechadesde'   , typeName:'date' , allow:{update:puedeEditar}},
            {name:'fechahasta'   , typeName:'date' , allow:{update:puedeEditar}},
            {name:'motivo'       , typeName:'text' , allow:{update:puedeEditar}},
            {name:'modi_fec'     , typeName:'timestamp' , allow:{update:false}, defaultDbValue: 'current_date'},
            {name:'modi_usu'     , typeName:'text' , allow:{update:false}, defaultValue: context.user.usuario},
            {name:'usuario'      , typeName:'text' , allow:{update:false}},
            {name:'fecha'        , typeName:'date' , allow:{update:false}},
        ],
        primaryKey:['persona','fechadesde','fechahasta'],
        sortColumns:[{column:'fechahasta', order:-1}, {column:'persona'}],
        foreignKeys:[
            {references:'personal', fields:['persona']},
            {references: "ipcba_usuarios", fields: [{source:'modi_usu' , target:'usu_usu'}], alias: 'modi_usu'},
        ],
        hiddenColumns:['modi_usu','modi_fec'],
        sql:{
            from:`(SELECT persona, fechadesde, fechahasta, motivo, modi_fec, modi_usu, modi_usu usuario, modi_fec::date fecha
                    FROM licencias)`,  
        }
   },context);
}