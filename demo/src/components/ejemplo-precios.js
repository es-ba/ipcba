"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
exports.__esModule = true;
var React = require("react");
var react_1 = require("react");
var best_globals_1 = require("best-globals");
var likeAr = require("like-ar");
var core_1 = require("@material-ui/core");
var FLECHATIPOPRECIO = "→";
var FLECHAATRIBUTOS = "➡";
var tiposPrecioDef = [
    { tipoprecio: 'P', descripcion: 'Precio normal', positivo: true, predeterminado: true },
    { tipoprecio: 'O', descripcion: 'Oferta', positivo: true },
    { tipoprecio: 'B', descripcion: 'Bonificado', positivo: true },
    { tipoprecio: 'S', descripcion: 'Sin existencia', positivo: false },
    { tipoprecio: 'N', descripcion: 'No vende', positivo: false, copiable: true },
    { tipoprecio: 'E', descripcion: 'Falta estacional', positivo: false, copiable: true },
];
var tipoPrecio = likeAr.createIndex(tiposPrecioDef, 'tipoprecio');
var tipoPrecioPredeterminado = tiposPrecioDef.find(function (tp) { return tp.predeterminado; });
var atributos = {
    13: {
        atributo: 13,
        nombreatributo: 'Marca',
        escantidad: false,
        tipodato: 'C'
    },
    16: {
        atributo: 16,
        nombreatributo: 'Gramaje',
        escantidad: true,
        tipodato: 'N'
    },
    55: {
        atributo: 55,
        nombreatributo: 'Variante',
        escantidad: false,
        tipodato: 'C'
    }
};
var productos = {
    P01: {
        producto: 'P01',
        nombreproducto: 'Lata de tomate',
        especificacioncompleta: 'Lata de tomate perita enteros pelado de 120 a 140g neto',
        atributos: {
            13: {
                orden: 1,
                normalizable: false,
                prioridad: null,
                rangodesde: null,
                rangohasta: null,
                tiponormalizacion: null
            },
            16: {
                orden: 2,
                normalizable: true,
                prioridad: 1,
                rangodesde: 120,
                rangohasta: 140,
                tiponormalizacion: 'normal'
            }
        },
        listaAtributos: [13, 16]
    },
    P02: {
        producto: 'P02',
        nombreproducto: 'Lata de arvejas',
        especificacioncompleta: 'Lata de arvejas peladas de 120 a 140g neto',
        atributos: {
            13: {
                orden: 1,
                normalizable: false,
                prioridad: null,
                rangodesde: null,
                rangohasta: null,
                tiponormalizacion: null
            },
            16: {
                orden: 2,
                normalizable: true,
                prioridad: 1,
                rangodesde: 120,
                rangohasta: 140,
                tiponormalizacion: 'normal'
            }
        },
        listaAtributos: [13, 16]
    },
    P03: {
        producto: 'P02',
        nombreproducto: 'Yerba',
        especificacioncompleta: 'Paquete de yerba con palo en envase de papel de 500g',
        atributos: {
            13: {
                orden: 1,
                normalizable: false,
                prioridad: null,
                rangodesde: null,
                rangohasta: null,
                tiponormalizacion: null
            },
            16: {
                orden: 3,
                normalizable: true,
                prioridad: 1,
                rangodesde: 120,
                rangohasta: 140,
                tiponormalizacion: 'normal'
            },
            55: {
                orden: 2,
                normalizable: true,
                prioridad: 1,
                rangodesde: 120,
                rangohasta: 140,
                tiponormalizacion: 'normal'
            }
        },
        listaAtributos: [13, 55, 16]
    }
};
var formularios = {
    99: {
        formulario: 99,
        nombreformulario: 'Prueba',
        orden: 99,
        productos: {
            P01: {
                orden: 2,
                observaciones: 2
            },
            P02: {
                orden: 3,
                observaciones: 1
            },
            P03: {
                orden: 1,
                observaciones: 1
            }
        },
        listaProductos: ['P03', 'P01', 'P02']
    }
};
var razones = {
    1: { escierredefinitivoinf: false, escierredefinitivofor: false }
};
var estructura = {
    tipoPrecio: tipoPrecio,
    razones: razones,
    atributos: atributos,
    productos: productos,
    formularios: formularios
};
var formularioCorto = {
    formulario: 99,
    razon: 1,
    comentarios: null,
    productos: {
        P01: {
            observaciones: {
                1: {
                    tipoprecioanterior: 'P',
                    precioanterior: 120,
                    tipoprecio: 'O',
                    precio: 130,
                    atributos: {
                        13: { valoranterior: 'La campagnola', valor: null },
                        16: { valoranterior: '300', valor: null }
                    },
                    cambio: null
                },
                2: {
                    tipoprecioanterior: 'P',
                    precioanterior: 102,
                    tipoprecio: null,
                    precio: null,
                    atributos: {
                        13: { valoranterior: 'Arcor', valor: null },
                        16: { valoranterior: '300', valor: null }
                    },
                    cambio: null
                }
            }
        },
        P02: {
            observaciones: {
                1: {
                    tipoprecioanterior: 'P',
                    precioanterior: 140,
                    tipoprecio: null,
                    precio: null,
                    atributos: {
                        13: { valoranterior: 'La campagnola', valor: null },
                        16: { valoranterior: '300', valor: null }
                    },
                    cambio: null
                }
            }
        },
        P03: {
            observaciones: {
                1: {
                    tipoprecioanterior: 'S',
                    precioanterior: null,
                    tipoprecio: 'S',
                    precio: null,
                    atributos: {
                        13: { valoranterior: 'Unión', valor: null },
                        16: { valoranterior: '500', valor: null },
                        55: { valoranterior: 'Suave sin palo', valor: null }
                    },
                    cambio: null
                }
            }
        }
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
best_globals_1.deepFreeze(formularioCorto);
function TypedInput(props) {
    var _a = react_1.useState(props.value), value = _a[0], setValue = _a[1];
    var inputRef = react_1.useRef(null);
    react_1.useEffect(function () {
        if (inputRef.current != null) {
            inputRef.current.focus();
        }
    }, []);
    // @ts-ignore acá hay un problema con el cambio de tipos
    var valueString = value == null ? '' : value;
    return (<input ref={inputRef} value={valueString} onChange={function (event) {
        // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
        setValue(event.target.value);
    }} onBlur={function (event) {
        if (value != props.value) {
            // @ts-ignore Tengo que averiguar cómo hacer esto genérico:
            props.onUpdate(event.target.value);
        }
        props.onFocusOut();
    }} onMouseOut={function () {
        if (document.activeElement != inputRef.current) {
            props.onFocusOut();
        }
    }} onKeyDown={function (event) {
        var tecla = event.charCode || event.which;
        if ((tecla == 13 || tecla == 9) && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
            if (!(props.onWantToMoveForward && props.onWantToMoveForward())) {
                if (inputRef.current != null) {
                    inputRef.current.blur();
                }
            }
            event.preventDefault();
        }
    }}/>);
}
var EditableTd = react_1.forwardRef(function (props, ref) {
    var _a = react_1.useState(false), editando = _a[0], setEditando = _a[1];
    react_1.useImperativeHandle(ref, function () { return ({
        focus: function () {
            setEditando(true && !props.disabled);
        },
        blur: function () {
            setEditando(false);
        }
    }); });
    return (<td colSpan={props.colSpan} rowSpan={props.rowSpan} className={props.className} onClick={function () { return setEditando(true && !props.disabled); }}>
            {editando ?
        <TypedInput value={props.value} onUpdate={function (value) {
            props.onUpdate(value);
        }} onFocusOut={function () {
            setEditando(false);
        }} onWantToMoveForward={props.onWantToMoveForward}/>
        : <div>{props.value}</div>}
        </td>);
});
var AtributosRow = react_1.forwardRef(function (props, ref) {
    var atributo = props.dataAtributo;
    return (<tr>
            <td>{atributo.atributo}</td>
            <td colSpan={2} className="atributo-anterior">{atributo.valorAnterior}</td>
            {props.primerAtributo ?
        <td rowSpan={props.cantidadAtributos} className="flechaAtributos" onClick={function () {
            if (props.habilitarCopiado) {
                props.onCopiarAtributos();
            }
        }}>{props.habilitarCopiado ? FLECHAATRIBUTOS : props.cambio}</td>
        : null}
            <EditableTd disabled={props.deshabilitarAtributo} colSpan={2} className="atributo-actual" value={atributo.valor} onUpdate={function (value) {
        props.onUpdate(props.dataAtributo.atributo, value);
    }} onWantToMoveForward={props.onWantToMoveForward} ref={ref}/>
        </tr>);
});
function PreciosRow(props) {
    var precioRef = react_1.useRef(null);
    var productoDef = productos[props.producto];
    var atributosRef = react_1.useRef(productoDef.listaAtributos.map(function () { return react_1.createRef(); }));
    var _a = react_1.useState(null), menuTipoPrecio = _a[0], setMenuTipoPrecio = _a[1];
    var _b = react_1.useState(false), menuConfirmarBorradoPrecio = _b[0], setMenuConfirmarBorradoPrecio = _b[1];
    var _c = react_1.useState(null), tipoDePrecioNegativoAConfirmar = _c[0], setTipoDePrecioNegativoAConfirmar = _c[1];
    var deshabilitarPrecio = false; // mejorar
    // const [deshabilitarPrecio, setDeshabilitarPrecio] = useState<boolean>(props.relPre.tipoPrecio?!(tipoPrecio[props.relPre.tipoPrecio].positivo):false);
    var habilitarCopiado = props.relPre.cambio == null && (!props.relPre.tipoprecio || tipoPrecio[props.relPre.tipoprecio].positivo);
    return (<>
            <tr>
                <td className="col-prod-esp" rowSpan={productoDef.listaAtributos.length + 1}>
                    <div className="producto">{productoDef.nombreproducto}</div>
                    <div className="especificacion">{productoDef.especificacioncompleta}</div>
                </td>
                <td className="observaiones"><button>Obs.</button></td>
                <td className="tipoPrecioAnterior">{props.relPre.tipoprecioanterior}</td>
                <td className="precioAnterior">{props.relPre.precioanterior}</td>
                {props.relPre.tipoprecio == null
        && props.relPre.tipoprecioanterior != null
        && tipoPrecio[props.relPre.tipoprecioanterior].copiable
        ?
            <td className="flechaTP" onClick={function () {
                if (tipoPrecio[props.relPre.tipoprecioanterior].positivo) {
                    props.setTipoPrecioPositivo(props.relPre.tipoprecioanterior);
                }
                else {
                    props.setTipoPrecioNegativo(props.relPre.tipoprecioanterior);
                }
            }}>{FLECHATIPOPRECIO}</td>
        :
            <td className="flechaTP"></td>}
                <td className="tipoPrecio" onClick={function (event) { return setMenuTipoPrecio(event.currentTarget); }}>{props.relPre.tipoprecio}
                </td>
                <core_1.Menu id="simple-menu" open={Boolean(menuTipoPrecio)} anchorEl={menuTipoPrecio} onClose={function () { return setMenuTipoPrecio(null); }}>
                    {tiposPrecioDef.map(function (tpDef) {
        return <core_1.MenuItem key={tpDef.tipoprecio} onClick={function () {
            setMenuTipoPrecio(null);
            var necesitaConfirmacion = !tipoPrecio[tpDef.tipoprecio].positivo && (props.relPre.precio != null || props.relPre.cambio != null);
            if (necesitaConfirmacion) {
                setTipoDePrecioNegativoAConfirmar(tpDef.tipoprecio);
                setMenuConfirmarBorradoPrecio(true);
            }
            else {
                // setDeshabilitarPrecio(!tipoPrecio[tpDef.tipoprecio].positivo);
                props.setTipoPrecioPositivo(tpDef.tipoprecio);
            }
            if (precioRef.current && !props.relPre.precio && tipoPrecio[tpDef.tipoprecio].positivo) {
                precioRef.current.focus();
            }
        }}>
                            <core_1.ListItemText>{tpDef.tipoprecio}&nbsp;</core_1.ListItemText>
                            <core_1.ListItemText>&nbsp;{tpDef.descripcion}</core_1.ListItemText>
                        </core_1.MenuItem>;
    })}
                </core_1.Menu>
                <core_1.Dialog open={menuConfirmarBorradoPrecio} onClose={function () { return setMenuConfirmarBorradoPrecio(false); }} aria-labelledby="alert-dialog-title" aria-describedby="alert-dialog-description">
                    <core_1.DialogTitle id="alert-dialog-title">{"Eligió un tipo de precio negativo pero había precios o atributos cargados"}</core_1.DialogTitle>
                    <core_1.DialogContent>
                        <core_1.DialogContentText id="alert-dialog-description">
                            Se borrará el precio y los atributos
                        </core_1.DialogContentText>
                    </core_1.DialogContent>
                    <core_1.DialogActions>
                        <core_1.Button onClick={function () {
        setMenuConfirmarBorradoPrecio(false);
    }} color="primary" variant="outlined">
                            No borrar
                        </core_1.Button>
                        <core_1.Button onClick={function () {
        props.setTipoPrecioNegativo(tipoDePrecioNegativoAConfirmar);
        // setDeshabilitarPrecio(true);
        setMenuConfirmarBorradoPrecio(false);
    }} color="secondary" variant="outlined">
                            Borrar precios y/o atributos
                        </core_1.Button>
                    </core_1.DialogActions>
                </core_1.Dialog>
                <EditableTd disabled={deshabilitarPrecio} className="precio" value={props.relPre.precio} onUpdate={function (value) {
        props.setPrecio(value);
        if (!props.relPre.tipoprecio && props.relPre.precio) {
            props.setTipoPrecioPositivo(tipoPrecioPredeterminado.tipoprecio);
        }
        if (precioRef.current != null) {
            precioRef.current.blur();
        }
    }} ref={precioRef}/>
            </tr>
            {productoDef.listaAtributos.map(function (atributo, index) {
        return <AtributosRow key={atributo} dataAtributo={props.relPre.atributos[atributo]} primerAtributo={index == 0} cambio={props.relPre.cambio} habilitarCopiado={habilitarCopiado} deshabilitarAtributo={deshabilitarPrecio} cantidadAtributos={productoDef.listaAtributos.length} ultimoAtributo={index == productoDef.listaAtributos.length - 1} onCopiarAtributos={function () {
            props.onCopiarAtributos();
            if (!props.relPre.precio && precioRef.current) {
                precioRef.current.focus();
            }
        }} onUpdate={function (atributo, valor) {
            props.updateAtributo(atributo, valor);
        }} onWantToMoveForward={function () {
            if (index < productoDef.listaAtributos.length - 1) {
                var nextItemRef = atributosRef.current[index + 1];
                if (nextItemRef.current != null) {
                    nextItemRef.current.focus();
                    return true;
                }
            }
            else {
                if (!props.relPre.precio) {
                    if (precioRef.current) {
                        precioRef.current.focus();
                        return true;
                    }
                }
            }
            return false;
        }} ref={atributosRef.current[index]}/>;
    })}
            

        </>);
}
var dataPreciosInicial = formularioCorto.productos;
function PruebaRelevamientoPrecios() {
    var _a = react_1.useState(formularioCorto), relVis = _a[0], setRelVis = _a[1];
    var losRelPre = relVis.productos;
    var formulario = formularios[relVis.formulario];
    var updateDataPrecio = function updateDataPrecio(relPre, producto, observacion) {
        var _a, _b;
        var relPreProd = losRelPre[producto];
        setRelVis(best_globals_1.deepFreeze(__assign(__assign({}, relVis), { productos: __assign(__assign({}, losRelPre), (_a = {}, _a[producto] = __assign(__assign({}, relPreProd), (_b = {}, _b[observacion] = relPre, _b)), _a)) })));
    };
    var ref = react_1.useRef(null);
    react_1.useEffect(function () {
        if (ref.current) {
            var thInThead = ref.current.querySelectorAll('thead th');
            var minReducer = function (min, th) { return Math.min(min, th.offsetTop); };
            // @ts-ignore
            var minTop = Array.prototype.reduce.call(thInThead, minReducer, Number.MAX_VALUE);
            Array.prototype.map.call(thInThead, function (th) {
                th.style.top = th.offsetTop - minTop + 'px';
            });
        }
    });
    return (<table className="formulario-precios" ref={ref}>
            <caption>Formulario X</caption>
            <thead>
                <tr>
                    <th rowSpan={2}>producto<br />especificación</th>
                    <th rowSpan={2}>obs.<br />atributos</th>
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
            {formulario.listaProductos.map(function (producto) {
        return best_globals_1.serie({ from: 1, to: formulario.productos[producto].observaciones }).map(function (observacion) {
            return <PreciosRow formulario={formulario} // se va con redux 
             relPre={relVis.productos[producto].observaciones[observacion]} // se va con redux 
             producto={producto} observacion={observacion}/>;
        });
    }
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
        </table>);
}
exports.PruebaRelevamientoPrecios = PruebaRelevamientoPrecios;
