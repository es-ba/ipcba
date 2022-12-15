"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
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
            {name:'positivosref'         ,typeName:'integer'},
            {name:'positivosant'         ,typeName:'integer'},
            {name:'positivosact'         ,typeName:'integer'},
            {name:'maxperiodoinformado'  ,typeName:'text'   }, 
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        foreignKeys:[
            {references:'rubros'     , fields:['rubro']      },
            {references:'formularios', fields:['formulario'] },
        ],
        sql:{from:`(select v.periodo, v.informante, v.visita, v.panel, v.tarea, ta.operativo, v.formulario, 
            sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivosact,
            sum(CASE WHEN t_1.espositivo = 'S' THEN 1 ELSE 0 END) as positivosant,
            sum(CASE WHEN t_ref.espositivo = 'S' THEN 1 ELSE 0 END) as positivosref,
            i.rubro, v.encuestador, per.nombre||' '||per.apellido as encuestadornombre, coalesce(p.solo_cluster,pp."cluster") as "cluster"
            ,max_periodos.maxperiodoinformado
            from relvis v
              inner join relpre_1 r on v.periodo = r.periodo and v.informante = r.informante and v.formulario = r.formulario and v.visita = r.visita
              inner join parametros p on unicoregistro
              inner join productos pp on r.producto = pp.producto
              left join relpre r_ref on r_ref.periodo = p.periodoreferenciaparapreciospositivos and r.informante = r_ref.informante 
                   and r.producto = r_ref.producto and r.observacion = r_ref.observacion and r.visita = r_ref.visita
              left join personal per on v.encuestador = per.persona
              left join tareas ta on v.tarea = ta.tarea
              left join tipopre t on r.tipoprecio = t.tipoprecio
              left join tipopre t_1 on r.tipoprecio_1 = t_1.tipoprecio
              left join tipopre t_ref on r_ref.tipoprecio = t_ref.tipoprecio   
              left join informantes i on v.informante = i.informante
              left join (SELECT informante, formulario, max(periodo) maxperiodoinformado
                      FROM relvis rv join razones z on rv.razon = z.razon 
                      WHERE espositivoformulario='S' 
                      GROUP BY rv.informante, rv.formulario ) as max_periodos on
                      max_periodos.informante = v.informante and max_periodos.formulario = v.formulario
            group by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario, v.visita, i.rubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(p.solo_cluster,pp."cluster"),max_periodos.maxperiodoinformado
            order by v.periodo, v.informante, v.panel, v.tarea, ta.operativo, v.formulario, v.visita, i.rubro, v.encuestador, per.nombre||' '||per.apellido, coalesce(p.solo_cluster,pp."cluster"),max_periodos.maxperiodoinformado)`
            },
    },context);
}