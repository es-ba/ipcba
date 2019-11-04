import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, AtributoDataTypes, HojaDeRuta, Razon} from "./dm-tipos";
import {tiposPrecioDef, estructura} from "./dm-estructura";
import {puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, tpNecesitaConfirmacion, razonNecesitaConfirmacion} from "./dm-funciones";
import {ActionHdr} from "./dm-react";
import {useState, useRef, useEffect, useImperativeHandle, createRef, forwardRef} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import * as likeAr from "like-ar";
import * as bestGlobals from "best-globals";
import {Menu, MenuItem, ListItemText, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@material-ui/core";
import { Store } from "redux";
import { string } from "prop-types";

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";

type Focusable = {
    focus:()=>void
    blur:()=>void
}
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
            setEditando(true)
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
    informante: number,
    formulario: number,
    producto: string,
    observacion: number,
    atributo: number,
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
    onCopiarAtributos:()=>void,
    onWantToMoveForward?:()=>boolean},
    ref:React.Ref<Focusable>
){
    const productosState = useSelector((hdr:HojaDeRuta)=>hdr.informantes[props.informante].formularios[props.formulario].productos);
    const relPre = productosState[props.producto].observaciones[props.observacion];
    const relAtr = productosState[props.producto].observaciones[props.observacion].atributos[props.atributo];
    const dispatch = useDispatch();
    const atributo = estructura.atributos[props.atributo];
    return (
        <tr>
            <td>{atributo.nombreatributo}</td>
            <td colSpan={2} className="atributo-anterior" >{relAtr.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={ () => {
                    dispatch({type: 'COPIAR_ATRIBUTOS', payload:{producto:props.producto, observacion:props.observacion}})
                    props.onCopiarAtributos()
                }}>{puedeCopiarAtributos(relPre)?FLECHAATRIBUTOS:relPre.cambio}</td>
                :null}
            <EditableTd disabled={!puedeCambiarPrecioYAtributos(relPre)} colSpan={2} className="atributo-actual" dataType={adaptAtributoDataTypes(atributo.tipodato)} value={relAtr.valor} onUpdate={value=>{
                dispatch({type: 'SET_ATRIBUTO', payload:{producto:props.producto, observacion:props.observacion, atributo:props.atributo, valor:value}})
            }} onWantToMoveForward={props.onWantToMoveForward} ref={ref} />
        </tr>
    )
});

function PreciosRow(props:{
    informante: number,
    formulario: number,
    producto:string,
    observacion:number
}){
    const productosState = useSelector((hdr:HojaDeRuta)=>hdr.informantes[props.informante].formularios[props.formulario].productos);
    const relPre = productosState[props.producto].observaciones[props.observacion];
    const dispatch = useDispatch();
    const precioRef = useRef<HTMLInputElement>(null);
    const productoDef:Producto = estructura.productos[props.producto];
    const atributosRef = useRef(productoDef.listaAtributos.map(() => createRef<HTMLInputElement>()));
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [dialogoObservaciones, setDialogoObservaciones] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    return (
        <>
            <tr>
                <td className="col-prod-esp" rowSpan={productoDef.listaAtributos.length + 1}>
                    <div className="producto">{productoDef.nombreproducto}</div>
                    <div className="especificacion">{productoDef.especificacioncompleta}</div>
                </td>
                <td className="observaiones">
                    <Button color="primary" variant="outlined" onClick={()=>{
                        setDialogoObservaciones(true)
                    }}>
                        OBS
                    </Button>
                    <Dialog
                    open={dialogoObservaciones}
                    onClose={()=>setDialogoObservaciones(false)}
                    aria-labelledby="alert-dialog-title"
                    aria-describedby="alert-dialog-description"
                >
                    <DialogTitle id="alert-dialog-title-obs">{"Observaciones del precio"}</DialogTitle>
                    <DialogContent>
                        <DialogContentText id="alert-dialog-description-obs">
                            acá van las obs
                        </DialogContentText>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={()=>{
                            setDialogoObservaciones(false)
                        }} color="primary" variant="outlined">
                            Guardar
                        </Button>
                        <Button onClick={()=>{
                            setDialogoObservaciones(false)
                        }} color="secondary" variant="outlined">
                            Descartar Observaciones
                        </Button>
                    </DialogActions>
                </Dialog>
                </td>
                <td className="tipoPrecioAnterior">{relPre.tipoprecioanterior}</td>
                <td className="precioAnterior">{relPre.precioanterior}</td>
                <td className="flechaTP" onClick={ () => {
                    if(tpNecesitaConfirmacion(relPre,relPre.tipoprecioanterior!)){
                        setTipoDePrecioNegativoAConfirmar(relPre.tipoprecioanterior);
                        setMenuConfirmarBorradoPrecio(true)
                    }else{
                        dispatch({type: 'COPIAR_TP', payload:{producto:props.producto, observacion:props.observacion}})
                    }
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
                            if(tpNecesitaConfirmacion(relPre,tpDef.tipoprecio)){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                dispatch({type: 'SET_TP', payload:{producto:props.producto, observacion:props.observacion, valor:tpDef.tipoprecio}})
                                if(precioRef.current && !relPre.precio && estructura.tipoPrecio[tpDef.tipoprecio].espositivo == 'S'){
                                    precioRef.current.focus();
                                }
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
                    <DialogTitle id="alert-dialog-title-tpm">{"Eligió un tipo de precio negativo pero había precios o atributos cargados"}</DialogTitle>
                    <DialogContent>
                        <DialogContentText id="alert-dialog-description-tpn">
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
                            dispatch({type: 'SET_TP', payload:{producto:props.producto, observacion:props.observacion, valor:tipoDePrecioNegativoAConfirmar}})
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd disabled={!puedeCambiarPrecioYAtributos(relPre)} className="precio" value={relPre.precio} onUpdate={value=>{
                    dispatch({type: 'SET_PRECIO', payload:{producto:props.producto, observacion:props.observacion, valor:value}})
                    if(precioRef.current!=null){
                        precioRef.current.blur()
                    }
                }} ref={precioRef} dataType="number" onWantToMoveForward={()=>{
                    var nextItemRef=atributosRef.current[0];
                    if(nextItemRef.current!=null){
                        nextItemRef.current.focus()
                        return true;
                    }
                    return false;
                }}/>
            </tr>
            {productoDef.listaAtributos.map((atributo, index)=>
                <AtributosRow key={atributo}
                    informante={props.informante}
                    formulario={props.formulario}
                    producto={props.producto}
                    observacion={props.observacion}
                    atributo={atributo}
                    primerAtributo={index==0}
                    cantidadAtributos={productoDef.listaAtributos.length}
                    ultimoAtributo={index == productoDef.listaAtributos.length-1}
                    onCopiarAtributos={()=>{
                        if(precioRef.current && !relPre.precio && puedeCopiarAtributos(relPre)){
                            precioRef.current.focus();
                        }
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

function RelevamientoPrecios(props:{informante: number,formulario: number,}){
    return (
        <table className="formulario-precios">
            <caption>Formulario {props.formulario}</caption>
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
            {estructura.formularios[props.formulario].listaProductos.map((producto:string) => {
                var forProd = estructura.formularios[props.formulario].productos[producto];
                return bestGlobals.serie({from:1, to:forProd.observaciones}).map(observacion=>
                    <PreciosRow 
                        key={producto+'/'+observacion}
                        informante={props.informante}
                        formulario={props.formulario}
                        producto={producto}
                        observacion={observacion}
                    />
                )
            })}
            </tbody>
        </table>
    );
}

function RazonFormulario(props:{informante: number,formulario: number,}){
    const relVis = useSelector((hdr:HojaDeRuta)=>hdr.informantes[props.informante].formularios[props.formulario]);
    const razones = estructura.razones;
    const [menuRazon, setMenuRazon] = useState<HTMLElement|null>(null);
    const [razonAConfirmar, setRazonAConfirmar] = useState<{razon:number|null, nombreRazon:string|null}>({razon:null, nombreRazon:null});
    const [menuConfirmarRazon, setMenuConfirmarRazon] = useState<boolean>(false);
    const dispatch = useDispatch();
    return (
        <table className="razon-formulario">
            <thead>
                <tr>
                    <th>razon</th>
                    <th>nombre</th>
                    <th>comentarios</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td onClick={event=>setMenuRazon(event.currentTarget)}>{relVis.razon}</td>
                    <td>{relVis.razon?razones[relVis.razon].nombrerazon:null}</td>
                    <EditableTd disabled={false} colSpan={1} className="comentarios-razon" dataType={"text"} value={relVis.comentarios} onUpdate={value=>{
                        dispatch({type: 'SET_COMENTARIO_RAZON', payload:{informante:props.informante, formulario:props.formulario, valor:value}})
                    }}/>
                    <Menu id="simple-menu-razon" open={Boolean(menuRazon)} anchorEl={menuRazon} onClose={()=>setMenuRazon(null)}>
                    {likeAr(estructura.razones).map((razon:Razon,index)=>
                        <MenuItem key={razon.nombrerazon} onClick={()=>{
                            if(razonNecesitaConfirmacion(relVis,index)){
                                setRazonAConfirmar({razon:index, nombreRazon:razon.nombrerazon});
                                setMenuConfirmarRazon(true)
                            }else{
                                dispatch({type: 'SET_RAZON', payload:{informante:props.informante, formulario:props.formulario, valor:index}})
                            }
                            setMenuRazon(null)
                        }}>
                            <ListItemText>&nbsp;{index}</ListItemText>
                            <ListItemText>&nbsp;{razon.nombrerazon}</ListItemText>
                        </MenuItem>
                    ).array()}
                </Menu>
                <Dialog
                    open={menuConfirmarRazon}
                    onClose={()=>setMenuConfirmarRazon(false)}
                    aria-labelledby="alert-dialog-title"
                    aria-describedby="alert-dialog-description"
                >
                    <DialogTitle id="alert-dialog-title-rn">{`Confirmación de razón negativa`}</DialogTitle>
                    <DialogContent>
                        <DialogContentText id="alert-dialog-description-rn">
                            <div>
                                Eligió la razón de no contacto {razonAConfirmar.razon} {razonAConfirmar.nombreRazon}. Se borrarán x precios ingresados.
                            </div>
                            <div>
                                Confirme el numero de precios a borrar
                            </div>
                        </DialogContentText>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={()=>{
                            setMenuConfirmarRazon(false)
                        }} color="primary" variant="outlined">
                            No borrar
                        </Button>
                        <Button onClick={()=>{
                            dispatch({type: 'SET_RAZON', payload:{informante:props.informante, formulario:props.formulario, valor:razonAConfirmar.razon}})
                            setMenuConfirmarRazon(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                </tr>
            </tbody>
        </table>
    );
}

function InformanteVisita(props:{informante: number,formulario: number,}){
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
        <div className="informante-visita" ref={ref}>
            <RazonFormulario informante={props.informante} formulario={props.formulario}/>
            <RelevamientoPrecios informante={props.informante} formulario={props.formulario}/>
        </div>
    );
}

export function mostrarHdr(store:Store<HojaDeRuta, ActionHdr>){
    ReactDOM.render(
        <Provider store={store}>
            <InformanteVisita informante={3333} formulario={99}/>
        </Provider>,
        document.getElementById('main_layout')
    )
}