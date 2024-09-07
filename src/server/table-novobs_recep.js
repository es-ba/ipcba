"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' ||context.user.usu_rol ==='analista' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'novobs_recep',
        //title:'Altas y bajas manuales del cálculo',
        tableName:'novobs',
        editable:puedeEditar,
        allow: {
            insert: false,
            delete: false,
            update: puedeEditar,
            import: false,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'calculo'                          , typeName:'integer' , nullable:false, visible: false, allow:{update:false}},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}},
            {name:'informante'                       , typeName:'integer' , nullable:false , allow:{update:false}},
            {name:'observacion'                      , typeName:'integer' , nullable:false , allow:{update:false}},
            {name:'visita'                           , typeName:'integer'                  , allow:{update:false}},
            {name:'usuario'                          , typeName:'text'                     , allow:{update:false}},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}},
            {name:'nombreformulario'                 , typeName:'text'                     , allow:{update:false}},
            {name:'estado'                           , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'comentariosrelpre'                , typeName:'text'                     , allow:{update:false}},
            {name:'esvisiblecomentarioendm'          , typeName:'boolean'                  , allow:{update:false}},
            {name:'comentarios_recep'                , typeName:'text'                     , allow:{update:puedeEditar}},
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
                          CASE WHEN n.modi_usu = 'cvpowner' or n.modi_usu = 'postgres' THEN n.usuario ELSE n.modi_usu END as usuario,
                          v.encuestador||':'||s.nombre||' '||s.apellido as encuestador,
                          v.recepcionista||':'||c.nombre||' '||c.apellido as recepcionista,
                          r.formulario||':'||fo.nombreformulario as nombreformulario, 
                          panel, tarea,
                          n.estado, r.comentariosrelpre, r.esvisiblecomentarioendm, n.comentarios_recep
                    from novobs n left join perfiltro f on n.periodo = f.periodo
                        left join (SELECT * FROM relpre WHERE visita = 1) r on r.periodo = f.periodo and n.producto = r.producto and n.informante = r.informante and n.observacion = r.observacion
                        left join formularios fo on r.formulario = fo.formulario
                        left join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita 
                        left join personal s on s.persona = v.encuestador
                        left join personal c on c.persona = v.recepcionista
                    where revisar_recep
                    )`
        }    
    },context);
}