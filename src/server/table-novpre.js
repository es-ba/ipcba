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
            {name:'informante'                       , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'formulario'                       , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'observacion'                      , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'visita'                           , typeName:'integer' , nullable:false , allow:{update:puedeEditar}, inTable:true},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}, inTable:true},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}, inTable:false},
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
            {references:'productos', fields:['producto']},            
            {references:'formularios', fields:['formulario']},            
            {references:'personal', fields:[
                {source:'recepcionista'  , target:'persona' },
            ], alias: 'rec'},        
            {references:'personal', fields:[
                {source:'encuestador'    , target:'persona' },
            ], alias: 'enc'},        
        ],
        sql:{
            from: `(select n.periodo,
                           n.producto, 
                           n.informante, 
                           n.observacion, 
                           n.visita,
                           CASE WHEN n.modi_usu = 'cvpowner' THEN n.usuario ELSE n.modi_usu END as modi_usu,
                           v.encuestador,
                           v.recepcionista,
                           v.panel, 
                           v.tarea,
                           v.formulario,
                           NULLIF((coalesce(rpa.precio::text||';','')||coalesce(rpa.tipoprecio||';','')||coalesce(rpa.cambio,'')),'') as infopre,
                           NULLIF((coalesce(rpa.precio_1::text||';','')||coalesce(rpa.tipoprecio_1||';','')||coalesce(rpa.cambio_1,'')),'') as infopreant,
                           n.confirma,
                           n.comentarios, n.revisar_recep, n.comentarios_recep
                    from 
                        novpre n
                        left join parametros par on unicoregistro
                        left join relpre_1 rpa on n.periodo = rpa.periodo and n.producto = rpa.producto and n.observacion = rpa.observacion and
                                                  n.informante = rpa.informante and n.visita = rpa.visita
                        left join relvis v on rpa.periodo = v.periodo and rpa.informante = v.informante and rpa.formulario = v.formulario and rpa.visita = v.visita
                    where n.periodo >= pb_desde  
            )`,
        isTable: true, 
        },
    },context);
}