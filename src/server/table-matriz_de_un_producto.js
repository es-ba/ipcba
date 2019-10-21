"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'matriz_de_un_producto',
        tableName:'matrizresultados',
        title:'Matriz de precios e imputados de un producto',
        editable:false, //puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'tipoinformante'     , typeName:'text'                                , allow:{update:false},title:'ti'        },
            {name:'periodo'            , typeName:'text'    , nullable:false            , allow:{update:false}                   },
            {name:'producto'           , typeName:'text'    , nullable:false            , allow:{update:false}                   },
            {name:'informante'         , typeName:'integer' , nullable:false            , allow:{update:false}                   },
            {name:'observacion'        , typeName:'integer' , nullable:false            , allow:{update:false}                   },
            {name:'celda1_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes1'        },
            {name:'celda2_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes2'        },
            {name:'celda3_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes3'        },
            {name:'celda4_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes4'        },
            {name:'celda5_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes5'        },
            {name:'celda6_div'         , typeName:'text'    , allow:{update:false}, clientSide:'parseCelda', title:'mes6'        },
            
            {name:'celda1' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'celda2' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'celda3' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'celda4' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'celda5' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
            {name:'celda6' , typeName:'jsonb'   , nullable:false            , allow:{update:true}, visible:false     },
 
            //{name:'celda1' , typeName:'jsonb'   , nullable:false            , allow:{update:false}, clientSide:'parseCelda', title:'mes1'},
            //{name:'celda2' , typeName:'jsonb'   , nullable:false            , allow:{update:false}, clientSide:'parseCelda', title:'mes2'},
            /*
            {name:'promobs_1'                    ,typeName:'decimal', allow:{update:false}},
            {name:'precioobservado_1'            ,typeName:'decimal', allow:{update:false}},
            {name:'impobs_1'                     ,typeName:'text'   , allow:{update:false}},
            {name:'antiguedadexcluido_1'         ,typeName:'integer', allow:{update:false}},
            {name:'antiguedadsinprecio_1'        ,typeName:'integer', allow:{update:false}},
            {name:'antiguedadconprecio_1'        ,typeName:'integer', allow:{update:false}},
            {name:'variacion_1'                  ,typeName:'decimal', allow:{update:false}},
            {name:'tipoprecio_1'                 ,typeName:'text'   , allow:{update:false}},
            {name:'razon_1'                      ,typeName:'integer', allow:{update:false}},
            {name:'atributo_1'                   ,typeName:'text'   , allow:{update:false}},
            */
        ],
        primaryKey:['periodo','producto','informante','observacion'],
        sortColumns:[{column:'tipoinformante'},{column:'informante'},{column:'observacion'}],
        foreignKeys:[
            {references:'informantes' , fields:['informante']},
            {references:'productos'   , fields:['producto']},
        ],
        detailTables:[
            //{table:'mobile_visita', abr:'V', label:'visita', fields:['periodo','informante','visita']},
        ],
        /*
        offline: {
            mode: 'master',
            details: ['mobile_hoja_de_ruta', 'mobile_visita', 'mobile_precios','mobile_atributos']
        },*/
        sql:{
            from:`
                (select tipoinformante, periodo6 periodo, producto, informante, observacion, 
                  jsonb_build_object('variacion',case when variacion_1<>0 then variacion_1||'%' else null end,
                                     'tpr',case when tipoprecio_1<>'P' then tipoprecio_1 else '' end ||case when razon_1<> 1 then razon_1::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_1,0)=0 THEN promobs_1 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_1,0)>0 THEN promobs_1 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_1, -1) - coalesce(precioobservado_1, -1)) > 0.01 then precioobservado_1 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_1,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_1<>'R' or coalesce(AntiguedadExcluido_1,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_1 IS NULL THEN antiguedadconprecio_1
                                                            ELSE antiguedadsinprecio_1
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_1,'R') <> 'R' THEN impobs_1 ELSE NULL END,
                                     'atributo',atributo_1) as celda1,
                  jsonb_build_object('variacion',case when variacion_2<>0 then variacion_2||'%' else null end,
                                     'tpr',case when tipoprecio_2<>'P' then tipoprecio_2 else '' end ||case when razon_2<> 1 then razon_2::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_2,0)=0 THEN promobs_2 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_2,0)>0 THEN promobs_2 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_2, -1) - coalesce(precioobservado_2, -1)) > 0.01 then precioobservado_2 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_2,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_2<>'R' or coalesce(AntiguedadExcluido_2,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_2 IS NULL THEN antiguedadconprecio_2
                                                            ELSE antiguedadsinprecio_2
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_2,'R') <> 'R' THEN impobs_2 ELSE NULL END,
                                     'atributo',atributo_2) as celda2,                  
                  jsonb_build_object('variacion',case when variacion_3<>0 then variacion_3||'%' else null end,
                                     'tpr',case when tipoprecio_3<>'P' then tipoprecio_3 else '' end ||case when razon_3<> 1 then razon_3::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_3,0)=0 THEN promobs_3 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_3,0)>0 THEN promobs_3 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_3, -1) - coalesce(precioobservado_3, -1)) > 0.01 then precioobservado_3 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_3,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_3<>'R' or coalesce(AntiguedadExcluido_3,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_3 IS NULL THEN antiguedadconprecio_3
                                                            ELSE antiguedadsinprecio_3
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_3,'R') <> 'R' THEN impobs_3 ELSE NULL END,
                                     'atributo',atributo_3) as celda3,                  
                  jsonb_build_object('variacion',case when variacion_4<>0 then variacion_4||'%' else null end,
                                     'tpr',case when tipoprecio_4<>'P' then tipoprecio_4 else '' end ||case when razon_4<> 1 then razon_4::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_4,0)=0 THEN promobs_4 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_4,0)>0 THEN promobs_4 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_4, -1) - coalesce(precioobservado_4, -1)) > 0.01 then precioobservado_4 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_4,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_4<>'R' or coalesce(AntiguedadExcluido_4,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_4 IS NULL THEN antiguedadconprecio_4
                                                            ELSE antiguedadsinprecio_4
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_4,'R') <> 'R' THEN impobs_4 ELSE NULL END,
                                     'atributo',atributo_4) as celda4,
                  jsonb_build_object('variacion',case when variacion_5<>0 then variacion_5||'%' else null end,
                                     'tpr',case when tipoprecio_5<>'P' then tipoprecio_5 else '' end ||case when razon_5<> 1 then razon_5::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_5,0)=0 THEN promobs_5 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_5,0)>0 THEN promobs_5 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_5, -1) - coalesce(precioobservado_5, -1)) > 0.01 then precioobservado_5 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_5,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_5<>'R' or coalesce(AntiguedadExcluido_5,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_5 IS NULL THEN antiguedadconprecio_5
                                                            ELSE antiguedadsinprecio_5
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_5,'R') <> 'R' THEN impobs_5 ELSE NULL END,
                                     'atributo',atributo_5) as celda5,                                     
                  jsonb_build_object('variacion',case when variacion_6<>0 then variacion_6||'%' else null end,
                                     'tpr',case when tipoprecio_6<>'P' then tipoprecio_6 else '' end ||case when razon_6<> 1 then razon_6::text else '' end,
                                     'promobs', CASE WHEN coalesce(antiguedadexcluido_6,0)=0 THEN promobs_6 ELSE NULL END,
                                     'xpromobs', CASE WHEN coalesce(antiguedadexcluido_6,0)>0 THEN promobs_6 ELSE NULL END,
                                     'precioobservado',CASE WHEN ABS(coalesce(promobs_6, -1) - coalesce(precioobservado_6, -1)) > 0.01 then precioobservado_6 ELSE NULL END,
                                     'excluido', CASE WHEN coalesce(antiguedadexcluido_6,0)>0 THEN 'X' ELSE NULL END,
                                     'antiguedadprecio',CASE WHEN impobs_6<>'R' or coalesce(AntiguedadExcluido_6,0)>0 THEN
                                                            CASE WHEN antiguedadsinprecio_6 IS NULL THEN antiguedadconprecio_6
                                                            ELSE antiguedadsinprecio_6
                                                            END
                                                        ELSE null
                                                        END,
                                     'impobs',CASE WHEN coalesce(impobs_6,'R') <> 'R' THEN impobs_6 ELSE NULL END,
                                     'atributo',atributo_6) as celda6
                from matrizresultados)`
        }        
    },context);
}