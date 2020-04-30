"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador';
    return context.be.tableDefAdapt({
        name:'relvis_pt',
        tableName:'relvis',
        title:'RelvisPT',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                   , typeName:'text'    , nullable:false            , allow:{update:false}               },
            {name:'informante'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'inf'  },
            {name:'visita'                    , typeName:'integer' , nullable:false , default:1, allow:{update:false}, title:'vis'  },
            {name:'formulario'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'for'  },
            {name:'panel'                     , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
            {name:'tarea'                     , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
            //{name: "cambiar"                  , typeName: "bigint" , editable:false            ,clientSide:'cambiarPanelTarea'},
            //{name:'otropanel'                 , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
            //{name:'otratarea'                 , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        sortColumns:[{column:'informante'},{column:'visita'},{column:'formulario'}],
        foreignKeys:[
            {references:'formularios', fields:['formulario']},
            {references:'informantes', fields:['informante']},
            {references:'periodos'   , fields:['periodo'   ]},
            {references:'relpan'     , fields:['periodo','panel']},            
        ],
        sql:{
            from:`(
                  select periodo, informante, visita, formulario, panel, tarea
                  from relvis rv
                  )`,
        }        
    },context);
}