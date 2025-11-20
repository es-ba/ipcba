'use strict'

import { TableDefinition, Context } from "backend-plus";

export const calgru_ccc_b1112_b21_vw = (context:Context): TableDefinition => {
  return {
    editable: false,
    name: 'calgru_ccc_b1112_b21_vw',
    title: 'empalme',
    fields:[
        {name:'periodo'                           , typeName:'text'   },
        {name:'calculo'                           , typeName:'integer'},
        {name:'agrupacion'                        , typeName:'text'   },
        {name:'grupo'                             , typeName:'text'   , sortMethod: 'codigo_ipc'},
        {name:'nombre'                            , typeName:'text'   },
        {name:'nivel'                             , typeName:'integer'},
        {name:'indice'                            , typeName:'decimal'},
        {name:'indiceredondeado'                  , typeName:'decimal'},
        {name:'variacion'                         , typeName:'decimal'},
        {name:'variacionacumuladaanualredondeada' , typeName:'decimal'},
        {name:'variacioninteranualredondeada'     , typeName:'decimal'},
    ],
    hiddenColumns:['indice'],
    primaryKey:['periodo','calculo','agrupacion','grupo'],
    filterColumns:[
        {column:'periodo', operator:'=', value:(context.be as any).internalData?.filterActualPeriodo},
    ],
    sql:{
        isTable: false,
    },
  }
}