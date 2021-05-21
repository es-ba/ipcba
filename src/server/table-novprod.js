"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'novprod',
        //title:'Novprod',
        editable:true, //puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        hiddenColumns:['tipoexterno'],
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false, allow:{update:false}, inTable: true},
            {name:'calculo'                      , typeName:'integer' , nullable:false, default:0, allow:{update:false}, inTable: true},
            {name:'producto'                     , typeName:'text'    , nullable:false, allow:{update:puedeEditar}, inTable: true},
            {name:'promedioext'                  , typeName:'decimal'  , allow:{update:puedeEditar}, inTable: true},
            {name:'anterior'                     , typeName:'decimal'  , allow:{update:false}, inTable: false},
            {name:'variacion'                    , typeName:'decimal'  , default:0, allow:{update:puedeEditar}, inTable: true},
            {name:'tipoexterno'                  , typeName:'text'     , allow:{update:puedeEditar}, inTable: true},
            {name:'responsable'                  , typeName:'text'     , allow:{update:false}, inTable: false},
        ],
        /*
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo},
            {column:'calculo', operator:'=' , value:context.be.internalData.filterUltimoCalculo}
        ],
        */        
        primaryKey:['periodo','calculo','producto'],
        foreignKeys:[
            {references:'periodos' , fields:['periodo']},
            {references:'productos', fields:['producto']},
        ],
        sql:{
            from:`(SELECT n.periodo, n.calculo, n.producto, n.promedioext, round(c0.promdiv::decimal,2)::decimal as anterior, variacion, n.tipoexterno, coalesce(g.responsable, gp.responsable) as responsable
                FROM novprod n
                LEFT JOIN calculos l ON n.periodo = l.periodo AND n.calculo = l.calculo 
                LEFT JOIN caldiv c0 ON c0.periodo = l.periodoanterior and c0.calculo = l.calculoanterior and n.producto = c0.producto and c0.division = '0'
                LEFT JOIN (SELECT agrupacion, grupo, grupopadre, responsable FROM grupos WHERE agrupacion = 'F' and esproducto ='S') g ON n.producto = g.grupo
                LEFT JOIN grupos gp ON  g.agrupacion = gp.agrupacion and g.grupopadre = gp.grupo
                )`,
        isTable: true,
        }
    },context);
}