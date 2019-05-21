"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin' || context.user.usu_rol ==='programador';
    return context.be.tableDefAdapt({
        name:'periodos',
        elementName:'periodo',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false                      },
            {name:'ano'                         , typeName:'integer' , nullable:false                      },
            {name:'mes'                         , typeName:'integer' , nullable:false                      },
            {name:'visita'                      , typeName:'integer' , nullable:false, allow:{select:false}},
            {name:'ingresando'                  , typeName:'text'                                          },
            {name: "generar"                    , typeName: "bigint"  , editable:false, clientSide:'generarPeriodo'},
            {name:'periodoanterior'             , typeName:'text'                    , visible: false},
            {name:'fechageneracionperiodo'      , typeName:'timestamp'                      },                
            {name:'comentariosper'              , typeName:'text'                    , allow:{select:false}},
            {name:'fechacalculoprereplote1'     , typeName:'timestamp'    , allow:{select:false}},
            {name:'fechacalculoprereplote2'     , typeName:'timestamp'    , allow:{select:false}},
            {name:'fecha_cierre_ingreso'        , typeName:'timestamp'    , allow:{select:false}},
            {name:'cerraringresocampohastapanel', typeName:'integer' , nullable:false, allow:{select:false}},
            {name:'habilitado'                  , typeName:'text'                                          },
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