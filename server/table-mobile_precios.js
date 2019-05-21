"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo';
    return context.be.tableDefAdapt({
        name:'mobile_precios',
        title:'precios',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'          , typeName:'text'    , editable:false     , visible:false    },
            {name:'formulario'       , typeName:'integer' , editable:false     , visible:false    },
            {name:'producto'         , typeName:'text'    , editable:false     , visible:false    },
            {name:'producto_div'     , typeName:'text'    , editable:false     , serverSide:true, clientSide:'parseProducto', title:'producto'   },
            {name:'productocompleto' , typeName:'jsonb'                , editable:false     , visible:false     },
            {name:'observacion'      , typeName:'integer' , title:'o'  , editable:false     , visible:false},
            {name:'observacion_div'  , typeName:'text'    , title:'o'  , editable:false     , serverSide:true, clientSide:'parseObservacion'},
            {name:'informante'       , typeName:'integer' , nullable:false             , editable:false     , visible:false    },
            {name:'panel'            , typeName:'integer' , nullable:false             , allow:{update:true}, visible:false     },
            {name:'tarea'            , typeName:'integer' , nullable:false             , allow:{update:true}, visible:false     },
            {name:'visita'           , typeName:'integer' , nullable:false , default:1 , allow:{update:false}, visible:false    },
            {name:'atributos'        , typeName:'text'    , nullable:false, allow:{update:false}, clientSide:'parseAtributosAnteriores', serverSide:true     },
            {name:'atributos_mes_anterior'       , typeName:'jsonb', nullable:false, visible:false,  allow:{update:false}   },
            {name:'tipoprecioanterior' , typeName:'text'   , title:'TP'    , allow:{update:false},  serverSide:true, clientSide:'parseTipoPrecioAnterior'},
            {name:'precioanterior'   , typeName:'decimal' , title:'precio anterior', allow:{update:false}, serverSide:true, clientSide:'parsePrecioAnterior' },
            {name:'atributos_mes_actual'         , typeName:'jsonb'   , nullable:false            , allow:{update:false}, visible:false     },
            {name:'copiar_tipoprecio', typeName:'text'    , allow:{update:false}, title:'c', clientSide:'copiarTipoprecio', serverSide:true      },
            {name:'tipoprecio'       , typeName:'text'                    , title:'TP' , allow:{update:puedeEditar},clientSide:'parseTipoPrecio' , serverSide:true},
            {name:'precio'           , typeName:'decimal' , allow:{update:puedeEditar} , clientSide:'parsePrecio' , serverSide:true, mobileInputType:'number'},
            {name:'cambio'           , typeName:'text'                                 , allow:{update:true}, visible:false     },
            {name:'comentariosrelpre', typeName:'text'                                 , allow:{update:puedeEditar}, postInput:'upperSpanish' },
            {name:'precionormalizado'  , typeName:'decimal' , editable:false     , visible:false},
            {name:'precionormalizado_1', typeName:'decimal' , editable:false     , visible:false},
            {name:'promobs_1'          , typeName:'decimal' , editable:false     , visible:false},
            {name:'normsindato'        , typeName:'text'    , editable:false     , visible:false},
            {name:'fueraderango'       , typeName:'text'    , editable:false     , visible:false},
            {name:'sinpreciohace4meses', typeName:'text'    , editable:false     , visible:false},
            {name:'atributos_para_normalizar'       , typeName:'jsonb', nullable:false, visible:false,  allow:{update:false}   },
            {name:'adv'                , typeName:'boolean' , allow:{update:false}   , visible:false},
            {name:'espec_destacada'    , typeName:'boolean' , editable:false     , visible:false},
            {name:'repregunta'         , typeName:'text'    , editable:false     , visible:false},
            {name:'ultimoperiodoconprecio', typeName:'text' , allow:{update:false}, visible:false /*, serverSide:true, clientSide:'parsePrecioAnterior'*/},
            {name:'orden'              , typeName:'integer' , editable:false     , visible:false},
        ],
        primaryKey:['periodo','informante','visita', 'formulario','producto','observacion'],
        sortColumns:[{column:'orden'},{column:'observacion'}],
        foreignKeys:[
            //{references:'informantes', fields:['informante']},
            {references:'tipopre_encuestador', fields:['tipoprecio'], displayFields:['nombretipoprecio', 'espositivo']},
            {references:'tipopre_encuestador', fields:[{source:'tipoprecioanterior', target:'tipoprecio'}], displayFields:['nombretipoprecio', 'espositivo'], alias: 'tipopre_encuestador_anterior'},
            //{references:'periodos', fields:['periodo']},
            //{references:'productos', fields:['producto']},
            //{references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},
            //{references:'formularios', fields:['formulario']},
        ],
        detailTables:[
        ],
        sql:{
            from:`(select r.periodo, r.producto, r.informante, r.formulario, rv.panel, rv.tarea, r.visita, r.observacion, r.precio, r.cambio, r.tipoprecio, 
                atrs.productocompleto, 
                        atrs.atributos_mes_anterior,
                        atrs.atributos_mes_actual,
                        atrs.atributos_para_normalizar,
                        CASE WHEN p.periodo is not null THEN 'R' ELSE null END as repregunta,
                        CASE WHEN c.antiguedadexcluido>0 and r.precio>0 THEN 'x' ELSE null END as excluido, r_1.precio as precioanterior, 
                        r_1.tipoprecio as tipoprecioanterior, r.comentariosrelpre, r.precionormalizado, r.especificacion, r.ultima_visita, r.observaciones,
                        r_1.comentariosrelpre as comentariosanterior,                  
                        CASE WHEN r_1.precio > 0 and r_1.precio <> r.precio THEN round((r.precio/r_1.precio*100-100)::decimal,1)::TEXT||'%' 
                        ELSE CASE WHEN c_1.promobs > 0 and c_1.promobs <> r.precionormalizado and r_1.precio is null THEN round((r.precionormalizado/c_1.promobs*100-100)::decimal,1)::TEXT||'%' 
                                ELSE NULL 
                                END 
                        END AS masdatos,
                        c_1.antiguedadsinprecio as antiguedadsinprecioant, c_1.promobs as promobs_1, r_1.precionormalizado as precionormalizado_1, 
                        atrs.normsindato, 
                        atrs.fueraderango,
                        r_his.sinpreciohace4meses,
                        atrs.productocompleto->>'nombreproducto'||' '||r.observacion as producto_div,
                        atrs.productocompleto->>'nombreproducto'||' '||r.observacion as atributos,
                        atrs.orden||' '||r.producto||' '||r.observacion as observacion_div,
                        case when p.periodo is null and tp.puedecopiar = 'S' then '→' else null end as copiar_tipoprecio,
                        false as adv, atrs.espec_destacada, case when r_1.precionormalizado is null then ultimoperiodoconprecio else null end as ultimoperiodoconprecio,
                        atrs.orden
                    from relpre r 
                        inner join relvis rv on r.periodo = rv.periodo and r.informante = rv.informante and r.visita = rv.visita and r.formulario = rv.formulario
                inner join periodos per ON r.periodo = per.periodo
                left join relpre r_1 
                   ON r_1.periodo = CASE WHEN r.visita > 1 THEN r.periodo ELSE per.periodoanterior END 
                   AND (
                         r_1.ultima_visita = true AND r.visita = 1 
                      OR r.visita > 1 AND r_1.visita = (r.visita - 1)
                   ) 
                   AND r_1.informante = r.informante 
                   AND r_1.producto = r.producto
                   AND r_1.observacion = r.observacion
                        left join prerep p on r.periodo = p.periodo and r.producto = p.producto and r.informante = p.informante
                        left join calobs c on r.periodo = c.periodo and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion and c.calculo = 0
                        left join calobs c_1 on r_1.periodo = c_1.periodo and r.producto = c_1.producto and r.informante = c_1.informante and r.observacion = c_1.observacion and c_1.calculo = 0
                        left join tipopre tp on r_1.tipoprecio = tp.tipoprecio,
                        lateral (select max(substr(periodo,2,4)||'/'||substr(periodo,7,2)||' '||round(precio::decimal,2)::text) ultimoperiodoconprecio 
                                   from relpre
                                   where precio is not null and r.informante = informante and r.producto = producto and r.observacion = observacion and r.visita = visita 
                                   and periodo < r.periodo
                                  ) re,
                lateral((
                        SELECT  
                            jsonb_agg(jsonb_build_object('atributo', at.atributo, 'nombreatributo', at.nombreatributo,'valor', ra_1.valor) order by pa.orden, ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita, ra.atributo) as atributos_mes_anterior,
                            jsonb_agg(jsonb_build_object('atributo', at.atributo, 'nombreatributo', at.nombreatributo,'valor', case when tp.espositivo = 'S' then ra.valor else null end, 'opciones', pa.opciones) order by pa.orden, ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita, ra.atributo) as atributos_mes_actual,
                            jsonb_agg(jsonb_build_object('atributo', ra.atributo, 'valor', ra.valor, 'valornormal', pa.valornormal, 'prioridad', pa.prioridad, 'normalizable', pa.normalizable, 'tiponormalizacion',pa.tiponormalizacion, 'valor_pesos', rm.valor_pesos) order by pa.prioridad, pa.orden, ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita, ra.atributo) as atributos_para_normalizar,
                            string_agg(distinct(CASE WHEN pa.valornormal IS NOT NULL AND pa.normalizable = 'S' AND ra.valor IS NULL AND r.precio IS NOT NULL THEN 'S' ELSE null END),',') as normsindato,
                            string_agg(distinct(CASE WHEN(tp.espositivo = 'S' AND comun.es_numero(ra.valor) AND pa.rangohasta IS NOT NULL AND pa.rangodesde IS NOT NULL AND
                                CASE
                                    WHEN comun.es_numero(ra.valor) THEN (ra.valor::double precision > pa.rangohasta OR ra.valor::double precision < pa.rangodesde) AND ra.valor::double precision <> pa.valornormal
                                    ELSE false
                                END)THEN 'S' ELSE null END),',') as fueraderango,
                            jsonb_build_object('producto',fo.producto,'nombreproducto',COALESCE(p.nombreparaformulario, p.nombreproducto),'especificacioncompleta'
                                    ,COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
                                    ||COALESCE(
                                    NULLIF(TRIM(
                                        COALESCE(trim(e.envase)||' ','')||
                                        CASE WHEN e.mostrar_cant_um='N' THEN ''
                                        ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '. '
                                    , '') 
                                    ||string_agg(
                                    CASE WHEN at.tipodato='N' AND at.visible = 'S' AND pa.rangodesde IS NOT NULL AND pa.rangohasta IS NOT NULL THEN 
                                    CASE WHEN pa.visiblenombreatributo = 'S' THEN at.nombreatributo||' ' ELSE '' END||'de '||pa.rangodesde||' a '||pa.rangohasta||' ' 
                                    ||COALESCE(at.unidaddemedida, at.nombreatributo, '')
                                    ||CASE WHEN pa.alterable = 'S' AND pa.normalizable = 'S' AND NOT(pa.rangodesde <= pa.valornormal AND pa.valornormal <= pa.rangohasta) THEN ' ó '||pa.valornormal||' '||at.unidaddemedida ELSE '' END
                                    ||CASE WHEN pa.otraunidaddemedida IS NOT NULL THEN '/'||pa.otraunidaddemedida||'.' ELSE '' END
                                    ||' '
                                    ELSE ''
                                    END,'' ORDER BY pa.orden)
                                    ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '')) as productocompleto,
                                e.destacada as espec_destacada,
                                fo.ordenimpresion as orden
                   FROM relatr ra
                     JOIN atributos at ON at.atributo = ra.atributo and ra.periodo = r.periodo and ra.informante = r.informante and ra.producto = r.producto and 
                    ra.visita = r.visita and ra.observacion = r.observacion
                     join productos p on r.producto = p.producto
                     join forobsinf fo on fo.informante = ra.informante and fo.producto = ra.producto and fo.formulario = r.formulario and fo.observacion = r.observacion
                     left join tipopre tp on r.tipoprecio = tp.tipoprecio
                     left join prodatr pa ON pa.atributo = ra.atributo AND pa.producto = ra.producto
                     left join especificaciones e ON e.producto = r.producto AND e.especificacion = 1
                     left join relatr ra_1 on ra_1.periodo=r_1.periodo and ra_1.informante=r_1.informante and ra_1.visita=r_1.visita and ra_1.producto=r_1.producto and ra_1.observacion=r_1.observacion and ra_1.atributo=ra.atributo
                     left join relmon rm on r.periodo = rm.periodo and ra.valor = rm.moneda
                  group by ra.periodo, fo.producto, ra.observacion, ra.informante, ra.visita, p.nombreparaformulario, p.nombreproducto, e.nombreespecificacion, e.envase, e.cantidad, e.unidaddemedida, e.excluir, e.destacada, fo.ordenimpresion, e.mostrar_cant_um
                  ORDER BY ra.periodo, fo.producto, ra.observacion, ra.informante, ra.visita)
                  UNION
                  SELECT jsonb_build_array() as atributos_mes_anterior, jsonb_build_array() as atributos_mes_actual, jsonb_build_array() as atributos_para_normalizar, null as normsindato, null as fueraderango,
                         jsonb_build_object('producto',o.producto,'nombreproducto',COALESCE(o.nombreparaformulario, o.nombreproducto),'especificacioncompleta'
                                    ,COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
                                    ||COALESCE(
                                    NULLIF(TRIM(
                                        COALESCE(trim(e.envase)||' ','')||
                                        CASE WHEN e.mostrar_cant_um='N' THEN ''
                                        ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '. '
                                    , '') 
                                    ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '')) as productocompleto,
                                e.destacada as espec_destacada,  null as orden
                  FROM productos o left join prodatr pa on o.producto = pa.producto
                  left join especificaciones e on o.producto = e.producto and e.especificacion = 1 
		          WHERE pa.atributo is null and nombreproducto not like 'Borrar%' and o.producto = r.producto
                  ) atrs,
                  lateral(
                    select CASE WHEN count(*) = 4 THEN 'S' ELSE null END as sinpreciohace4meses
                    from relpre rp_2_3
                    where moverperiodos(r.periodo,-1) >= rp_2_3.periodo and moverperiodos(r.periodo,-4) <= rp_2_3.periodo and r.producto = rp_2_3.producto and r.observacion = rp_2_3.observacion and r.informante = rp_2_3.informante and r.visita = rp_2_3.visita and rp_2_3.tipoprecio in ('S',null)
                  ) r_his
                        group by r.periodo, r.producto, r.observacion, r.informante, r.visita, rv.panel, rv.tarea, r.precio, r.tipoprecio, r.cambio, c.antiguedadexcluido, r_1.precio, r_1.tipoprecio, r_1.comentariosrelpre, c_1.antiguedadsinprecio, c_1.promobs,
                                 r_1.precionormalizado, atrs.atributos_mes_anterior, atrs.atributos_mes_actual, atrs.atributos_para_normalizar, atrs.normsindato, atrs.productocompleto, atrs.espec_destacada, atrs.orden, fueraderango, tp.puedecopiar, r_his.sinpreciohace4meses, p.periodo, re.ultimoperiodoconprecio
            )`,
        }        
    },context);
}