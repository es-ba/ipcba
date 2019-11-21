import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, RelAtr, AtributoDataTypes, HojaDeRuta, Razon, Estructura, RelInf, RelVis} from "./dm-tipos";
import {puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, puedeCambiarTP, tpNecesitaConfirmacion, razonNecesitaConfirmacion} from "./dm-funciones";
import {ActionHdr, dispatchers, dmTraerDatosHdr } from "./dm-react";
import {useState, useEffect} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import * as likeAr from "like-ar";
import * as clsx from 'clsx';
import {
    AppBar, Button, ButtonGroup, CssBaseline, Dialog, DialogActions, DialogContent, DialogContentText, 
    DialogTitle, Divider, Fab, Grid, IconButton, InputBase, List, ListItem, ListItemIcon, ListItemText, Drawer, 
    Menu, MenuItem, useScrollTrigger, SvgIcon, Toolbar, Typography, Zoom
} from "@material-ui/core";
import { createStyles, makeStyles, useTheme, Theme, fade} from '@material-ui/core/styles';
import { Store } from "redux";
import { prototype } from "events";

// https://material-ui.com/components/material-icons/
export const materialIoIconsSvgPath={
    Assignment: "M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z",
    ChevronLeft: "M14.71 6.71a.9959.9959 0 00-1.41 0L8.71 11.3c-.39.39-.39 1.02 0 1.41l4.59 4.59c.39.39 1.02.39 1.41 0 .39-.39.39-1.02 0-1.41L10.83 12l3.88-3.88c.39-.39.38-1.03 0-1.41z",
    ChevronRight: "M9.29 6.71c-.39.39-.39 1.02 0 1.41L13.17 12l-3.88 3.88c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l4.59-4.59c.39-.39.39-1.02 0-1.41L10.7 6.7c-.38-.38-1.02-.38-1.41.01z",
    Close: "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    Code: "M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z",
    Description: "M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z",
    EmojiObjects: "M12 3c-.46 0-.93.04-1.4.14-2.76.53-4.96 2.76-5.48 5.52-.48 2.61.48 5.01 2.22 6.56.43.38.66.91.66 1.47V19c0 1.1.9 2 2 2h.28c.35.6.98 1 1.72 1s1.38-.4 1.72-1H14c1.1 0 2-.9 2-2v-2.31c0-.55.22-1.09.64-1.46C18.09 13.95 19 12.08 19 10c0-3.87-3.13-7-7-7zm2 16h-4v-1h4v1zm0-2h-4v-1h4v1zm-1.5-5.59V14h-1v-2.59L9.67 9.59l.71-.71L12 10.5l1.62-1.62.71.71-1.83 1.82z",
    ExpandLess: "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z",
    ExpandMore: "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z",
    Info: "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z",
    KeyboardArrowUp: "M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z",
    Label: "M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z",
    LocalAtm: "M11 17h2v-1h1c.55 0 1-.45 1-1v-3c0-.55-.45-1-1-1h-3v-1h4V8h-2V7h-2v1h-1c-.55 0-1 .45-1 1v3c0 .55.45 1 1 1h3v1H9v2h2v1zm9-13H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4V6h16v12z",
    Menu: "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z",
    Search: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    Warning: "M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z",
}

const ICON = likeAr(materialIoIconsSvgPath).map(svgText=> () =>
    <SvgIcon><path d={svgText}/></SvgIcon>
).plain();

const ChevronLeftIcon = ICON.ChevronLeft;
const ChevronRightIcon = ICON.ChevronRight;
const MenuIcon = ICON.Menu;
const DescriptionIcon = ICON.Description;
const SearchIcon = ICON.Search;
const KeyboardArrowUpIcon = ICON.KeyboardArrowUp;

export var estructura:Estructura;

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";
const FLECHAVOLVER="←";
const PRIMARY_COLOR   ="#3f51b5";
const SECONDARY_COLOR ="#f50057";

type OnUpdate<T> = (data:T)=>void

type InputTypes = 'date'|'number'|'tel'|'text';

function adaptAtributoDataTypes(attrDataType:AtributoDataTypes):InputTypes{
    const adapter:{[key in AtributoDataTypes]:InputTypes} = {
        'N': 'number',
        'C': 'text'
    }
    return adapter[attrDataType]
}

const useStylesScrollTop = makeStyles((theme: Theme) =>
    createStyles({
        root: {
            position: 'fixed',
            bottom: theme.spacing(2),
            right: theme.spacing(2),
        },
    }),
);

const handleScroll = () => () => {
    window.scroll({behavior:'smooth', top:0, left:0})
};


function ScrollTop(props: any) {
    const { children } = props;
    const classes = useStylesScrollTop();
    // Note that you normally won't need to set the window ref as useScrollTrigger
    // will default to window.
    // This is only being set here because the demo is in an iframe.
    const trigger = useScrollTrigger({
        disableHysteresis: true,
        threshold: 100,
    });
    return (
        <Zoom in={trigger}>
            <div onClick={handleScroll()} role="presentation" className={classes.root}>
                {children}
            </div>
        </Zoom>
    );
}

function focusToId(id:string, cb?:(e:HTMLElement)=>void){
    var element=document.getElementById(id);
    if(element){
        if(cb){
            cb(element);
        }else{
            element.focus();
        }
    }
}

function TypedInput<T>(props:{
    value:T,
    dataType: InputTypes
    onUpdate:OnUpdate<T>, 
    onFocusOut:()=>void, 
    inputId:string
}){
    var inputId=props.inputId;
    var [value, setValue] = useState(props.value);
    useEffect(() => {
        focusToId(inputId);
    }, []);
    // @ts-ignore acá hay un problema con el cambio de tipos
    var valueString:string = value==null?'':value;
    return React.createElement((props.dataType=='text'?'textarea':'input'),{
        id:inputId,
        value:valueString, 
        "td-editable":true,
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
        //onMouseOut:()=>{
        //    // if(document.?activeElement.?id==inputId){
        //    if(document.activeElement && document.activeElement.id==inputId){
        //        props.onFocusOut();
        //    }
        //},
        onKeyDown:event=>{
            var tecla = event.charCode || event.which;
            if((tecla==13 || tecla==9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
                focusToId(inputId, e=>e.blur())
                event.preventDefault();
            }
        }
    })
}

const EditableTd = function<T extends any>(props:{
    inputId:string,
    disabled?:boolean,
    placeholder?: string,
    dataType: InputTypes,
    value:T, 
    className?:string, colSpan?:number, 
    onUpdate:OnUpdate<T>
}){
    const dispatch = useDispatch();
    const deboEditar=useSelector((hdr:HojaDeRuta)=>hdr.idActual == props.inputId);
    const [editando, setEditando]=useState(deboEditar);
    if(editando!=deboEditar){
        setEditando(deboEditar);
    }
    return (
        <td colSpan={props.colSpan} className={props.className} onClick={
            ()=>!props.disabled?dispatch(dispatchers.SET_FOCUS({nextId:props.inputId})):null
        } puede-editar={!props.disabled && !editando?"yes":"no"}>
            {editando?
                <TypedInput inputId={props.inputId} value={props.value} dataType={props.dataType} 
                    onUpdate={value =>{
                        props.onUpdate(value);
                    }} onFocusOut={()=>{
                        // dispatch(dispatchers.UNSET_FOCUS({}))
                    }}
                />
            :<div className={(props.placeholder && !props.value)?"placeholder":"value"}>{props.value?props.value:props.placeholder||''}</div>
            }
        </td>
    )
};

const AtributosRow = function(props:{ 
    relAtr: RelAtr, 
    relPre: RelPre,
    iRelPre: number,
    inputId: string, 
    inputIdPrecio: string, 
    nextId: string|false, 
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
}){
    const relAtr = props.relAtr;
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const atributo = estructura.atributos[relAtr.atributo];
    return (
        <tr>
            <td className="nombre-atributo">{atributo.nombreatributo}</td>
            <td colSpan={2} className="atributo-anterior" >{relAtr.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" button-container="yes">
                    {puedeCopiarAtributos(estructura, relPre)?<Button color="primary" variant="outlined" onClick={ () => {
                        dispatch(dispatchers.COPIAR_ATRIBUTOS({
                            forPk:relAtr, 
                            iRelPre:props.iRelPre,
                            nextId:relPre.precio?false:props.inputIdPrecio
                        }))
                    }}>{FLECHAATRIBUTOS}</Button>:relPre.cambio}
                </td>
                :null}
            <EditableTd colSpan={2} className="atributo-actual" inputId={props.inputId}
                disabled={!puedeCambiarPrecioYAtributos(estructura, relPre)} 
                dataType={adaptAtributoDataTypes(atributo.tipodato)} 
                value={relAtr.valor} 
                onUpdate={value=>{
                    dispatch(dispatchers.SET_ATRIBUTO({
                        forPk:relAtr, 
                        iRelPre:props.iRelPre,
                        valor:value,
                        nextId:props.nextId
                    }))
                }} 
            />
        </tr>
    )
};

const useStylesList = makeStyles((theme: Theme) =>
    createStyles({
        listItemText:{
            fontSize:'1.2rem',
        }
    }),
);

var PreciosRow = React.memo(function PreciosRow(props:{relPre:RelPre, iRelPre:number}){
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const inputIdPrecio = props.relPre.producto+'-'+props.relPre.observacion;
    const inputIdAtributos = relPre.atributos.map((relAtr)=>relAtr.producto+'-'+relAtr.observacion+'-'+relAtr.atributo);
    const productoDef:Producto = estructura.productos[relPre.producto];
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [dialogoObservaciones, setDialogoObservaciones] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    var esNegativo = relPre.tipoprecio && !estructura.tipoPrecio[relPre.tipoprecio].espositivo;
    const classes = useStylesList();
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
                <td className="observaciones" button-container="yes">
                    <Button color="primary" variant="outlined" onClick={()=>{
                        setDialogoObservaciones(true)
                    }}>
                        obs
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
                <td className="flechaTP" button-container="yes">{(puedeCopiarTipoPrecio(estructura, relPre))?
                    <Button color="secondary" variant="outlined" onClick={ () => {
                        if(tpNecesitaConfirmacion(estructura, relPre,relPre.tipoprecioanterior!)){
                            setTipoDePrecioNegativoAConfirmar(relPre.tipoprecioanterior);
                            setMenuConfirmarBorradoPrecio(true)
                        }else{
                            dispatch(dispatchers.COPIAR_TP({forPk:relPre, iRelPre:props.iRelPre, nextId:false}));
                        }
                    }}>
                        {FLECHATIPOPRECIO}
                    </Button>
                :''}</td>
                <td className="tipoPrecio" button-container="yes">
                    <Button color={esNegativo?"secondary":"primary"} variant="outlined" onClick={event=>setMenuTipoPrecio(event.currentTarget)}>
                        {relPre.tipoprecio||"\u00a0"}
                    </Button>
                </td>
                <Menu id="simple-menu"
                    open={Boolean(menuTipoPrecio)}
                    anchorEl={menuTipoPrecio}
                    onClose={()=>setMenuTipoPrecio(null)}
                >
                    {estructura.tiposPrecioDef.map(tpDef=>{
                        var color=estructura.tipoPrecio[tpDef.tipoprecio].espositivo?PRIMARY_COLOR:SECONDARY_COLOR;
                        return (
                        <MenuItem key={tpDef.tipoprecio} onClick={()=>{
                            setMenuTipoPrecio(null);
                            if(tpNecesitaConfirmacion(estructura, relPre,tpDef.tipoprecio)){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                dispatch(dispatchers.SET_TP({
                                    forPk:relPre, 
                                    iRelPre:props.iRelPre,
                                    tipoprecio:tpDef.tipoprecio, 
                                    nextId:!relPre.precio && estructura.tipoPrecio[tpDef.tipoprecio].espositivo?inputIdPrecio:false
                                }))
                            }
                        }}>
                                <ListItemText classes={{primary: classes.listItemText}} style={{color:color, maxWidth:'30px'}}>{tpDef.tipoprecio}&nbsp;</ListItemText>
                                <ListItemText classes={{primary: classes.listItemText}} style={{color:color}}>&nbsp;{tpDef.nombretipoprecio}</ListItemText>
                        </MenuItem>
                        )
                    })}
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
                            dispatch(dispatchers.SET_TP({
                                forPk:relPre, 
                                iRelPre: props.iRelPre,
                                nextId: false, 
                                tipoprecio:tipoDePrecioNegativoAConfirmar
                            }))
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd inputId={inputIdPrecio} disabled={!puedeCambiarPrecioYAtributos(estructura, relPre)} placeholder={puedeCambiarPrecioYAtributos(estructura, relPre)?'$':undefined} className="precio" value={relPre.precio} onUpdate={value=>{
                    dispatch(dispatchers.SET_PRECIO({
                        forPk:relPre, 
                        iRelPre: props.iRelPre,
                        precio:value,
                        nextId:value && inputIdAtributos.length?inputIdAtributos[0]:false
                    }));
                    // focusToId(inputIdPrecio,e=>e.blur());
                }} dataType="number" />
            </tr>
            {relPre.atributos.map((relAtr, index)=>
                <AtributosRow key={relPre.producto+'/'+relPre.observacion+'/'+relAtr.atributo}
                    relPre={relPre}
                    iRelPre={props.iRelPre}
                    relAtr={relAtr}
                    inputId={inputIdAtributos[index]}
                    inputIdPrecio={inputIdPrecio}
                    nextId={index<relPre.atributos.length-1?inputIdAtributos[index+1]:inputIdPrecio}
                    primerAtributo={index==0}
                    cantidadAtributos={relPre.atributos.length}
                    ultimoAtributo={index == relPre.atributos.length-1}
                />
            )}
            </table>
        </>
    );
})

function RelevamientoPrecios(props:{relVis:RelVis}){
    const relVis = props.relVis;
    const observaciones = relVis.observaciones;
    return (
        <>
            {observaciones.map((relPre:RelPre, iRelPre:number) => 
                <PreciosRow 
                    key={relPre.producto+'/'+relPre.observacion}
                    relPre={relPre}
                    iRelPre={iRelPre}
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
    const classes = useStylesList();
    return (
        <table className="razon-formulario">
            <thead></thead>
            <tbody>
                <tr>
                    <td>
                        <Button onClick={event=>setMenuRazon(event.currentTarget)} 
                        color={relVis.razon && !estructura.razones[relVis.razon].espositivoformulario?"secondary":"primary"} variant="outlined">
                            {relVis.razon}
                        </Button>
                    </td>
                    <td style={{color: relVis.razon && !estructura.razones[relVis.razon].espositivoformulario?SECONDARY_COLOR:PRIMARY_COLOR}}>{relVis.razon?razones[relVis.razon].nombrerazon:null}</td>
                    <EditableTd placeholder='agregar comentarios' disabled={false} colSpan={1} className="comentarios-razon" dataType={"text"} value={relVis.comentarios} inputId={relVis.informante+'f'+relVis.formulario}
                        onUpdate={value=>{
                            dispatch(dispatchers.SET_COMENTARIO_RAZON({forPk:relVis, comentarios:value, nextId:false}));
                        }}
                    />
                    <Menu id="simple-menu-razon" open={Boolean(menuRazon)} anchorEl={menuRazon} onClose={()=>setMenuRazon(null)}>
                    {likeAr(estructura.razones).map((razon:Razon,index)=>{
                        var color=estructura.razones[index].espositivoformulario?PRIMARY_COLOR:SECONDARY_COLOR;
                        return(
                        <MenuItem key={razon.nombrerazon} onClick={()=>{
                            if(razonNecesitaConfirmacion(estructura, relVis,index)){
                                setRazonAConfirmar({razon:index});
                                setMenuConfirmarRazon(true)
                            }else{
                                dispatch(dispatchers.SET_RAZON({forPk:relVis, razon:index, nextId:false}));
                            }
                            setMenuRazon(null)
                        }}>
                                <ListItemText classes={{primary: classes.listItemText}} style={{color:color, maxWidth:'30px'}}>&nbsp;{index}</ListItemText>
                                <ListItemText classes={{primary: classes.listItemText}} style={{color:color}}>&nbsp;{razon.nombrerazon}</ListItemText>
                        </MenuItem>
                        )}
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
                            dispatch(dispatchers.SET_RAZON({forPk:relVis, razon:razonAConfirmar.razon, nextId:false}));
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

const drawerWidth = 300;

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      display: 'flex',
    },
    appBar: {
      zIndex: theme.zIndex.drawer + 1,
      transition: theme.transitions.create(['width', 'margin'], {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.leavingScreen,
      }),
    },
    appBarShift: {
      marginLeft: drawerWidth,
      width: `calc(100% - ${drawerWidth}px)`,
      transition: theme.transitions.create(['width', 'margin'], {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.enteringScreen,
      }),
    },
    menuButton: {
      marginRight: 36,
    },
    hide: {
      display: 'none',
    },
    drawer: {
      width: drawerWidth,
      flexShrink: 0,
      whiteSpace: 'nowrap',
    },
    drawerOpen: {
      width: drawerWidth,
      transition: theme.transitions.create('width', {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.enteringScreen,
      }),
    },
    drawerClose: {
      transition: theme.transitions.create('width', {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.leavingScreen,
      }),
      overflowX: 'hidden',
      width: theme.spacing(7) + 1,
      [theme.breakpoints.up('sm')]: {
        width: theme.spacing(9) + 1,
      },
    },
    toolbar: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'flex-end',
      padding: theme.spacing(0, 1),
      ...theme.mixins.toolbar,
    },
    content: {
      flexGrow: 1,
    },
    search: {
      position: 'relative',
      borderRadius: theme.shape.borderRadius,
      backgroundColor: fade(theme.palette.common.white, 0.15),
      '&:hover': {
        backgroundColor: fade(theme.palette.common.white, 0.25),
      },
      marginLeft: 0,
      width: '100%',
      [theme.breakpoints.up('sm')]: {
        marginLeft: theme.spacing(1),
        width: 'auto',
      },
    },
    searchIcon: {
      width: theme.spacing(7),
      height: '100%',
      position: 'absolute',
      pointerEvents: 'none',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    },
    inputRoot: {
      color: 'inherit',
    },
    inputInput: {
      padding: theme.spacing(1, 1, 1, 7),
      transition: theme.transitions.create('width'),
      width: '100%',
      [theme.breakpoints.up('sm')]: {
        width: 120,
        '&:focus': {
          width: 200,
        },
      },
    }
  }),
);

export default function MiniDrawer() {
  
}
function FormularioVisita(props:{relVisPk: RelVisPk, onReturn:()=>void, onSelectVisita:(relVis:RelVis)=>void}){
    const relVis = useSelector((hdr:HojaDeRuta)=>
        hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!
            .formularios.find(relVis=>relVis.formulario==props.relVisPk.formulario)!
    );
    const formularios = useSelector((hdr:HojaDeRuta)=>
        hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!
            .formularios
    );
    const classes = useStyles();
    const theme = useTheme();
    const [open, setOpen] = React.useState(false);
    const [botonActual, setBotonActual] = React.useState<'todos'|'pendientes'|'compactar'|'advertencias'>('todos');

    const handleDrawerOpen = () => {
        setOpen(true);
    };

    const handleDrawerClose = () => {
        setOpen(false);
    };

  return (
    <div id="formulario-visita" className="menu-informante-visita">
        <div className={classes.root}>
            <CssBaseline />
            <AppBar
                position="fixed"
                className={clsx(classes.appBar, {
                [classes.appBarShift]: open,
                })}
            >
                <Toolbar>
                    <IconButton
                        color="inherit"
                        aria-label="open drawer"
                        onClick={handleDrawerOpen}
                        edge="start"
                        className={clsx(classes.menuButton, {
                        [classes.hide]: open,
                        })}
                    >
                        <MenuIcon />
                    </IconButton>
                    <Typography variant="subtitle1" noWrap>
                        {`inf ${props.relVisPk.informante}`}
                    </Typography>
                    <Grid item>
                        <ButtonGroup
                            variant="contained"
                            color="default"
                            size="small"
                            aria-label="large contained default button group"
                        >
                            <Button onClick={()=>{
                                setBotonActual('compactar')
                            }}disabled={botonActual=='compactar'}>
                                compactar
                            </Button>
                            <Button onClick={()=>{
                                setBotonActual('todos')
                            }}disabled={botonActual=='todos'}>
                                todos
                            </Button>
                            <Button onClick={()=>{
                                setBotonActual('pendientes')
                            }}disabled={botonActual=='pendientes'}>
                                pendientes
                            </Button>
                            <Button onClick={()=>{
                                setBotonActual('advertencias')
                            }}disabled={botonActual=='advertencias'}>
                                advertencias
                            </Button>
                        </ButtonGroup>
                    </Grid>
                    <div className={classes.search}>
                        <div className={classes.searchIcon}>
                            <SearchIcon />
                        </div>
                        <InputBase placeholder="Buscar..." classes={{
                                root: classes.inputRoot,
                                input: classes.inputInput,
                            }} inputProps={{ 'aria-label': 'search' }}
                        />
                    </div>
                </Toolbar>
            </AppBar>
            <Drawer
                variant="permanent"
                className={clsx(classes.drawer, {
                    [classes.drawerOpen]: open,
                    [classes.drawerClose]: !open,
                })}
                classes={{
                    paper: clsx({
                        [classes.drawerOpen]: open,
                        [classes.drawerClose]: !open,
                    }),
                }}
                open={open}
            >
                <div className={classes.toolbar}>
                    <IconButton onClick={handleDrawerClose}><ChevronLeftIcon /></IconButton>
                </div>
                <Divider />
                <List>
                    <ListItem button className="flecha-volver-hdr" onClick={props.onReturn}>
                        <ListItemIcon><DescriptionIcon/></ListItemIcon>
                        <ListItemText primary="Volver a hoja de ruta" />
                    </ListItem>
                </List>
                <Divider />
                <List>
                    {formularios.map((relVis:RelVis) => (
                        <ListItem button key={relVis.formulario} selected={relVis.formulario==props.relVisPk.formulario} onClick={()=>{
                            props.onSelectVisita(relVis)
                        }}>
                          <ListItemIcon>{relVis.formulario}</ListItemIcon>
                          <ListItemText primary={estructura.formularios[relVis.formulario].nombreformulario} />
                        </ListItem>
                    ))}
                </List>
            </Drawer>
            <main className={classes.content}>
                <RazonFormulario relVis={relVis}/>
                <div className="informante-visita">
                    <RelevamientoPrecios relVis={relVis}/>
                </div>
            </main>
            <ScrollTop>
                <Fab color="secondary" size="small" aria-label="scroll back to top">
                    <KeyboardArrowUpIcon />
                </Fab>
            </ScrollTop>
        </div>
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
        <>
            <AppBar position="fixed">
                <Toolbar>
                    <Typography variant="h6">
                        Hoja de ruta
                    </Typography>
                </Toolbar>
            </AppBar>
            <main>
                <table className="hoja-ruta">
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
            </main>
        </>
    );
}

function AppDmIPC(){
    const [relVisPk, setRelVisPk] = useState<RelVisPk>();
    if(relVisPk == undefined){
        return <HojaDeRuta onSelectVisita={setRelVisPk}/>
    }else{
        return <FormularioVisita relVisPk={relVisPk} onReturn={()=>setRelVisPk(undefined)} onSelectVisita={setRelVisPk}/>
    }
}

export function mostrarHdr(store:Store<HojaDeRuta, ActionHdr>, miEstructura:Estructura){
    estructura=miEstructura;
    document.documentElement.setAttribute('pos-productos','izquierda');
    ReactDOM.render(
        <Provider store={store}>
            <AppDmIPC/>
        </Provider>,
        document.getElementById('main_layout')
    )
}

// @ts-ignore addrParams tiene un tipo que acá no importa
export async function dmHojaDeRuta(_addrParams){
    const {store, estructura} = await dmTraerDatosHdr();
    mostrarHdr(store, estructura);
}

if(typeof window !== 'undefined'){
    // @ts-ignore para hacerlo
    window.dmHojaDeRuta = dmHojaDeRuta;
}