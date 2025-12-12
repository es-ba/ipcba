"use strict";

import { TableDefinition } from "backend-plus";

export const cuadros_ccc = ():TableDefinition =>{
    return {
        name:'cuadros_ccc',
        title:'textos de los cuadros',
        editable:false,
        fields:[
            {name:'cuadro'            , typeName:'text'       , nullable:false },
            {name:'descripcion'       , typeName:'text'       , isName:true },
            {name:'funcion'           , typeName:'text'       },
            {name:'parametro1'        , typeName:'text'       },
            {name:'periodo'           , typeName:'text'       },
            {name:'nivel'             , typeName:'integer'    },
            {name:'grupo'             , typeName:'text'       },
            {name:'agrupacion'        , typeName:'text'       },
            {name:'encabezado'        , typeName:'text'       },
            {name:'pie'               , typeName:'text'       },
            {name:'ponercodigos'      , typeName:'boolean'    },
            {name:'agrupacion2'       , typeName:'text'       },
            {name:'hogares'           , typeName:'integer'    },
            {name:'pie1'              , typeName:'text'       },
            {name:'cantdecimales'     , typeName:'integer'    },
            {name:'desde'             , typeName:'text'       },
            {name:'orden'             , typeName:'text'       },
            {name:'encabezado2'       , typeName:'text'       },
            {name:'activo'            , typeName:'text'        , nullable:false, defaultValue: 'S' },
            {name:'empalmedesde'      , typeName:'boolean'    },
            {name:'empalmehasta'      , typeName:'boolean'    },

        ],
        primaryKey:['cuadro'],
        foreignKeys:[
            {references:'cuadros_funciones_ccc', fields:['funcion']},
        ],
        constraints: [
            { constraintType: 'check', consName: 'texto invalido en descripcion de tabla cuadros_ccc', expr: `comun.cadena_valida(descripcion::text, 'amplio'::text)` },
            { constraintType: 'check', consName: 'texto invalido en parametro1 de tabla cuadros_ccc', expr: `comun.cadena_valida(parametro1::text, 'amplio'::text)` },
            { constraintType: 'check', consName: 'texto invalido en pie de tabla cuadros_ccc', expr: `comun.cadena_valida(pie::text, 'amplio'::text)` }
        ],
    };
}