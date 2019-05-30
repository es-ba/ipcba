"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'productos',
        //title:'Productos',
        allow:{
            insert:puedeEditarMigracion,
            delete:puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },        
        fields:[
            {name:'producto'                    , typeName:'text' , nullable:false                                         },
            {name:'nombreproducto'              , typeName:'text' , isName:true                      , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'formula'                     , typeName:'text' , nullable:false, default:'General',defaultValue:'General', allow:{select:puedeEditarMigracion}},
            {name:'estacional'                  , typeName:'text' , nullable:false, default:'N',defaultValue:'N'      , allow:{select:puedeEditarMigracion}},
            {name:'imputacon'                   , typeName:'text'                                    , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'cantperaltaauto'             , typeName:'integer'                                 , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'cantperbajaauto'             , typeName:'integer'                                 , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'unidadmedidaporunidcons'     , typeName:'text'                                    , allow:{update:puedeEditarMigracion}},
            {name:'esexternohabitual'           , typeName:'text'                                    , allow:{update:puedeEditarMigracion}},
            {name:'tipocalculo'                 , typeName:'text' , nullable:false, default:'D', defaultValue:'D'      , allow:{select:puedeEditarMigracion}},
            {name:'cantobs'                     , typeName:'integer'                                 , allow:{update:puedeEditarMigracion}},
            {name:'unidadmedidaabreviada'       , typeName:'text'                                    , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'codigo_ccba'                 , typeName:'text'                                    , allow:{select:puedeEditarMigracion}},
            {name:'porc_adv_inf'                , typeName:'decimal'                                 , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'porc_adv_sup'                , typeName:'decimal'                                 , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'tipoexterno'                 , typeName:'text'                                    , allow:{update:puedeEditar||puedeEditarMigracion} },
            {name:'nombreparaformulario'        , typeName:'text'                                    , allow:{select:puedeEditarMigracion}},
            {name:'serepregunta'                , typeName:'boolean'                                 , allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'nombreparapublicar'          , typeName:'text'                                    , allow:{update:puedeEditarMigracion}},
            {name:'calculo_desvios'             , typeName:'text', default:'N', defaultValue:'N'     , allow:{update:puedeEditarMigracion}},
            {name:'compatible'                  , typeName:'boolean'                                 , allow:{update:false}},
         ],
		primaryKey:['producto'],
        foreignKeys:[
            {references:'unidades', fields:[
                {source:'unidadmedidaporunidcons'    , target:'unidad'   },
            ]},
        ],
		detailTables:[
            {table:'especificaciones', abr:'ESP', label:'especificaciones', fields:['producto']},
            {table:'prodatr', abr:'ATR', label:'atributos', fields:['producto']},
            {table:'proddiv', abr:'DIV', label:'Divisiones', fields:['producto']},
            {table:'forprod', abr:'FOR', label:'Formularios', fields:['producto']},
            {table:'prodcontrolrangos', abr:'CTRL', label:'Contol Rangos', fields:['producto']},
        ],
        sql:{
            from:`(select p.*, 
                CASE WHEN unidadmedidaabreviada is not null then cvp.validar_unidadmedidaabreviada(producto) else null end as compatible
                   FROM productos p
                )`
        }
    },context);
}