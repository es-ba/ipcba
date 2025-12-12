"use strict"

import { TableDefinition } from "backend-plus";

export function cuadros_funciones_ccc():TableDefinition{
    return {
        editable: true,
        name: 'cuadros_funciones_ccc',
        fields: [
            {name:'funcion'            , typeName:'text'    , nullable:false},
            {name:'usa_parametro1'     , typeName:'boolean'                 },
            {name:'usa_periodo'        , typeName:'boolean'                 },
            {name:'usa_nivel'          , typeName:'boolean'                 },
            {name:'usa_grupo'          , typeName:'boolean'                 },
            {name:'usa_agrupacion'     , typeName:'boolean'                 },
            {name:'usa_ponercodigos'   , typeName:'boolean'                 },
            {name:'usa_agrupacion2'    , typeName:'boolean'                 },
            {name:'usa_cuadro'         , typeName:'boolean'                 },
            {name:'usa_hogares'        , typeName:'boolean'                 },
            {name:'usa_cantdecimales'  , typeName:'boolean'                 },
            {name:'usa_desde'          , typeName:'boolean'                 },
            {name:'usa_orden'          , typeName:'boolean'                 },
            {name:'usa_empalmedesde'   , typeName:'boolean'          },
            {name:'usa_empalmehasta'   , typeName:'boolean'          },
        ],
        primaryKey: ['funcion'],
    }
}