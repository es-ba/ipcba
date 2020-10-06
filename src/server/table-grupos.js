"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'grupos',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'agrupacion'                   , typeName:'text'    , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'grupo'                        , typeName:'text'    , nullable:false, allow:{update:puedeEditarMigracion}},
            {name:'nombregrupo'                  , typeName:'text'    , isName:true   , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'cluster'                      , typeName:'integer' , isName:true   , allow:{update:puedeEditarMigracion}},
            {name:'grupopadre'                   , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
            {name:'ponderador'                   , typeName:'decimal'                 , allow:{update:puedeEditarMigracion}},
            {name:'nivel'                        , typeName:'integer'                 , allow:{update:puedeEditarMigracion}},
            {name:'esproducto'                   , typeName:'text' , default:'N'      , allow:{update:puedeEditarMigracion}},
            {name:'nombrecanasta'                , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
            {name:'agrupacionorigen'             , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
            {name:'detallarcanasta'              , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
            {name:'explicaciongrupo'             , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'responsable'                  , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
        ],
        filterColumns:[
            {column:'esproducto', operator:'=', value:'N'},
        ],                
        primaryKey:['agrupacion','grupo'],
        foreignKeys:[
            {references:'agrupaciones', fields:['agrupacion']},
            {references:'grupos', fields:[
                {source:'agrupacion'  , target:'agrupacion'     },
                {source:'grupopadre'  , target:'grupo'          },
            ], alias: 'padre'},            
            {references:'agrupaciones', fields:[
                {source:'agrupacionorigen'  , target:'agrupacion'     },
            ], alias: 'ag_origen'},
            //{references:'grupos', fields:[
            //    {source:'agrupacionorigen'  , target:'agrupacion'     },
            //    {source:'grupo'             , target:'grupo'          },
            //], alias: 'ag_origen_g'},
        ]
    },context);
}