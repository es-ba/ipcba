"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    return context.be.tableDefAdapt({
        name:'cuadros',
        title:'textos de los cuadros',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'cuadro'            , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'descripcion'       , typeName:'text'    , isName:true, allow:{update:puedeEditar}},
            {name:'funcion'           , typeName:'text'    , allow:{update:false}      },
            {name:'parametro1'        , typeName:'text'    , allow:{update:false}      },
            {name:'periodo'           , typeName:'text'    , allow:{update:false}      },
            {name:'nivel'             , typeName:'integer' , allow:{update:false}      },
            {name:'grupo'             , typeName:'text'    , allow:{update:false}      },
            {name:'agrupacion'        , typeName:'text'    , allow:{update:false}      },
            {name:'encabezado'        , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'pie'               , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'ponercodigos'      , typeName:'boolean' , allow:{update:false}      },
            {name:'agrupacion2'       , typeName:'text'    , allow:{update:false}      },
            {name:'hogares'           , typeName:'integer' , allow:{update:false}      },
            {name:'pie1'              , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'cantdecimales'     , typeName:'integer' , allow:{update:false}      },
            {name:'desde'             , typeName:'text'    , allow:{update:false}      },
            {name:'orden'             , typeName:'text'    , allow:{update:false}      },
            {name:'encabezado2'       , typeName:'text'    , allow:{update:false}      },
        ],
        primaryKey:['cuadro'],

    },context);
}