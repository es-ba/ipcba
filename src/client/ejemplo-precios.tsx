import * as React from "react";
import * as ReactDOM from "react-dom";
import {TipoPrecio, Atributo, Producto, ProdAtr, Formulario, Estructura, RelVis, RelAtr, RelPre,} from "./dm-tipos";
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

/* SEPARAR*/

var productos:{[p:string]:Producto} = {
    P01:{
        producto:'P01',
        nombreproducto:'Lata de tomate',
        especificacioncompleta:'Lata de tomate perita enteros pelado de 120 a 140g neto',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:'N',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,16]
    },
    P02:{
        producto:'P02',
        nombreproducto:'Lata de arvejas',
        especificacioncompleta:'Lata de arvejas peladas de 120 a 140g neto',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,16]
    },
    P03:{
        producto:'P02',
        nombreproducto:'Yerba',
        especificacioncompleta:'Paquete de yerba con palo en envase de papel de 500g',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:3,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            },
            55:{
                orden:2,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,55,16]
    }
}

var tiposPrecioDef:TipoPrecio[]=[
    {tipoprecio:'P', nombretipoprecio:'Precio normal'   , espositivo:'S', puedecopiar:'N' , predeterminado:true},
    {tipoprecio:'O', nombretipoprecio:'Oferta'          , espositivo:'S', puedecopiar:'N' },
    {tipoprecio:'B', nombretipoprecio:'Bonificado'      , espositivo:'S', puedecopiar:'N' },
    {tipoprecio:'S', nombretipoprecio:'Sin existencia'  , espositivo:'N', puedecopiar:'N' },
    {tipoprecio:'N', nombretipoprecio:'No vende'        , espositivo:'N', puedecopiar:'S'},
    {tipoprecio:'E', nombretipoprecio:'Falta estacional', espositivo:'N', puedecopiar:'S'},
];

var tipoPrecio=likeAr.createIndex(tiposPrecioDef, 'tipoprecio');

var tipoPrecioPredeterminado = tiposPrecioDef.find(tp=>tp.predeterminado)!;


/*FIN SEPARAR*/


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
    observacion:number,
    relPre:RelPre, 
    //formulario:Formulario,
    //onCopiarAtributos:()=>void,
    //setPrecio:(precio:number|null)=>void,
    //setTipoPrecioPositivo:(tipoPrecio:string)=>void,
    //setTipoPrecioNegativo:(tipoDePrecioNegativo:string)=>void,
    //updateAtributo:(atributo:string, valor:string|null)=>void
    //onUpdate:(dataPrecio:RelPre)=>void,
}){
    const precioRef = useRef<HTMLInputElement>(null);
    const productoDef:Producto = productos[props.producto];
    const atributosRef = useRef(productoDef.listaAtributos.map(() => createRef<HTMLInputElement>()));
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    var deshabilitarPrecio = false; // mejorar
    // const [deshabilitarPrecio, setDeshabilitarPrecio] = useState<boolean>(props.relPre.tipoPrecio?!(tipoPrecio[props.relPre.tipoPrecio].espositivo):false);
    var habilitarCopiado = props.relPre.cambio==null && (!props.relPre.tipoprecio || tipoPrecio[props.relPre.tipoprecio].espositivo == 'S');
    return (
        <>
            <tr>
                <td className="col-prod-esp" rowSpan={productoDef.listaAtributos.length + 1}>
                    <div className="producto">{productoDef.nombreproducto}</div>
                    <div className="especificacion">{productoDef.especificacioncompleta}</div>
                </td>
                <td className="observaiones"><button>Obs.</button></td>
                <td className="tipoPrecioAnterior">{props.relPre.tipoprecioanterior}</td>
                <td className="precioAnterior">{props.relPre.precioanterior}</td>
                { props.relPre.tipoprecio==null 
                    && props.relPre.tipoprecioanterior!=null 
                    && tipoPrecio[props.relPre.tipoprecioanterior].puedecopiar
                ?
                    <td className="flechaTP" onClick={ () => {
                        if(tipoPrecio[props.relPre.tipoprecioanterior!].espositivo){
                            //props.setTipoPrecioPositivo(props.relPre.tipoprecioanterior!);
                        }else{
                            //props.setTipoPrecioNegativo(props.relPre.tipoprecioanterior!);    
                        }
                        
                    }}>{FLECHATIPOPRECIO}</td>
                :
                    <td className="flechaTP"></td>
                }
                <td className="tipoPrecio"
                    onClick={event=>setMenuTipoPrecio(event.currentTarget)}
                >{props.relPre.tipoprecio}
                </td>
                <Menu id="simple-menu"
                    open={Boolean(menuTipoPrecio)}
                    anchorEl={menuTipoPrecio}
                    onClose={()=>setMenuTipoPrecio(null)}
                >
                    {tiposPrecioDef.map(tpDef=>
                        <MenuItem key={tpDef.tipoprecio} onClick={()=>{
                            setMenuTipoPrecio(null);
                            var necesitaConfirmacion = !tipoPrecio[tpDef.tipoprecio].espositivo && (props.relPre.precio != null || props.relPre.cambio != null);
                            if(necesitaConfirmacion){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                // setDeshabilitarPrecio(!tipoPrecio[tpDef.tipoprecio].espositivo);
                                //props.setTipoPrecioPositivo(tpDef.tipoprecio);
                            }
                            if(precioRef.current && !props.relPre.precio && tipoPrecio[tpDef.tipoprecio].espositivo){
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
                <EditableTd disabled={deshabilitarPrecio} className="precio" value={props.relPre.precio} onUpdate={value=>{
                    //props.setPrecio(value);
                    if(!props.relPre.tipoprecio && props.relPre.precio){
                        //props.setTipoPrecioPositivo(tipoPrecioPredeterminado.tipoprecio);
                    }
                    if(precioRef.current!=null){
                        precioRef.current.blur()
                    }
                }} ref={precioRef} dataType="number"/>
            </tr>
            {productoDef.listaAtributos.map((atributo, index)=>
                <AtributosRow key={atributo}
                    dataAtributo={props.relPre.atributos[atributo]}
                    primerAtributo={index==0}
                    cambio={props.relPre.cambio}
                    habilitarCopiado={habilitarCopiado}
                    deshabilitarAtributo={deshabilitarPrecio}
                    cantidadAtributos={productoDef.listaAtributos.length}
                    ultimoAtributo={index == productoDef.listaAtributos.length-1}
                    onCopiarAtributos={()=>{
                        //props.onCopiarAtributos()
                        if(!props.relPre.precio && precioRef.current){
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
                            if(!props.relPre.precio){
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
                return likeAr(miProducto.observaciones).map((relPre:RelPre, observacion:number)=>
                    <PreciosRow 
                        //formulario={formulario} // se va con redux 
                        relPre={relPre} // se va con redux 
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