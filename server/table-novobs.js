"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    var puedeEditarRecep = context.user.usu_rol ==='recepcionista';
    return context.be.tableDefAdapt({
        name:'novobs',
        //title:'Altas y bajas manuales del cálculo',
        editable:puedeEditar,
        allow: {
            insert: puedeEditar,
            delete: false,
            update: puedeEditar,
            import: puedeEditar,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false                , allow:{update:puedeEditar}},
            {name:'calculo'                          , typeName:'integer' , nullable:false, visible: false, allow:{update:puedeEditar}},
            {name:'producto'                         , typeName:'text'    , nullable:false                , allow:{update:puedeEditar}},
            {name:'informante'                       , typeName:'integer' , nullable:false                , allow:{update:puedeEditar}},
            {name:'observacion'                      , typeName:'integer' , nullable:false                , allow:{update:puedeEditar}},
            {name:'visita'                           , typeName:'text'                     , allow:{update:false}},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}},
            {name:'nombreformulario'                 , typeName:'text'                     , allow:{update:false}},
            {name:'panel'                            , typeName:'text'                     , allow:{update:false}},
            {name:'tarea'                            , typeName:'text'                     , allow:{update:false}},
            {name:'estado'                           , typeName:'text'    , nullable:false , allow:{update:puedeEditar}},
            {name:'revisar_recep'   ,title:'Rev'     , typeName:'boolean'                  , allow:{update:puedeEditar}},
            {name:'comentarios'                      , typeName:'text'                     , allow:{update:puedeEditar}},
            {name:'comentarios_recep'                , typeName:'text'                     , allow:{update:puedeEditar||puedeEditarRecep}},
        ],
        primaryKey:['periodo','calculo','producto','informante','observacion'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'calculos', fields:['periodo','calculo']},            
        ],
        sql:{
            from: `(select n.periodo, n.calculo, n.producto, n.informante, n.observacion, string_agg(r.visita::text,'|' order by r.visita) as visita,
                          CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                          string_agg(distinct v.encuestador||':'||s.nombre||' '||s.apellido,'|') as encuestador,
                          string_agg(distinct v.recepcionista||':'||c.nombre||' '||c.apellido,'|') as recepcionista,
                          string_agg(distinct fo.nombreformulario,'|') as nombreformulario, 
                          string_agg(distinct panel::text, '|') as panel, string_agg(distinct tarea::text,'|') as tarea,
                          n.estado, n.revisar_recep, n.comentarios, n.comentarios_recep
                    from novobs n left join perfiltro f on n.periodo = f.periodo
                        left join relpre r on r.periodo = f.periodo and n.producto = r.producto and n.informante = r.informante and n.observacion = r.observacion
                        left join formularios fo on r.formulario = fo.formulario
                        left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita 
                        left join personal s on s.persona = v.encuestador
                        left join personal c on c.persona = v.recepcionista
                    group by n.periodo, n.calculo, n.producto, n.informante, n.observacion, n.modi_usu, n.estado
                    )`
                   
        }    
    },context);
}