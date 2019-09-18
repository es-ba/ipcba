"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'precios_maximos_minimos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'analista'                         , typeName:'text'    , nullable:false , allow:{update:false}},
            {name:'umabreviada'                      , typeName:'text'                     , allow:{update:false}},
            {name:'normaliza'                        , typeName:'text'                     , allow:{update:false}, visible:false},
            {name:'normalizable'                     , typeName:'boolean'                  , allow:{update:false}},
            {name:'precio1'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio2'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio3'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio4'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio5'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio6'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio7'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio8'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio9'                          , typeName:'text'                     , allow:{update:false}},
            {name:'precio10'                         , typeName:'text'                     , allow:{update:false}},
            {name:'varmin'                           , typeName:'decimal'                  , allow:{update:false}},
            {name:'varmax'                           , typeName:'decimal'                  , allow:{update:false}},
        ],
        primaryKey:['periodo','producto'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from: `(select cp.periodo, cp.producto, cp.responsable as analista, m.precio1, m.precio2, m.precio3, m.precio4, m.precio5,
			        p.unidadmedidaabreviada as umabreviada,
			        string_agg(CASE WHEN pa.normalizable = 'S' THEN pa.valornormal||' '||a.unidaddemedida END,',') as normaliza,
			        CASE WHEN string_agg(CASE WHEN pa.normalizable = 'S' THEN pa.valornormal||' '||a.unidaddemedida END,',') IS NULL THEN false ELSE true END as normalizable,
					x.precio6, x.precio7, x.precio8, x.precio9, x.precio10, 
					CASE WHEN comun.es_numero(split_part(m.precio1,'X',1)) and comun.es_numero(split_part(m.precio2,'X',1)) THEN 
					round(split_part(m.precio2,'X',1)::decimal/split_part(m.precio1,'X',1)::decimal*100-100,2) else null END as varmin,
					CASE WHEN comun.es_numero(split_part(x.precio9,'X',1)) and comun.es_numero(split_part(x.precio10,'X',1)) THEN 
					round(split_part(x.precio10,'X',1)::decimal/split_part(x.precio9,'X',1)::decimal*100-100,2) else null END as varmax
                    from calprodresp cp
                         left join productos p on cp.producto = p.producto					
					     left join precios_maximos_vw x on cp.periodo = x.periodo and cp.producto = x.producto
                         left join prodatr pa on cp.producto = pa.producto
                         left join atributos a on pa.atributo = a.atributo						 
				         left join precios_minimos_vw m on cp.periodo = m.periodo and cp.producto = m.producto
					where cp.calculo = 0
	                group by cp.periodo, cp.producto, cp.responsable, m.precio1, m.precio2, m.precio3, m.precio4, m.precio5,
                    x.precio6, x.precio7, x.precio8, x.precio9, x.precio10, p.unidadmedidaabreviada					
                    )`
        }    
    },context);
}