"use strict";

function DomCreator(){
    "use strict";
    this.show_exceptions=false;
}
    
DomCreator.prototype.stylize=function(target_element,styles,context,saltear){
    "use strict";
    if(typeof(styles)!='object'){
        target_element.textContent=styles;
    }else if(styles instanceof Array){
        this.grab(target_element,styles,context);
    }else if(styles!==null){
        for(var attribute in styles) if(styles.hasOwnProperty(attribute)){
            if(attribute=='nodes'){
                this.grab(target_element,styles[attribute],cambiandole(context,{literal:attribute=='literal'}));
            }else if(attribute=='xmlns'){
            }else if(attribute=='tipox'){
            }else if((saltear||{})[attribute]){
            }else{
                if(attribute=='style'){
                    if(typeof(styles[attribute])=='object'){
                        for(var sub_attr in styles[attribute]) if(styles[attribute].hasOwnProperty(sub_attr)){
                            if(!(sub_attr in target_element[attribute])){
                                throw this.exception('estilo '+JSON.stringify(sub_attr)+' inexistente en elemento '+target_element.tagName,context);
                            }
                            target_element[attribute][sub_attr]=styles[attribute][sub_attr];
                        }
                    }else{
                        target_element.style.cssText=styles[attribute];
                    }
                }else if(((target_element[attribute]||{}).toString())=='[object SVGAnimatedLength]'){
                    target_element[attribute].baseVal.value=Number(styles[attribute]);
                }else if(!(attribute in target_element) && (attribute in target_element.style)){
                    target_element.style[attribute]=styles[attribute];
                }else{
                    if(!(attribute in target_element)){
                        throw this.exception("atributo "+JSON.stringify(attribute)+" inexistente en elemento "+target_element.tagName,context);
                    }
                    target_element[attribute]=styles[attribute];
                }
            }
        }
    }
};
    
DomCreator.prototype.createObjectStylizeAndGrab=function(target_element,tipox,content,context){
    "use strict";
    var factory='create_'+tipox;
    if(factory in this){
        if(factory=='create_tabla'){
            this.create_tabla(target_element,tipox,content,context);
        }else{
            this[factory](target_element,tipox,content,context);
        }
    }else{
        throw this.exception('tipox inexistente '+tipox);
    }
};
    
DomCreator.prototype.createElementDOM=function(target_element,tagName,content,context){
    "use strict";
    var new_element;
    if(context.nameSpaceXml){
        new_element=document.createElementNS(context.nameSpaceXml,tagName);
    }else{
        new_element=document.createElement(tagName);
    }
    this.stylize(new_element,content,context);
    target_element.appendChild(new_element);
};
    
DomCreator.prototype.createElementSVG=function(target_element,tagName,content,context){
    "use strict";
    this.createElementDOM(target_element,tagName,content,cambiandole(context,{nameSpaceXml:'http://www.w3.org/2000/svg'}));
};

DomCreator.prototype.grab=function(target_element,content,context){
    "use strict";
    context=context||{};
    if(typeof(content)!='object' && 'innerText' in target_element && !target_element.textContent){
        // si es un contenido suelto dentro de un elemento que puede tener innerText pero no tiene...
        target_element.textContent=content;
    }else if(content instanceof Array){
        for(var i=0; i<content.length; i++){
            this.grab(target_element,content[i],context);
        }
    }else{
        if(typeof(content)!='object'){
            var new_text=document.createTextNode(content);
            target_element.appendChild(new_text);
        }else if(content){
            if('tipox' in content){
                this.createObjectStylizeAndGrab(target_element,content.tipox,content,context);
            }else{
                throw this.exception("Bad structure falta tipox",context,content);
            }
        }
    }
}
    
DomCreator.prototype.exception=function(message,context,show_content){
"use strict";
    if(this.show_exceptions){
        var message_element=document.createElement('div');
        message_element.className='debug_exceptions';
        message_element.textContent=message+(show_content?' '+JSON.stringify(show_content):'');
        (this.debug_errors_in||this.show_exceptions).appendChild(message_element);
    }
    return new Error(message);
};

DomCreator.prototype.create_debug_dump=function(target_element,tagName,content,context){
"use strict";
    target_element.textContent=JSON.stringify(content);
};

DomCreator.prototype.create_b        =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_div      =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_img      =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_p        =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_small    =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_span     =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_table    =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_td       =DomCreator.prototype.createElementDOM;
DomCreator.prototype.create_tr       =DomCreator.prototype.createElementDOM;
// -------------- SVG ------------------
DomCreator.prototype.create_svg      =DomCreator.prototype.createElementSVG;
DomCreator.prototype.create_circle   =DomCreator.prototype.createElementSVG;

var domCreator=new DomCreator();


function mostrar_ejemplos(){
    /* en vez de escribir
      document.write('<h1>Cuadros del IPC</h1>');
    */
    domCreator.grab(document.body,{h1: 'Cuadros del IPC'});
    /* La ventaja es cuando tenés que poner un < o un > o un & dentro del texto
      document.write('<h2>Algo & otro</h2>'); // esto no anda
      document.write('<h2>Algo &amp; otro</h2>'); // esto sí anda
      document.write('<h2>'+una_Variable+'</h2>'); // hay que asegurarse que una_Variable no tenga & o < etc...
    */
    /* 
    domCreator.grab(document.body,{h2: 'Algo & otro'});
    domCreator.grab(document.body,{h2: ['esto es solo un ejemplo ', {small: [ 'pero ', { small: 'muy'}, 'complicado']}]});
    domCreator.grab(document.body,
        {h2: 
            ['esto es solo un ejemplo ', 
                {small: 
                    [ 'pero '
                    , { small: 'muy'}
                    , 'complicado'
                    ]
                }
            ]
        }
    ); 
   */ 
}

var atributos_de_elemento_segun_formato_celda={
    '4':{tipox:"td", colSpan:'2', rowSpan:'2'},
    '3':{tipox:"td", colSpan:'3', rowSpan:'1'},
    '2':{tipox:"td", colSpan:'2'},
    'n':{tipox:"td", className:'numerico'},
    '1':{tipox:"td"},
    'C':{tipox:"td", className:'centrado'},
    'L':{tipox:"td", className:'izquierda'},
    'R':{tipox:"td", className:'derecha'},
    'W':{tipox:"td", className:'nowrap'},
    '5':{tipox:"td", colSpan:'2', rowSpan:'2', className:'izquierda'},
    '6':{tipox:"td", colSpan:'2', className:'centradob'},
    '7':{tipox:"td", colSpan:'3', rowSpan:'1', className:'centradob'},
    '8':{tipox:"td", rowSpan:'2', className:'izquierda'},
    '9':{tipox:"td", colSpan:'3', rowSpan:'2', className:'izquierda'},
    '0':{tipox:"td", colSpan:'4', rowSpan:'1', className:'centradob'},
}

var atributos_de_elemento_segun_formato_fila={
    'E':{tipox:"tr", className:'encabezado'},
    'P':{tipox:"tr", className:'encabezadop'},
    'N':{tipox:"tr", className:'niv_gen'},
    'D':{tipox:"tr"},
    'U':{tipox:"tr", className:'encabezadou'},
    'G':{tipox:"tr", className:'niv_pad'}, /*para las filas grupo-padre*/
}

DomCreator.prototype.create_tabla=function(target_element,tagName,content,context){
    var elemento_tabla=document.createElement('table');
    for(var id_fila in content.filas) if(iterable(id_fila,content.filas)){
        var fila=content.filas[id_fila];
        if(!('incluir_fila' in context) || context.incluir_fila(fila)){
            var elemento_fila=elemento_tabla.insertRow(-1);
            this.stylize(elemento_fila,context.estilo_fila||{});
            var numero_columna=0;
            for(var id_celda in fila) if(iterable(id_celda,fila)){
                var contenido_celda=fila[id_celda];
                numero_columna++;
                if(!('incluir_celda' in context) || context.incluir_celda(id_celda,contenido_celda,numero_columna,fila)){
                    var elemento_celda=elemento_fila.insertCell(-1);
                    this.stylize(elemento_celda,context.estilo_celda||{},context);
                    this.stylize(elemento_celda,contenido_celda,context);
                }
            }
        }
    }
    this.stylize(elemento_tabla,content,context,{filas:true});
    target_element.appendChild(elemento_tabla);
}

DomCreator.prototype.create_cuadro_cp=function(target_element,tagName,content,context){
    this.create_tabla(target_element,tagName,content,cambiandole(context,{
        incluir_fila:function(fila){
            if(fila.formato_renglon=='anchos'){
                this.ancho_columnas=fila;
                return false;
            }else{
                this.estilo_fila=atributos_de_elemento_segun_formato_fila[fila.formato_renglon[0]];
            }
            return true;
        },
        incluir_celda:function(nombre_campo,contenido_celda,numero_columna_sin_ajustar,fila){
            var celdas_de_formato={formato_renglon:true, renglon:true};
            var numero_columna=numero_columna_sin_ajustar-array_keys(celdas_de_formato).length;
            if(!(celdas_de_formato[nombre_campo]) && fila.formato_renglon.substr(numero_columna,1)!='.'){
                this.estilo_celda=atributos_de_elemento_segun_formato_celda[fila.formato_renglon[numero_columna]];
                if(this.ancho_columnas[nombre_campo]!='auto'){
                    this.estilo_celda.style=this.estilo_celda.style||{};
                    this.estilo_celda.style.width=this.ancho_columnas[nombre_campo]+'px';
                }else{
                    if('style' in (this.estilo_celda||{})){
                        this.estilo_celda.style=null;
                    }
                }
                return true;
            }else{
                return false;
            }
        }
    }));
}

DomCreator.prototype.create_cuadro_cpm=function(target_element,tagName,content,context){
   /* 
     var aux1=traducir_cuadro_cpm_cp_paso1(content);
     var aux2=traducir_cuadro_cpm_cp_paso2(aux1);
     var aux3=traducir_cuadro_cpm_cp_paso3(aux2);
     return aux3;
     
    return this.create_cuadro_cp(target_element, 'cuadro_cp', aux3, context); 
   */ 
    return this.create_cuadro_cp(target_element,tagName,traducir_cuadro_cpm_cp_paso3(traducir_cuadro_cpm_cp_paso2(traducir_cuadro_cpm_cp_paso1(content))), context);
    
}

function traducir_cuadro_cpm_cp(elemento_cuadro_cpm){
"use strict";
    var rta={tipox: "cuadro_cp"};
    // copio los atributos propios del cuadro
    for(var atributo in elemento_cuadro_cpm) if(iterable(atributo,elemento_cuadro_cpm)){
        if(atributo!='tipox' && atributo!='filas'){
            rta[atributo]=elemento_cuadro_cpm[atributo];
        }
    }
    // copio las filas
    rta.filas=[];
    var numero_renglon=0;
    var fila_nueva={};
    var laterales_fila_leida={}; // por fila que recorro me fijo los valores de sus laterales
    var laterales_fila_leida_antes=false; // la que leí antes
    var guardar_fila=function(){
        if(laterales_fila_leida_antes!==false){
            rta.filas.push(cambiandole(fila_nueva,laterales_fila_leida_antes));
            numero_renglon++;
        }
        laterales_fila_leida_antes=laterales_fila_leida;
        laterales_fila_leida={};
        fila_nueva={};
    }
    for(var id_fila in elemento_cuadro_cpm.filas) if(iterable(id_fila,elemento_cuadro_cpm.filas)){
        var fila_leida=elemento_cuadro_cpm.filas[id_fila];
        fila_nueva.renglon=numero_renglon;
        fila_nueva.formato_renglon=fila_leida.formato_renglon;
        for(var id_columna_leida in fila_leida) if(iterable(id_columna_leida,fila_leida)){
            if(id_columna_leida.substr(0,7)=='lateral'){
                // copio el valor para los laterales
                // fila_nueva[id_columna_leida]=fila_leida[id_columna_leida];
                laterales_fila_leida[id_columna_leida]=fila_leida[id_columna_leida];
            }else if(id_columna_leida=='celda'){
                var nombre_columna_nueva='columna'+JSON.stringify([fila_leida.lateral1]);
                if(JSON.stringify(laterales_fila_leida)!=JSON.stringify(laterales_fila_leida_antes)){
                    guardar_fila();
                }
                fila_nueva[nombre_columna_nueva]=fila_leida.celda;
            }
        }
        /*
        if(fila_leida.formato_renglon=='anchos'){
        }else{
        }
        */
    }
    guardar_fila();
    return rta;
}

function traducir_cuadro_cpm_cp_paso1(elemento_cuadro_cpm){
"use strict";
    var rta=cambiandole(elemento_cuadro_cpm, {tipox:'cuadro_cpm_paso1'});
    rta.filas=[];
    var lugares_donde_ya_puse={};
    for(var id_fila in elemento_cuadro_cpm.filas) if(iterable(id_fila,elemento_cuadro_cpm.filas)){
        var fila=elemento_cuadro_cpm.filas[id_fila];
        var parte_izquierda={};
        var parte_derecha={};
        for(var nombre_columna in fila) if(iterable(nombre_columna,fila)){
            if(nombre_columna.substr(0,7)=='lateral' || nombre_columna=='formato_renglon'){
                parte_izquierda[nombre_columna]=fila[nombre_columna];
            }else{
                parte_derecha[nombre_columna]=fila[nombre_columna];
            }
        }
        var json_parte_izquierda=JSON.stringify(parte_izquierda);
        var donde_estaba=lugares_donde_ya_puse[json_parte_izquierda];
        if(donde_estaba===undefined){
            donde_estaba=rta.filas.length;
            lugares_donde_ya_puse[json_parte_izquierda]=donde_estaba;
            rta.filas.push(parte_izquierda);
            rta.filas[donde_estaba].filas=[];
        }
        rta.filas[donde_estaba].filas.push(parte_derecha);
    }
    return rta;
}
function traducir_cuadro_cpm_cp_paso2(elemento_cuadro_cpm){
"use strict";
    var rta=cambiandole(elemento_cuadro_cpm, {tipox:'cuadro_cpm_paso2'});
    var vcelda;
    var vultima=rta.filas.length-1;
    var filadato=vultima+1;
    
    //for(var i = 0; i <= vultima; i++) 
    var i=0;
    do{
       if (rta.filas[i].formato_renglon.charAt(0) == 'D'){
            filadato=i;
            break;
       }
       i++;
    }while (i <= vultima );
    
    if(vultima>=filadato)  {
       vcelda= rta.filas[vultima].filas[0].cabezal1;
       rta.filas[0].filas[0].cabezal1= vcelda;
       rta.filas[1].filas[0].cabezal1= vcelda;
       rta.filas[1].filas[0].celda= vcelda;
       for (var nfil in rta.filas) if(iterable(nfil,rta.filas) && nfil <=1){ // FALTA cambiar este for
           for (var ncol in rta.filas[vultima].filas) if(iterable(ncol,rta.filas[vultima].filas) && ncol >=1){
               if(nfil==0) {
                   vcelda=rta.filas[0].filas[0].celda;
               }else{
                   vcelda= rta.filas[vultima].filas[ncol].cabezal1;
               }
               rta.filas[nfil].filas.push({cabezal1: rta.filas[vultima].filas[ncol].cabezal1, celda: vcelda});
           }
       }
       /*
       // version a mano
       rta.filas[0].filas[0].cabezal1='C1';
       rta.filas[0].filas.push({cabezal1:'C2', celda: celda0});
       rta.filas[0].filas.push({cabezal1:'C3', celda: celda0});
       rta.filas[1].filas[0]={cabezal1:'C1', celda:'C1'};
       rta.filas[1].filas.push({cabezal1:'C2', celda: 'C2'});
       rta.filas[1].filas.push({cabezal1:'C3', celda: 'C3'});

       // version que no funciona. Asignacion de punteros???
       f0_columnas=rta.filas[2].filas;
       f1_columnas=rta.filas[3].filas;
       for (var ncol in f0_columnas) if(iterable(ncol,f0_columnas)){
         f0_columnas[ncol].celda='100';
         alert ("fila0- col" + f0_columnas[ncol].cabezal1 + ":" + f0_columnas[ncol].celda)
       }  
       for (var ncol in f1_columnas) if(iterable(ncol,f1_columnas)){
         //f0_columnas[ncol].celda='100';
         f1_columnas[ncol].celda=f1_columnas[ncol].cabezal1;
         alert ("fila1- col" + f1_columnas[ncol].cabezal1 + ":" + f1_columnas[ncol].celda)
       }  
       rta.filas[0].filas=f0_columnas;
       rta.filas[1].filas=f1_columnas;
    */
    }
 
    return rta;
}
function traducir_cuadro_cpm_cp_paso3(elemento_cuadro_cpm){
"use strict";
    var rta=cambiandole(elemento_cuadro_cpm, {tipox:'cuadro_cp'});
    rta.filas=[];
    
    for(var id_fila in elemento_cuadro_cpm.filas) if(iterable(id_fila,elemento_cuadro_cpm.filas)){
        var fila=elemento_cuadro_cpm.filas[id_fila];
        var filanueva={};
        for(var nombre_columna in fila) if(iterable(nombre_columna,fila)){
            filanueva['renglon']=parseInt(id_fila);
            if(nombre_columna.substr(0,7)=='lateral' || nombre_columna=='formato_renglon'){
                filanueva[nombre_columna]=fila[nombre_columna];
            }
            else{
                var columnas= fila.filas;
                for(var ncol in columnas) if(iterable(ncol,columnas)){
                   var xcol ='columna["' + columnas[ncol].cabezal1 +'"]' ;
                   filanueva[xcol]=columnas[ncol].celda;
                   if(ncol!=0 && id_fila !=0) {
                       var f_renglon= filanueva['formato_renglon'];
                      filanueva['formato_renglon']= f_renglon + f_renglon.charAt(f_renglon.length-1);
                   }   
                }
            }
        }
        rta.filas.push(filanueva);
    }

    return rta;
}
