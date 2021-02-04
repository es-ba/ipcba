
import {cargarScriptEstructura, hayHojaDeRuta} from "../unlogged/dm-react";
const ServiceWorkerAdmin = require("service-worker-admin");

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