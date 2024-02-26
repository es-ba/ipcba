"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'personal_sin_carga',
        fields:[
            {name:'fecha'                            , typeName:'date'},
            {name:'persona'                          , typeName:'text'},
            {name:'labor'                            , typeName:'text'},
        ],
        primaryKey:['fecha','persona'],
        foreignKeys:[
            {references:'personal', fields:['persona']},
        ],
        sortColumns:[{column:'fecha'}, {column:'persona'}],
        sql:{
            from: `(select per.persona, per.fecha, per.labor 
                     from (select persona, fecha, labor 
                            from personal p
                            join tareas t on p.persona = t.encuestador 
                            join ipcba.usuarios u on p.username = u.usu_usu 
                            cross join (select fecha from fechas f 
                                        join relpan rp on f.fecha = rp.fechasalida 
                                        where seleccionada_planificacion = 'S') s
                            where operativo = 'C' and labor in ('E', 'S') and activo = 'S' and usu_activo) per
                    left join (select fecha, encuestador as persona
                                 from fechas f
                                 join relpan rp on f.fecha = rp.fechasalida
                                 join reltar rt on rp.periodo = rt.periodo and rp.panel = rt.panel
                                where f.seleccionada_planificacion = 'S'
                               union
                                select fecha, l.persona
                                  from fechas f
                                  join relpan rp on f.fecha = rp.fechasalida
                                  join licencias l on f.fecha between l.fechadesde and l.fechahasta
                                  where f.seleccionada_planificacion = 'S') q 
                    on per.persona = q.persona and per.fecha = q.fecha
                    where q.fecha is null)`,                  
        }  
    },context);
}