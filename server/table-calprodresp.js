"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'calprodresp',
        allow: {
            insert: false,
            delete: false,
            update: puedeEditar,
            import: false,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'calculo'                          , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'producto'                         , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'estimacion'                       , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'responsable'                      , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'revisado'                         , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'observaciones'                    , typeName:'text'    , allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','calculo','producto'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'calculos', fields:['periodo','calculo']},
        ],
        sortColumns:[{column:'periodo'}, {column:'calculo'}, {column:'producto'}],
        sql:{
            from: `(select p.periodo, p.calculo, p.producto, c.estimacion, p.revisado, p.responsable, p.observaciones
                    FROM calprodresp p
                    LEFT JOIN calculos c ON c.periodo = p.periodo AND c.calculo = p.calculo
                    )`                  
        }  
    },context);
}