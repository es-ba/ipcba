"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    var puedeEditarMigracion = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'informantes',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditar||puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion,
        },

        fields:[
            {name:'informante'                , typeName:'integer' , nullable:false, allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'nombreinformante'          , typeName:'text'    , isName:true   , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'estado'                    , typeName:'text'                    , allow:{update:puedeEditarMigracion}},
            {name:'tipoinformante'            , typeName:'text' , nullable:false, isName:true, title:'TI', allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'rubroclanae'               , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'cadena'                    , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'direccion'                 , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'altamanualperiodo'         , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'altamanualpanel'           , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'altamanualtarea'           , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'altamanualconfirmar'       , typeName:'timestamp'               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'razonsocial'               , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'nombrecalle'               , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'altura'                    , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'piso'                      , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'departamento'              , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'cuit'                      , typeName:'integer'                 , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'naecba'                    , typeName:'integer'                 , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'totalpers'                 , typeName:'integer'                 , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'cp'                        , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'distrito'                  , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'fraccion'                  , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'radio'                     , typeName:'integer'               , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'manzana'                   , typeName:'integer'               , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'lado'                      , typeName:'integer'               , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'obs_listador'              , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'nr_listador'               , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'fecha_listado'             , typeName:'date'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'grupo_listado'             , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'conjuntomuestral'          , typeName:'integer'                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'rubro'                     , typeName:'integer' , nullable:false               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'ordenhdr'                  , typeName:'integer' , nullable:false , default:100 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'cue'                       , typeName:'integer'               , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'idlocal'                   , typeName:'integer'               , allow:{update:puedeEditarMigracion}, visible:puedeEditarMigracion},
            {name:'muestra'                   , typeName:'integer' , nullable:false , default:1   , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'contacto'                  , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'telcontacto'               , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'modi_fec'                  , typeName:'timestamp'               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'barrio'                    , typeName:'text'                    , allow:{update:puedeEditar||puedeEditarMigracion}},
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