"use strict";

module.exports = function(context){
    var {be}=context;
    return be.tableDefAdapt({
        name:'unificacion_valores_atributos',
        editable:false,
        fields:[
            {name:'periodo'         , typeName:'text'    },
            {name:'panel'           , typeName:'integer' },
            {name:'tarea'           , typeName:'integer' },
            {name:'producto'        , typeName:'text'    },
            {name:'informante'      , typeName:'integer' },
            {name:'visita'          , typeName:'integer' }, 
            {name:'observacion'     , typeName:'integer' }, 
            {name:'formulario'      , typeName:'integer' }, 
            {name:'atributo_1'      , typeName:'integer' }, 
            {name:'valor_1'         , typeName:'text'    },
            {name:'atributo'        , typeName:'integer' }, 
            {name:'valor_2'         , typeName:'text'    },
            {name:'comentarios'     , typeName:'text'    },
            {name:'atributos'       , typeName:'text'    }, 
        ],
        refrescable: true,
        primaryKey:['periodo', 'producto', 'observacion', 'informante', 'visita', 'atributo_1', 'atributo' ],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'producto'},{column:'observacion'},{column:'visita'},{column:'atributo_1'},{column:'atributo'}],
        foreignKeys:[
            {references:'productos', fields:['producto']},
            {references:'atributos', fields:['atributo']},
            {references:'atributos', fields:[{source:'atributo_1', target:'atributo'}], alias:'atr'},
        ],
        hiddenColumns:['atributos'],
        sql:{
            isTable: false,
            from: `(select rm.periodo, v.panel, v.tarea, rm.producto, rm.informante, rm.visita, rm.observacion, rm.formulario, rm.atributo_1, rm.valor_1, r.atributo, 
                      r.valor_2, rm.comentariosrelpre as comentarios, concat(rm.atributo_1,r.atributo) atributos
                      from (select rp.formulario, ra.*, rp.comentariosrelpre, ra.atributo atributo_1, ra.valor valor_1
                              from cvp.relpre rp 
                              join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                              join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto and rp.visita = ra.visita and rp.observacion = ra.observacion 
                              --join cvp.prodatr a1 on ra.producto= a1.producto and ra.atributo = a1.atributo 
	                          join cvp.atributos a on ra.atributo = a.atributo 
                              where /*a1.validaropciones*/  a.nombreatributo = 'Marca' and t.espositivo = 'S') rm
                            join cvp.relvis v on v.periodo = rm.periodo and v.informante = rm.informante and v.visita = rm.visita and v.formulario = rm.formulario  
                            left join (select rp.formulario, ra.*, ra.atributo atributo_2, ra.valor valor_2
                                         from cvp.relpre rp 
                                         join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                                         join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto 
	                                        and rp.visita = ra.visita and rp.observacion = ra.observacion
	                                     join cvp.prodatr pa on rp.producto = pa.producto and ra.atributo = pa.atributo
	                                     where pa.normalizable = 'S' and t.espositivo = 'S') r on r.periodo = rm.periodo and r.informante = rm.informante and r.producto = rm.producto 
	                                        and r.observacion = rm.observacion and r.visita = rm.visita)`
        },
    },context);
}
