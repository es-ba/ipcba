'use strict'

import { TableDefinition, Context } from "types-ipcba";

export const calgru_ccc_b1112_b21_vw = (context:Context): TableDefinition => {
  return {
    editable: false,
    name: 'calgru_ccc_b1112_b21_vw',
    title: 'empalme',
    fields:[
        {name:'periodo'                           , typeName:'text'   },
        {name:'agrupacion_b1112'                  , typeName:'text'   },
        {name:'grupo_b1112'                       , typeName:'text'   },
        {name:'calculo'                           , typeName:'integer'},
        {name:'agrupacion'                        , typeName:'text'   },
        {name:'grupo'                             , typeName:'text'   , sortMethod: 'codigo_ipc'},
        {name:'nombre'                            , typeName:'text'   },
        {name:'nivel'                             , typeName:'integer'},
        {name:'indice'                            , typeName:'decimal'},
        {name:'indiceredondeado'                  , typeName:'decimal', title:'indice redondeado'},
        {name:'variacion'                         , typeName:'decimal'},
        {name:'variacionacumuladaanualredondeada' , typeName:'decimal', title:'variacion acumulada anual redondeada'},
        {name:'variacioninteranualredondeada'     , typeName:'decimal', title:'variacion interanual redondeada'},
    ],
    hiddenColumns:['indice','variacionacumuladaanualredondeada','variacioninteranualredondeada'],
    primaryKey:['periodo','calculo','agrupacion','grupo'],
    filterColumns:[
        {column:'periodo', operator:'=', value:context.be.internalData?.filterActualPeriodo},
    ],
    sql:{
        isTable: false,
    },
  }
}