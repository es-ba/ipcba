var html=require('js-to-html').html;
var likeAr = require('like-ar');
var TypedControls=require('typed-controls');
var datetime = bestGlobals.datetime;

var LEFTARROW = '←';
var RIGHTARROW = '→';
var CHECK = '✓';
var MAGNIFYING_GLASS = '\uD83D\uDD0D';

var my=myOwn;

function saveReferenceTableInLocalStorage(tableName){
    var promise = Promise.resolve();
    if(!my.offline.mode){
        var Connector = my.TableConnector; 
        var dummyElement = html.div().create();
        var conn=new Connector({
            my:my, 
            tableName: tableName, 
            getElementToDisplayCount:function(){ return dummyElement; },
        });
        //REVISAR, por ahi no hace falta
        var opts = {
            registerInLocalDB: true, 
            waitForFreshStructure: true
        }
        conn.getStructure(opts);
        promise=promise.then(function(){
            return conn.getData().then(function(data){
                localStorage.setItem(tableName, JSON.stringify(data));
                return 'ok';
            }); 
        }) 
    }
    return promise;
}

function getTiposPrecioPositivosFromLocalStorage(){
    var tiposPreEncuestador = JSON.parse(localStorage.getItem('tipopre_encuestador')) || [];
    return tiposPreEncuestador.filter(function(tipoPre){
        return tipoPre.espositivo == "S";
    }).map(function(tipoPre){
        return tipoPre.tipoprecio;
    });
}

function getTipoPrecioByTipoFromLocalStorage(tipoPrecio){
    var tiposPreEncuestador = JSON.parse(localStorage.getItem('tipopre_encuestador')) || [];
    return tiposPreEncuestador.find(function(tipoPre){
        return tipoPre.tipoprecio == tipoPrecio
    });
}

function getMobileDevice(){
    return 'iPad prueba'
}

function getVersionSistema(){
    return '0.1.0'
}

myOwn.getCollapsableElements = function getCollapsableElements(){
    var layout = document.getElementById("main_layout");
    return Array.prototype.slice.call(layout.querySelectorAll('[is-collapsed]'));
}
myOwn.collapseElements = function collapseElements(){
    var layout = document.getElementById("main_layout");
    var productDivColElements = Array.prototype.slice.call(layout.querySelectorAll('[my-colname=producto_div]'))
    myOwn.getCollapsableElements().forEach(function(collapsableElement){
        if(my.isPreciosGridCollapsed){
            my.wait4preciosGrid.then(function(preciosGrid){
                productDivColElements.forEach(function(element, i){
                    //ignoro header
                    if(i>0){
                        element.rowSpan = preciosGrid.depots[i-1].extraRows.length+1
                    }
                })
            })            
        }else{
            productDivColElements.forEach(function(element){
                element.rowSpan=1;
            })
        }
        my.isPreciosGridCollapsed = !my.isPreciosGridCollapsed;
        collapsableElement.setAttribute('is-collapsed', my.isPreciosGridCollapsed);
    });
}

myOwn.autoShowReferences = function autoShowReferences(depot, fieldName){
    var autoShowTables = ['mobile_hoja_de_ruta', 'mobile_visita','mobile_precios','mobile_atributos'];
    if(autoShowTables.includes(depot.connector.tableName) && depot.connector.def.allow.update && depot.connector.def.field[fieldName].allow.update){
        depot.rowControls[fieldName].displayExpander(new Event('Force F9'));
    }
}

DialogPromise.defaultOpts.autoFocus=false;

myOwn.getFormsSidebar = function getFormsSidebar(periodo, panel, tarea, informante, visita, formularioActual){
    var allFormsByInformant = JSON.parse(sessionStorage.getItem('formularios-por-informante'));
    var formsSidebarDiv = html.div({id:'formularios-sidebar'}).create();
    var informant = allFormsByInformant.find(function(informantForms){
        return informantForms.informante == informante;
    });
    informant.formularios.forEach(function(form){
        var formDiv = html.div({class:'formulario', 'formulario-seleccionado': form.formulario == formularioActual}).create();
        formDiv.appendChild(html.div({class:'numero-formulario'},form.formulario).create());
        formDiv.appendChild(html.div({class:'nombre-formulario'},form.nombreformulario).create());
        formsSidebarDiv.appendChild(formDiv);
        asignarClick(formDiv, changing(form, {periodo: periodo, panel: panel, tarea: tarea, informante: informante, visita:visita}), ['periodo','panel','tarea', 'informante', 'visita', 'formulario'],'precios');
    });
    return formsSidebarDiv;
}

myOwn.wScreens.hoja_ruta = function(addrParams){
    var mainLayout = document.getElementById('main_layout');
    if(my.offline.mode){
        var periodo = localStorage.getItem('periodo');
        var panel = localStorage.getItem('panel');
        var tarea = localStorage.getItem('tarea');
        var vaciado = JSON.parse(localStorage.getItem('vaciado')||'false');
        if(periodo && panel && tarea && !vaciado){
            var json = {
                periodo: periodo,
                panel: parseInt(panel),
                tarea: parseInt(tarea),
            };
            history.replaceState(null, null, location.origin+location.pathname+my.menuSeparator+'w=hoja_de_ruta&up='+JSON.stringify(json)+'&autoproced=true');
            my.showPage();
        }else{
            mainLayout.appendChild(html.p('No se cargó la Hoja de Ruta').create());
        }
    }else{
        mainLayout.appendChild(html.p('La hoja de ruta está disponible únicamente en modo avión.').create());
    }
}

function asignarClick(clickeableElement, row, fields, wType){
    var my=myOwn;
    clickeableElement.style.cursor='pointer';
    clickeableElement.onclick= function(){
        redirectTo(row, fields, wType, 250);
    };
}

function quitarClick(clickeableElement){
    clickeableElement.style.cursor='auto';
    clickeableElement.onclick= null;
}

function getParamsFromRow(row, fieldsArray){
    return likeAr(row).filter(function(value, fieldName){
        return fieldsArray.includes(fieldName);
    })
}

function redirectTo(row, fields,wType, timeout){
    setTimeout(function(){
        my.wait4preciosGrid = null;
        my.wait4atributosGrid = null;
        my.wait4visitaGrid = null;
        my.wait4attributes4Grid = null;
        var json = getParamsFromRow(row,fields);
        history.replaceState(null, null, location.origin+location.pathname+my.menuSeparator+'w='+wType+'&up='+JSON.stringify(json)+'&autoproced=true');
        my.showPage();
        window.scrollTo(0,0);
    }, timeout)
}

function updateAtributesCache(attributes){
    var formAttributes;
    my.wait4attributes4Grid.then(function(allAttributes){
        formAttributes = allAttributes;
    })
    my.wait4attributes4Grid = Promise.resolve().then(function(){
        attributes.forEach(function(attribute){
            var index = formAttributes.findIndex(function(attr){
                return attr.periodo == attribute.periodo && 
                    attr.informante == attribute.informante && 
                    attr.visita == attribute.visita && 
                    attr.formulario == attribute.formulario && 
                    attr.producto == attribute.producto && 
                    attr.observacion == attribute.observacion && 
                    attr.atributo == attribute.atributo
            });
            formAttributes[index]=attribute;
        });
        return formAttributes;
    })
}

function paintSelectedRow(depot, timeout){
    var rowTds = depot.extraRows.map(function(extraRow){
        return Array.prototype.slice.call(extraRow.cells)
    }).reduce(function(a,b){
        return a.concat(b);
    }).concat(Array.prototype.slice.call(depot.tr.cells));
    rowTds.forEach(function(td){
        td.setAttribute('selected-from-collapsed', true);
    })
    setTimeout(function(){
        rowTds.forEach(function(td){
            td.setAttribute('selected-from-collapsed', false);
        })
    },timeout)
}

/*Inicio Pantalla Hoja de Ruta */
myOwn.wScreens.hoja_de_ruta={
    parameters:[
        {name:'periodo'           , typeName:'text'   , references:'periodos'},
        {name:'panel'             , typeName:'integer'},
        {name:'tarea'             , typeName:'integer'},
    ],
    mainAction:function(params,divResult){
        if(my.offline.mode){
            var mainLayout = document.getElementById('main_layout');
            mainLayout.innerHTML="";
            var layout = html.div({id: "mobile-layout-hoja-de-ruta", class: "mobile-main-layout"}).create()
            mainLayout.appendChild(layout);
            layout.appendChild(html.div({id: "title"}, 'Hoja de Ruta').create());
            var spanArray = [];
            spanArray.push(html.span({id: "panel"}, 'Panel: ' + params.panel));
            spanArray.push(html.span({id: "tarea"}, 'Tarea: ' + params.tarea));
            spanArray.push(html.span({id: "encuestador"}, 'Encuestador: ' + localStorage.getItem('nombreencuestador')||''));
            layout.appendChild(html.div({id: "header-information"},spanArray).create());
            
            var fixedFields = [];
            likeAr(params).forEach(function(value, attrName, object){
                fixedFields.push({fieldName: attrName, value: value});
            });        

            var gridMobileDiv = html.div({class: "grid-mobile"}).create();
            layout.appendChild(gridMobileDiv);  

            var grid=my.tableGrid('mobile_hoja_de_ruta',gridMobileDiv,{tableDef:{
                hiddenColumns:['informantes__nombreinformante', 'informantes__tipoinformante'],
            }, fixedFields:fixedFields});
            return grid.waitForReady().then(function(){
                return grid
            });
        }else{
            return Promise.resolve().then(function(){
                history.pushState(null, null, 'menu#i=ipad,hoja_de_ruta');
                my.showPage();
            })
        }
    }
};
myOwn.clientSides.parseFormularios={
    update: false,
    prepare: function(depot, fieldName){
        var forms = JSON.parse(sessionStorage.getItem('formularios-por-informante')) || [];
        var result = forms.find(function(form){
            return form.informante == depot.row['informante'];
        });
        if(!result){
            forms.push({informante:depot.row['informante'], formularios:depot.row['formularios'], visita: depot.row['visita']});
            sessionStorage.setItem('formularios-por-informante', JSON.stringify(forms));
        }

        var attributesLength = depot.row['formularios'].length -1;
        depot.rowControls['$lock'].rowSpan+= attributesLength;
        depot.rowControls['informante_div'].rowSpan+= attributesLength;
        depot.row['formularios'].forEach(function(formulario, i){
            var td1 = html.td({},formulario.formulario).create()
            var td2 = html.td({},formulario.nombreformulario).create()
            if(i==0){
                depot.rowControls[fieldName].appendChild(td1);
                depot.rowControls[fieldName].appendChild(td2);
            }else{
                //creo extraRows
                depot.manager.createExtraRow(depot, depot.manager.dom.table.tBodies[0]);
                var extraRow = depot.extraRows[i-1];
                extraRow.appendChild(html.td().create());
                extraRow.appendChild(html.td().create());
                extraRow.appendChild(html.td().create());
                var extraCell0 = extraRow.cells[0];
                extraCell0.setAttribute('my-colname',fieldName);
                extraCell0.appendChild(td1);
                extraCell0.appendChild(td2);
            }
            asignarClick(td1,changing(depot.row,{formulario:formulario.formulario}),['periodo','panel','tarea','informante','visita','formulario'],'precios');
            asignarClick(td2,changing(depot.row,{formulario:formulario.formulario}),['periodo','panel','tarea','informante','visita','formulario'],'precios');
        })
    }
};
myOwn.clientSides.parseProd={
    update: false,
    prepare: function(depot, fieldName){
        depot.row['formularios'].forEach(function(formulario, i){
            var prodTd = html.span().create();
            var faltanTd = html.span().create();
            var advTd = html.span().create();
            var appendRow = function appendRow(i){
                if(i==0){
                    depot.rowControls[fieldName].appendChild(prodTd);
                    depot.rowControls['faltan_div'].appendChild(faltanTd);
                    depot.rowControls['adv'].appendChild(advTd);
                }else{
                    var extraRow = depot.extraRows[i-1];
                    var extraCell1 = extraRow.cells[1];
                    extraCell1.setAttribute('my-colname',fieldName);
                    extraCell1.appendChild(prodTd);
                    var extraCell2 = extraRow.cells[2];
                    extraCell2.setAttribute('my-colname','faltan_div');
                    extraCell2.appendChild(faltanTd);
                    var extraCell3 = extraRow.cells[3];
                    extraCell3.setAttribute('my-colname','adv');
                    extraCell3.appendChild(advTd);
                }
            }
            var removeColumns = function removeColumns(row,iRow,nombreRazon){
                var offset = iRow==0?3:0;
                row.cells[1+offset].colSpan = 3;
                row.cells[1+offset].textContent = nombreRazon;
                row.removeChild(row.cells[2+offset]);
                row.removeChild(row.cells[2+offset]);
                
            }
            if(my.offline.mode){
                var key = ['periodo','informante','visita'].map(function(fname){
                    return depot.row[fname];
                }).concat(formulario.formulario);
                my.ldb.getChild('mobile_precios', key).then(function(precios){
                    var cantFaltantes = precios.filter(function(precio){
                        var myTipoPrecio = getTipoPrecioByTipoFromLocalStorage(precio.tipoprecio);
                        return precio.tipoprecio == null || (myTipoPrecio && myTipoPrecio.espositivo == 'S' && precio.precio == null)
                    }).length;
                    faltanTd.textContent = cantFaltantes?cantFaltantes.toString():CHECK;
                    faltanTd.setAttribute('faltan',(cantFaltantes > 0)?'true':'false');
                    prodTd.textContent=precios.length.toString();
                 var cantAdvertencias = precios.filter(function(precio){
                        return precio.adv == true
                    }).length;
                    advTd.textContent = cantAdvertencias?cantAdvertencias.toString():CHECK;
                    advTd.setAttribute('adv',(cantAdvertencias > 0)?'true':'false');
                })
                my.ldb.getOne('mobile_visita', key).then(function(visita){
                    appendRow(i);
                    var esNegativoFormulario = visita.razones__espositivoformulario == 'N';
                    if(esNegativoFormulario){
                        var extraRow = (i==0)?depot.tr:depot.extraRows[i-1];
                        removeColumns(extraRow, i, visita.razones__nombrerazon);
                    }
                })
            }else{
                appendRow(i);
                if(formulario.espositivoformulario == 'N'){
                    var extraRow = (i==0)?depot.tr:depot.extraRows[i-1];
                    removeColumns(extraRow, i, formulario.nombrerazon);
                }else{
                    prodTd.textContent=formulario.prod;
                    faltanTd.textContent=formulario.faltan;
                    faltanTd.setAttribute('faltan',(formulario.faltan > 0)?'true':'false');
                    advTd.textContent=formulario.adv;
                    advTd.setAttribute('adv',(formulario.adv > 0)?'true':'false');
                }
            }
        })
    }
};

myOwn.clientSides.parseFaltan={
    update: false,
    prepare: function(depot, fieldName){
   }
}

myOwn.clientSides.parseInformante={
    update: false,
    prepare: function(depot, fieldName){
        var div = html.div({class:'informante'}).create();
        div.appendChild(html.span({class:'nombre-informante'}, depot.row['informantecompleto'].informante + ' ' + depot.row['informantecompleto'].nombreinformante).create());
        div.appendChild(html.span({class:'cantidad-periodos-sin-informacion'}, "(" + depot.row['informantecompleto'].cantidad_periodos_sin_informacion + ")").create());
        div.appendChild(html.div({class:'direccion-informante'}, depot.row['informantecompleto'].direccion).create());
        div.appendChild(html.div({class:'comentarios-informante'}, depot.row['informantecompleto'].comentarios).create());
        depot.rowControls[fieldName].appendChild(div);
    }
};
myOwn.clientSides.semaforo={
    update: false,
    prepare: function(depot, fieldName){
    }
};
/*Fin Pantalla Hoja de Ruta */

/*Inicio grilla visita */
myOwn.clientSides.controlarRazonesNegativas={
    prepare: function(depot, fieldName){
        depot.rowControls[fieldName].editOnlyFromList=true;
        myOwn.clientSides['control_razones_mobile'].prepare(depot, fieldName);
        var razonesEncuestador = JSON.parse(localStorage.getItem("razones_encuestador")) || [];
        var ignoreValues = razonesEncuestador.filter(function(razon){
            return razon.espositivoformulario == "S";
        }).map(function(razon){
            return razon.razon;
        });
        var opts = {
            buttonsDef:[{
                label:'No',
                value: false
            },{
                label:'Borrar',
                value:true,
                attributes: {delete: true}
            }],
            setAttrs:{device:'mobile'},
            inputDef:{
                attributes: {type: 'number', min: 0}
            }
        };
        my.wait4preciosGrid.then(function(preciosGrid){
            var message = "Usted eligió la razón de no contacto \"$$razon\" $$nombre_razon. \n Se borrarán " + preciosGrid.depots.length + " precios ingresados. \n Confirme el numero de precios a borrar"
            var preDialogFun = function preDialogFun(typedControl, typedValue){
                return Promise.resolve().then(function(){
                    var razonEncontrada = razonesEncuestador.find(function(razon){
                        return razon.razon == typedValue;
                    });
                    typedControl.dialogPromiseSetup.message = typedControl.dialogPromiseSetup.message.replace('$$razon', razonEncontrada.razon);
                    typedControl.dialogPromiseSetup.message = typedControl.dialogPromiseSetup.message.replace('$$nombre_razon', razonEncontrada.nombrerazon);
                })
            }
            var dialogPromiseSetup = {
                message: message, 
                opts: opts, 
                ignoreValues: ignoreValues, 
                dialogType: 'promptPromise', 
                expectedValue: preciosGrid.depots.length,
                preDialogFun: preDialogFun
            };
            depot.rowControls[fieldName].setDialogPromiseSetup(dialogPromiseSetup);
        })
    },
    update: function(depot, fieldName){
        myOwn.clientSides['control_razones_mobile'].update(depot, fieldName);
        my.wait4preciosGrid.then(function(preciosGrid){
            if(depot.row['razones__espositivoformulario'] == 'N'){
                var promiseArray = [];
                preciosGrid.depots.forEach(function(priceDepot){
                    if(priceDepot.row['tipoprecio']){
                        priceDepot.row['tipopre__espositivo'] = null;
                        priceDepot.row['tipopre__nombretipoprecio'] = null;
                        priceDepot.row['tipopre_encuestador_anterior__espositivo'] = null;
                        priceDepot.row['tipopre_encuestador_anterior__nombretipoprecio'] = null;
                        priceDepot.row['tipoprecio'] = null;
                        priceDepot.row['precio'] = null;
                        priceDepot.row['comentariosrelpre'] = null;
                        promiseArray.push(priceDepot.connector.saveRecord(priceDepot,{}));
                    }
                })
                if(promiseArray.length){
                    console.log("Cartel de espera!")
                    Promise.all(promiseArray).then(function(){
                        my.wait4attributes4Grid.then(function(allAttributes){
                            allAttributes.forEach(function(attribute){
                                attribute.valor = null;
                            });
                            my.ldb.putMany('mobile_atributos', allAttributes).then(function(){
                            redirectTo(depot.row,['periodo','panel','tarea'],'hoja_de_ruta', 500);
                            })                            
                        })
                    });
                }
            }else{
                preciosGrid.depots.forEach(function(priceDepot){
                    var precioTd = priceDepot.rowControls['precio']
                    precioTd.disable(false);
                    var tipoPrecioTd = priceDepot.rowControls['tipoprecio']
                    tipoPrecioTd.contentEditable=false;
                    tipoPrecioTd.editOnlyFromList=true;
                    
                })
            }
        });
    }    
};
/*Fin grilla visita */

/*Inicio Pantalla Precios */
myOwn.wScreens.precios={
    parameters:[
        {name:'periodo'    , typeName:'text'   , references:'periodos'},
        {name:'panel'      , typeName:'integer'},
        {name:'tarea'      , typeName:'integer'},
        {name:'informante' , typeName:'integer'},
        {name:'formulario' , typeName:'integer'},
        {name:'visita'     , typeName:'integer'},
    ],
    mainAction:function(params,divResult){
        if(my.offline.mode){
            var mainLayout = document.getElementById('main_layout');
            mainLayout.innerHTML="";
            var layout = html.div({id: "mobile-layout-precios", class: "mobile-main-layout"}).create()
            mainLayout.appendChild(layout);
            layout.appendChild(html.div({id: "title"}, 'Precios informante ' + params.informante).create());
            
            var backButton = html.button({class:'back-button'},LEFTARROW).create();
            asignarClick(backButton, params,['periodo','panel','tarea'],'hoja_de_ruta');

            var collapseButton = html.button({id:'collapse-button'},'compactar').create();
            var showAllButton = html.button({id:'filter-all-button', disabled:true},'todos').create();
            var showPendentsButton = html.button({id:'filter-pendents-button', disabled: false},'pendientes').create();
            var showWarningsButton = html.button({id:'filter-warnings-button', disabled: false},'advertencias').create();
            var searchProductInput = html.input({id:'search-product-input', placeholder:'Buscar producto ' + MAGNIFYING_GLASS, autocomplete:'off'}).create();
            my.showAllButton = showAllButton;
            my.showPendentsButton = showPendentsButton;
            my.showWarningsButton = showWarningsButton;
            my.searchProductInput = searchProductInput;
            var searchProductSpan = html.span({id: "search-product"},[searchProductInput]).create();
            var headerInformationDiv = html.div({id: "header-information"}, [backButton, collapseButton, showAllButton, showPendentsButton, showWarningsButton, searchProductSpan]).create();
            layout.appendChild(headerInformationDiv);
            window.onscroll = function(){
                if(window.scrollY > 50){
                    headerInformationDiv.setAttribute('set-fixed','true');
                }else{
                    headerInformationDiv.setAttribute('set-fixed','false');
                }
            };

            collapseButton.addEventListener('click', function(){
                myOwn.collapseElements();
                // window.scrollTo(0,0);
            });
            showAllButton.addEventListener('click', function(){
                showAllButton.disabled = true;
                showPendentsButton.disabled = false;
                showWarningsButton.disabled = false;
                preciosGrid.view=preciosGrid.view||{};
                preciosGrid.view.filter=[];
                preciosGrid.displayBody();
                window.scrollTo(0,0);
            });
            showPendentsButton.addEventListener('click', function(){
                showAllButton.disabled = false;
                showWarningsButton.disabled = false;
                showPendentsButton.disabled = true;
                preciosGrid.view=preciosGrid.view||{};
                preciosGrid.view.filter=[{
                    rowSymbols:{tipoprecio:'\u2205'},
                    row:{tipoprecio:null}
                },
                {
                    rowSymbols:{tipopre__espositivo:'=', precio:'\u2205'},
                    row:       {tipopre__espositivo:'S', precio:null    },
                }]
                preciosGrid.displayBody();
                window.scrollTo(0,0);
            });
            showWarningsButton.addEventListener('click', function(){
                showAllButton.disabled = false;
                showPendentsButton.disabled = false;
                showWarningsButton.disabled = true;
                preciosGrid.view=preciosGrid.view||{};
                preciosGrid.view.filter=[{
                    rowSymbols:{adv:'='},
                    row:{adv:true}
                }]
                preciosGrid.displayBody();
                window.scrollTo(0,0);
            });
            var style = document.createElement('style');
            var mainLayout = document.getElementById('main_layout');
            mainLayout.appendChild(style);
            var dpmmLines = 'dpmmLines-prices';
            var cambiarTimeout;

            var cambiar = function cambiar(){
                var caso=DialogPromise.simplificateText(my.searchProductInput.value.toLowerCase()).split(' ').filter(function(word){ return word.trim()});
                if(caso.length){
                    style.textContent="tr["+dpmmLines+"]{display: none} tr["+dpmmLines+"]"+
                        caso.map(function(word){
                            return word?"["+dpmmLines+"*="+JSON.stringify(word)+"]":"";
                        }).join('')+
                        "{ display: table-row}";
                }else{
                    style.textContent='';
                }
                cambiarTimeout = null;
            }
            
            searchProductInput.addEventListener('keydown', function(){
                var code=event.keyCode || event.which;
                if(code==13 || code==9){
                    event.preventDefault();
                    return;
                }
                window.scrollTo(0,0);
                if(cambiarTimeout){
                    clearTimeout(cambiarTimeout);
                }
                cambiarTimeout=setTimeout(cambiar,200);
            })
            searchProductInput.styleElement = style;

            var fixedFields = [];
            likeAr(params).forEach(function(value, attrName, object){
                fixedFields.push({fieldName: attrName, value: value});
            });      
            
            var gridVisitaDiv = html.div({class: "grid-mobile"}).create();
            layout.appendChild(gridVisitaDiv);  
            
            var floatingGridDiv = html.div({id: "floating-grid"}).create();
            var gridMobileDiv = html.div({class: "grid-mobile", 'is-collapsed':'false'}).create();
            gridMobileDiv.appendChild(my.getFormsSidebar(params.periodo, params.panel, params.tarea, params.informante, params.visita, params.formulario));  
            layout.appendChild(gridMobileDiv); 
            gridMobileDiv.appendChild(floatingGridDiv);
            var visitaGrid = my.tableGrid('mobile_visita',gridVisitaDiv,{tableDef:{
                hiddenColumns:['razones__espositivoformulario'],
            }, fixedFields:fixedFields});
            my.disableUpdatePrices = false;
            my.wait4visitaGrid = Promise.resolve().then(function(){
                return visitaGrid.waitForReady().then(function(){
                    return visitaGrid;
                });
            })
            
            var preciosGrid=my.tableGrid('mobile_precios',floatingGridDiv,{tableDef:{
                hiddenColumns:['productos__nombreproducto', 'tipopre_encuestador_anterior__nombretipoprecio', 'tipopre_encuestador_anterior__espositivo', 'tipopre__nombretipoprecio', 'tipopre__espositivo', 'comentariosrelpre'],
                firstDisplayCount: 1000,
                firstDisplayOverLimit: 1100,
            }, fixedFields:fixedFields});
            
            my.wait4preciosGrid = Promise.resolve().then(function(){
                return preciosGrid.waitForReady().then(function(){
                    my.isPreciosGridCollapsed = false;
                    return preciosGrid;
                });
            })

            my.wait4attributes4Grid = Promise.resolve().then(function(){
                var key = ['periodo','informante','visita', 'formulario'].map(function(fname){
                    return params[fname];
                });
                return my.ldb.getChild('mobile_atributos', key).then(function(result){
                    return result
                })
            })
            return my.wait4preciosGrid;
        }else{
            return Promise.resolve().then(function(){
                history.pushState(null, null, 'menu#i=ipad,hoja_de_ruta');
                my.showPage();
            })
        }
    }
};
myOwn.clientSides.parseProducto={
    update: function(depot, fieldName){
        var div = html.div({class:'producto'}).create();
        div.appendChild(html.div({class:'nombre-producto'}, depot.row['productocompleto'].nombreproducto).create());
        div.appendChild(html.div({class:'especificacion-producto', 'my-collapsable':'true'}, depot.row['productocompleto'].especificacioncompleta).create());
        depot.rowControls[fieldName].innerHTML='';
        depot.rowControls[fieldName].appendChild(div);
    },
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.style.backgroundColor='';
        if (depot.row.espec_destacada){
            td.style.backgroundColor='#C5F3F3'; //celeste CLARO //formulario impreso            
        }
        depot.rowControls[fieldName].addEventListener('click', function(){
            if(my.isPreciosGridCollapsed){
                my.collapseElements();
            }
            var searchProductInput = document.getElementById('search-product-input');
            if(searchProductInput.value){
                searchProductInput.value='';
                searchProductInput.styleElement.textContent='';
            }
            setTimeout(function(){
                var top = (my.getRect(depot.rowControls[fieldName])).top;
                window.scrollTo(0,Math.max(top-96,0));
                paintSelectedRow(depot,1000);
            },200)
            setTimeout(function(){
                var top = (my.getRect(depot.rowControls[fieldName])).top;
                window.scrollTo(0,Math.max(top-96,0));
            },400)
        })
    }
};
myOwn.clientSides.parseObservacion={
    update: function(depot, fieldName){
        depot.rowControls[fieldName].title=depot.row[fieldName];
        depot.rowControls[fieldName].textContent=depot.row.observacion==1?null:depot.row.observacion;
        depot.rowControls[fieldName].style.borderLeft='0px solid transparent';
        depot.rowControls.producto_div.style.borderRight='0px solid transparent';
    },
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.style.backgroundColor='';
        if (depot.row.espec_destacada){
            td.style.backgroundColor='#C5F3F3'; //celeste CLARO //formulario impreso            
        }
    }
};

myOwn.clientSides.parseAtributosAnteriores={
    update: function(depot, fieldName){
        
    },
    prepare: function(depot, fieldName){
        var observationsButton = html.button({class:'add-observation-button'},'Obs').create();
        observationsButton.addEventListener('click', function(){
            return promptPromise('Observaciones', depot.rowControls['comentariosrelpre'].getTypedValue(),{
                withCloseButton:true,
                inputDef:{ lines:4 },
                underElement:observationsButton,
                setAttrs:{device:'mobile'}
            }).then(function(text){
                depot.rowControls['comentariosrelpre'].setTypedValue(text||null,true);
            }).catch(function(err){
                if(!DialogPromise){
                    return alertPromise(err.message);
                }
            });
        });
        depot.rowControls[fieldName].innerHTML='';
        depot.rowControls[fieldName].appendChild(observationsButton);

        var attributesLength = depot.row['atributos_mes_anterior'].length;
        depot.rowControls['producto_div'].rowSpan+= attributesLength;
        depot.rowControls['observacion_div'].rowSpan+= attributesLength;
        depot.atributosAnterioresTds=[];
        depot.row['atributos_mes_anterior'].forEach(function(attribute, i){
            depot.manager.createExtraRow(depot, depot.manager.dom.table.tBodies[0]);
            var extraRow = depot.extraRows[i];
            var td = html.td({'my-collapsable':'true'}).create();
            extraRow.appendChild(td);
            depot.atributosAnterioresTds[attribute.nombreatributo]= td;
            var extraCell0 = extraRow.cells[0];
            extraCell0.setAttribute('my-collapsable','true');
            extraCell0.setAttribute('my-colname',fieldName);
            extraCell0.textContent = attribute.nombreatributo;
        });
        //var dpmmlines = DialogPromise.simplificateText(likeAr(depot.row['productocompleto']).join(' ').toLowerCase());
        var dpmmlines = DialogPromise.simplificateText(depot.row['productocompleto'].nombreproducto.toLowerCase());
        depot.tr.setAttribute("dpmmLines-prices", dpmmlines);
        depot.extraRows.forEach(function(extraRow){
            extraRow.setAttribute("dpmmLines-prices", dpmmlines);
        });
    }
};
myOwn.clientSides.parseTipoPrecioAnterior={
    update: function(depot, fieldName){
    },
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.style.backgroundColor='';
        if (depot.row.tipoprecioanterior === 'N'){
            td.style.backgroundColor='#33E6FF'; //celeste //formulario impreso            
        }
        if (depot.row.sinpreciohace4meses === 'S'){
            td.style.backgroundColor='#24E711'; //verde //formulario impreso            
        }       
        depot.row['atributos_mes_anterior'].forEach(function(attribute, i){
            var extraRow = depot.extraRows[i];
            var extraCell1 = extraRow.cells[1];
            extraCell1.colSpan = 2;
            extraCell1.setAttribute('my-colname','atributo_anterior');
            extraCell1.textContent=attribute.valor?attribute.valor:'-';
        })
    }
};

myOwn.clientSides.parsePrecioAnterior={
    update: function(depot, fieldName){        
        depot.rowControls[fieldName].textContent=depot.row.ultimoperiodoconprecio||depot.row.precioanterior;
    },
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        if(depot.row.ultimoperiodoconprecio){
            td.style.fontSize='95%';
            //td.style.align='left';
        }
        td.style.backgroundColor='';        
        if (depot.row.tipoprecioanterior === 'N'){
            td.style.backgroundColor='#33E6FF'; //celeste //formulario impreso            
        }
        if (depot.row.sinpreciohace4meses === 'S'){
            td.style.backgroundColor='#24E711'; //verde //formulario impreso            
        }       
    }
};

myOwn.clientSides.copiarTipoprecio={
    update: false,
    prepare: function(depot, fieldName){
        my.wait4visitaGrid.then(function(visitaGrid){
            var td = depot.rowControls[fieldName];
            if(depot.row[fieldName]){ //tengo configurada la flecha desde BBDD
                td.style.cursor='pointer';
                td.addEventListener('click', function(){
                    if(visitaGrid.depots[0].row['razones__espositivoformulario'] == 'S'){
                        var tipoPrecioTd = depot.rowControls['tipoprecio'];
                        var tipoprecioanterior = depot.row['tipoprecioanterior'];
                        var nombretipoprecioanterior = depot.row['tipopre_encuestador_anterior__nombretipoprecio'];
                        if(tipoPrecioTd.dialogPromiseSetup){
                            tipoPrecioTd.dialogPromiseSetup.message = tipoPrecioTd.dialogPromiseSetup.message.replace('$$tipoprecio', tipoprecioanterior);
                            tipoPrecioTd.dialogPromiseSetup.message = tipoPrecioTd.dialogPromiseSetup.message.replace('$$nombretipoprecio', nombretipoprecioanterior);
                        }
                        tipoPrecioTd.setTypedValue(tipoprecioanterior, true);
                    }
                });
            }else{
                if(depot.row['repregunta']=='R'){
                    td.style.backgroundImage = 'url(img/repregunta.png)';
                    td.style.backgroundRepeat = 'no-repeat';
                }
            }
        })
    }
};

myOwn.copiarAtributos = function copiarAtributos(precioDepot, setNull){
    my.showPendentsButton.disabled = false;
    var fixedFields = precioDepot.def.primaryKey.map(function(fname){
        return {fieldName: fname, value: precioDepot.row[fname]};
    })
    var dummyElement = html.div().create();
    var grid=my.tableGrid('mobile_atributos',dummyElement,{fixedFields:fixedFields});
    grid.waitForReady().then(function(){
        //actualizo caché atributos
        updateAtributesCache(grid.depots.map(function(depot){return depot.row}));
        var promisesArray = []
        precioDepot.row['atributos_mes_anterior'].forEach(function(atributo,i){
            //grid.depots[i].rowControls['valor'].setTypedValue(atributo.valor, true)
            grid.depots[i].row['valor']=setNull?null:atributo.valor;
            promisesArray.push(
                grid.depots[i].connector.saveRecord(grid.depots[i],{})
            );
        });
        Promise.all(promisesArray).then(function(){
            var fieldDef = precioDepot.def.field['precio'];
            my.clientSides[fieldDef.clientSide].update(precioDepot, fieldDef.name);    
        })
    });
    precioDepot.row['atributos_mes_anterior'].forEach(function(attribute,i){
        var extraRow = precioDepot.extraRows[i];
        var extraCell3 = extraRow.cells[i==0?3:2];
        var value = setNull?null:attribute.valor;
        extraCell3.textContent=value?value:'-';
    })
}

myOwn.clientSides.parsePrecio={
    update: function(depot, fieldName){
        //normalizo precio
        if(depot.row.precio==0){
            depot.rowControls['precio'].setTypedValue(null,true)
        }
        if(depot.row.precio){
            var vtope=0;
            var vacumulador = [];
            vacumulador[vtope]=depot.row.precio;
            //if (depot.row['producto']=='P0115323') {
            //    console.log('normalizo precio');
            //    console.log('vacumulador[vtope] Precio ' , vacumulador[vtope]);
            //}
            depot.row['atributos_para_normalizar'].forEach(function(attribute,i){
                if (attribute['normalizable']=='S'){
                    vtope++;
                    if (attribute['tiponormalizacion']=='Moneda'){
                        attribute['valor']=String(attribute['valor_pesos'])
                    }
                    if (!isNaN(parseFloat(attribute['valor']))){
                        vacumulador[vtope]=attribute['valor']
                    }else{
                        vacumulador[vtope]=null                    
                    }
                    var voperacion=attribute['tiponormalizacion'].split(",");
                    voperacion.forEach(function(operacion){
                        //if (depot.row['producto']=='P0115323') {
                        //    console.log(depot.row['productocompleto'].nombreproducto);
                        //    console.log('operacion ' , operacion);
                        //    console.log('Normalizacion, vacumulador[vtope] Valor del atributo ' , vacumulador[vtope]);
                        //    console.log('Normalizacion Valor normal ' , attribute['valornormal']);
                        //}
                        switch (operacion){
                            case '+':
                                vacumulador[vtope-1]=vacumulador[vtope-1]+vacumulador[vtope];
                                vtope=vtope -1;
                                break;
                            case '*':
                                vacumulador[vtope-1]=vacumulador[vtope-1]*vacumulador[vtope];
                                vtope=vtope -1; 
                                break;
                            case '1#':
                                vtope=vtope +1;
                                vacumulador[vtope]=1;
                                break;
                            case '2/':
                                vacumulador[vtope]=vacumulador[vtope]/2;
                                break;
                            case '6/':
                                vacumulador[vtope]=vacumulador[vtope]/6;   
                                break;
                            case '12/':
                                vacumulador[vtope]=vacumulador[vtope]/12;   
                                break;
                            case '100/':
                                vacumulador[vtope]=vacumulador[vtope]/100;   
                                break;
                            case 'Normal':
                                if (vacumulador[vtope] != null && vacumulador[vtope]!=0){
                                    vacumulador[vtope-1]=vacumulador[vtope-1]/vacumulador[vtope]*attribute['valornormal'];
                                    vtope=vtope-1;
                                }else{
                                    vacumulador[vtope-1]=null;
                                    vtope=vtope-1;
                                }
                                break;
                            case 'Moneda':
                                vacumulador[vtope-1]=vacumulador[vtope-1]*vacumulador[vtope]*attribute['valornormal'];
                                vtope=vtope-1;
                                break;
                            case 'Bonificar':
                                vacumulador[vtope-1]=vacumulador[vtope-1]*(100.0 - (vacumulador[vtope]||0))/100.0;
                                vtope=vtope-1;
                                break;
                            case '#': 
                                null;
                                break;
                            default:
                                throw new Error('Operador no considerado ' + operacion);
                        }
                        //if (depot.row['producto']=='P0115323') {
                        //    console.log('Normalizacion, vacumulador[vtope] despues de normalizar ' , vacumulador[vtope]);
                        //}
                    });
                    if (vtope != 0){
                       throw new Error('Queda informacion en el acumulador que no fue utilizada ' + vtope);
                    };
                    //depot.row['precionormalizado']=vacumulador[vtope];
                }
            });
            depot.row['precionormalizado']=vacumulador[vtope];
        };
        //normalizo precio
        myOwn.clientSides.control_precio.update(depot,fieldName);
    },
    prepare: function(depot, fieldName){
        myOwn.clientSides.control_precio.prepare(depot,fieldName);
    }
}

myOwn.clientSides.parseTipoPrecio={
    update: function(depot, fieldName){
        var tipoPrecioTd = depot.rowControls[fieldName];
        tipoPrecioTd.contentEditable=false;
        tipoPrecioTd.editOnlyFromList=true;
        var precioTd = depot.rowControls['precio']
        if(!my.disableUpdatePrices){
            my.wait4visitaGrid.then(function(visitaGrid){
                if(visitaGrid.depots[0].row['razones__espositivoformulario'] == 'N'){
                    precioTd.disable(true);
                    depot.rowControls[fieldName].editOnlyFromList=false;
                }else{
                    depot.rowControls[fieldName].editOnlyFromList=true
                    precioTd.disable(false);
                }
            })
        }

        var ignoreValues = getTiposPrecioPositivosFromLocalStorage();
        var opts = {
            buttonsDef:[{
                label:'No',
                value: false
            },{
                label:'Borrar',
                value:true,
                attributes: {delete: true}
            }],
            setAttrs:{device:'mobile'},
        };
        var message = "Usted eligió tipo de precio \"$$tipoprecio\" " + "$$nombretipoprecio" + ". \n Se borrará el precio";
        var preDialogFun = function preDialogFun(typedControl, typedValue){
            return Promise.resolve().then(function(){
                var tipoprecio = getTipoPrecioByTipoFromLocalStorage(typedValue);
                typedControl.dialogPromiseSetup.message = typedControl.dialogPromiseSetup.message.replace('$$tipoprecio', tipoprecio.tipoprecio);
                typedControl.dialogPromiseSetup.message = typedControl.dialogPromiseSetup.message.replace('$$nombretipoprecio', tipoprecio.nombretipoprecio);
            })
        }
        if(depot.row['tipoprecio']){
            var dialogPromiseSetup = {
                message: message, 
                opts: opts, 
                ignoreValues: ignoreValues, 
                dialogType: 'confirmPromise',
                preDialogFun: preDialogFun
            };
            tipoPrecioTd.setDialogPromiseSetup(dialogPromiseSetup);
        }
        var priceTd = depot.rowControls['precio'];
        if(depot.row[fieldName] && depot.row['tipopre__espositivo'] == 'N'){
            priceTd.style.display='none';
        }else{
            priceTd.style.display='block';
        }
        if(depot.row['tipopre__espositivo'] == 'S'){
            likeAr(depot.atributosActualesTds).forEach(function(attributeTd){
                attributeTd.style.cursor='pointer';
                attributeTd.onclick=function(){
                    var div = html.div({id:'grilla-atributos'}).create();
                    var params = getParamsFromRow(depot.row,['periodo', 'informante', 'visita', 'formulario','panel','tarea', 'producto', 'observacion']);
                    var wait4atributosGrid=myOwn.wScreens.atributos.mainAction(params, div, depot);
                    var elementForReplace = document.getElementById('main_layout');
                    var scrollY = window.scrollY;
                    var refreshPrecio=function(){
                        var fixedFields = ['periodo','informante','visita', 'formulario','producto','observacion'].map(function(fname){
                            return {fieldName: fname, value: depot.row[fname]};
                        });
                        var Connector = my.offline.mode?my.TableConnectorLocal:my.TableConnector; 
                        var dummyElement = html.div().create();
                        var conn=new Connector({
                            my:my, 
                            tableName: 'mobile_atributos', 
                            getElementToDisplayCount:function(){ return dummyElement; },
                        }, {fixedFields: fixedFields});
                        conn.getStructure();
                        conn.getData().then(function(attributes){
                            //Actualizo caché de atributos
                            updateAtributesCache(attributes);
                            attributes.forEach(function(attribute){
                                var td = depot.atributosActualesTds[attribute.nombreatributo];
                                td.textContent = attribute.valor?attribute.valor:'-';
                            })
                            myOwn.clientSides.parsePrecio.update(depot, 'precio');
                            depot.row['cambio'] = 'C';
                            depot.connector.saveRecord(depot,{})
                        });
                    };
                    wait4atributosGrid.then(function(atributosGrid){
                        atributosGrid.dom.main.addEventListener('savedRowOk',refreshPrecio)
                        my.showPendentsButton.disabled = false;
                    });
                    my.disableUpdatePrices = true;
                    window.scrollTo(0,0);
                    alertPromise(div,{
                        reject:false, 
                        replacingElement:elementForReplace, 
                        setAttrs:{'my-alert-promise':'atributos'}, 
                        withCloseButton: false,
                        buttonDef:{label:LEFTARROW, value:true, attributes:{class:'back-button'}}
                    }).then(function(){
                        my.wait4preciosGridFromAtributos = null;
                        my.wait4atributosGrid = null;
                        my.disableUpdatePrices = false;
                        window.scrollTo(0,scrollY);
                    });
                }
            })
        }else{
            depot.row['cambio'] = null;
            likeAr(depot.atributosActualesTds).forEach(function(attributeTd){
                quitarClick(attributeTd)
            })
        }
    },
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.disable(true);
        td.autoExpander=true;
        td.contentEditable=false;
        td.editOnlyFromList=true;
        td.addEventListener('click', function(event){
            my.autoShowReferences(depot, fieldName);
            event.preventDefault();
        });
        depot.atributosActualesTds=[];
        depot.row['atributos_mes_actual'].forEach(function(attribute,i){
            var extraRow = depot.extraRows[i];
            if(i==0){
                extraRow.appendChild(html.td({'my-collapsable':'true', class: 'flecha-copiar', rowspan: depot.row['atributos_mes_anterior'].length},RIGHTARROW).create());
                extraRow.cells[2].style.cursor='pointer';
                extraRow.cells[2].addEventListener('click', function(){
                    my.wait4visitaGrid.then(function(visitaGrid){
                        setTimeout(function(){
                            if(visitaGrid.depots[0].row['razones__espositivoformulario'] == 'S' && 
                                (depot.row['tipoprecio'] && depot.row['tipopre__espositivo'] == 'S'
                                   || depot.row.precio>0 || depot.rowControls.precio.getTypedValue()>0
                            ){
                                my.copiarAtributos(depot, false);
                            }
                        },200);
                    });
                });
            }
            var td = html.td({'my-collapsable':'true'}).create();
            depot.atributosActualesTds[attribute.nombreatributo]= td;
            extraRow.appendChild(td);
            var extraCell3 = extraRow.cells[i==0?3:2];
            extraCell3.colSpan=2;
            extraCell3.setAttribute('my-colname','atributo_actual');
            if(my.offline.mode){
                if(my.wait4attributes4Grid){
                    my.wait4attributes4Grid.then(function(allAttributes){
                        myAttribute = allAttributes.find(function(attr){
                            return attr.periodo == depot.row['periodo'] && 
                                attr.informante == depot.row['informante'] && 
                                attr.visita == depot.row['visita'] && 
                                attr.formulario == depot.row['formulario'] && 
                                attr.producto == depot.row['producto'] && 
                                attr.observacion == depot.row['observacion'] && 
                                attr.atributo == attribute.atributo
                        });
                        extraCell3.textContent=myAttribute.valor?myAttribute.valor:'-';
                    });
                }
            }else{
                extraCell3.textContent=attribute.valor?attribute.valor:'-';
            }
        })
        
        var tipoPrecioTd = depot.rowControls[fieldName];
        tipoPrecioTd.addEventListener('update', function(){
            //saco de localstorage para que funcione focus en iPad ya que el row aún no está actualizado
            //ipad 12 anda, 9.3.5 no
            var tiposPreciosPositivos = getTiposPrecioPositivosFromLocalStorage()
            if(tiposPreciosPositivos.includes(tipoPrecioTd.getTypedValue())){
                var priceTd = depot.rowControls['precio'];
                priceTd.style.display='block';
                priceTd.focus();
            }
        })
        depot.tr.addEventListener('savedRowOk', function(){
            var priceTd = depot.rowControls['precio'];
            if(depot.row[fieldName] && depot.row['tipopre__espositivo'] == 'N'){
                priceTd.setTypedValue(null,true)
                if(my.offline.mode){
                    my.copiarAtributos(depot, true);
                }
            }
            if(depot.row['precio'] !=null && depot.row[fieldName] == null){
                tipoPrecioTd.setTypedValue('P', true);
            }
            my.showPendentsButton.disabled = false;
            myOwn.clientSides.parsePrecio.update(depot, 'precio');
        });
    }
};
/*Fin Pantalla Precios */

/*Inicio Pantalla Atributos */
myOwn.wScreens.atributos={
    parameters:[
        {name:'periodo'            , typeName:'text'   , references:'periodos'},
        {name:'panel'              , typeName:'integer'},
        {name:'tarea'              , typeName:'integer'},
        {name:'informante'         , typeName:'integer'},
        {name:'formulario'         , typeName:'integer'},
        {name:'visita'             , typeName:'integer'},
        {name:'producto'           , typeName:'text', references:'productos'},
        {name:'observacion'        , typeName:'integer'},
    ],
    mainAction:function(params,divResult, precioDepotOriginal){
        var layout = html.div({id: "mobile-layout-atributos", class: "mobile-main-layout"}).create()
        divResult.appendChild(layout);
        layout.appendChild(html.div({id: "title"}, 'Atributos producto').create());

        var fixedFields = likeAr(params).map(function(value, attrName){
            return {fieldName: attrName, value: value};
        }).array();
    
        var gridPrecioDiv = html.div({class: "grid-mobile"}).create();
        layout.appendChild(gridPrecioDiv);  

        var preciosGrid=my.tableGrid('mobile_precios',gridPrecioDiv,{tableDef:{
            hiddenColumns:['productos__nombreproducto', 'tipopre_encuestador_anterior__nombretipoprecio', 'tipopre_encuestador_anterior__espositivo', 'tipopre__nombretipoprecio', 'tipopre__espositivo','copiar_tipoprecio', 'atributos', 'comentariosrelpre', 'observacion_div'],
            field:{
                tipoprecio:{allow: {update: false}},
                precio:{allow: {update: false}}
            },
            gridAlias: 'precio-from-atributos'
        }, fixedFields:fixedFields});
        
        my.wait4preciosGridFromAtributos = Promise.resolve().then(function(){
            return preciosGrid.waitForReady().then(function(){
                var precioDepot = preciosGrid.depots[0];
                precioDepot.extraRows.forEach(function(td){
                    td.style.display = 'none';
                });
                precioDepot.rowControls['producto_div'].rowSpan = 1;
                layout.appendChild(html.div({id:'attributes-observations'}, 
                    [
                        html.div({id:'attributes-observations-title'}, 'Observaciones'),
                        precioDepot.rowControls['comentariosrelpre']
                    ]
                ).create());
                //actualizo observaciones en la grilla original
                precioDepot.tr.addEventListener('savedRowOk', function(){
                    precioDepotOriginal.rowControls['comentariosrelpre'].setTypedValue(precioDepot.rowControls['comentariosrelpre'].getTypedValue(),true);
                    //cambiamos tambien el row para no esperar el evento update de typed-controls
                    precioDepotOriginal.row['comentariosrelpre']=precioDepot.row['comentariosrelpre'];
                    myOwn.clientSides.parsePrecio.update(precioDepotOriginal, 'precio');		
                })
                return preciosGrid;
            })
        });
        var gridMobileDiv = html.div({class: "grid-mobile"}).create();
        layout.appendChild(gridMobileDiv);  
      
        var grid=my.tableGrid('mobile_atributos',gridMobileDiv,{tableDef:{
            hiddenColumns:['atributo', 'tipodato'],
        }, fixedFields:fixedFields});

        my.wait4atributosGrid = Promise.resolve().then(function(){
            return grid.waitForReady().then(function(){
                return grid;
            });
        })
        return my.wait4atributosGrid;
    }
};

myOwn.autoSetupFunctions.push(function autoSetupMyTables(){
    var my=this;
    TypedControls.showLupa=false;
    TypedControls.Expanders.unshift({
        whenType: function(typedControl){ 
            var typeInfo = typedControl.controledType.typeInfo;
            return typeInfo.references && typeInfo.name=='tipoprecio';
        },
        dialogInput:function(typedControl){
            var dialogHeight = 450;
            //No entra en la pantalla
            if(my.getRect(typedControl).top - window.scrollY + dialogHeight > document.documentElement.clientHeight){
                //si no hay lugar abajo
                if(my.getRect(typedControl).top + dialogHeight > document.documentElement.scrollHeight){
                    document.body.style.height = document.documentElement.scrollHeight + dialogHeight + 'px';
                }
                window.scrollTo(0,(my.getRect(typedControl).top)-100);
                my.wait4preciosGrid.then(function(preciosGrid){
                    var myDepot = preciosGrid.depots.find(function(depot){
                        return depot.rowControls['tipoprecio'] === typedControl
                    })
                    paintSelectedRow(myDepot, 5000);
                })            
            }
            return myOwn.ExpanderReferences.dialogInput(typedControl)
        }
    });
    TypedControls.Expanders.unshift({
        whenType: function(typedControl){ 
            var typeInfo = typedControl.controledType.typeInfo;
            return typeInfo.references && typeInfo.name=='razon';
        },
        dialogInput:function(typedControl){
            return myOwn.ExpanderReferences.dialogInput(typedControl)
        }
    });
    TypedControls.Expanders.unshift({
        whenType: function(typedControl){ 
            var typeInfo = typedControl.controledType.typeInfo;
            if(typeInfo.name=='valor'){
                typeInfo.references = 'prodatrval';
                return true;
            }
            return typeInfo.references && typeInfo.name=='valor';
        },
        dialogInput:function(typedControl){
            return my.wait4atributosGrid.then(function(atributosGrid){
                var myDepot = atributosGrid.depots.find(function(depot){
                    return depot.rowControls['valor'] === typedControl
                })
                if(myDepot.row['opciones']!= 'N'){
                    var fixedFields = ['producto','atributo'].map(function(fname){
                        return {fieldName: fname, value: myDepot.row[fname]};
                    });
                    var othersValue = '__othersRow';
                    var opts = {};
                    opts.reference = {
                        fixedFields: fixedFields,
                        getValue: function getValue(row){
                            if(row.valor == othersValue){
                                return null;
                            }else{
                                return row.valor.toUpperCase();
                            }
                        },
                        getLabels: function getLabels(row, includePk){
                            var valor = (row.valor == othersValue)?'otro valor':row.valor;
                            return [valor.toUpperCase()];
                        }
                    };
                    if(myDepot.row['opciones']=='A'){
                        opts.extraRow = {valor:othersValue}
                    }
                    return myOwn.ExpanderReferences.dialogInput(typedControl,opts);
                }
            })   
        }
    });
});

/*Fin Pantalla Atributos */
my.mobileMode = true;

myOwn.clientSides.habilitarSincronizacion={
    update: false,
    prepare: function(depot, fieldName){
        var td = depot.rowControls[fieldName];
        var boton = html.button({class:'boton-sincronizacion'},'sincronizar').create();
        td.appendChild(boton);
        boton.onclick=function(){
            my.ajax.sincronizacion_habilitar({
                periodo: depot.row.periodo,
                panel: depot.row.panel,
                tarea: depot.row.tarea,
                encuestador: depot.row.encuestador,
            }).then(function(){
                //depot.manager.retrieveRowAndRefresh(depot);
                //REVISAR
                var scrollY = window.scrollY;
                depot.manager.prepareAndDisplayGrid().then(function(){
                    scrollTo(0,scrollY);
                })
            })
        }
    }
}

myOwn.wScreens.preparar_instalacion={
    parameters:[
        {name:'numero_encuestador'       , typeName:'text'   },
        {name:'numero_ipad'              , typeName:'text'   }
    ],
    mainAction:function(params,divResult){
        return my.ajax.instalacion_preparar({
            numero_encuestador: params.numero_encuestador,
            numero_ipad: params.numero_ipad,
            fecha_ipad: datetime.now()
        }).then(function(result){
            console.log(result)
            var ok = true;
            if(result.tiene_ipad_sin_descargar.length){
                ok = false;
                var ipadSinDescargar = result.tiene_ipad_sin_descargar[0];
                if(ipadSinDescargar){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'danger'},'El encuestador ' + ipadSinDescargar.nombre_encuestador + 
                            ' ' + ipadSinDescargar.apellido_encuestador + ' tiene el ipad ' + 
                                ipadSinDescargar.ipad + ' sin descargar!'
                            )
                        ])
                    .create());
                }
            }
            if(result.tiene_otro_ipad.length){
                ok = false;
                var ipadAnteriorAsignado = result.tiene_otro_ipad[0];
                if(ipadAnteriorAsignado){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'warning'},'El encuestador ' + ipadAnteriorAsignado.nombre_encuestador + 
                                ' ' + ipadAnteriorAsignado.apellido_encuestador + ' ya tiene el ipad ' + 
                                ipadAnteriorAsignado.ipad + ' asignado.'
                            )
                        ]).create()
                    );
                }
            }
            if(result.supera_tolerancia){
                ok = false;
                divResult.appendChild(
                    html.p({},[
                        html.span({class:'danger'},'Configurar correctamente fecha y hora del dispositivo para continuar la instalación.'
                        )
                    ]).create()
                );
            }else{
                if(result.supera_advertencia){
                    ok = false;
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'warning'},'Revisar fecha y hora del dispositivo.'
                            )
                        ]).create()
                    );
                }
                if(ok){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'all-ok'},'No hay advertencias, presione instalar para confirmar instalacion.'
                            )
                        ]).create()
                    );
                }
                var installButton = html.button({class:'load-ipad-button'},'instalar').create();
                divResult.appendChild(installButton);
                installButton.onclick=function(){
                    var message = 'confirma instalación para encuestador ' + params.numero_encuestador + ', ipad ' + params.numero_ipad + '?';
                    confirmPromise(message).then(function(){
                        installButton.disabled=true;
                        return install(params.numero_encuestador, params.numero_ipad, divResult);
                    });
                }
            }
            return 'ok'
        }).catch(function(err){
            divResult.appendChild(html.p('no se pudo instalar el dispositivo. ' + err.message).create());
            return 'ok'
        })
    }
};

function install(numeroEncuestador, numeroIpad, divResult){
    var waitGif=html.img({src:'img/loading16.gif'}).create()
    divResult.appendChild(waitGif);
    divResult.appendChild(html.p('instalando dispositivo...').create());
    return my.ajax.instalacion_crear({
        numero_encuestador: numeroEncuestador,
        numero_ipad: numeroIpad,
        token_original: localStorage.getItem('token_instalacion'),
        version_sistema: getVersionSistema()
    }).then(function(token){
        localStorage.setItem('token_instalacion', token.token_instalacion);
        localStorage.setItem('encuestador', token.encuestador);
        localStorage.setItem('ipad', token.ipad);
        localStorage.removeItem('descargado');
        localStorage.removeItem('vaciado');
        divResult.appendChild(html.p('creando base de datos local ...').create());
        return prepareStructures().then(function(){
            divResult.appendChild(html.p('instalacion finalizada! Ya puede sincronizar el dispositivo.').create());
            waitGif.style.display = 'none';
            return 'ok'
        });
    }).catch(function(err){
        divResult.appendChild(html.p('no se pudo instalar el dispositivo. ' + err.message).create());
        return 'ok'
    })
}


function prepareStructures(){
    var createConnectorForTable = function createConnectorForTable(tableName){
        var dummyElement = html.div().create();
        var Connector = my.TableConnector; 
        var connector=new Connector({
            my:my, 
            tableName: tableName, 
            getElementToDisplayCount:function(){ return dummyElement; },
            activeOnly: true
        });
        return connector;
    }
    //registro las definiciones de las tablas
    var opts = {
        registerInLocalDB: true, 
        waitForFreshStructure: true
    }
    var promiseChain = Promise.resolve();
    promiseChain=promiseChain.then(function(){
        var connector=createConnectorForTable('mobile_hoja_de_ruta');
        return connector.getStructure(opts)
    })
    promiseChain=promiseChain.then(function(){
        var connector=createConnectorForTable('prodatrval');
        return connector.getStructure(opts);
    })
    /*promiseChain=promiseChain.then(function(){
        var allStructures = [];
        var connector=createConnectorForTable('mobile_hoja_de_ruta');
        wait4AllStructures=connector.getStructure().then(function(structure){
            return my.getStructuresToRegisterInLdb(structure,[]).then(function(structuresToRegister){
                allStructures = allStructures.concat(structuresToRegister);
                return allStructures;
            })
        })
        var connector=createConnectorForTable('prodatrval');
        wait4AllStructures = wait4AllStructures.then(function(){
            return connector.getStructure().then(function(structure){
                return my.getStructuresToRegisterInLdb(structure,[]).then(function(structuresToRegister){
                    allStructures = allStructures.concat(structuresToRegister);
                })
            })
        })
        wait4AllStructures.then(function(){
            var anotherPromiseChain=Promise.resolve();
            allStructures.forEach(function(structureToRegister){
                anotherPromiseChain = anotherPromiseChain.then(function(){
                    return my.ldb.registerStructure(structureToRegister);
                });
            });
            return anotherPromiseChain;
        });
        return wait4AllStructures;
    });*/

    /*promiseChain=promiseChain.then(function(){
        var connector=createConnectorForTable('prodatrval');
        return connector.getStructure().then(function(structure){
            return my.getStructuresToRegisterInLdb(structure,[]).then(function(structuresToRegister){
                var anotherPromiseChain=Promise.resolve();
                structuresToRegister.forEach(function(structureToRegister){
                    anotherPromiseChain = anotherPromiseChain.then(function(){
                        return my.ldb.registerStructure(structureToRegister);
                    });
                });
                return anotherPromiseChain;
            })
        })
    });*/
    promiseChain=promiseChain.then(function(){
        return saveReferenceTableInLocalStorage('tipopre_encuestador');
    });
    promiseChain=promiseChain.then(function(){
        return saveReferenceTableInLocalStorage('razones_encuestador');
    });
    return promiseChain;
}
function cargarDispositivo(tokenInstalacion, encuestador){
    var mainLayout = document.getElementById('main_layout');
    return my.ajax.hojaderuta_traer({
        token_instalacion: tokenInstalacion
    }).then(function(reltarHabilitada){
        if(reltarHabilitada){
            var periodo = reltarHabilitada.periodo;
            var panel = reltarHabilitada.panel;
            var tarea = reltarHabilitada.tarea;
            // como esto se ejecuta desde el ipad y el ipad se esta cargando hay que confirmar la CARGA del panel
            return confirmPromise('confirma carga del período ' + periodo + ', panel ' + panel + ', tarea ' + tarea).then(function(){
                // una vez que confirmo debe deshabilitarse el boton cargar (para no confundir al usuario)
                // el boton debe habilitarse al final (tanto por error como por exito)
                if(my.offline.mode){
                    throw new Error('No se puede asignar una tarea en modo avion');
                }
                mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
                var installStatus = html.p('preparando base de datos local, por favor espere...').create();
                mainLayout.appendChild(installStatus);
                return prepareStructures().then(function(){
                    var promiseChain = Promise.resolve();
                    return my.ajax.tareamodoavion_crear({
                        periodo: periodo,
                        panel: panel,
                        tarea: tarea,
                        token_instalacion: tokenInstalacion
                    },{informProgress: function(result){
                        var tableName = result.tableName;
                        var data = result.data;
                        if(tableName=='mobile_hoja_de_ruta' && result.data[0]){
                            localStorage.setItem('nombreencuestador', result.data[0]['nombreencuestador']);
                        }
                        promiseChain = promiseChain.then(function(){
                            installStatus.textContent = installStatus.textContent + '.';
                            mainLayout.appendChild(html.p('cargando datos en tabla ' + tableName + ', por favor espere...').create());
                            return my.ldb.putMany(tableName,data)
                        })
                    }}).then(function(){
                        return promiseChain.then(function(){
                            localStorage.setItem('descargado',JSON.stringify(false));
                            mainLayout.appendChild(html.p('Carga completa!, pasando a modo avion...').create());
                            localStorage.setItem('periodo', periodo);
                            localStorage.setItem('panel', panel);
                            localStorage.setItem('tarea', tarea);
                            localStorage.setItem('vaciado',JSON.stringify(false));
                            var json = {
                                periodo: periodo,
                                panel: panel,
                                tarea: tarea,
                            };
                            history.replaceState(null, null, location.origin+location.pathname+my.menuSeparator+'w=hoja_de_ruta&up='+JSON.stringify(json)+'&autoproced=true');
                            my.changeOfflineMode();
                            return 'ok'
                        })
                    })
                })
            })
        }else{
            mainLayout.appendChild(html.p('La sincronización se encuentra deshabilitada o vencida para el encuestador '+ encuestador).create());
        }
    })
}

function descargarDispositivo(tokenInstalacion, encuestador){
    var mainLayout = document.getElementById('main_layout');
    var waitGif = mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
    mainLayout.appendChild(html.p([
        'descargando, por favor espere',
        waitGif
    ]).create());
    var promiseChain = Promise.resolve();
    var data = {};
    var mobileTables = ['mobile_hoja_de_ruta', 'mobile_visita', 'mobile_precios', 'mobile_atributos'];
    mobileTables.forEach(function(tableName){
        promiseChain = promiseChain.then(function(){
            return my.ldb.getAll(tableName).then(function(results){
                data[tableName] = results;
            });
        })
    });
    promiseChain = promiseChain.then(function(){
        return my.ajax.dm_descargar({
            token_instalacion: tokenInstalacion,
            data: JSON.stringify(data),
            encuestador: encuestador
        }).then(function(message){
            waitGif.style.display = 'none';
            if(message=='descarga completa'){
                localStorage.setItem('descargado',JSON.stringify(true));
            }
            mainLayout.appendChild(html.p(message).create());
        });
    });
    return promiseChain;
}

myOwn.wScreens.sincronizar=function(){
    var mainLayout = document.getElementById('main_layout');
    var tokenInstalacion = localStorage.getItem('token_instalacion') || null;
    var ipad = localStorage.getItem('ipad') || null;
    var encuestador = localStorage.getItem('encuestador') || null;
    if(tokenInstalacion && ipad && encuestador){
        return my.ldb.existsStructure('mobile_hoja_de_ruta').then(function(existsStructure){
            if(existsStructure){
                return my.ldb.isEmpty('mobile_hoja_de_ruta').then(function(isEmptyLocalDatabase){
                    var vaciado = JSON.parse(localStorage.getItem('vaciado')||'false');
                    if(isEmptyLocalDatabase || vaciado){
                        mainLayout.appendChild(html.p('El dispositivo no tiene hoja de ruta cargada').create());
                        var loadButton = html.button({class:'load-ipad-button'},'cargar').create();
                        mainLayout.appendChild(loadButton);
                        loadButton.onclick = function(){
                            loadButton.disabled=true;
                            cargarDispositivo(tokenInstalacion, encuestador).then(function(){
                                loadButton.disabled=false;
                            },function(err){
                                alertPromise(err.message);
                                loadButton.disabled=true;
                            })
                        }
                    }else{
                        mainLayout.appendChild(html.p('El dispositivo tiene información cargada').create());
                        var downloadButton = html.button({class:'download-ipad-button'},'descargar').create();
                        var fueDescargadoAntes = JSON.parse(localStorage.getItem('descargado')||'false');
                        if(fueDescargadoAntes){
                            mainLayout.appendChild(html.p('El dispositivo ya fue descargado').create());
                        }
                        mainLayout.appendChild(downloadButton);
                        downloadButton.onclick = function(){
                            confirmPromise('¿confirma descarga de D.M.?').then(function(){
                                downloadButton.disabled=true;
                                descargarDispositivo(tokenInstalacion, encuestador).then(function(){
                                    downloadButton.disabled=false;
                                },function(err){
                                    alertPromise(err.message);
                                    downloadButton.disabled=true;
                                })
                            })
                        }
                    }
                });
            }else{
                mainLayout.appendChild(html.p('No existe la tabla mobile_hoja_de_ruta. Por favor reinstale el dispositivo').create());
            }
        })
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    }
};

myOwn.wScreens.vaciar=function(){
    var mainLayout = document.getElementById('main_layout');
    var tokenInstalacion = localStorage.getItem('token_instalacion') || null;
    var ipad = localStorage.getItem('ipad') || null;
    var encuestador = localStorage.getItem('encuestador') || null;
    if(tokenInstalacion && ipad && encuestador){
        return my.ldb.existsStructure('mobile_hoja_de_ruta').then(function(existsStructure){
            if(existsStructure){
                return my.ldb.isEmpty('mobile_hoja_de_ruta').then(function(isEmptyLocalDatabase){
                    var vaciado = JSON.parse(localStorage.getItem('vaciado')||'false');
                    if(!(isEmptyLocalDatabase || vaciado)){
                        var clearButton = html.button({class:'load-ipad-button'},'vaciar D.M.').create();
                        mainLayout.appendChild(clearButton);
                        clearButton.onclick = function(){
                            confirmPromise('¿confirma vaciado de D.M.?').then(function(){
                                clearButton.disabled=true;
                                localStorage.setItem('vaciado',JSON.stringify(true));
                            }).then(function(){
                                mainLayout.appendChild(html.p('D.M. vaciado correctamente!').create());
                            });
                        }
                    }else{
                        mainLayout.appendChild(html.p('El D.M. está vacío.').create());
                    }
                });
            }else{
                mainLayout.appendChild(html.p('No existe la tabla mobile_hoja_de_ruta. Por favor reinstale el dispositivo').create());
            }
        })
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    }
};

var appCache = window.applicationCache;
appCache.addEventListener('downloading', function(e) {
    localStorage.setItem('cache-status','downloading');
    var mainLayout = document.getElementById('main_layout');
    if(mainLayout){
        mainLayout.prepend(
            html.p({id:'cache-status'},[
                'descargando cache',
                html.img({src:'img/loading16.gif'}).create()
            ]).create()
        );
    }
}, false);

appCache.addEventListener('updateready', function (e) {
    localStorage.setItem('cache-status','ready');
    var cacheStatusElement = document.getElementById('cache-status');
    if(!cacheStatusElement){
        var mainLayout = document.getElementById('main_layout');
        cacheStatusElement = html.p({id:'cache-status'}).create();
        mainLayout.prepend(cacheStatusElement);
    }
    setTimeout(function(){
        cacheStatusElement.textContent='cache actualizada';
        setTimeout(function(){
            cacheStatusElement.style.display='none';
        }, 10000);
    }, 1000);
}, false);