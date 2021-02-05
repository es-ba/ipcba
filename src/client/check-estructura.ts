
import {hayHojaDeRuta, LOCAL_STORAGE_STATE_NAME} from "../unlogged/dm-react";
const ServiceWorkerAdmin = require("service-worker-admin");

var cargarScriptEstructura = async (callBack?:()=>Promise<void>)=>{
    const {periodo, panel, tarea} = myOwn.getLocalVar(LOCAL_STORAGE_STATE_NAME)!;
    var script = document.createElement('script');
    var src = `carga-dm/${periodo}p${panel}t${tarea}_estructura.js`;
    script.src=src;
    document.body.appendChild(script);
    script.onload=async ()=>{
        console.log(`trae ${src}`);
        callBack?await callBack():null;
    }
    script.onerror=(err)=>{
        console.log("problema cargando estructura. ", err)
    }
}

window.addEventListener('load', async function(){
    if(hayHojaDeRuta()){
        var swa = new ServiceWorkerAdmin();
        swa.installOrActivate({
            onEachFile: null,
            onInfoMessage: null,
            onError: null,
            onReadyToStart: null,
            onStateChange: async ()=>cargarScriptEstructura(),
            //onStateChange:async(showScreen, newVersionAvaiable, installing, waiting, active, installerState)=>{
            //    console.log(showScreen, newVersionAvaiable, installing, waiting, active, installerState);
            //    alert("showScreen: " + showScreen + " newVersionAvaiable: " +newVersionAvaiable + " installing: " +installing +" waiting: " + waiting +" active: " + active +" installerState: "+ installerState)
            //}
        });
    }
});