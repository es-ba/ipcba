"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'precios_positivos',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'cluster'              ,typeName:'integer'},
            {name:'informante'           ,typeName:'integer'},
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'encuestador'          ,typeName:'text'   },
            {name:'encuestadornombre'    ,typeName:'text'   },
            {name:'operativo'            ,typeName:'text'   },
            {name:'formulario'           ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'rubro'                ,typeName:'integer'},
            {name:'med_positivosref'     ,typeName:'integer'},
            {name:'max_positivosref'     ,typeName:'integer'},
            {name:'positivosant'         ,typeName:'integer'},
            {name:'positivosact'         ,typeName:'integer'},
            {name:'razon'                ,typeName:'integer'},
            {name:'maxperiodoinformado'  ,typeName:'text'   }, 
            {name:'modalidad'            ,typeName:'text'   }, 
            {name:'codcomentarios'       ,typeName:'text', title:'cod'},
            {name:'comentarios'          ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        foreignKeys:[
            {references:'rubros'     , fields:['rubro']      },
            {references:'formularios', fields:['formulario'] },
        ],
        hiddenColumns:['cluster'],
        sql:{from:`(select v.periodo, v.informante, v.visita, v.panel, v.tarea, ta.operativo, v.formulario, 
            sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivosact,
            sum(CASE WHEN t_1.espositivo = 'S' THEN 1 ELSE 0 END) as positivosant,
            i.rubro, v.encuestador, per.nombre||' '||per.apellido as encuestadornombre, coalesce(p.solo_cluster,pp."cluster") as "cluster"
            ,v.razon,max_periodos.maxperiodoinformado, rt.modalidad, v.codcomentarios, v.comentarios, rr.max_positivosref, rr.med_positivosref
            from relvis v
              inner join relpre_1 r on v.periodo = r.periodo and v.informante = r.informante and v.formulario = r.formulario and v.visita = r.visita
              inner join parametros p on unicoregistro
              inner join productos pp on r.producto = pp.producto
              inner join reltar rt on v.periodo = rt.periodo and v.panel = rt.panel and v.tarea = rt.tarea
              left join (SELECT periodo, informante, visita, formulario,
                            PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY cantpositivos) med_positivosref,
                            MAX(cantpositivos) max_positivosref
                        FROM (SELECT p.periodo, rf.periodo periodoref, rf.informante, rf.visita, rf.formulario,
                                sum(CASE WHEN tf.espositivo = 'S' THEN 1 ELSE 0 END) cantpositivos
                                FROM (SELECT periodo, periodoanterior, moverperiodos(periodoanterior, -11) periodolimite 
                                      FROM periodos) p 
                                LEFT JOIN relpre rf ON rf.periodo BETWEEN p.periodolimite and p.periodoanterior 
                                LEFT JOIN tipopre tf on rf.tipoprecio = tf.tipoprecio
                                GROUP BY p.periodo, rf.periodo, rf.informante, rf.visita, rf.formulario) q
                         GROUP BY periodo, informante, visita, formulario) rr on
                        v.periodo = rr.periodo and v.informante = rr.informante and v.visita = rr.visita and v.formulario = rr.formulario              
              left join personal per on v.encuestador = per.persona
              left join tareas ta on v.tarea = ta.tarea
              left join tipopre t on r.tipoprecio = t.tipoprecio
              left join tipopre t_1 on r.tipoprecio_1 = t_1.tipoprecio
              left join informantes i on v.informante = i.informante
              left join (SELECT informante, formulario, max(periodo) maxperiodoinformado
                      FROM relvis rv join razones z on rv.razon = z.razon 
                      WHERE espositivoformulario='S' 
                      GROUP BY rv.informante, rv.formulario ) as max_periodos on
                      max_periodos.informante = v.informante and max_periodos.formulario = v.formulario
            group by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario, v.visita, i.rubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(p.solo_cluster,pp."cluster"),v.razon,max_periodos.maxperiodoinformado,rt.modalidad, rr.max_positivosref, rr.med_positivosref
            order by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario, v.visita, i.rubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(p.solo_cluster,pp."cluster"),v.razon,max_periodos.maxperiodoinformado,rt.modalidad, rr.max_positivosref, rr.med_positivosref)`
            },
    },context);
}