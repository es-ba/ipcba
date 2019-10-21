"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_normalizables_sindato',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'producto'                     , typeName:'text'    },
            {name:'nombreproducto'               , typeName:'text'    },
            {name:'observacion'                  , typeName:'integer', title:'obs'},
            {name:'informante'                   , typeName:'integer', title:'inf'},
            {name:'atributo'                     , typeName:'integer' },
            {name:'valor'                        , typeName:'text'    },
            {name:'visita'                       , typeName:'integer', title:'vis'},
            {name:'validar_con_valvalatr'        , typeName:'boolean' },
            {name:'nombreatributo'               , typeName:'text'    },
            {name:'valornormal'                  , typeName:'decimal'  },
            {name:'orden'                        , typeName:'integer' },
            {name:'normalizable'                 , typeName:'text'    },
            {name:'tiponormalizacion'            , typeName:'text'    },
            {name:'alterable'                    , typeName:'text'    },
            {name:'prioridad'                    , typeName:'integer' },
            {name:'operacion'                    , typeName:'text'    },
            {name:'rangodesde'                   , typeName:'decimal', title:'desde'},
            {name:'rangohasta'                   , typeName:'decimal', title:'hasta'},
            {name:'orden_calculo_especial'       , typeName:'integer' },
            {name:'tipo_promedio'                , typeName:'text'    },
            {name:'formulario'                   , typeName:'integer', title:'for'},
            {name:'precio'                       , typeName:'decimal'  },
            {name:'tipoprecio'                   , typeName:'text'    },
            {name:'comentariosrelpre'            , typeName:'text'    },
            {name:'cambio'                       , typeName:'text'    },
            {name:'precionormalizado'            , typeName:'decimal'  },
            {name:'especificacion'               , typeName:'integer', title:'esp', visible:false},
            {name:'ultima_visita'                , typeName:'boolean', visible:false}, 
            {name:'panel'                        , typeName:'integer' },
            {name:'tarea'                        , typeName:'integer' },     
            {name:'encuestador'                  , typeName:'text', title:'enc'},     
            {name:'recepcionista'                , typeName:'text', title:'rec'},     
        ],
        primaryKey:['periodo','producto','observacion','informante','visita', 'atributo'],
        sql:{
            isTable: false,
        },
    });
}