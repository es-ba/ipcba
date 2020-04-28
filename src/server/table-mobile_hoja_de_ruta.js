"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'mobile_hoja_de_ruta',
        tableName:'relvis',
        title:'Hoja de ruta mobile',
        editable:true, //puedeEditar,
        policy:'web',
        allow:{
            insert:false,
            delete:false,
            update:true,
        },
        fields:[
            {name:'periodo'            , typeName:'text'    , nullable:false            , allow:{update:false}, visible:false    },
            {name:'informante'         , typeName:'integer' , nullable:false            , allow:{update:false}, visible:false    },
            {name:'informante_div'     , typeName:'text'  , allow:{update:false}, clientSide:'parseInformante', title:'informante'   },
            {name:'visita'             , typeName:'integer' , nullable:false , default:1, allow:{update:false}, visible:false    },
            {name:'formularios'        , typeName:'jsonb'   , nullable:false            , allow:{update:false}, visible:false    },
            {name:'formularios_div'    , typeName:'text'  , allow:{update:false}, clientSide:'parseFormularios', title:'formularios'   },
            {name:'prod_div'           , typeName:'text'  , allow:{update:false}, clientSide:'parseProd'  , title:'prod'     },
            {name:'faltan_div'         , typeName:'text'  , allow:{update:false}, clientSide:'parseFaltan', title:'faltan'   },
            //{name:'prod'               , typeName:'text'    , nullable:false            , allow:{update:false}                   },
            {name:'panel'              , typeName:'integer' , nullable:false            , allow:{update:true}, visible:false     },
            {name:'tarea'              , typeName:'integer' , nullable:false            , allow:{update:true}, visible:false     },
            {name:'nombreencuestador'  , typeName:'text'                                , allow:{update:true}, visible:false     },
            {name:'encuestador'        , typeName:'text'                                , allow:{update:true}, visible:false     },
            {name:'adv'                , typeName:'text'    ,            clientSide: 'semaforo', allow:{update:false}},
            {name:'informantecompleto' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'direccion'          , typeName:'text'                                , allow:{update:true}, visible:false    },
            //{name:'raz__escierredefinitivoinf', typeName:'text'                                , allow:{update:false}, visible:false},
            //{name:'raz__escierredefinitivofor', typeName:'text'                                , allow:{update:false}, visible:false},
        ],
        primaryKey:['periodo','informante','visita'],
        sortColumns:[{column:'direccion'},{column:'visita'}],
        foreignKeys:[
            //{references:'informantes', fields:['informante']},
            //{references:'periodos'   , fields:['periodo'   ]},
            //{references:'personal'   , fields:[{source:'encuestador'  , target:'persona'  }]},
        ],
        detailTables:[
            //{table:'mobile_visita', abr:'V', label:'visita', fields:['periodo','informante','visita']},
        ],
        offline: {
            mode: 'master',
            details: ['mobile_visita', 'mobile_precios','mobile_atributos']
        },
        sql:{
            from:`
                (select v.periodo, v.informante, v.visita, 
                      max(rt.encuestador) as encuestador,
                      max(coalesce(p.nombre||' '||p.apellido, p.apellido, p.nombre, '')) as nombreencuestador,
                      v.panel, v.tarea,
                      jsonb_agg(jsonb_build_object('formulario',v.formulario,'nombreformulario',f.nombreformulario,'faltan',rp.faltan, 'adv',rp.adv, 'prod',prod,'nombrerazon',r.nombrerazon,'espositivoformulario',r.espositivoformulario) ORDER BY f.orden) as formularios, 
                      jsonb_build_object('informante',v.informante,'nombreinformante',i.nombreinformante,'direccion',i.direccion,'comentarios',ri.observaciones,'cantidad_periodos_sin_informacion', distanciaperiodos(v.periodo, max_periodos.maxperiodoinformado), 'contacto', i.contacto, 'telcontacto', i.telcontacto, 'web', i.web) as informantecompleto,
                      i.direccion
                      from relvis v
                        join formularios f on v.formulario=f.formulario
                        join informantes i on v.informante = i.informante 
                        join razones r on v.razon = r.razon
                        join reltar rt using (periodo, panel, tarea)
                        left join personal p on rt.encuestador = p.persona 
                        left join (select periodo, informante, visita, formulario, (sum(case when tipoprecio is null then 1 else 0 end))::text as faltan, (sum(case when true = true then 1 else 0 end))::text as adv, count(*)::text as prod
                            from relpre
                            group by periodo, informante, visita, formulario) rp on v.periodo = rp.periodo and v.informante = rp.informante and v.visita = rp.visita and v.formulario = rp.formulario
                        left join (select periodo, informante, visita, string_agg(observaciones,' | ') observaciones 
                            from  relinf
                            group by periodo, informante, visita) ri on v.periodo = ri.periodo and v.informante = ri.informante and v.visita = ri.visita,
                        lateral(
                         SELECT 
                        CASE WHEN COUNT(*) > 0 THEN max(periodo) ELSE null END AS maxperiodoinformado
                          FROM relvis rv
                          WHERE razon = 1 and rv.informante = v.informante
                        ) as max_periodos
                        --where v.periodo = 'a2018m10' and v.panel=1 and v.tarea=1
                      group by v.periodo, v.informante, i.nombreinformante, i.direccion, ri.observaciones,v.visita, v.panel, v.tarea, max_periodos.maxperiodoinformado, contacto, telcontacto, web
                  )
            `
        }        
    },context);
}