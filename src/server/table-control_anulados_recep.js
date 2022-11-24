"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador'|| context.user.usu_rol ==='recepcionista' || context.forDump;
    var esAnalista = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'control_anulados_recep',
        tableName:'relpre',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar||esAnalista,
        },
        //editable:false,
        //dbOrigin:'view',
        fields:[
            {name: "recuperar"                   , typeName: "bigint"  , editable:false, clientSide:'recuperar', visible:puedeEditar},
            {name:'periodo'                      ,typeName:'text'   ,   allow:{update:false}},
            {name:'producto'                     ,typeName:'text'   ,   allow:{update:false}},
            {name:'informante'                   ,typeName:'integer',   allow:{update:false}},
            {name:'observacion'                  ,typeName:'integer',   allow:{update:false}, title:'Obs'},
            {name:'visita'                       ,typeName:'integer',   allow:{update:false}, title:'Vis'},
            {name:'panel'                        ,typeName:'integer',   allow:{update:false}},
            {name:'tarea'                        ,typeName:'integer',   allow:{update:false}},
            {name:'encuestador'                  ,typeName:'text'   ,   allow:{update:false}, title:'Enc'},
            {name:'recepcionista'                ,typeName:'text'   ,   allow:{update:false}, title:'Rec'},
            {name:'formulario'                   ,typeName:'integer',   allow:{update:false}, title:'For'},
            {name:'precio'                       ,typeName:'decimal',   allow:{update:false}},
            {name:'precionormalizado'            ,typeName:'decimal',   allow:{update:false}, title:'PNorm'},
            {name:'tipoprecio'                   ,typeName:'text'   ,   allow:{update:false}, title:'TP'},
            {name:'precioant'                    ,typeName:'decimal',   allow:{update:false}},
            {name:'precionormalizadoant'         ,typeName:'decimal',   allow:{update:false}, title:'PNormAnt'},
            {name:'tipoprecioant'                ,typeName:'text'   ,   allow:{update:false}, title:'TPAnt'},
            {name:'comentariosrelpre'            ,typeName:'text'   ,   allow:{update:puedeEditar}},
            {name:'observaciones'                ,typeName:'text'   ,   allow:{update:esAnalista}},
        ],
        primaryKey:['periodo','producto','informante','observacion','visita'],
        foreignKeys:[
            {references:'informantes', fields:['informante']},
            {references:'productos', fields:['producto']},
            {references:'relvis', fields:['periodo', 'informante', 'visita', 'formulario']},
            {references:'personal', fields:[
                {source:'encuestador'         , target:'persona'     },
            ]}],
        detailTables:[
            {table:'blaatr', fields:['periodo','producto','observacion','informante','visita'], abr:'ATR', label:'atributos' },
        ],
        sql:{
            from: `(select r.periodo, r.producto, r.informante, r.observacion, r.visita, v.panel, v.tarea, v.encuestador, v.recepcionista, 
                  r.formulario, r.comentariosrelpre, b.precio, round(b.precionormalizado::decimal,2) as precionormalizado, b.tipoprecio, 
                  r_1.precio_1 as precioant, round(r_1.precionormalizado_1::decimal,2) as precionormalizadoant, r_1.tipoprecio_1 as tipoprecioant, r.observaciones
                    from relpre r left join relvis v USING (periodo,informante,visita,formulario)
                    left join blapre b USING (periodo,producto,informante,observacion,visita)
                    left join relpre_1 r_1 USING (periodo,producto,informante,visita,observacion)
                    where r.tipoprecio = 'A')`,
        }        
    }, context);
}