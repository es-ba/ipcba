
import {hayHojaDeRuta, LOCAL_STORAGE_STATE_NAME} from "../unlogged/dm-react";
const ServiceWorkerAdmin = require("service-worker-admin");
var html=require('js-to-html').html;

var cargarScriptEstructura = (callBack?:()=>Promise<void>):Promise<void>=>{
    return new Promise(( resolve, reject )=>{
        const {periodo, panel, tarea} = myOwn.getLocalVar(LOCAL_STORAGE_STATE_NAME)!;
        var script = document.createElement('script');
        var src = `carga-dm/${periodo}p${panel}t${tarea}_estructura.js`;
        script.src=src;
        document.body.appendChild(script);
        script.onload=async ()=>{
            console.log(`trae ${src}`);
            callBack?await callBack():null;
            resolve();
        }
        script.onerror=(err)=>{
            document.body.appendChild(html.div('no se pudo cargar la estructura').create());
            console.log("problema cargando estructura. ", err)
            reject(new Error(`problema cargando estructura ${src}`))
        }
    });
}

myOwn.autoSetupFunctions.push(async function checkEstructura(){
    if(hayHojaDeRuta()){
        var swa = new ServiceWorkerAdmin();
        swa.installOrActivate({
            onEachFile: null,
            onInfoMessage: null,
            onError: null,
            onReadyToStart: null,
            onStateChange:async(showScreen, newVersionAvaiable, installing, waiting, active, installerState)=>{
                console.log(showScreen, newVersionAvaiable, installing, waiting, active, installerState);
                if(active){
                    console.log('active, busco script')
                    cargarScriptEstructura();
                }
            }
        });
    }
});