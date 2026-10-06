'use strict'

import {Context, TableDefinition} from "backend-plus";

export function calculos_ccc(context: Context): TableDefinition{
  var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='ccc_analista';
  return {
    editable:puedeEditar,
    allow:{
        insert:false,
        delete:false,
        update:puedeEditar,
    },
    name: 'calculos_ccc',
    tableName: 'calculos',
        fields:[
            {name: "calcular_ccc"                , typeName: "bigint", editable:false, clientSide:'calcular_ccc'},
            {name:'periodo'                      , typeName:'text'   , allow:{update:false}},
            {name:'calculo'                      , typeName:'integer', allow:{update:false}},
            {name:'estimacion'                   , typeName:'integer', allow:{update:false}},
            {name:'abierto'                      , typeName:'text'   , allow:{update:false}},
            {name:'fechacalculo'                 , typeName:'timestamp', allow:{update:false}},
            {name:'abierto_ccc'                  , typeName:'text', nullable:false, postInput:'upperSpanish', defaultValue:'S', allow:{update:puedeEditar}},
            {name:'fechacalculo_ccc'             , typeName:'timestamp', allow:{update:false}},
            {name:'esperiodobase'                , typeName:'text'     , allow:{update:false}},
            {name:'periodoanterior'              , typeName:'text'     , allow:{update:false}},
            {name:'calculoanterior'              , typeName:'integer'  , allow:{update:false}},
            {name:'hasta_panel'                  , typeName:'integer'  , allow:{update:false}},
        ],
    primaryKey:['periodo','calculo'],
    detailTables:[
        {table:'valorizacion_canasta_ccc', fields:['periodo','calculo'], abr:'G'},
    ],
    sortColumns:[{column:'periodo', order:-1}, {column:'calculo'}],
    //filterColumns:[
    //    {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo.replace(/\d\d\d\d/,function(annio){ return annio-1;})},
    //    {column:'calculo', operator:'=' ,value:context.be.internalData.filterUltimoCalculo}
    //],
    sql: {
        isTable: false,
        from: `(SELECT periodo, c.calculo, estimacion, abierto, fechacalculo, esperiodobase, periodoanterior, calculoanterior, hasta_panel, 
                abierto_ccc, fechacalculo_ccc 
                FROM calculos c 
                JOIN calculos_def d on c.calculo = d.calculo 
                WHERE principal
               )`
    },
  }
}