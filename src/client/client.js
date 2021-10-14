"use string";

/// <reference path="../node_modules/types.d.ts/modules/typed-controls/index.d.ts" />
/// <reference path="../node_modules/types.d.ts/modules/js-to-html/index.d.ts" />

var html=require('js-to-html').html;

var TypedControls=require('typed-controls');

var my = myOwn;

my.tableAction.showImg={
    img: my.path.img+'picture.png',
    actionRow: function(depot){
        var div=depot.manager.dom.main;
        return Promise.resolve().then(function(){
            if('url' in depot.row){
                return depot.row.url;
            }
            return depot.my.ajax.getpictureurl({atomic_number:depot.row.atomic_number}).then(function(urlList){
                return urlList.length?urlList[0].url:false;
            });
        }).then(function(url){
            if(url){
                var img=html.img({src:url}).create();
                div.insertBefore(img,depot.manager.dom.table);
            }
        });
    }
};

/** @param {{nombreBoton:string; llamada:(depot:any)=>Promise<string>}} opts */
function botonClientSideEnGrilla(opts){
    return {
        prepare: function (depot, fieldName) {
            var td = depot.rowControls[fieldName];
            var boton = html.button(opts.nombreBoton).create();
            td.buttonGenerar = boton;
            td.innerHTML = "";
            td.appendChild(boton);
            var restaurarBoton = function(){
                boton.disabled=false;
                boton.textContent=opts.nombreBoton;
                boton.style.backgroundColor='';
            }
            boton.onclick=function(){
                boton.disabled=true;
                boton.textContent='procesando...';
                opts.llamada(depot).then(function(result){
                    boton.disabled=false;
                    boton.textContent='¡listo!';
                    boton.title=result;
                    boton.style.backgroundColor='#8F8';
                    var grid=depot.manager;
                    grid.retrieveRowAndRefresh(depot).then(function(){
                        setTimeout(restaurarBoton,3000);
                    },function(){
                        setTimeout(restaurarBoton,3000);
                    })
                }, function(err){
                    boton.textContent='error';
                    boton.style.backgroundColor='#FF8';
                    alertPromise(err.message).then(restaurarBoton,restaurarBoton);
                })
            }
        }
    };
}

my.clientSides.generarPeriodo = botonClientSideEnGrilla({
    nombreBoton:'generar',
    llamada:function(depot){
        return my.ajax.fechageneracionperiodo_touch({
            periodo: depot.row.periodo
        });
    }
});

my.clientSides.generarPanel = botonClientSideEnGrilla({
    nombreBoton:'generar',
    llamada:function(depot){
        return my.ajax.fechageneracionpanel_touch({
            periodo: depot.row.periodo,
            panel  : depot.row.panel
        });
    }
});

my.clientSides.calcular = botonClientSideEnGrilla({
    nombreBoton:'calcular',
    llamada:function(depot){
        return my.ajax.fechacalculo_touch({
            periodo: depot.row.periodo,
            calculo: depot.row.calculo,
        });
    }
});

my.clientSides.recuperar = botonClientSideEnGrilla({
    nombreBoton:'recuperar',
    llamada:function(depot){
        return my.ajax.precio_recuperar({
            periodo: depot.row.periodo,
            producto: depot.row.producto,
            observacion: depot.row.observacion,
            informante: depot.row.informante,
            visita: depot.row.visita,
        });
    }
});

my.esValidoAtributo = function esValidoAtributo(atributo){
    return !((atributo.prodatr__rangodesde && atributo.valor<atributo.prodatr__rangodesde) || (atributo.prodatr__rangohasta && atributo.valor>atributo.prodatr__rangohasta))
}

my.esValorNormal = function(atributo){
    return (atributo.especificaciones__mostrar_cant_um==='N' && atributo.prodatr__valornormal && atributo.valor==atributo.prodatr__valornormal)
}

my.esNormalizableSinValor = function esNormalizableSinValor(atributo, precio){
    return (atributo.prodatr__valornormal && atributo.prodatr__normalizable==='S' && atributo.valor == null && precio.precio);
}

my.clientSides.control_rangos = {
    prepare: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        td.editOnlyFromList=true;
        td.style.width='80px';
        if(depot.row['escantidad']=='S' || depot.row['prodatr__normalizable']=='S' && depot.row['tipodato']=='N'){
            //instancio otro TypeStore porque sino me cambia el postInput de todos los TDs
            td.controledType.typeInfo=TypeStore.typerFrom(td.controledType.typeInfo);
            td.controledType.typeInfo.postInput='parseDecimal';
        }
        if(depot.def.name == 'mobile_atributos' && depot.row['opciones']!='N'){
            td.disable(true);
            td.autoExpander=true;
            td.contentEditable=false;
            td.addEventListener('click', function(event){
                my.autoShowReferences(depot, fieldName);
                event.preventDefault();
            });
        }
    },
    update: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        if(depot.def.name == 'mobile_atributos' && depot.row['opciones']!='N'){
            td.disable(true);
            td.autoExpander=true;
            td.contentEditable=false;
        }
        td.style.backgroundColor='';
        //Atributo fuera de rango: #FFCE33 (amarillo
        if(my.esValidoAtributo(depot.row)||my.esValorNormal(depot.row)){
            if(depot.rowControls.prodatr__rangodesde){
                depot.rowControls.prodatr__rangodesde.style.fontWeight='';
            }            
            if(depot.rowControls.prodatr__rangohasta){
                depot.rowControls.prodatr__rangohasta.style.fontWeight='';
            }
        }else{
            td.style.backgroundColor='#FFCE33';
            if(depot.rowControls.prodatr__rangodesde){
                depot.rowControls.prodatr__rangodesde.style.fontWeight='bold';
            }
            if(depot.rowControls.prodatr__rangohasta){
                depot.rowControls.prodatr__rangohasta.style.fontWeight='bold';
            }
        }
        //Normalizable sin valor: #FF9333 (naranja)
        if(my.offline.mode){
            var key = ['periodo','informante','visita','formulario','producto','observacion'].map(function(fname){
                return depot.row[fname];
            });
            my.ldb.getOne('mobile_precios', key).then(function(precio){
                //Normalizable sin valor: #FF9333 (naranja)
                if(my.esNormalizableSinValor(depot.row,precio)){
                    var td = depot.rowControls[fieldName];
                    td.style.backgroundColor='#FF9333';    
                }
                if(my.wait4preciosGridFromAtributos){
                    my.wait4preciosGridFromAtributos.then(function(preciosGrid){
                        var depot = preciosGrid.depots[0];
                        var fieldDef = depot.def.field['precio']
                        my.clientSides[fieldDef.clientSide].update(depot, fieldDef.name);    
                    })
                }
            })
        }else{
            if(depot.row.normalizable==='S'){
                td.style.backgroundColor='#FF9333';    
            }
        }
    }
};

my.clientSides.copiar_atributo = {
    update: true,
    prepare: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        td.style.fontSize='120%';
        td.onclick=function(){
            var valor=depot.rowControls.valoranterior.getTypedValue()
            depot.rowControls.valor.setTypedValue(valor, true);
        }
    },
}
my.clientSides.control_razones = {
    prepare: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        td.style.width='80px';
        depot.rowControls[fieldName].addEventListener('update', function(){
			if (depot.rowControls.fechaingreso){
				depot.rowControls.fechaingreso.setTypedValue(bestGlobals.date.today(), true);
			}
			if (depot.rowControls.recepcionista){
				depot.rowControls.recepcionista.setTypedValue(depot.row.operadorrec, true);
			}
			if (depot.detailControls.relpre){
				depot.detailControls.relpre.divDetail=null;
			}
        })
    },
    update: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        td.style.backgroundColor='';
        if(depot.row.raz__escierredefinitivofor === 'S' || depot.row.raz__escierredefinitivoinf === 'S'){
            td.style.backgroundColor='#F18ADB'; //rosa
        }
    }
};

my.clientSides.navegar_cambio = {
    prepare: function (depot, fieldName) {
        depot.rowControls[fieldName].addEventListener('blur', function(){
            var cambio = depot.rowControls[fieldName].getTypedValue();
            if(cambio=='C'){
                var detailDef=depot.detailControls.relatr;
                if(detailDef && !detailDef.show){
                    var gridReady = detailDef.displayDetailGrid({fixedFields:detailDef.calculateFixedFields(), detailing:{}},{});
                    gridReady.then(function(grid){
                        if(grid.depots.length){
                            grid.depots[0].rowControls.valor.focus();
                        }
                    })
                }
            }
        })
    },
    update: true
};

my.clientSides.control_razones_mobile = {
    prepare: function (depot, fieldName) {
        var td = depot.rowControls[fieldName];
        td.disable(true);
        td.autoExpander=true;
        td.contentEditable=false;
        td.addEventListener('click', function(event){
            my.autoShowReferences(depot, fieldName);
            event.preventDefault();
        });
        my.clientSides.control_razones.prepare(depot, fieldName);
    },
    update: function (depot, fieldName) {
        my.clientSides.control_razones.update(depot, fieldName);
    }
};

my.clientSides.control_precio = {
    prepare: function (depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.style.width='90px';
    },
    update: function (depot, fieldName){
        var td = depot.rowControls[fieldName];
        td.style.backgroundColor='';
        if (depot.row.tipoprecio === 'S' && depot.row.sinpreciohace4meses === 'S'){
            td.style.backgroundColor='#3399FF'; //azul            
        }
        var normsindato;
        var fueraderango;
        /*
        var agregarVisitaTd = depot.rowControls['agregarvisita'];
        if (depot.row.puedeagregarvisita === 'N'){
            agregarVisitaTd.disabled = "true";
        }else{
            agregarVisitaTd.disabled = "false";
		}
        */
        var myPromise = Promise.resolve();
        if(my.offline.mode){
            var key = ['periodo','informante','visita', 'formulario', 'producto','observacion'].map(function(fname){
                return depot.row[fname];
            });
            myPromise = myPromise.then(function(){
                return my.ldb.getChild('mobile_atributos', key).then(function(atributos){
                    atributos.forEach(function(atributo, i){
                        var attrTd = depot.atributosActualesTds[atributo.nombreatributo];
                        if(!my.esValidoAtributo(atributo) && !my.esValorNormal(atributo) && depot.row['tipopre__espositivo'] == 'S'){
                            attrTd.style.backgroundColor='#FFCE33';
                            fueraderango = "S";
                        }
                        if(my.esNormalizableSinValor(atributo,depot.row)){
                            normsindato = "S";
                            attrTd.style.backgroundColor='#FF9333';
                        }
                        if(fueraderango!="S" && normsindato != "S"){
                            attrTd.style.backgroundColor='#FFFFFF';
                        }
                    });
                });
            })
        }else{
            normsindato = depot.row.normsindato;
            fueraderango = depot.row.fueraderango;
        }
        
        myPromise = myPromise.then(function(){
            var tieneAdvertencias;
            if(depot.row.precio &&
               (((depot.row.comentariosrelpre == null && my.offline.mode || !my.offline.mode)  && depot.row.precionormalizado_1 && (depot.row.precionormalizado < depot.row.precionormalizado_1/2 || depot.row.precionormalizado > depot.row.precionormalizado_1*2)) ||
                ((depot.row.comentariosrelpre == null && my.offline.mode || !my.offline.mode)  && depot.row.promobs_1 && (depot.row.precionormalizado < depot.row.promobs_1/2 || depot.row.precionormalizado > depot.row.promobs_1*2)) ||
                normsindato === 'S' || fueraderango === 'S'
               )
            ){
                td.style.backgroundColor='#FF9333'; //naranja
                tieneAdvertencias = true;
            }else{
                td.style.backgroundColor='#FFFFFF'; //blanco
                tieneAdvertencias = false;
            }
            if(my.offline.mode && tieneAdvertencias != depot.row.adv){
                depot.row['adv'] = tieneAdvertencias;
                depot.connector.saveRecord(depot,{});
            }
        });
    }
};

my.clientSides.colorSample={
    action: function(depot, fieldName){
        depot.row[fieldName]=depot.row.color;
        depot.rowControls[fieldName].style.backgroundColor='#'+depot.row[fieldName];
    }
};

function wScreenExportarAppPrecios(ocasion, titulo){
    return function(){
        setTimeout(function(){
            var layout = document.getElementById('main_layout');
            var progressDiv=html.div({class:"progress-div"}).create();
            var resultDiv=html.div({class:"result-div"}).create();
            var botonExportar=html.button("exportar").create();
            botonExportar.onclick=function(){
                my.ajax.precios_exportarapp({
                    ocasion:ocasion,
                },{divProgress:progressDiv}).then(function(result){
                    resultDiv.textContent=result;
                    resultDiv.style.color='green';
                }).catch(function(error){
                    resultDiv.textContent=error.message;
                    resultDiv.style.color='red';
                })
            }
            layout.appendChild(
                html.div([
                    html.div({class:'titulo-form'}, titulo),
                    html.table({class:'table-param-screen'},[
                        html.tr([
                            html.td(), html.td([botonExportar]), 
                        ])
                    ]),
                    resultDiv,
                    progressDiv,
                ]).create()
            );
            
        },50);
    };
}

my.wScreens.exporta_precios=wScreenExportarAppPrecios('final', "Exportar precios a la app de precios (también hace copia local)"); 
my.wScreens.exporta_precios_local=wScreenExportarAppPrecios('local', "Copiar los precios para revisar lo que se exportará a la app de precios"); 

my.wScreens.mostrar_cuadros=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var controlPeriodo=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlCuadro=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlSeparadorDecimal=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlPeriodoDesde=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlHogar=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlAgrupacion=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var resultDiv=html.div({class:"result-div"}).create();
        var botonVer=html.button("ver").create();
        botonVer.onclick=function(){
            my.ajax.cuadros_mostrar({
                periodo:controlPeriodo.getTypedValue(),
                cuadro:controlCuadro.getTypedValue(),
                separadordecimal:controlSeparadorDecimal.getTypedValue(),
                periododesde:controlPeriodoDesde.getTypedValue(),
                hogar:controlHogar.getTypedValue(),
                agrupacion:controlAgrupacion.getTypedValue(),
            }).then(function(result){
                //console.log(result.rows);
                //var armarcuadro = proceso_formulario_boton_ejecutar('cuadros_resultados','botonVer',["periodo","cuadro","separadordecimal","periodo_desde","hogar","agrupacion"],null,null,false);

                resultDiv.textContent=JSON.stringify(result);
                //resultDiv.textContent=armarcuadro;
                //grid.refresh();
            })
        }
        TypedControls.adaptElement(controlPeriodo,{typeName:'text', references:'periodos', defaultValue:'a2018m07'});
        TypedControls.adaptElement(controlCuadro,{typeName:'text', references:'cuadros', defaultValue:'1'});
        TypedControls.adaptElement(controlSeparadorDecimal,{typeName:'text', defaultValue:','});
        TypedControls.adaptElement(controlPeriodoDesde,{typeName:'text', references:'periodos', defaultValue:'a2018m07'});
        TypedControls.adaptElement(controlHogar,{typeName:'text', references:'hogares', defaultValue:'Hogar 1'});
        TypedControls.adaptElement(controlAgrupacion,{typeName:'text', references:'agrupaciones', defaultValue:'A'});
        layout.appendChild(
            html.div([
                //html.div({class:'titulo-form'},"Cuadros"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("periodo"), controlPeriodo, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("cuadro"), controlCuadro, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("separador decimal"), controlSeparadorDecimal, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("periodo desde"), controlPeriodoDesde, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("hogar"), controlHogar, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("agrupacion"), controlAgrupacion, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td(), html.td([botonVer]), 
                    ])
                ]),
                resultDiv,
            ]).create()
        );        
    },50);
}
my.wScreens.copia_calculo=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var controlPeriodo=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var motivoCopia=html.td({style:'min-width:300px', colspan:2, "typed-controls-direct-input":"true"}).create();
        var resultDiv=html.div({class:"result-div"}).create();
        var divGrilla=html.div().create();
        var botonCopiar=html.button("copiar").create();
        var grid=my.tableGrid("calculos",divGrilla,{tableDef:{
            hiddenColumns:['periodoanterior','calculoanterior','esperiodobase','pb_calculobase','agrupacionprincipal','valido'],
            filterColumns:[
                {column:'periodo', operator:'>=', value:'a2018m05'.replace(/\d\d\d\d/,function(annio){ return annio-1;})},
                {column:'calculo', operator:'>' ,value:0},
            ],        
        }})
        botonCopiar.onclick=function(){
            my.ajax.calculo_copiar({
                periodo:controlPeriodo.getTypedValue(),
                motivocopia:motivoCopia.getTypedValue(),
            }).then(function(result){
                resultDiv.textContent=result;
                grid.refresh();
            })
        }
        TypedControls.adaptElement(controlPeriodo,{typeName:'text', references:'periodos'});
        TypedControls.adaptElement(motivoCopia,{typeName:'text'});
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"copiar cálculo"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("periodo"), controlPeriodo, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("motivo de copia"), motivoCopia
                    ]),
                    html.tr([
                        html.td(), html.td([botonCopiar]), 
                    ])
                ]),
                resultDiv,
                divGrilla,
            ]).create()
        );
    },50);
}
    
my.wScreens.filtravarios_caldiv=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var desdePeriodoElement=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var hastaPeriodoElement=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var resultDiv=html.div({class:"result-div"}).create();
        var divGrilla=html.div().create();
        var botonVer=html.button("ver").create();
        /*
        var grid=my.tableGrid("caldiv",divGrilla,{tableDef:{
            filterColumns:[
                {column:'periodo', operator:'>=', value:'a2018m05'.replace(/\d\d\d\d/,function(annio){ return annio-1;})},
            ],        
        }})
        */
        botonVer.onclick=function(){
            var periododesde = desdePeriodoElement.getTypedValue();
            var periodohasta = hastaPeriodoElement.getTypedValue();
            my.ajax.caldiv_filtrarvarios({
                periododesde:desdePeriodoElement.getTypedValue(),
                periodohasta:hastaPeriodoElement.getTypedValue(),
            }).then(function(result){
                resultDiv.textContent=result.value;
                //console.log("result", result.value);
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periododesde});
                //fixedFields.push({fieldName: 'periodohasta', value: periodohasta});
                //if(!result){
                var grid=my.tableGrid("caldiv_vw",divGrilla,{tableDef:{},fixedFields: fixedFields});
                //}
                grid.refresh();
            })
            /*
            my.ajax.caldiv_filtrarvarios({
                periododesde:desdePeriodo.getTypedValue(),
                periodohasta:hastaPeriodo.getTypedValue(),
            }).then(function(result){
                resultDiv.textContent=result;
                grid.refresh();
            })*/
        }
        TypedControls.adaptElement(desdePeriodoElement,{typeName:'text', references:'periodos'});
        TypedControls.adaptElement(hastaPeriodoElement,{typeName:'text', references:'periodos'});
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"filtrar varios CalDiv"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("desde periodo"), desdePeriodoElement, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("hasta periodo"), hastaPeriodoElement, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td(), html.td([botonVer]), 
                    ])
                ]),
                resultDiv,
                divGrilla,
            ]).create()
        );
    },50);
}

my.wScreens.seleccion_supervision=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var supervisionPeriodoElement=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var supervisionPanelElement=html.td({style:'min-width:50px', "typed-controls-direct-input":"true"}).create();
        var botonPreparar=html.button("preparar").create();
        var resultDiv=html.div({class:"result-div"}).create();
        var otherResultDiv=html.div({class:"otherresult-div"}).create();
        var botonSeleccionar=html.button("seleccionar (aleatoria)").create();
        var divGrilla=html.div().create();
        var divOtherGrilla=html.div().create();
        botonPreparar.onclick=function(){
            var periodo = supervisionPeriodoElement.getTypedValue();
            var panel = supervisionPanelElement.getTypedValue();
            my.ajax.supervision_preparar({
                periodo:supervisionPeriodoElement.getTypedValue(),
                panel:supervisionPanelElement.getTypedValue(),
            }).then(function(result){
                resultDiv.textContent=result.value;
                //console.log("result", result.value);
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodo});
                fixedFields.push({fieldName: 'panel', value: panel});
                if(!result){
                    var grid=my.tableGrid("relsup_a_elegir",divGrilla,{tableDef:{},fixedFields: fixedFields});
                }else{
                    var grid=my.tableGrid("relsup",divGrilla,{tableDef:{},fixedFields: fixedFields});                    
                }
                var otherGrid=my.tableGrid("reltar_candidatas",divOtherGrilla,{tableDef:{},fixedFields: fixedFields});
                grid.refresh();
                otherGrid.refresh();
            })
        }
        botonSeleccionar.onclick=function(){
            var periodo = supervisionPeriodoElement.getTypedValue();
            var panel = supervisionPanelElement.getTypedValue();
            my.ajax.supervision_seleccionar({
                periodo:supervisionPeriodoElement.getTypedValue(),
                panel:supervisionPanelElement.getTypedValue(),
            }).then(function(result){
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodo});
                fixedFields.push({fieldName: 'panel', value: panel});
                //console.log("otherResult", result);                    
                if(!result){
                    otherResultDiv.textContent=null;
                    var grid=my.tableGrid("reltar_candidatas",divOtherGrilla,{tableDef:{},fixedFields: fixedFields});
                    grid.refresh();
                }else{
                    otherResultDiv.textContent=result;
                    //console.log("otherResult", result);                    
                }
            })
        }
        TypedControls.adaptElement(supervisionPeriodoElement,{typeName:'text', references:'periodos'});
        TypedControls.adaptElement(supervisionPanelElement,{typeName:'integer'});
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"seleccionar supervisión"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("periodo"), supervisionPeriodoElement, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("panel"), supervisionPanelElement
                    ]),
                    html.tr([
                        html.td(), html.td([botonPreparar]), 
                    ])
                ]),
                divGrilla,
                html.table({class:'table-selec-screen'},[
                    html.tr([
                        html.td(), html.td([botonSeleccionar]), 
                    ])
                ]),
                otherResultDiv,
                divOtherGrilla,
            ]).create()
        );
    },50);
}

my.wScreens.controles_formulario={
    parameters:[
        {name:'periodo'   , typeName:'text'   , references:'periodos'},
        {name:'informante', typeName:'integer', references:'informantes'},
        {name:'visita'    , typeName:'integer'},
        {name:'formulario', typeName:'integer', references:'formularios'},
    ],
    mainAction:function(params,divResult){
        var detailTables=[
            {table:'control_normalizables_sindato', abr:'NSD', label:'normalizables sin dato', fields:['periodo','informante','visita','formulario']},
            {table:'control_atributos', abr:'AFR', label:'atributos fuera de rango', fields:['periodo','informante','visita','formulario']},
            {table:'hdrexportarefectivossinprecio', abr:'ESP', label:'efectivos sin precio', fields:['periodo','informante','visita','formulario']},
            {table:'control_rangos', abr:'RAN', label:'Control de rangos de precios', fields:['periodo','informante','visita','formulario']},
            {table:'controlvigencias', abr:'VIG', label:'Control de atributo vigencia', fields:['periodo','informante']},
            {table:'control_diccionario_atributos', abr:'DIC', label:'Control de diccionario de atributos', fields:['periodo','informante','visita','formulario']},
            {table:'control_verificar_precio', abr:'CVP', label:'Control para verificar precio', fields:['periodo','informante','visita','formulario']},
            {table:'precios_positivos', abr:'PP', label:'Control precios positivos', fields:['periodo','informante','visita','formulario']},
            {table:'precios_inconsistentes', abr:'PI', label:'Control precios inconsistentes', fields:['periodo','informante','visita','formulario']},
            {table:'tercera_ausencia', abr:'TA', label:'Control tercer mes ausencia', fields:['periodo','informante','visita','formulario']},
        ];
        return Promise.all(detailTables.map(function(det){
            var divGrilla=html.div().create();
            divResult.appendChild(divGrilla);
            var grid=my.tableGrid(det.table,divGrilla,{tableDef:{
                title:det.label,
                layout:{errorList:true}
                // hiddenColumns:my.wScreens.controles_formulario.parameters.map(function(p){ return p.name; }),
            }, fixedFields:det.fields.map(function(key){ return {fieldName:key, value:params[key]}; })});
            return grid.waitForReady();
        }));
    }
};

if(bestGlobals.changing.remove){
    confirmPromise(
        "hay que agregar changing remove a hiddenColumns",
        {
            askForNoRepeat:"changing.remove",
            buttonsDef:[{label:"Aviso a desarrollo", value:true}]
        }
    );
}

function prepareTableButtons(){
    var buttons = document.querySelectorAll("button#tables");
    Array.prototype.forEach.call(buttons, function(button){
        button.addEventListener('click', function(){
            var layout = document.getElementById('table_layout');
            my.tableGrid(this.getAttribute('id-table'),layout);
        });
    });
}

myOwn.sortMethods.codigo_ipc=function(codigo){
    return codigo.substr(1); // quitamos la primera letra!
}

/*Inicio Pantalla Matriz de precios e imputados de un producto */
myOwn.wScreens.matriz = function(addrParams){
    var json = {
        periodo: 'a2018m12',
        producto: 'P0112421',
    };
    history.replaceState(null, null, location.origin+location.pathname+my.menuSeparator+'w=matriz_de_un_producto&up='+JSON.stringify(json)+'&autoproced=true');
    my.showPage();
}

myOwn.wScreens.matriz_de_un_producto={
    parameters:[
        {name:'periodo'           , typeName:'text'   , references:'periodos'},
        {name:'producto'          , typeName:'text'   , references:'productos'},
    ],
    mainAction:function(params,divResult){
        var mainLayout = document.getElementById('main_layout');
        mainLayout.innerHTML="";
        var layout = html.div({id: "matriz_de_un_producto-layout", class: "mobile-main-layout"}).create()
        mainLayout.appendChild(layout);
        layout.appendChild(html.div({id: "title"}, 'Matriz de Resultados del Cálculo').create());
        var spanArray = [];
        spanArray.push(html.span({id: "periodo"}, 'Periodo: ' + params.periodo));
        spanArray.push(html.span({id: "producto"}, 'Producto: ' + params.producto));
        layout.appendChild(html.div({id: "header-information"},spanArray).create());
        
        var fixedFields = [];
        likeAr(params).forEach(function(value, attrName, object){
            fixedFields.push({fieldName: attrName, value: value});
        });        

        var gridMatrizDiv = html.div({class: "grid-matriz"}).create();
        layout.appendChild(gridMatrizDiv);  

        var grid=my.tableGrid('matriz_de_un_producto',gridMatrizDiv,{tableDef:{
            hiddenColumns:['informantes__nombreinformante', 'informantes__tipoinformante'],
        }, fixedFields:fixedFields});
        return grid.waitForReady().then(function(){
            return grid
        });
    }
};
myOwn.clientSides.parseCelda={
    update: false,
    prepare: function(depot, fieldName){
        console.log('fieldName',fieldName);
        var espacio= ' ';
        var fName = fieldName.substring(0,6);
        console.log('fName',fName);
        var div = html.div({class:'informante'}).create();
        div.appendChild(html.span({class:'nombre-informante'}, depot.row[fName].variacion).create());
        div.appendChild(html.span({class:'nombre-informante'}, espacio).create());
        div.appendChild(html.span({class:'cantidad-periodos-sin-informacion'}, depot.row[fName].tpr).create());
        var div2 = html.div({class:'informante'}).create();
        div2.appendChild(html.span({class:'direccion-informante'}, depot.row[fName].promobs).create());
        div2.appendChild(html.span({class:'direccion-informante'}, espacio).create());
        div2.appendChild(html.span({class:'direccion-informante'}, depot.row[fName].xpromobs).create());
        div2.appendChild(html.span({class:'direccion-informante'}, espacio).create());
        div2.appendChild(html.span({class:'comentarios-informante'}, depot.row[fName].excluido).create());
        div2.appendChild(html.span({class:'direccion-informante'}, espacio).create());
        div2.appendChild(html.span({class:'comentarios-informante'}, depot.row[fName].antiguedadprecio).create());
        var div3 = html.div({class:'informante'}).create();
        div3.appendChild(html.span({class:'direccion-informante'}, depot.row[fName].precioobservado).create());
        div3.appendChild(html.span({class:'direccion-informante'}, espacio).create());
        div3.appendChild(html.span({class:'direccion-informante'}, depot.row[fName].impobs).create());
        var div4 = html.div({class:'informante'}).create();
        div4.appendChild(html.span({class:'direccion-informante'}, depot.row[fName].atributo).create());
        depot.rowControls[fieldName].appendChild(div);
        depot.rowControls[fieldName].appendChild(div2);
        depot.rowControls[fieldName].appendChild(div3);
        depot.rowControls[fieldName].appendChild(div4);
    }
};
/*Fin Pantalla Matriz de precios e imputados de un producto */

my.clientSides.agregar_visita = {
    update:false,
    prepare:function(depot, fieldName){
        depot.rowControls[fieldName].addEventListener('update', function(){
            var valor = depot.rowControls[fieldName].getTypedValue();
            if(valor==true){
                depot.rowControls.ultima_visita.setTypedValue(null, true);
            }
        });
    }
}

my.setPlaceHolder = function setPlaceHolderWithDefault(typedControl, valueOrCondition){
    var getValue = function(){
        if(typeof valueOrCondition == "function"){
            return valueOrCondition();
        }else{
            return valueOrCondition;
        }
    }
    typedControl.addEventListener('focus', function(){
        var value=getValue();
        if(value){
            typedControl.setAttribute('placeholder', value);
        }
    });
    typedControl.addEventListener('blur', function(){
        var actualValue=this.textContent;
        if(!actualValue || !actualValue.trim()){
            var value=getValue();
            if(value){
                typedControl.setTypedValue(value, true);
            }
            typedControl.removeAttribute('placeholder');
        }
    });
}

my.clientSides.ingreso_tipoprecio = {
    update:function(depot, fieldName){
        var detailDef=depot.detailControls.relatr;
        if(detailDef && detailDef.show && depot.row.cambio == null && depot.rowControls.cambio.getTypedValue() == 'C'){
            detailDef.forceDisplayDetailGrid({fixedFields:detailDef.calculateFixedFields(), detailing:{}},{});
        }
    },
    prepare:function(depot, fieldName){
        my.setPlaceHolder(depot.rowControls[fieldName], function(){
            return depot.rowControls.precio.getTypedValue() && 'P';
        })
        depot.rowControls[fieldName].addEventListener('blur',function(){
            var translate={
                '0':'O',
                '1':'S',
                '2':'N'
            }
            value = depot.rowControls[fieldName].textContent;
            if(value in translate){
                depot.rowControls[fieldName].textContent=translate[value];
                depot.rowControls[fieldName].setTypedValue(translate[value], true);
            }
        })
    }
}

my.clientSides.agregar_visita_por_visita = botonClientSideEnGrilla({
    nombreBoton:'AgregarVisita',
    llamada:function(depot){
        return my.ajax.visita_agregar_por_visita({
            periodo: depot.row.periodo,
            informante: depot.row.informante,
            visita: depot.row.visita,
            formulario: depot.row.formulario,
        });
    }
});

my.wScreens.buscar_informante=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var controlPeriodo   =html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var controlInformante=html.td({style:'min-width:100px', "typed-controls-direct-input":"true"}).create();
        var botonBuscar=html.button("buscar").create();
        var resultDiv=html.div({class:"result-div"}).create();
        var divGrilla=html.div().create();
        botonBuscar.onclick=function(){
            var periodo = controlPeriodo.getTypedValue();
            var informante = controlInformante.getTypedValue();
            my.ajax.informante_buscar({
                periodo:controlPeriodo.getTypedValue(),
                informante:controlInformante.getTypedValue(),
            }).then(function(result){
                resultDiv.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodo});
                fixedFields.push({fieldName: 'informante', value: informante});
                var grid=my.tableGrid("relvis",divGrilla,{tableDef:{},fixedFields: fixedFields});
                grid.refresh();
            })
        }
        TypedControls.adaptElement(controlPeriodo   ,{typeName:'text'   , references:'periodos'});
        TypedControls.adaptElement(controlInformante,{typeName:'integer', references:'informantes'});
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"buscar informante"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("periodo"), controlPeriodo, html.td({style:'min-width:200px'})
                    ]),
                    html.tr([
                        html.td("informante"), controlInformante
                    ]),
                    html.tr([
                        html.td(), html.td([botonBuscar]), 
                    ])
                ]),
                divGrilla,
            ]).create()
        );
    },50);
}

/*
my.wScreens.correr_periodobase=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var botonCorrerPb=html.button("Ejecutar").create();
        var resultDiv=html.div({class:"result-div"}).create();
        var divGrilla=html.div().create();
        botonCorrerPb.onclick=function(){
            my.ajax.periodobase_correr({
                ejecutar:true,
            }).then(function(result){
                resultDiv.textContent=result.value;
                var fixedFields = [];
                var grid=my.tableGrid("calculos",divGrilla,{tableDef:{},fixedFields: fixedFields});
                grid.refresh();
            })
        }
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"Ejecutar Periodo Base"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td(), html.td([botonCorrerPb]), 
                    ])
                ]),
                divGrilla,
            ]).create()
        );
    },50);
}
*/

my.clientSides.cambiarPanelTareaUnInf = botonClientSideEnGrilla({
    nombreBoton:'cambiar',
    llamada:function(depot){
        return my.ajax.paneltarea_cambiaruninf({
            periodo: depot.row.periodo,
            informante: depot.row.informante,
            visita: depot.row.visita,
            formulario: depot.row.formulario,
            otropanel: depot.row.otropanel,
            otratarea: depot.row.otratarea,
        });
    }
});

my.wScreens.cambiar_paneltarea=function(addrParams){
    setTimeout(function(){
        var layout = document.getElementById('main_layout');
        var controlPeriodoDesde=html.td({style:'min-width:100px', "typed-controls-direct-input":"true", tabindex:1}).create();
        var controlPanelDesde=html.td({style:'min-width:100px', "typed-controls-direct-input":"true", tabindex:2}).create();
        var controlTareaDesde=html.td({style:'min-width:100px', "typed-controls-direct-input":"true", tabindex:3}).create();

        var controlPanelHasta=html.td({style:'min-width:100px', "typed-controls-direct-input":"true", tabindex:4}).create();
        var controlTareaHasta=html.td({style:'min-width:100px', "typed-controls-direct-input":"true", tabindex:5}).create();

        var botonBuscarDesde=html.button("buscar desde").create();
        var botonBuscarHasta=html.button("buscar hasta").create();
        var botonBuscar=html.button("buscar ambos").create();
        var botonCambiarDesde=html.button("cambiar >").create();
        var botonCambiarHasta=html.button("< cambiar").create();
        var botonIntercambiar=html.button("< intercambiar >").create();
        var resultDivDesde=html.div({class:"result-div"}).create();
        var resultDivHasta=html.div({class:"result-div"}).create();
        var divGrillaDesde=html.div().create();
        var divGrillaHasta=html.div().create();
        var dameManejadorOnClickBotonBuscar=function(ida){
            return function(){
                var periodoDesde = controlPeriodoDesde.getTypedValue();
                var panelDesde = controlPanelDesde.getTypedValue();
                var tareaDesde = controlTareaDesde.getTypedValue();
                var panelHasta = controlPanelHasta.getTypedValue();
                var tareaHasta = controlTareaHasta.getTypedValue();
                var parametrosBusqueda;
                if(ida){
                    parametrosBusqueda={
                        periodo:controlPeriodoDesde.getTypedValue(),
                        panel:controlPanelDesde.getTypedValue(),
                        tarea:controlTareaDesde.getTypedValue(),
                        otropanel:controlPanelHasta.getTypedValue(),
                        otratarea:controlTareaHasta.getTypedValue(),
                    }
                }else{
                    parametrosBusqueda={
                        periodo:controlPeriodoDesde.getTypedValue(),
                        panel:controlPanelHasta.getTypedValue(),
                        tarea:controlTareaHasta.getTypedValue(),
                        otropanel:controlPanelDesde.getTypedValue(),
                        otratarea:controlTareaDesde.getTypedValue(),
                    }
                }
                return my.ajax.paneltarea_buscar(parametrosBusqueda).then(function(result){
                    resultDivDesde.textContent=result.value;
                    var fixedFields = [];
                    fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                    if(ida){
                        fixedFields.push({fieldName: 'panel', value: panelDesde});
                        fixedFields.push({fieldName: 'tarea', value: tareaDesde});
                        fixedFields.push({fieldName: 'otropanel', value: panelHasta});
                        fixedFields.push({fieldName: 'otratarea', value: tareaHasta});
                        var grid=my.tableGrid("relvis_pt",divGrillaDesde,{tableDef:{},fixedFields: fixedFields});
                    }else{
                        fixedFields.push({fieldName: 'panel', value: panelHasta});
                        fixedFields.push({fieldName: 'tarea', value: tareaHasta});
                        fixedFields.push({fieldName: 'otropanel', value: panelDesde});
                        fixedFields.push({fieldName: 'otratarea', value: tareaDesde});
                        var grid=my.tableGrid("relvis_pt",divGrillaHasta,{tableDef:{},fixedFields: fixedFields});
                    }
                    return grid.refresh();
                })
            }
        }
        botonBuscarDesde.onclick=dameManejadorOnClickBotonBuscar(true);
        botonBuscarHasta.onclick=dameManejadorOnClickBotonBuscar(false);
        var habilitarBotonesCambio = function(){
            botonCambiarDesde.disabled=false;
            botonCambiarHasta.disabled=false;
            botonIntercambiar.disabled=false;
        }
        botonBuscar.onclick=function(){
            Promise.all([
                dameManejadorOnClickBotonBuscar(true)(),
                dameManejadorOnClickBotonBuscar(false)()
            ]).then(habilitarBotonesCambio).catch(function(err){
                console.log(err);
                alertPromise('ERROR '+err.message)
            })
        }
        botonCambiarDesde.onclick=function(){
            var periodoDesde = controlPeriodoDesde.getTypedValue();
            var panelDesde = controlPanelDesde.getTypedValue();
            var tareaDesde = controlTareaDesde.getTypedValue();
            var panelHasta = controlPanelHasta.getTypedValue();
            var tareaHasta = controlTareaHasta.getTypedValue();
            my.ajax.paneltarea_cambiar({
                periodo:controlPeriodoDesde.getTypedValue(),
                panel:controlPanelDesde.getTypedValue(),
                tarea:controlTareaDesde.getTypedValue(),
                otropanel:controlPanelHasta.getTypedValue(),
                otratarea:controlTareaHasta.getTypedValue(),
            }).then(function(result){
                resultDivDesde.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelDesde});
                fixedFields.push({fieldName: 'tarea', value: tareaDesde});
                fixedFields.push({fieldName: 'otropanel', value: panelHasta});
                fixedFields.push({fieldName: 'otratarea', value: tareaHasta});
                var gridDesde=my.tableGrid("relvis_pt",divGrillaDesde,{tableDef:{},fixedFields: fixedFields});
                gridDesde.refresh();
                resultDivHasta.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelHasta});
                fixedFields.push({fieldName: 'tarea', value: tareaHasta});
                fixedFields.push({fieldName: 'otropanel', value: panelDesde});
                fixedFields.push({fieldName: 'otratarea', value: tareaDesde});
                var gridHasta=my.tableGrid("relvis_pt",divGrillaHasta,{tableDef:{},fixedFields: fixedFields});
                gridHasta.refresh();
            })            
        }
        botonCambiarHasta.onclick=function(){
            var periodoDesde = controlPeriodoDesde.getTypedValue();
            var panelDesde = controlPanelDesde.getTypedValue();
            var tareaDesde = controlTareaDesde.getTypedValue();
            var panelHasta = controlPanelHasta.getTypedValue();
            var tareaHasta = controlTareaHasta.getTypedValue();
            my.ajax.paneltarea_cambiar({
                periodo:controlPeriodoDesde.getTypedValue(),
                panel:controlPanelHasta.getTypedValue(),
                tarea:controlTareaHasta.getTypedValue(),
                otropanel:controlPanelDesde.getTypedValue(),
                otratarea:controlTareaDesde.getTypedValue(),
            }).then(function(result){
                resultDivDesde.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelDesde});
                fixedFields.push({fieldName: 'tarea', value: tareaDesde});
                fixedFields.push({fieldName: 'otropanel', value: panelHasta});
                fixedFields.push({fieldName: 'otratarea', value: tareaHasta});
                var gridDesde=my.tableGrid("relvis_pt",divGrillaDesde,{tableDef:{},fixedFields: fixedFields});
                gridDesde.refresh();
                resultDivHasta.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelHasta});
                fixedFields.push({fieldName: 'tarea', value: tareaHasta});
                fixedFields.push({fieldName: 'otropanel', value: panelDesde});
                fixedFields.push({fieldName: 'otratarea', value: tareaDesde});
                var gridHasta=my.tableGrid("relvis_pt",divGrillaHasta,{tableDef:{},fixedFields: fixedFields});
                gridHasta.refresh();
            })            
        }
        botonIntercambiar.onclick=function(){
            var periodoDesde = controlPeriodoDesde.getTypedValue();
            var panelDesde = controlPanelDesde.getTypedValue();
            var tareaDesde = controlTareaDesde.getTypedValue();
            var panelHasta = controlPanelHasta.getTypedValue();
            var tareaHasta = controlTareaHasta.getTypedValue();
            my.ajax.paneltarea_intercambiar({
                periodo:controlPeriodoDesde.getTypedValue(),
                panel:controlPanelHasta.getTypedValue(),
                tarea:controlTareaHasta.getTypedValue(),
                otropanel:controlPanelDesde.getTypedValue(),
                otratarea:controlTareaDesde.getTypedValue(),
            }).then(function(result){
                resultDivDesde.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelDesde});
                fixedFields.push({fieldName: 'tarea', value: tareaDesde});
                fixedFields.push({fieldName: 'otropanel', value: panelHasta});
                fixedFields.push({fieldName: 'otratarea', value: tareaHasta});
                var gridDesde=my.tableGrid("relvis_pt",divGrillaDesde,{tableDef:{},fixedFields: fixedFields});
                gridDesde.refresh();
                resultDivHasta.textContent=result.value;
                var fixedFields = [];
                fixedFields.push({fieldName: 'periodo', value: periodoDesde});
                fixedFields.push({fieldName: 'panel', value: panelHasta});
                fixedFields.push({fieldName: 'tarea', value: tareaHasta});
                fixedFields.push({fieldName: 'otropanel', value: panelDesde});
                fixedFields.push({fieldName: 'otratarea', value: tareaDesde});
                var gridHasta=my.tableGrid("relvis_pt",divGrillaHasta,{tableDef:{},fixedFields: fixedFields});
                gridHasta.refresh();
            })            
        }
        TypedControls.adaptElement(controlPeriodoDesde   ,{typeName:'text'   , references:'periodos'});
        TypedControls.adaptElement(controlPanelDesde     ,{typeName:'integer'                       });
        TypedControls.adaptElement(controlTareaDesde     ,{typeName:'integer'                       });
        TypedControls.adaptElement(controlPanelHasta     ,{typeName:'integer'                       });
        TypedControls.adaptElement(controlTareaHasta     ,{typeName:'integer'                       });
        layout.appendChild(
            html.div([
                html.div({class:'titulo-form'},"cambiar panel-tarea"),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td("periodo"), controlPeriodoDesde, html.td({style:'min-width:200px'})
                    ]),
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td({style:'width:700px'},[html.td("panel desde"), controlPanelDesde,]),
                        html.td({style:'width:700px'},[html.td("panel hasta"), controlPanelHasta,]),
                    ]),
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td({style:'width:700px'},[html.td("tarea desde "), controlTareaDesde,]),
                        html.td({style:'width:700px'},[html.td("tarea hasta "), controlTareaHasta,]),
                    ]),
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td({style:'width:700px'},[html.td([botonBuscarDesde]),html.span(' '),html.td([botonBuscar]),]), 
                        html.td({style:'width:700px'},[html.td([botonBuscarHasta]),]), 
                    ]),
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td({style:'width:700px'},[html.td([botonCambiarDesde]),]), 
                        html.td({style:'width:700px'},[html.td([botonCambiarHasta]),]), 
                    ])
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr([
                        html.td({style:'width:1400px; display:flex; justify-content:center'},[html.td([botonIntercambiar]),]), 
                    ])
                ]),
                html.table({class:'table-param-screen'},[
                    html.tr({style:'display:flex'},[
                        html.td({style:'min-width:700px;'},[divGrillaDesde]),
                        html.td({style:'min-width:700px;'},[divGrillaHasta]),
                    ]),
                ]),
            ]).create()
        );
        var huboCambio = function(){
            divGrillaDesde.innerHTML="";
            divGrillaHasta.innerHTML="";
            botonCambiarDesde.disabled=true;
            botonCambiarHasta.disabled=true;
            botonIntercambiar.disabled=true;
        }
        huboCambio();
        controlPeriodoDesde.addEventListener('update', huboCambio);
        controlPanelDesde.addEventListener('update', huboCambio);
        controlTareaDesde.addEventListener('update', huboCambio);
        controlPanelHasta.addEventListener('update', huboCambio);
        controlTareaHasta.addEventListener('update', huboCambio);
    },50);
}

my.clientSides.altamanualgenerar = botonClientSideEnGrilla({
    nombreBoton:'generar',
    llamada:function(depot){
        return my.ajax.altamanualconfirmar_touch({
            informante: depot.row.informante,
        });
    }
});

my.clientSides.procederCambioPT = botonClientSideEnGrilla({
    nombreBoton:'proceder',
    llamada:function(depot){
        return my.ajax.fechaprocesado_touch({
            id_lote: depot.row.id_lote
        });
    }
});