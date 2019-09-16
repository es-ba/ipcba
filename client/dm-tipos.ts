"use strict";


/* TODO: controlar los nombres y tipos de la base
 * atributo
 * producto
 * 
 */

export type Atributo = {
    atributo:string
    nombreatributo:string
    tipo:string
}

export type Producto={
    producto:string
    nombreproducto:string
    especificacion:string
    atributos:{
        [atributo:number]: true
    }
    listaAtributos:number[]
}

export type Formulario={
    formulario:number
    nombreformulario:string
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
    formularios:{[fomrulario:number]:Formulario}
}

export type RelAtr={
    valorAnterior:string
    valor:string
}

export type RelPre={
    observaciones:{
        [observacion:number]:{
            precio:number,
            precioAnterior:number,
            tipoPrecio:string,
            tipoPrecioAnterior:string,
            atributos:{
                [atributo:number]:RelAtr
            }
        }
    }
}

export type RelVis={
    razon: number,
    fechaVisita: number,
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