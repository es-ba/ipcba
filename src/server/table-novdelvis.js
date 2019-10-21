"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='recep_gabinete';
    return context.be.tableDefAdapt({
        name:'novdelvis',
        editable:puedeEditar,
        allow: {
            insert: puedeEditar,
            delete: false,
            update: puedeEditar,
            import: false,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false                       , inTable: true},
            {name:'informante'                       , typeName:'integer' , nullable:false                       , inTable: true},
            {name:'visita'                           , typeName:'integer' , nullable:false                       , inTable: true},
            {name:'formulario'                       , typeName:'integer' , nullable:false                       , inTable: true},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}, inTable: true},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}, inTable: false},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}, inTable: false},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}, inTable: false},
            {name:'confirma'                         , typeName:'boolean'                                        , inTable: true},
            {name:'comentarios'                      , typeName:'text'                                           , inTable: true},
        ],
        sortColumns:[{column:'periodo', order:-1}],
        primaryKey:['periodo','informante','visita', 'formulario'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'formularios', fields:['formulario']},
        ],
        sql:{
            from: `(
                select n.periodo,
                  n.informante, 
                  n.visita,
                  n.formulario,
                  CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                  string_agg(distinct v.encuestador||':'||s.nombre||' '||s.apellido,'|') as encuestador, 
                  v.panel,
                  v.tarea,
                  n.confirma,
                  n.comentarios
                from 
                  novdelvis n 
                    left join relvis v on 
                      n.periodo = v.periodo and n.informante = v.informante and n.formulario = v.formulario and n.visita = v.visita 
                    left join personal s on 
                      s.persona = v.encuestador
                    left join personal c on 
                      c.persona = v.recepcionista
                      group by n.periodo, n.informante, n.visita, n.formulario, v.panel, v.tarea
                )`,
                isTable: true,
        }    
    },context);
}