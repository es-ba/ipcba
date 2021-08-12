"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='supervisor';
    var puedeEditarToken = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador'
    return context.be.tableDefAdapt({
        name:'relvis',
        title:'Relvis',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                   , typeName:'text'    , nullable:false            , allow:{update:false}               },
            {name:'informante'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'inf'  },
            {name:'visita'                    , typeName:'integer' , nullable:false , default:1, allow:{update:false}, title:'vis'  },
            {name:'formulario'                , typeName:'integer' , nullable:false            , allow:{update:false}, title:'for'  },
            {name:'panel'                     , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
            {name:'tarea'                     , typeName:'integer' , nullable:false            , allow:{update:puedeEditar}                 },
            {name:'fechasalida'               , typeName:'date'                                , allow:{update:puedeEditar}, title:'salida' },
            {name:'fechaingreso'              , typeName:'date'                                , allow:{update:puedeEditar}, title:'ingreso'},
            {name:'encuestador'               , typeName:'text'                                , allow:{update:puedeEditar}, title:'enc'    },
            {name:'ingresador'                , typeName:'text'                                , allow:{update:puedeEditar}, title:'ing'    },
            {name:'recepcionista'             , typeName:'text'                                , allow:{update:puedeEditar}, title:'rec'    },
            {name:'razon'                     , typeName:'integer'                             , allow:{update:puedeEditar}, clientSide:'control_razones', serverSide:true, inTable:true},
            {name:'ultimavisita'              , typeName:'integer' , nullable:false , default:1, allow:{update:false}, visible:false},
            {name:'codcomentarios'            , typeName:'text'                                , allow:{update:puedeEditar}, title:'cod', postInput:'upperSpanish'  },
            {name:'comentarios'               , typeName:'text'                                , allow:{update:puedeEditar}                 },
            {name:'supervisor'                , typeName:'text'                                , allow:{update:false}, visible:false},
            {name:'informantereemplazante'    , typeName:'integer'                             , allow:{update:false}, visible:false},
            {name:'ultima_visita'             , typeName:'boolean'                             , allow:{update:false}, visible:false},
            {name:'verificado_rec'            , typeName:'text'                                , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'fechageneracion'           , typeName:'timestamp'                           , allow:{update:false}, visible:false},
            {name:'preciosgenerados'          , typeName:'boolean'                             , allow:{update:false}, visible:false},
            {name:'orden'                     , typeName:'integer'                             , allow:{update:false}, visible:false, inTable:false},
            {name:'raz__escierredefinitivoinf', typeName:'text'                                , allow:{update:false}, visible:false, inTable:false},
            {name:'raz__escierredefinitivofor', typeName:'text'                                , allow:{update:false}, visible:false, inTable:false},
            {name:'direccion'                 , typeName:'text'                                , allow:{update:false}, visible:false, inTable:false},
            {name:'operadorrec'               , typeName:'text'                                , allow:{update:false}, visible:false, inTable:false},
            {name:'token_relevamiento'        , typeName:'text'                                , allow:{update:puedeEditarToken}                   },
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
            {references:'personal'   , fields:[{source:'recepcionista', target:'persona'  }], alias:'perrec'},
            {references:'tokens'     , fields:[{source:'token_relevamiento', target:'token'  }]},
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
                  v.fechageneracion, f.orden, i.direccion, v.preciosgenerados, v.token_relevamiento,
                  CASE WHEN rec.labor = 'R' THEN rec.persona 
                       WHEN per.labor = 'R' THEN per.persona 
                       ELSE rec.persona END operadorrec, v.codcomentarios
                  from relvis v
                  join informantes i on v.informante = i.informante
                  left join formularios f on v.formulario=f.formulario
                  left join personal rec on rec.username = '`+ context.user.usu_usu +`' and rec.activo = 'S'
                  left join personal per on ((rec.apellido = per.apellido and rec.nombre = per.nombre) or per.username = '`+ context.user.usu_usu +`')  
                  and per.activo = 'S' and rec.persona is distinct from per.persona
                  )`,
            isTable:true,
                }        
    },context);
}