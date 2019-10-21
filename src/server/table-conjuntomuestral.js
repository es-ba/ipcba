"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'conjuntomuestral_vw',
		tableName:'conjuntomuestral',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'conjuntomuestral'            , typeName:'integer', nullable:false, allow:{update:puedeEditar}},
            {name:'encuestador'                 , typeName:'text'   , allow:{update:puedeEditar}},
            {name:'panel'                       , typeName:'integer', allow:{update:puedeEditar}},
            {name:'tiponegociomuestra'          , typeName:'integer', allow:{update:puedeEditar}},
            {name:'paneles'                     , typeName:'text', allow:{update:false}, inTable:false},
            {name:'tareas'                      , typeName:'text', allow:{update:false}, inTable:false},
        ],
        primaryKey:['conjuntomuestral'],
        sql:{
          from: `(SELECT c.conjuntomuestral, c.encuestador, c.panel, c.tiponegociomuestra,
                  CASE WHEN min(r.panel) IS NULL AND max(r.panel) IS NULL THEN NULL::text
                                WHEN MIN(r.panel) = max(r.panel) then min(r.panel)::text
                                ELSE MIN(r.panel)||'-'||MAX(r.panel) end as paneles,
			      CASE WHEN min(r.tarea) IS NULL AND max(r.tarea) IS NULL THEN NULL::text
                                WHEN MIN(r.tarea) = max(r.tarea) then min(r.tarea)::text
                                ELSE MIN(r.tarea)||'-'||MAX(r.tarea) end as tareas
                   FROM conjuntomuestral c 
                   LEFT JOIN informantes i ON c.conjuntomuestral = i.conjuntomuestral
                   LEFT JOIN relvis r ON i.informante=r.informante
                   WHERE r.periodo is null or r.periodo>='` + context.be.internalData.filterUltimoPeriodo + `' group by c.conjuntomuestral, c.encuestador, c.panel, c.tiponegociomuestra)`,
          isTable:true,
        }
    },context);
}