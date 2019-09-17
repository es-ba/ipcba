"use strict";


/* TODO: controlar los nombres y tipos de la base
 * atributo
 * producto
 * 
 */

export type Atributo = {
    atributo:string
    tipodato:string
    nombreatributo:string
    prodatr__rangodesde: number
    prodatr__rangohasta: number
    prodatr__valornormal: number
    prodatr__normalizable: string
    normalizable: string
    escantidad: string
    prodatr__orden: number
    opciones: string
    especificaciones__mostrar_cant_um: string
}

export type Producto={
    producto:string
    nombreproducto:string  //AGREGAR A CONSULTA (actualmente lo muestra en un objeto llamado productocompleto)
    especificacioncompleta: string //AGREGAR A CONSULTA (actualmente lo muestra en un objeto llamado productocompleto)
    atributos:{
        [atributo:number]: true
    }
    listaAtributos:number[]
}

export type Formulario={
    formulario:number
    nombreformulario:string //AGREGAR a MOBILE VISITA, actualmente está en HOJA DE RUTA
    orden: number
    productos:{
        [producto:string]: {
            observaciones: number
        }
    }
    ListaProductos:number[]
}

export type Estructura={
    atributos:{[atributo:number]:Atributo}
    productos:{[producto:string]:Producto}
    formularios:{[formulario:number]:Formulario}
}

export type RelAtr={
    valoranterior:string
    valor:string
    valornormal: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
    prioridad: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
    normalizable: string //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
    tiponormalizacion: string //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
    valor_pesos: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
}

export type RelPre={
    observaciones:{
        [observacion:number]:{
            precio:number,
            precioanterior:number,
            tipopecio:string,
            tipoprecioanterior:string,
            atributos:{
                [atributo:number]:RelAtr
            }
            cambio: string
            comentariosrelpre: string
            precionormalizado: number
            precionormalizado_1: number
            promobs_1: number
            normsindato:string
            fueraderango:string
            sinpreciohace4meses:string
            adv: boolean
        }
    }
}

export type RelVis={
    formulario: number
    razon: number
    raz__escierredefinitivoinf: string
    raz__escierredefinitivofor: string
    comentarios: string
    productos:{
        [producto:number]:RelPre
    }
};

export type Informante={
    informante:number,
    informantenombre:string,
    domicilio:string,
    formularios:{
        [formulario:number]:RelVis
    }
}

export type HojaDeRuta={
    encuestador:string,
    dispositivo:string,
    fechaCarga:Date,
    informantes:{[informante:number]:Informante}
}