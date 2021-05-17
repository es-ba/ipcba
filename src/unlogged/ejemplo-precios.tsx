import * as React from "react";
import * as ReactDOM from "react-dom";
import {Producto, RelPre, RelAtr, AtributoDataTypes, HojaDeRuta, Razon, Estructura, RelInf, RelVis, RelVisPk, 
    LetraTipoOpciones, OptsHdr, FocusOpts
} from "./dm-tipos";
import {
    puedeCopiarTipoPrecio, puedeCopiarAtributos, muestraFlechaCopiarAtributos, 
    puedeCambiarPrecioYAtributos, tpNecesitaConfirmacion, razonNecesitaConfirmacion, 
    controlarPrecio, controlarAtributo, precioTieneAdvertencia, precioEstaPendiente,
    precioTieneError, 
    COLOR_ERRORES,
    precioTieneAtributosCargados,
    parseString
} from "./dm-funciones";
import {ActionHdr, dispatchers, dmTraerDatosHdr, borrarDatosRelevamientoLocalStorage, devolverHojaDeRuta, isDirtyHDR, 
    hdrEstaDescargada, getCacheVersion} from "./dm-react";
import {useState, useEffect, useRef, useLayoutEffect} from "react";
import { Provider, useSelector, useDispatch } from "react-redux"; 
import {areEqual} from "react-window";
import * as memoizeBadTyped from "memoize-one";
import * as likeAr from "like-ar";
import * as clsxx from 'clsx';
//@ts-ignore el módulo clsx no tiene bien puesto los tipos en su .d.ts
var clsx: (<T>(a1:string|T, a2?:T)=> string) = clsxx;

//@ts-ignore el módulo memoize-one no tiene bien puesto los tipos en su .d.ts
var memoize:typeof memoizeBadTyped.default = memoizeBadTyped;

import {
    CircularProgress, CssBaseline, Fab, 
    IconButton, Paper, useScrollTrigger, SvgIcon, Switch, Table, TableBody, TableCell, TableHead, TableRow, Zoom,
} from "@material-ui/core";
import { createStyles, makeStyles, Theme} from '@material-ui/core/styles';
import { Store } from "redux";

type CommonAttributes = {className?:string,style?:React.CSSProperties,id?:string} // CSSProperties
type BootstrapColors = 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info' | 'light' | 'dark';

const TOOLBAR_STYLE=hdrEstaDescargada()?{backgroundColor:'red'}:{backgroundColor:"#3f51b5"};

function useLockBodyScroll() {
  useLayoutEffect(() => {
    // Get original body overflow
    const originalStyle = window.getComputedStyle(document.body).overflow;
    // Prevent scrolling on mount
    document.body.style.overflow = "hidden";
    // Re-enable scrolling when component unmounts
    return () => {
        document.body.style.overflow = originalStyle
    };
  }, []); // Empty array ensures effect is only run on mount and unmount
}

type MenuPosition={
    top:number|null,
    left:number|null,
    maxHeight:number|string,
    maxWidth:number|string, 
    scrollY:number|null
};

const Menu = (props:{
    open:boolean,
    id:string,
    anchorEl:Element|null|undefined,
    onClose?:()=>void,
    children:any,
}&CommonAttributes)=>{
    return props.open?React.createElement(OpenedMenu,props,props.children):null
}

const OpenedMenu = (props:{
    id:string,
    anchorEl:Element|null|undefined,
    onClose?:()=>void,
    children:any,
})=>{
    useLockBodyScroll();
    const divEl = useRef(null);
    const [position, setPosition] = useState<MenuPosition>({
        top:null,
        left:null,
        maxHeight:'auto',
        maxWidth:'auto',
        scrollY:null
    });
    useLayoutEffect(() => {
        if(divEl && divEl.current){
            let myElement = divEl.current! as HTMLDivElement;
            if(position.top == null || position.left==null || window.scrollY != position.scrollY){
                //posicionamiento inicial
                var initialPosition:MenuPosition={
                    top: 0,
                    left: 0,
                    maxHeight:'auto',
                    maxWidth:'auto',
                    scrollY: window.scrollY
                };
                let element = props.anchorEl as HTMLElement|null;
                if(element){
                    while(element != null) {
                        initialPosition.top! += element.offsetTop;
                        initialPosition.left! += element.offsetLeft;
                        element = element.offsetParent as HTMLElement|null;
                    }
                    initialPosition.top!-=window.scrollY;
                    initialPosition.left!-=window.scrollX;
                }
                initialPosition.maxHeight=window.innerHeight-initialPosition.top!;
                initialPosition.maxWidth=window.innerWidth-initialPosition.left!;
                setPosition(initialPosition);
            }else{
                //corrección para aprovechar máximo de pantalla posible
                let aSubir=0;
                if(myElement.scrollHeight > myElement.clientHeight){
                    let faltante = myElement.scrollHeight - myElement.clientHeight + 5;
                    let disponibleParaAjuste = window.innerHeight - myElement.offsetHeight;
                    aSubir = Math.min(faltante, disponibleParaAjuste);
                }
                let aIzquierda=0;
                if(myElement.scrollWidth > myElement.clientWidth){
                    let faltante = myElement.scrollWidth - myElement.clientWidth + 5;
                    let disponibleParaAjuste = window.innerWidth - myElement.offsetWidth;
                    aIzquierda = Math.min(faltante, disponibleParaAjuste);
                }
                if(aSubir || aIzquierda){
                    setPosition({
                        top:position.top - aSubir,
                        left:position.left - aIzquierda,
                        maxHeight:Number(position.maxHeight) + aSubir,
                        maxWidth:Number(position.maxWidth) + aIzquierda,
                        scrollY: window.scrollY
                    });
                }
            }
        }
    },[window.scrollY, position]);
    return ReactDOM.createPortal(
        <div 
            className="dropdown-menu-container"
            onClick={props.onClose}
            style={{
                width:'100%',
                height:'100%',
                zIndex: 99998,
                position: 'fixed',
                top: 0,
                left: 0,
            }}>
            <div 
                id={props.id}
                ref={divEl}
                onClick={(event)=>event.stopPropagation()}
                className="dropdown-menu"
                style={{
                    display:'unset',
                    top:position.top==null?'unset':position.top,
                    left:position.left==null?'unset':position.left,
                    maxHeight:position.maxHeight,
                    maxWidth:position.maxWidth,
                    zIndex: 99999,
                    overflow:'auto',
                }}
            >
                {props.children}
            </div>
        </div>,
        document.body
    )
}
function MenuItem(props:{
    children:any,
    disabled?: boolean
    onClick?:(event:React.MouseEvent)=>void,
}&CommonAttributes){
    var {id, className, style, children, ...other} = props;
    return <li
        {...other}
        id={props.id}
        className={`${className||''} dropdown-item ${props.disabled?'disabled':''}`}
        style={{ ...{height:'50px', paddingTop:'8px'},...(props.style || {})}}
        onClick={props.onClick}
    >
        {children}
    </li>
}
function ListItemText(props:{
    children?:any,
    primary?:string,
    secondary?:string,
    onClick?:(event:React.MouseEvent)=>void,
}&CommonAttributes){
    var {id, className, style, children, primary, secondary,  ...other} = props;
    return <span
        {...other}
        id={props.id}
        className={`${className||''}`}
        style={{ ...{verticalAlign:'middle'},...(props.style || {})}}
        onClick={props.onClick}
    >
        {primary?primary:null}
        {secondary?
            <p style={{
                color:"rgba(0, 0, 0, 0.54)",
                fontSize: "0.875rem",
                marginBottom:"0px"
            }}>
                {secondary}
            </p>
        :
            null
        }
        {children}
    </span>
}
const Chip = (props:{
    label:string|JSX.Element|HTMLElement,
    style:any,
})=>{
    return <span className="badge" style={...props.style}>{props.label}</span>
}
const ButtonGroup = (props:{children:any}&CommonAttributes)=>{
    return <div 
        className="btn-group"
        role="group"
        style={{ 
            ...{
                margin: '0px 3px',
            }, 
            ...props.style
        }}
    >
        {props.children}
    </div>
}
const Button = (props:{
    variant?:string,
    color?:string,
    onClick?:(event:React.MouseEvent)=>void,
    disabled?:boolean
    fullwidth?:boolean
    children:any,
    size?:'lg'|'md'
}&CommonAttributes)=>{
    props.variant = props.variant || 'contained';
    props.color = props.color || 'light';
    const {...other} = props;
    return <button 
        {...other}
        id={props.id}
        className={`
            btn 
            btn${props.variant=='contained'?'':'-'+props.variant}${props.color?'-'+props.color:''} 
            ${props.className || ''} 
            ${props.size?`btn-${props.size}`:''}
        `}
        disabled={props.disabled}
        onClick={props.onClick}
        style={{ 
            ...{
                width:props.fullwidth?'100%':'none',
                color: props.disabled?'rgba(0, 0, 0, 0.12)':'',
                border: props.disabled?'1px solid rgba(0, 0, 0, 0.12)':'',
                whiteSpace: 'unset'
            }, 
            ...props.style
        }}
    >{props.children}</button>
}

function ResizableTextarea(props:{
    value:string
    autoFocus?:boolean,
    disabled:boolean,
    readOnly:boolean,
    fullWidth?:boolean
    placeholder?:string,
    rowsMax?:number,
    onKeyDown?:(event:any)=>void,
    onChange?:(event:any)=>void,
    onFocus?:(event:any)=>void,
    onBlur?:(event:any)=>void,
    color?:string
}&CommonAttributes){
    const [myValue, setMyValue] = useState<string|null>(props.value);
    const [config, setConfig] = useState({
		rows: 1,
		minRows: 1,
	    maxRows: props.rowsMax?props.rowsMax:100,
	})
    const textareaEl = useRef(null);
    useEffect(() => {
        setMyValue(props.value || null)
    }, [props.value]);
    useLayoutEffect(() => {
        if(textareaEl && textareaEl.current){
            const {minRows, maxRows} = config;
            const textareaElement = textareaEl.current! as HTMLTextAreaElement;
            const textareaLineHeight = parseInt(window.getComputedStyle(textareaElement).lineHeight);
            const previousRows = textareaElement.rows;
            textareaElement.rows = minRows; // reset number of rows in textarea 
            const currentRows = ~~(textareaElement.scrollHeight / textareaLineHeight);
            if (currentRows === previousRows) {
                textareaElement.rows = currentRows;
            }
            if (currentRows >= maxRows) {
                textareaElement.rows = maxRows;
                textareaElement.scrollTop = textareaElement.scrollHeight;
            }
            setConfig({
                rows: currentRows < maxRows ? currentRows : maxRows,
                minRows,
                maxRows
            })
        }
    }, [myValue]);
	return <textarea
        id={props.id}
        ref={textareaEl}
		rows={config.rows}
		value={myValue || ''}
        spellCheck={false}
        autoCapitalize="off"
        autoComplete="off"
        autoCorrect="off"
		onChange={(event)=>{
            setMyValue(event.target.value || null)
            props.onChange?.(event);
        }}
        autoFocus={props.autoFocus}
        disabled={props.disabled}
        readOnly={props.readOnly}
        className={`${props.className||''}`}
        onKeyDown={(event)=>{
            props.onKeyDown?.(event)
        }}
        onClick={(event)=>{
            var element = event.target as HTMLTextAreaElement;
            var selection = element.value.length||0;
            element.selectionStart = selection;
            element.selectionEnd = selection;
        }}
        onFocus={props.onFocus}
        onBlur={props.onBlur}
        placeholder={props.placeholder}
        style={{...props.style,...{width:props.fullWidth?'100%':'unset'}}}
	/>
}

const TextField = (props:{
    id?:string,
    autoFocus?:boolean,
    disabled?:boolean,
    readOnly?:boolean,
    className?:string,
    fullWidth?:boolean
    value?:any,
    type?:InputTypes,
    placeholder?:string,
    rowsMax?:number,
    onKeyDown?:(event:any)=>void,
    onChange?:(event:any)=>void,
    onFocus?:(event:any)=>void,
    onBlur?:(event:any)=>void,
    hasError:boolean,
    borderBottomColor?:string,
    borderBottomColorError?:string,
    color?:string
})=>{
    var {hasError, borderBottomColorError, borderBottomColor, color} = props;
    borderBottomColor=borderBottomColor||PRIMARY_COLOR;
    const styles = {
        border: "0px solid white",
        borderBottom:  `1px solid ${hasError?borderBottomColorError:borderBottomColor}`,
        color: color,
        outline:'none'
    };
    return props.type=='text'?
        <ResizableTextarea
            id={props.id}
            autoFocus={props.autoFocus}
            fullWidth={props.fullWidth}
            disabled={props.disabled || false}
            readOnly={props.readOnly || false}
            className={`${props.className||''}`}
            value={props.value} 
            onKeyDown={(event)=>{
                props.onKeyDown?.(event)
            }}
            onChange={props.onChange}
            onFocus={props.onFocus}
            onBlur={props.onBlur}
            placeholder={props.placeholder}
            style={{...styles}}
        />
    :
        <input
            id={props.id}
            spellCheck={false}
            autoCapitalize="off"
            autoComplete="off"
            autoCorrect="off"
            autoFocus={props.autoFocus}
            disabled={props.disabled}
            readOnly={props.readOnly}
            className={`${props.className||''}`}
            value={props.value} 
            type={props.type}
            onKeyDown={props.onKeyDown}
            onChange={props.onChange}
            onFocus={props.onFocus}
            onBlur={props.onBlur}
            placeholder={props.placeholder}
            style={styles}
        />
};

const Typography = ({children, ...others}:{
    children:any,
    component?:string
    variant?:'h1'|'h2'|'h3'|'h4'|'h5'|'h6'
}&CommonAttributes)=>{
    others.style = {...others.style, ...{margin:0}};
    return React.createElement(others.variant||others.component||'div',others,children);
}

const List = (props:{
    children?:any,
}&CommonAttributes)=>{
    var {id, className, style, children, ...other} = props;
    return <ul
        {...other}
        id={id}
        className={`${className||''} dropdown-menu`}
        style={{ ...{display: 'unset'},...(style || {})}}
    >
        {children}
    </ul>
}

const ListItem = (props:{
    children?:any,
    selected?:boolean,
    onClick?:(event:React.MouseEvent)=>void,
}&CommonAttributes)=>{
    var {id, className, selected, onClick, style, children, ...other} = props;
    return <li
        {...other}
        id={id}
        onClick={onClick}
        className={`${className||''} dropdown-item ${selected?'text-light bg-secondary':'text-secondary bg-transparent'}`}
        style={{ ...{display:'flex', justifyContent:'flex-start', paddingTop:8, paddingBottom:8, paddingLeft:15},...(style || {})}}
    >
        {children}
    </li>
}

const ListItemIcon = (props:{
    children?:any,
}&CommonAttributes)=>{
    var {id, className, style, children, ...other} = props;
    return <div
        {...other}
        id={id}
        className={`${className||''}`}
        style={{ ...{fontSize:'1.4rem', minWidth:65},...(style || {})}}
    >
        {children}
    </div>
}

const Divider = ({...other}:{}&CommonAttributes)=>
    <div 
        {...other}
        id={other.id}
        className={`${other.className||''} dropdown-divider`}
        style={{ ...{},...(other.style || {})}}
    />

const Badge = (props:{
    children?:any,
    color?:string,
    badgeContent:string|null,
    backgroundColor?:string,
    anchorOrigin?:{ horizontal: 'left'| 'right', vertical: 'bottom'| 'top' },
    variant?:'standard'|'dot',
    fullWidth?:boolean
}&CommonAttributes)=>{
    var {id, className, style, variant, fullWidth, children, color, anchorOrigin, backgroundColor, badgeContent, ...other} = props;
    anchorOrigin = anchorOrigin || {horizontal:'right', vertical:'top'};
    variant = variant || 'standard';
    fullWidth = fullWidth==undefined?true:fullWidth;
    var badgePosition = {
        top:anchorOrigin.vertical=='top'?-5:'unset',
        left:anchorOrigin.horizontal=='left'?-5:'unset',
        right:anchorOrigin.horizontal=='right'?-5:'unset',
        bottom:anchorOrigin.vertical=='bottom'?-5:'unset'
    }
    return badgeContent==null?
        <>{children}</>
    :
        <span 
            {...other}
            id={props.id}
            className={`${className||''}`}
            style={{
                //top:0,
                //transform: 'scale(1) translate(9px, -50%)',
                //right:0,
                width: fullWidth?'100%':'unset',
                display: 'inline-flex',
                position: 'relative',
                flexShrink: 0,
                verticalAlign: 'middle',
                //position:'absolute',
                //color,
                //backgroundColor,
                //borderRadius: 10,
                //fontSize: '0.85rem',
                //minWidth: 20
            }}
        >
            {children}
            <span style={{ ...{
                ...badgePosition,
                height: variant=='standard'?'20px':'8px',
                width: variant=='standard'?'unset':'8px',
                display: 'flex',
                padding: variant=='standard'?'0 6px':'unset',
                zIndex: 1,
                position: 'absolute',
                flexWrap: 'wrap',
                fontSize: '0.75rem',
                minWidth: variant=='standard'?'20px':'8px',
                boxSizing: 'border-box',
                transition: 'transform 225ms cubic-bezier(0.4, 0, 0.2, 1) 0ms',
                alignItems: 'center',
                fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
                fontWeight: 500,
                lineHeight: 1,
                alignContent: 'center',
                borderRadius: '10px',
                flexDirection: 'row',
                justifyContent: 'center',
                color,
                backgroundColor,
            },...(style || {})}}
            >{badgeContent}</span>
        </span>
}

function Grid(props:{
    container?:boolean,
    spacing?:number,
    component?:'span'|'label'
    item?:boolean,
    wrap?:'wrap'|'nowrap',
    direction?:'row'|'column'
    alignItems?:'stretch' | 'flex-start' | 'flex-end' | 'center' | 'baseline',
    children:any,
    xs?:number,
    sm?:number,
}&CommonAttributes){
    var {container, item, wrap, direction, alignItems, children, className, xs, sm, spacing, ...other} = props;
    return <div
    {...other}
    className={`${className||''} ${xs!=null?'grid-xs-'+xs:''} ${sm!=null?'grid-sm-'+sm:''}`}
    style={container?{
        display:'flex',
        flexWrap:wrap,
        flexDirection:direction,
        alignItems:alignItems,
        margin:spacing!=null?spacing*8+'px':undefined
    }:{
    }}
>{children}</div>
}
const AppBar = (props:{
        children:any,
        color?:'dark' | 'light',
        backgroundColor?:BootstrapColors,
        position?:'sticky'|'fixed',
        shift?:number,
        shiftCondition?:boolean
    }&CommonAttributes)=>{
    const {id, className, position, shift, shiftCondition, children, ...other} = props;
    var {backgroundColor, color} = props;
    backgroundColor = backgroundColor || 'primary';
    color = color || 'dark';
    return <nav 
        {...other}
        id={id}
        className={`${className||''} navbar-expand-lg navbar ${position?position+"-top":""} navbar-${color} ${props.style?.backgroundColor?'':'bg-'+backgroundColor}`}
        style={{ ...{
            zIndex:1300,
            height:"70px",
            width: shift && shiftCondition?`calc(100% - ${shift}px)`:'100%',
            marginLeft: shift && shiftCondition?`${shift}px`:'0',
            transition: '0.4s',
            justifyContent: 'unset',
            flexWrap:'unset',
            paddingLeft: 25
        },...(props.style || {})}}
    >
        {React.Children.map(children, child => (
            <span className={"navbar-nav"} style={{margin: '0px 2px', flexWrap:'unset'}}>
                <span className="nav-item">
                    <span className="nav-link active">
                        {child}
                    </span>
                </span>
            </span>
        ))}
    </nav>
}

const Drawer = (props:{children:any, initialWidth?:number, openedWidth?:number, open:boolean}&CommonAttributes)=>{
    const {id, className, open, initialWidth, openedWidth, children, ...other} = props;
    return <div style={{ ...{
        width: open?openedWidth:initialWidth}
    }}>
        <div 
            {...other}
            id={id}
            className={`${className||''} sidebar`}
            style={{ ...{
                height: '100%',
                width: open?openedWidth:initialWidth,
                position: 'fixed',
                zIndex: 1,
                top: 0,
                left: 0,
                backgroundColor: '#ffffff',
                overflowX: 'hidden',
                transition: '0.4s',
                whiteSpace: 'nowrap',
                border: "1px solid #ddd",
            },...(props.style || {})}}
        >
            {children}
        </div>
    </div>
}

const SearchInput = (props:{value:string, onChange?:(event:any)=>void, onReset?:()=>void,}&CommonAttributes)=>{
    const {id, className, value, onChange, onReset, ...other} = props;
    return <span className="input-group">
        <span 
            className="input-group-append bg-white border-right-0 rounded-left"
        >
            <span 
                className="input-group-text bg-transparent rounded-left"
                style={{padding:"5px"}}
            >
                <SearchIcon />
            </span>
        </span>
        <input
            {...other}
            id={id}
            value={value}
            className={`${className||''} form-control border-right-0 border-left-0`}
            placeholder="Buscar..."
            type="search"
            aria-label="Search"
            onChange={onChange}
            style={{ ...{
                
            },...(props.style || {})}}
        />
        {value && onReset?
            <span 
                onClick={onReset}
                className="input-group-append bg-white border-left-0 rounded-right">
                <span className="input-group-text bg-default rounded-right">
                    <ClearIcon />
                </span>
            </span>
        :null}
    </span>
}

const Dialog = (props:{
    open:boolean,
    onClose?:()=>void,
    children:any,
}&CommonAttributes)=>{
    return props.open?React.createElement(OpenedDialog,props,props.children):null
}
const OpenedDialog = (props:{
    //open:boolean,
    onClose?:()=>void,
    children:any,
}&CommonAttributes)=>{
    const {id, className, style, /*open,*/ onClose, ...other} = props;
    useLockBodyScroll();
    //useEffect(() => {
    //    document.body.style.overflow=open?'hidden':'unset'
    //});
    return ReactDOM.createPortal(
            <div 
                onClick={props.onClose}
                style={{
                    width:'100%',
                    height:'100%',
                    zIndex: 99998,
                    position: 'fixed',
                    backgroundColor: 'rgba(0, 0, 0, 0.5)',
                    top: 0,
                    left: 0,
            }}>
                <div
                    onClick={(event)=>event.stopPropagation()}
                    className="modal-dialog"
                    role="document"
                    style={{ ...{
                        zIndex: 99999,
                    },...(style || {})}}
                >
                    <div className="modal-content">
                        {props.children}
                    </div>
                </div>
            </div>,
            document.body
        )
}
const DialogTitle = (props:{
    children:any,
}&CommonAttributes)=>{
    const {id, className, style, children, ...other} = props;
    return <div id={id}
        style={{ ...{

        },...(style || {})}}
            className={`${className||''} modal-header`}
        >
            <h5 className="modal-title">{children}</h5>
    </div>
}

const DialogContent = (props:{
    children:any,
}&CommonAttributes)=>{
    const {id, className, style, children, ...other} = props;
    return <div id={id}
        style={{ ...{

        },...(style || {})}}
            className={`${className||''} modal-body`}
        >
            {children}
    </div>
}
const DialogContentText = (props:{
    children:any,
}&CommonAttributes)=>{
    const {id, className, style, children, ...other} = props;
    return <p id={id}
        style={{ ...{

        },...(style || {})}}
            className={`${className||''}`}
        >
            {children}
    </p>
}
const DialogActions = (props:{
    children:any,
}&CommonAttributes)=>{
    const {id, className, style, children, ...other} = props;
    return <div id={id}
        style={{ ...{

        },...(style || {})}}
            className={`${className||''} modal-footer`}
        >
            {children}
    </div>
}
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
    Delete:"M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z",
    Description: "M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z",
    EmojiObjects: "M12 3c-.46 0-.93.04-1.4.14-2.76.53-4.96 2.76-5.48 5.52-.48 2.61.48 5.01 2.22 6.56.43.38.66.91.66 1.47V19c0 1.1.9 2 2 2h.28c.35.6.98 1 1.72 1s1.38-.4 1.72-1H14c1.1 0 2-.9 2-2v-2.31c0-.55.22-1.09.64-1.46C18.09 13.95 19 12.08 19 10c0-3.87-3.13-7-7-7zm2 16h-4v-1h4v1zm0-2h-4v-1h4v1zm-1.5-5.59V14h-1v-2.59L9.67 9.59l.71-.71L12 10.5l1.62-1.62.71.71-1.83 1.82z",
    ExitToApp: "M10.09 15.59L11.5 17l5-5-5-5-1.41 1.41L12.67 11H3v2h9.67l-2.58 2.59zM19 3H5c-1.11 0-2 .9-2 2v4h2V5h14v14H5v-4H3v4c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z",
    ExpandLess: "M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z",
    ExpandMore: "M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z",
    FormatLineSpacing: "M6 7h2.5L5 3.5 1.5 7H4v10H1.5L5 20.5 8.5 17H6V7zm4-2v2h12V5H10zm0 14h12v-2H10v2zm0-6h12v-2H10v2z",
    Info: "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z",
    KeyboardArrowUp: "M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z",
    Label: "M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z",
    LocalAtm: "M11 17h2v-1h1c.55 0 1-.45 1-1v-3c0-.55-.45-1-1-1h-3v-1h4V8h-2V7h-2v1h-1c-.55 0-1 .45-1 1v3c0 .55.45 1 1 1h3v1H9v2h2v1zm9-13H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4V6h16v12z",
    Menu: "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z",
    RemoveShoppingCart: "M22.73 22.73L2.77 2.77 2 2l-.73-.73L0 2.54l4.39 4.39 2.21 4.66-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h7.46l1.38 1.38c-.5.36-.83.95-.83 1.62 0 1.1.89 2 1.99 2 .67 0 1.26-.33 1.62-.84L21.46 24l1.27-1.27zM7.42 15c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h2.36l2 2H7.42zm8.13-2c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H6.54l9.01 9zM7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2z",
    Save:"M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm3-10H5V5h10v4z",
    Search: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    Settings: "M15.95 10.78c.03-.25.05-.51.05-.78s-.02-.53-.06-.78l1.69-1.32c.15-.12.19-.34.1-.51l-1.6-2.77c-.1-.18-.31-.24-.49-.18l-1.99.8c-.42-.32-.86-.58-1.35-.78L12 2.34c-.03-.2-.2-.34-.4-.34H8.4c-.2 0-.36.14-.39.34l-.3 2.12c-.49.2-.94.47-1.35.78l-1.99-.8c-.18-.07-.39 0-.49.18l-1.6 2.77c-.1.18-.06.39.1.51l1.69 1.32c-.04.25-.07.52-.07.78s.02.53.06.78L2.37 12.1c-.15.12-.19.34-.1.51l1.6 2.77c.1.18.31.24.49.18l1.99-.8c.42.32.86.58 1.35.78l.3 2.12c.04.2.2.34.4.34h3.2c.2 0 .37-.14.39-.34l.3-2.12c.49-.2.94-.47 1.35-.78l1.99.8c.18.07.39 0 .49-.18l1.6-2.77c.1-.18.06-.39-.1-.51l-1.67-1.32zM10 13c-1.65 0-3-1.35-3-3s1.35-3 3-3 3 1.35 3 3-1.35 3-3 3z",
    SyncAlt:"M22 8l-4-4v3H3v2h15v3l4-4zM2 16l4 4v-3h15v-2H6v-3l-4 4z",
    SystemUpdate:"M17 1.01L7 1c-1.1 0-2 .9-2 2v18c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V3c0-1.1-.9-1.99-2-1.99zM17 19H7V5h10v14zm-1-6h-3V8h-2v5H8l4 4 4-4z",
    Warning: "M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z",
    /// JULI ICONS:
    Pendientes:"M2.4 15.35 H 104.55 V 35.65 H -104.55 M 2.4 59.35 H 104.55 V 35.65 Z M 2.4 103.35 H 104.55 V 35.65 Z  M145.6,109.35V133H121.95V109.35H145.6m6-6H115.95V139H151.6V103.35h0Z M145.6,65.35V89H121.95V65.35H145.6m6-6H115.95V95H151.6V59.35h0Z M145.6,21.35V45H121.95V21.35H145.6m6-6H115.95V51H151.6V15.35h0Z",
    Repregunta:"M19.9,13.3c0,4.4-3.6,7.9-7.9,7.9s-7.9-3.6-7.9-7.9S7.6,5.4,12,5.4V8l5.3-4l-5.3-4v2.6C6.1,2.7,1.4,7.5,1.4,13.3 S6.1,23.9,12,23.9s10.6-4.7,10.6-10.6H19.9z M8.9,17.8v-7.6h3.2c0.8,0,1.4,0.1,1.8,0.2c0.4,0.1,0.7,0.4,0.9,0.7 c0.2,0.4,0.3,0.7,0.3,1.2c0,0.6-0.2,1-0.5,1.4c-0.3,0.4-0.8,0.6-1.5,0.7c0.3,0.2,0.6,0.4,0.8,0.6c0.2,0.2,0.5,0.6,0.9,1.2l0.9,1.5 h-1.8l-1.1-1.7c-0.4-0.6-0.7-1-0.8-1.1c-0.1-0.2-0.3-0.3-0.5-0.3c-0.2-0.1-0.4-0.1-0.8-0.1h-0.3v3.2H8.9z M10.4,13.4h1.1 c0.7,0,1.2,0,1.4-0.1c0.2-0.1,0.3-0.2,0.4-0.3c0.1-0.2,0.2-0.3,0.2-0.6c0-0.3-0.1-0.5-0.2-0.6c-0.1-0.2-0.3-0.3-0.6-0.3 c-0.1,0-0.5,0-1.1,0h-1.2V13.4z",
}

const ICON = likeAr(materialIoIconsSvgPath).map(svgText=> () =>
    <SvgIcon><path d={svgText}/></SvgIcon>
).plain();

const ChevronLeftIcon = ICON.ChevronLeft;
const MenuIcon = ICON.Menu;
const DeleteIcon = ICON.Delete;
const DescriptionIcon = ICON.Description;
const SearchIcon = ICON.Search;
const KeyboardArrowUpIcon = ICON.KeyboardArrowUp;
const ClearIcon = ICON.Clear;
const SaveIcon = ICON.Save;
const SettingsIcon = ICON.Settings;
const SyncAltIcon = ICON.SyncAlt;
const SystemUpdateIcon = ICON.SystemUpdate;
const RepreguntaIcon = ICON.Repregunta;
const ExitToAppIcon = ICON.ExitToApp;

export var estructura:Estructura;

const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";
const PRIMARY_COLOR   ="#3f51b5";
const DEFAULT_ERROR_COLOR   ="#f44336";
const SECONDARY_COLOR ="#f50057";
const COLOR_ADVERTENCIAS = "rgb(255, 147, 51)";
const COLOR_PENDIENTES = "rgb(63, 81, 181)";
var CHECK = '✓';

type Styles = React.CSSProperties;

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

function focusToId(id:string, opts:FocusOpts, cb?:(e:HTMLElement)=>void){
    var element=document.getElementById(id);
    if(element){
        if(cb){
            cb(element);
        }else{
            element.focus();
            if(opts.moveToElement){
                let headerOffset = 120; //ajuste
                let elementPosition = 0
                while(element != null) {
                    elementPosition += element.offsetTop;
                    element = element.offsetParent as HTMLElement|null;
                }
                window.scrollTo({
                    top: elementPosition - headerOffset,
                    behavior: opts.behavior||'auto'
                });
            }
        }
    }
}

function TypedInput<T extends string|number|null>(props:{
    autoFocus:boolean,
    borderBottomColor:string,
    borderBottomColorError:string
    color:string
    hasError:boolean,
    value:T,
    dataType: InputTypes
    onUpdate:OnUpdate<T>, 
    idProximo:string|null,
    inputId:string,
    tipoOpciones?:LetraTipoOpciones|null,
    opciones?:string[]|null
    onFocus?:()=>void
    disabled?:boolean,
    readOnly?:boolean,
    placeholder?:string,
    simplificateText: boolean,
    textTransform?:'lowercase'|'uppercase',
}){
    const dispatch = useDispatch();
    function valueT(value:string):T{
        if(value=='' || value==null){
            // @ts-ignore sé que T es null
            return null;
        }else if(props.dataType=="number"){
            var valorT:number=Number(value);
            if(isNaN(valorT)){
                valorT=Number(value.replace(/[^0-9.,]/g,''));
            }
            // @ts-ignore sé que T es number
            return valorT;
        }
        // @ts-ignore sé que T es string
        return value;
    }
    function valueS(valueT:T):string{
        if(valueT==null){
            return '';
        }else if(props.dataType=="number"){
            return valueT.toString();
        }
        // @ts-ignore sé que T es string
        return valueT;
    }
    useEffect(() => {
        var typedInputElement = document.getElementById(inputId)
        if(valueT(value) != props.value && typedInputElement && typedInputElement === document.activeElement){
            typedInputElement.style.backgroundColor='red';
        }
        setValue(valueS(props.value));
    }, [props.value]);
    useEffect(function(){
        return function(){
            var typedInputElement = document.getElementById(inputId) as HTMLInputElement;
            if(typedInputElement){
                var value = valueT(typedInputElement.value);
                if(value!==props.value){
                    props.onUpdate(value);
                }
            }
        }
    },[])
    var inputId=props.inputId;
    var [value, setValue] = useState<string>(valueS(props.value));
    const onBlurFun = function <TE extends React.FocusEvent<HTMLInputElement>>(event:TE){
        /* CANDIDATO */ 
        // var customValue = event.target.value
        var customValue = parseString(event.target.value.trim(),props.textTransform,props.simplificateText);
        setValue(customValue);
        var value = valueT(customValue);
        if(value!==props.value){
            props.onUpdate(value);
        }
        dispatch(dispatchers.UNSET_FOCUS({unfocusing:props.inputId}));
    };
    const onChangeFun = function <TE extends React.ChangeEvent<HTMLInputElement>>(event:TE){
        setValue(event.target.value);
    }
    const onKeyDownFun:React.KeyboardEventHandler = function(event:React.KeyboardEvent<HTMLInputElement>){
        var tecla = event.charCode || event.which;
        if((tecla==13) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey){
            // @ts-ignore puede existir blur si target es un HTMLInputElement
            if(event.target.blur instanceof Function){
                // @ts-ignore puede existir blur si target es un HTMLInputElement
                event.target.blur();
            }
            if(props.idProximo!=null){
                var moveToElement = props.idProximo.split('-').length == 2;
                focusToId(props.idProximo,{
                    moveToElement,
                    behavior: 'smooth'
                })
            }
            props.onFocus?props.onFocus():null;
            event.preventDefault();
        }
    }

    return <TextField
        autoFocus={props.autoFocus}
        placeholder={props.placeholder}
        id={inputId}
        value={value}
        type={props.dataType} 
        onBlur={onBlurFun}
        onKeyDown={onKeyDownFun}
        onChange={onChangeFun}
        onFocus={(_event)=>{
            props.onFocus?props.onFocus():null;
        }}
        fullWidth={true}
        disabled={props.disabled?props.disabled:false}
        readOnly={props.readOnly?props.readOnly:false}
        hasError={props.hasError}
        borderBottomColor={props.borderBottomColor}
        borderBottomColorError={props.borderBottomColorError}
        color={props.color}
    />
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
                hasError={false}
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
            }} color="danger" variant="text">
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

function EditableTd<T extends string|number|null>(props:{
    autoFocus?:boolean,
    borderBottomColor?:string,
    borderBottomColorError?:string
    color?:string
    hasError:boolean,
    inputId:string,
    idProximo?:string|null,
    disabled?:boolean,
    placeholder?: string,
    dataType: InputTypes,
    value:T, 
    className?:string
    onUpdate:OnUpdate<T|null>,
    tipoOpciones?:LetraTipoOpciones|null,
    opciones?:string[]|null,
    titulo?:string,
    onFocus?:()=>void,
    textTransform?:'uppercase'|'lowercase',
    simplificateText?:boolean,
}){
    const [editando, setEditando]=useState(false);
    const [editandoOtro, setEditandoOtro]=useState(false);
    const mostrarMenu = useRef<HTMLTableDataCellElement>(null);
    const editaEnLista = props.tipoOpciones=='C' || props.tipoOpciones=='A';
    const borderBottomColor = props.borderBottomColor || PRIMARY_COLOR;
    const borderBottomColorError = props.borderBottomColorError || DEFAULT_ERROR_COLOR;
    const color = props.color || '#000000';
    var stringValue:string = props.value == null ? '' : props.value.toString();
    return <>
        <div  
            className={`${props.className}`} 
            ref={mostrarMenu} 
            onClick={(_event)=>{
                if(!props.disabled){
                    setEditando(true);
                    props.onFocus?props.onFocus():null;
                }
            }}
            puede-editar={!props.disabled && !editando?"yes":"no"}
        >
            <Badge 
                backgroundColor={borderBottomColorError}
                anchorOrigin={{vertical:'top', horizontal:'right'}}
                color="#ffffff"
                badgeContent={props.hasError?"!":null}
            >
                <TypedInput
                    autoFocus={props.autoFocus||false}
                    hasError={props.hasError}
                    borderBottomColor={borderBottomColor}
                    borderBottomColorError={borderBottomColorError}
                    color={color}
                    inputId={props.inputId}
                    value={props.value}
                    disabled={props.disabled}
                    readOnly={editaEnLista}
                    dataType={props.dataType}
                    idProximo={props.idProximo||null}
                    simplificateText={!!props.simplificateText}
                    textTransform={props.textTransform}
                    onUpdate={value =>{
                        props.onUpdate(value);
                    }}
                    tipoOpciones={props.tipoOpciones}
                    opciones={props.opciones}
                    placeholder={props.placeholder}
                    onFocus={()=>{props.onFocus?props.onFocus():null}}
                />            
            </Badge>
        </div>
        {editaEnLista && editando?
            <Menu id="simple-menu"
                open={editando && mostrarMenu.current !== undefined}
                anchorEl={mostrarMenu.current}
                onClose={()=> {
                    setEditando(false);
                }}
            >
                <MenuItem key='***** title' disabled={true}>
                    <ListItemText style={{color:'black', fontSize:'80%', fontWeight:'bold'}}>{props.titulo}</ListItemText>
                </MenuItem>
                {props.value && (props.opciones||[]).indexOf(stringValue)==-1?
                    <MenuItem key='*****current value******'
                        onClick={()=>{
                            setEditando(false);
                            props.onUpdate(parseString(props.value as string,"uppercase",true) as T);
                        }}
                    >
                        <ListItemText style={{color:'blue'}}>{props.value}</ListItemText>
                    </MenuItem>
                :null}
                <Divider />
                {(props.opciones||[]).map(label=>(
                    <MenuItem key={label}
                        onClick={()=>{
                            setEditando(false);
                            // @ts-ignore TODO: mejorar los componentes tipados #49
                            props.onUpdate(parseString(label,"uppercase",true));
                        }}
                    >
                        <ListItemText style={label == stringValue?{color:'blue'}:{}}>{label}</ListItemText>                    
                    </MenuItem>
                ))}
                {props.tipoOpciones=='A'?<Divider />:null}
                {props.tipoOpciones=='A'?
                    <MenuItem key='*****other value******' 
                        onClick={()=>{
                            setEditando(false);
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
            // @ts-ignore TODO: mejorar los componentes tipados #49
            <DialogoSimple 
                titulo={props.titulo} 
                valor={props.value as unknown as string /* TODO ver #49 */} 
                dataType={props.dataType} 
                inputId={props.inputId+'_otro_attr'}
                onCancel={()=>setEditandoOtro(false)}
                onUpdate={(value)=>{
                    setEditandoOtro(false);
                    // @ts-ignore TODO: mejorar los componentes tipados #49
                    props.onUpdate(value?parseString(value,"uppercase",true):null);
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
    idProximoAtributo: string|null,
    idProximoPrecio: string|null,
    primerAtributo:boolean, 
    cantidadAtributos:number, 
    ultimoAtributo:boolean,
    razonPositiva:boolean,
    onSelection:()=>void
}){
    const relAtr = props.relAtr;
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const atributo = estructura.atributos[relAtr.atributo];
    const prodatr = estructura.productos[relAtr.producto].atributos[relAtr.atributo];
    const [menuCambioAtributos, setMenuCambioAtributos] = useState<Element|null>(null);
    const {color: colorAdv, tieneAdv} = controlarAtributo(relAtr, relPre, estructura);
    return (
        <>
            <div className="nombre-atributo">{atributo.nombreatributo}</div>
            <div className="atributo-anterior" >{relAtr.valoranterior}</div>
            {props.primerAtributo?
                <div className="flechaAtributos" button-container="yes" style={{gridRow:"span "+relPre.atributos.length}}>
                    {props.razonPositiva?(
                        muestraFlechaCopiarAtributos(estructura, relPre)?
                            <Button disabled={!props.razonPositiva} color="primary" variant="outline" onClick={ () => {
                                props.onSelection();
                                dispatch(dispatchers.BLANQUEAR_ATRIBUTOS({
                                    forPk:relAtr, 
                                    iRelPre:props.iRelPre,
                                }))
                                dispatch(dispatchers.SET_FOCUS({nextId:!relPre.precio?props.inputIdPrecio:false}))
                            }}>
                                {FLECHAATRIBUTOS}
                            </Button>
                        :(relPre.cambio=='C' && puedeCopiarAtributos(estructura, relPre))?
                            <Button disabled={!props.razonPositiva} color="primary" variant="outline" onClick={ (event) => {
                                props.onSelection();
                                setMenuCambioAtributos(event.currentTarget)                            
                            }}>
                                C
                            </Button>
                        :(relPre.cambio=='=' && precioTieneAtributosCargados(relPre))?
                            <Button disabled={!props.razonPositiva} color="primary" variant="outline" onClick={ (event) => {
                                props.onSelection();
                                setMenuCambioAtributos(event.currentTarget)                            
                            }}>
                                =
                            </Button>
                        :relPre.cambio
                    ):null}
                </div>
            :null}
            <EditableTd 
                borderBottomColor={PRIMARY_COLOR}
                borderBottomColorError={colorAdv}
                color={relPre.cambio != "C" && relPre.tipoprecio == null?PRIMARY_COLOR:undefined}
                hasError={tieneAdv && props.razonPositiva}
                className="atributo-actual" 
                inputId={props.inputId}
                idProximo={props.idProximoAtributo || props.idProximoPrecio}
                disabled={!props.razonPositiva || !puedeCambiarPrecioYAtributos(estructura, relPre)} 
                dataType={adaptAtributoDataTypes(atributo.tipodato)} 
                value={relAtr.valor} 
                textTransform='uppercase'
                simplificateText={true}
                onUpdate={value=>{
                    dispatch(dispatchers.SET_ATRIBUTO({
                        forPk:relAtr, 
                        iRelPre:props.iRelPre,
                        valor:value,
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
                {relPre.cambio == 'C'?
                    <>
                        <MenuItem onClick={()=>{
                            dispatch(dispatchers.COPIAR_ATRIBUTOS_VACIOS({
                                forPk:relAtr, 
                                iRelPre:props.iRelPre,
                            }))
                            setMenuCambioAtributos(null)
                        }}>
                            <ListItemText style={{color:PRIMARY_COLOR}}>
                                Copiar el resto de los atributos vacíos
                            </ListItemText>
                        </MenuItem>
                        <MenuItem onClick={()=>{
                            dispatch(dispatchers.COPIAR_ATRIBUTOS({
                                forPk:relAtr, 
                                iRelPre:props.iRelPre,
                            }))
                            setMenuCambioAtributos(null)
                        }}>
                            <ListItemText style={{color:SECONDARY_COLOR}}>
                                Anular el cambio pisando los valores distintos
                            </ListItemText>
                        </MenuItem>
                    </>
                :null}
                <MenuItem onClick={()=>{
                    dispatch(dispatchers.BLANQUEAR_ATRIBUTOS({
                        forPk:relAtr, 
                        iRelPre:props.iRelPre,
                    }))
                    setMenuCambioAtributos(null)
                }}>
                    <ListItemText style={{color:SECONDARY_COLOR}}>
                        Blanquear atributos
                    </ListItemText>
                </MenuItem>
            </Menu>
        </>
    )
};

function strNumber(num:number|null):string{
    var str = num==null ? "" : num.toString();
    if(/[.,]\d$/.test(str)){
        str+="0";
    }
    return str;
}

function numberElement(num:number|null):JSX.Element{
    var str=strNumber(num);
    var element=null;
    str.replace(/^([^.,]*)([.,]\d+)?$/, function(_, left:string, right:string){
        element = <span>{left}<span style={{fontSize:'80%'}}>{right}</span></span>;
        return '';
    });
    return element||<span>-</span>;
}

var FakeButton = (props:{children:React.ReactChild}) =>
    <div className="fakeButton">
        {props.children}
    </div>

var ObsPrecio = (props:{inputIdPrecio:string, relPre:RelPre, iRelPre:number, razonPositiva:boolean, onSelection:()=>void})=> {
    const {inputIdPrecio, relPre, razonPositiva, iRelPre} = props;
    const dispatch = useDispatch();
    const [dialogoObservaciones, setDialogoObservaciones] = useState<boolean>(false);
    const [observacionAConfirmar, setObservacionAConfirmar] = useState<string|null>(relPre.comentariosrelpre);
    return <>
        <Button disabled={!razonPositiva} color="primary" variant="outline" tiene-observaciones={relPre.comentariosrelpre?'si':'no'} onClick={()=>{
            props.onSelection();
            setDialogoObservaciones(true)
        }}>
            {relPre.comentariosrelpre||'obs'}
        </Button>
        <Dialog
            open={dialogoObservaciones}
            onClose={()=>{
                setDialogoObservaciones(false)
                setObservacionAConfirmar(relPre.comentariosrelpre);
            }}
        >
            <DialogTitle id="alert-dialog-title-obs">{"Observaciones del precio"}</DialogTitle>
            <DialogContent>
                <DialogContentText id="alert-dialog-description-obs">
                    <EditableTd
                        autoFocus={true}
                        hasError={false}
                        inputId={inputIdPrecio+"_comentarios"}
                        disabled={false}
                        placeholder={"agregar observaciones"}
                        className="observaciones"
                        value={observacionAConfirmar}
                        onUpdate={value=>{
                            setObservacionAConfirmar(value);
                        }} 
                        dataType="text"
                    />
                </DialogContentText>
            </DialogContent>
            <DialogActions>
                <Button onClick={()=>{
                    setObservacionAConfirmar(relPre.comentariosrelpre)
                    setDialogoObservaciones(false)
                }} color="danger" variant="outline">
                    Descartar cambio
                </Button>
                <Button onClick={()=>{
                    dispatch(dispatchers.SET_COMENTARIO_PRECIO({
                        forPk:relPre, 
                        iRelPre: iRelPre,
                        comentario:observacionAConfirmar,
                    }));
                    setDialogoObservaciones(false)
                }} color="primary" variant="contained">
                    Guardar
                </Button>
            </DialogActions>
        </Dialog>
    </>
}

var TipoPrecio = (props:{inputIdPrecio:string, relPre:RelPre, iRelPre:number, razonPositiva:boolean, onSelection:()=>void})=> {
    const {inputIdPrecio, relPre, razonPositiva, iRelPre} = props;
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<Element|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    var esNegativo = relPre.tipoprecio && !estructura.tipoPrecio[relPre.tipoprecio].espositivo;
    const dispatch = useDispatch();
    return <>
        <div className="flechaTP" button-container="yes" es-repregunta={relPre.repregunta?"yes":"no"}>
            {relPre.repregunta?
                <RepreguntaIcon/>
            :((puedeCopiarTipoPrecio(estructura, relPre))?
                <Button disabled={!razonPositiva} color="danger" variant="outline" onClick={ () => {
                    props.onSelection();
                    if(tpNecesitaConfirmacion(estructura, relPre,relPre.tipoprecioanterior!)){
                        setTipoDePrecioNegativoAConfirmar(relPre.tipoprecioanterior);
                        setMenuConfirmarBorradoPrecio(true)
                    }else{
                        dispatch(dispatchers.COPIAR_TP({forPk:relPre, iRelPre:iRelPre}));
                    }
                }}>
                    {FLECHATIPOPRECIO}
                </Button>
                :'')
            }
        </div>
        <div className="tipo-precio" button-container="yes">
            <Button disabled={!razonPositiva} color={esNegativo?"danger":"primary"} variant="outline" onClick={event=>{
                props.onSelection();
                setMenuTipoPrecio(event.currentTarget)
            }}>
                {razonPositiva && relPre.tipoprecio || "\u00a0"}
            </Button>
        </div>
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
                            tipoprecio:tpDef.tipoprecio
                        }))
                        dispatch(dispatchers.SET_FOCUS({nextId:!relPre.precio && estructura.tipoPrecio[tpDef.tipoprecio].espositivo?inputIdPrecio:false}))
                    }
                }}>
                    <ListItemText style={{color:color, maxWidth:'30px'}}>{tpDef.tipoprecio}&nbsp;</ListItemText>
                    <ListItemText style={{color:color}}>&nbsp;{tpDef.nombretipoprecio}</ListItemText>
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
                }} color="primary" variant="outline">
                    No borrar
                </Button>
                <Button onClick={()=>{
                    dispatch(dispatchers.SET_TP({
                        forPk:relPre, 
                        iRelPre: props.iRelPre,
                        tipoprecio:tipoDePrecioNegativoAConfirmar
                    }))
                    setMenuConfirmarBorradoPrecio(false)
                }} color="danger" variant="outline">
                    Borrar precio y atributos
                </Button>
            </DialogActions>
        </Dialog>
    </>
}

var PreciosRow = React.memo(function PreciosRow(props:{
    style:Styles,
    relPre:RelPre, iRelPre:number,
    hasSearchString:boolean, allForms:boolean, esPrecioActual:boolean,
    inputIdPrecio:string, inputIdProximo:string|null, razonPositiva:boolean, compactar:boolean,
    isScrolling:boolean
}){
    const {hasSearchString, allForms, esPrecioActual, inputIdPrecio} = props;
    const [render4scroll, setRender4scroll] = useState(props.isScrolling);
    useEffect(function(){
        if(!props.isScrolling){
            setRender4scroll(false);
        }
    }, [props.isScrolling]);
    const relPre = props.relPre;
    const dispatch = useDispatch();
    const inputIdAtributos = relPre.atributos.map((relAtr)=>inputIdPrecio+'-'+relAtr.atributo);
    const productoDef:Producto = estructura.productos[relPre.producto];
    const cantidadMesesBadgeStyles = {backgroundColor:'#dddddd', color: "#000000"};
    const prodDestacadoBadgeStyle = {backgroundColor:'#b8dbed', color: "#000000"};
    const comentariosAnalistaBadgeStyles = {backgroundColor:COLOR_ADVERTENCIAS};
    const {color: colorAdv, tieneAdv} = controlarPrecio(relPre, estructura, esPrecioActual);
    const precioAnteriorAMostrar = numberElement(relPre.precioanterior || relPre.ultimoprecioinformado);
    const chipColor = (relPre.tipoprecioanterior && estructura.tipoPrecio[relPre.tipoprecioanterior].espositivo?
        null
    :
        (relPre.tipoprecioanterior == "N"?
            "#76bee4"
        :
            (relPre.tipoprecioanterior=='S' && relPre.sinpreciohace4meses?
                "#66b58b"
            :    
                '#FFFFFF'
            )
        )
    );
    const chipTextColor = chipColor=='#FFFFFF'?'#000000':'#FFFFFF';
    const badgeCondition = !relPre.precioanterior && relPre.ultimoprecioinformado;
    var compactar = props.compactar;
    var handleSelection = function handleSelection(relPre:RelPre, hasSearchString:boolean, allForms:boolean, inputId: string | null, compactar:boolean, inputIdPrecio:string){
        if(hasSearchString || allForms || compactar){
            dispatch(dispatchers.SET_QUE_VER({queVer: 'todos', informante: relPre.informante, formulario: relPre.formulario, allForms: false, searchString:'', compactar:false}));
            dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relPre.informante, formulario:relPre.formulario}));
            dispatch(dispatchers.SET_FOCUS({nextId:inputId || inputIdPrecio}))
        }
    }
    return (
        <div style={props.style} className="caja-relpre" es-positivo={relPre.tipoprecio == null ? (relPre.cambio=='C'?'si':'maso'):(estructura.tipoPrecio[relPre.tipoprecio].espositivo?'si':'no')}>
            <div className="caja-producto" id={'caja-producto-'+inputIdPrecio}>
                <div className="producto">{productoDef.nombreproducto}</div>
                <div className="observacion">{relPre.observacion==1?"":relPre.observacion.toString()}</div>
                {!compactar?
                    <>
                        <div className="especificacion">
                            <Badge
                                badgeContent={productoDef.destacado?"":null}
                                color={prodDestacadoBadgeStyle.color}
                                backgroundColor={prodDestacadoBadgeStyle.backgroundColor}
                                style={{top: 0, right:0, zIndex:-1}}
                            >
                                <span>{productoDef.especificacioncompleta}</span>
                            </Badge>
                        </div>
                        {!!relPre.comentariosrelpre_1 && relPre.esvisiblecomentarioendm_1?
                            <div className="comentario-analista">
                                <Badge
                                    badgeContent=""
                                    fullWidth={false}
                                    style={{top: 6, right: -10, zIndex:-1}}
                                    variant="dot"
                                    backgroundColor={comentariosAnalistaBadgeStyles.backgroundColor}
                                >
                                    <span>{relPre.comentariosrelpre_1}</span>
                                </Badge>
                            </div>
                            :null
                        }
                    </>
                    :null}
            </div>
            <div className="caja-precios">
                <div className="encabezado">
                    <div className="observaciones" button-container="yes">
                        {render4scroll?
                            <FakeButton>
                                {relPre.comentariosrelpre||'obs'}
                            </FakeButton>
                        :
                            <ObsPrecio 
                                inputIdPrecio={inputIdPrecio}
                                relPre={relPre} 
                                iRelPre={props.iRelPre}
                                razonPositiva={props.razonPositiva}
                                onSelection={()=>handleSelection(relPre, hasSearchString, allForms, null, compactar, inputIdPrecio)}
                            />
                        }
                    </div>
                    <div className="tipo-precio-anterior">{relPre.tipoprecioanterior}</div>
                    <div className="precio-anterior" precio-anterior style={{width: "100%", overflow: badgeCondition?'unset':'hidden'}}>
                        {render4scroll?                                
                            <span>{precioAnteriorAMostrar}</span>
                        :
                        <Badge 
                            backgroundColor={cantidadMesesBadgeStyles.backgroundColor}
                            color={cantidadMesesBadgeStyles.color}
                            badgeContent={relPre.cantidadperiodossinprecio?relPre.cantidadperiodossinprecio.toString():null}
                        >
                            {chipColor?
                                <Chip style={{backgroundColor:chipColor, color:chipTextColor, width:"100%", fontSize: "1rem", minHeight:25}} label={precioAnteriorAMostrar || "-"}/>
                            :
                                <span>{precioAnteriorAMostrar}</span>
                            }
                        </Badge>
                        }
                    </div>
                    {!render4scroll?<>
                        <TipoPrecio
                            inputIdPrecio={inputIdPrecio}
                            relPre={relPre} 
                            iRelPre={props.iRelPre}
                            razonPositiva={props.razonPositiva}
                            onSelection={()=>handleSelection(relPre, hasSearchString, allForms, null, compactar, inputIdPrecio)}
                        />
                        <EditableTd 
                            borderBottomColor={PRIMARY_COLOR}
                            borderBottomColorError={colorAdv}
                            hasError={tieneAdv && props.razonPositiva}
                            inputId={inputIdPrecio} 
                            idProximo={props.inputIdProximo}
                            disabled={!props.razonPositiva || !puedeCambiarPrecioYAtributos(estructura, relPre)} 
                            placeholder={puedeCambiarPrecioYAtributos(estructura, relPre)?'$':undefined} 
                            className="precio" 
                            value={relPre.precio} 
                            onUpdate={value=>{
                                /*
                                if(!props.razonPositiva){
                                    console.log('SE DETECTÓ UN ONUPDATE en razón negativa');
                                    alert('SE DETECTÓ UN ONUPDATE en razón negativa');
                                }
                                */
                                dispatch(dispatchers.SET_PRECIO({
                                    forPk:relPre, 
                                    iRelPre: props.iRelPre,
                                    precio:value,
                                }));
                            }} 
                            dataType="number"
                            onFocus={()=>{
                                handleSelection(relPre, hasSearchString, allForms, inputIdPrecio, compactar, inputIdPrecio);
                            }}
                        />
                    </>
                    :null}                   
                </div>
                {!render4scroll?
                <div className="atributos">
                    {!compactar?
                        relPre.atributos.map((relAtr, index)=>
                            <AtributosRow key={relPre.producto+'/'+relPre.observacion+'/'+relAtr.atributo}
                                relPre={relPre}
                                iRelPre={props.iRelPre}
                                relAtr={relAtr}
                                inputId={inputIdAtributos[index]}
                                inputIdPrecio={inputIdPrecio}
                                idProximoAtributo={index<relPre.atributos.length-1?inputIdAtributos[index+1]:null}
                                idProximoPrecio={props.inputIdProximo}
                                primerAtributo={index==0}
                                cantidadAtributos={relPre.atributos.length}
                                ultimoAtributo={index == relPre.atributos.length-1}
                                onSelection={()=>handleSelection(relPre,hasSearchString,allForms, inputIdAtributos[index], compactar, inputIdPrecio)}
                                razonPositiva={props.razonPositiva}
                            />
                        )
                    :null}
                </div>
                :null}
            </div>
        </div>
    );
}, areEqual)

function DetalleFiltroObservaciones(_props:{}){
    const {queVer} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    return <>
        {queVer == 'pendientes'? <Typography variant="h5" className="titulo-pendientes">mostrando observaciones pendientes <ICON.CheckBoxOutlineBlankOutlined /> </Typography>:(
            queVer == 'advertencias'? <Typography variant="h5" className="titulo-advertencias">mostrando observaciones con advertencias <ICON.Warning /> </Typography>:(
                null
            )
        )}
    </>
}

/* CANDIDATO */
const IndexedPreciosRow = /*React.memo*/(({ data, index, isScrolling, style }: {data: any, index:number, isScrolling:boolean, style:Styles}) => {
    var {items, observaciones, idActual, razonPositiva, allForms, searchString, compactar} = data;
    var item = items[index];
    var iRelPre = item.iRelPre;
    var relPre = observaciones[iRelPre];
    var inputIdPrecio = relPre.producto+'-'+relPre.observacion;
    var relPreProx = index<items.length-1 ? observaciones[items[index+1].iRelPre] : null;  
    var inputIdProximo = relPreProx != null ? relPreProx.producto+'-'+relPreProx.observacion : null;
    return <PreciosRow 
        style={style}
        key={relPre.producto+'/'+relPre.observacion}
        relPre={relPre}
        iRelPre={Number(iRelPre)}
        hasSearchString={!!searchString}
        isScrolling={isScrolling}
        allForms={allForms}
        inputIdPrecio={inputIdPrecio}
        inputIdProximo={inputIdProximo}
        esPrecioActual={!!idActual && idActual.startsWith(inputIdPrecio)}
        razonPositiva={razonPositiva}
        compactar={compactar}
    />
}/*,areEqual*/);

type Style4Render = {top:number, left:number, height:number, width:string, position:'fixed'|'relative'|'absolute'};

function VariableSizeList(props:{
    width:number|string, 
    height:number,
    itemCount:number, 
    itemSize:(i:number)=>number,
    useIsScrolling:boolean,
    itemData:any,
    children:(props:{data: any, index:number, isScrolling:boolean, style:Style4Render}) => JSX.Element
}){
    var rowFun=props.children;
    var heightSum=0;
    var lista:{style:Style4Render, isScrolling:boolean}[] = new Array(props.itemCount).fill(true).map((_, i:number)=>{
        var height = props.itemSize(i);
        var top = heightSum;
        heightSum+=height;
        return {
            style:{
                top,
                left:0,
                height,
                width:'100%',
                position:'absolute',
            },
            isScrolling:heightSum-window.scrollY>1500 || top+height<window.scrollY
        }
    });
    var [ultimoTop, setUltimoTop]=useState(-99999);
    var calculateList=function(){
        if(ultimoTop!=window.scrollY){
            setUltimoTop(window.scrollY);
            lista = lista.map(nodo=>({...nodo, isScrolling: nodo.isScrolling && (nodo.style.top-window.scrollY>1500 || nodo.style.top+nodo.style.height<window.scrollY)}));
        }
    };
    useEffect(function(){
        var interval=setInterval(calculateList,1000);
        return function(){
            clearInterval(interval);
        }
    })
    return <div style={{height:heightSum, width:props.width, position:'relative', top:0, left:0}} >
        {lista.length?lista.map(function(node, i){
            var x=rowFun({data:props.itemData, index:i, isScrolling:node.isScrolling, style:node.style});
            return x;
            // return rowFun({data:props.itemData, index:i, isScrolling:node.isScrolling, style:node.style});
        }):<div>cargando</div>}
    </div>
}

// function isNotNull<T>(value:T): T is not null{
//     return value != null;
// }

function RelevamientoPrecios(props:{
    relVis:RelVis,
    observaciones: RelPre[]
    razonPositiva:boolean,
    compactar: boolean,
}){
    const {queVer, searchString, allForms, idActual, observacionesFiltradasIdx, observacionesFiltradasEnOtrosIdx, letraGrandeFormulario} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const dispatch = useDispatch();
    var cantidadResultados = observacionesFiltradasIdx.length;
    const getItemSize = (index:number) => {
        var iRelPre = observacionesFiltradasIdx[index].iRelPre;
        var relPre = props.observaciones[iRelPre];
        return props.compactar?
            (letraGrandeFormulario?75:60) + 25 * Math.floor(estructura.productos[relPre.producto].nombreproducto.length / 19)
        :
        (letraGrandeFormulario?75:60)+Math.max(
                relPre.atributos.reduce(
                    (acum,relAtr)=>Math.ceil((Math.max(
                        (relAtr.valoranterior||'').toString().length,
                        (relAtr.valor||'').toString().length,
                        (estructura.atributos[relAtr.atributo].nombreatributo?.length*8/16)
                    )+1)/8)*(letraGrandeFormulario?60:45)+acum,0
                ), 
                estructura.productos[relPre.producto].especificacioncompleta?.length*(letraGrandeFormulario?2:1.5)
            );
    } 
       
    const createItemData = memoize(
        (
            items: {iRelPre: number}[], 
            observaciones:RelPre[], 
            idActual: string|null, 
            razonPositiva:boolean, 
            allForms: boolean, 
            searchString: string, 
            compactar: boolean
        ) =>     
        ({
            items,
            observaciones,
            idActual,
            razonPositiva,
            allForms,
            searchString,
            compactar
        })
    );
    const itemData = createItemData(observacionesFiltradasIdx, props.observaciones, idActual, props.razonPositiva, allForms, searchString, props.compactar);
    
    return <div className="informante-visita">
        {cantidadResultados?
            <VariableSizeList
                useIsScrolling 
                height={900}
                itemCount={observacionesFiltradasIdx.length}
                itemData={itemData}
                itemSize={getItemSize}
                width={"100%"}
            >
                {IndexedPreciosRow}
            </VariableSizeList>
        :(observacionesFiltradasEnOtrosIdx.length==0?
            <div>No hay</div>
        :null)
        }
        {
            observacionesFiltradasEnOtrosIdx.length>0?
                <div className="zona-degrade">
                    <Button className="boton-hay-mas" color="secondary" variant="outline"
                        onClick={()=>{
                            dispatch(dispatchers.SET_QUE_VER({queVer, informante: props.relVis.informante, formulario: props.relVis.formulario, allForms: true, searchString, compactar: props.compactar}));
                        }}
                    >ver más {queVer} en otros formularios</Button>
                    {observacionesFiltradasEnOtrosIdx.map(({iRelPre}, i) => {
                        var relPre = props.observaciones[iRelPre];
                        return i<10?
                        <Typography 
                            key={relPre.producto+'/'+relPre.observacion}
                        >
                            {estructura.productos[relPre.producto].nombreproducto} {relPre.observacion>1?relPre.observacion.toString():''}
                        </Typography>:null
                    })}
                </div>
            :
            <div className="zona-degrade">
                <Typography>Hay más observaciones en otros formularios</Typography>
            </div>
        }
    </div>;
}

function RazonFormulario(props:{relVis:RelVis, relInf:RelInf}){
    const relVis = props.relVis;
    const razones = estructura.razones;
    const {verRazon} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const [menuRazon, setMenuRazon] = useState<Element|null>(null);
    const [razonAConfirmar, setRazonAConfirmar] = useState<{razon:number|null}>({razon:null});
    const [menuConfirmarRazon, setMenuConfirmarRazon] = useState<boolean>(false);
    var cantObsConPrecio = props.relInf.observaciones.filter((relPre:RelPre)=>relPre.formulario == relVis.formulario && !!relPre.precio).length;
    const [confirmarCantObs, setConfirmarCantObs] = useState(null);
    const dispatch = useDispatch();
    const onChangeFun = function <TE extends React.ChangeEvent>(event:TE){
        //@ts-ignore en este caso sabemos que etarget es un Element que tiene value.
        var valor = event.target.value;
        setConfirmarCantObs(valor);
    }
    return (
        verRazon?
        <div className="razon-formulario">
            <div>
                <Button 
                    onClick={event=>setMenuRazon(event.currentTarget)} 
                    color={relVis.razon && !estructura.razones[relVis.razon].espositivoformulario?"danger":"primary"} 
                    variant="outline"
                    style={{width:'90%', maxWidth:70}}
                >
                    {relVis.razon}
                </Button>
            </div>
            <div>{relVis.razon?razones[relVis.razon].nombrerazon:null}</div>
            <EditableTd
                hasError={false}
                placeholder="sin comentarios"
                disabled={false}
                className="comentarios-razon"
                dataType={"text"}
                value={relVis.comentarios}
                inputId={relVis.informante+'f'+relVis.formulario}
                onUpdate={value=>{
                    dispatch(dispatchers.SET_COMENTARIO_RAZON({forPk:relVis, comentarios:value}));
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
                            dispatch(dispatchers.SET_RAZON({forPk:relVis, razon:index}));
                        }
                        setMenuRazon(null)
                    }}>
                        <ListItemText style={{color:color, maxWidth:'30px'}}>&nbsp;{index}</ListItemText>
                        <ListItemText style={{color:color}}>&nbsp;{razon.nombrerazon}</ListItemText>
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
                <DialogTitle id="alert-dialog-title-rn">{`Confirmación de razón negativa para formulario ${relVis.formulario}`}</DialogTitle>
                <DialogContent>
                    <DialogContentText id="alert-dialog-description-rn">
                        <div>
                            Eligió la razón de no contacto {razonAConfirmar.razon?`${razonAConfirmar.razon} ${estructura.razones[razonAConfirmar.razon].nombrerazon}`:''}. 
                            Se {cantObsConPrecio==1?'borrará un precio':`borrarán ${cantObsConPrecio} precios`} ingresados.
                        </div>
                        <div>
                            Confirme la acción ingresando la cantidad de precios que se van a borrar: 
                        </div>
                        <TextField
                            hasError={false}
                            value={confirmarCantObs}
                            onChange={onChangeFun}
                        />
                    </DialogContentText>
                </DialogContent>
                <DialogActions>
                    <Button onClick={()=>{
                        setMenuConfirmarRazon(false)
                    }} color="primary" variant="outline">
                        No borrar
                    </Button>
                    <Button disabled={confirmarCantObs!=cantObsConPrecio} onClick={()=>{
                        dispatch(dispatchers.SET_RAZON({forPk:relVis, razon:razonAConfirmar.razon}));
                        setMenuConfirmarRazon(false)
                    }} color="danger" variant="outline">
                        Proceder borrando
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
        :null
    );
}

function FormularioVisitaWrapper(props:{relVisPk: RelVisPk}){
    const {queVer, searchString, compactar, allForms, letraGrandeFormulario} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    const dispatch = useDispatch();
    const hdr = useSelector((hdr:HojaDeRuta)=>hdr);
    const relInf = hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!;
    const relVis = relInf.formularios.find(relVis=>relVis.formulario==props.relVisPk.formulario)!;
    const formularios = hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!.formularios;
    const [open, setOpen] = React.useState<boolean>(false);
    const handleDrawerOpen = () => {
        setOpen(true);
    };
    const handleDrawerToggle = () => {
        setOpen(!open);
    };
    const initialWidth = letraGrandeFormulario?80:70;
    const openedWidth = letraGrandeFormulario?350:320;
    const buttonGroupStyle = letraGrandeFormulario?{}:{height:38};
    return <>
        <AppBar
            style={TOOLBAR_STYLE}
            position="fixed"
            shift={openedWidth}
            shiftCondition={open}
        >
            {open?null:        
                <IconButton
                    color="inherit"
                    aria-label="open drawer"
                    onClick={handleDrawerOpen}
                    edge="start"
                >
                    <MenuIcon/>
                </IconButton>
            }
            <Typography variant="h6">
               {`inf ${props.relVisPk.informante}`}
           </Typography>
           <Grid item>
                <ButtonGroup style={buttonGroupStyle}>
                    <Button onClick={()=>{
                        dispatch(dispatchers.SET_OPCION({variable:'compactar',valor:!compactar}))
                    }}>
                        <ICON.FormatLineSpacing />
                    </Button>
               </ButtonGroup>
               <ButtonGroup style={buttonGroupStyle}>
                    <Button onClick={()=>{
                        dispatch(dispatchers.SET_QUE_VER({queVer:'todos', informante: relVis.informante, formulario: relVis.formulario, allForms, searchString, compactar}));
                    }} className={queVer=='todos'?'boton-seleccionado-todos':'boton-selecionable'}>
                        <ICON.CheckBoxOutlined />
                    </Button>
                    <Button onClick={()=>{
                        dispatch(dispatchers.SET_QUE_VER({queVer:'pendientes', informante: relVis.informante, formulario: relVis.formulario, allForms, searchString, compactar}));
                    }} className={queVer=='pendientes'?'boton-seleccionado-pendientes':'boton-selecionable'}>
                        <ICON.CheckBoxOutlineBlankOutlined />
                    </Button>
                    <Button onClick={()=>{
                        dispatch(dispatchers.SET_QUE_VER({queVer:'advertencias', informante: relVis.informante, formulario: relVis.formulario, allForms, searchString, compactar}));
                    }} className={queVer=='advertencias'?'boton-seleccionado-advertencias':'boton-selecionable'}>
                        <ICON.Warning />
                    </Button>
                </ButtonGroup>
            </Grid>
            <SearchInput
                value={searchString}
                onChange={(event)=>{
                    dispatch(dispatchers.SET_QUE_VER({allForms, queVer, searchString:event.target.value, informante: relVis.informante, formulario:relVis.formulario, compactar}))
                    window.scroll({behavior:'auto', top:0, left:0})
                }}
                onReset={()=>{
                    dispatch(dispatchers.SET_QUE_VER({allForms, queVer, searchString:'', informante: relVis.informante, formulario:relVis.formulario, compactar}))
                    window.scroll({behavior:'auto', top:0, left:0})
                }}
            />
        </AppBar>
        <Drawer
            initialWidth={initialWidth}
            openedWidth={openedWidth}
            open={open}
        >
            <div style={{
                display: "flex",
                padding: "8px 8px",
                justifyContent: "flex-end",
            }}>
                <IconButton onClick={handleDrawerToggle}><MenuIcon /></IconButton>
            </div>
            <List>
                <ListItem className="flecha-volver-hdr" onClick={()=>
                    dispatch(dispatchers.UNSET_FORMULARIO_ACTUAL({}))
                }>
                    <ListItemIcon><DescriptionIcon/></ListItemIcon>
                    <ListItemText primary="Volver a hoja de ruta"/>
                </ListItem>
                {formularios.map((relVis:RelVis) => (
                    <ListItem key={relVis.formulario} selected={relVis.formulario==props.relVisPk.formulario && !allForms} onClick={()=>{
                        setOpen(false);
                        dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relVis.informante, formulario:relVis.formulario}));
                    }}>
                        <ListItemIcon>{numberElement(relVis.formulario)}</ListItemIcon>
                        <ListItemText primary={estructura.formularios[relVis.formulario].nombreformulario} />
                    </ListItem>
                ))}
            </List>
        </Drawer>
    </>
}

function FormularioVisita(props:{relVisPk: RelVisPk}){
    const {compactar, /*posFormularios, */ idActual} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    /*useEffect(() => {
        const pos = posFormularios.find((postision)=>postision.formulario==props.relVisPk.formulario);
        const prevScrollY = pos?pos.position:0;
        function registrarPosicionIntraformulario(){
            if(prevScrollY != window.scrollY){
                dispatch(dispatchers.SET_FORM_POSITION({formulario:props.relVisPk.formulario,position:window.scrollY}))
            }
        }
        if(queVer=='todos' && !compactar && !searchString && !allForms){
            window.scrollTo(0, prevScrollY);
            var interval = setInterval(registrarPosicionIntraformulario, 1000);            
            return function(){
                clearInterval(interval);
            }
        }else{
            window.scrollTo(0, 0);
            return function(){}
        }

    },[props.relVisPk, posFormularios, compactar, queVer, searchString]);
    */
    useEffect(() => {
        if(idActual){
            focusToId(idActual, {moveToElement:true});
        }
    }, [idActual]);
    const hdr = useSelector((hdr:HojaDeRuta)=>hdr);
    const relInf = hdr.informantes.find(relInf=>relInf.informante==props.relVisPk.informante)!;
    const relVis = relInf.formularios.find(relVis=>relVis.formulario==props.relVisPk.formulario)!;
    return (
        <div id="formulario-visita" className="menu-informante-visita" es-positivo={relVis.razon && estructura.razones[relVis.razon].espositivoformulario?'si':'no'}>
            <div style={{display:'flex'}}>
                <FormularioVisitaWrapper relVisPk={props.relVisPk} />
                <main style={{flexGrow: 1}}>
                    <DetalleFiltroObservaciones></DetalleFiltroObservaciones>
                    <RazonFormulario relVis={relVis} relInf={relInf}/>
                    <RelevamientoPrecios 
                        relVis={relVis}
                        observaciones={relInf.observaciones}
                        razonPositiva={!!relVis.razon && estructura.razones[relVis.razon].espositivoformulario}
                        compactar={compactar}
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

function FormulariosCols(props:{informante:RelInf, relVis:RelVis}){
    const opciones = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const errorStyles = {backgroundColor: COLOR_ERRORES, color:"white"};
    const advStyles = {backgroundColor: COLOR_ADVERTENCIAS, color:"white"};
    const pendentStyles = {backgroundColor: COLOR_PENDIENTES, color:"white"};
    const dispatch = useDispatch();
    const {mostrarColumnasFaltantesYAdvertencias} = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const informante = props.informante;
    const relVis = props.relVis;
    var misObservaciones = informante.observaciones.filter((relPre:RelPre)=>relPre.formulario == relVis.formulario);
    var cantPendientes = misObservaciones.filter((relPre:RelPre)=>precioEstaPendiente(relPre, relVis, estructura)).length;
    var cantAdvertencias = misObservaciones.filter((relPre:RelPre)=>precioTieneAdvertencia(relPre, relVis, estructura)).length;
    var cantErrores = misObservaciones.filter((relPre:RelPre)=>precioTieneError(relPre, relVis, estructura)).length;
    var todoListo = cantAdvertencias == 0 && cantPendientes == 0 && !opciones.mostrarColumnasFaltantesYAdvertencias && relVis.razon
    var numbersStyles : {textAlign:'right', paddingRight:string} = {
        textAlign: 'right',
        paddingRight: '15px'
    }
    var styles=cantErrores ? errorStyles : (cantAdvertencias ? advStyles : pendentStyles);
    var conBadge=cantErrores || cantAdvertencias || (cantPendientes < misObservaciones.length?cantPendientes:null)
    var formButton = <Button 
        fullwidth 
        variant={todoListo?"contained":"outline"} 
        color={todoListo?"success":"primary"}
        size="lg"
        className={"boton-ir-formulario"}
        onClick={()=>{
            dispatch(dispatchers.SET_FORMULARIO_ACTUAL({informante:relVis.informante, formulario:relVis.formulario}));
        }
    }>
        <span>{relVis.formulario} {estructura.formularios[relVis.formulario].nombreformulario} </span>
        <span className="special-right">
            {relVis.razon && !estructura.razones[relVis.razon].espositivoformulario ? 
                <ICON.RemoveShoppingCart /> 
            :(!cantPendientes && !!relVis.razon?
                    CHECK
                :
                    null
            )}
        </span>
    </Button>
    return(
        <>
            <TableCell>
                {mostrarColumnasFaltantesYAdvertencias?
                    formButton
                :
                    <Badge 
                        backgroundColor={styles.backgroundColor}
                        color={styles.color}
                        badgeContent={conBadge?conBadge.toString():null}
                    >{formButton}</Badge>
                }
            </TableCell>
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={numbersStyles}>{numberElement(misObservaciones.length)}</TableCell>:null}
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={{...numbersStyles, backgroundColor:cantPendientes?'#DDAAAA':'#AADDAA'}}>{cantPendientes?numberElement(cantPendientes):CHECK}</TableCell>:null}
            {mostrarColumnasFaltantesYAdvertencias?<TableCell style={{...numbersStyles, backgroundColor:cantAdvertencias?COLOR_ADVERTENCIAS:'none'}}>{cantAdvertencias?numberElement(cantAdvertencias):'-'}</TableCell>:null}
        </>
    )
}

function InformanteRow(props:{informante:RelInf}){
    const opciones = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const informante = props.informante;
    const contacto = estructura.informantes[informante.informante].contacto;
    const telcontacto = estructura.informantes[informante.informante].telcontacto;
    const web = estructura.informantes[informante.informante].web;
    const email = estructura.informantes[informante.informante].email;
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
                                    <div>{informante.informante} {informante.nombreinformante} 
                                        <span className="periodos-sin-informacion"> {informante.cantidad_periodos_sin_informacion>1?`(${informante.cantidad_periodos_sin_informacion})`:''}</span>
                                    </div>
                                    <div className='direccion-informante'>{estructura.informantes[informante.informante].direccion}</div>
                                    {contacto?<div className='contacto-informante'>{contacto}</div>:null}
                                    {telcontacto?<div className='telcontacto-informante'>{telcontacto}</div>:null}
                                    {web?<div className='web-informante'><a href={(web.startsWith('http') || web.startsWith('https')?"":"//")+web} target="_blank">{web}</a></div>:null}
                                    {email?<div className='email-informante'>{email}</div>:null}
                                </TableCell>
                            :null}
                            {opciones.letraGrandeFormulario?null:
                                <FormulariosCols informante={props.informante} relVis={relVis}/>
                            }
                        </TableRow>
                        {opciones.letraGrandeFormulario?
                            <TableRow key={relVis.informante+'/'+relVis.formulario+'_letra_grande'}>
                                <FormulariosCols informante={props.informante} relVis={relVis}/>
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

const useStylesButton = makeStyles({
    toolbarButtons: {
      marginLeft: 'auto',
    },
});

function PantallaInicial(_props:{}){
    const updateOnlineStatus = function(){
        setOnline(window.navigator.onLine);
    }
    const [online, setOnline] = useState(window.navigator.onLine);
    window.addEventListener('online',  updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    const classes = useStylesTable();
    const paragraphStyles={fontSize:"1.2rem", fontWeight:600, padding: "5px 10px"};
    return (
        <>
            <AppBar position="fixed" style={TOOLBAR_STYLE}>
                <Typography variant="h6">
                    IPCBA PWA - Dispositivo sin carga
                </Typography>
            </AppBar>
            <main>
                <Paper className={classes.root} style={{height:'600px', padding:"15px"}}>
                    <div className={classes.root}>
                        {online?
                            <>
                                <Typography component="p" style={paragraphStyles}>
                                    Sincronizar dispositivo
                                    <span style={{padding:'5px'}}>
                                        <Button
                                            color="primary"
                                            variant="contained"
                                            onClick={()=>{
                                                history.replaceState(null, '', `${location.origin+location.pathname}/../menu#i=dm2,sincronizar_dm2`);
                                                location.reload();   
                                            }}
                                        >
                                            <SyncAltIcon/>
                                        </Button>
                                    </span>
                                </Typography>
                            </>
                        :
                            <Typography component="p" style={paragraphStyles}>
                                No hay conexión a internet, por favor conécte el dispositivo a una red para sincronizar una hoja de ruta.
                            </Typography>
                        }
                    </div>
                </Paper>
            </main>
        </>
    );
}

function PantallaHojaDeRuta(_props:{}){
    useEffect(() => {
        window.scrollTo(0, posHdr)
        return function(){
            if(posHdr != window.scrollY){
                dispatch(dispatchers.SET_OPCION({variable:'posHdr',valor:window.scrollY}))
            }
        }
    });
    const hdr = useSelector((hdr:HojaDeRuta)=>(hdr));
    const {informantes, panel, tarea, encuestador, nombreencuestador, apellidoencuestador} = useSelector((hdr:HojaDeRuta)=>(hdr));
    const {letraGrandeFormulario, mostrarColumnasFaltantesYAdvertencias, posHdr, customDataMode} = useSelector((hdr:HojaDeRuta)=>(hdr.opciones));
    const classes = useStylesTable();
    const classesButton = useStylesButton();
    const dispatch = useDispatch();
    const appVersion = getCacheVersion();
    const stylesTableHeader:React.CSSProperties = {fontSize: "1.2rem", padding:"15px 0", textAlign:"center"};
    const updateOnlineStatus = function(){
        setOnline(window.navigator.onLine);
    }
    const [online, setOnline] = useState(window.navigator.onLine);
    const [mensajeDescarga, setMensajeDescarga] = useState<string|null>(null);
    const [descargaCompleta, setDescargaCompleta] = useState<boolean|null>(false);
    const [descargando, setDescargando] = useState<boolean|null>(false);
    window.addEventListener('online',  updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    return (
        <>
            <AppBar position="fixed" style={TOOLBAR_STYLE}>
                <Typography variant="h6">
                    Hoja de ruta - {appVersion}
                </Typography>
                <div className={classesButton.toolbarButtons}>
                    <IconButton
                        color="inherit"
                        onClick={()=>
                            dispatch(dispatchers.SET_OPCION({variable:'pantallaOpciones',valor:true}))
                        }
                    >
                        <SettingsIcon/>
                    </IconButton>
                    {online?
                        customDataMode?
                            <>
                                {isDirtyHDR()?
                                    <>
                                        <IconButton
                                            color="inherit"
                                            onClick={async ()=>{
                                                setMensajeDescarga('descargando, por favor espere...');
                                                setDescargando(true);
                                                var message = await devolverHojaDeRuta(hdr);
                                                setDescargando(false);
                                                if(message=='descarga completa'){
                                                    setDescargaCompleta(true);
                                                    await borrarDatosRelevamientoLocalStorage();
                                                    message+=', redirigiendo a grilla de relevamiento...';
                                                    setTimeout(function(){
                                                        location.reload();       
                                                    }, 3000)
                                                }
                                                setMensajeDescarga(message)
                                            }}
                                        >
                                            <SaveIcon/>
                                        </IconButton>
                                    </>
                                :
                                    <IconButton
                                        color="inherit"
                                        onClick={async ()=>{
                                            var message = await borrarDatosRelevamientoLocalStorage();
                                            if(message == 'ok'){
                                                location.reload();   
                                            }else{
                                                setMensajeDescarga(message)
                                            }
                                        }}
                                    >
                                        <ExitToAppIcon/>
                                    </IconButton>
                                }
                                <Dialog
                                    open={!!mensajeDescarga}
                                    //hace que no se cierre el mensaje
                                    onClose={()=>setMensajeDescarga(mensajeDescarga)}
                                    aria-labelledby="alert-dialog-title"
                                    aria-describedby="alert-dialog-description"
                                >
                                    <DialogTitle id="alert-dialog-title">Información de descarga</DialogTitle>
                                    <DialogContent>
                                        <DialogContentText id="alert-dialog-description">
                                            {mensajeDescarga}{descargando?<CircularProgress />:null}
                                        </DialogContentText>
                                    </DialogContent>
                                    <DialogActions>
                                        {descargando?
                                            null
                                        :
                                            <Button 
                                                onClick={()=>{
                                                    if(descargaCompleta){
                                                        location.reload()
                                                    }else{
                                                        setMensajeDescarga(null)
                                                    }
                                                }} 
                                                color="primary" 
                                                variant="contained"
                                            >
                                                Cerrar
                                            </Button>
                                        }
                                    </DialogActions>
                                </Dialog>
                            </>
                        :
                            <Button
                                color="inherit"
                                onClick={()=>{
                                    history.replaceState(null, '', `${location.origin+location.pathname}/../menu#i=dm2,sincronizar_dm2`);
                                    location.reload();   
                                }}
                            >
                                <ExitToAppIcon/>
                            </Button>
                    :null}
                </div>
            </AppBar>
            <main>
                <Paper className={classes.root}>
                    <Typography component="p" style={{fontSize:"1.2rem", fontWeight:600, padding: "5px 10px"}}>
                        Panel: {panel} Tarea: {tarea} Encuestador/a: {apellidoencuestador}, {nombreencuestador} ({encuestador})
                    </Typography>
                    <Table className="hoja-ruta" style={{borderTopStyle: "groove"}}>
                        <colgroup>
                            {mostrarColumnasFaltantesYAdvertencias?
                                letraGrandeFormulario?
                                    <>
                                        <col style={{width:"64%"}}/>
                                        <col style={{width:"12%"}}/>
                                        <col style={{width:"12%"}}/>
                                        <col style={{width:"12%"}}/>
                                    </>
                                :
                                    <>
                                        <col style={{width:"25%"}}/>
                                        <col style={{width:"42%"}}/>
                                        <col style={{width:"11%"}}/>
                                        <col style={{width:"11%"}}/>
                                        <col style={{width:"11%"}}/>
                                    </>
                            :
                                letraGrandeFormulario?
                                    <col style={{width:"100%"}}/>
                                :
                                    <>
                                        <col style={{width:"34%"}}/>
                                        <col style={{width:"66%"}}/>
                                    </>
                            }
                        </colgroup>      
                        <TableHead style={{fontSize: "1.2rem"}}>
                            <TableRow className="hdr-tr-informante">
                                {letraGrandeFormulario || !mostrarColumnasFaltantesYAdvertencias?null:<TableCell style={{...stylesTableHeader,...{textAlign:'left', paddingLeft:"10px"}}}>informante</TableCell>}
                                {mostrarColumnasFaltantesYAdvertencias?<TableCell style={{...stylesTableHeader,...{textAlign:'left', paddingLeft:"10px"}}}>formulario</TableCell>:null}
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
    const {letraGrandeFormulario, mostrarColumnasFaltantesYAdvertencias, customDataMode} = useSelector((hdr:HojaDeRuta)=>hdr.opciones)
    const dispatch = useDispatch();
    const [mensajeBorrar, setMensajeBorrar] = useState<string|null>(null);
    const [habilitarBorrar, setHabilitarBorrar] = useState<boolean>(false);
    const [online, setOnline] = useState(window.navigator.onLine);
    const updateOnlineStatus = function(){
        setOnline(window.navigator.onLine);
    }
    window.addEventListener('online',  updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);
    const FRASE_BORRADO = "no guardar";
    return (
        <>
            <AppBar position="fixed" style={TOOLBAR_STYLE}>
                <IconButton
                    color="inherit"
                    aria-label="open drawer"
                    edge="start"
                    onClick={()=>
                        dispatch(dispatchers.SET_OPCION({variable:'pantallaOpciones',valor:false}))
                    }
                >
                    <ChevronLeftIcon />
                </IconButton>
                <Typography variant="h6">Opciones del dispositivo móvil</Typography>
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
                {online && customDataMode && isDirtyHDR()?
                    <Typography>
                        <Button
                            color="danger"
                            variant="contained"
                            onClick={()=>{
                                setMensajeBorrar(`Si continua perderá los datos que haya ingresado en el dispositivo 
                                desde la última vez que la descargó. Los datos descargados previamente 
                                (que ya están en la base de datos) se conservan. Escriba "${FRASE_BORRADO}"`
                                )
                            }}
                        >
                            <DeleteIcon/> Descartar cambios hoja de ruta
                        </Button>
                        <Dialog
                            open={!!mensajeBorrar}
                            //hace que no se cierre el mensaje
                            onClose={()=>setMensajeBorrar(mensajeBorrar)}
                            aria-labelledby="alert-dialog-title"
                            aria-describedby="alert-dialog-description"
                        >
                            <DialogTitle id="alert-dialog-title">Información de descarga</DialogTitle>
                            <DialogContent>
                                <DialogContentText id="alert-dialog-description">
                                    {mensajeBorrar}
                                </DialogContentText>
                                <TextField
                                    hasError={false}
                                    onChange={(event)=>
                                        setHabilitarBorrar(event.target.value.toLowerCase()==FRASE_BORRADO)
                                    }
                                />
                            </DialogContent>
                            <DialogActions>
                                <Button 
                                    onClick={()=>{
                                        setMensajeBorrar(null)
                                    }} 
                                    color="primary" 
                                    variant="outline"
                                >
                                    Cancelar
                                </Button>
                                <Button 
                                    onClick={async ()=>{
                                        setMensajeBorrar("descartando hoja de ruta...")
                                        var message = await borrarDatosRelevamientoLocalStorage();
                                        if(message == 'ok'){
                                            location.reload();   
                                        }else{
                                            setMensajeBorrar(message)
                                        }
                                    }} 
                                    color="danger" 
                                    variant="outline"
                                    disabled={!habilitarBorrar}
                                >
                                    No guardar
                                </Button>
                            </DialogActions>
                        </Dialog>
                    </Typography>
                :
                    null
                }
                {online && !customDataMode?
                    <Button
                        color="primary"
                        variant="contained"
                        onClick={()=>{
                            history.replaceState(null, '', `${location.origin+location.pathname}/../login#path=/dm#inst=1`);
                            location.reload();   
                    }}
                    >
                        Actualizar aplicación
                        <SystemUpdateIcon/>
                    </Button>
                :
                    null
                }
            </main>
        </>
    )
}

export function OpenedTabs(){
    const [tabs, setTabs] = useState(infoOpenedTabs.otherTabsNames);
    const updateTabsStatus = function(){
        setTabs(infoOpenedTabs.otherTabsNames);
    }
    useEffect(()=>{
        window.addEventListener('my-tabs',updateTabsStatus);
        return () => window.removeEventListener('my-tabs',updateTabsStatus);
    },[])
    return tabs?
        <div className="tab-counter tab-error">¡ATENCIÓN! Hay más de una ventana abierta. Se pueden perder datos: {tabs}</div>
    :
        <div className="tab-counter">✔</div>
}

function AppDmIPCOk(){
    const {relVisPk, letraGrandeFormulario, pantallaOpciones/*, refreshKey*/} = useSelector((hdr:HojaDeRuta)=>hdr.opciones);
    document.documentElement.setAttribute('pos-productos', letraGrandeFormulario?'arriba':'izquierda');
    if(relVisPk == undefined){
        if(pantallaOpciones){
            return <PantallaOpciones/>
        }else{
            return <PantallaHojaDeRuta/>
        }
    }else{
        return <FormularioVisita relVisPk={relVisPk}/>
    }
}

function ReseterForm(props:{onTryAgain:()=>void}){
    const dispatch = useDispatch();
    return <>
        <Button variant="outline"
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
                <Typography>{this.state.error instanceof Error ? this.state.error.message : 'unknown error'}</Typography>
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
            <style>
                {`
                    #main-top-bar{
                        display: none
                    }
                `}
            </style>
            <OpenedTabs/>
            <AppDmIPC/>
        </Provider>,
        document.getElementById('main_layout')
    )
}

function loadCSS(cssURL:string):Promise<void>{
    return new Promise(( resolve, reject )=>{
        var link = document.createElement( 'link' );
        link.rel  = 'stylesheet';
        link.href = cssURL;
        document.head.appendChild( link );
        link.onload = ()=>{ 
            resolve(); 
            console.log(`trae ${cssURL}`);
        };
        link.onerror=(err)=>{
            reject(new Error(`problema cargando estilo ${cssURL}`))
        }
    });
}

export async function dmHojaDeRuta(optsHdr:OptsHdr){
    const {store, estructura} = await dmTraerDatosHdr(optsHdr);
    var src = 'css/bootstrap.min.css'; //bootstrap 5.0.1
    try{
        await loadCSS(src);
    }catch(err){
        throw(err)
    }
    mostrarHdr(store, estructura);
}

export async function dmPantallaInicial(){
    ReactDOM.render(
        <PantallaInicial/>,
        document.getElementById('main_layout')
    )
}

if(typeof window !== 'undefined'){
    // @ts-ignore para hacerlo
    window.dmHojaDeRuta = dmHojaDeRuta;
    // @ts-ignore para hacerlo
    window.dmPantallaInicial = dmPantallaInicial;
}

//CONTROL DE PESTAÑAS
var allOpenedTabs:{[x:string]:number}={};
var infoOpenedTabs={
    allOpenedTabs,
    myId:'calculando...',
    otherTabsNames:''
}

function loadInstance(){
    var bc = new BroadcastChannel('contador');
    var myId=String.fromCodePoint(100+Math.floor(Math.random()*1000))+Math.floor(Math.random()*100)//+'-'+new Date().getTime();
    allOpenedTabs[myId]=1;
    infoOpenedTabs.myId=myId;
    var event = new Event('my-tabs');
    bc.onmessage=function(ev){
        if(ev.data.que=='soy'){
            if(!allOpenedTabs[ev.data.id]){
                allOpenedTabs[ev.data.id]=0;
            }
            allOpenedTabs[ev.data.id]++;
        }
        if(ev.data.que=='unload'){
            delete allOpenedTabs[ev.data.id];
        }
        if(ev.data.que=='load'){
            allOpenedTabs[ev.data.id]=1;
            bc.postMessage({que:'soy',id:myId});
        }
        infoOpenedTabs.otherTabsNames=likeAr(allOpenedTabs).filter((_,id)=>id!=myId).join(',');
        window.dispatchEvent(event);
    };
    bc.postMessage({que:'load',id:myId});
    window.dispatchEvent(event);
    window.addEventListener('unload',function(){
        bc.postMessage({que:'unload',id:myId});
        window.dispatchEvent(event);
    })
    //mostrarQuienesSomos();
}

window.addEventListener('load', function(){
    loadInstance()
})
//FIN CONTROL PESTAÑAS