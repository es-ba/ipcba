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
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false, allow:{update:false} },
            {name:'calculo'                      , typeName:'integer' , nullable:false, allow:{update:false} },
            {name:'producto'                     , typeName:'text'    , nullable:false, allow:{update:puedeEditar} },
            {name:'promedioext'                  , typeName:'decimal'  , allow:{update:puedeEditar}  },
            {name:'anterior'                     , typeName:'decimal'  , allow:{update:false} },
            {name:'variacion'                    , typeName:'decimal'  , default:0, allow:{update:puedeEditar} },
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
            from:`(SELECT n.periodo, n.calculo, n.producto, n.promedioext, round(c0.promdiv::decimal,2)::decimal as anterior, variacion
                FROM novprod n
                LEFT JOIN calculos l ON n.periodo = l.periodo AND n.calculo = l.calculo 
                LEFT JOIN caldiv c0 ON c0.periodo = l.periodoanterior and c0.calculo = l.calculoanterior and n.producto = c0.producto and c0.division = '0'
                 )`
        }
    },context);
}