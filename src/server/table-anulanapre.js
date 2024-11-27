"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpre',
        editable:puedeEditar,
        allow: {
            delete: false,
            update: puedeEditar,
			insert: false,
			import: false,
        },
        fields:[
            {name: "recuperar"                       , typeName: "bigint" , editable:false, clientSide:'recuperar', visible:puedeEditar},
            {name:'periodo'                          , typeName:'text'    , nullable:false , allow:{update:false}, inTable:true},
            {name:'producto'                         , typeName:'text'    , nullable:false , allow:{update:false}, inTable:true},
            {name:'informante'                       , typeName:'integer' , nullable:false , allow:{update:false}, inTable:true},
            {name:'panel'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'tarea'                            , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'formulario'                       , typeName:'integer'                  , allow:{update:false}, inTable:false},
            {name:'observacion'                      , typeName:'integer' , nullable:false , allow:{update:false}, inTable:true},
            {name:'visita'                           , typeName:'integer' , nullable:false , allow:{update:false}, inTable:true},
            {name:'modi_usu'        ,title:'usuario' , typeName:'text'                     , allow:{update:false}, inTable:true},
            {name:'encuestador'                      , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'recepcionista'                    , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'infopre'                          , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'infopreant'                       , typeName:'text'                     , allow:{update:false}, inTable:false},
            {name:'comentariosrelpre'                , typeName:'text'                     , allow:{update:puedeEditar}, inTable:true},
            {name:'esvisiblecomentarioendm'          , typeName:'boolean'                  , allow:{update:puedeEditar}, inTable:true},
        ],
        refrescable: true,
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
            from: `(select r.periodo,
                           r.producto, 
                           r.informante, 
                           r.observacion, 
                           r.visita,
                           r.modi_usu,
                           v.encuestador,
                           v.recepcionista,
                           v.panel, 
                           v.tarea,
                           v.formulario,
                           NULLIF((coalesce(rpa.precio::text||';','')||coalesce(rpa.tipoprecio||';','')||coalesce(rpa.cambio,'')),'') as infopre,
                           NULLIF((coalesce(rpa.precio_1::text||';','')||coalesce(rpa.tipoprecio_1||';','')||coalesce(rpa.cambio_1,'')),'') as infopreant,
                           r.comentariosrelpre, 
	                       r.esvisiblecomentarioendm
                    from 
                        relpre r
                        left join novpre n on n.periodo = r.periodo and n.producto = r.producto and n.observacion = r.observacion and
                                                  n.informante = r.informante and n.visita = r.visita
                        left join parametros par on unicoregistro
                        left join relpre_1 rpa on r.periodo = rpa.periodo and r.producto = rpa.producto and r.observacion = rpa.observacion and
                                                  r.informante = rpa.informante and r.visita = rpa.visita
                        left join relvis v on rpa.periodo = v.periodo and rpa.informante = v.informante and rpa.formulario = v.formulario and rpa.visita = v.visita
                    where r.periodo >= pb_desde and r.tipoprecio = 'M' and n.periodo is null
            )`,
        isTable: true, 
        },
    },context);
}