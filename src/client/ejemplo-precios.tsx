import * as React from "react";
import * as ReactDOM from "react-dom";
import {TipoPrecio, Atributo, Producto, ProdAtr, Formulario, Estructura, RelVis, RelAtr, RelPre} from "./dm-tipos";
import {tipoPrecio, tipoPrecioPredeterminado, tiposPrecioDef, productos, puedeCopiarTipoPrecio} from "./dm-constantes";
import {ProductoState, ActionFormulario} from "./dm-react";
import {useState, useRef, useEffect, useImperativeHandle, createRef, forwardRef} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import {changing, serie, deepFreeze} from "best-globals";
import * as likeAr from "like-ar";
import {Menu, MenuItem, ListItemText, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@material-ui/core";
import { Store } from "redux";

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";

type Focusable = {
    focus:()=>void
    blur:()=>void
}
type AtributoDataTypes = 'N'|'C';

type OnUpdate<T> = (data:T)=>void

type InputTypes = 'date'|'number'|'tel'|'text';

function adaptAtributoDataTypes(attrDataType:AtributoDataTypes):InputTypes{
    const adapter:{[key in AtributoDataTypes]:InputTypes} = {
        'N': 'number',
        'C': 'text'
    }
    return adapter[attrDataType]
}

function TypedInput<T>(props:{
    value:T,
    dataType: InputTypes
    onUpdate:OnUpdate<T>, 
    onFocusOut:()=>void, 
    onWantToMoveForward?:(()=>boolean)|null
}){
    var [value, setValue] = useState(props.value);
    const inputRef = useRef<HTMLInputElement>(null);
    useEffect(() => {
        if(inputRef.current != null){
            inputRef.current.focus();
        }
    }, []);
    // @ts-ignore acá hay un problema con el cambio de tipos
    var valueString:string = value==null?'':value;
    return (
        <input ref={inputRef} value={valueString} type={props.dataType} onChange={(event)=>{
            // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
            setValue(event.target.value);
        }} onBlur={(event)=>{
            if(value!=props.value){
                // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                props.onUpdate(event.target.value);
            }
            props.onFocusOut();
        }} onMouseOut={()=>{
            if(document.activeElement!=inputRef.current){
                props.onFocusOut();
            }
        }} onKeyDown={event=>{
            var tecla = event.charCode || event.which;
            if((tecla==13 || tecla==9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
                if(!(props.onWantToMoveForward && props.onWantToMoveForward())){
                    if(inputRef.current!=null){
                        inputRef.current.blur();
                    }
                }
                event.preventDefault();
            }
        }}/>
    )
}

const EditableTd = forwardRef(function<T extends any>(props:{
    disabled?:boolean,
    dataType: InputTypes,
    value:T, 
    className?:string, colSpan?:number, rowSpan?:number, 
    onUpdate:OnUpdate<T>, 
    onWantToMoveForward?:(()=>boolean)|null
},
    ref:React.Ref<Focusable>
){
    const [editando, setEditando] = useState(false);
    useImperativeHandle(ref, () => ({
        focus: () => {
            setEditando(true && !props.disabled)
        },
        blur: () => {
            setEditando(false)
        }
    }));    
    return (
        <td colSpan={props.colSpan} rowSpan={props.rowSpan} className={props.className} onClick={
            ()=>setEditando(true && !props.disabled)
        }>
            {editando?
                <TypedInput value={props.value} dataType={props.dataType} onUpdate={value =>{
                    props.onUpdate(value);
                }} onFocusOut={()=>{
                    setEditando(false);
                }} onWantToMoveForward={props.onWantToMoveForward}/>
            :<div>{props.value}</div>}
        </td>
    )
});

const AtributosRow = forwardRef(function(props:{
    dataAtributo:RelAtr, 
    cambio:string|null,
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
    habilitarCopiado:boolean, 
    deshabilitarAtributo:boolean,
    onCopiarAtributos:()=>void,
    onUpdate:(atributo:string, valor:string|null)=>void,
    onWantToMoveForward?:()=>boolean},
    ref:React.Ref<Focusable>
){
    const atributo = props.dataAtributo;
return (
        <tr>
            <td>{'attr'/*atributo.atributo*/}</td>
            <td colSpan={2} className="atributo-anterior" >{atributo.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={ () => {
                    if(props.habilitarCopiado){
                        props.onCopiarAtributos()
                    }
                }}>{props.habilitarCopiado?FLECHAATRIBUTOS:props.cambio}</td>
                :null}
            <EditableTd disabled={props.deshabilitarAtributo} colSpan={2} className="atributo-actual" dataType={adaptAtributoDataTypes(atributo.tipodato)} value={atributo.valor} onUpdate={value=>{
                //props.onUpdate(props.dataAtributo.atributo, value)
            }} onWantToMoveForward={props.onWantToMoveForward}
            ref={ref} />
        </tr>
    )
});

function PreciosRow(props:{
    producto:string,
    observacion:number
}){
    const productosState = useSelector((productos:ProductoState)=>productos);
    const relPre = productosState.byIds[props.producto].observaciones[props.observacion];
    const dispatch = useDispatch();
    const precioRef = useRef<HTMLInputElement>(null);
    const productoDef:Producto = productos[props.producto];
    const atributosRef = useRef(productoDef.listaAtributos.map(() => createRef<HTMLInputElement>()));
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    var deshabilitarPrecio = false; // mejorar
    // const [deshabilitarPrecio, setDeshabilitarPrecio] = useState<boolean>(relPre.tipoPrecio?!(tipoPrecio[relPre.tipoPrecio].espositivo):false);
    var habilitarCopiado = relPre.cambio==null && (!relPre.tipoprecio || tipoPrecio[relPre.tipoprecio].espositivo == 'S');
    return (
        <>
            <tr>
                <td className="col-prod-esp" rowSpan={productoDef.listaAtributos.length + 1}>
                    <div className="producto">{productoDef.nombreproducto}</div>
                    <div className="especificacion">{productoDef.especificacioncompleta}</div>
                </td>
                <td className="observaiones"><button>Obs.</button></td>
                <td className="tipoPrecioAnterior">{relPre.tipoprecioanterior}</td>
                <td className="precioAnterior">{relPre.precioanterior}</td>
                <td className="flechaTP" onClick={ () => {
                    dispatch({type: 'COPIAR_TP', payload:{producto:props.producto, observacion:props.observacion}})
                }}>{(puedeCopiarTipoPrecio(relPre))?FLECHATIPOPRECIO:''}</td>
                <td className="tipoPrecio"
                    onClick={event=>setMenuTipoPrecio(event.currentTarget)}
                >{relPre.tipoprecio}
                </td>
                <Menu id="simple-menu"
                    open={Boolean(menuTipoPrecio)}
                    anchorEl={menuTipoPrecio}
                    onClose={()=>setMenuTipoPrecio(null)}
                >
                    {tiposPrecioDef.map(tpDef=>
                        <MenuItem key={tpDef.tipoprecio} onClick={()=>{
                            setMenuTipoPrecio(null);
                            var necesitaConfirmacion = !tipoPrecio[tpDef.tipoprecio].espositivo && (relPre.precio != null || relPre.cambio != null);
                            if(necesitaConfirmacion){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                // setDeshabilitarPrecio(!tipoPrecio[tpDef.tipoprecio].espositivo);
                                //props.setTipoPrecioPositivo(tpDef.tipoprecio);
                            }
                            if(precioRef.current && !relPre.precio && tipoPrecio[tpDef.tipoprecio].espositivo){
                                precioRef.current.focus();
                            }
                        }}>
                            <ListItemText>{tpDef.tipoprecio}&nbsp;</ListItemText>
                            <ListItemText>&nbsp;{tpDef.nombretipoprecio}</ListItemText>
                        </MenuItem>
                    )}
                </Menu>
                <Dialog
                    open={menuConfirmarBorradoPrecio}
                    onClose={()=>setMenuConfirmarBorradoPrecio(false)}
                    aria-labelledby="alert-dialog-title"
                    aria-describedby="alert-dialog-description"
                >
                    <DialogTitle id="alert-dialog-title">{"Eligió un tipo de precio negativo pero había precios o atributos cargados"}</DialogTitle>
                    <DialogContent>
                        <DialogContentText id="alert-dialog-description">
                            Se borrará el precio y los atributos
                        </DialogContentText>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={()=>{
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="primary" variant="outlined">
                            No borrar
                        </Button>
                        <Button onClick={()=>{
                            //props.setTipoPrecioNegativo(tipoDePrecioNegativoAConfirmar!)
                            // setDeshabilitarPrecio(true);
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd disabled={deshabilitarPrecio} className="precio" value={relPre.precio} onUpdate={value=>{
                    //props.setPrecio(value);
                    if(!relPre.tipoprecio && relPre.precio){
                        //props.setTipoPrecioPositivo(tipoPrecioPredeterminado.tipoprecio);
                    }
                    if(precioRef.current!=null){
                        precioRef.current.blur()
                    }
                }} ref={precioRef} dataType="number"/>
            </tr>
            {productoDef.listaAtributos.map((atributo, index)=>
                <AtributosRow key={atributo}
                    dataAtributo={relPre.atributos[atributo]}
                    primerAtributo={index==0}
                    cambio={relPre.cambio}
                    habilitarCopiado={habilitarCopiado}
                    deshabilitarAtributo={deshabilitarPrecio}
                    cantidadAtributos={productoDef.listaAtributos.length}
                    ultimoAtributo={index == productoDef.listaAtributos.length-1}
                    onCopiarAtributos={()=>{
                        //props.onCopiarAtributos()
                        if(!relPre.precio && precioRef.current){
                            precioRef.current.focus();
                        }
                    }}
                    onUpdate={(atributo:string, valor:string|null)=>{
                        //props.updateAtributo(atributo,valor)
                    }}
                    onWantToMoveForward={()=>{
                        if(index<productoDef.listaAtributos.length-1){
                            var nextItemRef=atributosRef.current[index+1];
                            if(nextItemRef.current!=null){
                                nextItemRef.current.focus()
                                return true;
                            }
                        }else{
                            if(!relPre.precio){
                                if(precioRef.current){
                                    precioRef.current.focus();
                                    return true;
                                }
                            }
                        }
                        return false;
                    }}
                    ref={atributosRef.current[index]}
                />
            )}
        </>
    );
}

function PruebaRelevamientoPrecios(){
    const productosState = useSelector((productos:ProductoState)=>productos);
    const ref = useRef<HTMLTableElement>(null);
    useEffect(()=>{
        if(ref.current){
            var thInThead=ref.current.querySelectorAll('thead th');
            var minReducer = (min:number, th:HTMLElement)=>Math.min(min, th.offsetTop);
            // @ts-ignore
            var minTop = Array.prototype.reduce.call(thInThead, minReducer, Number.MAX_VALUE)
            Array.prototype.map.call(thInThead,(th:HTMLElement)=>{
                th.style.top = th.offsetTop - minTop + 'px'
            })
        }
    })
    return (
        <table className="formulario-precios" ref={ref}>
            <caption>Formulario X</caption>
            <thead>
                <tr>
                    <th rowSpan={2}>producto<br/>especificación</th>
                    <th rowSpan={2}>obs.<br/>atributos</th>
                    <th colSpan={2}>anterior</th>
                    <th rowSpan={2} className="flechaTitulos"></th>
                    <th colSpan={2}>actual</th>
                </tr>
                <tr>
                    <th>TP</th>
                    <th>precio</th>
                    <th>TP</th>
                    <th>precio</th>
                </tr>
            </thead>
            <tbody>
            {productosState.allIds.map((idProducto:string) => {
                var miProducto = productosState.byIds[idProducto];
                return likeAr(miProducto.observaciones).map((_relPre:RelPre, observacion:number)=>
                    <PreciosRow 
                        key={idProducto+observacion.toString()}
                        producto={idProducto} 
                        observacion={observacion}
                    />
                ).array()
                }
            )}
            </tbody>
        </table>
    );
}

export function mostrarHdr(store:Store<ProductoState, ActionFormulario>){
    ReactDOM.render(
        <Provider store={store}>
            <PruebaRelevamientoPrecios/>
        </Provider>,
        document.getElementById('main_layout')
    )
}