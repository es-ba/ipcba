"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    var puedeEditarMigracion = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'periodos',
        elementName:'periodo',
        editable:puedeEditar||puedeEditarMigracion,
        allow:{
            insert:puedeEditar||puedeEditarMigracion,
            delete:puedeEditarMigracion,
            update:puedeEditar||puedeEditarMigracion,
        },
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false, allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'ano'                         , typeName:'integer' , nullable:false, allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'mes'                         , typeName:'integer' , nullable:false, allow:{update:puedeEditar||puedeEditarMigracion}},
            {name:'visita'                      , typeName:'integer' , default:1, defaultValue:1, nullable:false, allow:{select:puedeEditarMigracion}},
            {name:'ingresando'                  , typeName:'text'    , default:'S', defaultValue:'S', allow:{update:puedeEditar||puedeEditarMigracion}},
            {name: "generar"                    , typeName: "bigint" , editable:false, clientSide:'generarPeriodo'},
            {name:'periodoanterior'             , typeName:'text'                    , visible: puedeEditarMigracion},
            {name:'fechageneracionperiodo'      , typeName:'timestamp'                      },                
            {name:'comentariosper'              , typeName:'text'                    , allow:{select:puedeEditarMigracion}},
            {name:'fechacalculoprereplote1'     , typeName:'timestamp'    , allow:{select:puedeEditarMigracion}},
            {name:'fechacalculoprereplote2'     , typeName:'timestamp'    , allow:{select:puedeEditarMigracion}},
            {name:'fecha_cierre_ingreso'        , typeName:'timestamp'    , allow:{select:puedeEditarMigracion}},
            {name:'cerraringresocampohastapanel', typeName:'integer' , nullable:false, default:0, defaultValue:0, allow:{select:puedeEditarMigracion}},
            {name:'habilitado'                  , typeName:'text', default:'S', defaultValue:'S', allow:{update:puedeEditar||puedeEditarMigracion}},
        ],
        primaryKey:['periodo'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'periodoanterior', target:'periodo'}
            ], alias: 'per'},
        ],
        sortColumns:[{column:'periodo', order:-1}],
        detailTables:[
            {table:'relpan', abr:'PAN', label:'paneles', fields:['periodo']},
        ]
    },context);
}