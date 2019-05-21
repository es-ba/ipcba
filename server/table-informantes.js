"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'informantes',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },

        fields:[
            {name:'informante'                , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'nombreinformante'          , typeName:'text'    , isName:true   , allow:{update:puedeEditar}},
            {name:'estado'                    , typeName:'text'                    },
            {name:'tipoinformante'            , typeName:'text' , nullable:false, isName:true, title:'TI', allow:{update:puedeEditar}},
            {name:'rubroclanae'               , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'cadena'                    , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'direccion'                 , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'altamanualperiodo'         , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'altamanualpanel'           , typeName:'integer'                 , allow:{update:puedeEditar}},
            {name:'altamanualtarea'           , typeName:'integer'                 , allow:{update:puedeEditar}},
            {name:'altamanualconfirmar'       , typeName:'timestamp'               , allow:{update:puedeEditar}},
            {name:'razonsocial'               , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'nombrecalle'               , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'altura'                    , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'piso'                      , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'departamento'              , typeName:'text'                    , allow:{update:puedeEditar}},
            //{name:'cuit'                      , typeName:'integer'                 },
            //{name:'naecba'                    , typeName:'integer'                 },
            //{name:'totalpers'                 , typeName:'integer'                 },
            {name:'cp'                        , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'distrito'                  , typeName:'integer'                 , allow:{update:puedeEditar}},
            {name:'fraccion'                  , typeName:'integer'                 , allow:{update:puedeEditar}},
            //{name:'radio'                     , typeName:'integer'                 },
            //{name:'manzana'                   , typeName:'integer'                 },
            //{name:'lado'                      , typeName:'integer'                 },
            {name:'obs_listador'              , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'nr_listador'               , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'fecha_listado'             , typeName:'date'                    , allow:{update:puedeEditar}},
            {name:'grupo_listado'             , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'conjuntomuestral'          , typeName:'integer'                 , allow:{update:puedeEditar}},
            {name:'rubro'                     , typeName:'integer' , nullable:false               , allow:{update:puedeEditar}},
            {name:'ordenhdr'                  , typeName:'integer' , nullable:false , default:100 , allow:{update:puedeEditar}},
            //{name:'cue'                       , typeName:'integer'                 },
            //{name:'idlocal'                   , typeName:'integer'                 },
            {name:'muestra'                   , typeName:'integer' , nullable:false , default:1   , allow:{update:puedeEditar}},
            {name:'contacto'                  , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'telcontacto'               , typeName:'text'                    , allow:{update:puedeEditar}},

        ],
        primaryKey:['informante'],
        foreignKeys:[
            {references:'conjuntomuestral', fields:['conjuntomuestral']},
            {references:'rubros'          , fields:['rubro']           },
            {references:'muestras'        , fields:['muestra']         },
            {references:'tipoinf'         , fields:['tipoinformante']  },
        ]
    },context);
}