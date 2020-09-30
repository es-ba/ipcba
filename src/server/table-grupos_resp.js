"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    return context.be.tableDefAdapt({
        name:'grupos_resp',
        tableName:'grupos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'agrupacion'                   , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'grupo'                        , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'grupopadre'                   , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'nivel'                        , typeName:'integer'                 , allow:{update:false}},
            {name:'esproducto'                   , typeName:'text'                    , allow:{update:false}},
            {name:'responsable'                  , typeName:'text'                    , allow:{update:false}},
        ],
        filterColumns:[
            {column:'agrupacion', operator:'=', value:'F'},
        ],                
        primaryKey:['agrupacion','grupo'],
        foreignKeys:[
            {references:'agrupaciones', fields:['agrupacion']},
            {references:'productos', fields:[
                {source:'grupo'         , target:'producto'     },
            ]},
        ],
        sql:{
            from:`(
                select g.agrupacion, g.grupo, g.grupopadre, 
                  g.nivel, g.esproducto, coalesce (g.responsable,gp.responsable) as responsable
                  from grupos g
                  left join grupos gp on g.agrupacion = gp.agrupacion and g.grupopadre = gp.grupo
                  )`
        }
    },context);
}