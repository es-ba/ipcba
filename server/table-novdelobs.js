"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='recep_gabinete';
    return context.be.tableDefAdapt({
        name:'novdelobs',
        editable:puedeEditar,
        allow: {
            insert: puedeEditar,
            delete: false,
            update: puedeEditar,
            import: false,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false                       },
            {name:'producto'                         , typeName:'text'    , nullable:false                       },
            {name:'informante'                       , typeName:'integer' , nullable:false                       },
            {name:'observacion'                      , typeName:'integer' , nullable:false                       },
            {name:'visita'                           , typeName:'integer' , nullable:false                       },
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}},
            {name:'nombreformulario'                 , typeName:'text'                     , allow:{update:false}},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'infopre'                          , typeName:'text'                     , allow:{update:false}},
            {name:'infopreant'                       , typeName:'text'                     , allow:{update:false}},
            {name:'confirma'                         , typeName:'boolean'                                        },
            {name:'comentarios'                      , typeName:'text'                                           },
        ],
        sortColumns:[{column:'periodo', order:-1}],
        primaryKey:['periodo','producto','informante','observacion', 'visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from: `(
                select n.periodo,
                  n.producto, 
                  n.informante, 
                  n.observacion, 
                  n.visita, 
                  CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                  string_agg(distinct v.encuestador||':'||s.nombre||' '||s.apellido,'|') as encuestador, 
                  string_agg(distinct fo.nombreformulario,'|') as nombreformulario,
                  v.panel,
                  v.tarea,
                  NULLIF((coalesce(r.precio::text||';','')||coalesce(r.tipoprecio||';','')||coalesce(r.cambio,'')),'') as infopre,
                  NULLIF((coalesce(rpa.precio_1::text||';','')||coalesce(rpa.tipoprecio_1||';','')||coalesce(rpa.cambio_1,'')),'') as infopreant,
                  n.confirma,
                  n.comentarios
                from 
                  novdelobs n 
                    left join relpre r on 
                      r.periodo = n.periodo and n.producto = r.producto and n.informante = r.informante and n.observacion = r.observacion and n.visita = r.visita
                    left join formularios fo on 
                      r.formulario = fo.formulario
                    left join relvis v on 
                      r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita 
                    left join personal s on 
                      s.persona = v.encuestador
                    left join personal c on 
                      c.persona = v.recepcionista
                    left join relpre_1 rpa on 
                      n.periodo = rpa.periodo and n.producto = rpa.producto and n.observacion = rpa.observacion and n.informante = rpa.informante and n.visita = rpa.visita  
                group by n.periodo, n.producto, n.informante, n.observacion, n.visita, v.panel, v.tarea, r.precio, r.tipoprecio, r.cambio, rpa.precio_1, rpa.tipoprecio_1, rpa.cambio_1
                )`
        }    
    },context);
}