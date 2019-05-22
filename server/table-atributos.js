"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'atributos',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'atributo'                    , typeName:'integer', nullable:false},
            {name:'nombreatributo'              , typeName:'text'   , isName:true   },
            {name:'tipodato'                    , typeName:'text'   , nullable:false},
            {name:'abratributo'                 , typeName:'text'      },
            {name:'escantidad'                  , typeName:'text', default:'N', defaultValue:'N'},
            {name:'unidaddemedida'              , typeName:'text'      },
            {name:'es_vigencia'                 , typeName:'boolean'   },
            {name:'valorinicial'                , typeName:'text'      },
            {name:'visible'                     , typeName:'text', default:'S', defaultValue:'S'},
        ],
        primaryKey:['atributo'],
        foreignKeys:[
            {references:'unidades', fields:[
                {source:'unidaddemedida'         , target:'unidad'     },
            ]},
        ],

    }, context);
}