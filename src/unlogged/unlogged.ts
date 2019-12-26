"use strict";
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
    var periodo = url.searchParams.get("per");
    var panel = url.searchParams.get("pan");
    var tarea = url.searchParams.get("tar");
    dmHojaDeRuta({periodo, panel, tarea});
})