"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
    	name:'migra_relpre',
        title:'Relpre',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false             , allow:{update:puedeEditar}                   },
            {name:'producto'                     , typeName:'text'    , nullable:false             , allow:{update:puedeEditar}                   },
            {name:'observacion'                  , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'obs'      },
            {name:'informante'                   , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'inf'      },
            {name:'formulario'                   , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'for'      },
            {name:'precio'                       , typeName:'decimal' , allow:{update:puedeEditar} ,width:75,clientSide:'control_precio' , serverSide:true},
            {name:'tipoprecio'                   , typeName:'text'                                 , allow:{update:puedeEditar} ,title:'TP', postInput:'upperSpanish' },
            {name:'visita'                       , typeName:'integer' , nullable:false , default:1 , allow:{update:puedeEditar}, title:'vis'      },
            {name:'comentariosrelpre'            , typeName:'text'                                 , allow:{update:puedeEditar}             },
            {name:'cambio'                       , typeName:'text'                                 , allow:{update:puedeEditar}            , postInput:'upperSpanish' },            
            {name:'precionormalizado'            , typeName:'decimal'                              , allow:{update:puedeEditar}                   },
            {name:'especificacion'               , typeName:'integer'                              , allow:{update:puedeEditar}                   },
            {name:'ultima_visita'                , typeName:'boolean'                              , allow:{update:puedeEditar}                   },
            {name:'observaciones'                , typeName:'text'                                 , allow:{update:puedeEditar}                   },
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},            
            {references:'tipopre', fields:['tipoprecio']},            
        ],
        //sortColumns:[{column:'orden'},{column:'observacion'}],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita']},
        ],       
    },context);
}