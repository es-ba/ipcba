"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'formulario_emergencia',
        tableName:'renglon',
        title:'Formularios Emergencia',
        editable:false, //puedeEditar,
        fields:[
            {name:'periodo'               , typeName:'text'                                , allow:{update:false}        },
            {name:'informante'            , typeName:'integer'   },
            {name:'nombreinformante'      , typeName:'text'   },
            {name:'formulario'            , typeName:'integer'},
            {name:'nombreformulario'      , typeName:'text'   },
            {name:'orden'                 , typeName:'integer'   },
            {name:'producto'              , typeName:'text'   },
            {name:'observacion'           , typeName:'integer'},
            {name:'nombreproducto'        , typeName:'text'   },
            {name:'precio_1'              , typeName:'decimal' , title:'precioᵃ'},
            {name:'tipoprecio_1'          , typeName:'text'   , title:'TPᵃ'},
            {name:'precio'                , typeName:'decimal' },
            {name:'tipoprecio'            , typeName:'text'   , title:'TP'},
            {name:'comentariosrelpre'     , typeName:'text'   , title:'comentarios'},
            {name:'unidad'                , typeName:'text'   },
            {name:'marca'                 , typeName:'text'   },
            {name:'cc'                    , typeName:'text'   },
            {name:'gramaje'               , typeName:'text'   },
            {name:'gramaje_escurrido'     , typeName:'text'   },
            {name:'nombre'                , typeName:'text'   },
            {name:'envase'                , typeName:'text'   },
            {name:'litros'                , typeName:'text'   },
            {name:'ml'                    , typeName:'text'   },
            {name:'metros_por_rollo'      , typeName:'text'   },
            {name:'hojas'                 , typeName:'text'   },
            {name:'otros'                 , typeName:'text'   },
            {name:'grupo_prioridad'       , typeName:'integer'},
            {name:'prod_prioritario'      , typeName:'integer'},
            {name:'obs_no_unica'          , typeName:'integer'},
        ],
        primaryKey:['periodo','informante','formulario','producto','observacion'],
        sortColumns:[{column:'periodo'},{column:'informante'},{column:'formulario'},{column:'orden'},{column:'producto'},{column:'observacion'}],
        foreignKeys:[
            {references:'informantes' , fields:['informante']},
            {references:'productos'   , fields:['producto']},
        ],
        detailTables:[
        ],
        sql:{
            from:`(select 
                p.periodo
                ,p.informante
                ,nombreinformante
                ,direccion
                ,p.formulario
                ,nombreformulario
                ,fp.orden
                ,p.producto
                ,p.observacion
                ,nombreproducto
                ,precio_1
                ,tipoprecio_1
                ,precio
                ,tipoprecio
                ,comentariosrelpre
                ,a1 .valor as unidad
                ,a13.valor as marca
                ,a15.valor as cc
                ,a16.valor as gramaje
                ,a17.valor as gramaje_escurrido
                ,a22.valor as nombre
                ,a23.valor as envase
                ,a11.valor as litros
                ,a61.valor as ml
                ,a60.valor as metros_por_rollo
                ,a53.valor as hojas
                ,otros
                ,case when (select count(*) 
                    from relpre where (periodo, informante, visita, producto) = (p.periodo, p.informante, p.visita, p.producto) 
                    ) = 1 then 0 else p.observacion end obs_no_unica
                ,prioritario as prod_prioritario
                ,grupo_prioridad
            from relpre_1 p inner join informantes using(informante)
                 inner join formularios using(formulario)
                 inner join forprod fp using(formulario,producto)
                 inner join productos using(producto)
                 inner join periodos per using(periodo)
                 left join relatr a1  on a1 .periodo=p.periodo  and a1 .informante=p.informante and a1 .visita=p.visita and a1 .producto=p.producto and a1 .observacion=p.observacion and a1 .atributo=1  
                 left join relatr a13 on a13.periodo=p.periodo  and a13.informante=p.informante and a13.visita=p.visita and a13.producto=p.producto and a13.observacion=p.observacion and a13.atributo=13 
                 left join relatr a15 on a15.periodo=p.periodo  and a15.informante=p.informante and a15.visita=p.visita and a15.producto=p.producto and a15.observacion=p.observacion and a15.atributo=15 
                 left join relatr a16 on a16.periodo=p.periodo  and a16.informante=p.informante and a16.visita=p.visita and a16.producto=p.producto and a16.observacion=p.observacion and a16.atributo=16 
                 left join relatr a17 on a17.periodo=p.periodo  and a17.informante=p.informante and a17.visita=p.visita and a17.producto=p.producto and a17.observacion=p.observacion and a17.atributo=17 
                 left join relatr a22 on a22.periodo=p.periodo  and a22.informante=p.informante and a22.visita=p.visita and a22.producto=p.producto and a22.observacion=p.observacion and a22.atributo=22 
                 left join relatr a23 on a23.periodo=p.periodo  and a23.informante=p.informante and a23.visita=p.visita and a23.producto=p.producto and a23.observacion=p.observacion and a23.atributo=23 
                 left join relatr a11 on a11.periodo=p.periodo  and a11.informante=p.informante and a11.visita=p.visita and a11.producto=p.producto and a11.observacion=p.observacion and a11.atributo=11 
                 left join relatr a61 on a61.periodo=p.periodo  and a61.informante=p.informante and a61.visita=p.visita and a61.producto=p.producto and a61.observacion=p.observacion and a61.atributo=61 
                 left join relatr a60 on a60.periodo=p.periodo  and a60.informante=p.informante and a60.visita=p.visita and a60.producto=p.producto and a60.observacion=p.observacion and a60.atributo=60 
                 left join relatr a53 on a53.periodo=p.periodo  and a53.informante=p.informante and a53.visita=p.visita and a53.producto=p.producto and a53.observacion=p.observacion and a53.atributo=53 ,
                lateral (select string_agg(nombreatributo||':'||valor, ',') as otros 
                    from relatr a inner join atributos using(atributo) 
                    where a.periodo=p.periodo  and a.informante=p.informante and a.visita=p.visita and a.producto=p.producto and a.observacion=p.observacion and a.atributo not in (1,13,15,16,17,22,23)) as otros
            where prioritario is not null and grupo_prioridad is not null
                and per.periodo = (select max(periodo) from periodos where ingresando='N')
            order by 
                 p.periodo
                ,p.informante
                ,fp.orden
                ,p.producto
                ,p.observacion
            )`
       }        
    },context);
}