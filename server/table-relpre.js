"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete';
    //console.log('Hola Mundo! ',puedeEditar);
    //console.log('Hola Mundo! ',context.user);
    return context.be.tableDefAdapt({
        name:'relpre',
        //title:'Relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false             , allow:{update:false}                   },
            {name:'producto'                     , typeName:'text'    , nullable:false             , allow:{update:false}                   },
            {name:'informante'                   , typeName:'integer' , nullable:false             , allow:{update:false}, title:'inf'      },
            {name:'formulario'                   , typeName:'integer' , nullable:false             , allow:{update:false}, title:'for'      },
            {name:'visita'                       , typeName:'integer' , nullable:false , default:1 , allow:{update:false}, title:'vis'      },
            {name:'observacion'                  , typeName:'integer' , nullable:false             , allow:{update:false}, title:'obs'      },
            {name:'precio'                       , typeName:'decimal' , allow:{update:puedeEditar} ,width:75,clientSide:'control_precio' , serverSide:true},
            {name:'tipoprecio'                   , typeName:'text'                                 , allow:{update:puedeEditar} ,title:'TP', postInput:'upperSpanish', clientSide:'ingreso_tipoprecio', serverSide:true },
            {name:'cambio'                       , typeName:'text'                                 , allow:{update:puedeEditar}            , postInput:'upperSpanish', clientSide:'navegar_cambio'    , serverSide:true },            
            {name:'repregunta'                   , typeName:'text'                                 , allow:{import:false, update:false}, title:'R'        },            
            {name:'excluido'                     , typeName:'text'                                 , allow:{import:false, update:false}, title:'X'        },            
            {name:'antiguedadsinprecioant'       , typeName:'integer'                              , allow:{import:false, update:false}, title:'Aspa'     },            
            {name:'precioanterior'               , typeName:'decimal'                              , allow:{import:false, update:false}                   },
            {name:'tipoprecioanterior'           , typeName:'text'                                 , allow:{import:false, update:false}, title:'TPa'      },
            {name:'masdatos'                     , typeName:'text'                                 , allow:{import:false, update:false}                   },
            {name:'comentariosrelpre'            , typeName:'text'                                 , allow:{update:puedeEditar}             },
            {name:'comentariosanterior'          , typeName:'text'                                 , allow:{import:false, update:false}                   },
            {name:'precionormalizado'            , typeName:'decimal'                              , allow:{import:false, update:false}, visible:false    },
            {name:'especificacion'               , typeName:'integer'                              , visible:false                          },
            {name:'ultima_visita'                , typeName:'boolean'                                                                       },
            {name:'observaciones'                , typeName:'text'                                 , visible:false                          },
            {name:'promobs_1'                    , typeName:'decimal'                              , width:75, visible:false                },
            {name:'precionormalizado_1'          , typeName:'decimal'                              , width:75, visible:false                },
            {name:'normsindato'                  , typeName:'text'                                 , visible:false                          },
            {name:'fueraderango'                 , typeName:'text'                                 , visible:false                          },
            {name:'sinpreciohace4meses'          , typeName:'text'                                 , visible:false                          },
            {name:'orden'                        , typeName:'integer'                              , visible:false                          },
            {name:'agregarvisita'                , typeName:'boolean'                              , allow:{update:puedeEditar}, serverSide:true, inTable:false, clientSide:'agregar_visita'},
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},            
            {references:'tipopre', fields:['tipoprecio']},            
        ],
        sortColumns:[{column:'orden'},{column:'observacion'}],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita']},
        ],
        sql:{
            from:`(select r.periodo, r.producto, r.informante, r.formulario, r.visita, r.observacion, r.precio, r.tipoprecio, r.cambio, 
                    CASE WHEN p.periodo is not null THEN 'R' ELSE null END as repregunta,
                    CASE WHEN c.antiguedadexcluido>0 and r.precio>0 THEN 'x' ELSE null END as excluido, r_1.precio_1 as precioanterior, 
                    r_1.tipoprecio_1 as tipoprecioanterior, r.comentariosrelpre, r.precionormalizado, r.especificacion, r.ultima_visita, r.observaciones,
                    r_1.comentariosrelpre_1 as comentariosanterior,                  
                    CASE WHEN r_1.precio_1 > 0 and r_1.precio_1 <> r.precio THEN round((r.precio/r_1.precio_1*100-100)::decimal,1)::TEXT||'%' 
                        ELSE CASE WHEN c_1.promobs > 0 and c_1.promobs <> r.precionormalizado and r_1.precio_1 is null THEN round((r.precionormalizado/c_1.promobs*100-100)::decimal,1)::TEXT||'%' 
                                ELSE NULL 
                                END 
                        END AS masdatos,
                    c_1.antiguedadsinprecio as antiguedadsinprecioant, c_1.promobs as promobs_1, r_1.precionormalizado_1, normsindato, fueraderango,
                    CASE WHEN s.periodo is not null THEN 'S' ELSE null END as sinpreciohace4meses, fp.orden,
                    case when r.ultima_visita is true then null else true end as agregarvisita
                    from relpre r
                    inner join forprod fp on r.producto = fp.producto and r.formulario = fp.formulario
                    left join relpre_1 r_1 on r.periodo=r_1.periodo and r.producto = r_1.producto and r.informante=r_1.informante and r.visita = r_1.visita and r.observacion = r_1.observacion
                    left join prerep p on r.periodo = p.periodo and r.producto = p.producto and r.informante = p.informante
                    left join calobs c on r.periodo = c.periodo and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion and c.calculo = 0
                    left join calobs c_1 on r_1.periodo_1 = c_1.periodo and r.producto = c_1.producto and r.informante = c_1.informante and r.observacion = c_1.observacion and c_1.calculo = 0
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as normsindato from control_normalizables_sindato) n on
                    r.periodo = n.periodo and r.informante = n.informante and r.observacion = n.observacion and r.visita = n.visita and r.producto = n.producto                    
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as fueraderango from control_atributos) a on
                    r.periodo = a.periodo and r.informante = a.informante and r.observacion = a.observacion and r.visita = a.visita and r.producto = a.producto
                    left join control_sinprecio s on r.periodo =s.periodo and r.informante = s.informante and r.visita = s.visita and r.observacion = s.observacion and r.producto = s.producto
                    )`,
        },
        hiddenColumns:['agregarvisita','ultima_visita']
    },context);
}