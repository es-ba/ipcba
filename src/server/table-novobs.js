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
            {name:'periodo'                          , typeName:'text'    , nullable:false                , allow:{update:puedeEditar}, inTable: true},
            {name:'calculo'                          , typeName:'integer' , nullable:false, visible: false, allow:{update:puedeEditar}, inTable: true},
            {name:'producto'                         , typeName:'text'    , nullable:false                , allow:{update:puedeEditar}, inTable: true},
            {name:'informante'                       , typeName:'integer' , nullable:false                , allow:{update:puedeEditar}, inTable: true},
            {name:'observacion'                      , typeName:'integer' , nullable:false                , allow:{update:puedeEditar}, inTable: true},
            {name:'visita'                           , typeName:'integer'                  , allow:{update:false}, inTable: false},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}, inTable: true},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}, inTable: false},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}, inTable: false},
            {name:'nombreformulario'                 , typeName:'text'                     , allow:{update:false}, inTable: false},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}, inTable: false},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}, inTable: false},
            {name:'estado'                           , typeName:'text'    , nullable:false , allow:{update:puedeEditar}, inTable: true},
            {name:'comentariosrelpre'                , typeName:'text'                     , allow:{update:puedeEditar}, table:'relpre'},
            {name:'esvisiblecomentarioendm'          , typeName:'boolean'                  , allow:{update:puedeEditar}, table:'relpre'},
            {name:'revisar_recep'   ,title:'Rev'     , typeName:'boolean'                  , allow:{update:puedeEditar}, inTable: true},
            {name:'comentarios_recep'                , typeName:'text'                     , allow:{update:puedeEditar||puedeEditarRecep}, inTable: true},
        ],
        primaryKey:['periodo','calculo','producto','informante','observacion'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'calculos', fields:['periodo','calculo']},            
        ],
        sql:{
            from: `(select n.periodo, n.calculo, n.producto, n.informante, n.observacion, r.visita,
                          CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                          v.encuestador||':'||s.nombre||' '||s.apellido as encuestador,
                          v.recepcionista||':'||c.nombre||' '||c.apellido as recepcionista,
                          fo.nombreformulario, 
                          panel, tarea,
                          n.estado, n.revisar_recep, r.comentariosrelpre, r.esvisiblecomentarioendm, n.comentarios_recep
                    from novobs n left join perfiltro f on n.periodo = f.periodo
                        left join (SELECT * FROM relpre WHERE visita = 1) r on r.periodo = f.periodo and n.producto = r.producto and n.informante = r.informante and n.observacion = r.observacion
                        left join formularios fo on r.formulario = fo.formulario
                        left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita 
                        left join personal s on s.persona = v.encuestador
                        left join personal c on c.persona = v.recepcionista
                    )`,
        isTable: true,
        }    
    },context);
}