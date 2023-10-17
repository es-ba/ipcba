"use strict";

module.exports = function(context){
    var {be}=context;
    var {db}=be;
    return be.tableDefAdapt({
        name:'planificacion',
        editable:false,
        fields:[
            {name:'periodo'         , typeName:'text'    },
            {name:'panel'           , typeName:'integer' },
            {name:'tarea'           , typeName:'integer' },
            {name:'encuestador'     , typeName:'text'      },
            {name:'apenom'          , typeName:'text'    , title:'apellido y nombre'},
            {name:'fechadesde'      , typeName:'date'},
            {name:'fechahasta'      , typeName:'date'},
            {name:'planurl'         , typeName:'text'      },
            {name:'parametros'      , typeName:'text'      },
            {name:'url'             , typeName:'text' , clientSide:'displayUrl', serverSide:true, inTable:false, width:650},

        ],
        refrescable: true,
        primaryKey:['periodo', 'encuestador'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'}],
        hiddenColumns:['parametros','planurl'],
        sql:{
            fields:{
                url:{expr:`planUrl||parametros`}
            },
            isTable: false,
            from: `(SELECT periodo, panel, tarea, encuestador, concat(pp.nombre||' ',pp.apellido) apenom, fechadesde, fechahasta
                    , t.planificacion_url as planurl
                    ,'/planificacion'||'/'||periodo||'/'||encuestador||'/'||fechadesde||'/'||fechahasta as parametros
                    FROM (SELECT * FROM personal per WHERE per.username = ${db.quoteLiteral(context.user.usu_usu)}) per
                         INNER JOIN reltar rt ON rt.encuestador = per.persona OR per.labor not in ('E','S')
                         INNER JOIN personal pp ON rt.encuestador = pp.persona
                         INNER JOIN periodos p USING (periodo)
                         INNER JOIN parametros t on unicoregistro
                         INNER JOIN (SELECT periodo, MIN(panel) panel, MIN(fechasalida) fechadesde, MAX(fechasalida) fechahasta
                                     FROM relpan
                                     WHERE CURRENT_TIMESTAMP <= fechasalida AND 
                                    (SUBSTR(periodo,2,4)::INTEGER = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INTEGER /*anio actual*/
                                    AND EXTRACT(WEEK FROM fechasalida)::INTEGER = EXTRACT(WEEK FROM CURRENT_TIMESTAMP)::INTEGER + 1 /*semana siguiente*/
                                    OR SUBSTR(periodo,2,4)::INTEGER = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INTEGER + 1) /*anio siguiente*/
                                    GROUP BY periodo) rp USING (periodo, panel)
                    WHERE p.ingresando = 'S')`
        },
    },context);
}