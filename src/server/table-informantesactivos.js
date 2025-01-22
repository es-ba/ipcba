"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'informantesactivos',
        title:'informantes activos',
        editable:false,
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'paneles'                      , typeName:'text'    },
            {name:'tareas'                       , typeName:'text'    },
            {name:'informante'                   , typeName:'integer' },
            {name:'ti'                           , typeName:'text'    },
            {name:'encuestadores'                , typeName:'text'    },
            {name:'recepcionistas'               , typeName:'text'    },
            {name:'razon'                        , typeName:'text'    },
            {name:'visita'                       , typeName:'integer' },
            {name:'nombreinformante'             , typeName:'text'    },
            {name:'direccion'                    , typeName:'text'    },
            {name:'formularios'                  , typeName:'text'    },
            {name:'contacto'                     , typeName:'text'    },
            {name:'distrito'                     , typeName:'integer' },
            {name:'fraccion_ant'                 , typeName:'integer' },
            {name:'comuna'                       , typeName: 'integer'},
            {name:'fraccion'                     , typeName: 'integer'},
            {name:'radio'                        , typeName: 'integer'},
            {name:'manzana'                      , typeName: 'integer'},
            {name:'depto'                        , typeName: 'integer'},
            {name:'barrio'                       , typeName: 'integer'},
            {name:'rubro'                        , typeName:'integer' },
            {name:'nombrerubro'                  , typeName:'text'    },
            {name:'maxperiodoinformado'          , typeName:'text'    },
            {name:'minperiodoinformado'          , typeName:'text'    },
            {name:'periodoalta'                  , typeName:'text'    },
            {name:'modalidad'                    , typeName:'text'    },
            {name:'cadena'                       , typeName:'text'    },
            {name:'telcontacto'                  , typeName:'text'    },
            {name:'web'                          , typeName:'text'    },
            {name:'email'                        , typeName:'text'    },
        ],
        primaryKey:['periodo','informante','visita'],
        //sortColumns:[{column:'valor'}],
        filterColumns:[
            {column:'visita', operator:'=', value:1},
        ],        
        sql:{
            from:`(SELECT c.periodo,
                string_agg(distinct c.panel::text,'~' order by c.panel::text) as paneles,
                string_agg(distinct c.tarea::text,'~' order by c.tarea::text) as tareas,
                c.informante,
                i.tipoinformante AS ti,
                COALESCE(string_agg(DISTINCT (c.encuestador::text || ':'::text) || c.nombreencuestador, '|'::text), NULL::text) AS encuestadores,
                COALESCE(string_agg(DISTINCT (c.recepcionista::text || ':'::text) || c.nombrerecepcionista, '|'::text), NULL::text) AS recepcionistas,
                COALESCE(string_agg(DISTINCT (c.supervisor::text || ':'::text) || c.nombresupervisor, '|'::text), NULL::text) AS supervisores,
                    CASE
                        WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
                        ELSE COALESCE(min(c.razon) || ''::text, NULL::text)
                    END AS razon,
                string_agg((c.formulario::text || ' '::text) || c.nombreformulario::text, chr(10) ORDER BY c.formulario) AS formularioshdr,
                lpad(' '::text, count(*)::integer, chr(10)) AS espacio,
                c.visita,
                c.nombreinformante,
                c.direccion,
                string_agg((c.formulario::text || ':'::text) || c.nombreformulario::text, '|'::text) AS formularios,
                (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto,
                c.conjuntomuestral,
                c.ordenhdr,
                i.distrito,
                i.fraccion_ant,
                i.comuna,
                i.fraccion,
                i.radio,
                i.manzana,
                i.depto,
                i.barrio,
                i.rubro,
                r.nombrerubro,
                a.maxperiodoinformado,
                a.minperiodoinformado,
                c.fechasalida,
                a.periodoalta,
                rt.modalidad,
                i.cadena,
                i.telcontacto,
                i.web,
                i.email
            FROM cvp.control_hojas_ruta c
                LEFT JOIN cvp.reltar rt ON c.periodo = rt.periodo and c.panel = rt.panel and c.tarea = rt.tarea
                LEFT JOIN cvp.tareas t ON c.tarea = t.tarea
                LEFT JOIN cvp.personal p ON p.persona::text = t.encuestador::text
                LEFT JOIN cvp.informantes i ON c.informante = i.informante
                LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
                LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                           min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                           FROM cvp.control_hojas_ruta cr 
                           LEFT JOIN cvp.razones z using(razon)
                           GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
            GROUP BY c.periodo, c.informante, i.tipoinformante, c.visita, c.nombreinformante, c.direccion, 
            ((COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text), c.conjuntomuestral, c.ordenhdr, i.distrito,
            i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, a.periodoalta,
            rt.modalidad, i.cadena, i.telcontacto, i.web, i.email
            )`
        }
    },context);
}