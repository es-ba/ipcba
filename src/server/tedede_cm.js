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