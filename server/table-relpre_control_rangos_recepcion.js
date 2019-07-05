"use strict";

module.exports = function(context){
    
    var esRecepcionista = context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='coordinador';
    var esAnalista = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpre_control_rangos_recepcion',
        tableName:'relpre',
        title:'control de inconsistencias de precios',
        editable:esAnalista||esRecepcionista,
        allow:{
            insert:false,
            delete:false,
            update:esAnalista||esRecepcionista,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false             , allow:{update:false}                              },
            {name:'producto'               , typeName:'text'    , nullable:false             , allow:{update:false}                              },
            {name:'informante'             , typeName:'integer' , nullable:false             , allow:{update:false}                              },
            {name:'observacion'            , typeName:'integer' , nullable:false             , allow:{update:false}                              },
            {name:'visita'                 , typeName:'integer' , nullable:false , default:1 , allow:{update:false}                              },
            {name:'panel'                  , typeName:'integer' , nullable:false             , allow:{update:false}                              },
            {name:'tarea'                  , typeName:'integer' , nullable:false             , allow:{update:false}                              },
            {name:'encuestador'            , typeName:'text'                                 , allow:{update:false}, visible:esRecepcionista     },
            {name:'recepcionista'          , typeName:'text'                                 , allow:{update:false}, visible:esRecepcionista     },
            {name:'formulario'             , typeName:'integer' , nullable:false             , allow:{update:false}, visible:esRecepcionista     },  
            {name:'precionormalizadored'   , typeName:'decimal'                              , allow:{update:false}                              },
            {name:'precio'                 , typeName:'decimal'                              , allow:{update:esRecepcionista||esAnalista}                          },
            {name:'tipoprecio'             , typeName:'text'                                 , allow:{update:esRecepcionista||esAnalista}, title:'TP'              },
            {name:'cambio'                 , typeName:'text'                                 , allow:{update:esRecepcionista||esAnalista}, postInput:'upperSpanish'},
            {name:'repregunta'             , typeName:'text'                                 , allow:{update:false}                              },
            {name:'precioant'              , typeName:'decimal'                              , allow:{update:false}, width:75                    },
            {name:'tipoprecioant'          , typeName:'text'                                 , allow:{update:false}                              },
            {name:'antiguedadsinprecioant' , typeName:'integer'                              , allow:{update:false}                              },
            {name:'variac'                 , typeName:'decimal'                              , allow:{update:false}, width:75                    },
            {name:'comentariosrelpre'      , typeName:'text'                                 , allow:{update:esRecepcionista}                    },
            {name:'observaciones'          , typeName:'text'                                 , allow:{update:esAnalista}                         },
            {name:'promvar'                , typeName:'decimal'                              , allow:{update:false}, width:75 ,visible:esAnalista},
            {name:'desvvar'                , typeName:'decimal'                              , allow:{update:false}, width:75 ,visible:esAnalista},
            {name:'promrotativo'           , typeName:'decimal'                              , allow:{update:false}, width:75 ,visible:esAnalista},
            {name:'desvprot'               , typeName:'decimal'                              , allow:{update:false}, width:75 ,visible:esAnalista},
            //{name:'atrnormalizables'       , typeName:'text'                                 , allow:{update:false}                              },
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos'   , fields:['periodo']},
            {references:'productos'  , fields:['producto']},
            {references:'relvis'     , fields:['periodo', 'informante', 'visita', 'formulario']},            
            {references:'tipopre'    , fields:['tipoprecio']},            
        ],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita']},
        ],
        sql:{
            from: `(SELECT cr.periodo, cr.producto, cr.informante, rp.formulario, rp.precio, rp.tipoprecio, rp.cambio, rp.comentariosrelpre, 
                    cr.observacion, cr.repregunta, round(cr.precioant::decimal,2) precioant, cr.panel, cr.encuestador, cr.recepcionista, 
                    cr.tarea, cr.visita, cr.tipoprecioant, cr.antiguedadsinprecioant, round(cr.variac::decimal,2) variac, 
                    round(cr.precionormalizado::decimal,2) precionormalizadored, round(cr.promvar::decimal,2) promvar,
                    round(cr.desvvar::decimal,2) desvvar, round(cr.promrotativo::decimal,2) promrotativo, round(cr.desvprot::decimal,2) desvprot, 
                    rp.observaciones /*, ra.atrnormalizables*/
                    FROM relpre rp join control_rangos cr on rp.periodo = cr.periodo and rp.producto = cr.producto and 
                                rp.observacion = cr.observacion and rp.informante = cr.informante and rp.visita = cr.visita
                         /*left join (select r.periodo, r.informante, r.producto, r.visita, r.observacion, 
                                    string_agg(a.nombreatributo||'('||a.unidaddemedida||')'||':'||r.valor, '; ') atrnormalizables
                                    from relatr r
                                    left join prodatr pa on r.producto = pa.producto and r.atributo = pa.atributo 
                                    left join atributos a on pa.atributo = a.atributo
                                    where pa.normalizable = 'S' 
                                    group by r.periodo, r.informante, r.producto, r.visita, r.observacion) ra
                         on cr.periodo = ra.periodo and  cr.informante = ra.informante and  cr.producto = ra.producto and
                         cr.visita = ra.visita and  cr.observacion = ra.observacion*/
					WHERE not(upper(rp.observaciones) like '%OK%') or rp.observaciones is null)`,
        }    
    },context);
}