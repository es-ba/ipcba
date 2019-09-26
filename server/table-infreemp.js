"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='recepcionista';
    return context.be.tableDefAdapt({
        name:'infreemp',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'id_informante_reemplazante' , typeName:'integer'  , nullable:false, sequence:{name: 'secuencia_informantes_reemplazantes', firstValue: 1}},
            {name:'informante'                 , typeName:'integer'  , nullable:false            , allow:{update:puedeEditar}},
            {name:'direccionalternativa'       , typeName:'text'     ,                           , allow:{update:puedeEditar}},
            {name:'nombreinformantealternativo', typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'comentariorecep'            , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'comentarioana'              , typeName:'text'                                 , allow:{update:puedeEditar}},
            {name:'reemplazo'                  , typeName:'integer'                              , allow:{update:puedeEditar}},
            {name:'alta_fec'                   , typeName:'timestamp'                            , allow:{update:false}},
        ],
        primaryKey:['informante', 'direccionalternativa'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
        ]
    },context);
}