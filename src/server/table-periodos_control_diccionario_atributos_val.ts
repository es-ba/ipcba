"use strict";

import { TableDefinition } from "backend-plus";
import { periodos_control } from "./table-periodos_control";

export const periodos_control_diccionario_atributos_val = ():TableDefinition =>{
    return periodos_control('periodos_control_diccionario_atributos_val','control_diccionario_atributos','DA','Control diccionario de atributos valor');
}
