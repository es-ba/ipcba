"use strict";
import {LOCAL_STORAGE_STATE_NAME, hayHojaDeRuta, cargarScriptEstructura} from "../unlogged/dm-react";
import {html}  from 'js-to-html';
const ServiceWorkerAdmin = require("service-worker-admin");

var reloadWithoutHash = ()=>{
    history.replaceState(null, '', `${location.origin+location.pathname}/../dm`);
    location.reload()
}

window.addEventListener('load', async function(){
    var layout = document.getElementById('total-layout')!;
    if(!layout){
        console.log('no encuentro el DIV.total-layout')
        await myOwn.ready;
        layout = document.getElementById('total-layout')!;
    }
    await myOwn.ready;
    layout.innerHTML=`
        <span id="mini-console"></span>
        <div id=nueva-version-instalada style="position:fixed; top:5px; z-index:9500; display:none">
            <span>Hay una nueva versión instalada </span><button id=refrescar><span class=rotar>↻</span> refrescar</button>
        </div>
        <div id=instalado style="display:none">
            <div id=main_layout></div>
        </div>
        <div id=instalando style="display:none; margin-top:30px">
            <div id=volver-de-instalacion style="position:fixed; top:5px; z-index:9500;">
                <span id=volver-de-instalacion-por-que></span>
                <button id=volver-de-instalacion-como>volver</button>
            </div>
            <div id=archivos>
                <h2>progreso instalacion</h2>
            </div>
        </div>
    `;
    var startApp:()=>Promise<void> = async ()=>{};
    if(location.pathname.endsWith('/rescate')){
        try{
            for (let x in localStorage){
                console.log(localStorage[x]);
                await myOwn.ajax.dm2_rescatar({localStorageItem:localStorage[x], localStorageItemKey:x})
                layout.append(
                    html.p(`item "${x}" de localStogage guardado.`).create()
                )
            }
            layout.append(
                html.p(`todos los items fueron salvados.`).create()
            )
        }catch(err){
            layout.append(
                html.p(`se produjo un error al salvar los datos del dm.`).create()
            )
        }
        try{
            var registrations = await navigator.serviceWorker.getRegistrations();
            for(let registration of registrations) {
                await registration.unregister()
            }
            layout.append(
                html.p(`todos los sw fueron desinstalados.`).create()
            )
        }catch(err){
            layout.append(
                html.p(`se produjo un error al desinstalar los sw.`).create()
            )
        }
    }else{
        if(location.pathname.endsWith('/dm')){
            if(hayHojaDeRuta()){
                startApp = async ()=>{
                    cargarScriptEstructura(async ()=>{
                        var version = await swa.getSW('version');
                        myOwn.setLocalVar('ipc2.0-app-cache-version', version);
                        const {periodo, panel, tarea} = myOwn.getLocalVar(LOCAL_STORAGE_STATE_NAME)!;
                        //@ts-ignore existe 
                        dmHojaDeRuta({addrParamsHdr:{periodo, panel, tarea}});
                    })
                }
            }else{
                startApp = async ()=>{
                    //@ts-ignore existe 
                    dmPantallaInicial();
                }
            }
            var refrescarStatus=async function(showScreen, newVersionAvaiable, installing){
                var buscandoActualizacion = location.href.endsWith('#inst=1');
                document.getElementById('nueva-version-instalada')!.style.display=newVersionAvaiable=='yes'?'':'none';
                document.getElementById('volver-de-instalacion')!.style.display=newVersionAvaiable=='yes'?'none':'';
                if(showScreen=='app' && !buscandoActualizacion){
                    document.getElementById('instalado')!.style.display='';
                    document.getElementById('instalando')!.style.display='none';
                }else{
                    document.getElementById('instalado')!.style.display='none';
                    document.getElementById('instalando')!.style.display='';
                }
            };
            var swa = new ServiceWorkerAdmin();
            swa.installOrActivate({
                onEachFile: async (url, error)=>{
                    console.log('file: ',url);
                    document.getElementById('archivos')!.append(
                        html.div(url).create()
                    )
                },
                onInfoMessage: (m)=>console.log('message: ', m),
                onError: async (err, context)=>{
                    console.log('error: '+(context?` en (${context})`:''), err);
                    console.log(context, err, 'error-console')
                    console.log('error al descargar cache', err.message)
                    if(context!='initializing service-worker'){
                        var layout = await awaitForCacheLayout;
                        var cacheStatusElement = document.getElementById('cache-status');
                        if(!cacheStatusElement){
                            cacheStatusElement = html.p({id:'cache-status'}).create();
                            layout.insertBefore(cacheStatusElement, layout.firstChild);
                        }
                        cacheStatusElement.classList.remove('warning')
                        cacheStatusElement.classList.remove('all-ok')
                        cacheStatusElement.classList.add('danger')
                        cacheStatusElement.textContent='error al descargar la aplicación. ' + err.message;
                    }
                },
                onReadyToStart:startApp,
                onStateChange:refrescarStatus
            });
        }
        document.getElementById('refrescar')!.addEventListener('click',()=>{
            reloadWithoutHash()
        });
        document.getElementById('volver-de-instalacion-como')!.addEventListener('click',()=>{
            reloadWithoutHash()
        });
    }
})

var awaitForCacheLayout = async function prepareLayoutForCache(){
    await new Promise(function(resolve, _reject){
        window.addEventListener('load',resolve);
    });
    var layout=(document.getElementById('cache-layout')||document.createElement('div'));
    if(!layout.id){
        layout.id='cache-layout';
        layout.appendChild(html.div({id:'app-versions'}).create());
        layout.appendChild(html.div({id:'app-status'}).create());
        document.body.appendChild(layout.appendChild(html.div({id:'cache-log'}).create()));
        document.body.insertBefore(layout,document.body.firstChild)
    }
    return layout;
}();