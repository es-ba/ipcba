import * as React from "react";
import {TipoPrecio, Atributo, Producto, ProdAtr, Formulario, Estructura, RelVis, RelAtr, RelPre, RelPreProd} from "./dm-tipos";
import {useState, useRef, useEffect, useImperativeHandle, createRef, forwardRef} from "react";
import {changing, serie, deepFreeze} from "best-globals";
import * as likeAr from "like-ar";
import {Menu, MenuItem, ListItemText, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@material-ui/core";


const FLECHATIPOPRECIO="→";
const FLECHAATRIBUTOS="➡";

type Focusable = {
    focus:()=>void
    blur:()=>void
}

var tiposPrecioDef:TipoPrecio[]=[
    {tipoprecio:'P', descripcion:'Precio normal'   , positivo:true , predeterminado:true},
    {tipoprecio:'O', descripcion:'Oferta'          , positivo:true },
    {tipoprecio:'B', descripcion:'Bonificado'      , positivo:true },
    {tipoprecio:'S', descripcion:'Sin existencia'  , positivo:false},
    {tipoprecio:'N', descripcion:'No vende'        , positivo:false, copiable:true},
    {tipoprecio:'E', descripcion:'Falta estacional', positivo:false, copiable:true},
];

var tipoPrecio=likeAr.createIndex(tiposPrecioDef, 'tipoprecio');

var tipoPrecioPredeterminado = tiposPrecioDef.find(tp=>tp.predeterminado)!;

var atributos:{[a:number]:Atributo}={
    13:{
        atributo:13,
        nombreatributo:'Marca',
        escantidad:false,
        tipodato:'C'
    },
    16:{
        atributo:16,
        nombreatributo:'Gramaje',
        escantidad:true,
        tipodato:'N'
    },
    55:{
        atributo:55,
        nombreatributo:'Variante',
        escantidad:false,
        tipodato:'C'
    }
}

var productos:{[p:string]:Producto} = {
    P01:{
        producto:'P01',
        nombreproducto:'Lata de tomate',
        especificacioncompleta:'Lata de tomate perita enteros pelado de 120 a 140g neto',
        atributos:{
            13:{
                orden:1,
                normalizable:false,
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:true,
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
                normalizable:false,
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:true,
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
                normalizable:false,
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:3,
                normalizable:true,
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            },
            55:{
                orden:2,
                normalizable:true,
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,55,16]
    }
}

var formularios:{[f:number]:Formulario}={
    99:{
        formulario:99,
        nombreformulario:'Prueba',
        orden:99,
        productos:{
            P01:{
                orden:2,
                observaciones:2
            },
            P02:{
                orden:3,
                observaciones:1
            },
            P03:{
                orden:1,
                observaciones:1
            },
        },
        listaProductos:['P03','P01','P02']
    }
}

var razones={
    1:{escierredefinitivoinf:false, escierredefinitivofor:false}
}

var estructura:Estructura={
    tipoPrecio,
    razones,
    atributos,
    productos,
    formularios,
}

var formularioCorto:RelVis = {
    formulario:99,
    razon:1,
    comentarios:null,
    productos:{
        P01:{
            observaciones:{
                1:{
                    tipoprecioanterior:'P',
                    precioanterior:120,
                    tipoprecio:'O',
                    precio:130,
                    atributos:{
                        13:{valoranterior:'La campagnola', valor:null},
                        16:{valoranterior:'300', valor:null}
                    },
                    cambio: null
                },
                2:{
                    tipoprecioanterior:'P',
                    precioanterior:102,
                    tipoprecio:null,
                    precio:null,
                    atributos:{
                        13:{valoranterior:'Arcor', valor:null},
                        16:{valoranterior:'300', valor:null}
                    },
                    cambio: null
                }
            }
        },
        P02:{
            observaciones:{
                1:{
                    tipoprecioanterior:'P',
                    precioanterior:140,
                    tipoprecio:null,
                    precio:null,
                    atributos:{
                        13:{valoranterior:'La campagnola', valor:null},
                        16:{valoranterior:'300', valor:null}
                    },
                    cambio: null
                }
            }
        },
        P03:{
            observaciones:{
                1:{
                    tipoprecioanterior:'S',
                    precioanterior:null,
                    tipoprecio:'S',
                    precio:null,
                    atributos:{
                        13:{valoranterior:'Unión', valor:null},
                        16:{valoranterior:'500', valor:null},
                        55:{valoranterior:'Suave sin palo', valor:null},
                    },
                    cambio: null
                }
            }
        },
        /*
        {
            producto:'Azucar',
            especificacion:'Azucar blanca de 900 a 1200g en bolsa de plástico o papel',
            tipoPrecioAnterior:'S',
            precioAnterior:null,
            tipoPrecio:null,
            precio:null,
            atributos:[
                {atributo:'Marca'  , valorAnterior:'Ledesma', valor:null},
                {atributo:'Envase' , valorAnterior:'papel'  , valor:null},
                {atributo:'Gramaje', valorAnterior:'1000'   , valor:null}
            ],
            cambio: null
        },
        {
            producto:'Leche entera en sachet',
            especificacion:'Leche entera en sachet de 1 litro sin adhitivos ni vitaminas',
            tipoPrecioAnterior:'P',
            precioAnterior:56,
            tipoPrecio:'P',
            precio:57.75,
            atributos:[
                {atributo:'Marca', valorAnterior:'Sancor', valor:'Sancor'},
            ],
            cambio: null
        },
        {
            producto:'Dulce de leche',
            especificacion:'Dulce de leche en envase de 300g a 550g. Excluir mezclas especiales y marcas premium',
            tipoPrecioAnterior:'P',
            precioAnterior:98.40,
            tipoPrecio:'P',
            precio:57.75,
            atributos:[
                {atributo:'Marca'   , valorAnterior:'Sancor', valor:null},
                {atributo:'Variante', valorAnterior:'Repostero', valor:null},
                {atributo:'Gramaje' , valorAnterior:'500g', valor:null},
                {atributo:'Envase'  , valorAnterior:'Plástico', valor:null},
            ],
            cambio: null
        }
        */
    }
};

/*
var dataPreciosInicial=[...formularioCorto,
    {
        producto:'Mandarina',
        especificacion:'Mandarina común',
        tipoPrecioAnterior:'E',
        precioAnterior:null,
        tipoPrecio:null,
        precio:null,
        atributos:[],
        cambio: null
    },
    {
        producto:'Carbón de leña',
        especificacion:'Carbón de leña en bolsa de plástico o papel de 3 a 5kg',
        tipoPrecioAnterior:'N',
        precioAnterior:null,
        tipoPrecio:null,
        precio:null,
        atributos:[
            {atributo:'Marca'   , valorAnterior:'s/m'   , valor:null},
            {atributo:'Kilos'   , valorAnterior:'3'     , valor:null},
            {atributo:'Envase'  , valorAnterior:'Papel' , valor:null},
        ],
        cambio: null
    },
];

while(dataPreciosInicial.length<100){
    dataPreciosInicial.push(changing(formularioCorto[Math.floor(Math.random()*formularioCorto.length)],{}));
}
*/
deepFreeze(formularioCorto);

type OnUpdate<T> = (data:T)=>void

function TypedInput<T>(props:{
    value:T, 
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
        <input ref={inputRef} value={valueString} onChange={(event)=>{
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
                <TypedInput value={props.value} onUpdate={value =>{
                    props.onUpdate(value);
                }} onFocusOut={()=>{
                    setEditando(false);
                }} onWantToMoveForward={props.onWantToMoveForward}/>
            :<div>{props.value}</div>}
        </td>
    )
});

const AtributosRow = forwardRef(function(props:{
    dataAtributo:DataAtributo, 
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
            <td>{atributo.atributo}</td>
            <td colSpan={2} className="atributo-anterior" >{atributo.valorAnterior}</td>
            {props.primerAtributo?
                <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={ () => {
                    if(props.habilitarCopiado){
                        props.onCopiarAtributos()
                    }
                }}>{props.habilitarCopiado?FLECHAATRIBUTOS:props.cambio}</td>
                :null}
            <EditableTd disabled={props.deshabilitarAtributo} colSpan={2} className="atributo-actual" value={atributo.valor} onUpdate={value=>{
                props.onUpdate(props.dataAtributo.atributo, value)
            }} onWantToMoveForward={props.onWantToMoveForward}
            ref={ref} />
        </tr>
    )
});

function PreciosRow(props:{
    producto:string,
    observacion:number,
    relPre:RelPre, 
    formulario:Formulario,
    onCopiarAtributos:()=>void,
    setPrecio:(precio:number|null)=>void,
    setTipoPrecioPositivo:(tipoPrecio:string)=>void,
    setTipoPrecioNegativo:(tipoDePrecioNegativo:string)=>void,
    updateAtributo:(atributo:string, valor:string|null)=>void
    onUpdate:(dataPrecio:RelPre)=>void,
}){
    const precioRef = useRef<HTMLInputElement>(null);
    const productoDef = productos[props.producto];
    const atributosRef = useRef(productoDef.listaAtributos.map(() => createRef<HTMLInputElement>()));
    const [menuTipoPrecio, setMenuTipoPrecio] = useState<HTMLElement|null>(null);
    const [menuConfirmarBorradoPrecio, setMenuConfirmarBorradoPrecio] = useState<boolean>(false);
    const [tipoDePrecioNegativoAConfirmar, setTipoDePrecioNegativoAConfirmar] = useState<string|null>(null);
    var deshabilitarPrecio = false; // mejorar
    // const [deshabilitarPrecio, setDeshabilitarPrecio] = useState<boolean>(props.relPre.tipoPrecio?!(tipoPrecio[props.relPre.tipoPrecio].positivo):false);
    var habilitarCopiado = props.relPre.cambio==null && (!props.relPre.tipoprecio || tipoPrecio[props.relPre.tipoprecio].positivo);
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
                    && tipoPrecio[props.relPre.tipoprecioanterior].copiable
                ?
                    <td className="flechaTP" onClick={ () => {
                        if(tipoPrecio[props.relPre.tipoprecioanterior!].positivo){
                            props.setTipoPrecioPositivo(props.relPre.tipoprecioanterior!);
                        }else{
                            props.setTipoPrecioNegativo(props.relPre.tipoprecioanterior!);    
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
                            var necesitaConfirmacion = !tipoPrecio[tpDef.tipoprecio].positivo && (props.relPre.precio != null || props.relPre.cambio != null);
                            if(necesitaConfirmacion){
                                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                                setMenuConfirmarBorradoPrecio(true)
                            }else{
                                // setDeshabilitarPrecio(!tipoPrecio[tpDef.tipoprecio].positivo);
                                props.setTipoPrecioPositivo(tpDef.tipoprecio);
                            }
                            if(precioRef.current && !props.relPre.precio && tipoPrecio[tpDef.tipoprecio].positivo){
                                precioRef.current.focus();
                            }
                        }}>
                            <ListItemText>{tpDef.tipoprecio}&nbsp;</ListItemText>
                            <ListItemText>&nbsp;{tpDef.descripcion}</ListItemText>
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
                            props.setTipoPrecioNegativo(tipoDePrecioNegativoAConfirmar!)
                            // setDeshabilitarPrecio(true);
                            setMenuConfirmarBorradoPrecio(false)
                        }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </Button>
                    </DialogActions>
                </Dialog>
                <EditableTd disabled={deshabilitarPrecio} className="precio" value={props.relPre.precio} onUpdate={value=>{
                    props.setPrecio(value);
                    if(!props.relPre.tipoprecio && props.relPre.precio){
                        props.setTipoPrecioPositivo(tipoPrecioPredeterminado.tipoprecio);
                    }
                    if(precioRef.current!=null){
                        precioRef.current.blur()
                    }
                }} ref={precioRef}/>
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
                        props.onCopiarAtributos()
                        if(!props.relPre.precio && precioRef.current){
                            precioRef.current.focus();
                        }
                    }}
                    onUpdate={(atributo:string, valor:string|null)=>{
                        props.updateAtributo(atributo,valor)
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

var dataPreciosInicial = formularioCorto.productos;

export function PruebaRelevamientoPrecios(){
    const [relVis, setRelVis] = useState(formularioCorto);
    const losRelPre = relVis.productos;
    const formulario = formularios[relVis.formulario];
    const updateDataPrecio = function updateDataPrecio(relPre:RelPre,producto:string, observacion:number){
        const relPreProd=losRelPre[producto];
        setRelVis(deepFreeze({
            ...relVis,
            productos:{
                ...losRelPre, 
                [producto]:{
                    ...relPreProd, [observacion]:relPre
                }
            }
        }))
    }
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
            {formulario.listaProductos.map((producto:string) =>
                serie({from:1, to:formulario.productos[producto].observaciones}).map((observacion:number)=>
                    <PreciosRow 
                        formulario={formulario} // se va con redux 
                        relPre={relVis.productos[producto].observaciones[observacion]} // se va con redux 
                        producto={producto} 
                        observacion={observacion}
                    />
                )
                
                    /*
                <>{
                likeAr(relPreProd.observaciones).map((relPre:RelPre, observacion:number)=>
                    <tr>
                        <td>{producto}</td>
                        <td>{observacion.toString()}</td>
                    </tr>
                    <PreciosRow key={index} dataPrecio={dataPrecio} 
                    onCopiarAtributos={()=>{
                        var myDataPrecio = {
                            ...dataPrecio,
                            atributos: dataPrecio.atributos.map(atrib=>{
                                return {...atrib, valor:atrib.valorAnterior}
                            }),
                            cambio:'=',
                            tipoPrecio:dataPrecio.tipoPrecio||tipoPrecioPredeterminado.tipoprecio,
                        };
                        updateDataPrecio(myDataPrecio,index);
                    }}
                    setPrecio={(precio:number|null)=>{
                        updateDataPrecio({...dataPrecio, precio},index);
                    }}
                    setTipoPrecioPositivo={(tipoPrecio:string)=>{
                        updateDataPrecio({...dataPrecio, tipoPrecio},index);
                    }}
                    setTipoPrecioNegativo={(tipoDePrecioNegativo:string)=>{
                        var myDataPrecio = {
                            ...dataPrecio,
                            tipoPrecio: tipoDePrecioNegativo,
                            precio: null,
                            cambio: null,
                            atributos: dataPrecio.atributos.map(atrib=>{return {...atrib, valor:null}})
                        };
                        updateDataPrecio(myDataPrecio,index);
                    }}
                    updateAtributo={(atributo:string, valor:string|null)=>{
                        var myDataPrecio = {
                            ...dataPrecio,
                            atributos: dataPrecio.atributos.map(atrib=>
                                atrib.atributo == atributo?{...atrib, valor}:atrib
                            )
                        };
                        updateDataPrecio({
                            ...myDataPrecio,
                            cambio: dataPrecio.atributos.find((atrib)=>
                                atrib.valorAnterior == atrib.valor
                            )!==null?'C':'='
                        },index);
                    }}
                    onUpdate={
                        (dataPrecioForUpdate:DataPrecio)=>updateDataPrecio(dataPrecioForUpdate,index)
                    }></PreciosRow>
                ).array()
                }
                </>
                    */
            )}
            </tbody>
        </table>
    );
}