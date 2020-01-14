"use strict";
import {LOCAL_STORAGE_STATE_NAME} from "../unlogged/dm-react";
import {html}  from 'js-to-html';
import * as JSON4all from "json4all";

window.addEventListener('load', async function(){
    var layout = document.getElementById('total-layout')!;
    if(!layout){
        console.log('no encuentro el DIV.total-layout')
        await myOwn.ready;
        layout = document.getElementById('total-layout')!;
    }
    // @ts-ignore ready existe!
    await myOwn.ready;
    layout.innerHTML='<div id=main_layout></div><span id="mini-console"></span>';
    var url = new URL(window.location.href);
    var periodo = url.searchParams.get("periodo");
    var panel = url.searchParams.get("panel");
    var tarea = url.searchParams.get("tarea");
    dmHojaDeRuta({periodo, panel, tarea});
})

var wasDownloading=false;
var appCache = window.applicationCache;
appCache.addEventListener('downloading', async function(e) {
    wasDownloading=true;
    var layout = await awaitForCacheLayout;
    layout.insertBefore(
        html.p({id:'cache-status', class:'warning'},[
            'descargando aplicación, por favor no desconecte el dispositivo',
            html.img({src:'img/loading16.gif'}).create()
        ]).create(), 
        layout.firstChild
    );
}, false);
appCache.addEventListener('error', async function(e) {
    if(wasDownloading){
        console.log('error al descargar cache', e.message)
        var layout = await awaitForCacheLayout;
        var cacheStatusElement = document.getElementById('cache-status');
        if(!cacheStatusElement){
            cacheStatusElement = html.p({id:'cache-status'}).create();
            layout.insertBefore(cacheStatusElement, layout.firstChild);
        }
        cacheStatusElement.classList.remove('warning')
        cacheStatusElement.classList.add('danger')
        cacheStatusElement.textContent='error al descargar la aplicación. ' + e.message;
    }
}, false);

async function cacheReady(){
    wasDownloading=false;
    var {periodo, panel, tarea} = JSON4all.parse(localStorage.getItem(LOCAL_STORAGE_STATE_NAME));
    var result = await AjaxBestPromise.get({
        url:`carga-dm/${periodo}p${panel}t${tarea}_manifest.manifest`,
        data:{}
    });
    localStorage.setItem('app-cache-version',result.split('\n')[1]);
    setTimeout(function(){
        var cacheStatusElement = document.getElementById('cache-status');
        if(!cacheStatusElement){
            var mainLayout = document.getElementById('main_layout');
            cacheStatusElement = html.p({id:'cache-status'}).create();
            mainLayout.insertBefore(cacheStatusElement, mainLayout.firstChild);
        }
        setTimeout(function(){
            cacheStatusElement.classList.add('all-ok')
            cacheStatusElement.textContent='aplicación actualizada, puede desconectar el dispositivo';
            setTimeout(function(){
                cacheStatusElement.style.display='none';
            }, 5000);
            setTimeout(function(){
                location.reload();
            },2000)
        }, 5000);
    },500)
}
appCache.addEventListener('updateready', function (e) {
    console.log("actualiza cache");
    if (appCache.status == appCache.UPDATEREADY) {
        console.log("swap cache");
        appCache.swapCache()
    }
    cacheReady()
}, false);
appCache.addEventListener('cached', function() {
    console.log("cachea primera vez");
    cacheReady()
}, false );

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
async function displayWhenReady(message, type, message2, enOtroRenglon){
    var layout = await awaitForCacheLayout;
    var logLayout = document.getElementById('cache-log');
    var texto = logLayout.firstElementChild;
    texto=document.createElement('div');
    logLayout.appendChild(texto);
    texto.className='log_manifest';
    texto.textContent=message;
    if(type!='progress'){
        var texto2=document.createElement('span');
        texto2.className='mensaje_alerta';
        texto2.textContent=' '+message2;
        texto.appendChild(texto2);
    }
}