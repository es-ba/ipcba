"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'hdrexportarcierretemporal',
        tableName:'relpantarinf',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'   },
            {name:'panel'                        , typeName:'integer'},
            {name:'tarea'                        , typeName:'integer'},
            {name:'fechasalida'                  , typeName:'date'   },
            {name:'informante'                   , typeName:'integer'},
            {name:'encuestador'                  , typeName:'text'   },
            {name:'nombreencuestador'            , typeName:'text'   },
            {name:'recepcionista'                , typeName:'text'   },
            {name:'nombrerecepcionista'          , typeName:'text'   },
            {name:'razon'                        , typeName:'text'   },
            {name:'visita'                       , typeName:'integer'},
            {name:'nombreinformante'             , typeName:'text'   },
            {name:'direccion'                    , typeName:'text'   },
            {name:'formularios'                  , typeName:'text'   },
            {name:'contacto'                     , typeName:'text'   },
            {name:'telcontacto'                  , typeName:'text'   },
            {name:'web'                          , typeName:'text'   },
            {name:'email'                        , typeName:'text'   },
            {name:'conjuntomuestral'             , typeName:'integer', visible:false},
            {name:'ordenhdr'                     , typeName:'integer', visible:false},
            {name:'distrito'                     , typeName:'integer', visible:false},
            {name:'fraccion_ant'                 , typeName:'integer', visible:false},
            {name:'comuna'                       , typeName:'integer', visible:false},
            {name:'fraccion'                     , typeName:'integer', visible:false},
            {name:'radio'                        , typeName:'integer', visible:false},
            {name:'manzana'                      , typeName:'integer', visible:false},
            {name:'depto'                        , typeName:'integer', visible:false},
            {name:'barrio'                       , typeName:'integer', visible:false},
            {name:'rubro'                        , typeName:'integer'},
            {name:'nombrerubro'                  , typeName:'text'   },
            {name:'maxperiodoinformado'          , typeName:'text'   },
            {name:'codobservaciones'             , typeName:'text', allow:{update:false}, title:'cod'},
            {name:'observaciones'                , typeName:'text', allow:{update:false}},
            {name:'observaciones_campo'          , typeName:'text', allow:{update:false}},
            {name:'fechasalidahasta'             , typeName:'date', allow:{update:false}},
            {name:'modalidad'                    , typeName:'text', allow:{update:false}},
            {name:'modalidad_ant'                , typeName:'text', allow:{update:false}},
            {name:'recuperos'                    , typeName:'text', allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','informante','visita','panel','tarea'],
        sql:{
            from:`(select r.periodo, r.informante, r.visita, r.fechasalidahasta, r.observaciones, r.codobservaciones, r.panel, r.tarea, h.fechasalida, h.encuestador, h.nombreencuestador, h.recepcionista, 
                    h.nombrerecepcionista, h.razon, h.nombreinformante, h.direccion, h.formularios, h.contacto, h.conjuntomuestral, h.ordenhdr, h.distrito, h.fraccion_ant, 
                    h.comuna, h.fraccion, h.radio, h.manzana, h.depto, h.barrio, h.rubro, h.nombrerubro, h.maxperiodoinformado, h.observaciones_campo, h.modalidad, h.modalidad_ant, 
                    h.telcontacto, h.web, h.email, r.recuperos                
                    from relpantarinf r 
                    join hdrexportarcierretemporal h on r.periodo= h.periodo and r.informante = h.informante and r.visita = h.visita and r.panel = h.panel and r.tarea = h.tarea
                )`
            },
        },context);
}