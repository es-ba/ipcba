"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
    	name:'migra_relpre',
        title:'Relpre',
        tableName:'relpre',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false             , allow:{update:puedeEditar}                   },
            {name:'producto'                     , typeName:'text'    , nullable:false             , allow:{update:puedeEditar}                   },
            {name:'observacion'                  , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'obs'      },
            {name:'informante'                   , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'inf'      },
            {name:'formulario'                   , typeName:'integer' , nullable:false             , allow:{update:puedeEditar}, title:'for'      },
            {name:'precio'                       , typeName:'decimal' , allow:{update:puedeEditar} ,width:75,clientSide:'control_precio' , serverSide:true},
            {name:'tipoprecio'                   , typeName:'text'                                 , allow:{update:puedeEditar} ,title:'TP', postInput:'upperSpanish' },
            {name:'visita'                       , typeName:'integer' , nullable:false , default:1 , allow:{update:puedeEditar}, title:'vis'      },
            {name:'comentariosrelpre'            , typeName:'text'                                 , allow:{update:puedeEditar}             },
            {name:'cambio'                       , typeName:'text'                                 , allow:{update:puedeEditar}            , postInput:'upperSpanish' },            
            {name:'precionormalizado'            , typeName:'decimal'                              , allow:{update:puedeEditar}                   },
            {name:'especificacion'               , typeName:'integer'                              , allow:{update:puedeEditar}                   },
            {name:'ultima_visita'                , typeName:'boolean'                              , allow:{update:puedeEditar}                   },
            {name:'observaciones'                , typeName:'text'                                 , allow:{update:puedeEditar}                   },
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},            
            {references:'tipopre', fields:['tipoprecio']},            
        ],
        //sortColumns:[{column:'orden'},{column:'observacion'}],
        detailTables:[
            {table:'relatr', abr:'ATR', label:'atributos', fields:['periodo','producto','observacion','informante','visita']},
        ], /*
        sql:{
            from:`(select r.periodo, r.producto, r.informante, r.formulario, r.visita, r.observacion, r.precio, r.tipoprecio, r.cambio, 
                    CASE WHEN p.periodo is not null THEN 'R' ELSE null END as repregunta,
                    CASE WHEN c.antiguedadexcluido>0 and r.precio>0 THEN 'x' ELSE null END as excluido, r_1.precio_1 as precioanterior, 
                    r_1.tipoprecio_1 as tipoprecioanterior, r.comentariosrelpre, r.precionormalizado, r.especificacion, r.ultima_visita, r.observaciones,
                    r_1.comentariosrelpre_1 as comentariosanterior,                  
                    CASE WHEN r_1.precio_1 > 0 and r_1.precio_1 <> r.precio THEN round((r.precio/r_1.precio_1*100-100)::decimal,1)::TEXT||'%' 
                        ELSE CASE WHEN c_1.promobs > 0 and c_1.promobs <> r.precionormalizado and r_1.precio_1 is null THEN round((r.precionormalizado/c_1.promobs*100-100)::decimal,1)::TEXT||'%' 
                                ELSE NULL 
                                END 
                        END AS masdatos,
                    c_1.antiguedadsinprecio as antiguedadsinprecioant, c_1.promobs as promobs_1, r_1.precionormalizado_1, normsindato, fueraderango,
                    CASE WHEN s.periodo is not null THEN 'S' ELSE null END as sinpreciohace4meses, fp.orden
                    , CASE WHEN aa.puedeagregarvisita like '%S%' and r.ultima_visita THEN 'S' ELSE 'N' END as puedeagregarvisita
                    from relpre r
                    inner join forprod fp on r.producto = fp.producto and r.formulario = fp.formulario
                    left join relpre_1 r_1 on r.periodo=r_1.periodo and r.producto = r_1.producto and r.informante=r_1.informante and r.visita = r_1.visita and r.observacion = r_1.observacion
                    left join prerep p on r.periodo = p.periodo and r.producto = p.producto and r.informante = p.informante
                    left join calobs c on r.periodo = c.periodo and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion and c.calculo = 0
                    left join calobs c_1 on r_1.periodo_1 = c_1.periodo and r.producto = c_1.producto and r.informante = c_1.informante and r.observacion = c_1.observacion and c_1.calculo = 0
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as normsindato from control_normalizables_sindato) n on
                    r.periodo = n.periodo and r.informante = n.informante and r.observacion = n.observacion and r.visita = n.visita and r.producto = n.producto                    
                    left join (select distinct periodo, producto, observacion, informante, visita, 'S' as fueraderango from control_atributos) a on
                    r.periodo = a.periodo and r.informante = a.informante and r.observacion = a.observacion and r.visita = a.visita and r.producto = a.producto
                    left join control_sinprecio s on r.periodo =s.periodo and r.informante = s.informante and r.visita = s.visita and r.observacion = s.observacion and r.producto = s.producto,
                    lateral (select ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita, string_agg(distinct CASE WHEN es_vigencia THEN 'S' ELSE 'N' END,'') as puedeagregarvisita   
                    from cvp.relatr ra join cvp.atributos at on ra.atributo = at.atributo 
                    where ra.periodo = r.periodo and ra.producto = r.producto and ra.observacion = r.observacion and ra.informante = r.informante and ra.visita = r.visita --and es_vigencia
                    group by ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita) aa
                    )`,
        } */       
    },context);
}