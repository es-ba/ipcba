"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'personal_sin_carga',
        fields:[
            {name:'fecha'                            , typeName:'date'},
            {name:'persona'                          , typeName:'text'},
        ],
        primaryKey:['fecha','persona'],
        foreignKeys:[
            {references:'personal', fields:['persona']},
        ],
        sortColumns:[{column:'fecha'}, {column:'persona'}],
        sql:{
            from: `(select fecha, trim(persona) persona 
                    from (select fecha, lista, persona, position(persona IN lista) = 0 and licencia is null as libre 
                        from (select f.fecha, ' '||string_agg(encuestador, ' ' order by encuestador::integer)||' ' lista, l.persona as licencia
                                from fechas f
                                join relpan rp on f.fecha = rp.fechasalida
                                join reltar rt on rp.periodo = rt.periodo and rp.panel = rt.panel
                                left join licencias l on rt.encuestador = l.persona and fecha between l.fechadesde and l.fechahasta
                                where f.seleccionada_planificacion = 'S'
                                group by f.fecha, l.persona) q
                        join (select ' '||persona||' ' persona from personal p 
                        join ipcba.usuarios u on p.username = u.usu_usu 
                        where labor in ('E', 'S') and activo = 'S' and usu_activo) p on true) w
                        where libre)`,                  
        }  
    },context);
}