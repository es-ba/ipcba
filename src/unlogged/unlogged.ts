"use strict";
import {LOCAL_STORAGE_STATE_NAME, hayHojaDeRuta} from "../unlogged/dm-react";
import {html}  from 'js-to-html';
const ServiceWorkerAdmin = require("service-worker-admin");
//import * as AjaxBestPromise from "ajax-best-promise";

window.addEventListener('load', async function(){
    var layout = document.getElementById('total-layout')!;
    if(!layout){
        console.log('no encuentro el DIV.total-layout')
        await myOwn.ready;
        layout = document.getElementById('total-layout')!;
    }
    await myOwn.ready;
    layout.innerHTML='<div id=main_layout></div><span id="mini-console"></span>';
    var startApp:(installing:boolean)=>Promise<void> = async ()=>{};
    var url = new URL(window.location.href);
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
                const {periodo, panel, tarea} = myOwn.getLocalVar(LOCAL_STORAGE_STATE_NAME)!;
                startApp = async (installing)=>{
                    if(installing) return
                    var script = document.createElement('script');
                    var src = `carga-dm/${periodo}p${panel}t${tarea}_estructura.js`;
                    script.src=src;
                    document.body.appendChild(script);
                    script.onload=async ()=>{
                        console.log(`trae ${src}`);
                        var version = await swa.getSW('version');
                        myOwn.setLocalVar('ipc2.0-app-cache-version', version);
                        //@ts-ignore existe 
                        dmHojaDeRuta({addrParamsHdr:{periodo, panel, tarea}});
                        if(window.navigator.onLine){
                            var layout = await awaitForCacheLayout;
                            var cacheStatusElement = document.getElementById('cache-status');
                            if(!cacheStatusElement){
                                cacheStatusElement = html.p({id:'cache-status'}).create();
                                layout.insertBefore(cacheStatusElement, layout.firstChild);
                            }
                            cacheStatusElement.classList.remove('warning')
                            cacheStatusElement.classList.remove('danger')
                            cacheStatusElement.classList.add('all-ok')
                            cacheStatusElement.textContent='ya puede usar el dispositivo sin internet';
                        }
                        setTimeout(()=>cacheStatusElement?cacheStatusElement.style.display="none":null,3000)
                    }
                }
            }else{
                startApp = async (installing)=>{
                    if(installing) return
                    //@ts-ignore existe 
                    dmPantallaInicial();
                }
            }
            var swa = new ServiceWorkerAdmin();
            var primerArchivo=true;
            swa.installIfIsNotInstalled({
                onEachFile: async (url, error)=>{
                    console.log('file: ',url);
                    var layout = await awaitForCacheLayout;
                    if(primerArchivo){
                        layout.insertBefore(
                            html.p({id:'cache-status', class:'warning'},[
                                'buscando actualizaciones, por favor no desconecte el dispositivo',
                                html.img({src:'img/loading16.gif'}).create()
                            ]).create(), 
                            layout.firstChild
                        );
                    }
                    primerArchivo=false;
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
                onJustInstalled:async (run)=>{
                    console.log("on just installed")
                    var layout = await awaitForCacheLayout;
                    var cacheStatusElement = document.getElementById('cache-status');
                    if(!cacheStatusElement){
                        cacheStatusElement = html.p({id:'cache-status'}).create();
                        layout.insertBefore(cacheStatusElement, layout.firstChild);
                    }
                    cacheStatusElement.classList.remove('warning')
                    cacheStatusElement.classList.remove('danger')
                    cacheStatusElement.classList.add('all-ok')
                    cacheStatusElement.textContent='aplicación actualizada, espere a ser redirigido...';
                    setTimeout(run,2000)
                },
                onReadyToStart:startApp,
                onNewVersionAvailable:(install)=>{
                    console.log("on new version available")
                    install();
                }
            });
        }
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