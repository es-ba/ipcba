
var pru_casos_para_cuadros=[
    { modulo: pru_domCreator
    , casos: [
        { titulo: "tabla simple"
        , entrada: { tipox: "tabla", id:"este", filas: [ {uno:'a', dos:'b'}, {uno:['cc','j'], dos:{ className:'small', nodes:'ddd'}} ] }
        , salida: '<table id="este"><tbody><tr><td>a</td><td>b</td></tr><tr><td>ccj</td><td class="small">ddd</td></tr></tbody></table>'
        }
        ,
        { titulo: "cuadro_cp típico"
        , entrada: { tipox: "cuadro_cp", className:"cuadro", filas: [ 
            {renglon:0, formato_renglon:'anchos', uno:100, dos:'auto'}
          , {renglon:1, formato_renglon:'E1n', uno:'a', dos:'b'}
          , {renglon:2, formato_renglon:'D.4', uno:null, dos:'c'}
          ] }
        , salida: '<table class="cuadro"><tbody><tr class="encabezado"><td style="width: 100px;">a</td><td class="numerico">b</td></tr><tr><td colspan="2" rowspan="2">c</td></tr></tbody></table>'
        }
        ,
        { titulo: "cuadro_cp típico. Bug cuando ponía auto antes que 100 en los anchos andaba mal"
        , entrada: { tipox: "cuadro_cp", className:"cuadro", filas: [ 
            {renglon:0, formato_renglon:'anchos', uno:'auto', dos:100}
          , {renglon:1, formato_renglon:'E1n', uno:'a', dos:'b'}
          , {renglon:2, formato_renglon:'D.4', uno:null, dos:'c'}
          ] }
        , salida: '<table class="cuadro"><tbody><tr class="encabezado"><td>a</td><td class="numerico" style="width: 100px;">b</td></tr><tr><td colspan="2" rowspan="2" style="width: 100px;">c</td></tr></tbody></table>'
        }
    ]
    }
,
    { modulo: pru_traductor_cuadro_cpm
    , casos: [
        { titulo: "caso simple traducción cuadro_cpm"
        , entrada: { 
            tipox:"cuadro_cpm"
          , id:'este_cuadro'
          , filas:[
              {formato_renglon:'anchos', lateral1:'auto', lateral2:'500'   , cabezal1:null, celda:'100' }
            , {formato_renglon:'E111'  , lateral1:'Cód' , lateral2:'Índice', cabezal1:null, celda:null  }
            , {formato_renglon:'D11n'  , lateral1:'L1'  , lateral2:'LLLL1' , cabezal1:'C1', celda:'X1-1'}
            , {formato_renglon:'D11n'  , lateral1:'L1'  , lateral2:'LLLL1' , cabezal1:'C2', celda:'X1-2'}
            , {formato_renglon:'D11n'  , lateral1:'L1'  , lateral2:'LLLL1' , cabezal1:'C3', celda:'X1-3'}
            , {formato_renglon:'D11n'  , lateral1:'L2'  , lateral2:'LLLL2' , cabezal1:'C1', celda:'X2-1'}
            , {formato_renglon:'D11n'  , lateral1:'L2'  , lateral2:'LLLL2' , cabezal1:'C2', celda:'X2-2'}
            , {formato_renglon:'D11n'  , lateral1:'L2'  , lateral2:'LLLL2' , cabezal1:'C3', celda:'X2-3'}
            ]
          }
        , intermedio1: {
            tipox:"cuadro_cpm_paso1"
          , id:'este_cuadro'
          , filas:[
              {formato_renglon:'anchos', lateral1:'auto', lateral2:'500'   , filas: [{ cabezal1:null, celda:'100' }]}
            , {formato_renglon:'E111'  , lateral1:'Cód' , lateral2:'Índice', filas: [{ cabezal1:null, celda:null  }]}
            , {formato_renglon:'D11n'  , lateral1:'L1'  , lateral2:'LLLL1' , filas: [
                {cabezal1:'C1', celda:'X1-1'}
              , {cabezal1:'C2', celda:'X1-2'}
              , {cabezal1:'C3', celda:'X1-3'}
              ]}
            , {formato_renglon:'D11n'  , lateral1:'L2'  , filas: [
                {cabezal1:'C1', celda:'X2-1'}
              , {cabezal1:'C2', celda:'X2-2'}
              , {cabezal1:'C3', celda:'X2-3'}
              ]}
            ]
          }
        , intermedio2: {
            tipox:"cuadro_cpm_paso2"
          , id:'este_cuadro'
          , filas:[
              {formato_renglon:'anchos', lateral1:'auto', lateral2:'500'   , filas: [
                { cabezal1:'C1', celda:'100' }
              , { cabezal1:'C2', celda:'100' }
              , { cabezal1:'C3', celda:'100' }
              ]}
            , {formato_renglon:'E111'  , lateral1:'Cód' , lateral2:'Índice', filas: [
                { cabezal1:'C1', celda:'C1'  }
              , { cabezal1:'C2', celda:'C2'  }
              , { cabezal1:'C3', celda:'C3'  }
              ]}
            , {formato_renglon:'D11n'  , lateral1:'L1'  , lateral2:'LLLL1' , filas: [
                {cabezal1:'C1', celda:'X1-1'}
              , {cabezal1:'C2', celda:'X1-2'}
              , {cabezal1:'C3', celda:'X1-3'}
              ]}
            , {formato_renglon:'D11n'  , lateral1:'L2'  , filas: [
                {cabezal1:'C1', celda:'X2-1'}
              , {cabezal1:'C2', celda:'X2-2'}
              , {cabezal1:'C3', celda:'X2-3'}
              ]}
            ]
          }
        , salida: {
            tipox:"cuadro_cp"
          , id:'este_cuadro'
          , filas:[ // al formato_renglon se le repite el último caracter tantas veces como columnas de datos de la matriz haya-1
              {renglon:0, formato_renglon:'anchos', lateral1:'auto',lateral2:'500'   ,'columna["C1"]':'100' ,'columna["C2"]':'100' ,'columna["C3"]':'100' }
            , {renglon:1, formato_renglon:'E11111', lateral1:'Cód', lateral2:'Índice','columna["C1"]':'C1'  ,'columna["C2"]':'C2'  ,'columna["C3"]':'C3'  }
            , {renglon:2, formato_renglon:'D11nnn', lateral1:'L1' , lateral2:'LLLL1' ,'columna["C1"]':'X1-1','columna["C2"]':'X1-2','columna["C3"]':'X1-3'}
            , {renglon:3, formato_renglon:'D11nnn', lateral1:'L2' , lateral2:'LLLL2' ,'columna["C1"]':'X2-1','columna["C2"]':'X2-2','columna["C3"]':'X2-3'}
            ]
          }
        }
    ]
    }
]

pru_casos=pru_casos.concat(pru_casos_para_cuadros);

function pru_traductor_cuadro_cpm(caso){
    var obtenido1=traducir_cuadro_cpm_cp_paso1(caso.entrada);
    pru_comparar(caso.intermedio1,obtenido1,caso.titulo+' paso 1');
    var obtenido2=traducir_cuadro_cpm_cp_paso2(obtenido1);
    pru_comparar(caso.intermedio2,obtenido2,caso.titulo+' paso 2');
    var obtenido3=traducir_cuadro_cpm_cp_paso3(obtenido2);
    pru_comparar(caso.salida,obtenido3,caso.titulo+' paso 3');
}
