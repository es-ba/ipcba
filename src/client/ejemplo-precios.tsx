import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, RelAtr, AtributoDataTypes, HojaDeRuta, Razon, Estructura, RelInf, RelVis} from "./dm-tipos";
import {puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, puedeCambiarTP, tpNecesitaConfirmacion, razonNecesitaConfirmacion} from "./dm-funciones";
import {ActionHdr} from "./dm-react";
import {useState, useRef, useEffect, useImperativeHandle, createRef, forwardRef} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import * as likeAr from "like-ar";
import {Menu, MenuItem, ListItemText, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@material-ui/core";
import { Store } from "redux";


export var estructura:Estructura;

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
    return React.createElement(props.dataType=='text'?'textarea':'input',{
        ref:inputRef, 
        value:valueString, 
        type:props.dataType, 
        onChange:(event)=>{
            // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
            setValue(event.target.value);
        }, 
        onBlur:(event)=>{
            if(value!=props.value){
                // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                props.onUpdate(event.target.value);
            }
            props.onFocusOut();
        },
        onMouseOut:()=>{
            if(document.activeElement!=inputRef.current){
                props.onFocusOut();
            }
        },
        onKeyDown:event=>{
            var tecla = event.charCode || event.which;
            if((tecla==13 || tecla==9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
                if(!(props.onWantToMoveForward && props.onWantToMoveForward())){
                    if(inputRef.current!=null){
                        inputRef.current.blur();
                    }
                }
                event.preventDefault();
            }
        })
    )
}

const EditableTd = forwardRef(function<T extends any>(props:{
    disabled?:boolean,
    dataType: InputTypes,
    value:T, 
    className?:string, colSpan?:number, 
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
        <td colSpan={props.colSpan} className={props.className} onClick={
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
    relVis: RelVis, 
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
    onCopiarAtributos:()=>void,
    onWantToMoveForward?:()=>boolean},
    ref:React.Ref<Focusable>
){
    const relAtr = props.relAtr;
    const relPre = props.relPre;
    const relVis = props.relVis;
    const dispatch = useDispatch();
    const atributo = estructura.atributos[relAtr.atributo];
    return (
        <tr>
            <td className="nombre-atributo">{atributo.nombreatributo}</td>
            <td colSpan={2} className="atributo-anterior" >{relAtr.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={ () => {
                    dispatch({type: 'COPIAR_ATRIBUTOS', payload:{forPk:relAtr}})
                    props.onCopiarAtributos()
                }}>{puedeCopiarAtributos(estructura, relPre)?FLECHAATRIBUTOS:relPre.cambio}</td>
                :null}
            <EditableTd disabled={!puedeCambiarPrecioYAtributos(estructura, relPre, relVis)} colSpan={2} className="atributo-actual" dataType={adaptAtributoDataTypes(atributo.tipodato)} value={relAtr.valor} onUpdate={value=>{
                dispatch({type: 'SET_ATRIBUTO', payload:{forPk:relAtr, valor:value}})
            }} onWantToMoveForward={props.onWantToMoveForward} ref={ref} />
        </tr>
    )
});

function PreciosRow(props:{relPre:RelPre, relVis:RelVis})
{
    const relPre = props.relPre;
    const relVis = props.relVis;
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
            <div className="caja-producto">
                <div className="producto">{productoDef.nombreproducto}</div>
                <div className="observacion">{relPre.observacion==1?"":relPre.observacion.toString()}</div>
                <div className="especificacion">{productoDef.especificacioncompleta}</div>
            </div>
            <table className="caja-precios">
                <colgroup>
                    <col style={{width:"26%"}}/>
                    <col style={{width:"8%" }}/>
                    <col style={{width:"25%"}}/>
                    <col style={{width:"8%" }}/>
                    <col style={{width:"8%" }}/>
                    <col style={{width:"25%"}}/>
                </colgroup>                  
            <tr>
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
                                dispatch({type: 'SET_TP', payload:{forPk:relPre, tipoprecio:tpDef.tipoprecio}})
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
                            dispatch({type: 'SET_TP', payload:{forPk:relPre, tipoprecio:tipoDePrecioNegativoAConfirmar}})
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd disabled={!puedeCambiarPrecioYAtributos(estructura, relPre, relVis)} className="precio" value={relPre.precio} onUpdate={value=>{
                    dispatch({type: 'SET_PRECIO', payload:{forPk:relPre, precio:value}})
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
                    relVis={relVis}
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
            </table>
        </>
    );
}

function RelevamientoPrecios(props:{relVis:RelVis}){
    const relVis = props.relVis;
    const observaciones = relVis.observaciones;
    return (
        <>
            {observaciones.map((relPre:RelPre) => 
                <PreciosRow 
                    key={relPre.producto+'/'+relPre.observacion}
                    relPre={relPre}
                    relVis={relVis}
                />
            )}
        </>
    );
}

function RazonFormulario(props:{relVis:RelVis}){
    const relVis = props.relVis;
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
                        dispatch({type: 'SET_COMENTARIO_RAZON', payload:{forPk:relVis, comentarios:value}})
                    }}/>
                    <Menu id="simple-menu-razon" open={Boolean(menuRazon)} anchorEl={menuRazon} onClose={()=>setMenuRazon(null)}>
                    {likeAr(estructura.razones).map((razon:Razon,index)=>
                        <MenuItem key={razon.nombrerazon} onClick={()=>{
                            if(razonNecesitaConfirmacion(estructura, relVis,index)){
                                setRazonAConfirmar({razon:index});
                                setMenuConfirmarRazon(true)
                            }else{
                                dispatch({type: 'SET_RAZON', payload:{forPk:relVis, razon:index}})
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
                            dispatch({type: 'SET_RAZON', payload:{forPk:relVis, razon:razonAConfirmar.razon}})
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

interface RelVisPk {
    informante:number,
    formulario:number
}

function FormularioVisita(props:{relVisPk: RelVisPk, onReturn:()=>void}){
    const relVis = useSelector((hdr:HojaDeRuta)=>
        hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!
            .formularios.find(relVis=>relVis.formulario==props.relVisPk.formulario)!
    );
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
        <div className="informante-visita" pos-productos="izquierda" ref={ref}>
            <Button color="primary" variant="outlined" onClick={props.onReturn}>
                {FLECHAVOLVER}
            </Button>
            <RazonFormulario relVis={relVis}/>
            <RelevamientoPrecios relVis={relVis}/>
        </div>
    );
}

function InformanteRow(props:{informante:RelInf, onSelectVisita:(relVis:RelVis)=>void}){
    const informante = props.informante;
    return (
        <>
            <tr style={{verticalAlign:'top'}}>
                <td rowSpan={informante.formularios.length+1}>{informante.informante} {informante.nombreinformante}</td>
            </tr>
            {informante.formularios.map((relVis:RelVis)=>
                <tr key={informante.informante+'/'+relVis.formulario} onClick={()=>{
                    props.onSelectVisita(relVis)
                }}>
                    <td>{relVis.formulario} {estructura.formularios[relVis.formulario].nombreformulario}</td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            )}
        </>
    )
}

function HojaDeRuta(props:{onSelectVisita:(relVisPk:RelVisPk)=>void}){
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
                    <InformanteRow key={informante.informante} informante={informante} onSelectVisita={props.onSelectVisita}/>
                )}
            </tbody>
        </table>
    );
}

function AppDmIPC(){
    const [relVisPk, setRelVisPk] = useState<RelVisPk>();
    if(relVisPk == undefined){
        return <HojaDeRuta onSelectVisita={setRelVisPk}/>
    }else{
        return <FormularioVisita relVisPk={relVisPk} onReturn={()=>setRelVisPk(undefined)}/>
    }
}

export function mostrarHdr(store:Store<HojaDeRuta, ActionHdr>, miEstructura:Estructura){
    estructura=miEstructura;
    ReactDOM.render(
        <Provider store={store}>
            <AppDmIPC/>
        </Provider>,
        document.getElementById('main_layout')
    )
}