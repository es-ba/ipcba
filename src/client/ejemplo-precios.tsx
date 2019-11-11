import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, RelAtr, AtributoDataTypes, HojaDeRuta, Razon, Estructura, RelInf, Formulario, RelVis} from "./dm-tipos";
import {puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, tpNecesitaConfirmacion, razonNecesitaConfirmacion} from "./dm-funciones";
import {ActionHdr} from "./dm-react";
import {useState, useRef, useEffect, useImperativeHandle, createRef, forwardRef} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import * as likeAr from "like-ar";
import * as bestGlobals from "best-globals";
import {Menu, MenuItem, ListItemText, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@material-ui/core";
import { Store } from "redux";


export var estructura:Estructura;
var elStore:Store<HojaDeRuta, ActionHdr>;

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";
const FLECHAVOLVER="←";

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
    relAtr: RelAtr, 
    relPre: RelPre,
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
    onCopiarAtributos:()=>void,
    onWantToMoveForward?:()=>boolean},
    ref:React.Ref<Focusable>
){
    const relAtr = props.relAtr;
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const atributo = estructura.atributos[relAtr.atributo];
    return (
        <tr>
            <td>{atributo.nombreatributo}</td>
            <td colSpan={2} className="atributo-anterior" >{relAtr.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={ () => {
                    dispatch({type: 'COPIAR_ATRIBUTOS', payload:{forPk:relAtr}})
                    props.onCopiarAtributos()
                }}>{puedeCopiarAtributos(estructura, relPre)?FLECHAATRIBUTOS:relPre.cambio}</td>
                :null}
            <EditableTd disabled={!puedeCambiarPrecioYAtributos(estructura, relPre)} colSpan={2} className="atributo-actual" dataType={adaptAtributoDataTypes(atributo.tipodato)} value={relAtr.valor} onUpdate={value=>{
                dispatch({type: 'SET_ATRIBUTO', payload:{forPk:relAtr, valor:value}})
            }} onWantToMoveForward={props.onWantToMoveForward} ref={ref} />
        </tr>
    )
});

function PreciosRow(props:{relPre:RelPre})
{
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const precioRef = useRef<HTMLInputElement>(null);
    const productoDef:Producto = estructura.productos[relPre.producto];
    const atributosRef = useRef(productoDef.lista_atributos.map(() => createRef<HTMLInputElement>()));
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [dialogoObservaciones, setDialogoObservaciones] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    return (
        <>
            <tr>
                <td className="col-prod-esp" rowSpan={relPre.atributos.length + 1}>
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
                    if(tpNecesitaConfirmacion(estructura, relPre,relPre.tipoprecioanterior!)){
                        setTipoDePrecioNegativoAConfirmar(relPre.tipoprecioanterior);
                        setMenuConfirmarBorradoPrecio(true)
                    }else{
                        dispatch({type: 'COPIAR_TP', payload:{forPk:relPre}});
                    }
                }}>{(puedeCopiarTipoPrecio(estructura, relPre))?FLECHATIPOPRECIO:''}</td>
                <td className="tipoPrecio"
                    onClick={event=>setMenuTipoPrecio(event.currentTarget)}
                >{relPre.tipoprecio}
                </td>
                <Menu id="simple-menu"
                    open={Boolean(menuTipoPrecio)}
                    anchorEl={menuTipoPrecio}
                    onClose={()=>setMenuTipoPrecio(null)}
                >
                    {estructura.tiposPrecioDef.map(tpDef=>
                        <MenuItem key={tpDef.tipoprecio} onClick={()=>{
                            setMenuTipoPrecio(null);
                            if(tpNecesitaConfirmacion(estructura, relPre,tpDef.tipoprecio)){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                dispatch({type: 'SET_TP', payload:{forPk:relPre, valor:tpDef.tipoprecio}})
                                if(precioRef.current && !relPre.precio && estructura.tipoPrecio[tpDef.tipoprecio].espositivo){
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
                            dispatch({type: 'SET_TP', payload:{forPk:relPre, valor:tipoDePrecioNegativoAConfirmar}})
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd disabled={!puedeCambiarPrecioYAtributos(estructura, relPre)} className="precio" value={relPre.precio} onUpdate={value=>{
                    dispatch({type: 'SET_PRECIO', payload:{forPk:relPre, valor:value}})
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
            {relPre.atributos.map((relAtr, index)=>
                <AtributosRow key={relPre.producto+'/'+relPre.observacion+'/'+relAtr.atributo}
                    relPre={relPre}
                    relAtr={relAtr}
                    primerAtributo={index==0}
                    cantidadAtributos={relPre.atributos.length}
                    ultimoAtributo={index == relPre.atributos.length-1}
                    onCopiarAtributos={()=>{
                        if(precioRef.current && !relPre.precio && puedeCopiarAtributos(estructura, relPre)){
                            precioRef.current.focus();
                        }
                    }}
                    onWantToMoveForward={()=>{
                        if(index<relPre.atributos.length-1){
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
    const productos = useSelector((hdr:HojaDeRuta)=>hdr.informantes_idx[props.informante].formularios_idx[props.formulario].productos);
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
            {productos.map((producto) => {
                var forProd = estructura.formularios[props.formulario].productos[producto.producto];
                return bestGlobals.serie({from:1, to:forProd.observaciones}).map(observacion=>
                    <PreciosRow 
                        key={producto.producto+'/'+observacion}
                        informante={props.informante}
                        formulario={props.formulario}
                        producto={producto.producto}
                        observacion={observacion}
                    />
                )
            })}
            </tbody>
        </table>
    );
}

function RazonFormulario(props:{informante: number,formulario: number,}){
    const relVis = useSelector((hdr:HojaDeRuta)=>hdr.informantes_idx[props.informante].formularios_idx[props.formulario]);
    const razones = estructura.razones;
    const [menuRazon, setMenuRazon] = useState<HTMLElement|null>(null);
    const [razonAConfirmar, setRazonAConfirmar] = useState<{razon:number|null}>({razon:null});
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
                            if(razonNecesitaConfirmacion(estructura, relVis,index)){
                                setRazonAConfirmar({razon:index});
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
                                Eligió la razón de no contacto {razonAConfirmar.razon?`${razonAConfirmar.razon} ${estructura.razones[razonAConfirmar.razon].nombrerazon}`:''}. Se borrarán x precios ingresados.
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

function InformanteVisita(props:{informante: number,formulario: number}){
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
            <Button color="primary" variant="outlined" onClick={()=>{
                ReactDOM.render(
                    <Provider store={elStore}>
                        <HojaDeRuta/>   
                    </Provider>,
                    document.getElementById('main_layout')
                )
            }}>
                {FLECHAVOLVER}
            </Button>
            <RazonFormulario informante={props.informante} formulario={props.formulario}/>
            <RelevamientoPrecios informante={props.informante} formulario={props.formulario}/>
        </div>
    );
}

function InformanteRow(props:{informanteId:number}){
    const informante = useSelector((hdr:HojaDeRuta)=>hdr.informantes_idx[props.informanteId]);
    return (
        <>
            <tr>
                <td rowSpan={likeAr(informante.formularios).array().length+1}>{props.informanteId} {informante.nombreinformante}</td>
            </tr>
            {informante.formularios.map((visita:RelVis)=>
                <tr key={props.informanteId+'/'+visita.formulario} onClick={()=>{
                    ReactDOM.render(
                        <Provider store={elStore}>
                            <InformanteVisita informante={props.informanteId} formulario={visita.formulario}/>   
                        </Provider>,
                        document.getElementById('main_layout')
                    )
                }}>
                    <td>{visita.formulario} {estructura.formularios[visita.formulario].nombreformulario}</td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            )}
        </>
    )
}

function HojaDeRuta(){
    const informantes = useSelector((hdr:HojaDeRuta)=>hdr.informantes);
    return (
        <table id="hoja-ruta">
            <thead>
                <tr>
                    <th>informante</th>
                    <th>formularios</th>
                    <th>prod</th>
                    <th>faltan</th>
                    <th>adv</th>
                </tr>
            </thead>
            <tbody>
                {informantes.map((informante:RelInf)=>
                    <InformanteRow key={informante.informante} informanteId={informante.informante}/>
                )}
            </tbody>
        </table>
    );
}

export function mostrarHdr(store:Store<HojaDeRuta, ActionHdr>, miEstructura:Estructura){
    estructura=miEstructura;
    elStore=store;
    ReactDOM.render(
        <Provider store={store}>
            <HojaDeRuta/>
        </Provider>,
        document.getElementById('main_layout')
    )
}