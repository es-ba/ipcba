"use strict";

module.exports = function(context){
    
    var esRecepcionista = context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='coordinador';
    var esAnalista = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpre_control_rangos',
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
            {name:'encuestador'            , typeName:'text'                                 , allow:{update:false}, visible:esRecepcionista||esAnalista},
            {name:'recepcionista'          , typeName:'text'                                 , allow:{update:false}, visible:esRecepcionista||esAnalista},
            {name:'formulario'             , typeName:'integer' , nullable:false             , allow:{update:false}, visible:esRecepcionista||esAnalista},  
            {name:'precionormalizadored'   , typeName:'decimal'                              , allow:{update:false}                              },
            {name:'tipoprecio'             , typeName:'text'                                 , allow:{update:false}, title:'TP'                  },
            {name:'cambio'                 , typeName:'text'                                 , allow:{update:false}                              },
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
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos'   , fields:['periodo']},
            {references:'productos'  , fields:['producto']},
            {references:'relvis'     , fields:['periodo', 'informante', 'visita', 'formulario']},            
            {references:'tipopre'    , fields:['tipoprecio']},            
        ],
        sql:{
            from: `(SELECT cr.periodo, cr.producto, cr.informante, rp.formulario, rp.tipoprecio, rp.cambio, rp.comentariosrelpre, 
                    cr.observacion, cr.repregunta, round(cr.precioant::decimal,2) precioant, cr.panel, cr.encuestador, cr.recepcionista, 
                    cr.tarea, cr.visita, cr.tipoprecioant, cr.antiguedadsinprecioant, round(cr.variac::decimal,2) variac, 
                    round(cr.precionormalizado::decimal,2) precionormalizadored, round(cr.promvar::decimal,2) promvar,
                    round(cr.desvvar::decimal,2) desvvar, round(cr.promrotativo::decimal,2) promrotativo, round(cr.desvprot::decimal,2) desvprot, 
                    rp.observaciones
                    FROM relpre rp join control_rangos cr on rp.periodo = cr.periodo and rp.producto = cr.producto and 
                                rp.observacion = cr.observacion and rp.informante = cr.informante and rp.visita = cr.visita)`,
        }    
    },context);
}