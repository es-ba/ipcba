"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'precios_porcentaje_positivos_y_anulados_ref',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'informante'           ,typeName:'integer'},
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'encuestador'          ,typeName:'text'   },
            {name:'encuestadornombre'    ,typeName:'text'   },
            {name:'operativo'            ,typeName:'text'   },
            {name:'formulario'           ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'rubro'                ,typeName:'integer'},
            {name:'preciospotenciales'   ,typeName:'integer'},
            {name:'positivosact'         ,typeName:'integer'},
            {name:'anulados'             ,typeName:'integer'},
            {name:'porcentaje'           ,typeName:'text'   },            
            {name:'atributospotenciales' ,typeName:'integer'},
            {name:'atributospositivos'   ,typeName:'integer'},
            {name:'porcatributos'        ,typeName:'text'   },            
            {name:'positivosref'         ,typeName:'integer'},
            {name:'positivosant'         ,typeName:'integer'},
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        foreignKeys:[
            {references:'rubros'     , fields:['rubro']      },
            {references:'formularios', fields:['formulario'] },
        ],
        sql:{
            from:`(select v.periodo, v.informante, v.visita, v.panel, v.tarea, ta.operativo, v.formulario, count(*) preciospotenciales,
            sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END) as positivosact, 
            sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END) as anulados,
            ((sum(CASE WHEN t.espositivo = 'S' THEN 1 ELSE 0 END)+sum(CASE WHEN t.espositivo = 'N' and t.visibleparaencuestador = 'N' THEN 1 ELSE 0 END))*100/count(*))::text||'%' as porcentaje,
            sum(a.atributospotenciales) atributospotenciales, sum(a.atributospositivos) atributospositivos, 
            CASE WHEN sum(a.atributospotenciales)>0 THEN round((sum(a.atributospositivos)/sum(a.atributospotenciales)*100))::text||'%' ELSE '0%' END as porcatributos, 
            i.rubro, v.encuestador, per.nombre||' '||per.apellido as encuestadornombre,
            sum(CASE WHEN t_1.espositivo = 'S' THEN 1 ELSE 0 END) as positivosant, 
            sum(CASE WHEN tref.espositivo = 'S' THEN 1 ELSE 0 END) as positivosref
            from cvp.relvis v
              inner join cvp.relpre_1 r_1 on v.periodo = r_1.periodo and v.informante = r_1.informante and v.formulario = r_1.formulario and v.visita = r_1.visita
              inner join cvp.parametros par on unicoregistro
              left join cvp.relpre r on r.periodo = par.periodoreferenciaparapreciospositivos and r.producto= r_1.producto and r.observacion = r_1.observacion and r.informante = r_1.informante and r.visita = r_1.visita
              left join cvp.personal per on v.encuestador = per.persona
              left join cvp.tareas ta on v.tarea = ta.tarea
              left join cvp.tipopre t on r_1.tipoprecio = t.tipoprecio
              left join cvp.tipopre t_1 on r_1.tipoprecio_1 = t_1.tipoprecio
              left join cvp.tipopre tref on r.tipoprecio = tref.tipoprecio
              left join cvp.informantes i on v.informante = i.informante,
              lateral (select pro.producto, count(distinct pa.atributo) atributospotenciales, CASE WHEN t.espositivo = 'S' THEN count(distinct pa.atributo) ELSE 0 END as atributospositivos
                       from cvp.productos pro left join cvp.prodatr pa on pro.producto = pa.producto
                       where r.producto = pro.producto
                       group by pro.producto) a
            group by v.periodo, v.informante, v.visita, v.panel, v.tarea, ta.operativo, v.formulario, i.rubro, v.encuestador, per.nombre||' '||per.apellido
            order by v.periodo, v.informante, v.visita, v.panel, v.tarea, ta.operativo, v.formulario, i.rubro, v.encuestador, per.nombre||' '||per.apellido)`
            },
    },context);
}