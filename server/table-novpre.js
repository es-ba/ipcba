"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    var puedeEditarRecep = context.user.usu_rol ==='recepcionista';
    return context.be.tableDefAdapt({
        name:'novpre',
        //title:'Anulación de precios',
        editable:puedeEditar,
        allow: {
            insert: puedeEditar,
            delete: false,
            update: puedeEditar,
            import: puedeEditar,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'nombreproducto'                   , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'informante'                       , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'observacion'                      , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'visita'                           , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}, inTable:true},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'nombreformulario'                 , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'infopre'                          , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'infopreant'                       , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'confirma'                         , typeName:'boolean' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'revisar_recep'   ,title:'Rev'     , typeName:'boolean'                  , allow:{update:puedeEditar}, inTable:true},
            {name:'comentarios'                      , typeName:'text'                     , allow:{update:puedeEditar}, inTable:true},
            {name:'comentarios_recep', title:'Recepcion', typeName:'text'                  , allow:{update:puedeEditar||puedeEditarRecep}, inTable:true},
        ],
        /*
        filterColumns:[
            {column:'periodo', operator:'=', value: context.be.internalData.filterUltimoPeriodo}
        ],
        */
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'relpre', fields:['periodo', 'producto', 'observacion', 'informante', 'visita']},            
        ],
        sql:{
            from: `(select n.periodo, 
                           n.producto, 
                           r.informante, 
                           r.observacion, 
                           r.visita,
                           CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                           (v.encuestador||':'||s.nombre||' '||s.apellido) as encuestador,
                           (v.recepcionista||':'||c.nombre||' '||c.apellido) as recepcionista,
                           p.nombreproducto, 
                           (r.formulario||':'||fo.nombreformulario)as nombreformulario, 
                           v.panel, 
                           v.tarea,
                           NULLIF((coalesce(rp.precio::text||';','')||coalesce(rp.tipoprecio||';','')||coalesce(rp.cambio,'')),'') as infopre,
                           NULLIF((coalesce(rpa.precio_1::text||';','')||coalesce(rpa.tipoprecio_1||';','')||coalesce(rpa.cambio_1,'')),'') as infopreant,
                           n.confirma,
                           n.comentarios, n.revisar_recep, n.comentarios_recep
                    from 
                           novpre n 
                            join relpre r on r.periodo = n.periodo and r.informante = n.informante and r.observacion = n.observacion and r.producto = n.producto
                            join productos p on r.producto = p.producto
                            join formularios fo on r.formulario = fo.formulario
                            join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita
                            join personal s on s.persona = v.encuestador
                            join personal c on c.persona = v.recepcionista
                            left join cvp.relpre rp on n.periodo = rp.periodo and n.producto = rp.producto and n.observacion = rp.observacion and
                                    n.informante = rp.informante and n.visita = rp.visita
                            left join relpre_1 rpa on n.periodo = rpa.periodo and n.producto = rpa.producto and n.observacion = rpa.observacion and
                                    n.informante = rpa.informante and n.visita = rpa.visita  
            )`,
        isTable: true, 
        },
    },context);
}