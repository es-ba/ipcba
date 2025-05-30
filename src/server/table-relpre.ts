"use strict";

import { Context, TableDefinition } from "backend-plus";

export const relpre = (context:Context):TableDefinition => {
    const puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    const puedeEditarRecep = context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    const puedeAgregarVisita = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion';
    const puedeVerNormalizado = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion';
    //console.log('Hola Mundo! ',puedeEditar);
    //console.log('Hola Mundo! ',context.user);
    return {
        name:'relpre',
        //title:'Relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false             , allow:{update:false}                   , inTable: true},
            {name:'producto'                     , typeName:'text'    , nullable:false             , allow:{update:false}                   , inTable: true},
            {name:'informante'                   , typeName:'integer' , nullable:false             , allow:{update:false}, title:'inf'      , inTable: true},
            {name:'formulario'                   , typeName:'integer' , nullable:false             , allow:{update:false}, title:'for'      , inTable: true},
            {name:'visita'                       , typeName:'integer' , nullable:false             , allow:{update:false}, title:'vis'      , inTable: true, defaultValue:1},
            {name:'observacion'                  , typeName:'integer' , nullable:false             , allow:{update:false}, title:'obs'      , inTable: true},
            {name:'precio'                       , typeName:'decimal' , allow:{update:puedeEditar} ,width:75,clientSide:'control_precio' , serverSide:true, inTable: true},
            {name:'tipoprecio'                   , typeName:'text'                                 , allow:{update:puedeEditar} ,title:'TP', postInput:'upperSpanish', clientSide:'ingreso_tipoprecio', serverSide:true , inTable: true},
            {name:'cambio'                       , typeName:'text'                                 , allow:{update:false}            , postInput:'upperSpanish', clientSide:'navegar_cambio'    , serverSide:true , inTable: true},
            {name:'repregunta'                   , typeName:'text'                                 , allow:{import:false, update:false}, title:'R', inTable: false},
            {name:'excluido'                     , typeName:'text'                                 , allow:{import:false, update:false}, title:'X', inTable: false},
            {name:'cantidadperiodossinprecio'    , typeName:'integer'                              , allow:{import:false, update:false}, title:'Cpsp', inTable: false},
            {name:'precioanterior'               , typeName:'decimal'                              , allow:{import:false, update:false}, inTable: false   },
            {name:'tipoprecioanterior'           , typeName:'text'                                 , allow:{import:false, update:false}, title:'TPa', inTable: false},
            {name:'masdatos'                     , typeName:'text'                                 , allow:{import:false, update:false}, inTable: false   },
            {name:'comentariosrelpre'            , typeName:'text'                                 , allow:{update:puedeEditar}        , inTable: true    },
            {name:'esvisiblecomentarioendm'      , typeName:'boolean'                              , allow:{update:puedeEditarRecep}, title:'Ver', visible:puedeEditarRecep, inTable: true},
            {name:'comentariosanterior'          , typeName:'text'                                 , allow:{import:false, update:false}, inTable: false   },
            {name:'precionormalizado'            , typeName:'decimal'                              , allow:{import:false, update:false}, visible: puedeVerNormalizado, inTable: true},
            {name:'especificacion'               , typeName:'integer'                              , visible:false, inTable: true                         },
            {name:'ultima_visita'                , typeName:'boolean'                              , inTable: true                          },
            {name:'observaciones'                , typeName:'text'                                 , visible:false, inTable: true                         },
            {name:'promobs_1'                    , typeName:'decimal'                              , width:75, visible:false, inTable: false},
            {name:'precionormalizado_1'          , typeName:'decimal'                              , width:75, visible:false, inTable: false},
            {name:'normsindato'                  , typeName:'text'                                 , visible:false          , inTable: false},
            {name:'fueraderango'                 , typeName:'text'                                 , visible:false          , inTable: false},
            {name:'sinpreciohace4meses'          , typeName:'text'                                 , visible:false          , inTable: false},
            {name:'orden'                        , typeName:'integer'                              , visible:false          , inTable: false},
            {name:'agregarvisita'                , typeName:'boolean'                              , allow:{select:puedeAgregarVisita, update:puedeAgregarVisita}, serverSide:true, inTable:false, clientSide:'agregar_visita'},
            {name:'modi_fec'                     , typeName:'timestamp'                            , visible:false, inTable: true                         },
            {name:'panel'                        , typeName:'integer'                              , inTable: false    },
            {name:'validar_pav_y_o'              , typeName:'boolean'                              , visible:false          , inTable: false},
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},
            {references:'tipopre', fields:['tipoprecio'], displayFields: ['espositivo']},
        ],
        sortColumns:[{column:'orden'},{column:'observacion'}],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita'], refreshParent: true},
            {table:'prodespecificacioncompleta', abr:'ESP', label:'especificacion', fields:['producto','observacion','formulario']},
            {table:'precios_maximos_minimos_resumen', abr:'PMM', label:'precios max min', fields:['periodo','producto']},
        ],
        sql:{
            fields:{
                validar_pav_y_o:{ expr: `(select coalesce(bool_or(validaropciones and validar_con_prodatrval), true) validar_pav_y_o from (
                select ra.*, pa.validaropciones , exists( select 1
                                    FROM prodatrval pav
                                    WHERE pav.producto = ra.producto and pav.atributo = ra.atributo and pav.valor = ra.valor) validar_con_prodatrval
                from relatr ra inner join prodatr pa on pa.producto = ra.producto and ra.atributo = pa.atributo
                where ra.periodo = relpre.periodo and ra.producto = relpre.producto and ra.observacion = relpre.observacion and ra.informante = relpre.informante and ra.visita = relpre.visita and pa.validaropciones) validar_pav_y_o_)`},
            },
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
                    case when r.ultima_visita is true then null else true end as agregarvisita, r.esvisiblecomentarioendm, r.modi_fec,
                    CASE WHEN distanciaperiodos(r.periodo,re.ultimoperiodoconprecio)-1>0 THEN distanciaperiodos(r.periodo,re.ultimoperiodoconprecio)-1
                    ELSE NULL
                    END cantidadperiodossinprecio, v.panel
                    from relpre r
                    inner join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
                    inner join forprod fp on r.producto = fp.producto and r.formulario = fp.formulario
                    left join relpre_1 r_1 on r.periodo=r_1.periodo and r.producto = r_1.producto and r.informante=r_1.informante and r.visita = r_1.visita and r.observacion = r_1.observacion
                    left join prerep p on r.periodo = p.periodo and r.producto = p.producto and r.informante = p.informante
                    left join (select cobs.* from calobs cobs join calculos_def cdef on cobs.calculo = cdef.calculo where cdef.principal) c on r.periodo = c.periodo and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion
                    left join calobs c_1 on r_1.periodo_1 = c_1.periodo and r.producto = c_1.producto and r.informante = c_1.informante and r.observacion = c_1.observacion and c_1.calculo = c.calculo
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as normsindato from control_normalizables_sindato) n on
                    r.periodo = n.periodo and r.informante = n.informante and r.observacion = n.observacion and r.visita = n.visita and r.producto = n.producto
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as fueraderango from control_atributos) a on
                    r.periodo = a.periodo and r.informante = a.informante and r.observacion = a.observacion and r.visita = a.visita and r.producto = a.producto
                    left join control_sinprecio s on r.periodo =s.periodo and r.informante = s.informante and r.visita = s.visita and r.observacion = s.observacion and r.producto = s.producto,
					lateral (select max(periodo) ultimoperiodoconprecio
                               from relpre
                               where precio is not null and r.informante = informante and r.producto = producto and r.observacion = observacion and r.visita = visita
                               and periodo < r.periodo
                            ) re
                    )`,
            isTable: true,
        },
        hiddenColumns:['panel', 'ultima_visita', 'tipopre__espositivo' ]
    };
}