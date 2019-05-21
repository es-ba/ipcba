"use strict";

module.exports = function(context){
    
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpre_control_rangos_analisis',
        tableName: 'relpre',
        title:'control de inconsistencias de precios análisis',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false             , allow:{update:false}                             },
            {name:'producto'               , typeName:'text'    , nullable:false             , allow:{update:false}                             },
            {name:'informante'             , typeName:'integer' , nullable:false             , allow:{update:false}                             },
            {name:'observacion'            , typeName:'integer' , nullable:false             , allow:{update:false}                             },
            {name:'visita'                 , typeName:'integer' , nullable:false , default:1 , allow:{update:false}                             },
            {name:'panel'                  , typeName:'integer' , nullable:false             , allow:{update:false}                             },
            {name:'tarea'                  , typeName:'integer' , nullable:false             , allow:{update:false}                             },
            {name:'precionormalizadored'   , typeName:'decimal'                              , allow:{update:false}                             },
            {name:'tipoprecio'             , typeName:'text'                                 , allow:{update:false}                 ,title:'TP' },
            {name:'cambio'                 , typeName:'text'                                 , allow:{update:false}                             },
            {name:'repregunta'             , typeName:'text'                                 , allow:{update:false}                             },
            {name:'precioant'              , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
            {name:'tipoprecioant'          , typeName:'text'                                 , allow:{update:false}                             },
            {name:'antiguedadsinprecioant' , typeName:'integer'                              , allow:{update:false}                             },
            {name:'variac'                 , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
            {name:'comentariosrelpre'      , typeName:'text'                                 , allow:{update:puedeEditar}                       },
            {name:'observaciones'          , typeName:'text'                                 , allow:{update:puedeEditar}                       },
            {name:'promvar'                , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
            {name:'desvvar'                , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
            {name:'promrotativo'           , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
            {name:'desvprot'               , typeName:'decimal'                              , allow:{update:false}        ,width:75            },
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:[
                {source:'informante'         , target:'informante'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
            {references:'relvis', fields:[
                {source:'periodo'      , target:'periodo'         },
                {source:'informante'   , target:'informante'      },
                {source:'visita'       , target:'visita'          },
                {source:'formulario'   , target:'formulario'      },
            ]},            
            {references:'tipopre', fields:[
                {source:'tipoprecio'                  , target:'tipoprecio'  },
            ]},            
        ],
        detailTables:[
            //{table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita']},
        ],
       sql:{
            from: `(SELECT cr.periodo, cr.producto, cr.informante, rp.formulario, rp.tipoprecio, rp.cambio, rp.comentariosrelpre, cr.observacion, cr.repregunta, round(cr.precioant::decimal,2) precioant, cr.panel, cr.tarea, cr.visita, cr.tipoprecioant, cr.antiguedadsinprecioant, round(cr.variac::decimal,2) variac, round(cr.precionormalizado::decimal,2) precionormalizadored, round(cr.promvar::decimal,2) promvar, round(cr.desvvar::decimal,2) desvvar, round(cr.promrotativo::decimal,2) promrotativo, round(cr.desvprot::decimal,2) desvprot, rp.observaciones
            FROM relpre rp join control_rangos cr on rp.periodo = cr.periodo and rp.producto = cr.producto and rp.observacion = cr.observacion and rp.informante = cr.informante and rp.visita = cr.visita)`,
        }    
    },context);
}