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
    if(window.location.href.endsWith('demo2')){
        dmHojaDeRuta2({});
    }else{
        const {store, estructura} = await dmHojaDeRuta({});
        mostrarHdr(store, estructura);
    }
})