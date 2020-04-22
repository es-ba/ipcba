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
        ],
        refrescable: true,
        primaryKey:['periodo', 'panel', 'tarea', 'informante','visita'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'}],
        sql:{
            isTable: false,
            from: `(select periodo, panel, tarea, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email,
                    case when per.labor = 'E' then per.persona else null end as encuestador,
                    per.persona, 
                    string_agg(distinct tk.username, ', ' order by tk.username) as usuario,
                    string_agg(distinct ptk.persona, ', ' order by ptk.persona) as usuario_codigo,
                    string_agg(distinct concat_ws(' ',ptk.nombre,ptk.apellido), ', ' order by concat_ws(' ',ptk.nombre,ptk.apellido)) as apenom
                from (select * from personal per where per.username = ${db.quoteLiteral(context.user.usu_usu)}) per
                    inner join reltar rt on rt.encuestador = per.persona or per.labor <> 'E'
                    inner join relvis rv using (periodo, panel, tarea)
                    inner join periodos p using (periodo)
                    inner join relpan rp using (periodo, panel)
                    inner join informantes i on rv.informante = i.informante 
                    left join tokens tk on tk.token = token_relevamiento
                    left join personal ptk on ptk.username = tk.username
                where p.ingresando = 'S' 
                    and current_date between COALESCE(rp.fechasalidadesde, rp.fechasalida) and COALESCE(rp.fechasalidahasta, rp.fechasalida) 
                group by periodo, panel, tarea, rp.fechasalida, rv.informante, rv.visita, i.nombreinformante, i.direccion, i.contacto, i.telcontacto, i.web, i.email, per.persona, per.labor)`
        },
    },context);
}