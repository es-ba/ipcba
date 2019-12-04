"use strict";
import {RelPre, RelVis, RelAtr, Estructura, ProdAtr} from "./dm-tipos";
import * as likeAr from "like-ar";

export function puedeCopiarTipoPrecio(estructura:Estructura, relPre:RelPre){
    return relPre.tipoprecio==null && relPre.tipoprecioanterior!=null && estructura.tipoPrecio[relPre.tipoprecioanterior].puedecopiar
}

export function puedeCopiarAtributos(estructura:Estructura, relPre:RelPre){
    return !relPre.atributos.every(relAtr=>relAtr.valoranterior == null) && (!relPre.tipoprecio || estructura.tipoPrecio[relPre.tipoprecio].espositivo);
}

export function muestraFlechaCopiarAtributos(estructura:Estructura, relPre:RelPre){
    return relPre.cambio==null && puedeCopiarAtributos(estructura, relPre);
}

export function puedeCambiarPrecioYAtributos(estructura:Estructura, relPre:RelPre){
    return relPre.tipoprecio==null || estructura.tipoPrecio[relPre.tipoprecio].espositivo;
}

export function puedeCambiarTP(estructura:Estructura, relVis:RelVis){
    return relVis.razon && estructura.razones[relVis.razon].espositivoformulario;
}

export function tpNecesitaConfirmacion(estructura:Estructura, relPre:RelPre, tipoPrecioSeleccionado:string){
    return !estructura.tipoPrecio[tipoPrecioSeleccionado].espositivo && (relPre.precio != null || relPre.cambio != null)
}

export function calcularCambioAtributosEnPrecio(relPre:RelPre){
    var hayAtributosActuales = relPre.atributos.some(relAtr=>relAtr.valor != null);
    var hayDiferenciasEntreAtributos = relPre.atributos.some(relAtr=>relAtr.valor!=relAtr.valoranterior);
    return !hayAtributosActuales?null:(!hayDiferenciasEntreAtributos?'=':'C')
}

export function normalizarPrecio(relPre:RelPre, estructura:Estructura){
    if(!relPre.precio){
        return null
    }
    var vtope=0;
    var vacumulador:(number|null)[] = [];
    vacumulador[vtope]=relPre.precio;
    var atributosNormalizables = likeAr(estructura.productos[relPre.producto].atributos).filter((prodAtr:ProdAtr)=>prodAtr.normalizable).array()
    atributosNormalizables.forEach(function(prodAtr:ProdAtr){
        vtope++;
        var relAtr = relPre.atributos.find((relAtr:RelAtr)=>relAtr.atributo==prodAtr.atributo)!;
        if (prodAtr.tiponormalizacion=='Moneda' && relAtr.valor){
            relAtr.valor=String(estructura.relmon[relAtr.valor].valor_pesos);
        }
        if (relAtr.valor && !isNaN(parseFloat(relAtr.valor))){
            vacumulador[vtope]=Number(relAtr.valor)
        }else{
            vacumulador[vtope]=null                    
        }
        var voperacion=prodAtr.tiponormalizacion!.split(",");
        voperacion.forEach(function(operacion){
            switch (operacion){
                case '+':
                    vacumulador[vtope-1]=vacumulador[vtope-1]!+vacumulador[vtope]!;
                    vtope=vtope -1;
                    break;
                case '*':
                    vacumulador[vtope-1]=vacumulador[vtope-1]!*vacumulador[vtope]!;
                    vtope=vtope -1; 
                    break;
                case '1#':
                    vtope=vtope +1;
                    vacumulador[vtope]=1;
                    break;
                case '2/':
                    vacumulador[vtope]=vacumulador[vtope]!/2;
                    break;
                case '6/':
                    vacumulador[vtope]=vacumulador[vtope]!/6;   
                    break;
                case '12/':
                    vacumulador[vtope]=vacumulador[vtope]!/12;   
                    break;
                case '100/':
                    vacumulador[vtope]=vacumulador[vtope]!/100;   
                    break;
                case 'Normal':
                    if (vacumulador[vtope] != null && vacumulador[vtope]!=0){
                        vacumulador[vtope-1]=vacumulador[vtope-1]!/vacumulador[vtope]!*prodAtr.valornormal!;
                        vtope=vtope-1;
                    }else{
                        vacumulador[vtope-1]=null;
                        vtope=vtope-1;
                    }
                    break;
                case 'Moneda':
                    vacumulador[vtope-1]=vacumulador[vtope-1]!*vacumulador[vtope]!*prodAtr.valornormal!;
                    vtope=vtope-1;
                    break;
                case 'Bonificar':
                    vacumulador[vtope-1]=vacumulador[vtope-1]!*(100.0 - (vacumulador[vtope]||0))/100.0;
                    vtope=vtope-1;
                    break;
                case '#': 
                    null;
                    break;
                default:
                    throw new Error('Operador no considerado ' + operacion);
            }
        });
        if (vtope != 0){
           throw new Error('Queda informacion en el acumulador que no fue utilizada ' + vtope);
        };
    });
    return vacumulador[vtope];
};

export function controlarAtributo(relAtr:RelAtr, relPre:RelPre, estructura:Estructura){
    var prodAtr = estructura.productos[relPre.producto].atributos[relAtr.atributo];
    var esValidoAtributo = function esValidoAtributo(relAtr:RelAtr, prodAtr:ProdAtr){
        return !((prodAtr.rangodesde && Number(relAtr.valor)<prodAtr.rangodesde) || (prodAtr.rangohasta && Number(relAtr.valor)>prodAtr.rangohasta))
    }
    var esValorNormal = function(relAtr:RelAtr, prodAtr:ProdAtr){
        return !prodAtr.mostrar_cant_um && prodAtr.valornormal && Number(relAtr.valor)==prodAtr.valornormal
    }
    var esNormalizableSinValor = function esNormalizableSinValor(relAtr:RelAtr, prodAtr:ProdAtr, relPre:RelPre){
        return prodAtr.valornormal && prodAtr.normalizable && relAtr.valor == null && relPre.tipoprecio && estructura.tipoPrecio[relPre.tipoprecio].espositivo;
    }
    var tieneAdvertencia:boolean=false;
    var color:string;
    if(!esValidoAtributo(relAtr, prodAtr) && !esValorNormal(relAtr, prodAtr) && relAtr.valor != null){
        color='#FFCE33';
        tieneAdvertencia = true;
    }
    if(esNormalizableSinValor(relAtr, prodAtr, relPre)){
        tieneAdvertencia = true;
        color='#FF9333';
    }
    if(!tieneAdvertencia){
        color='#FFFFFF';
    }
    return {tieneAdvertencia, color}
}

export function controlarPrecio(relPre:RelPre, estructura:Estructura){
    var atributoTieneAdvertencia:boolean=false;
    var color:string;
    relPre.atributos.forEach(function(relAtr){
        atributoTieneAdvertencia = atributoTieneAdvertencia || controlarAtributo(relAtr, relPre, estructura).tieneAdvertencia;
    });
    var tieneAdvertencias;
    if(relPre.precio && relPre.precionormalizado && (
        (relPre.comentariosrelpre == null && relPre.precionormalizado_1 && (relPre.precionormalizado < relPre.precionormalizado_1/2 || relPre.precionormalizado > relPre.precionormalizado_1*2)) ||
        (relPre.comentariosrelpre == null && relPre.promobs_1 && (relPre.precionormalizado < relPre.promobs_1/2 || relPre.precionormalizado > relPre.promobs_1*2)) 
       ) || atributoTieneAdvertencia
    ){
        color='#FF9333'; //naranja
        tieneAdvertencias = true;
    }else{
        color='#FFFFFF'; //blanco
        tieneAdvertencias = false;
    }
    return {tieneAdv: tieneAdvertencias, color: color};
}

export function razonNecesitaConfirmacion(estructura:Estructura, relVis:RelVis, razon:number){
    return !estructura.razones[razon].espositivoformulario
}

export function hayPreciosOAtributosCargadosEnFormulario(estructura:Estructura, relVis:RelVis){
    //Revisar
    //return likeAr(relVis.productos).map(function(producto:{observaciones:{[o:number]:RelPre}}){
    //    return likeAr(producto.observaciones).filter(function(relPre:RelPre){
    //        relPre.cambio != null || relPre.tipoprecio != null
    //    }).array();
    //}).array().length > 0
}