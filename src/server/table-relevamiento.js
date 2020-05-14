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
            {name:'informante'      , typeName:'integer' },
            {name:'visita'          , typeName:'integer' }, 
            {name:'nombreinformante', typeName:'text'    },
            {name:'direccion'       , typeName:'text'    },
            {name:'contacto'        , typeName:'text'    },
            {name:'telcontacto'     , typeName:'text'    },
            {name:'web'             , typeName:'text'    },
            {name:'email'           , typeName:'text'    },
            {name:'abrir'           , typeName: 'text', clientSide:'abrir'},
            {name:'encuestador'     , typeName:'text'    , visible:false},
            {name:'persona'         , typeName:'text'    , visible:false},
            {name:'usuario'         , typeName:'text'    , title:'abierto por'},
            {name:'apenom'          , typeName:'text'    , title:'apellido y nombre', allowEmptyText:true},
            {name:'cantformulariostotales'   , typeName:'integer' , title:'form. totales', visible:false}, 
            {name:'cantformularioscompletos' , typeName:'integer' , title:'form. completos'},
            {name:'cantformulariosfaltantes' , typeName:'integer' , title:'form. faltantes'}, 
            {name:'cantpreciostotales'       , typeName:'integer' , title:'precios totales', visible:false}, 
            {name:'cantprecioscompletos'     , typeName:'integer' , title:'precios completos'}, 
            {name:'cantpreciosfaltantes'     , typeName:'integer' , title:'precios faltantes'}, 
        ],
        refrescable: true,
        primaryKey:['periodo', 'panel', 'tarea', 'informante','visita'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'}],
        sql:{
            isTable: false,
            from: `(select rv.periodo, panel, tarea, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email,
                    case when per.labor = 'E' then per.persona else null end as encuestador, per.persona, 
                    string_agg(distinct tk.username, ', ' order by tk.username) as usuario,
                    string_agg(distinct ptk.persona, ', ' order by ptk.persona) as usuario_codigo,
                    string_agg(distinct concat_ws(' ',ptk.nombre,ptk.apellido), ', ' order by concat_ws(' ',ptk.nombre,ptk.apellido)) as apenom,
                    nullif(count(distinct rv.formulario),0) as cantformulariostotales,
                    count(distinct case when z.espositivoformulario = 'N' then rv.formulario else null end)  +
                    count(distinct case when pre.tipoprecio is not null then pre.formulario else null end)  -
                    (select count(*) from 
                        regexp_matches (
                        regexp_replace(string_agg(distinct pre.formulario::text||pre.tipo,'' order by pre.formulario::text||pre.tipo),'[NS]','', 'g')
                        , '([0-9]{2,4})\\1'
                        )
                    ) --estado intermedio
                    as cantformularioscompletos, 
                    nullif(count(distinct rv.formulario),0) - (
                    count(distinct case when z.espositivoformulario = 'N' then rv.formulario else null end)  +
                    count(distinct case when pre.tipoprecio is not null then pre.formulario else null end)  -
                    (select count(*) from 
                        regexp_matches (
                        regexp_replace(string_agg(distinct pre.formulario::text||pre.tipo,'' order by pre.formulario::text||pre.tipo),'[NS]','', 'g')
                        , '([0-9]{2,4})\\1'
                        )
                    ) --estado intermedio
                    ) as cantformulariosfaltantes,
                    sum(case when z.espositivoformulario = 'S' and pre.periodo is not null then 1 else 0 end) as cantpreciostotales,
                    sum(case when z.espositivoformulario = 'S' and pre.periodo is not null and pre.tipoprecio is not null then 1 else 0 end) as cantprecioscompletos,
                    sum(case when z.espositivoformulario = 'S' and pre.periodo is not null then 1 else 0 end) - 
                    sum(case when z.espositivoformulario = 'S' and pre.periodo is not null and pre.tipoprecio is not null then 1 else 0 end) as cantpreciosfaltantes
                    from (select * from personal per where per.username = ${db.quoteLiteral(context.user.usu_usu)}) per
                        inner join reltar rt on rt.encuestador = per.persona or per.labor <> 'E'
                        inner join relvis rv using (periodo, panel, tarea)
                        inner join razones z using(razon)
                        inner join periodos p using (periodo)
                        inner join relpan rp using (periodo, panel)
                        inner join informantes i on rv.informante = i.informante 
                        left join tokens tk on tk.token = token_relevamiento
                        left join personal ptk on ptk.username = tk.username
                        left join relinf ri on rv.periodo = ri.periodo and rv.informante = ri.informante and rv.visita = ri.visita
                        left join (select *, case when tipoprecio is null then 'N' else 'S' end as tipo from relpre) pre on rv.periodo = pre.periodo and rv.informante = pre.informante and rv.visita = pre.visita and rv.formulario = pre.formulario
                        where p.ingresando = 'S' 
                        and current_date between COALESCE(ri.fechasalidadesde,rp.fechasalidadesde, rp.fechasalida) and COALESCE(ri.fechasalidahasta,rp.fechasalidahasta, rp.fechasalida)
                    group by rv.periodo, panel, tarea, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email, per.persona, per.labor)`
        },
    },context);
}