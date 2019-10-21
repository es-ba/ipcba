"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'agrupaciones',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'agrupacion'                  , typeName:'text'    , nullable:false, postInput:'upperSpanish'},
            {name:'nombreagrupacion'            , typeName:'text'    , isName:true},
            {name:'paravarioshogares'           , typeName:'boolean' , nullable:false, defaultValue:false},
            {name:'calcular_junto_grupo'        , typeName:'text'      },
            {name:'valoriza'                    , typeName:'boolean'   ,  defaultValue:false},
            {name:'tipo_agrupacion'             , typeName:'text'      , postInput:'upperSpanish', options:['INDICE', 'CANASTA', 'GENERAL'] },
        ],
        primaryKey:['agrupacion'],
        constraints:[
            {constraintType:'check', consName:"texto invalido en nombreagrupacion de tabla agrupaciones", expr:"comun.cadena_valida(nombreagrupacion, 'castellano')"}
        ]
    },context);
}