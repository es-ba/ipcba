"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete' || context.user.usu_rol ==='migracion';
    //console.log('Puede editar relatr! ',puedeEditar);
    return context.be.tableDefAdapt({
        name:'relatr',
        //title:'Relatr',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                          , typeName:'text'    , nullable:false, allow:{update:false}, inTable:true},
            {name:'informante'                       , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'visita'                           , typeName:'integer' , nullable:false , default:1, allow:{update:false}, inTable:true},
            {name:'producto'                         , typeName:'text'    , nullable:false, allow:{update:false}, inTable:true},
            {name:'observacion'                      , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'atributo'                         , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            // {name:'tipodato'                         , typeName:'text'                    , allow:{update:false}},
            {name:'valor'                            , typeName:'text'    , allow:{update:puedeEditar} ,clientSide:'control_rangos' , serverSide:true, postInput:'upperSpanish', inTable:true},
            {name:'valoranterior'                    , typeName:'text'    , allow:{update:false}, inTable:false},
            {name:'prodatr__rangodesde'              , typeName:'decimal' , title:'desde', allow:{update:false}, inTable:false},
            {name:'prodatr__rangohasta'              , typeName:'decimal' , title:'hasta', allow:{update:false}, inTable:false},
            {name:'prodatr__valornormal'             , typeName:'decimal' , title:'valorNormal', allow:{update:false}, visible:false, inTable:false},
            {name:'normalizable'                     , typeName:'text'    , visible:false, inTable:false},
            {name:'prodatr__orden'                   , typeName:'integer' , allow:{update:false}, visible:false, inTable:false},
            {name:'opciones'                         , typeName:'text'    , allow:{update:false}, visible:false, inTable:false},
            {name:'especificaciones__mostrar_cant_um', typeName:'text'    , allow:{update:false}, visible:false, inTable:false},
            {name:'validar_con_valvalatr'            , typeName:'boolean' , allow:{update:false}, visible:false, inTable:true},

        ],
        primaryKey:['periodo','producto','observacion','informante','visita', 'atributo'],
        sortColumns:[{column:'prodatr__orden'}],
        foreignKeys:[
            {references:'atributos', fields:['atributo'], displayFields:['nombreatributo','tipodato']},
            {references:'informantes', fields:['informante']},
            {references:'periodos', fields:['periodo']},
            {references:'productos', fields:['producto']},
            {references:'relpre', fields:['periodo', 'producto', 'observacion', 'informante', 'visita']},
            /*            
            {references:'valvalatr', fields:[
                {source:'producto'                    , target:'producto'    },
                {source:'atributo'                    , target:'atributo'    },
                {source:'valor'                       , target:'valor'       },
                {source:'validar_con_valvalatr'       , target:'validar'     },
            ]},
            */            
        ],
        softForeignKeys:[
            {references:'prodatr', fields:['producto','atributo'], displayFields:['rangodesde','rangohasta','orden', 'valornormal']},
            {references:'especificaciones', fields:['producto'], displayFields:['mostrar_cant_um']},
        ],
        detailTables:[
            {table:'relatr_tipico', abr:'Valores Típicos', fields:['periodo','producto','atributo'], abr:'V'}
        ],
        sql:{
            from:`(
                select a.periodo, a.informante, a.visita, a.producto, a.observacion, a.atributo, a.valor, a_1.valor_1 as valoranterior,
                  n.normalizable, pa.opciones, a.validar_con_valvalatr
                  from relatr a
                  join prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo
                  left join relatr_1 a_1 on a.periodo = a_1.periodo and a.producto = a_1.producto and a.observacion = a_1.observacion and
                  a.informante = a_1.informante and a.visita = a_1.visita and a.atributo = a_1.atributo
                  left join control_normalizables_sindato n on a.periodo = n.periodo and a.informante = n.informante and
                  a.observacion = n.observacion and a.visita = n.visita and a.producto = n.producto and a.atributo = n.atributo
                  )`,
            isTable: true,
        }
    },context);
}