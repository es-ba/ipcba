"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'razones',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'razon'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'nombrerazon'            , typeName:'text'    , nullable:false, allow:{update:puedeEditar}, isName:true},
            {name:'espositivoinformante'   , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'espositivoformulario'   , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'escierredefinitivoinf'  , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'escierredefinitivofor'  , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'visibleparaencuestador' , typeName:'text'    , nullable:false, default:'S', allow:{update:puedeEditar}},
            {name:'escierretemporalfor'    , typeName:'text'    , default:'N', allow:{update:puedeEditar}},
        ],
        primaryKey:['razon'],

    },context);
}