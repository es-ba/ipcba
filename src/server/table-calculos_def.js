"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calculos_def',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'definicion'                   , typeName:'text'                  },
            {name:'principal'                    , typeName:'boolean'                  },
            {name:'agrupacionprincipal'          , typeName:'text' , nullable:false , default:'A', defaultValue:'A'},
            {name:'basado_en_extraccion_calculo' , typeName:'integer'               },
            {name:'basado_en_extraccion_muestra' , typeName:'integer'               },
            {name:'para_rellenado_de_base'       , typeName:'boolean' , nullable:false , default:false, defaultValue:false},
            {name:'grupo_raiz'                   , typeName:'text'                  },
            {name:'rellenante_de'                , typeName:'integer'               },
        ],
        primaryKey:['calculo'],
        foreignKeys:[
            {references:'calculos_def', fields:[{source:'basado_en_extraccion_calculo', target:'calculo'}], alias:'caldef', onUpdate: 'cascade'},
            {references:'muestras', fields:[{source:'basado_en_extraccion_muestra'    , target:'muestra'}]},
        ],
        constraints:[
            {constraintType:'unique', fields:['principal']}
        ]

    }, context);
}