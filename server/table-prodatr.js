"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'prodatr',
        //title:'Prodatr',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditarMigracion,
            delete:false,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'producto'                  , typeName:'text'    , nullable:false               , allow:{update:puedeEditarMigracion}},
            {name:'atributo'                  , typeName:'integer' , nullable:false               , allow:{update:puedeEditarMigracion}},
            {name:'valornormal'               , typeName:'decimal'                                , allow:{update:puedeEditarMigracion}},
            {name:'orden'                     , typeName:'integer' , nullable:false               , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'normalizable'              , typeName:'text'    , default:'N', defaultValue:'N', allow:{update:puedeEditarMigracion}},
            {name:'tiponormalizacion'         , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'alterable'                 , typeName:'text'    , default:'N', defaultValue:'N', allow:{update:puedeEditarMigracion}},
            {name:'prioridad'                 , typeName:'integer'                                , allow:{update:puedeEditarMigracion}},
            {name:'operacion'                 , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'rangodesde'                , typeName:'decimal'                                , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'rangohasta'                , typeName:'decimal'                                , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'orden_calculo_especial'    , typeName:'integer'                                , allow:{update:puedeEditarMigracion}},
            {name:'tipo_promedio'             , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'esprincipal'               , typeName:'text'    , default:'N', defaultValue:'N', allow:{update:puedeEditarMigracion}},
            {name:'tipodato'                  , typeName:'text'    , nullable:false               , allow:{update:puedeEditarMigracion}},
            {name:'abratributo'               , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'escantidad'                , typeName:'text'    , default:'N', defaultValue:'N', allow:{update:puedeEditarMigracion}},
            {name:'unidaddemedida'            , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'es_vigencia'               , typeName:'boolean'                                , allow:{update:puedeEditarMigracion}},
            {name:'valorinicial'              , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'visiblenombreatributo'     , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'otraunidaddemedida'        , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
            {name:'opciones'                  , typeName:'text'                                   , allow:{update:puedeEditarMigracion}},
        ],
        primaryKey:['producto','atributo'],
        foreignKeys:[
            {references:'atributos', fields:['atributo']},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from:`(select p.producto, p.atributo, p.valornormal, p.orden, p.normalizable, p.tiponormalizacion, 
		           p.alterable, p.prioridad, p.operacion, p.rangodesde, p.rangohasta, p.orden_calculo_especial, p.tipo_promedio, p.esprincipal,
		           a.tipodato, a.abratributo, a.escantidad, a.unidaddemedida, a.es_vigencia, a.valorinicial, p.opciones, p.visiblenombreatributo, p.otraunidaddemedida 
                   from prodatr p left join atributos a on p.atributo = a.atributo
                )`
        }       
    },context);
}