"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'mobile_visita',
        tableName:'relvis',
        title:'visita mobile',
        editable:true, //puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:true,
        },
        fields:[
            {name:'periodo'        , typeName:'text'    , nullable:false            , allow:{update:false}, visible:false    },
            {name:'informante'     , typeName:'integer' , nullable:false            , allow:{update:false}                   },
            {name:'visita'         , typeName:'integer' , nullable:false , default:1, allow:{update:false}, visible:false    },
            {name:'formulario'     , typeName:'integer' , nullable:false            , allow:{update:false}                   },
            {name:'panel'          , typeName:'integer' , nullable:false            , allow:{update:true}, visible:false     },
            {name:'tarea'          , typeName:'integer' , nullable:false            , allow:{update:true}, visible:false     },
            {name:'razon'          , typeName:'integer' , nullable:false            , allow:{update:true}, clientSide:'controlarRazonesNegativas', serverSide:true},
            {name:'nombreencuestador'  , typeName:'text'                            , allow:{update:true}, visible:false },
            //{name:'adv'                , typeName:'text'    ,            clientSide: 'semaforoVisita', allow:{update:false}},
            {name:'raz__escierredefinitivoinf', typeName:'text'                                , allow:{update:false}, visible:false},
            {name:'raz__escierredefinitivofor', typeName:'text'                                , allow:{update:false}, visible:false},
            {name:'orden'         , typeName:'integer' , nullable:false             , allow:{update:false}, visible:false    },
        ],
        primaryKey:['periodo','informante','visita', 'formulario'],
        sortColumns:[{column:'orden'},{column:'visita'}],
        foreignKeys:[
            //{references:'informantes', fields:['informante']},
            //{references:'periodos'   , fields:['periodo'   ]},
            //{references:'formularios', fields:['formulario']},
            {references:'razones_encuestador',     fields:['razon'], displayFields:['nombrerazon', 'espositivoformulario']},
        ],
        softForeignKeys:[
            {references:'razones_encuestador', fields:['razon'], displayFields:['escierredefinitivoinf','escierredefinitivofor'], alias:'raz'},
        ],
        detailTables:[
            /*{table:'relpre', abr:'PRE', label:'precios', fields:['periodo','informante','visita','formulario']},
            {wScreen:'controles_formulario', abr:'C', label:'controles', fields:['periodo','informante','visita','formulario']},
            {table:'control_normalizables_sindato', abr:'NSD', label:'normalizables sin dato', fields:['periodo','informante','visita','formulario']},
            {table:'control_atributos', abr:'AFR', label:'atributos fuera de rango', fields:['periodo','informante','visita','formulario']},
            {table:'hdrexportarefectivossinprecio', abr:'ESP', label:'efectivos sin precio', fields:['periodo','informante','visita','formulario']},
            {table:'control_rangos', abr:'RAN', label:'Control de rangos de precios', fields:['periodo','informante','visita','formulario']},
            {table:'controlvigencias', abr:'VIG', label:'Control de atributo vigencia', fields:['periodo','informante']},
            */
        ],
        sql:{
            from:`(
                select v.periodo, v.informante, v.visita, v.formulario, v.panel, v.tarea, 
                  CASE WHEN v.razon = 0 THEN 1 ELSE v.razon END as razon,p.nombre || p.apellido as nombreencuestador,
                  f.orden
                  from relvis v
                    left join personal p on v.encuestador = p.persona 
                    left join formularios f on v.formulario=f.formulario
                  )`,
        }        
    },context);
}