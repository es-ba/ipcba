"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista' /*|| context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion'*/;
    return context.be.tableDefAdapt({
        name:'prodatrval',
        policy:'web',
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'producto'                  , typeName:'text'     },
            {name:'atributo'                  , typeName:'integer'  },
            {name:'valor'                     , typeName:'text'     , postInput:'upperSpanish'},
            {name:'orden'                     , typeName:'integer'  },
            {name:'atributo_2'                , typeName:'integer'  },
            {name:'valor_2'                   , typeName:'text'     , postInput:'upperSpanish'},
            {name:'usuario'                   , typeName:'text'     , allow:{update:false}    },
            {name:'fecha'                     , typeName:'date'     , allow:{update:false}    },
        ],
        primaryKey:['producto','atributo','valor'],
        foreignKeys:[
            {references:'prodatr', fields:['producto','atributo']},
            {references:'prodatr', fields:[
                                           {source:'producto'     , target:'producto'},
                                           {source:'atributo_2'   , target:'atributo'}
                                          ], alias: 'pat'}
        ],
        softForeignKeys:[
            {references:'atributos', fields:['atributo']},
            {references:'atributos', fields:[{source:'atributo_2', target:'atributo'}], alias: 'at'},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from:`(SELECT producto, atributo, valor, orden, atributo_2, valor_2, modi_usu usuario, modi_fec::date fecha
                    FROM prodatrval)`,  
        }
    },context);
}