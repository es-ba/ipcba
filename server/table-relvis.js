"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin' || context.user.usu_rol ==='programador';
    return context.be.tableDefAdapt({
        name:'relvis',
        title:'Relvis',
        editable:true, //puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:true,
        },
        fields:[
            {name:'periodo'                   , typeName:'text'    , nullable:false            , allow:{update:false}               },
            {name:'informante'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'inf' /*, label:'informante'*/},
            {name:'visita'                    , typeName:'integer' , nullable:false , default:1, allow:{update:false}, title:'vis' /*, label:'visita'*/},
            {name:'formulario'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'for' /*, label:'formulario'*/},
            {name:'panel'                     , typeName:'integer' , nullable:false            , allow:{update:true}                },
            {name:'tarea'                     , typeName:'integer' , nullable:false            , allow:{update:true}                },
            {name:'fechasalida'               , typeName:'date'                                , allow:{update:true}, title:'salida' /*, label:'fecha salida'*/},
            {name:'fechaingreso'              , typeName:'date'                                , allow:{update:true}, title:'ingreso' /*, label:'fecha ingreso'*/},
            {name:'encuestador'               , typeName:'text'                                , allow:{update:true}, title:'enc' /*, label:'encuestador'*/},
            {name:'ingresador'                , typeName:'text'                                , allow:{update:true}, title:'ing' /*, label:'ingresador'*/},
            {name:'recepcionista'             , typeName:'text'                                , allow:{update:true}, title:'rec' /*, label:'recepcionista'*/},
            {name:'razon'                     , typeName:'integer'                             , allow:{update:true}, clientSide:'control_razones', serverSide:true},
            {name:'ultimavisita'              , typeName:'integer' , nullable:false , default:1, allow:{select:false}               },
            {name:'comentarios'               , typeName:'text'                                , allow:{update:true}                },
            {name:'supervisor'                , typeName:'text'                                , allow:{select:false}               },
            {name:'informantereemplazante'    , typeName:'integer'                             , allow:{select:false}               },
            {name:'ultima_visita'             , typeName:'boolean'                             , allow:{select:false}               },
            {name:'verificado_rec'            , typeName:'text'                                , allow:{update:true}                },
            {name:'orden'                     , typeName:'integer'                             , allow:{update:false}, visible:false},
            {name:'raz__escierredefinitivoinf', typeName:'text'                                , allow:{update:false}, visible:false},
            {name:'raz__escierredefinitivofor', typeName:'text'                                , allow:{update:false}, visible:false},
            {name:'direccion'                 , typeName:'text'                                , allow:{update:false}, visible:false},
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        sortColumns:[{column:'direccion'},{column:'orden'},{column:'visita'}],
        foreignKeys:[
            {references:'formularios', fields:['formulario']},
            {references:'informantes', fields:['informante']},
            {references:'periodos'   , fields:['periodo'   ]},
            {references:'relpan'     , fields:['periodo','panel']},            
            {references:'razones'    , fields:['razon']},            
            {references:'personal'   , fields:[{source:'encuestador'  , target:'persona'  }]},
            {references:'personal'   , fields:[{source:'ingresador'   , target:'persona'  }], alias:'pering'},
            //{references:'personal'   , fields:[{source:'recepcionista', target:'persona'  }], alias:'perrec'},
            //{references:'personal'   , fields:[{source:'supervisor'   , target:'persona'  }], alias:'persup'},
        ],
        softForeignKeys:[
            {references:'razones', fields:['razon'], displayFields:['escierredefinitivoinf','escierredefinitivofor'], alias:'raz'},
        ],
        detailTables:[
            {table:'relpre', abr:'PRE', label:'precios', fields:['periodo','informante','visita','formulario']},
            {wScreen:'controles_formulario', abr:'C', label:'controles', fields:['periodo','informante','visita','formulario']},
            /*
            {table:'control_normalizables_sindato', abr:'NSD', label:'normalizables sin dato', fields:['periodo','informante','visita','formulario']},
            {table:'control_atributos', abr:'AFR', label:'atributos fuera de rango', fields:['periodo','informante','visita','formulario']},
            {table:'hdrexportarefectivossinprecio', abr:'ESP', label:'efectivos sin precio', fields:['periodo','informante','visita','formulario']},
            {table:'control_rangos', abr:'RAN', label:'Control de rangos de precios', fields:['periodo','informante','visita','formulario']},
            {table:'controlvigencias', abr:'VIG', label:'Control de atributo vigencia', fields:['periodo','informante']},
            */
        ],
        sql:{
            from:`(
                select v.periodo, v.informante, v.visita, v.formulario, v.panel, v.tarea, v.fechasalida, v.fechaingreso, v.encuestador, v.ingresador, 
                  v.recepcionista, v.razon, v.ultimavisita, v.comentarios, v.supervisor, v.informantereemplazante, v.ultima_visita, v.verificado_rec,
                  f.orden, i.direccion                  
                  from relvis v
                  join informantes i on v.informante = i.informante
                  left join formularios f on v.formulario=f.formulario
                  )`,
        }        
    },context);
}