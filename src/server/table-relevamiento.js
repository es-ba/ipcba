"use strict";

module.exports = function(context){
    var {be}=context;
    var {db}=be;
    return be.tableDefAdapt({
        name:'relevamiento',
        editable:false,
        fields:[
            {name:'periodo'         , typeName:'text'    },
            {name:'panel'           , typeName:'integer' },
            {name:'tarea'           , typeName:'integer' },
            {name:'fechasalida'     , typeName:'date'    },
            {name:'fechasalidadesde', typeName:'date', title:'fechadesde' },
            {name:'fechasalidahasta', typeName:'date', title:'fechahasta' },
            {name:'informante'      , typeName:'integer' },
            {name:'visita'          , typeName:'integer' }, 
            {name:'razones'         , typeName:'text'    },
            {name:'abrir'           , typeName:'text', clientSide:'abrir'},
            {name:'nombreinformante', typeName:'text'    },
            {name:'nombrerubro'     , typeName:'text'    },
            {name:'direccion'       , typeName:'text'    },
            {name:'contacto'        , typeName:'text'    },
            {name:'telcontacto'     , typeName:'text'    },
            {name:'web'             , typeName:'text'    },
            {name:'email'           , typeName:'text'    },
            {name:'encuestador'     , typeName:'text'    , visible:false},
            {name:'persona'         , typeName:'text'    , visible:false},
            {name:'cantformulariostotales'   , typeName:'integer' , title:'form. totales', visible:false}, 
            {name:'cantformularioscompletos' , typeName:'integer' , title:'form. completos'},
            {name:'cantformulariosfaltantes' , typeName:'integer' , title:'form. faltantes'}, 
            {name:'cantpreciostotales'       , typeName:'integer' , title:'precios totales', visible:false}, 
            {name:'cantprecioscompletos'     , typeName:'integer' , title:'precios completos'}, 
            {name:'cantpreciosfaltantes'     , typeName:'integer' , title:'precios faltantes'}, 
            {name:'cantpreciosinconsistentes', typeName:'integer' , title:'inconsistentes'}, 
            {name:'usuario'         , typeName:'text'    , title:'abierto por'},
            {name:'apenom'          , typeName:'text'    , title:'apellido y nombre', allowEmptyText:true},
        ],
        refrescable: true,
        primaryKey:['periodo', 'panel', 'tarea', 'informante','visita'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'}],
        hiddenColumns:['apenom'],
        sql:{
            isTable: false,
            from: `(select rv.periodo, panel, tarea, rt.fechasalidadesde, rt.fechasalidahasta, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email, rub.nombrerubro, 
                    case when per.labor = 'E' then per.persona else null end as encuestador, per.persona, 
                    string_agg(distinct tk.username, ', ' order by tk.username) as usuario,
                    string_agg(distinct ptk.persona, ', ' order by ptk.persona) as usuario_codigo,
                    string_agg(distinct concat_ws(' ',ptk.nombre,ptk.apellido), ', ' order by concat_ws(' ',ptk.nombre,ptk.apellido)) as apenom,
                    nullif(count(distinct rv.formulario),0) as cantformulariostotales,
                    count(distinct case when z.espositivoformulario = 'N' then rv.formulario else null end)  +
                    count(distinct case when pre.tipoprecio is not null then pre.formulario else null end)  -
                    (select count(*) from 
                        regexp_matches (
                            replace(string_agg(distinct pre.formulario::text||pre.tipo,'' order by pre.formulario::text||pre.tipo),'N','S')
                        , '(([0-9]{2,4})S)\\1', 'g'
                        )
                    ) --estado intermedio
                    as cantformularioscompletos, 
                    nullif(count(distinct rv.formulario),0) - (
                    count(distinct case when z.espositivoformulario = 'N' then rv.formulario else null end)  +
                    count(distinct case when pre.tipoprecio is not null then pre.formulario else null end)  -
                    (select count(*) from 
                        regexp_matches (
                            replace(string_agg(distinct pre.formulario::text||pre.tipo,'' order by pre.formulario::text||pre.tipo),'N','S')
                        , '(([0-9]{2,4})S)\\1','g'
                        )
                    ) --estado intermedio
                    ) as cantformulariosfaltantes,
                    sum(case when z.espositivoformulario is null then null when z.espositivoformulario = 'S' and pre.periodo is not null then 1 else 0 end) as cantpreciostotales,
                    sum(case when z.espositivoformulario is null then null when z.espositivoformulario = 'S' and pre.periodo is not null and pre.tipoprecio is not null then 1 else 0 end) as cantprecioscompletos,
                    sum(case when z.espositivoformulario is null then null when z.espositivoformulario = 'S' and pre.periodo is not null then 1 else 0 end) - 
                    sum(case when z.espositivoformulario is null then null when z.espositivoformulario = 'S' and pre.periodo is not null and pre.tipoprecio is not null then 1 else 0 end) as cantpreciosfaltantes,
                    sum(case when pre.inconsistente then 1 else null end) as cantpreciosinconsistentes,
                    string_agg (distinct rv.razon::text,'~' order by rv.razon::text) as razones
                    from (select * from personal per where per.username = ${db.quoteLiteral(context.user.usu_usu)}) per
                        inner join reltar rt on rt.encuestador = per.persona or per.labor not in ('E','S')
                        inner join relvis rv using (periodo, panel, tarea)
                        inner join periodos p using (periodo)
                        inner join relpan rp using (periodo, panel)
                        inner join informantes i on rv.informante = i.informante 
                        left join rubros rub using (rubro)
                        left join razones z using(razon)
                        left join tokens tk on tk.token = token_relevamiento
                        left join personal ptk on ptk.username = tk.username
                        left join relinf ri on rv.periodo = ri.periodo and rv.informante = ri.informante and rv.visita = ri.visita
                        left join (select pre.*, tp.inconsistente, case when tipoprecio is null then 'N' else 'S' end as tipo from relpre pre left join tipopre tp using(tipoprecio)) pre on rv.periodo = pre.periodo and rv.informante = pre.informante and rv.visita = pre.visita and rv.formulario = pre.formulario
                        where p.ingresando = 'S' 
                        and current_timestamp between COALESCE(ri.fechasalidadesde, rt.fechasalidadesde, rp.fechasalidadesde, rp.fechasalida)+interval '9 hours'  and COALESCE(ri.fechasalidahasta, rt.fechasalidahasta, rp.fechasalidahasta, rp.fechasalida) +interval '24 hours'
                    group by rv.periodo, panel, tarea, rt.fechasalidadesde, rt.fechasalidahasta, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email, rub.nombrerubro, per.persona, per.labor)`
        },
    },context);
}