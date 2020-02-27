"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'informantesactivos',
        title:'informantes activos',
        editable:false,
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'panel'                        , typeName:'integer' },
            {name:'tareas'                       , typeName:'text'    },
            {name:'informante'                   , typeName:'integer' },
            {name:'ti'                           , typeName:'text'    },
            {name:'encuestadores'                , typeName:'text'    },
            {name:'recepcionistas'               , typeName:'text'    },
            {name:'ingresadores'                 , typeName:'text'    },
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
        ],
        primaryKey:['periodo','informante','visita'],
        //sortColumns:[{column:'valor'}],
        sql:{
            from:`(SELECT c.periodo,
                c.panel,
                string_agg(distinct c.tarea::text,'~' order by c.tarea::text) as tareas,
                c.informante,
                i.tipoinformante AS ti,
                COALESCE(string_agg(DISTINCT (c.encuestador::text || ':'::text) || c.nombreencuestador, '|'::text), NULL::text) AS encuestadores,
                COALESCE(string_agg(DISTINCT (c.recepcionista::text || ':'::text) || c.nombrerecepcionista, '|'::text), NULL::text) AS recepcionistas,
                COALESCE(string_agg(DISTINCT (c.ingresador::text || ':'::text) || c.nombreingresador, '|'::text), NULL::text) AS ingresadores,
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
                c.fechasalida
            FROM cvp.control_hojas_ruta c
                LEFT JOIN cvp.tareas t ON c.tarea = t.tarea
                LEFT JOIN cvp.personal p ON p.persona::text = t.encuestador::text
                LEFT JOIN cvp.informantes i ON c.informante = i.informante
                LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
                LEFT JOIN ( SELECT control_hojas_ruta.informante,
                        control_hojas_ruta.visita,
                        max(control_hojas_ruta.periodo::text) AS maxperiodoinformado,
                        min(control_hojas_ruta.periodo::text) AS minperiodoinformado
                    FROM cvp.control_hojas_ruta
                    WHERE control_hojas_ruta.razon = 1 
                    GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON c.informante = a.informante AND c.visita = a.visita
            GROUP BY c.periodo, c.panel, c.informante, i.tipoinformante, c.visita, c.nombreinformante, c.direccion, 
            ((COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text), c.conjuntomuestral, c.ordenhdr, i.distrito,
            i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida
            )`
        }
    },context);
}