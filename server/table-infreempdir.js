"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='recepcionista';
    return context.be.tableDefAdapt({
        name:'infreempdir',
        tableName:'infreemp',
        editable:puedeEditar,
        title:'infreempdir',
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'fecha'                      , typeName:'text'                      , allow:{update:false}      },
            {name:'periodo'                    , typeName:'text'                      , allow:{update:false}      },
            {name:'informante'                 , typeName:'integer'                   , allow:{update:puedeEditar}},
            {name:'panel'                      , typeName:'integer'                   , allow:{update:false}      },
            {name:'tarea'                      , typeName:'integer'                   , allow:{update:false}      },
            {name:'rubro'                      , typeName:'integer'                   , allow:{update:false}      },
            {name:'nombrerubro'                , typeName:'text'                      , allow:{update:false}      },
            {name:'conjuntomuestral'           , typeName:'integer', title:'CM'       , allow:{update:false}      },
            {name:'formularios'                , typeName:'text'                      , allow:{update:false}      },
            {name:'direccionalternativa'       , typeName:'text'   , nullable:false   , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'comentariorecep'            , typeName:'text'                      , allow:{update:puedeEditar}},
            {name:'nombreinformantealternativo', typeName:'text'                      , allow:{update:puedeEditar}},
            {name:'reemplazo'                  , typeName:'integer'                   , allow:{update:puedeEditar}},
            {name:'comentarioana'              , typeName:'text'                      , allow:{update:puedeEditar}},
            {name:'chk'                        , typeName:'text'                      , allow:{update:false}      },
            {name:'periodoalta'                , typeName:'text'                      , allow:{update:false}      },
            {name:'formulariosalta'            , typeName:'text'                      , allow:{update:false}      },
        ],
        primaryKey:['informante', 'direccionalternativa'],
        sortColumns:[{column:'fecha'},{column:'periodo'},{column:'informante'}],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
        ],
        detailTables:[
            {table:'misma_direccion', abr:'En la misma dirección', fields:['informante',], abr:'M'}
        ],
        sql:{
            from:`(SELECT to_char(alta_fec,'YYYY/MM/DD') fecha, v.periodo, ir.informante, f.panel, f.tarea, i.rubro, nombrerubro, 
                    i.conjuntomuestral, f.formularios, comentariorecep, direccionalternativa, nombreinformantealternativo, ir.reemplazo, comentarioana, 
                    CASE WHEN se.formularios is not null and f.formularios = se.formularios then '✓' 
                        WHEN se.formularios is not null and f.formularios <> se.formularios then '✘' 
                        else null end as chk,
                        re.periodo periodoalta, se.formularios formulariosalta
                    FROM infreemp ir
                        JOIN informantes i on ir.informante = i.informante
                        JOIN rubros ru on i.rubro = ru.rubro
                        /* Formularios del reemplazante: */
                        LEFT JOIN (SELECT reemplazo, min(periodo) periodo
                                    FROM infreemp if 
                                    LEFT JOIN relvis rs on if.reemplazo = rs.informante
                                    WHERE if.reemplazo is not null 
                                    GROUP BY reemplazo) re ON ir.reemplazo = re.reemplazo
                        LEFT JOIN (SELECT periodo, reemplazo, string_agg(s.formulario::text||':'||nombreformulario,',' order by s.formulario) formularios
                                    FROM infreemp if
                                    LEFT JOIN relvis s on if.reemplazo = s.informante
                                    JOIN formularios o on s.formulario = o.formulario
                                    WHERE if.reemplazo is not null
                                    GROUP BY periodo, reemplazo) se on se.periodo = re.periodo and se.reemplazo = re.reemplazo,
                        /* Formularios del reemplazado */
                        lateral (SELECT informante, max(periodo) periodo
                                FROM relvis rv
                                WHERE ir.informante = rv.informante
                                GROUP BY informante) v,
                        lateral (SELECT informante, panel, tarea , string_agg(r.formulario::text||':'||nombreformulario,',' order by r.formulario) formularios
                                FROM relvis r 
                                JOIN formularios fo on r.formulario = fo.formulario
                                WHERE ir.informante = r.informante and r.periodo = v.periodo
                                group by informante, panel, tarea) f
                    )`
        }        
    },context);
}