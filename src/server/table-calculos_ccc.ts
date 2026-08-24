'use strict'

import {TableDefinition } from "backend-plus";

export function calculos_ccc(): TableDefinition{
  return {
    editable: false,
    name: 'calculos_ccc',
    tableName: 'calculos',
        fields:[
            {name:'periodo'                      , typeName:'text'     },
            {name:'calculo'                      , typeName:'integer'  },
            {name:'estimacion'                   , typeName:'integer'  },
            {name:'abierto'                      , typeName:'text'     },
            {name:'fechacalculo'                 , typeName:'timestamp'},
            {name:'esperiodobase'                , typeName:'text'     },
            {name:'periodoanterior'              , typeName:'text'     },
            {name:'calculoanterior'              , typeName:'integer'  },
            {name:'hasta_panel'                  , typeName:'integer'  },
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
        from: `(SELECT periodo, c.calculo, estimacion, abierto, fechacalculo, esperiodobase, periodoanterior, calculoanterior, hasta_panel 
                FROM calculos c 
                JOIN calculos_def d on c.calculo = d.calculo 
                WHERE principal
               )`
    },
  }
}