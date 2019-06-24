"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
    	name:'migra_relatr',
        title:'Relatr',
        tableName:'relatr',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'producto'                         , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'observacion'                      , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'informante'                       , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'atributo'                         , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'valor'                            , typeName:'text'    , allow:{update:puedeEditar}, clientSide:'control_rangos' , serverSide:true, postInput:'upperSpanish'},
            {name:'visita'                           , typeName:'integer' , nullable:false , default:1, allow:{update:puedeEditar}},
            {name:'validar_con_valvalatr'            , typeName:'boolean'                             , allow:{update:puedeEditar}                   },
		],
        primaryKey:['periodo','producto','observacion','informante','visita', 'atributo'],
        foreignKeys:[
            {references:'atributos', fields:['atributo'], displayFields:['nombreatributo','tipodato']},
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relpre', fields:['periodo', 'producto', 'observacion', 'informante', 'visita']},
        ],
        //softForeignKeys:[
        //    {references:'prodatr', fields:['producto','atributo'], displayFields:['rangodesde','rangohasta','orden', 'valornormal']},
        //],
        detailTables:[
            {table:'relatr_tipico', abr:'Valores Típicos', fields:['periodo','producto','atributo'], abr:'V'}
        ],
    },context);
}