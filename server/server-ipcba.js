"use strict";

var Path = require('path');
var backendPlus = require("backend-plus");
var MiniTools = require('mini-tools');

var changing = require('best-globals').changing;

class AppIpcba extends backendPlus.AppBackend{
    constructor(){
        super();
        this.internalData={
            filterUltimoPeriodo : 'a2018m05',
            filterUltimoCalculo : 0,
            filterAgrupacion : 'Z'
        }
    }
    isAdmin(reqOrContext){
        var be = this;
        return reqOrContext && reqOrContext.user && reqOrContext.user[be.config.login.rolFieldName] == 'programador';
    }
    postConfig(){
        super.postConfig();
        this.fieldDomain.grupo={sortMethod:'codigo_ipc'};
        this.fieldDomain.grupopadre={sortMethod:'codigo_ipc', title:'grupo padre'};
    }
    get rootPath(){ return Path.resolve(__dirname,'..'); }
    configStaticConfig(){
        super.configStaticConfig();
        this.setStaticConfig(`
          server:
            port: 3034
            skins:
              "":
                local-path: client/
              confort:
                local-path: node_modules/backend-skins/dist/
              confort-bis:
                local-path: node_modules/backend-skins/dist/
              default:
                local-path: node_modules/backend-skins/dist/
          db:
            motor: postgresql
            host: localhost
            database: cvp_db
            schema: cvp
            user: cvpowner
            search_path: [cvp, ipcba, precios_app]
          login:
            schema: ipcba
            table: usuarios
            userFieldName: usu_usu
            passFieldName: usu_clave
            rolFieldName: usu_rol
            infoFieldList: [usu_usu, usu_rol]
            activeClausule: usu_activo
            double-dragon: true
            plus:
              allowHttpLogin: true
              fileStore: true
              loginForm:
                formTitle: example tables
                formImg: unlogged/tables-lock.png
            x-loginPagePath: false
          x-login:
            table: users
            userFieldName: username
            passFieldName: md5pass
            rolFieldName: rol
            infoFieldList: [username, rol]
            activeClausule: current_timestamp<=active_until
            lockedClausule: current_timestamp>=locked_since
          client-setup:
            cursors: true
            skin: default
            menu: true
            lang: es
            grid-buffer: wsql
            version: 0.1
            deviceWidthForMobile: 768px
            user-scalable: no
          logo: 
            path: client/img
        `);
    }
    addLoggedServices(){
        var be = this;
        super.addLoggedServices();
        this.app.get('/echo', function(req,res){
            res.end('echo');
        });
    }
    getProcedures(){
        var be = this;
        return super.getProcedures().then(function(procedures){
            return procedures.concat(
                require('./procedures-ipcba.js').map(be.procedureDefCompleter, be)
            );
        });
    }
    getMenu(context){
        var programador = {role:'programador'};
        var coordinador = {role:'coordinador'};
        var analista = {role:'analista'};
        var recepcionista = {role:'recepcionista'};
        var jefeCampo = {role:'jefe_campo'};
        var supervisor = {role:'supervisor'};
        var recepGabinete = {role:'recep_gabinete'};
        var migracion = {role:'migracion'};
        return {menu:[
            {menuType:'table', name:'bienvenida', selectedByDefault:true},
            {menuType:'menu', name:'ipad', onlyVisibleFor:[programador, analista, coordinador, jefeCampo, recepcionista], menuContent:[
                {menuType:'table', name:'personal', showInOfflineMode: false},
                {menuType:'table', name:'instalaciones', showInOfflineMode: false},
                {menuType:'hoja_ruta', name:'hoja_de_ruta', label: 'hoja de ruta', showInOfflineMode: true},
                {menuType:'preparar_instalacion', name:'instalar_dm', label: 'instalar dispositivo', showInOfflineMode: false},
                {menuType:'sincronizar', name:'sincronizar', showInOfflineMode: false},
                {menuType:'vaciar', name:'vaciar_dm', label:'vaciar ipad', showInOfflineMode: false},
            ], showInOfflineMode: true},
            {menuType:'matriz', name:'matriz', onlyVisibleFor:[programador], showInOfflineMode: false},
            {menuType:'menu', name:'calculos', label:'cálculo', onlyVisibleFor:[programador,coordinador,analista,migracion], menuContent:[
                {menuType:'table', name:'calculos', label:'cálculo', onlyVisibleFor:[programador,coordinador,analista,migracion], selectedByDefault:true},
                {menuType:'copia_calculo', name:'copias', label:'copias', onlyVisibleFor:[programador,coordinador,analista]},
            ]},
            {menuType:'menu', name:'administracion', label:'administración', menuContent:[
                {menuType:'table', name:'calculos_novobs', label:'altas y bajas manuales del cálculo', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType: 'menu',name:'app precios', onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                    {menuType:'exporta_precios_local', name:'exportaAppPreciosLocal', label:'exportar local'},
                    {menuType:'exporta_precios', name:'exportaAppPrecios', label:'exportar FINAL'},
                    {menuType: 'table', name:'app_agrupaciones',label:'agrupaciones'},
                    {menuType: 'table', name:'app_calculo_grupos',label:'cal_gru'},
                    {menuType: 'table', name:'app_calculo_productos',label:'cal_prod'},
                    {menuType: 'table', name:'app_grupos',label:'grupos'},
                    {menuType: 'table', name:'app_grupos_producto',label:'grupos_producto'},
                    {menuType: 'table', name:'app_productos',label:'productos'},
                    {menuType: 'table', name:'app_periodos',label:'periodos'},
                ]},
                {menuType:'table', name:'periodos_novpre', label:'anulación de precios', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'prodatrval', label:'atributos seleccionables', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'novdelobs', label:'borrar observaciones', onlyVisibleFor:[programador,coordinador,analista,recepGabinete]},
                {menuType:'table', name:'novdelvis', label:'borrar visitas', onlyVisibleFor:[programador,coordinador,analista,recepGabinete]},
                //{menuType:'table', name:'cierre_periodos', label:'cierre de períodos'},
                {menuType:'table', name:'periodos_vista_control_diccionario', label:'control del diccionario valores de atributos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'grupos_resp', label:'grupos de revision', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_calprodresp', label:'revision de los productos por el analista', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'cuadros', label: 'textos de los cuadros', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'ipcba_usuarios', label: 'usuarios', onlyVisibleFor:[programador,coordinador,analista]},
            ], onlyVisibleFor:[programador,coordinador,analista,recepGabinete]},
            {menuType:'menu', name:'canasta_ipcba', label:'canasta de IPCBA', menuContent:[
                {menuType:'table', name:'grupos'   , onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'productos', onlyVisibleFor:[programador,coordinador,analista,recepcionista,jefeCampo,recepGabinete,supervisor]},
            ], onlyVisibleFor:[programador,coordinador,analista,recepcionista,jefeCampo,recepGabinete,supervisor]},
            {menuType:'menu', name:'control_cierre', label:'control para cierre', menuContent:[
                {menuType:'table', name:'periodos_control_generacion_formularios'     , label:'completitud de visitas'},
                {menuType:'table', name:'periodos_control_grupos_para_cierre'     , label:'control de grupos'},
                {menuType:'table', name:'periodos_control_productos_para_cierre'  , label:'control de productos'},
            ], onlyVisibleFor:[programador,coordinador,analista]},
            {menuType:'menu', name:'gabinete', menuContent:[
                {menuType:'table', name:'calculos_novprod'               , label:'administración de externos', onlyVisibleFor:[programador,coordinador,analista]},
                //{menuType:'table', name:'calculos'              , label:'Cálculos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'calculos_canasta_producto'      , label:'canasta por producto', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_ajustes'       , label:'control de ajustes de precios', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_controlvigencias'      , label:'control de atributo vigencia', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_atributos'     , label:'control de inconsistencias de atributos', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
                {menuType:'table', name:'periodos_relpre_control_rangos_analisis'  , label:'control de inconsistencias de precios',onlyVisibleFor:[programador,analista,coordinador] },
                {menuType:'table', name:'periodos_relpre_control_rangos_recepcion' , label:'control de inconsistencias de precios Rec', onlyVisibleFor:[programador,recepcionista,supervisor,jefeCampo]},
                {menuType:'table', name:'periodos_control_normalizables_sindato' , label:'control de normalizables sin dato', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
                {menuType:'table', name:'periodos_control_anulados_recep' , label:'control de precios anulados en recepción', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor]},
                {menuType:'table', name:'periodos_control_ingresados_calculo'    , label:'control de precios ingresados que no entran al cálculo', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_sinvariacion'            , label:'control de precios sin variacion', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_tipoprecio'            , label:'control de tipos de precios', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_sinprecio'             , label:'control de tipo de precio sin existencia', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_relpre_1_sn'                   , label:'control de tipo de precio sin existencia/no vende', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'relmon'                        , label:'cotización moneda extranjera', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_desvios'              , label:'desvíos de los productos publicados', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_precios_porcentaje_positivos_y_anulados', label:'porcentajes de potenciales y positivos por formulario', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_precios_maximos_vw'            , label:'precios máximos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_precios_minimos_vw'            , label:'precios mínimos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'proddivestimac'                , label:'umbrales para estimaciones', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_variaciones_maximas_vw'        , label:'variaciones máximas', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_variaciones_minimas_vw'        , label:'variaciones mínimas', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'calculos_caldiv_vw'                     , label:'vista de caldiv', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'filtravarios_caldiv', name:'caldiv_vw_varios', label:'vista de caldiv varios', onlyVisibleFor:[programador]},
                {menuType:'table', name:'calculos_calgru_vw'                     , label:'vista de calgru', onlyVisibleFor:[programador,coordinador,analista]},
                //{menuType:'table', name:'periodos_control_observaciones'         , label:'vista de control de observaciones', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_comentariosrelvis'     , label:'vista de control de comentarios por formulario', onlyVisibleFor:[programador,coordinador,jefeCampo,analista]},
                {menuType:'table', name:'periodos_control_comentariosrelpre'     , label:'vista de control de comentarios por producto', onlyVisibleFor:[programador,coordinador,jefeCampo,analista]},
            ], onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
            {menuType:'menu', name:'informantes', menuContent:[
                {menuType:'table', name:'infreempdir'                           , label:'administración de reemplazos'             },
                {menuType:'table', name:'periodos_control_hojas_ruta'           , label:'control de hoja de ruta', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_relinf'                       , label:'comentarios de la hoja de ruta', onlyVisibleFor:[programador,coordinador,jefeCampo,analista]},
                {menuType:'table', name:'periodos_hdrexportar'                  , label:'exportar hoja de ruta', onlyVisibleFor:[programador,coordinador,jefeCampo,analista]},
                {menuType:'table', name:'periodos_hdrexportarteorica'           , label:'exportar hoja de ruta teórica', onlyVisibleFor:[programador,coordinador,jefeCampo,analista]},
                {menuType:'table', name:'periodos_hdrexportarcierretemporal'    , label:'exportar hoja de ruta cierre temporal', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,recepGabinete]},
                {menuType:'table', name:'periodos_hdrexportarefectivossinprecio', label:'exportar hoja de ruta efectivos sin precio', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,supervisor,recepGabinete]},
                {menuType:'table', name:'periodos_reemplazosexportar'           , label:'exportar titulares-reemplazos de hoja de ruta', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesactivos'           , label:'informantes activos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesaltasbajas'        , label:'informantes altas y bajas', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesformulario'        , label:'informantes por formulario', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesrazon'             , label:'informantes por razón', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesrubro'             , label:'informantes por rubro', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'informantes'                  , onlyVisibleFor:[programador,coordinador,analista,recepcionista,supervisor]},
                {menuType:'table', name:'conjuntomuestral'             , label:'conjuntos muestrales', onlyVisibleFor:[programador,coordinador,analista,recepcionista,supervisor]},
            ], onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
            {menuType:'menu', name:'ingreso', menuContent:[
                {menuType:'table', name:'periodos_ingreso', selectedByDefault:true},
            ]},
            {menuType:'menu', name:'resultados', menuContent:[
                {menuType:'table', name:'cuagru', label: 'grupos por cuadro'},
                {menuType:'mostrar_cuadros', name:'cuadros', label:'cuadros', onlyVisibleFor:[programador]},
                //{menuType:'table', name:'cuadros', label: 'cuadros'},
                {menuType:'menu', name:'frecuencia de cambio', name:'frecuencia de cambio', menuContent:[
                    {menuType:'table', name:'periodos_freccambio_nivel0', label:'nivel 0'},
                    {menuType:'table', name:'periodos_freccambio_nivel1', label:'nivel 1'},
                    {menuType:'table', name:'periodos_freccambio_nivel3', label:'nivel 3'},
                    {menuType:'table', name:'periodos_freccambio_resto', label:'resto IPCBA general'},
                    {menuType:'table', name:'periodos_freccambio_restorest', label:'resto IPCBA restricto'},
                ]},
                //{menuType:'proc', name:'', label: 'Resultados (permite elegir columnas)'},
            ], onlyVisibleFor:[programador,coordinador,analista]},
            {menuType:'menu', name:'salida_campo', label:'salida a campo', menuContent:[
                {menuType:'table', name:'relenc', label:'titulares de panel-tarea', selectedByDefault:true},
            ], onlyVisibleFor:[programador,coordinador,jefeCampo]},
            {menuType:'menu', name:'supervisiones', menuContent:[
                {menuType:'table', name:'periodos_hojaderutasupervisor'  , label:'hoja de ruta del supervisor', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                {menuType:'table', name:'periodos_reltar', label:'observaciones de paneles-tareas', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                {menuType:'seleccion_supervision', name:'seleccion', label:'selección', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                {menuType:'table', name:'pantar', label:'tamaño de supervisiones', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                {menuType:'table', name:'periodos_reltar', onlyVisibleFor:[programador, analista, recepcionista]},
            ]},
            {menuType:'menu', name:'vista_tablas', label:'vista tablas', menuContent:[
                {menuType:'table', name:'periodos_matrizresultados', label:'matrizresultados', onlyVisibleFor:[programador]},
                {menuType:'table', name:'calculos_canasta_producto', label:'canasta_producto', onlyVisibleFor:[programador]},
                {menuType:'table', name:'formularios'                                        , onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'gru_grupos'                                         , onlyVisibleFor:[programador]},
                {menuType:'table', name:'hogares'                                            , onlyVisibleFor:[programador]},
                {menuType:'table', name:'hogparagr'                                          , onlyVisibleFor:[programador]},
                {menuType:'table', name:'parhog'                                             , onlyVisibleFor:[programador]},
                {menuType:'table', name:'parhoggru'                                          , onlyVisibleFor:[programador]},
                {menuType:'table', name:'prodagr'                                            , onlyVisibleFor:[programador]},
                {menuType:'table', name:'razones'                                            , onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'relsup'                                             , onlyVisibleFor:[programador]},
                {menuType:'table', name:'infreemp'                                           , onlyVisibleFor:[programador]},
            ], onlyVisibleFor:[programador,coordinador,analista]},
            {menuType:'menu', name:'migracion', label:'migracion', menuContent:[
                {menuType:'table', name:'agrupaciones'                                       },
                {menuType:'table', name:'atributos'                                          },
                {menuType:'table', name:'calculos_def'                                       },
                {menuType:'table', name:'conjuntomuestral'                                   },
                {menuType:'table', name:'divisiones'                                         },
                {menuType:'table', name:'especificaciones'                                   },
                {menuType:'table', name:'forinf'                                             },
                {menuType:'table', name:'formularios'                                        },
                {menuType:'table', name:'forprod'                                            },
                {menuType:'table', name:'grupos'                                             },
                {menuType:'table', name:'informantes'                                        },
                {menuType:'table', name:'magnitudes'                                         },
                {menuType:'table', name:'monedas'                                            },
                {menuType:'table', name:'muestras'                                           },
                {menuType:'table', name:'pantar'                                             },
                {menuType:'table', name:'parametros'                                         },
                {menuType:'table', name:'periodos'                                           },
                {menuType:'table', name:'personal'                                           },
                {menuType:'table', name:'prodatr'                                            },
                {menuType:'table', name:'proddiv'                                            },
                {menuType:'table', name:'productos'                                          },
                {menuType:'table', name:'razones'                                            },
                {menuType:'table', name:'migra_relatr', label:'relatr'                       },
                {menuType:'table', name:'relpan'                                             },
                {menuType:'table', name:'migra_relpre', label:'relpre'                       },
                {menuType:'table', name:'reltar'                                             },
                {menuType:'table', name:'relvis'                                             },
                {menuType:'table', name:'rubfor'                                             },
                {menuType:'table', name:'rubros'                                             },
                {menuType:'table', name:'tareas'                                             },
                {menuType:'table', name:'tipoinf'                                            },
                {menuType:'table', name:'tipopre'                                            },
                {menuType:'table', name:'unidades'                                           },
                {menuType:'table', name:'valvalatr'                                          },
            ], onlyVisibleFor:[programador,migracion]},
        ]}
    }
    clientIncludes(req, hideBEPlusInclusions) {
        var be = this;
        return super.clientIncludes(req, hideBEPlusInclusions).concat([
            { type: 'js', src: 'client/hoja-de-ruta.js' },
            { type: 'js', src: 'client/imp-formularios.js' },
            { type: 'css', file: 'hoja-de-ruta.css' },
            { type: 'css', file: 'imp-formularios.css' },
            { type: 'css', file: '../../css/hoja-de-ruta.css' },
            { type: 'css', file: '../../css/imp-formularios.css' },
        ]);
    }
    getVisibleMenu(menu, context){
        var be=this;
        var currentUserRole = context.user[be.config.login.rolFieldName];
        var processItem = function processItem(item, index, menu){
            var itemExists = true;
            if(item.onlyVisibleFor){
                var visibilityConfigResult = item.onlyVisibleFor.filter(function findByRole(visibilityConfig) { 
                    return visibilityConfig.role == currentUserRole;
                });
                if(visibilityConfigResult.length === 0){
                    menu.splice(index, 1);
                    itemExists = false;
                }
            }
            if(itemExists && item.menuType == 'menu'){
                for(var i = item.menuContent.length -1; i >= 0 ; i--){
                    processItem(item.menuContent[i], i, item.menuContent);
                };
            }
        };
        for(var index = menu.menu.length -1; index >= 0 ; index--){
            processItem(menu.menu[index], index, menu.menu);
        };
        return menu;
    }
    getTables(){
        return super.getTables().concat([
            'pantar',
            'bienvenida',
            'agrupaciones',
            'conjuntomuestral',
            'calculos_def',
            'calculos',
            'calculos_canasta_producto',
            'calculos_novprod',
            'calculos_caldiv_vw',
            'calculos_calgru_vw',
            'calculos_novobs',
            'magnitudes',
            'unidades',
            'especificaciones',
            'prodespecificacioncompleta',
            'prodcontrolrangos',
            'prodagr',
            'tipoinf',
			'forinf',
            'formularios',
            'productos',
            'novobs',
            'novpre',
            'novdelobs',
            'novdelvis',
            'cierre_periodos',
            'vista_control_diccionario',
            'ipcba_usuarios',
            'grupos',
            'grupos_resp',
            'gru_grupos',
            'forprod',
            'atributos',
            'prodatr',
            'prodatrval',
            'divisiones',
            'hogares',
            'proddiv',
            'conjuntomuestral',
            'novprod',
            'muestras',
            'rubros',
            'informantes',
            'personal',
            'razones',
            'razones_encuestador',
            'periodos',
            'periodos_novpre',
            'periodos_ingreso',
            'periodos_control_productos_para_cierre',
            'periodos_control_grupos_para_cierre',
            'periodos_controlvigencias',
            'periodos_control_atributos',
            'periodos_control_ajustes',
            //'periodos_relpre_control_rangos',
            'periodos_relpre_control_rangos_analisis',
            'periodos_relpre_control_rangos_recepcion',
            //'paneles_relpre_control_rangos',
            'paneles_relpre_control_rangos_analisis',
            'paneles_relpre_control_rangos_recepcion',
            'periodos_control_normalizables_sindato',
            'periodos_control_anulados_recep',
            'periodos_control_sinvariacion',
            'periodos_control_ingresados_calculo',
            'periodos_control_tipoprecio',
            'periodos_control_sinprecio',
            'periodos_precios_minimos_vw',
            'periodos_precios_maximos_vw',
            'periodos_variaciones_minimas_vw',
            'periodos_variaciones_maximas_vw',
            'periodos_control_observaciones',
            'periodos_informantesrubro',
            'periodos_informantesrazon',
            'periodos_informantesformulario',
            'periodos_informantesactivos',
            'periodos_informantesaltasbajas',
            'periodos_reemplazosexportar',
            'periodos_hdrexportarefectivossinprecio',
            'periodos_hdrexportarcierretemporal',
            'periodos_hdrexportar',
            'periodos_hdrexportarteorica',
            'periodos_control_hojas_ruta',
            'periodos_hojaderutasupervisor',
            'periodos_desvios',
            'periodos_relpre_1_sn',
            'periodos_control_comentariosrelpre',
            'periodos_control_comentariosrelvis',
            'periodos_control_generacion_formularios',
            'periodos_precios_porcentaje_positivos_y_anulados',
            'periodos_relinf',
            'periodos_reltar',
            'periodos_calprodresp',
            'paneles_relinf',
            'relpantar_relinf',
            'tareas',
            'reltar',
            'reltar_candidatas',
            'relinf',
            'calprodresp',
            'cuadros',
            'cuagru',
            'precios_minimos_vw',
            'precios_maximos_vw',
            'monedas',
            'relenc',
            'relmon',
            'relpan',
            'relpantar',
            'relvis',
			'parametros',
            'mobile_hoja_de_ruta',
            'matriz_de_un_producto',
            'mobile_visita',
            'mobile_precios',
            'mobile_atributos',
            'tipopre',
            'tipopre_encuestador',
            'relpre',
            'migra_relpre',
            'migra_relatr',
            //'relpre_control_rangos',
			'relpre_control_rangos_analisis',
			'relpre_control_rangos_recepcion',
			'relpre_control_rangos_atrnorm',
            'valvalatr',
            'relatr',
            'relsup',
			'rubfor',
            'relsup_a_elegir',
            'hojaderutasupervisor',
            'hdrexportarefectivossinprecio',
            'calgru',
            'calgru_vw',
            'caldiv_vw',
            'caldiv',
            'proddivestimac',
            'controlvigencias',
            'canasta_producto',
            'control_atributos',
            'control_ajustes',
            'control_normalizables_sindato',
            'control_observaciones',
            'control_ingresados_calculo',
            'control_tipoprecio',
            'control_sinprecio',
            'control_sinvariacion',
            'control_rangos',
            'control_hojas_ruta',
            'control_grupos_para_cierre',
            'control_anulados_recep',
            'control_generacion_formularios',
            'vista_control_diccionario',
            'periodos_vista_control_diccionario',
            'control_productos_para_cierre',
            'hdrexportar',
            'hdrexportarteorica',
            'reemplazosexportar',
            'hdrexportarcierretemporal',
            'informantesaltasbajas',
            'informantesformulario',
            'informantesrazon',
            'informantesrubro',
            'informantesactivos',
            'variaciones_minimas_vw',
            'variaciones_maximas_vw',
            'parhog',
            'parhoggru',
            'hogparagr',
            'relatr_tipico',
            'periodos_freccambio_nivel0',
            'periodos_freccambio_nivel1',
            'periodos_freccambio_nivel3',
            'periodos_freccambio_resto',
            'periodos_freccambio_restorest',
            'periodos_matrizresultados',
            'freccambio_nivel0',
            'freccambio_nivel1',
            'freccambio_nivel3',
            'freccambio_resto',
            'freccambio_restorest',
            'relpre_1_sn',
            'desvios',
            'control_comentariosrelpre',
            'control_comentariosrelvis',
            'precios_porcentaje_positivos_y_anulados',
            'matrizresultados',
            'app_agrupaciones',
            'app_calculo_grupos',
            'app_calculo_productos',
            'app_grupos',
            'app_grupos_producto',
            'app_periodos',
            'app_productos',
            'instalaciones',
            'infreemp',
            'infreempdir',
            'misma_direccion'
        ]);
    }


}

new AppIpcba().start();