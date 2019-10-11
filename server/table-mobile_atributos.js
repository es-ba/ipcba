"use strict";

module.exports = function(context){
    var puedeEditar = true;
    return context.be.tableDefAdapt({
        name:'mobile_atributos',
        tableName:'relatr',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        policy:'web',
        fields:[
            {name:'periodo'              , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'informante'           , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'visita'               , typeName:'integer' , nullable:false , default:1, allow:{update:false}},
            {name:'panel'                , typeName:'integer' , nullable:false             , allow:{update:true}, visible:false     },
            {name:'tarea'                , typeName:'integer' , nullable:false             , allow:{update:true}, visible:false     },
            {name:'producto'             , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'observacion'          , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'atributo'             , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'formulario'           , typeName:'integer' , nullable:false             , allow:{update:false}                   },
            {name:'tipodato'             , typeName:'text'    , allow:{update:false}},
            {name:'nombreatributo'       , typeName:'text'    , allow:{update:false}, title: 'atributo'},
            {name:'valoranterior'        , typeName:'text'    , allow:{update:false}      },
            {name:'copiar_atributo'      , typeName:'text'    , allow:{update:false}, title:'c', clientSide:'copiar_atributo', serverSide:true      },
            {name:'valor'                , typeName:'text'    , clientSide:'control_rangos' , serverSide:true, postInput:'upperSpanish'},
            {name:'prodatr__rangodesde'  , typeName:'decimal' , title:'desde', allow:{update:false}, visible:false},
            {name:'prodatr__rangohasta'  , typeName:'decimal' , title:'hasta', allow:{update:false}, visible:false},
            {name:'prodatr__valornormal' , typeName:'decimal' , title:'valorNormal', allow:{update:false}, visible:false},
            {name:'prodatr__normalizable', typeName:'text'    , allow:{update:false}, visible:false},
            {name:'normalizable'         , typeName:'text'    , visible:false},
            {name:'escantidad'           , typeName:'text'    , allow:{update:false}, visible:false},
            {name:'prodatr__orden'       , typeName:'integer' , allow:{update:false}, visible:false},
            {name:'opciones'             , typeName:'text'    , allow:{update:false}, visible:false},
            {name:'especificaciones__mostrar_cant_um', typeName:'text'    , allow:{update:false}, visible:false},

        ],
        primaryKey:['periodo','informante','visita', 'formulario','producto','observacion', 'atributo'],
        sortColumns:[{column:'prodatr__orden'}],
        foreignKeys:[
            //{references:'atributos', fields:['atributo'], displayFields:['nombreatributo','tipodato']},
            //{references:'informantes', fields:['informante']},
            //{references:'periodos', fields:['periodo']},
            //{references:'productos', fields:['producto']},
            {references:'mobile_precios', fields:['periodo', 'producto', 'observacion', 'informante', 'visita']},
        ],
        softForeignKeys:[
            {references:'prodatr', fields:['producto','atributo'], displayFields:['rangodesde','rangohasta','orden','valornormal','normalizable']},
            {references:'especificaciones', fields:['producto'], displayFields:['mostrar_cant_um']},
        ],
        detailTables:[
            //{table:'relatr_tipico', abr:'Valores Típicos', fields:['periodo','producto','atributo'], abr:'V'}
        ],
        sql:{
            from:`(
                select a.periodo, a.informante, a.visita, a.producto, a.observacion, a.atributo, 
                case when tp.espositivo = 'S' then a.valor else null end as valor, 
                a.valor_1 as valoranterior,
                r.formulario, rv.panel, rv.tarea, '→' as copiar_atributo, at.nombreatributo, at.tipodato, at.escantidad,
                case when pa.valornormal IS NOT NULL AND pa.normalizable::text = 'S'::text AND a.valor IS NULL AND r.precio IS NOT NULL then 'S' else '' end as normalizable,
                pa.opciones
                from relatr_1 a
                    join prodatr pa ON pa.atributo = a.atributo AND pa.producto = a.producto
                    join relpre r on a.periodo = r.periodo and a.informante = r.informante and a.visita = r.visita and a.observacion = r.observacion and r.producto = a.producto
                    join relvis rv on r.periodo = rv.periodo and r.informante = rv.informante and r.visita = rv.visita and r.formulario = rv.formulario
                    join atributos at on a.atributo = at.atributo
                    left join tipopre tp on r.tipoprecio = tp.tipoprecio
                )`
        }
    },context);
}