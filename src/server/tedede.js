//tedede.js
//UTF-8:SÍ
"use strict";
var paraCuadros = require('./para_cuadros');

var version_js_tedede='V 2.41';

var URL_IMAGEN_LOADING='url(../imagenes/mini_loading.gif)';
var URL_IMAGEN_CONFIRMADO='url(../imagenes/mini_confirmado.png)';
var URL_IMAGEN_ERROR='url(../imagenes/mini_Error.png)';
var id_temporario=0;

//FF:

// var innerTextModificable=document.getElementsByTagName("body")[0].textContent!=undefined;
var innerTextModificable=document.createElement("div").textContent!==undefined;
if(!innerTextModificable){
    if('Element' in window){
        Object.defineProperty(Element.prototype, "innerText", {
            get: function() {return this.textContent; },
            set: function(y) { this.textContent=y; }
        });
    }
}

function validar_un_parametro(parametros_recibidos_en_la_funcion, nombre, definicion){
"use strict";
/* auxiliar de controlar_parametros */
    if(definicion instanceof Object && definicion.validar && parametros_recibidos_en_la_funcion.hasOwnProperty(nombre) && parametros_recibidos_en_la_funcion.nombre!=undefined){
        var opciones_de_validacion=definicion.validar;
        /*
        if(is_array($opciones_de_validacion)){
            $funcion_validadora=@$opciones_de_validacion['funcion'];
            if($opciones_de_validacion['instanceof'] && !is_a($parametros_recibidos_en_la_funcion[$param],$opciones_de_validacion['instanceof'])){
                throw new Exception_Parametro_con_nombre_invalido(
                    " es ".
                    (@get_class($parametros_recibidos_en_la_funcion[$param])?:gettype($parametros_recibidos_en_la_funcion[$param])).
                    ", no es  ".$opciones_de_validacion['instanceof']);
            }
        }else*/{
            var funcion_validadora=opciones_de_validacion;
        }
        if(!funcion_validadora(parametros_recibidos_en_la_funcion[nombre])){
            throw new Error(JSON.stringify(parametros_recibidos_en_la_funcion[nombre])+" no es valido para "+nombre);
        }
    }
    if(!parametros_recibidos_en_la_funcion.hasOwnProperty(nombre)){
        var valor_por_defecto=definicion instanceof Object?definicion.def:definicion;
        parametros_recibidos_en_la_funcion[nombre]=valor_por_defecto;
    }
}

function controlar_parametros(parametros_recibidos_en_la_funcion, definicion_de_parametros){
"use strict";
    for(var nombre_definido in definicion_de_parametros){ if(definicion_de_parametros.hasOwnProperty(nombre_definido)){
        if(!definicion_de_parametros.hasOwnProperty(nombre_recibido)){
            validar_un_parametro(parametros_recibidos_en_la_funcion,nombre_definido,definicion_de_parametros[nombre_definido]);
        }
    }}
    for(var nombre_recibido in parametros_recibidos_en_la_funcion){ if(parametros_recibidos_en_la_funcion.hasOwnProperty(nombre_recibido)){
        if(!definicion_de_parametros.hasOwnProperty(nombre_recibido)){
            throw new Error("falta el parametro "+nombre_recibido+" en la definicion de parametros de "+JSON.stringify(controlar_parametros));
        }
    }}
}

function es_objeto(objeto){
    return typeof objeto=='object' && objeto!==null;
}

function es_funcion(objeto){
    return typeof objeto=='function';
}

function es_booleano(objeto){
    return objeto===true || objeto===false;
}

function es_elemento(objeto){
    return objeto instanceof Element;
}

function enviar_quitar_fondo(elemento_id){
    var elemento=elemento_existente(elemento_id);
    elemento.style.backgroundImage='';
    elemento.style.backgroundRepeat='';
    elemento.style.backgroundPosition='';
}

function jsonear_via_todo(arreglo_asociativo_de_parametros){
    return "todo="+encodeURIComponent(JSON.stringify(arreglo_asociativo_de_parametros));
}

function parametros_via_url(arreglo_asociativo_de_parametros){
    var pares=[];
    for(var nombre in arreglo_asociativo_de_parametros) if(iterable(nombre,arreglo_asociativo_de_parametros)){
        pares.push(nombre+'='+encodeURIComponent(arreglo_asociativo_de_parametros[nombre]));
    }
    return pares.join('&');
}

function enviar_paquete(params){
"use strict";
    controlar_parametros(params,{
        destino:location.href,
        proceso:null,
        paquete:{obligatorio:true},
        cuando_ok:{validar:es_funcion,obligatorio:!!params.asincronico},
        cuando_error:{validar:es_funcion},
        usar_fondo_de:{validar:es_elemento},
        finalmente:{validar:es_funcion},
        asincronico:{validar:es_booleano,def:false},
        voy_por:null,
        estado:null,
        mostrar_tilde_confirmacion:{validar:es_booleano},
        preprocesar_paquete:{validar:es_funcion,def:jsonear_via_todo},
        postprocesar_paquete:{validar:es_funcion,def:JSON.parse}
    });
    var con_fondo=params.usar_fondo_de;
    if(con_fondo){
        params.usar_fondo_de.style.backgroundImage=URL_IMAGEN_LOADING;
        params.usar_fondo_de.style.backgroundRepeat='no-repeat';
        params.usar_fondo_de.style.backgroundPosition='top right';
        params.usar_fondo_de.title='';
    }
    if(!params.asincronico){
        document.body.style.cursor = "wait";
    }
    var peticion=new XMLHttpRequest();
    var rta=false;
    var funcion_atrapar_error=function(mensaje_error,momento){
        if(con_fondo){
            params.usar_fondo_de.style.backgroundImage=URL_IMAGEN_ERROR;
            params.usar_fondo_de.title=mensaje_error;
        }else if(!params.cuando_error){
            alert(mensaje_error+'\n'+'timming:'+momento);
        }
        document.body.style.cursor = "default";
        if(params.cuando_error){
            params.cuando_error(mensaje_error,momento);
        }
    }
    try{
        peticion.onreadystatechange=function(){
            switch(peticion.readyState) { 
            case 4: 
                try{
                    rta = peticion.responseText;
                    if(peticion.status!=200){
                        funcion_atrapar_error('Error de status '+peticion.status+' '+peticion.statusText,1);
                    }else if(rta){
                        try{
                            var obtenido=params.postprocesar_paquete?params.postprocesar_paquete(rta):{ok:true, mensaje:rta};
                            if(obtenido.ok){
                                try{
                                    params.cuando_ok(obtenido.mensaje);
                                    if(con_fondo){
                                        if(!params.usar_fondo_de.id){
                                            params.usar_fondo_de.id="id_temporario_"+id_temporario++;
                                        }
                                        if(params.mostrar_tilde_confirmacion){
                                            setTimeout('enviar_quitar_fondo('+JSON.stringify(params.usar_fondo_de.id)+')',3000);
                                            params.usar_fondo_de.style.backgroundImage=URL_IMAGEN_CONFIRMADO;
                                            params.usar_fondo_de.style.backgroundRepeat='no-repeat';
                                            params.usar_fondo_de.style.backgroundPosition='top right';
                                        }else{
                                            enviar_quitar_fondo(params.usar_fondo_de.id);
                                        }
                                    }
                                    document.body.style.cursor = "default";
                                }catch(err_llamador){
                                    funcion_atrapar_error(descripciones_de_error(err_llamador),2);
                                }
                            }else{
                                funcion_atrapar_error(obtenido.mensaje,3);
                            }
                        }catch(err_json){
                            funcion_atrapar_error('ERROR PARSEANDO EL JSON '+':'+err_json.description+' / '+JSON.stringify(err_json)+' / '+rta,4);
                        }
                    }else{
                        funcion_atrapar_error(peticion.responseText,5);
                    }
                }catch(err){
                    funcion_atrapar_error(descripciones_de_error(err),6);
                }
                if(params.finalmente){
                    try{
                        params.finalmente();
                    }catch(err){
                        funcion_atrapar_error('Error en el proceso de finalización luego de enviado un paquete\n'+descripciones_de_error(err),8);
                    }
                }
            }
        }
        peticion.open('POST', params.destino, params.asincronico); // !sincronico);
        peticion.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
        var parametros=params.preprocesar_paquete(params.paquete);
        if(params.voy_por){
            parametros+="&voy_por="+encodeURIComponent(JSON.stringify(params.voy_por));
        }
        if(params.estado){
            parametros+="&estado="+encodeURIComponent(JSON.stringify(params.estado));
        }
        if(params.proceso){
            parametros+='&proceso='+params.proceso;
        }
        peticion.send(parametros);
    }catch(err){
        funcion_atrapar_error(err,7);
    }
    if(!params.asincronico){
        document.body.style.cursor = "default";
        return rta;
    }else{
        document.body.style.cursor = "progress";
    }
}

function obtener_arreglo_asociativo_con_valores_de_elementos(arreglo_nombres_de_elementos){
    campos_con_valores={};
    for(var i in arreglo_nombres_de_elementos){ if(arreglo_nombres_de_elementos.hasOwnProperty(i)){
        var campo=arreglo_nombres_de_elementos[i];
        var elemento=elemento_existente(campo);
        if(elemento.type=='checkbox'){
            campos_con_valores[campo]=elemento.checked;
        }else{
            campos_con_valores[campo]=elemento.value;
        }
    }}
    return campos_con_valores;
}
function proceso_encuesta_boton_ejecutar(proceso,id_boton,campos,cuando_ok,cuando_error){
    var poner_mensaje=function(mensaje,color){
        var elemento_rta=elemento_existente('proceso_encuesta_respuesta');
        if(es_objeto(mensaje)){
            elemento_rta.textContent=JSON.stringify(mensaje);
        }else{
            elemento_rta.textContent=mensaje;
        }
        elemento_rta.style.backgroundColor=color;
    }
    enviar_paquete({
        proceso:proceso,
        paquete:obtener_arreglo_asociativo_con_valores_de_elementos(campos),
        cuando_ok:cuando_ok||function(mensaje){ poner_mensaje(mensaje,'lightGreen'); },
        cuando_error:cuando_error||function(mensaje){ poner_mensaje(mensaje,'yellow'); },
        usar_fondo_de:elemento_existente(id_boton)
    });
}

var proceso_comenzo;

var html={
    format:'',
    begin:'<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><meta http-equiv=Content-Type content="text/html; charset=windows-1252"/><meta name=ProgId content=Excel.Sheet/><meta name=Generator content="Microsoft Excel 11"/></head><body>',
    end:'</body></html>'
}

function enviar_a_procesar(params){
"use strict";
    controlar_parametros(params,{
        proceso:null,
        campos:{validar:es_objeto},
        cuando_ok:{validar:es_funcion},
        cuando_error:{validar:es_funcion},
        cuando_un_paso:{validar:es_funcion},
        elemento_boton:{validar:es_elemento},
        voy_por:null,
        estado:null,
        impresion:{validar:es_booleano}
    });
    var elemento_rta=elemento_existente('proceso_formulario_respuesta');
    if(!params.voy_por){
        proceso_comenzo=new Date();
    }
    var frase_procesando='procesando desde '+proceso_comenzo.getHours()+':'+proceso_comenzo.getMinutes()+':'+proceso_comenzo.getSeconds();
    if(!params.voy_por){
        elemento_rta.innerHTML=frase_procesando;
        elemento_rta.style.backgroundColor='cyan';
    }
    var poner_mensaje=function(mensaje,en_vez_de_poner_hacer_esto,color,cuando_un_paso){
        if(cuando_un_paso){
            cuando_un_paso(mensaje);
        }
        if(en_vez_de_poner_hacer_esto && (!mensaje || !mensaje.parcial)){
            en_vez_de_poner_hacer_esto(mensaje);
        }else{
            elemento_rta.style.backgroundColor=color;
            if(es_objeto(mensaje)){
                if(mensaje.tipo=='html'){
                    elemento_rta.innerHTML=mensaje.html;
                    if(mensaje.js_indirecto){
                        setTimeout(mensaje.js_indirecto,500);
                    }
                }else if(mensaje.parcial){
                    elemento_rta.innerHTML=frase_procesando+'<BR>'+JSON.stringify(mensaje.parcial).small()+'<BR>'+JSON.stringify(mensaje.estado).small();
                    elemento_rta.style.backgroundColor='cyan';
                    params.voy_por=mensaje.parcial;
                    params.estado=mensaje.estado;
                    enviar_a_procesar(params);
                }else if(mensaje.tipo=='tedede_cm'){
                    elemento_rta.innerHTML='';
                    //elemento_rta.style.backgroundColor='';
                    var contenido;
                    domCreator.show_exceptions=proceso_encuesta_respuesta;
                    if('pre_procesar' in mensaje){
                        contenido=window[mensaje.pre_procesar](mensaje.tedede_cm);
                    }else{
                        contenido=mensaje.tedede_cm;
                    }
                    domCreator.grab(elemento_rta,contenido);
                }else{
                    elemento_rta.textContent=JSON.stringify(mensaje);
                }
                if(document.getElementById('boton_exportar')){
                    boton_exportar.style.visibility='visible';
                   // boton_exportar.href="data:text/csv;base64," + btoa(html.begin+elemento_rta.innerHTML+html.end);
                    boton_exportar.href="data:application/vnd.ms-excel;base64," + btoa(html.begin+elemento_rta.innerHTML+html.end);
                    boton_exportar.download="exportar.xls";
                }
            }else{
                elemento_rta.textContent=mensaje;
            }
        }
        if(!es_objeto(mensaje) || !mensaje.parcial){
            params.elemento_boton.disabled=false;
        }
    }
    var parametros_para_el_paquete=params.campos.valores||obtener_arreglo_asociativo_con_valores_de_elementos(params.campos);
    if(params.impresion){
        ir_a_url(location.pathname+'?imprimir='+params.proceso+'&todo='+encodeURIComponent(JSON.stringify(parametros_para_el_paquete)));
    }else{
        params.elemento_boton.disabled=true;
        enviar_paquete({
            proceso:params.proceso,
            paquete:parametros_para_el_paquete,
            cuando_ok:function(mensaje){ poner_mensaje(mensaje,params.cuando_ok,'lightGreen',params.cuando_un_paso); },
            cuando_error:function(mensaje){ poner_mensaje(mensaje,params.cuando_error,'yellow'); },
            usar_fondo_de:params.elemento_boton,
            voy_por:params.voy_por,
            estado:params.estado,
            asincronico:true
        });
    }
}

/*
function proceso_formulario_boton_ejecutar(proceso,id_boton,campos,cuando_ok,cuando_error,impresion,cuando_un_paso){
    enviar_a_procesar({
        proceso:proceso, 
        elemento_boton:elemento_existente(id_boton), 
        campos:campos, 
        cuando_ok:cuando_ok, 
        cuando_error:cuando_error, 
        cuando_un_paso:cuando_un_paso, 
        impresion:impresion 
    });
}
*/
function boton_ingresar_usuario(){
"use strict";
    var todo_ok=true;
    enviar_paquete({
        proceso:'ingresar_usuario',
        paquete:{
            tra_usu:elemento_existente('tra_usu').value, 
            tra_nombre:elemento_existente('tra_nombre').value, 
            tra_apellido:elemento_existente('tra_apellido').value, 
            tra_interno:elemento_existente('tra_interno').value, 
            tra_rol:elemento_existente('tra_rol').value, 
            tra_rol_a_ingresar:elemento_existente('tra_rol_a_ingresar').value, 
            tra_mail:elemento_existente('tra_mail').value, 
            tra_clave:trim(elemento_existente('tra_clave').value), 
        },
        cuando_ok:function(datos){
            elemento_existente('proceso_formulario_respuesta').textContent=datos;
            elemento_existente('tra_clave').value=hex_md5(trim(elemento_existente('tra_clave').value)+trim(elemento_existente('tra_usu').value.toLowerCase()));
        },
        cuando_error:function(mensaje){
            elemento_existente('proceso_formulario_respuesta').textContent=mensaje;
        },
        usar_fondo_de:elemento_existente('boton_ingresar_usuario'),
        mostrar_tilde_confirmacion:true
    });
}


var clave_a_enviar_para_login_dual=false;

function adaptar_clave_para_enviar(clave,usuario){
    if(clave_a_enviar_para_login_dual){
        return clave;
    }else{
        return hex_md5(trim(clave)+trim(usuario.toLowerCase()));
    }
}

function boton_login(){
"use strict";
    var todo_ok=true;
    var clave_a_enviar;
    enviar_paquete({
        proceso:'login',
        paquete:{
            tra_usu:elemento_existente('tra_usu').value.toLowerCase(), 
            tra_clave:adaptar_clave_para_enviar(elemento_existente('tra_clave').value,elemento_existente('tra_usu').value),
            tra_borrar_localstorage:elemento_existente('tra_borrar_localstorage').checked
        },
        cuando_ok:function(datos){
            elemento_existente('proceso_formulario_respuesta').textContent=datos;
            elemento_existente('tra_clave').value='';
            if(elemento_existente('tra_borrar_localstorage').checked){
                borrar_localStorage(true);
            }
            // var regexp_logut=/(logout|login)$/i;
            // ir_a_url(regexp_logut.test(document.location.href)?(location.pathname+'?hacer=menu'):document.location.href);
            ir_a_url(location.pathname+'?hacer=bienvenida');
        },
        cuando_error:function(mensaje){
            elemento_existente('proceso_formulario_respuesta').textContent=mensaje;
        },
        usar_fondo_de:elemento_existente('boton_login'),
        mostrar_tilde_confirmacion:true
    });
}

function boton_cambio_de_clave(){
"use strict";
    var todo_ok=true;
    enviar_paquete({
        proceso:'cambio_de_clave',
        paquete:{
            tra_usu:elemento_existente('tra_usu').value, 
            tra_clave_vieja:adaptar_clave_para_enviar(elemento_existente('tra_clave_vieja').value,elemento_existente('tra_usu').value),
            tra_clave_nueva:trim(elemento_existente('tra_clave_nueva').value), 
            tra_clave_repet:trim(elemento_existente('tra_clave_repet').value), 
        },
        cuando_ok:function(datos){
            elemento_existente('proceso_formulario_respuesta').textContent=datos;
            elemento_existente('tra_clave_vieja').value=hex_md5(trim(elemento_existente('tra_clave_nueva').value)+trim(elemento_existente('tra_usu').value.toLowerCase()));
        },
        cuando_error:function(mensaje){
            elemento_existente('proceso_formulario_respuesta').textContent=mensaje;
        },
        usar_fondo_de:elemento_existente('boton_cambio_de_clave'),
        mostrar_tilde_confirmacion:true
    });
}

function boton_sin_pass(){
    elemento_existente('boton_mandar_mail').style.visibility='visible';
    elemento_existente('tra_mail').style.visibility='visible';
    var deshabilitar_y_vaciar=function(id){
        var elemento=elemento_existente(id);
        if(elemento.type=='button'){
        }else{
            elemento.value='';
        }
        elemento.disabled=true;
    }
    deshabilitar_y_vaciar('tra_usu');
    deshabilitar_y_vaciar('tra_clave');
    deshabilitar_y_vaciar('tra_borrar_localstorage');
    deshabilitar_y_vaciar('boton_login');
    deshabilitar_y_vaciar('boton_sin_pass');
}

function boton_mandar_mail(){
    var tra_mail=elemento_existente('tra_mail');
    if(!tra_mail.value || !tra_mail.value.match(/@/)){
        alert('Hay que especificar un mail');
    }else{
        enviar_paquete({
            proceso:'mandar_nueva_clave',
            paquete:{
                tra_mail:tra_mail.value, 
            },
            cuando_ok:function(datos){
                elemento_existente('proceso_formulario_respuesta').textContent=datos;
            },
            cuando_error:function(mensaje){
                elemento_existente('proceso_formulario_respuesta').textContent=mensaje;
            },
            usar_fondo_de:elemento_existente('boton_mandar_mail'),
            mostrar_tilde_confirmacion:true
        });
    }
}

function boton_correr_consistencias(){
    elemento_existente('proceso_formulario_respuesta').textContent='';
    "use strict";
    var todo_ok=true;
    enviar_paquete({
        proceso:'correr_consistencias',
        paquete:{
            tra_bol_desde:elemento_existente('tra_bol_desde').value, 
            tra_bol_hasta:elemento_existente('tra_bol_hasta').value, 
            tra_consistir_todas:elemento_existente('tra_consistir_todas').checked
        },
        cuando_ok:function(datos){
            elemento_existente('proceso_formulario_respuesta').textContent=datos;
            //elemento_existente('tra_bol_desde').value='';
            //elemento_existente('tra_bol_hasta').value='';
            //var regexp_logut=/(logout|login)$/i;
            //ir_a_url(regexp_logut.test(document.location.href)?(location.pathname+'?hacer=menu'):document.location.href);
        },
        cuando_error:function(mensaje){
            elemento_existente('proceso_formulario_respuesta').textContent=mensaje;
        },
        asincronico:true,
        usar_fondo_de:elemento_existente('boton_correr_consistencias'),
        mostrar_tilde_confirmacion:true
    });
}

function proximo_elemento(elemento){
"use strict";
    var proximo=elemento;
    var no_me_voy_a_colgar=200;
    if(elemento.children.length){
        while(proximo.children.length>0 && no_me_voy_a_colgar--){
            proximo=proximo.children[0];
        }
        return proximo;
    }else{
        while(proximo && proximo.nextElementSibling===null && no_me_voy_a_colgar--){
            proximo=proximo.parentNode;
        }
        if(proximo){
            return proximo.nextElementSibling;
        }
    }
    return null;
}

function es_elemento_interactivo(elemento){
"use strict";
    return (
               (elemento instanceof HTMLInputElement 
                || elemento instanceof HTMLButtonElement 
                || elemento instanceof HTMLTextAreaElement
               ) && !elemento.disabled
              || elemento instanceof HTMLElement && elemento.contentEditable=="true"
           ) && elemento.style.display!='none' && elemento.style.visibility!='hidden' && !elemento.saltearEnter;
}

function proximo_elemento_que_sea(elemento, controlador){
"use strict";
    var proximo=proximo_elemento(elemento);
    var no_me_voy_a_colgar=2000;
    while(proximo && !controlador(proximo) && no_me_voy_a_colgar--){
        proximo=proximo_elemento(proximo);
    }
    return proximo;
}

function enter_hace_tab_en_este_elemento(elemento){
    return elemento.id.substr(0,4)!='var_' && !elemento.getAttribute('nuestro_campo');
}

window.onkeypress=function(evento){
    if((evento.which==13 || evento.which==10) && evento.ctrlKey){
        var enfoco=document.activeElement;
        if(enfoco.tagName=='TEXTAREA'){
            enfoco.style.height=enfoco.offsetHeight+32+'px';
            enfoco.style.width=enfoco.offsetWidth+32+'px';
        }
    }
}

document.onkeypress=function(evento){
"use strict";
    if(evento.which==13){ // Enter
        var enfoco=this.activeElement;
        var este=this.activeElement;
        if(este.type!="button" && este.type!="textarea"){
            if(enter_hace_tab_en_este_elemento(este)){
                var no_me_voy_a_colgar=2000;
                while(este && this.activeElement===enfoco && no_me_voy_a_colgar--){
                    este=proximo_elemento_que_sea(este,es_elemento_interactivo);
                    este.focus();
                }
                if(este){
                    evento.preventDefault();
                }
            }
        }
    }
}

function mostrar_opciones(id_elemento_opciones,que_poner){
    var elemento_dato;
    var id_dato;
    try{
        var id_dato=quitar_prefijo(id_elemento_opciones,'opciones_de_');
    }catch(e){
    }
    elemento_dato=document.getElementById(id_dato);
    if(elemento_dato && elemento_dato.disabled){
        return false;
    }
    var elemento=elemento_existente(id_elemento_opciones);
    elemento.style.display=que_poner||(elemento.style.display=='table'?'none':'table');
}

function mostrar_opciones_asignar(id_elemento_destino,valor){
    var elemento=elemento_existente(id_elemento_destino);
    elemento.value=valor;
    mostrar_opciones('opciones_de_'+id_elemento_destino,'none');
}

function mostrar_status(fondo,que,evaluo){
    var texto=document.createElement('div');
    texto.textContent=que+(evaluo?': '+eval(que):'');
    fondo.appendChild(texto);
}

var contolador_cuantas_instancias;
var direccion_url;
var direccion_url_eah2012;
var estoy_en_la_eah=true;

window.addEventListener('load',function(){ 
    direccion_url_eah2012='eah2012.php'
    direccion_url=document.location.pathname;
    if(direccion_url.indexOf(direccion_url_eah2012)!=-1){
        estoy_en_la_eah=true;
    }else{
        estoy_en_la_eah=false;
    }
});

function instalar_contolador_cuantas_instancias(){
  window.addEventListener('load',function(){ 
    contolador_cuantas_instancias=new SharedWorker('../tedede/cuantas_instancias.js');
    contolador_cuantas_instancias.port.addEventListener('message',function(e){ 
    "use strict";
        if(e.data.asignar_id){
            contolador_cuantas_instancias.port.asignar_id=e.data.asignar_id;
        }
        var cartel_aviso=document.getElementById('contolador_cuantas_instancias_aviso');
        if(e.data.cant_activos>1 && estoy_en_la_eah ){
            if(!cartel_aviso){
                cartel_aviso=document.createElement("div");
                cartel_aviso.id='contolador_cuantas_instancias_aviso';
                document.body.appendChild(cartel_aviso);
            }
            cartel_aviso.textContent='ATENCIÓN. Parece que hay varias solapas abiertas ('+e.data.cant_activos+
                '). Es importante cerrar todas las solapas para que haya una sola. '+
                (localStorage.getItem('debug_tedede_solapas')?JSON.stringify(e.data):'');
            cartel_aviso.style.display=null;
            cartel_aviso.onclick=function(){
                contolador_cuantas_instancias.port.postMessage({accion:'status'});
            }
        }else{
            if(cartel_aviso){
                cartel_aviso.style.display='none';
            }
        }
    });
    contolador_cuantas_instancias.port.start();
    window.addEventListener('unload',function(){ 
    "use strict";
        contolador_cuantas_instancias.port.postMessage({accion:'desconectar',id_desconectando:contolador_cuantas_instancias.port.asignar_id});
    });
  });
}

function click_ir_url(url,evento){
    if(!evento.ctrlKey){
        location.href=url;
        event.preventDefault()
    }
}

function log_pantalla_principal(mensaje){
    if(localStorage.getItem('log_pantalla_principal')){
        var texto=document.createElement('div');
        texto.textContent=mensaje;
        texto.className='debug_inline';
        elemento_existente('div_principal').appendChild(texto);
    }
}
function editar_error(que_file,que_line,fondo){
    "use strict";
    var todo_ok=true;
    enviar_paquete({
        destino:'../tools/reporte_errores.php',
        paquete:{
            tra_file:que_file, 
            tra_line:que_line, 
        },
        cuando_ok:function(datos){
        },
        cuando_error:function(mensaje){
            alert('paso_error'+que_file+' '+que_line+' con el mensaje '+mensaje);
        },
        asincronico:false,
        usar_fondo_de:fondo,
        mostrar_tilde_confirmacion:true
    });
}
function detectar_capsLock_y_dar_enter(e){
    var kc = Number(e.keyCode?e.keyCode:e.which);
    var sk = e.shiftKey?e.shiftKey:((kc == 16)?true:false);
    if(((kc >= 65 && kc <= 90) && !sk)||((kc >= 97 && kc <= 122) && sk)){
        document.getElementById('divMayus').style.visibility = 'visible';
    }else{
         document.getElementById('divMayus').style.visibility = 'hidden';
    }
    // /*
    if(kc==13){
        if(document.getElementById("boton_login")){
            boton_login();
        }else if(document.getElementById("boton_ingresar_usuario") && event.target.id=="tra_clave"){
            boton_ingresar_usuario();
        }
    }
    //*/
}

function desplegar_extender_texto(este){
    if(!document.getElementById('contenedor_extender_texto')){
        var textoarea = document.createElement('textarea');
        textoarea.value = este.value;
        textoarea.onkeyup = function(){ return extender_elemento_al_contenido(this); }
        textoarea.onblur = function(){
            este.value = textoarea.value;
            padre = textoarea.parentNode;
            padre.removeChild(textoarea);
        }
        textoarea.id = 'contenedor_extender_texto';
        document.body.appendChild(textoarea);
        extender_elemento_al_contenido(textoarea);
        textoarea.style.position = 'fixed';
        textoarea.style.left = (este.offsetLeft + 10) + 'px';
        textoarea.style.top = (este.offsetTop + 10) + 'px';
        textoarea.focus();
    }
}
function extender_elemento_al_contenido(esto,noAchicar){
    if(!noAchicar){
        while (
            esto.rows > 1 &&
            esto.scrollHeight < esto.offsetHeight
        ){
            esto.rows--;
        }
    }
    var h=0;
    while (esto.scrollHeight > esto.offsetHeight && h!==esto.offsetHeight)
    {
        h=esto.offsetHeight;
        esto.rows++;
    }
    // esto.rows++    
}

function traer_combos(origen, cuales){
    // alert('quiero traer combos para '+cuales+' del '+origen+' '+elemento_existente(origen).value);
    // return;
    enviar_paquete({
        proceso:'traer_combos',
        paquete:{
            tra_campo_origen:origen,
            tra_valor:elemento_existente(origen).value,
            tra_cuales:cuales
        },
        cuando_ok:function(mensaje){
            rta=mensaje;
            ok=mensaje.ok;
            var destino = '';
            for(var cual in cuales){if(cuales.hasOwnProperty(cual)){
                destino = document.getElementById('opciones_de_'+cuales[cual]);
                destino.innerHTML = rta[cuales[cual]];
            }}
        },
        usar_fondo_de:elemento_existente(origen),
        mostrar_tilde_confirmacion:true,
        asincronico:false
    });
}

function probar_node(nombreParametro, nombreBoton, listaIdParametros){
    //alert(JSON.stringify([nombreParametro, nombreBoton, listaIdParametros]));
    listaParametros=obtener_arreglo_asociativo_con_valores_de_elementos(listaIdParametros);
    listaParametros['tra_ope']=operativo_actual;
    listaParametros['tra_anio_ope']=anio_operativo;
    var paramNode='';
    //paramNode= parametros_via_url(listaParametros);
    paramNode=encodeURIComponent(JSON.stringify(listaParametros));
    alert('param a node '+ paramNode);
    //json_stringify(paramNode)
    window.location.href='../tabulado?tabulado='+ paramNode;
}