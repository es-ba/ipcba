"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'instalaciones',
        editable:false,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'token_instalacion' , typeName:'text'      , nullable:false},
            {name:'fecha_hora'        , typeName:'timestamp' , nullable:false},
            {name:'encuestador'       , typeName:'text'      , nullable:false},
            {name:'ipad'              , typeName:'text'      , nullable:false},
            {name:'version_sistema'   , typeName:'text'      , nullable:false},
            {name:'token_original'    , typeName:'text'      , nullable:false},            
        ],
        primaryKey:['token_instalacion'],
        foreignKeys:[
            {references:'personal', fields:[{source:'encuestador', target:'persona'}]}
        ],
        sortColumns:[{column:'fecha_hora', order:-1}],
    },context);
}