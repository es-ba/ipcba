import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, RelAtr, AtributoDataTypes, HojaDeRuta, Razon, Estructura, RelInf, RelVis, RelVisPk, LetraTipoOpciones, QueVer} from "./dm-tipos";
import {
    puedeCopiarTipoPrecio, puedeCopiarAtributos, muestraFlechaCopiarAtributos, 
    puedeCambiarPrecioYAtributos, tpNecesitaConfirmacion, razonNecesitaConfirmacion, 
    controlarPrecio, controlarAtributo, precioTieneAdvertencia, precioEstaPendiente
} from "./dm-funciones";
import {ActionHdr, dispatchers, dmTraerDatosHdr } from "./dm-react";
import {useState, useEffect, useRef} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import * as likeAr from "like-ar";
import * as clsx from 'clsx';
import {
    AppBar, Badge, Button, ButtonGroup, Chip, CssBaseline, Dialog, DialogActions, DialogContent, DialogContentText, 
    DialogTitle, Divider, Fab,  FormControl, FormControlLabel, FormGroup, Grid, IconButton, InputBase, List, ListItem, ListItemIcon, ListItemText, Drawer, 
    Menu, MenuItem, Paper, useScrollTrigger, SvgIcon, Switch, Table, TableBody, TableCell, TableHead, TableRow, TextField, Toolbar, Typography, Zoom
} from "@material-ui/core";
import { createStyles, makeStyles, Theme, fade} from '@material-ui/core/styles';
import { Store } from "redux";
import { changing } from "best-globals";

// https://material-ui.com/components/material-icons/
export const materialIoIconsSvgPath={
    Assignment: "M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z",
    CheckBoxOutlineBlankOutlined: "M19 5v14H5V5h14m0-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z",
    CheckBoxOutlined: "M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zM17.99 9l-1.41-1.42-6.59 6.59-2.58-2.57-1.42 1.41 4 3.99z",
    ChevronLeft: "M14.71 6.71a.9959.9959 0 00-1.41 0L8.71 11.3c-.39.39-.39 1.02 0 1.41l4.59 4.59c.39.39 1.02.39 1.41 0 .39-.39.39-1.02 0-1.41L10.83 12l3.88-3.88c.39-.39.38-1.03 0-1.41z",
    ChevronRight: "M9.29 6.71c-.39.39-.39 1.02 0 1.41L13.17 12l-3.88 3.88c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l4.59-4.59c.39-.39.39-1.02 0-1.41L10.7 6.7c-.38-.38-1.02-.38-1.41.01z",
    Clear: "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    Close: "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    Code: "M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z",
    Description: "M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z",
    EmojiObjects: "M12 3c-.46 0-.93.04-1.4.14-2.76.53-4.96 2.76-5.48 5.52-.48 2.61.48 5.01 2.22 6.56.43.38.66.91.66 1.47V19c0 1.1.9 2 2 2h.28c.35.6.98 1 1.72 1s1.38-.4 1.72-1H14c1.1 0 2-.9 2-2v-2.31c0-.55.22-1.09.64-1.46C18.09 13.95 19 12.08 19 10c0-3.87-3.13-7-7-7zm2 16h-4v-1h4v1zm0-2h-4v-1h4v1zm-1.5-5.59V14h-1v-2.59L9.67 9.59l.71-.71L12 10.5l1.62-1.62.71.71-1.83 1.82z",
    ExpandLess: "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z",
    ExpandMore: "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z",
    FormatLineSpacing: "M6 7h2.5L5 3.5 1.5 7H4v10H1.5L5 20.5 8.5 17H6V7zm4-2v2h12V5H10zm0 14h12v-2H10v2zm0-6h12v-2H10v2z",
    Info: "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z",
    KeyboardArrowUp: "M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z",
    Label: "M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z",
    LocalAtm: "M11 17h2v-1h1c.55 0 1-.45 1-1v-3c0-.55-.45-1-1-1h-3v-1h4V8h-2V7h-2v1h-1c-.55 0-1 .45-1 1v3c0 .55.45 1 1 1h3v1H9v2h2v1zm9-13H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4V6h16v12z",
    Menu: "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z",
    Search: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    Settings: "M15.95 10.78c.03-.25.05-.51.05-.78s-.02-.53-.06-.78l1.69-1.32c.15-.12.19-.34.1-.51l-1.6-2.77c-.1-.18-.31-.24-.49-.18l-1.99.8c-.42-.32-.86-.58-1.35-.78L12 2.34c-.03-.2-.2-.34-.4-.34H8.4c-.2 0-.36.14-.39.34l-.3 2.12c-.49.2-.94.47-1.35.78l-1.99-.8c-.18-.07-.39 0-.49.18l-1.6 2.77c-.1.18-.06.39.1.51l1.69 1.32c-.04.25-.07.52-.07.78s.02.53.06.78L2.37 12.1c-.15.12-.19.34-.1.51l1.6 2.77c.1.18.31.24.49.18l1.99-.8c.42.32.86.58 1.35.78l.3 2.12c.04.2.2.34.4.34h3.2c.2 0 .37-.14.39-.34l.3-2.12c.49-.2.94-.47 1.35-.78l1.99.8c.18.07.39 0 .49-.18l1.6-2.77c.1-.18.06-.39-.1-.51l-1.67-1.32zM10 13c-1.65 0-3-1.35-3-3s1.35-3 3-3 3 1.35 3 3-1.35 3-3 3z",
    Warning: "M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z",
    /// JULI ICONS:
    Pendientes:"M2.4 15.35 H 104.55 V 35.65 H -104.55 M 2.4 59.35 H 104.55 V 35.65 Z M 2.4 103.35 H 104.55 V 35.65 Z  M145.6,109.35V133H121.95V109.35H145.6m6-6H115.95V139H151.6V103.35h0Z M145.6,65.35V89H121.95V65.35H145.6m6-6H115.95V95H151.6V59.35h0Z M145.6,21.35V45H121.95V21.35H145.6m6-6H115.95V51H151.6V15.35h0Z",
    Repregunta:"M19.9,13.3c0,4.4-3.6,7.9-7.9,7.9s-7.9-3.6-7.9-7.9S7.6,5.4,12,5.4V8l5.3-4l-5.3-4v2.6C6.1,2.7,1.4,7.5,1.4,13.3 S6.1,23.9,12,23.9s10.6-4.7,10.6-10.6H19.9z M8.9,17.8v-7.6h3.2c0.8,0,1.4,0.1,1.8,0.2c0.4,0.1,0.7,0.4,0.9,0.7 c0.2,0.4,0.3,0.7,0.3,1.2c0,0.6-0.2,1-0.5,1.4c-0.3,0.4-0.8,0.6-1.5,0.7c0.3,0.2,0.6,0.4,0.8,0.6c0.2,0.2,0.5,0.6,0.9,1.2l0.9,1.5 h-1.8l-1.1-1.7c-0.4-0.6-0.7-1-0.8-1.1c-0.1-0.2-0.3-0.3-0.5-0.3c-0.2-0.1-0.4-0.1-0.8-0.1h-0.3v3.2H8.9z M10.4,13.4h1.1 c0.7,0,1.2,0,1.4-0.1c0.2-0.1,0.3-0.2,0.4-0.3c0.1-0.2,0.2-0.3,0.2-0.6c0-0.3-0.1-0.5-0.2-0.6c-0.1-0.2-0.3-0.3-0.6-0.3 c-0.1,0-0.5,0-1.1,0h-1.2V13.4z",
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
const ClearIcon = ICON.Clear;
const SettingsIcon = ICON.Settings;
const RepreguntaIcon = ICON.Repregunta;

export var estructura:Estructura;

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";
const PRIMARY_COLOR   ="#3f51b5";
const SECONDARY_COLOR ="#f50057";
const COLOR_ADVERTENCIAS = "rgb(255, 147, 51)";
var CHECK = '✓';

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
    altoActual:number,
    onFocusOut:()=>void, 
    inputId:string,
    tipoOpciones?:LetraTipoOpciones|null,
    opciones?:string[]|null
    backgroundColor?:string,
    onFocus?:()=>void
}){
    var inputId=props.inputId;
    var [value, setValue] = useState(props.value);
    useEffect(() => {
        focusToId(inputId);
        props.onFocus?props.onFocus():null;
    }, []);
    // @ts-ignore acá hay un problema con el cambio de tipos
    var valueString:string = value==null?'':value;
    var style:any=props.altoActual?{height:props.altoActual+'px'}:{};
    style.backgroundColor=props.backgroundColor?props.backgroundColor:'none';
    if(props.dataType=='text'){
        var input = <TextField
            multiline
            rowsMax="4"
            // className={classes.textField}
            // margin="normal"
            id={inputId}
            value={valueString}
            type={props.dataType} 
            style={style}
            onChange={(event)=>{
                // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                setValue(event.target.value);
            }}
            onBlur={(event)=>{
                if(value!==props.value){
                    // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                    props.onUpdate(event.target.value);
                }
                props.onFocusOut();
            }}
            onKeyDown={event=>{
                var tecla = event.charCode || event.which;
                if((tecla==13 || tecla==9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
                    focusToId(inputId, e=>e.blur())
                    props.onFocus?props.onFocus():null;
                    event.preventDefault();
                }
            }}
        />
        return input;
    }else{
        return <input
            id={inputId}
            value={valueString}
            type={props.dataType} 
            style={style}
            onChange={(event)=>{
                // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                setValue(event.target.value);
            }}
            onBlur={(event)=>{
                if(value!==props.value){
                    // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
                    props.onUpdate(event.target.value);
                }
                props.onFocusOut();
            }}
            onKeyDown={event=>{
                var tecla = event.charCode || event.which;
                if((tecla==13 || tecla==9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
                    focusToId(inputId, e=>e.blur())
                    props.onFocus?props.onFocus():null;
                    event.preventDefault();
                }
            }}
        />
    }
}

function DialogoSimple(props:{titulo?:string, valor:string, dataType:InputTypes, inputId:string, onCancel:()=>void, onUpdate:(valor:string)=>void}){
    const [valor, setValor] = useState(props.valor);
    return <Dialog
        open={true}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
    >
        <DialogTitle id="alert-dialog-title-obs">{props.titulo || ''}</DialogTitle>
        <DialogContent>
            <TextField
                autoFocus
                value={valor}
                type={props.dataType}
                onChange={(event)=>{
                    setValor(event.target.value);
                }}
                // onKey = 13 ...
            />
        </DialogContent>
        <DialogActions>
            <Button onClick={()=>{
                props.onCancel()
            }} color="secondary" variant="text">
                cancelar
            </Button>
            <Button onClick={()=>{
                props.onUpdate(valor)
            }} color="primary" variant="contained">
                Ok
            </Button>
        </DialogActions>
    </Dialog>
}

const EditableTd = function<T extends any>(props:{
    backgroundColor?:string,
    badgeCondition?:boolean,
    badgeBackgroundColor?:any,
    borderBottomColor?:string,
    inputId:string,
    disabled?:boolean,
    placeholder?: string,
    dataType: InputTypes,
    value:T, 
    className?:string, colSpan?:number, 
    onUpdate:OnUpdate<T>,
    tipoOpciones?:LetraTipoOpciones|null,
    opciones?:string[]|null,
    titulo?:string,
    onFocus?:()=>void
}){
    const dispatch = useDispatch();
    const deboEditar=useSelector((hdr:HojaDeRuta)=>hdr.opciones.idActual == props.inputId);
    const [editando, setEditando]=useState(deboEditar);
    const [editandoOtro, setEditandoOtro]=useState(false);
    const [anchoSinEditar, setAnchoSinEditar] = useState(0);
    // const [mostrarMenu, setMostrarMenu] = useState<HTMLElement|null>(null);
    const mostrarMenu = useRef<HTMLTableDataCellElement>(null);
    const editaEnLista = props.tipoOpciones=='C' || props.tipoOpciones=='A';
    const badgeCondition = props.badgeCondition || false;
    const sanitizarValor = function(valor:T){
        if(valor==undefined || valor == null || valor.trim()==''){
            return null
        }else{
            return props.dataType == 'number'?Number(valor):valor.trim()
        }

    }
    if(editando!=deboEditar){
        setEditando(deboEditar);
    }
    const classesBadge = useStylesBadge({backgroundColor: props.badgeBackgroundColor});
    var stringValue = props.value == null ? props.value : props.value.toString();
    return <>
        <td style={{
            backgroundColor:props.backgroundColor?props.backgroundColor:'none', 
            borderBottomColor:props.borderBottomColor?props.borderBottomColor:"#3f51b5",
            overflowX: badgeCondition?'unset':'hidden'
        }} 
            colSpan={props.colSpan} 
            className={props.className} 
            ref={mostrarMenu} 
            onClick={(event)=>{
                if(!props.disabled){
                    // @ts-ignore offsetHeight debería existir porque event.target es un TD
                    var altoActual:number = event.target.offsetHeight!;
                    setAnchoSinEditar(altoActual);
                    dispatch(dispatchers.SET_FOCUS({nextId:props.inputId}));
                    props.onFocus?props.onFocus():null;
                }
            }} 
            puede-editar={!props.disabled && !editando?"yes":"no"}
        >
            <ConditionalWrapper
                condition={badgeCondition}
                wrapper={children => 
                    <Badge badgeContent="!" anchorOrigin={{vertical: 'bottom',horizontal: 'right'}} 
                    style={{width:"100%"}} classes={{ badge: classesBadge.badge }} className={classesBadge.margin}>{children}
                    </Badge>
                }
            >
            {editando && !editaEnLista?
                <TypedInput inputId={props.inputId} value={props.value} dataType={props.dataType} 
                    altoActual={anchoSinEditar}
                    onUpdate={value =>{
                        props.onUpdate(sanitizarValor(value));
                    }} onFocusOut={()=>{
                        if(deboEditar && editando){
                            dispatch(dispatchers.UNSET_FOCUS({unfocusing: props.inputId}))
                        }
                    }}
                    tipoOpciones={props.tipoOpciones}
                    opciones={props.opciones}
                    backgroundColor={props.backgroundColor}
                    onFocus={()=>{props.onFocus?props.onFocus():null}}
                />
            :<div className={(props.placeholder && props.value==null)?"placeholder":"value"}>{props.value != null?props.value:props.placeholder||''}</div>
            }
            </ConditionalWrapper>
        </td>
        {editaEnLista && editando?
            <Menu id="simple-menu"
                open={editando && mostrarMenu.current !== undefined}
                transformOrigin={{ vertical: "top", horizontal: "center" }}
                anchorEl={mostrarMenu.current}
                onClose={()=> dispatch(dispatchers.UNSET_FOCUS({unfocusing: props.inputId}))}
            >
                <MenuItem key='***** title' disabled={true} style={{color:'black', fontSize:'50%', fontWeight:'bold'}}>
                    <ListItemText style={{color:'black', fontSize:'50%', fontWeight:'bold'}}>{props.titulo}</ListItemText>
                </MenuItem>
                {props.value && (props.opciones||[]).indexOf(stringValue)==-1?
                    <MenuItem key='*****current value******' value={stringValue}
                        onClick={()=>{
                            props.onUpdate(props.value);
                        }}
                    >
                        <ListItemText style={{color:'blue'}}>{props.value}</ListItemText>
                    </MenuItem>
                :null}
                <Divider />
                {(props.opciones||[]).map(label=>(
                    <MenuItem key={label} value={label}
                        onClick={()=>{
                            props.onUpdate(label);
                        }}
                    >
                        <ListItemText style={label == stringValue?{color:'blue'}:{}}>{label}</ListItemText>                    
                    </MenuItem>
                ))}
                {props.tipoOpciones=='A'?<Divider />:null}
                {props.tipoOpciones=='A'?
                    <MenuItem key='*****other value******' 
                        onClick={()=>{
                            setEditandoOtro(true)
                        }}
                    >
                        <ListItemText style={{textDecoration:'italic'}}>OTRO</ListItemText>
                    </MenuItem>
                :null}
            </Menu>
            :null
        }
        {editandoOtro?
            <DialogoSimple 
                titulo={props.titulo} 
                valor={props.value} 
                dataType={props.dataType} 
                inputId={props.inputId+'_otro_attr'}
                onCancel={()=>setEditandoOtro(false)}
                onUpdate={(value)=>{
                    setEditandoOtro(false);
                    props.onUpdate(value);
                }}
            />
        :null}
    </>
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
    onSelection:()=>void
}){
    const relAtr = props.relAtr;
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const atributo = estructura.atributos[relAtr.atributo];
    const prodatr = estructura.productos[relAtr.producto].atributos[relAtr.atributo];
    const [menuCambioAtributos, setMenuCambioAtributos] = useState<HTMLElement|null>(null);
    const classes = useStylesList();
    const {color, tieneAdv} = controlarAtributo(relAtr, relPre, estructura);
    return (
        <tr>
            <td className="nombre-atributo">{atributo.nombreatributo}</td>
            <td colSpan={2} className="atributo-anterior" >{relAtr.valoranterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" button-container="yes">
                    {muestraFlechaCopiarAtributos(estructura, relPre)?
                        <Button color="primary" variant="outlined" onClick={ () => {
                            props.onSelection();
                            dispatch(dispatchers.COPIAR_ATRIBUTOS({
                                forPk:relAtr, 
                                iRelPre:props.iRelPre,
                                nextId:relPre.precio?false:props.inputIdPrecio
                            }))
                        }}>
                            {FLECHAATRIBUTOS}
                        </Button>
                    :(relPre.cambio=='C' && puedeCopiarAtributos(estructura, relPre))?
                        <Button color="primary" variant="outlined" onClick={ (event) => {
                            props.onSelection();
                            setMenuCambioAtributos(event.currentTarget)                            
                        }}>
                            C
                        </Button>
                    :relPre.cambio}
                </td>
            :null}
            <EditableTd
                borderBottomColor={color}
                badgeCondition={tieneAdv}
                badgeBackgroundColor={color}
                colSpan={2} className="atributo-actual" inputId={props.inputId}
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
                tipoOpciones={prodatr.opciones}
                opciones={prodatr.lista_prodatrval}
                titulo={atributo.nombreatributo}
                onFocus={()=>{
                    props.onSelection();
                }}
            />
            
            <Menu id="simple-menu-cambio"
                open={Boolean(menuCambioAtributos)}
                anchorEl={menuCambioAtributos}
                onClose={()=>setMenuCambioAtributos(null)}
            >
                <MenuItem key={} onClick={()=>{
                    dispatch(dispatchers.COPIAR_ATRIBUTOS_VACIOS({
                        forPk:relAtr, 
                        iRelPre:props.iRelPre,
                        nextId:relPre.precio?false:props.inputIdPrecio
                    }))
                    setMenuCambioAtributos(null)
                }}>
                    <ListItemText style={{color:PRIMARY_COLOR}}  classes={{primary: classes.listItemText}}>
                        Copiar el resto de los atributos vacíos
                    </ListItemText>
                </MenuItem>
                <MenuItem key={} onClick={()=>{
                    dispatch(dispatchers.COPIAR_ATRIBUTOS({
                        forPk:relAtr, 
                        iRelPre:props.iRelPre,
                        nextId:relPre.precio?false:props.inputIdPrecio
                    }))
                    setMenuCambioAtributos(null)
                }}>
                    <ListItemText style={{color:SECONDARY_COLOR}} classes={{primary: classes.listItemText}}>
                        Anular el cambio pisando los valores distintos
                    </ListItemText>
                </MenuItem>
            </Menu>
        </tr>
    )
};

const useStylesList = makeStyles((_theme: Theme) =>
    createStyles({
        listItemText:{
            fontSize:'1.2rem',
        }
    }),
);

var PreciosRow = React.memo(function PreciosRow(props:{
    relPre:RelPre, iRelPre:number
}){
    const {searchString, allForms} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const inputIdPrecio = props.relPre.producto+'-'+props.relPre.observacion;
    const inputIdAtributos = relPre.atributos.map((relAtr)=>relAtr.producto+'-'+relAtr.observacion+'-'+relAtr.atributo);
    const productoDef:Producto = estructura.productos[relPre.producto];
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [dialogoObservaciones, setDialogoObservaciones] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    const [observacionAConfirmar, setObservacionAConfirmar] = useState<string|null>(relPre.comentariosrelpre);
    var esNegativo = relPre.tipoprecio && !estructura.tipoPrecio[relPre.tipoprecio].espositivo;
    const classes = useStylesList();
    const classesBadgeCantidadMeses = useStylesBadge({backgroundColor:'#dddddd', color: "#000000"});
    const classesBadgeProdDestacado = useStylesBadge({backgroundColor:'#b8dbed', color: "#000000"});
    const classesBadgeComentariosAnalista = useStylesBadge({backgroundColor:COLOR_ADVERTENCIAS});
    const {color, tieneAdv} = controlarPrecio(relPre, estructura);
    const chipColor = relPre.sinpreciohace4meses?"#66b58b":(relPre.tipoprecioanterior == "N"?"#76bee4":null);
    const precioAnteriorAMostrar = relPre.precioanterior || relPre.ultimoprecioinformado;
    const badgeCondition = !relPre.precioanterior && relPre.ultimoprecioinformado;
    var handleSelection = function handleSelection(relPre:RelPre, searchString:string, allForms:boolean){
        if(searchString || allForms){
            dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relPre.informante, formulario:relPre.formulario}));
            dispatch(dispatchers.RESET_SEARCH({}))
        }
    }
    return (
        <>
            <div className="caja-producto" id={'caja-producto-'+inputIdPrecio}>
                <div className="producto">{productoDef.nombreproducto}</div>
                <div className="observacion">{relPre.observacion==1?"":relPre.observacion.toString()}</div>
                <ConditionalWrapper
                    condition={(productoDef.destacado)}
                    wrapper={children => 
                        <Badge style={{width:"100%"}} badgeContent=" " 
                            classes={{ badge: classesBadgeProdDestacado.badge }} className={classesBadgeProdDestacado.margin}>{children}
                        </Badge>
                    }
                >
                    <div className="especificacion">{productoDef.especificacioncompleta}</div>
                </ConditionalWrapper>
                <ConditionalWrapper
                    condition={(relPre.comentariosrelpre_1 && relPre.esvisiblecomentarioendm_1)}
                    wrapper={children => 
                        <Badge style={{width:"100%"}} badgeContent=" " classes={{ badge: classesBadgeComentariosAnalista.badge }} 
                            className={classesBadgeComentariosAnalista.margin}>
                            {children}    
                        </Badge>
                    }
                >
                    <div className="comentario-analista">{relPre.comentariosrelpre_1}</div>
                </ConditionalWrapper>
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
                <tbody>
                    <tr>
                        <td className="observaciones" button-container="yes">
                            <Button color="primary" variant="outlined" onClick={()=>{
                                handleSelection(relPre, searchString, allForms);
                                setDialogoObservaciones(true)
                            }}>
                                obs
                            </Button>
                            <Dialog
                                open={dialogoObservaciones}
                                onClose={()=>{
                                    setDialogoObservaciones(false)
                                    setObservacionAConfirmar(relPre.comentariosrelpre);
                                }}
                                aria-labelledby="alert-dialog-title"
                                aria-describedby="alert-dialog-description"
                            >
                                <DialogTitle id="alert-dialog-title-obs">{"Observaciones del precio"}</DialogTitle>
                                <DialogContent>
                                    <DialogContentText id="alert-dialog-description-obs">
                                    <EditableTd inputId={inputIdPrecio+"_comentarios"} placeholder={"agregar observaciones"} className="observaciones" value={observacionAConfirmar} onUpdate={value=>{
                                        setObservacionAConfirmar(value);
                                    }} dataType="text"/>
                                    </DialogContentText>
                                </DialogContent>
                                <DialogActions>
                                    <Button onClick={()=>{
                                        dispatch(dispatchers.SET_COMENTARIO_PRECIO({
                                            forPk:relPre, 
                                            iRelPre: props.iRelPre,
                                            comentario:observacionAConfirmar,
                                            nextId: false
                                        }));
                                        setDialogoObservaciones(false)
                                    }} color="primary" variant="outlined">
                                        Guardar
                                    </Button>
                                    <Button onClick={()=>{
                                        setObservacionAConfirmar(relPre.comentariosrelpre)
                                        setDialogoObservaciones(false)
                                    }} color="secondary" variant="outlined">
                                        Descartar Observaciones
                                    </Button>
                                </DialogActions>
                            </Dialog>
                        </td>
                        <td className="tipoPrecioAnterior">{relPre.tipoprecioanterior}</td>
                        <td className="precioAnterior" precio-anterior style={{width: "100%", overflow: badgeCondition?'unset':'hidden'}}>
                            <ConditionalWrapper
                                condition={(badgeCondition)}
                                wrapper={children => 
                                    <Badge style={{width:"calc(100% - 5px)", display:'unset'}} badgeContent={relPre.cantidadperiodossinprecio} 
                                        classes={{ badge: classesBadgeCantidadMeses.badge }} className={classesBadgeCantidadMeses.margin}>{children}
                                    </Badge>
                                }
                            >
                                {chipColor?
                                    <Chip style={{backgroundColor:chipColor, color:"#ffffff", width:"100%", fontSize: "1rem"}} label={precioAnteriorAMostrar || "-"}></Chip>
                                :
                                    precioAnteriorAMostrar
                                }
                            </ConditionalWrapper>
                        </td>
                        <td className="flechaTP" button-container="yes" es-repregunta={relPre.repregunta?"yes":"no"}>
                            {relPre.repregunta?
                                <RepreguntaIcon/>
                            :((puedeCopiarTipoPrecio(estructura, relPre))?
                                <Button color="secondary" variant="outlined" onClick={ () => {
                                    handleSelection(relPre, searchString, allForms);
                                    if(tpNecesitaConfirmacion(estructura, relPre,relPre.tipoprecioanterior!)){
                                        setTipoDePrecioNegativoAConfirmar(relPre.tipoprecioanterior);
                                        setMenuConfirmarBorradoPrecio(true)
                                    }else{
                                        dispatch(dispatchers.COPIAR_TP({forPk:relPre, iRelPre:props.iRelPre, nextId:false}));
                                    }
                                }}>
                                    {FLECHATIPOPRECIO}
                                </Button>
                                :'')
                            }
                        </td>
                        <td className="tipoPrecio" button-container="yes">
                            <Button color={esNegativo?"secondary":"primary"} variant="outlined" onClick={event=>{
                                handleSelection(relPre, searchString, allForms);
                                setMenuTipoPrecio(event.currentTarget)
                            }}>
                                {relPre.tipoprecio||"\u00a0"}
                            </Button>
                        </td>
                        <Menu id="simple-menu"
                            open={Boolean(menuTipoPrecio)}
                            anchorEl={menuTipoPrecio}
                            onClose={()=>setMenuTipoPrecio(null)}
                        >
                            {estructura.tiposPrecioDef.filter(tpDef=>tpDef.visibleparaencuestador).map(tpDef=>{
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
                        <EditableTd 
                            borderBottomColor={color}
                            badgeCondition={tieneAdv}
                            badgeBackgroundColor={color}
                            inputId={inputIdPrecio} 
                            disabled={!puedeCambiarPrecioYAtributos(estructura, relPre)} placeholder={puedeCambiarPrecioYAtributos(estructura, relPre)?'$':undefined} className="precio" value={relPre.precio} onUpdate={value=>{
                            dispatch(dispatchers.SET_PRECIO({
                                forPk:relPre, 
                                iRelPre: props.iRelPre,
                                precio:value,
                                nextId:value && inputIdAtributos.length?inputIdAtributos[0]:false
                            }));
                            // focusToId(inputIdPrecio,e=>e.blur());
                        }} dataType="number" onFocus={()=>{
                            handleSelection(relPre, searchString, allForms);
                        }}/>
                        
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
                            onSelection={()=>handleSelection(relPre,searchString,allForms)}
                        />
                    )}
                </tbody>
            </table>
        </>
    );
})

function filterNotNull<T extends {}>(x:T|null):x is T {
    return x != null
}

function RelevamientoPrecios(props:{
    relInf:RelInf, 
    relVis: RelVis,
    formulario:number
}){
    const relInf = props.relInf;
    const relVis = props.relVis;
    const {queVer, searchString, allForms} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const dispatch = useDispatch();
    var observaciones = relInf.observaciones;
    var criterio = (relPre:RelPre) => 
        (searchString?estructura.productos[relPre.producto].nombreproducto.toLocaleLowerCase().search(searchString.toLocaleLowerCase())>-1:true)
        && (queVer !='advertencias' || precioTieneAdvertencia(relPre, relVis, estructura))
        && (queVer !='pendientes' || precioEstaPendiente(relPre, relVis, estructura));
    var observacionesFiltradas:{relPre:RelPre, iRelPre:number}[]=observaciones.map((relPre:RelPre, iRelPre:number) =>
        ((allForms?true:relPre.formulario==props.formulario) &&
        criterio(relPre))?{relPre, iRelPre}:null
    ).filter(filterNotNull);
    var observacionesFiltradasEnOtros:{relPre:RelPre, iRelPre:number}[]=observaciones.map((relPre:RelPre, iRelPre:number) =>
        (!(allForms?true:relPre.formulario==props.formulario) && 
        (relPre.observacion==1 || queVer!='todos') && // si son todos no hace falta ver las observaciones=2
        criterio(relPre))?{relPre, iRelPre}:null
    ).filter(filterNotNull);
    var cantidadResultados = observacionesFiltradas.length;
    return <>
        {queVer == 'pendientes'? <Typography className="titulo-pendientes">observaciones pendientes</Typography>:(
            queVer == 'advertencias'? <Typography className="titulo-advertencias">observaciones con advertencias</Typography>:(
                null
            )
        )}
        <div className="informante-visita">
            {cantidadResultados?
                observacionesFiltradas.map(({relPre, iRelPre}) =>
                    <PreciosRow 
                        key={relPre.producto+'/'+relPre.observacion}
                        relPre={relPre}
                        iRelPre={Number(iRelPre)}
                    />
                )
            :(observacionesFiltradasEnOtros.length==0 && queVer != 'todos'?
                <div>No hay</div>
            :null)
            }
            {
                observacionesFiltradasEnOtros.length>0?
                <div className="zona-degrade">
                    <Button className="boton-hay-mas" variant="outlined"
                        onClick={()=>{
                            dispatch(dispatchers.SET_OPCION({variable:'allForms',valor:true}))
                            dispatch(dispatchers.SET_OPCION({variable:'verRazon',valor:false}))
                        }}
                    >ver más {queVer == 'todos'?'':queVer} en otros formularios</Button>
                    {observacionesFiltradasEnOtros.map(({relPre}, i) => (
                        i<10?
                        <Typography 
                            key={relPre.producto+'/'+relPre.observacion}
                        >
                            {estructura.productos[relPre.producto].nombreproducto} {relPre.observacion>1?relPre.observacion.toString():''}
                        </Typography>:null
                    ))}
                </div>:null
            }
        </div>
    </>;
}

function RazonFormulario(props:{relVis:RelVis}){
    const relVis = props.relVis;
    const razones = estructura.razones;
    const {verRazon} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const [menuRazon, setMenuRazon] = useState<HTMLElement|null>(null);
    const [razonAConfirmar, setRazonAConfirmar] = useState<{razon:number|null}>({razon:null});
    const [menuConfirmarRazon, setMenuConfirmarRazon] = useState<boolean>(false);
    const dispatch = useDispatch();
    const classes = useStylesList();
    return (
        verRazon?
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
                    <td>{relVis.razon?razones[relVis.razon].nombrerazon:null}</td>
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
        :null
    );
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
      whiteSpace: (props:{open:boolean}) => props.open?'normal':'nowrap',
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
      width: 150,
    }
  }),
);

function FormularioVisita(props:{relVisPk: RelVisPk}){
    const {queVer, searchString} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const dispatch = useDispatch();
    const {relInf, relVis} = useSelector((hdr:HojaDeRuta)=>{
        var relInf=hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!;
        var relVis=relInf.formularios.find(relVis=>relVis.formulario==props.relVisPk.formulario)!;
        return {relInf, relVis}
    });
    const formularios = useSelector((hdr:HojaDeRuta)=>
        hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!
            .formularios
    );
    const [open, setOpen] = React.useState<boolean>(false);
    const classes = useStyles({open:open});

    const handleDrawerOpen = () => {
        setOpen(true);
    };

    const handleDrawerClose = () => {
        setOpen(false);
    };

    const handleDrawerToggle = () => {
        setOpen(!open);
    };

  return (
    <div id="formulario-visita" className="menu-informante-visita">
        <div className={classes.root}>
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
                            aria-label="large contained default button group"
                            style={{margin:'0 5px'}}
                        >
                            <Button onClick={()=>{
                                // setBotonQueVer('compactar')
                                // TODO: ESTE TIENE QUE SER UN TOGGLE BUTTON que no modifique el botón quever
                            }}>
                                <ICON.FormatLineSpacing />
                            </Button>
                        </ButtonGroup>
                        <ButtonGroup
                            variant="contained"
                            color="default"
                            aria-label="large contained default button group"
                        >
                            <Button onClick={()=>{
                                dispatch(dispatchers.SET_OPCION({variable:'queVer',valor:'todos'}));
                            }}disabled={queVer=='todos'}>
                                <ICON.CheckBoxOutlined />
                            </Button>
                            <Button onClick={()=>{
                                dispatch(dispatchers.SET_OPCION({variable:'queVer',valor:'pendientes'}));
                            }}disabled={queVer=='pendientes'}>
                                <ICON.CheckBoxOutlineBlankOutlined />
                            </Button>
                            <Button onClick={()=>{
                                dispatch(dispatchers.SET_OPCION({variable:'queVer',valor:'advertencias'}));
                            }}disabled={queVer=='advertencias'}>
                                <ICON.Warning />
                            </Button>
                        </ButtonGroup>
                    </Grid>
                    <div className={classes.search}>
                        <div className={classes.searchIcon}>
                            <SearchIcon />
                        </div>
                        <InputBase id="search" placeholder="Buscar..." value={searchString} classes={{
                                root: classes.inputRoot,
                                input: classes.inputInput,
                            }} inputProps={{ 'aria-label': 'search' }}
                            onChange={(event)=>{
                                dispatch(dispatchers.SET_OPCION({variable:'searchString',valor:event.target.value}))
                                //EVALUAR SI SE SACA
                                //window.scroll({behavior:'auto', top:0, left:0})
                            }}
                        />
                        {searchString?
                            <IconButton size="small" style={{color:'#ffffff'}} onClick={()=>dispatch(dispatchers.SET_OPCION({variable:'searchString',valor:''}))}><ClearIcon /></IconButton>
                        :null}
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
                    <IconButton onClick={handleDrawerToggle}><MenuIcon /></IconButton>
                </div>
                <List>
                    <ListItem button className="flecha-volver-hdr" onClick={()=>
                        dispatch(dispatchers.UNSET_FORMULARIO_ACTUAL({}))
                    }>
                        <ListItemIcon><DescriptionIcon/></ListItemIcon>
                        <ListItemText primary="Volver a hoja de ruta" />
                    </ListItem>
                    {formularios.map((relVis:RelVis) => (
                        <ListItem button key={relVis.formulario} selected={relVis.formulario==props.relVisPk.formulario} onClick={()=>{
                            setOpen(false);
                            dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relVis.informante, formulario:relVis.formulario}))
                            dispatch(dispatchers.RESET_SEARCH({}));
                        }}>
                          <ListItemIcon>{relVis.formulario}</ListItemIcon>
                          <ListItemText primary={estructura.formularios[relVis.formulario].nombreformulario} />
                        </ListItem>
                    ))}
                </List>
            </Drawer>
            <main className={classes.content}>
                <RazonFormulario relVis={relVis}/>
                <RelevamientoPrecios 
                    relInf={relInf} 
                    relVis={relVis}
                    formulario={relVis.formulario}
                />
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

const useStylesBadge = makeStyles((theme: Theme) =>
  createStyles({
    margin: {
      margin: theme.spacing(0),
    },
    padding: {
      padding: theme.spacing(0, 2),
    },
    badge: {
      backgroundColor: (props:{backgroundColor:string}) => props.backgroundColor?props.backgroundColor:'unset',
      color: (props:{color:string}) => props.color?props.color:'white',
    }
  }),
);

const ConditionalWrapper = ({ condition, wrapper, children }) => 
  condition ? wrapper(children) : children;

function FormulariosRows(props:{informante:RelInf, relVis:RelVis}){
    const opciones = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const classes = useStylesBadge({backgroundColor: COLOR_ADVERTENCIAS});
    const dispatch = useDispatch();
    const {mostrarColumnasFaltantesYAdvertencias} = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const informante = props.informante;
    const relVis = props.relVis;
    var misObservaciones = informante.observaciones.filter((relPre:RelPre)=>relPre.formulario == relVis.formulario);
    var cantPendientes = misObservaciones.filter((relPre:RelPre)=>precioEstaPendiente(relPre, relVis, estructura)).length;
    var cantAdvertencias = misObservaciones.filter((relPre:RelPre)=>precioTieneAdvertencia(relPre, relVis, estructura)).length;
    var todoListo = cantAdvertencias == 0 && cantPendientes == 0 && !opciones.mostrarColumnasFaltantesYAdvertencias
    var numbersStyles = {
        textAlign: 'right',
        paddingRight: '15px'
    }
    return(
        <>
            <TableCell>
                <ConditionalWrapper
                    condition={!mostrarColumnasFaltantesYAdvertencias}
                    wrapper={children => 
                        <Badge style={{width:"calc(100% - 5px)"}} badgeContent={cantAdvertencias} 
                            classes={{ badge: classes.badge }} className={classes.margin}>{children}
                        </Badge>
                    }
                >
                    <Button style={{width:'100%', backgroundColor: todoListo?"#5CB85C":"none", color: todoListo?"#ffffff":"none"}} size="large" variant="outlined" color="primary" 
                        className={"boton-ir-formulario"}   onClick={()=>{
                            dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relVis.informante, formulario:relVis.formulario}));
                            dispatch(dispatchers.RESET_SEARCH({}));
                        }
                    }>
                        {relVis.formulario} {estructura.formularios[relVis.formulario].nombreformulario} {(todoListo)?CHECK:null}
                    </Button>
                </ConditionalWrapper>
            </TableCell>
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={numbersStyles}>{misObservaciones.length}</TableCell>:null}
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={changing(numbersStyles, {backgroundColor:cantPendientes?'#DDAAAA':'#AADDAA'})}>{cantPendientes?cantPendientes:CHECK}</TableCell>:null}
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={changing(numbersStyles, {backgroundColor:cantAdvertencias?COLOR_ADVERTENCIAS:'none'})}>{cantAdvertencias?cantAdvertencias:'-'}</TableCell>:null}
        </>
    )
}

function InformanteRow(props:{informante:RelInf}){
    const opciones = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const informante = props.informante;
    return (
        <>
            {informante.formularios.map((relVis:RelVis, index:number)=>{
                return (
                    <>
                        <TableRow key={relVis.informante+'/'+relVis.formulario} style={{
                            verticalAlign:'top',
                            borderTop:opciones.letraGrandeFormulario?"2px solid":"none"
                        }}>
                            {index==0?
                                <TableCell 
                                    rowSpan={opciones.letraGrandeFormulario?1:informante.formularios.length}
                                    colSpan={opciones.letraGrandeFormulario?4:1}
                                >
                                    <div>{informante.informante} {informante.nombreinformante} ({informante.cantidad_periodos_sin_informacion})</div>
                                    <div className='direccion-informante'>{estructura.informantes[informante.informante].direccion}</div>
                                </TableCell>
                            :null}
                            {opciones.letraGrandeFormulario?null:
                                <FormulariosRows informante={props.informante} relVis={relVis}/>
                            }
                        </TableRow>
                        {opciones.letraGrandeFormulario?
                            <TableRow>
                                <FormulariosRows informante={props.informante} relVis={relVis}/>
                            </TableRow>
                        :null}
                    </>
                )
            })}
        </>
    )
}

const useStylesTable = makeStyles({
    root: {
      width: '100%',
      overflowX: 'auto',
    },
    table: {
      minWidth: 650,
    },
  });

function PantallaHojaDeRuta(_props:{}){
    const {informantes, panel, tarea, encuestador, nombreencuestador, apellidoencuestador} = useSelector((hdr:HojaDeRuta)=>({
        informantes:hdr.informantes,
        opciones:hdr.opciones,
        panel: hdr.panel,
        tarea: hdr.tarea,
        encuestador: hdr.encuestador,
        nombreencuestador: hdr.nombreencuestador,
        apellidoencuestador: hdr.apellidoencuestador
    }));
    const {letraGrandeFormulario, mostrarColumnasFaltantesYAdvertencias} = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const classes = useStylesTable();
    const dispatch = useDispatch();
    const stylesTableHeader = {fontSize: "1.3rem"}
    return (
        <>
            <AppBar position="fixed">
                <Toolbar>
                    <Typography variant="h6">
                        Hoja de ruta
                    </Typography>
                    <Button style={{marginTop:'5px'}}
                        color="inherit"
                        onClick={()=>
                            dispatch(dispatchers.SET_OPCION({variable:'pantallaOpciones',valor:true}))
                        }
                    >
                        <SettingsIcon/>
                    </Button>
                </Toolbar>
            </AppBar>
            <main>
                <Paper className={classes.root}>
                    <Typography component="p" style={{fontSize:"1.2rem", fontWeight:600, padding: "5px 10px"}}>
                        Panel: {panel} Tarea: {tarea} Encuestador/a: {apellidoencuestador}, {nombreencuestador} ({encuestador})
                    </Typography>
                    <Table className="hoja-ruta" style={{borderTopStyle: "groove"}}>
                        <colgroup>
                            {letraGrandeFormulario?null:<col style={{width:"33%"}}/>}
                            <col style={{width:letraGrandeFormulario?"79%":"46%"}}/>
                            {mostrarColumnasFaltantesYAdvertencias?<col style={{width:"7%"}}/>:null}
                            {mostrarColumnasFaltantesYAdvertencias?<col style={{width:"7%"}}/>:null}
                            {mostrarColumnasFaltantesYAdvertencias?<col style={{width:"7%"}}/>:null}
                        </colgroup>      
                        <TableHead style={{fontSize: "1.2rem"}}>
                            <TableRow className="hdr-tr-informante">
                                {letraGrandeFormulario || !mostrarColumnasFaltantesYAdvertencias?null:<TableCell style={stylesTableHeader}>informante</TableCell>}
                                {mostrarColumnasFaltantesYAdvertencias?<TableCell style={stylesTableHeader}>formulario</TableCell>:null}
                                {mostrarColumnasFaltantesYAdvertencias?<TableCell style={stylesTableHeader}>prod</TableCell>:null}
                                {mostrarColumnasFaltantesYAdvertencias?<TableCell style={stylesTableHeader}>faltan</TableCell>:null}
                                {mostrarColumnasFaltantesYAdvertencias?<TableCell style={stylesTableHeader}>adv</TableCell>:null}
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {informantes.map((informante:RelInf)=>
                                <InformanteRow key={informante.informante} informante={informante}/>
                            )}
                        </TableBody>
                    </Table>
                </Paper>
            </main>
        </>
    );
}

function PantallaOpciones(){
    const {letraGrandeFormulario, mostrarColumnasFaltantesYAdvertencias} = useSelector((hdr:HojaDeRuta)=>hdr.opciones)
    const dispatch = useDispatch();
    return (
        <>
            <AppBar position="fixed">
                <Toolbar>
                    <Typography variant="h6">Opciones del dispositivo móvil</Typography>
                </Toolbar>
            </AppBar>
            <main>
                <Typography>
                    <Grid component="span">Letra en formulario:</Grid>
                    <Grid component="label" container alignItems="center" spacing={1}>
                        <Grid item>chica</Grid>
                        <Grid item>
                            <Switch
                                checked={letraGrandeFormulario}
                                onChange={(event)=>{
                                    dispatch(dispatchers.SET_OPCION({variable:'letraGrandeFormulario',valor:event.target.checked}));
                                    document.documentElement.setAttribute('pos-productos',event.target.checked?'arriba':'izquierda');
                                }}
                                value="letraGrandeEnFormulario"
                                color="primary"
                                inputProps={{ 'aria-label': 'primary checkbox' }}
                            />
                        </Grid>
                        <Grid item>Grande</Grid>
                    </Grid>            
                </Typography>
                <Typography>
                    <Grid component="span">Mostrar advertencias en hoja de ruta</Grid>
                    <Grid component="label" container alignItems="center" spacing={1}>
                        <Grid item>no</Grid>
                        <Grid item>
                            <Switch
                                checked={mostrarColumnasFaltantesYAdvertencias}
                                onChange={(event)=>{
                                    dispatch(dispatchers.SET_OPCION({variable:'mostrarColumnasFaltantesYAdvertencias',valor:event.target.checked}));
                                }}
                                value="mostrarColumnasFaltantesYAdvertencias"
                                color="primary"
                                inputProps={{ 'aria-label': 'primary checkbox' }}
                            />
                        </Grid>
                        <Grid item>sí</Grid>
                    </Grid>            
                </Typography>
                <Button style={{marginTop:'2px'}}
                    color="primary"
                    variant="contained"
                    onClick={()=>
                        dispatch(dispatchers.SET_OPCION({variable:'pantallaOpciones',valor:false}))
                    }
                >
                    <DescriptionIcon/>
                    Volver a hoja de ruta
                </Button>
            </main>
        </>
    )
}

function AppDmIPCOk(){
    const {relVisPk, letraGrandeFormulario, pantallaOpciones} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    document.documentElement.setAttribute('pos-productos', letraGrandeFormulario?'arriba':'izquierda');
    if(relVisPk == undefined){
        if(pantallaOpciones){
            return <PantallaOpciones/>
        }else{
            return <PantallaHojaDeRuta/>
        }
    }else{
        return <FormularioVisita relVisPk={relVisPk} />
    }
}

function ReseterForm(props:{onTryAgain:()=>void}){
    const dispatch = useDispatch();
    return <>
        <Button variant="outlined"
            onClick={()=>{
                dispatch(dispatchers.RESET_OPCIONES({}));
                props.onTryAgain();
            }}
        >Volver a la hoja de ruta</Button>
    </>;
}

class DmIPCCaptureError extends React.Component<
    {},
    {hasError:boolean, error:Error|{}, info?:any}
>{
    constructor(props:any) {
        super(props);
        this.state = { hasError: false, error:{} };
    }
    componentDidCatch(error:Error, info:any){
        this.setState({ hasError: true , error, info });
    }
    render(){
        if(this.state.hasError){
            return <>
                <Typography>Hubo un problema en la programación del dipositivo móvil.</Typography>
                <ReseterForm onTryAgain={()=>
                    this.setState({ hasError: false, error:{} })
                }/>
                <Typography>Error detectado:</Typography>
                <Typography>{this.state.error.message}</Typography>
                <Typography>{JSON.stringify(this.state.info)}</Typography>
            </>;
        }
        return this.props.children;
    }
}

function AppDmIPC(){
    return <DmIPCCaptureError>
        <CssBaseline />
        <AppDmIPCOk />
    </DmIPCCaptureError>
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

// @ts-ignore addrParams tiene un tipo que acá no importa
export async function dmHojaDeRuta(_addrParams){
    const {store, estructura} = await dmTraerDatosHdr();
    mostrarHdr(store, estructura);
}

if(typeof window !== 'undefined'){
    // @ts-ignore para hacerlo
    window.dmHojaDeRuta = dmHojaDeRuta;
}