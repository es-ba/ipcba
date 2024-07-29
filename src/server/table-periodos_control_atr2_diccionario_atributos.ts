"use strict";

import { TableDefinition } from "backend-plus";
import { periodos_control } from "./table-periodos_control";

export const periodos_control_atr2_diccionario_atributos = ():TableDefinition =>{
    return periodos_control('periodos_control_atr2_diccionario_atributos','relpre_control_atr2_diccionario_atributos','DA','Control (atr2) diccionario de atributos');
}
