'use strict'

import { TableDefinition } from "types-ipcba";

export const valorizacion_canasta_ccc = (): TableDefinition => {
  return {
    editable: false,
    name: 'valorizacion_canasta_ccc',
    fields:[
        {name:'periodo'                           , typeName:'text'   },
        {name:'calculo'                           , typeName:'integer'},
        {name:'hogar'                             , typeName:'text'   },
        {name:'agrupacion'                        , typeName:'text'   },
        {name:'grupo'                             , typeName:'text'   },
        {name:'grupopadre'                        , typeName:'text'   },
        {name:'nivel'                             , typeName:'integer'},
        {name:'nombregrupo'                       , typeName:'text'   },
        {name:'valorhoggru'                       , typeName:'decimal', title:'Valorizacion'},
    ],
    primaryKey:['periodo','calculo','hogar','agrupacion','grupo'],
    sql:{
        isTable: false,
        from: `(SELECT v.periodo, v.calculo, v.hogar, v.agrupacion, v.grupo, g.grupopadre, g.nivel, 
                 coalesce (c.nombreproducto, p.nombreproducto, g.nombregrupo) nombregrupo, v.valorhoggru
                 FROM ccc.valorizacion_canasta_ccc v
                 JOIN ccc.grupos_ccc g ON v.agrupacion = g.agrupacion AND v.grupo = g.grupo
                 LEFT JOIN ccc.productos_ccc p ON v.grupo = p.producto
                 LEFT JOIN cvp.productos c  ON v.grupo = c.producto
                 WHERE g.nivel >= 1)`
    },
  }
}