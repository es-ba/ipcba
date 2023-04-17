"use strict";

var Path = require('path');
var backendPlus = require("backend-plus");
var MiniTools = require('mini-tools');
var uptime = new Date().toString();
var fs = require("fs").promises;
var cookieParser = require('cookie-parser')

var {changing, datetime} = require('best-globals');
const { json } = require('backend-plus');

const APP_DM_VERSION="#23-03-09";
class AppIpcba extends backendPlus.AppBackend{
    isAdmin(reqOrContext){
        var be = this;
        return reqOrContext && (reqOrContext.forDump || reqOrContext.user && reqOrContext.user[be.config.login.rolFieldName] == 'programador');
    }
    async postConfig(){
        await super.postConfig();
        this.fieldDomain.grupo={sortMethod:'codigo_ipc'};
        this.fieldDomain.grupopadre={sortMethod:'codigo_ipc', title:'grupo padre'};
        var be=this;
        await be.inTransaction(null, async function(client) {
        var result = await client.query(`
        SELECT * FROM calculos_def where principal
        `).fetchOneRowIfExists();
        if (result.rowCount === 0) {
            var ultimoCalculo = 0;
            console.log("Campo calculo no definido en la tabla calculos_def se inicializa con 0");
        } else {
            var ultimoCalculo = result.row.calculo;
        } 
        var result2 = await client.query(`
        SELECT max(periodo) actperiodo FROM calculos where fechacalculo is not null
        `).fetchOneRowIfExists();
        if (!result2.row.actperiodo) {
            var actualperiodo = 'a2012m07';
            console.log("No hay calculos ejecutados, se inicializa con a2012m07");
        } else {
            var actualperiodo = result2.row.actperiodo;
        } 
        be.internalData={
            filterUltimoPeriodo : 'a2012m07',
            filterActualPeriodo : actualperiodo,
            filterUltimoCalculo : ultimoCalculo,
            filterAgrupacion : 'Z',
            filterExcluirCluster : 3
            }
        });
    }
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
            session-store: memory-saved
            keep-alive: true
            bitacoraTableName: bp_bitacora
          db:
            motor: postgresql
            host: localhost
            database: cvp_db
            schema: cvp
            user: cvpowner
            search_path: [cvp, ipcba, precios_app]
            fkOnUpdate: false
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
              maxAge-5-sec: 5000    
              maxAge: 864000000
              maxAge-10-day: 864000000
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
          install:
            dump:
              skip-content: true
              scripts:
                prepare: 
                - cvp-db-types.sql
                - cvp-db-domains.sql
                - schema-comun.sql
                - schema-ipcba.sql
                - schema-his.sql
                - cvp-db-roles.sql
                post-adapt:
                - fun-cal_canasta_borrar.sql
                - fun-cal_canasta_valorizar.sql
                - fun-cal_control.sql
                - fun-cal_copiar_calprodagr.sql
                - fun-cal_copiar.sql
                - fun-cal_invalidar_aux.sql
                - fun-cal_invalidar.sql
                - fun-cal_mensajes.sql
                - fun-cal_perbase_prop.sql
                - fun-calbase_periodos.sql
                - fun-calcularprerep.sql
                - fun-calcularunperiodo.sql
                - fun-calcularvarios.sql
                - fun-calculo_borrar.sql
                - fun-calculo_controlarabierto.sql 
                - fun-caldiv_bajar.sql
                - fun-caldiv_contar.sql
                - fun-caldiv_impext.sql
                - fun-caldiv_promfinal.sql
                - fun-caldiv_prompriimp.sql
                - fun-caldiv_promsegimp.sql
                - fun-caldiv_rellenar.sql
                - fun-caldiv_subir.sql
                - fun-calgru_canasta_variacion.sql
                - fun-calgru_indexar.sql
                - fun-calgru_info.sql
                - fun-calgru_insertar.sql
                - fun-calgru_segimp.sql
                - fun-calgru_segimpunpaso.sql
                - fun-calgru_valorizar.sql
                - fun-calhog_subtotalizar.sql
                - fun-calhog_subtotalizar_unhog.sql
                - fun-calhog_valorizar.sql
                - fun-calhog_valorizar_unhog.sql
                - fun-calobs_altasybajas.sql
                - fun-calobs_extraer.sql
                - fun-calobs_impperbase.sql
                - fun-calobs_priimp.sql
                - fun-calobs_promedio.sql
                - fun-calobs_rellenar.sql
                - fun-calobs_segimp.sql
                - fun-calobs_segimp_perbase.sql
                - fun-calprod_indexar.sql
                - fun-calprod_valorizar.sql
                - fun-copiarcalculo.sql
                - fun-crear_vista_calobs_periodos.sql
                - fun-controlar_estado_carga.sql
                - fun-diferenciaentreperiodosparar.sql
                - fun-moverperiodos.sql
                - fun-periodo_igual_mes_anno_anterior.sql
                - fun-obtenerunidadnormalizada.sql
                - fun-estadoinformante.sql
                - fun-devolver_mes_anio.sql
                - fun-formularioshdr.sql
                - fun-matrizresultados_atributos_fun.sql
                - fun-periodo_minimas_variaciones.sql
                - fun-periodo_maximas_variaciones.sql
                - fun-periodo_minimos_precios.sql
                - fun-periodo_maximos_precios.sql
                - fun-periodobase.sql
                - fun-testpanelesgenerados.sql
                - fun-res_cuadro_i.sql
                - fun-res_cuadro_ii.sql
                - fun-res_cuadro_iivv.sql
                - fun-res_cuadro_ivebs.sql
                - fun-res_cuadro_matriz_canasta.sql
                - fun-res_cuadro_matriz_canasta_var.sql
                - fun-res_cuadro_matriz_hogar.sql
                - fun-res_cuadro_matriz_hogar_per.sql
                - fun-res_cuadro_matriz_hogar_var.sql
                - fun-res_cuadro_matriz_i.sql
                - fun-res_cuadro_matriz_ingreso.sql
                - fun-res_cuadro_matriz_linea.sql
                - fun-res_cuadro_matriz_linea_var.sql
                - fun-res_cuadro_matriz_up.sql
                - fun-res_cuadro_piivvi.sql
                - fun-res_cuadro_pp.sql
                - fun-res_cuadro_up.sql
                - fun-res_cuadro_vc.sql
                - trg-actualizar_estado_informante_trg.sql
                - trg-actualizar_periodo_panelrotativo_trg.sql
                - trg-actualizar_tarea_encuestador_trg.sql
                - trg-adm_blanqueo_precios_trg.sql
                - trg-agrupaciones_fijas_trg.sql
                - trg-altamanualdeinformantes_trg.sql
                - trg-blanquear_precios_trg.sql
                - trg-borrar_precios_trg.sql
                - trg-borrar_visita_trg.sql
                - trg-calcular_precionormaliz_cambio_relatr_trg.sql
                - trg-calcular_precionormaliz_relpre_trg.sql
                - trg-cambio_panel_tarea_trg.sql
                - trg-cambios_razon_trg.sql
                - trg-controlar_actualizacion_datos_trg.sql
                - trg-controlar_existencia_visita_1_trg.sql
                - trg-controlar_revision_trg.sql
                - trg-correr_normalizacion_moneda_trg.sql
                - trg-desp_actualizar_ultima_visita_trg.sql
                - trg-generar_direccion_informante_trg.sql
                - trg-generar_visitas_reemplazo_trg.sql
                - trg-insertat_atributos_trg.sql
                - trg-modi_trg.sql
                - trg-novobs_validacion_trg.sql
                - trg-permitir_actualizar_valor_trg.sql
                - trg-prodatr_validamod_valornormal_trg.sql
                - trg-proddiv_ins_trg.sql
                - trg-razon_cierre_definitivo_trg.sql
                - trg-razon_cierre_temporal_trg.sql
                - trg-relatr_valor_valida_moneda_trg.sql
                - trg-relatr_valor_valida_numerico_trg.sql
                - trg-relpre_validacion_trg.sql
                - trg-relvis_tarea_trg.sql
                - trg-restaurar_atributos_trg.sql
                - trg-revisar_cambio_trg.sql
                - trg-setar_renglon_de_cal_mensajes_trg.sql
                - trg-validar_abrir_cerrar_calculo_trg.sql
                - trg-validar_fechas_visita_trg.sql
                - trg-validar_habilitado_trg.sql
                - trg-validar_imputacon_trg.sql
                - trg-validar_ingresando_trg.sql
                - trg-validar_personal_trg.sql
                - trg-validar_recepcion_trg.sql
                - trg-validar_transmitir_canasta_trg.sql
                - trg-verificar_act_promedio.sql
                - trg-verificar_calcularprerep.sql
                - trg-verificar_cargado_dm.sql
                - trg-verificar_generar_externos.sql
                - trg-verificar_generar_formulario.sql
                - trg-verificar_generar_panel.sql
                - trg-verifiacr_generar_periodo.sql
                - trg-verificar_ingresando.sql
                - trg-verificar_insersion_ultima_visita_trg.sql
                - trg-verificar_lanzamiento_calculo.sql
                - trg-verificar_sincronizacion.sql
                - trg-verificar_valor_pesos_trg.sql
                - trg-hisc_parametros_trg.sql
                - vw-bienvenida.sql
                - vw-gru_grupos.sql
                - vw-caldiv_vw.sql
                - vw-informantes_inactivos.sql
                - vw-informantes_estado.sql
                - vw-caldivsincambio.sql
                - vw-calgru_promedios.sql
                - vw-calgru_vw.sql
                - vw-calobs_periodos.sql
                - vw-calobs_vw.sql
                - vw-matrizperiodos6.sql
                - vw-canasta_alimentaria.sql
                - vw-canasta_alimentaria_var.sql
                - vw-canasta_consumo.sql
                - vw-canasta_consumo_var.sql
                - vw-canasta_producto.sql
                - vw-control_ajustes.sql
                - vw-control_anulados_recep.sql
                - vw-control_atributos.sql
                - vw-control_calculoresultados.sql
                - vw-control_calobs.sql
                - vw-control_generacion_formularios.sql
                - vw-gru_prod.sql
                - vw-control_grupos_para_cierre.sql
                - vw-control_hojas_ruta.sql
                - vw-control_ingreso_atributos.sql
                - vw-control_ingreso_precios.sql
                - vw-control_normalizables_sindato.sql
                - vw-control_precios.sql
                - vw-control_precios2.sql
                - vw-control_productos_para_cierre.sql
                - vw-relatr_1.sql
                - vw-relpre_1.sql
                - vw-panel_promrotativo.sql
                - vw-control_rangos.sql
                - vw-panel_promrotativo_mod.sql
                - vw-control_rangos_mod.sql
                - vw-control_relev_telef.sql
                - vw-control_sinprecio.sql
                - vw-control_sinvariacion.sql
                - vw-perfiltro.sql
                - vw-control_tipoprecio.sql
                - vw-controlvigencias.sql
                - vw-desvios.sql
                - vw-estadoinformantes.sql
                - vw-forobs.sql
                - vw-foresp.sql
                - vw-forobsinf.sql
                - vw-freccambio_nivel0.sql
                - vw-freccambio_nivel1.sql
                - vw-freccambio_nivel3.sql
                - vw-freccambio_resto.sql
                - vw-freccambio_restorest.sql
                - vw-hdrexportar.sql
                - vw-hdrexportarcierretemporal.sql
                - vw-hdrexportarefectivossinprecio.sql
                - vw-hdrexportarteorica.sql
                - vw-hojaderuta.sql
                - vw-hojaderutasupervisor.sql
                - vw-informantesaltasbajas.sql
                - vw-informantesformulario.sql
                - vw-informantesrazon.sql
                - vw-informantesrubro.sql
                - vw-control_ingresados_calculo.sql
                - vw-matrizresultados.sql
                - vw-matrizresultadossinvariacion.sql
                - vw-parahojasderuta.sql
                - vw-paraimpresionformulariosatributos.sql
                - vw-paraimpresionformulariosenblanco.sql
                - vw-paraimpresionformulariosprecios.sql
                - vw-paralistadodecontroldecm.sql
                - vw-paralistadodecontroldeinformantes.sql
                - vw-precios_maximos_vw.sql
                - vw-precios_minimos_vw.sql
                - vw-precios_porcentaje_positivos_y_anulados.sql
                - vw-preciosmedios_albs.sql
                - vw-preciosmedios_albs_var.sql
                - vw-prod_for_rub.sql
                - vw-promedios_maximos_minimos.sql
                - vw-reemplazosexportar.sql
                - vw-revisor_parametros.sql
                - vw-revisor.sql
                - vw-variaciones_maximas_vw.sql
                - vw-variaciones_minimas_vw.sql
          logo: 
            path: client/img
        `);
    }
    /* falta agregar:
    - vw-transf_data.sql
    - vw-transf_data_orig.sql
    - vw-valorizacion_canasta.sql
    - vw-valorizacion_canasta_cuadros.sql
    */
    getManifestPaths(parameters){
        const centralPart=`${parameters.periodo}p${parameters.panel}t${parameters.tarea}`;
        return {
            manifestPath: `carga-dm/${centralPart}_manifest.manifest`,
            estructuraPath: `carga-dm/${centralPart}_estructura.js`,
            hdrPath: `carga-dm/${centralPart}_hdr.json`,
        }        
    }
    addSchrödingerServices(mainApp, baseUrl){
        var be=this;
        mainApp.get(baseUrl+'/rescate',async function(req,res,_next){
            // @ts-ignore sé que voy a recibir useragent por los middlewares de Backend-plus
            var {useragent} = req;
            var htmlMain=be.mainPage({useragent}, false, {skipMenu:true}).toHtmlDoc();
            MiniTools.serveText(htmlMain,'html')(req,res);
        });
        mainApp.get(baseUrl+'/demo',async function(req,res,_next){
            // @ts-ignore sé que voy a recibir useragent por los middlewares de Backend-plus
            var {useragent} = req;
            var htmlMain=be.mainPage({useragent}, false, {skipMenu:true}).toHtmlDoc();
            MiniTools.serveText(htmlMain,'html')(req,res);
        });
        mainApp.get(baseUrl+'/dm',async function(req,res,_next){
            var {user} = req;
            if(!user){
                res.redirect(401, baseUrl+'/login#w=path&path=/dm')
            }
            var webManifestPath = 'carga-dm/web-manifest.webmanifest';
            var {useragent, user} = req;
            var parameters = req.query;
            var extraFiles = [
                // { type: 'js', src:'dm-main.js' },
            ];
            var htmlMain=be.mainPage({useragent, user}, false, {skipMenu:true, icon:"img/icon-dm.png", extraFiles, webManifestPath}).toHtmlDoc();
            MiniTools.serveText(htmlMain,'html')(req,res);
        });
        mainApp.use(cookieParser());
        var createServiceWorker = async function(){
            var sw = await fs.readFile('node_modules/service-worker-admin/dist/service-worker-wo-manifest.js', 'utf8');
            var manifest = be.createResourcesForCacheJson({});
            var swManifest = sw
                .replace("'/*version*/'", JSON.stringify(manifest.version))
                .replace("'/*appName*/'", JSON.stringify(manifest.appName))
                .replace(/\[\s*\/\*urlsToCache\*\/\s*\]/, JSON.stringify(manifest.cache))
                .replace(/\[\s*\/\*fallbacks\*\/\s*\]/, JSON.stringify(manifest.fallback || []));
                //.replace("/#CACHE$/", "/(a\\d+m\\d+p\\d+t\\d+_estructura.js)|(a\\d+m\\d+p\\d+t\\d+_hdr.json)/");
            return swManifest
        }
        mainApp.get(baseUrl+`/sw-manifest.js`, async function(req, res, next){
            try{
                MiniTools.serveText(await createServiceWorker(),'application/javascript')(req,res);
            }catch(err){
                MiniTools.serveErr(req,res,next)(err);
            }
        });
        mainApp.get(baseUrl+`/carga-dm/web-manifest.webmanifest`, async function(req, res, next){
            console.log("be", be);
            let pwaVersion = be.config.server.pwaVersion || '';
            var entorno = baseUrl.includes('pr')?'PR':'';
            try{
                const content = {
                  "name": `IPCBA Progressive Web App`,
                  "short_name": `IPCBA ${pwaVersion} PWA ${entorno}`,
                  "description": "Progressive Web App for IPCBA.",
                  "icons": [
                    {
                      "src": "../img/logo-dm-32.png",
                      "sizes": "32x32",
                      "type": "image/png"
                    },
                    {
                      "src": "../img/logo-dm-48.png",
                      "sizes": "48x48",
                      "type": "image/png"
                    },
                    {
                      "src": "../img/logo-dm-64.png",
                      "sizes": "64x64",
                      "type": "image/png"
                    },
                    {
                      "src": "../img/logo-dm-72.png",
                      "sizes": "72x72",
                      "type": "image/png"
                    },
                    {
                      "src": "../img/logo-dm-192.png",
                      "sizes": "192x192",
                      "type": "image/png"
                    },
                    {
                      "src": "../img/logo-dm-512.png",
                      "sizes": "512x512",
                      "type": "image/png"
                    }
                  ],
                  "start_url": "../dm",
                  "display": "standalone",
                  "theme_color": "#3F51B5",
                  "background_color": "#FED214"
                }
                MiniTools.serveText(JSON.stringify(content), 'application/json')(req,res);
            }catch(err){
                console.log(err);
                MiniTools.serveErr(req, res, next)(err);
            }
        });
        super.addSchrödingerServices(mainApp, baseUrl);
    }
    addLoggedServices(opts){
        var be=this;
        super.addLoggedServices();
        [
            {sufix:`manifest.manifest`     , fieldName:'archivo_manifiesto', mimeType:'text/cache-manifest'},
            {sufix:`estructura.js`         , fieldName:'archivo_estructura', mimeType:'application/javascript'},
            {sufix:`hdr.json`              , fieldName:'archivo_hdr'       , mimeType:'application/json'},
            {sufix:`resources_cache.json`  , fieldName:'archivo_cache'     , mimeType:'application/json'},

        ].forEach(function(def){
            be.app.get(`/carga-dm/:periodo(a\\d\\d\\d\\dm\\d\\d)p:panel(\\d{1,2})t:tarea(\\d{1,4})_${def.sufix}`, async function(req, res, next){
                await be.inDbClient(req, async function(client){
                    try{
                        const {value} = await client.query(`
                            SELECT ${be.db.quoteIdent(def.fieldName)}
                                FROM reltar
                                WHERE periodo = $1 AND panel = $2 AND tarea = $3
                            `, [req.params.periodo, req.params.panel, req.params.tarea]
                        ).fetchUniqueValue();
                        MiniTools.serveText(value, def.mimeType)(req,res);
                    }catch(err){
                        console.log(err);
                        MiniTools.serveErr(req, res, next)(err);
                    }
                });
            })
        });
        be.app.get(`/carga-dm/dm-manifest.manifest`, async function(req, res, next){
            try{
                const content = be.getManifestContent({});
                MiniTools.serveText(content, 'text/cache-manifest')(req,res);
            }catch(err){
                console.log(err);
                MiniTools.serveErr(req, res, next)(err);
            }
        });
        super.addLoggedServices(opts);
    }
    getProcedures(){
        var be = this;
        return super.getProcedures().then(function(procedures){
            return procedures.concat(
                require('./procedures-ipcba.js').map(be.procedureDefCompleter, be)
            ).map(function(procedureDef){
                if(procedureDef.action=='get_token'){
                    procedureDef.policy='web';
                }
                return procedureDef;
            });
        });
    }
    getManifestContent(parameters){
        var be = this;
        if(parameters.periodo){
            var {manifestPath, estructuraPath, hdrPath} = be.getManifestPaths(parameters);
        }
        const especifico=parameters.periodo?`
../${estructuraPath}
../${hdrPath}
../dm
`:'';
        const version=parameters.periodo?`${parameters.periodo}p${parameters.panel}t${parameters.tarea} ${datetime.now().toYmdHms()}`:uptime;
        return (
`CACHE MANIFEST
#${version}

CACHE:
#--------------------------- JS ------------------------------------
../lib/react.production.min.js
../lib/react-dom.production.min.js
../lib/material-ui.production.min.js
../lib/material-styles.production.min.js
../lib/clsx.min.js
../lib/redux.min.js
../lib/react-redux.min.js
../lib/index-prod.umd.js
../lib/memoize-one.js
../lib/require-bro.js
../lib/like-ar.js
../lib/best-globals.js
../lib/json4all.js
../lib/js-to-html.js
../lib/redux-typed-reducer.js
../adapt.js
../dm-tipos.js
../dm-funciones.js
../dm-react.js
../ejemplo-precios.js
../unlogged.js
../lib/js-yaml.js
../lib/xlsx.core.min.js
../lib/lazy-some.js
../lib/sql-tools.js
../dialog-promise/dialog-promise.js
../moment/min/moment.js
../pikaday/pikaday.js
../lib/polyfills-bro.js
../lib/big.js
../lib/type-store.js
../lib/typed-controls.js
../lib/ajax-best-promise.js
../my-ajax.js
../my-start.js
../lib/my-localdb.js
../lib/my-websqldb.js
../lib/my-localdb.js.map
../lib/my-websqldb.js.map
../lib/my-things.js
../lib/my-tables.js
../lib/my-inform-net-status.js
../lib/my-menu.js
../lib/my-skin.js
../lib/cliente-en-castellano.js
../client/client.js
../client/menu.js
../client/hoja-de-ruta.js
../client/hoja-de-ruta-react.js
${especifico}

#------------------------------ CSS ---------------------------------
../dialog-promise/dialog-promise.css
../pikaday/pikaday.css
../css/my-things.css
../css/my-tables.css
../css/my-menu.css
../css/menu.css
../css/offline-mode.css
../css/hoja-de-ruta.css
../default/css/my-things.css
../default/css/my-tables.css
../default/css/my-menu.css
../css/ejemplo-precios.css
../default/css/ejemplo-precios.css

#------------------------------ IMAGES ---------------------------------
../img/logo.png
../img/logo-dm.png
../img/main-loading.gif

FALLBACK:
../menu* ../dm

NETWORK:
*`
        );
    }
    async getResourcesForCacheJson(params){
        var be=this;
        return await be.inDbClient(null, async function(client){
            return JSON.parse((await client.query(`
                SELECT archivo_cache
                    FROM reltar
                    WHERE periodo = $1 AND panel = $2 AND tarea = $3
                `, [params.periodo, params.panel, params.tarea]
            ).fetchUniqueValue()).value);
        })
    }
    createResourcesForCacheJson(parameters){
        var be = this;
        var jsonResult = {};
        
        jsonResult.version = APP_DM_VERSION;
        jsonResult.appName = 'ipcba';
        if(parameters.periodo){
            var {estructuraPath, hdrPath} = be.getManifestPaths(parameters);
        }
        const especifico=[];
        jsonResult.cache=[
            "dm",
            "offline",
            "lib/react.production.min.js",
            "lib/react-dom.production.min.js",
            "lib/material-ui.production.min.js",
            "lib/material-styles.production.min.js",
            "lib/clsx.min.js",
            "lib/redux.min.js",
            "lib/react-redux.min.js",
            "lib/index-prod.umd.js",
            "lib/memoize-one.js",
            "lib/require-bro.js",
            "lib/like-ar.js",
            "lib/best-globals.js",
            "lib/json4all.js",
            "lib/js-to-html.js",
            "lib/redux-typed-reducer.js",
            "adapt.js",
            "dm-tipos.js",
            "dm-funciones.js",
            "dm-react.js",
            "ejemplo-precios.js",
            "unlogged.js",
            "lib/js-yaml.js",
            "lib/xlsx.core.min.js",
            "lib/lazy-some.js",
            "lib/sql-tools.js",
            "dialog-promise/dialog-promise.js",
            "moment/min/moment.js",
            "pikaday/pikaday.js",
            "lib/polyfills-bro.js",
            "lib/big.js",
            "lib/type-store.js",
            "lib/typed-controls.js",
            "lib/ajax-best-promise.js",
            "my-ajax.js",
            "my-start.js",
            "lib/my-localdb.js",
            "lib/my-websqldb.js",
            "lib/my-localdb.js.map",
            "lib/my-websqldb.js.map",
            "lib/my-things.js",
            "lib/my-tables.js",
            "lib/my-inform-net-status.js",
            "lib/my-menu.js",
            "lib/my-skin.js",
            "lib/cliente-en-castellano.js",
            "lib/service-worker-admin.js",
            //"client/imp-formularios.js",
            //"client/client.js",
            //"client/menu.js",
            //"client/hoja-de-ruta.js",
            //"client/hoja-de-ruta-react.js",
            //"dialog-promise/dialog-promise.css",
            //"pikaday/pikaday.css",
            //"css/my-things.css",
            //"css/my-tables.css",
            //"css/my-menu.css",
            //"css/menu.css",
            //"css/offline-mode.css",
            //"css/hoja-de-ruta.css",
            //"default/css/my-things.css",
            //"default/css/my-tables.css",
            //"default/css/my-menu.css",
            "css/ejemplo-precios.css",
            "css/bootstrap.min.css",
            "default/css/ejemplo-precios.css",
            //"img/logo.png",
            //"img/logo-dm.png",
            "img/main-loading.gif",
            "client-setup"
        ].concat(especifico);
        jsonResult.fallback=[
            {"path":"login", "fallback":"offline"},
            {"path":"logout", "fallback":"offline"},
            {"path":"not-logged-in#i=dm2,sincronizar_dm2", "fallback":"offline"},
            {"path":"not-logged-in#i=dm2,instalar_dm2", "fallback":"offline"},
            {"path":"login#i=dm2,sincronizar_dm2", "fallback":"offline"},
            {"path":"menu#i=dm2,sincronizar_dm2", "fallback":"offline"},
            {"path":"login#i=dm2,instalar_dm2", "fallback":"offline"},
            {"path":"menu#i=dm2,instalar_dm2", "fallback":"offline"}
        ];
        return jsonResult
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
        var encuestador = {role:'encuestador'};
        if(this.config.server.policy=='web'){
            var asignadores=[programador, analista, coordinador, jefeCampo, recepcionista, recepGabinete, supervisor, encuestador]
            return {menu:[
                //{menuType:'hoja_ruta', name:'hoja_de_ruta', label: 'hoja de ruta DM 1', showInOfflineMode: true, selectedByDefault: true},
                //{menuType:'menu', name:'dm', label:'D.M.', onlyVisibleFor:asignadores, menuContent:[
                //    {menuType:'preparar_instalacion', name:'instalar_dm', label: 'instalar', showInOfflineMode: false, onlyVisibleFor:asignadores},
                //    {menuType:'sincronizar', name:'sincronizar', showInOfflineMode: false},    
                //    {menuType:'vaciar', name:'vaciar_dm', label:'vaciar', showInOfflineMode: false},
                //]},
                {menuType:'menu', name:'dm2', label:'DM 2.0', menuContent:[
                    {menuType:'hoja_ruta_2', name:'hoja_de_ruta_2', label: 'hoja de ruta', showInOfflineMode: true },
                    {menuType:'preparar_instalacion2', name:'instalar_dm2', label: 'instalar', showInOfflineMode: false, onlyVisibleFor:asignadores},
                    {menuType:'sincronizar_dm2', name:'sincronizar_dm2', label:'sincronizar', showInOfflineMode: false, onlyVisibleFor:asignadores},
                    {menuType:'vaciar_dm2', name:'vaciar_dm2', label:'vaciar', showInOfflineMode: false, onlyVisibleFor:asignadores},
                ]},
                {menuType:'instalacion_actual', name:'instalacion_actual', label: 'instalación actual', showInOfflineMode: false, onlyVisibleFor:[programador]},
            ]};
        }

        var subMenuCalculos = [
            {menuType:'table'        , name:'calculos'          , label:'cálculo', onlyVisibleFor:[programador,coordinador,analista,migracion], selectedByDefault:true},
            {menuType:'table'        , name:'calculos_novprod'  , label:'administración de externos', onlyVisibleFor:[programador,coordinador,analista]},
            {menuType:'table'        , name:'proddivestimac'    , label:'umbrales para estimaciones', onlyVisibleFor:[programador,coordinador,analista]},
            {menuType:'copia_calculo', name:'copias'            , label:'copias', onlyVisibleFor:[programador,coordinador,analista]},
        ]
        if(this.config.server.esAppParaCambioDeBase){
            subMenuCalculos.push({menuType:'proc'         , name:'periodobase_correr', label:'periodobase', onlyVisibleFor:[programador,migracion,coordinador,analista]})
        }
        subMenuCalculos = subMenuCalculos.concat(
            [
                {menuType:'table'        , name:'calbase_div'       , label:'calbase_div' , onlyVisibleFor:[programador,migracion,coordinador,analista]},
                {menuType:'table'        , name:'calbase_prod'      , label:'calbase_prod', onlyVisibleFor:[programador,migracion,coordinador,analista]},
                {menuType:'table'        , name:'calbase_obs'       , label:'calbase_obs' , onlyVisibleFor:[programador,migracion,coordinador,analista]},
                {menuType:'table'        , name:'ejecucion_calculos', label:'cálculos ejecutados', onlyVisibleFor:[programador,coordinador,analista]},
            ]
        )
        var menuPrincipal = [
            {menuType:'table', name:'bienvenida', selectedByDefault:true},
            {menuType:'relevamiento', name:'relevamiento'/*, onlyVisibleFor:[programador]*/},
            {menuType:'demo_dm', name:'demo_dm', label: 'demo', showInOfflineMode: true, onlyVisibleFor:[programador]},
            {menuType:'menu', name:'dm', label:'D.M.', onlyVisibleFor:[programador, analista, coordinador, jefeCampo, recepcionista], policy:'web', menuContent:[
                {menuType:'table', name:'personal', showInOfflineMode: false},
                {menuType:'table', name:'instalaciones', showInOfflineMode: false},
            ], showInOfflineMode: true},
            {menuType:'menu', name:'administracion', label:'administración', menuContent:[
                {menuType:'table', name:'prodatrval', label:'atributos seleccionables', onlyVisibleFor:[programador,coordinador,analista,recepcionista,jefeCampo]},
                //{menuType:'table', name:'cierre_periodos', label:'cierre de períodos'},
                {menuType:'table', name:'parametros', label:'parametros', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'cuadros', label: 'textos de los cuadros', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'ipcba_usuarios', label: 'usuarios', onlyVisibleFor:[programador,coordinador,analista]},
            ], onlyVisibleFor:[programador,coordinador,analista,recepGabinete, recepcionista, jefeCampo]},
            {menuType:'menu', name:'salida_campo', label:'salida a campo', menuContent:[
                {menuType:'table', name:'relenc', label:'titulares de panel-tarea', selectedByDefault:true},
            ], onlyVisibleFor:[programador,coordinador,jefeCampo]},
            {menuType:'menu', name:'gabinete', menuContent:[
                {menuType:'menu', name:'ingreso', menuContent:[
                    {menuType:'table', name:'periodos_ingreso', selectedByDefault:true},
                    {menuType:'buscar_informante', name:'Informante', label:'Buscar Informante'},
                    {menuType:'cambiar_paneltarea', name:'paneltarea', label:'Cambiar Panel Tarea', onlyVisibleFor:[programador,coordinador,analista]},
                    {menuType:'table', name:'cambiopantar_lote', label:'Cambiar Panel Tarea por Lotes', onlyVisibleFor:[programador,coordinador,analista]},
                    {menuType:'table', name:'pantar', label:'panel tarea', onlyVisibleFor:[programador,coordinador,analista]},
                ]},
                {menuType:'menu', name:'recepcion', menuContent:[
                //{menuType:'table', name:'revision'   , label:'revisión'                    },
                //{menuType:'table', name:'infreempdir', label:'administración de reemplazos'},
                {menuType:'table', name:'periodos_precios_maximos_minimos', label:'precios maximos-mínimos'},
                ], onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista]},
                {menuType:'menu', name:'controles', menuContent:[
                    {menuType:'table', name:'periodos_relpre_control_rangos_recepcion', label:'inconsistencias de precios Rec', onlyVisibleFor:[programador,recepcionista,supervisor,coordinador,analista,jefeCampo]},
                    {menuType:'table', name:'periodos_control_anulados_recep'         , label:'anulados en recepción', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor]},
                    {menuType:'table', name:'periodos_hdrexportarefectivossinprecio'  , label:'efectivos sin precio', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,supervisor,recepGabinete]},
                    {menuType:'table', name:'periodos_control_normalizables_sindato'  , label:'normalizables sin dato', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
                    {menuType:'table', name:'periodos_precios_positivos'              , label:'precios positivos periodo referente', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista]},
                    {menuType:'table', name:'periodos_control_cambios'                , label:'cambios de atributos', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista]},
                    {menuType:'table', name:'periodos_control_atributos'              , label:'inconsistencias de atributos', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
                    {menuType:'table', name:'periodos_control_atr1_diccionario_atributos', label:'inconsistencia (atr1) de diccionario', onlyVisibleFor:[programador,coordinador,recepcionista,analista,jefeCampo]},
                    {menuType:'table', name:'periodos_control_atr2_diccionario_atributos', label:'inconsistencia (atr2) de diccionario', onlyVisibleFor:[programador,coordinador,recepcionista,analista,jefeCampo]},
                    {menuType:'table', name:'periodos_control_diccionario_atributos_val', label:'inconsistencia de diccionario (corrección)', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista]},
                    {menuType:'table', name:'periodos_control_generacion_formularios' , label:'completitud de visitas', onlyVisibleFor:[programador,coordinador,analista]},
                    {menuType:'table', name:'periodos_controlvigencias'               , label:'atributo vigencia', onlyVisibleFor:[programador,coordinador,analista,recepGabinete]},
                    {menuType:'table', name:'periodos_control_ingresados_calculo'     , label:'precios ingresados que no entran al cálculo', onlyVisibleFor:[programador,coordinador,analista]},                    
                    {menuType:'table', name:'periodos_control_sinvariacion'           , label:'precios sin variacion', onlyVisibleFor:[programador,recepcionista,jefeCampo]},
                    {menuType:'table', name:'periodos_control_verificar_precio'       , label:'precios para verificar', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista]},
                    {menuType:'table', name:'periodos_control_comentariosrelvis'      , label:'comentarios por formulario', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista]},
                    {menuType:'table', name:'periodos_control_comentariosrelpre'      , label:'comentarios por producto', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista]},
                ]},
                {menuType:'table', name:'periodos_novpre_recep', label:'anulación de precios (recep)', onlyVisibleFor:[programador,jefeCampo,recepcionista,recepGabinete]},
                {menuType:'menu', name:'supervisiones', menuContent:[
                    {menuType:'table', name:'periodos_hojaderutasupervisor'  , label:'hoja de ruta del supervisor', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor,recepcionista]},
                    {menuType:'table', name:'periodos_reltar', label:'observaciones de paneles-tareas', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                    {menuType:'seleccion_supervision', name:'seleccion', label:'selección', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor,recepcionista]},
                    {menuType:'table', name:'pantar', label:'tamaño de supervisiones', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor]},
                    {menuType:'table', name:'periodos_reltar', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor,recepcionista]},
                    {menuType:'table', name:'periodos_submod', label:'submodalidad', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,supervisor,recepcionista]},
                    {menuType:'proc' , name:'dm2_backup_pre_recuperar', label:'recuperar backup', onlyVisibleFor:[programador]},
                ]},
                /*
                //{menuType:'table', name:'periodos_control_altas_bajas_anulados'  , label:'control de altas/bajas/anulados', onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
                //{menuType:'table', name:'calculos'              , label:'Cálculos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_precios_maximos_vw'            , label:'precios máximos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_precios_minimos_vw'            , label:'precios mínimos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_variaciones_maximas_vw'        , label:'variaciones máximas', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_variaciones_minimas_vw'        , label:'variaciones mínimas', onlyVisibleFor:[programador,coordinador,analista]},
                //{menuType:'table', name:'periodos_control_observaciones'         , label:'vista de control de observaciones', onlyVisibleFor:[programador,coordinador,analista]},
                */
            ], onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
            {menuType:'menu', name:'informantes', menuContent:[

                {menuType:'menu', name:'alta manual', menuContent:[
                   {menuType:'table', name:'informantes_altamanual'                , label:'informantes', onlyVisibleFor:[programador,coordinador, analista]},
                   {menuType:'table', name:'forinf'                                , label:'formularios', onlyVisibleFor:[programador,coordinador, analista]},
                ]},


                {menuType:'table', name:'periodos_relinf'                       , label:'comentarios de la hoja de ruta', onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,supervisor]},
                {menuType:'menu', name:'hoja de ruta', menuContent:[
                    {menuType:'table', name:'periodos_hdrexportarteorica'       , label:'teórica'             , onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,recepGabinete,supervisor]},
                    {menuType:'table', name:'periodos_hdrexportar'              , label:'efectiva'            , onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,recepGabinete]},
                    {menuType:'table', name:'periodos_hdrexportarcierretemporal', label:'cierre temporal'     , onlyVisibleFor:[programador,coordinador,jefeCampo,analista,recepcionista,recepGabinete]},
                    {menuType:'table', name:'periodos_reemplazosexportar'       , label:'titulares-reemplazos', onlyVisibleFor:[programador,coordinador,analista]},
                ]},
                {menuType:'table', name:'conjuntomuestral'                      , label:'conjuntos muestrales', onlyVisibleFor:[programador,coordinador,analista,recepcionista,supervisor,jefeCampo]},
                {menuType:'table', name:'informantes'                           , onlyVisibleFor:[programador,coordinador,analista,recepcionista,supervisor,jefeCampo]},
                {menuType:'table', name:'periodos_informantesactivos'           , label:'activos', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesaltasbajas'        , label:'altas y bajas', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'calculos_novobs_recep'                 , label:'altas y bajas (recep)', onlyVisibleFor:[programador,jefeCampo,recepcionista,recepGabinete]},
                {menuType:'table', name:'periodos_informantesrubro'             , label:'por rubro', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesrazon'             , label:'por razón', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_informantesformulario'        , label:'por formulario', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_control_hojas_ruta'           , label:'control de hoja de ruta', onlyVisibleFor:[programador,coordinador,analista]},
            ], onlyVisibleFor:[programador,coordinador,analista,jefeCampo,recepcionista,supervisor,recepGabinete]},
            {menuType:'menu', name:'canasta_ipcba', label:'canasta de IPCBA', menuContent:[
                {menuType:'table', name:'grupos'   , onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'productos', onlyVisibleFor:[programador,coordinador,analista,recepcionista,jefeCampo,recepGabinete,supervisor]},
                //{menuType:'table', name:'periodos_vista_control_diccionario', label:'diccionario valores de atributos', onlyVisibleFor:[programador,coordinador,analista]},
            ], onlyVisibleFor:[programador,coordinador,analista,recepcionista,jefeCampo,recepGabinete,supervisor]},
            {menuType:'menu', name:'analisis', label:'análisis', menuContent:[
                {menuType:'menu', name:'calculos', label:'cálculo', onlyVisibleFor:[programador,coordinador,analista,migracion], menuContent:subMenuCalculos},
                {menuType:'table', name:'calculos_novobs', label:'altas y bajas manuales del cálculo', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'periodos_novpre', label:'anulación de precios', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'menu', name:'listados', label:'listados', onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                    {menuType:'menu', name:'grupos'   , label:'grupos'   , onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                        {menuType:'table', name:'periodos_control_grupos_para_cierre'     , label:'control de grupos'},
                        //{menuType:'proc', name:'', label: 'Resultados (permite elegir columnas)'},
                    ]},
                    {menuType:'menu', name:'productos', label:'productos', onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                        {menuType:'table', name:'periodos_desvios'                      , label:'desvíos de los productos publicados'},
                        {menuType:'table', name:'periodos_control_productos_para_cierre', label:'control de productos'},
                        {menuType:'table', name:'periodos_calprodresp'                  , label:'revision de los productos por el analista'},
                        {menuType:'table', name:'grupos_resp'                           , label:'grupos de revision'},
                        //{menuType:'table', name:'periodos_unificacion_valores_atributos', label:'unificación de marcas'},
                        {menuType:'proc', name:'unificar_valores_atributos_exportar', label:'unificación de marcas'},
                    ]},
                    {menuType:'menu', name:'precios'  , label:'precios'  , onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                        {menuType:'table', name:'periodos_relpre_control_rangos_analisis'         , label:'inconsistencias de precios analisis'},
                        {menuType:'table', name:'periodos_precios_inconsistentes'                 , label:'incompletitud'},
                        {menuType:'table', name:'periodos_precios_porcentaje_positivos_y_anulados', label:'porcentajes de potenciales y positivos por formulario'},
                        {menuType:'table', name:'periodos_control_ajustes'                        , label:'ajustes de precios'},
                        {menuType:'proc' , name:'control_ajustes_exportar'                        , label:'ajustes de precios exp'},
                        {menuType:'table', name:'periodos_control_sinvariacion'                   , label:'precios sin variacion'},
                        {menuType:'table', name:'periodos_control_tipoprecio'                     , label:'tipos de precios'},
                        {menuType:'table', name:'periodos_control_sinprecio'                      , label:'tipo de precio sin existencia'},
                        {menuType:'table', name:'periodos_relpre_1_sn'                            , label:'tipo de precio sin existencia/no vende'},
                        {menuType:'proc' , name:'relpre_exportar'                                 , label:'relpre exp'},
                        {menuType:'proc' , name:'calobs_ampliado_exportar'                        , label:'calobs ampliado'},
        
                    ]},
                    //{menuType:'menu', name:'atributos', label:'atributos', onlyVisibleFor:[programador,coordinador,analista], menuContent:[
                    //    {menuType:'matriz', name:'matriz', onlyVisibleFor:[programador], showInOfflineMode: false},
                    //]},
                ]},
                {menuType:'menu', name:'borrar', label:'borrar', onlyVisibleFor:[programador,coordinador,analista,recepGabinete], menuContent:[
                    {menuType:'table', name:'novdelvis', label:'visitas'},
                    {menuType:'table', name:'novdelobs', label:'observaciones'},
                ]},
                {menuType:'table', name:'relmon', label:'cotización moneda extranjera', onlyVisibleFor:[programador,coordinador,analista]},
                {menuType:'table', name:'calculos_canasta_producto', label:'canasta por producto', onlyVisibleFor:[programador,coordinador,analista]},                        
            ], onlyVisibleFor:[programador,coordinador,analista,migracion,recepGabinete]},                
            {menuType:'menu', name:'resultados', menuContent:[
                {menuType:'table', name:'calgru_base', label:'vista de calgru base'},
                {menuType:'table', name:'caldiv_base', label:'vista de caldiv base'},
                {menuType:'table', name:'calculos_calgru_vw', label:'vista de calgru'},
                {menuType:'table', name:'calgru_b1112_b21_vw', label:'empalme'},
                {menuType:'table', name:'calculos_caldiv_vw', label:'vista de caldiv'},
                {menuType:'filtravarios_caldiv', name:'caldiv_vw_varios', label:'vista de caldiv varios', onlyVisibleFor:[programador]},
                {menuType:'table', name:'cuagru', label: 'grupos por cuadro'},
                {menuType:'mostrar_cuadros', name:'cuadros', label:'cuadros para informe', onlyVisibleFor:[programador]},
                //{menuType:'table', name:'cuadros', label: 'cuadros'},
                {menuType:'menu', name:'frecuencia_de_cambio', label:'frecuencia de cambio', menuContent:[
                    {menuType:'table', name:'periodos_freccambio_nivel0', label:'nivel 0'},
                    {menuType:'table', name:'periodos_freccambio_nivel1', label:'nivel 1'},
                    {menuType:'table', name:'periodos_freccambio_nivel3', label:'nivel 3'},
                    //{menuType:'table', name:'periodos_freccambio_resto', label:'resto IPCBA general'},
                    //{menuType:'table', name:'periodos_freccambio_restorest', label:'resto IPCBA restricto'},
                ]},
                {menuType: 'menu',name:'app precios', menuContent:[
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
            ], onlyVisibleFor:[programador,coordinador,analista]},
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
                {menuType:'table', name:'barrios'                                            },
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
                {menuType:'table', name:'periodos_migra_relatr', label:'relatr'              },
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
        ];
        if(this.config.ipc && this.config.ipc.calculando_periodo_base){
            menuPrincipal.push({menuType:'menu', name:'perbase', label:'periodo base', menuContent:[
                {menuType:'proc' , name:'perbase_calcular'  , label:'calcular'  },
                // {menuType:'table', name:'perbase_parametros', label:'configurar'},
            ]})
        }
        return {menu:menuPrincipal};
    }
    async isThisProcedureAllowed(context, procedureDef, params){
        var be = this;
        var tablaAccessProcedures={
            table_structure:true,
            table_data:true,
            table_record_save:true,
            table_record_delete:true,
            table_record_lock:true,
            table_record_enter:true,
            table_record_leave:true,
        }
        if(!await super.isThisProcedureAllowed(context, procedureDef, params)){
            return false;
        }
        if(context.be.config.server.policy=='web'){
            if(tablaAccessProcedures[procedureDef.action]){
                var tableDef = await be.tableStructures[params.table](context);
                return tableDef.policy=='web';
            }else if(procedureDef.policy!='web'){
                return false;
            }
        }
        return true;
    }
    clientIncludes(req, opts) {
        var be = this;
        var loggedResources = req && opts && !opts.skipMenu;
        var menuedResources=loggedResources ? [
            { type:'js' , src: 'client/client.js' },
            { type: 'js', src: 'client/hoja-de-ruta.js' },
            { type: 'js', src: 'client/hoja-de-ruta-react.js' },
            { type: 'js', src: 'client/imp-formularios.js' },
        ]:[
            {type:'js' , src:'unlogged.js' },
        ];
        if(opts && opts.extraFiles){
            menuedResources = menuedResources.concat(opts.extraFiles);
        }
        return [
            { type: 'js', module: 'react', modPath: 'umd', fileDevelopment:'react.development.js', file:'react.production.min.js' },
            { type: 'js', module: 'react-dom', modPath: 'umd', fileDevelopment:'react-dom.development.js', file:'react-dom.production.min.js' },
            { type: 'js', module: '@material-ui/core', modPath: 'umd', fileDevelopment:'material-ui.development.js', file:'material-ui.production.min.js' },
            { type: 'js', module: 'material-styles', fileDevelopment:'material-styles.development.js', file:'material-styles.production.min.js' },
            { type: 'js', module: 'clsx', file:'clsx.min.js' },
            { type: 'js', module: 'redux', modPath:'../dist', fileDevelopment:'redux.js', file:'redux.min.js' },
            { type: 'js', module: 'react-redux', modPath:'../dist', fileDevelopment:'react-redux.js', file:'react-redux.min.js' },
            { type: 'js', module: 'react-window', fileDevelopment:'index-dev.umd.js', file:'index-prod.umd.js' },
            { type: 'js', module: 'memoize-one',  file:'memoize-one.js' },
            ...super.clientIncludes(req, opts),
            { type: 'js', module: 'service-worker-admin',  file:'service-worker-admin.js' },
            { type: 'js', module: 'redux-typed-reducer', modPath:'../dist', file:'redux-typed-reducer.js' },
            { type: 'js', src: 'adapt.js' },
            { type: 'js', src: 'dm-tipos.js' },
            { type: 'js', src: 'dm-funciones.js' },
            { type: 'js', src: 'dm-react.js' },
            { type: 'js', src: 'ejemplo-precios.js' },
            { type: 'css', file: 'ejemplo-precios.css' },
            { type: 'css', file: 'hoja-de-ruta.css' },
            { type: 'css', file: 'imp-formularios.css' },
            { type: 'css', file: 'menu.css' },
            ... menuedResources
        ];
    }
    getVisibleMenu(menu, context){
        var be=this;
        var currentUserRole = (context.user||{})[be.config.login.rolFieldName];
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
            {name: 'ejecucion_calculos', path: __dirname},
            {name: 'pantar', path: __dirname},
            {name: 'barrios', path: __dirname},
            {name: 'bienvenida', path: __dirname},
            {name: 'agrupaciones', path: __dirname},
            {name: 'conjuntomuestral', path: __dirname},
            {name: 'calculos_def', path: __dirname},
            {name: 'calculos', path: __dirname},
            {name: 'calculos_canasta_producto', path: __dirname},
            {name: 'calculos_novprod', path: __dirname},
            {name: 'calculos_caldiv_vw', path: __dirname},
            {name: 'calculos_calgru_vw', path: __dirname},
            {name: 'calculos_calgru_b1112_b21_vw', path: __dirname},
            {name: 'calculos_novobs', path: __dirname},
            {name: 'calbase_prod', path: __dirname},
            {name: 'calbase_div', path: __dirname},
            {name: 'calbase_obs', path: __dirname},
            {name: 'magnitudes', path: __dirname},
            {name: 'unidades', path: __dirname},
            {name: 'especificaciones', path: __dirname},
            {name: 'prodespecificacioncompleta', path: __dirname},
            {name: 'prodcontrolrangos', path: __dirname},
            {name: 'prodagr', path: __dirname},
            {name: 'tipoinf', path: __dirname},
            {name: 'forinf', path: __dirname},
            {name: 'formularios', path: __dirname},
            {name: 'productos', path: __dirname},
            {name: 'calobs', path: __dirname},
            {name: 'calhoggru', path: __dirname},
            {name: 'calhogsubtotales', path: __dirname},
            {name: 'calprod', path: __dirname},
            {name: 'calprodagr', path: __dirname},
            {name: 'novobs', path: __dirname},
            {name: 'novobs_recep', path: __dirname},
            {name: 'blapre', path: __dirname},
            {name: 'blaatr', path: __dirname},
            {name: 'novpre', path: __dirname},
            {name: 'novpre_recep', path: __dirname},
            {name: 'novdelobs', path: __dirname},
            {name: 'novdelvis', path: __dirname},
            {name: 'cierre_periodos', path: __dirname},
            {name: 'vista_control_diccionario', path: __dirname},
            {name: 'ipcba_usuarios', path: __dirname},
            {name: 'grupos', path: __dirname},
            {name: 'grupos_resp', path: __dirname},
            {name: 'gru_grupos', path: __dirname},
            {name: 'forprod', path: __dirname},
            {name: 'atributos', path: __dirname},
            {name: 'prerep', path: __dirname},
            {name: 'prodatr', path: __dirname},
            {name: 'prodatrval', path: __dirname},
            {name: 'divisiones', path: __dirname},
            {name: 'hogares', path: __dirname},
            {name: 'proddiv', path: __dirname},
            {name: 'conjuntomuestral', path: __dirname},
            {name: 'novprod', path: __dirname},
            {name: 'muestras', path: __dirname},
            {name: 'rubros', path: __dirname},
            {name: 'informantes', path: __dirname},
            {name: 'contactos', path: __dirname},
            {name: 'personal', path: __dirname},
            {name: 'razones', path: __dirname},
            {name: 'razones_encuestador', path: __dirname},
            {name: 'periodos', path: __dirname},
            {name: 'periodos_novpre', path: __dirname},
            {name: 'periodos_ingreso', path: __dirname},
            {name: 'periodos_control_productos_para_cierre', path: __dirname},
            {name: 'periodos_control_grupos_para_cierre', path: __dirname},
            {name: 'periodos_controlvigencias', path: __dirname},
            {name: 'periodos_control_atributos', path: __dirname},
            {name: 'periodos_control_atr1_diccionario_atributos', path: __dirname},
            {name: 'periodos_control_atr2_diccionario_atributos', path: __dirname},
            {name: 'periodos_control_diccionario_atributos_val', path: __dirname},
            {name: 'periodos_control_ajustes', path: __dirname},
            {name: 'periodos_control_cambios', path: __dirname},
            //{name: 'periodos_relpre_control_rangos', path: __dirname},
            {name: 'periodos_relpre_control_rangos_analisis', path: __dirname},
            {name: 'periodos_relpre_control_rangos_recepcion', path: __dirname},
            {name: 'periodos_unificacion_valores_atributos', path: __dirname},
            //{name: 'paneles_relpre_control_rangos', path: __dirname},
            {name: 'paneles_relpre_control_rangos_analisis', path: __dirname},
            {name: 'paneles_relpre_control_rangos_recepcion', path: __dirname},
            {name: 'paneles_unificacion_valores_atributos', path: __dirname},
            {name: 'periodos_control_normalizables_sindato', path: __dirname},
            {name: 'periodos_control_anulados_recep', path: __dirname},
            {name: 'periodos_control_sinvariacion', path: __dirname},
            {name: 'periodos_control_ingresados_calculo', path: __dirname},
            {name: 'periodos_control_tipoprecio', path: __dirname},
            {name: 'periodos_control_sinprecio', path: __dirname},
            {name: 'periodos_precios_minimos_vw', path: __dirname},
            {name: 'periodos_precios_maximos_vw', path: __dirname},
            {name: 'periodos_precios_maximos_minimos', path: __dirname},
            {name: 'periodos_variaciones_minimas_vw', path: __dirname},
            {name: 'periodos_variaciones_maximas_vw', path: __dirname},
            {name: 'periodos_control_observaciones', path: __dirname},
            {name: 'periodos_informantesrubro', path: __dirname},
            {name: 'periodos_informantesrazon', path: __dirname},
            {name: 'periodos_informantesformulario', path: __dirname},
            {name: 'periodos_informantesactivos', path: __dirname},
            {name: 'periodos_informantesaltasbajas', path: __dirname},
            {name: 'periodos_reemplazosexportar', path: __dirname},
            {name: 'periodos_hdrexportarefectivossinprecio', path: __dirname},
            {name: 'periodos_hdrexportarcierretemporal', path: __dirname},
            {name: 'periodos_hdrexportar', path: __dirname},
            {name: 'periodos_hdrexportarteorica', path: __dirname},
            {name: 'periodos_control_hojas_ruta', path: __dirname},
            {name: 'periodos_hojaderutasupervisor', path: __dirname},
            {name: 'periodos_desvios', path: __dirname},
            {name: 'periodos_relpre_1_sn', path: __dirname},
            {name: 'periodos_control_verificar_precio', path: __dirname},
            {name: 'periodos_control_comentariosrelpre', path: __dirname},
            {name: 'periodos_control_comentariosrelvis', path: __dirname},
            {name: 'periodos_control_generacion_formularios', path: __dirname},
            {name: 'periodos_precios_porcentaje_positivos_y_anulados', path: __dirname},
            {name: 'periodos_precios_porcentaje_positivos_y_anulados_ref', path: __dirname},
            {name: 'periodos_precios_positivos', path: __dirname},
            {name: 'periodos_precios_inconsistentes', path: __dirname},
            {name: 'periodos_novpre_recep', path: __dirname},
            {name: 'calculos_novobs_recep', path: __dirname},
            {name: 'periodos_relinf', path: __dirname},
            {name: 'periodos_reltar', path: __dirname},
            {name: 'periodos_calprodresp', path: __dirname},
            {name: 'paneles_relinf', path: __dirname},
            {name: 'relpantar_relinf', path: __dirname},
            {name: 'tareas', path: __dirname},
            {name: 'reltar', path: __dirname},
            {name: 'reltar_candidatas', path: __dirname},
            {name: 'relinf', path: __dirname},
            {name: 'relinf_observaciones', path: __dirname},
            {name: 'calprodresp', path: __dirname},
            {name: 'cuadros', path: __dirname},
            {name: 'cuagru', path: __dirname},
            {name: 'precios_minimos_vw', path: __dirname},
            {name: 'precios_maximos_vw', path: __dirname},
            {name: 'precios_maximos_minimos', path: __dirname},
            {name: 'precios_positivos', path: __dirname},
            {name: 'precios_inconsistentes', path: __dirname},
            {name: 'monedas', path: __dirname},
            {name: 'relenc', path: __dirname},
            {name: 'relmon', path: __dirname},
            {name: 'relpan', path: __dirname},
            {name: 'relpantar', path: __dirname},
            {name: 'relvis', path: __dirname},
            {name: 'relvis_pt', path: __dirname},
            {name: 'parametros', path: __dirname},
            {name: 'mobile_hoja_de_ruta', path: __dirname},
            {name: 'matriz_de_un_producto', path: __dirname},
            {name: 'mobile_visita', path: __dirname},
            {name: 'mobile_precios', path: __dirname},
            {name: 'mobile_atributos', path: __dirname},
            {name: 'tipopre', path: __dirname},
            {name: 'tipopre_encuestador', path: __dirname},
            {name: 'relpre', path: __dirname},
            {name: 'migra_relpre', path: __dirname},
            {name: 'migra_relatr', path: __dirname},
            {name: 'periodos_migra_relatr', path: __dirname},
            //{name: 'relpre_control_rangos', path: __dirname},
            {name: 'relpre_control_rangos_analisis', path: __dirname},
            {name: 'relpre_control_rangos_recepcion', path: __dirname},
            {name: 'relpre_control_rangos_atrnorm', path: __dirname},
            {name: 'unificacion_valores_atributos', path: __dirname},
            {name: 'valvalatr', path: __dirname},
            {name: 'relevamiento', path: __dirname},
            {name: 'relatr', path: __dirname},
            {name: 'relsup', path: __dirname},
            {name: 'rubfor', path: __dirname},
            {name: 'relsup_a_elegir', path: __dirname},
            {name: 'hojaderutasupervisor', path: __dirname},
            {name: 'hdrexportarefectivossinprecio', path: __dirname},
            {name: 'calgru', path: __dirname},
            {name: 'calgru_vw', path: __dirname},
            {name: 'calgru_b1112_b21_vw', path: __dirname},
            {name: 'calgru_base', path: __dirname},
            {name: 'caldiv_base', path: __dirname},
            {name: 'caldiv_vw', path: __dirname},
            {name: 'caldiv', path: __dirname},
            {name: 'proddivestimac', path: __dirname},
            {name: 'controlvigencias', path: __dirname},
            {name: 'canasta_producto', path: __dirname},
            {name: 'control_atributos', path: __dirname},
            {name: 'control_ajustes', path: __dirname},
            {name: 'control_cambios', path: __dirname},
            {name: 'control_normalizables_sindato', path: __dirname},
            {name: 'control_observaciones', path: __dirname},
            {name: 'control_ingresados_calculo', path: __dirname},
            {name: 'control_tipoprecio', path: __dirname},
            {name: 'control_sinprecio', path: __dirname},
            {name: 'control_sinvariacion', path: __dirname},
            {name: 'relpre_control_sinvariacion', path: __dirname},
            {name: 'relpre_control_atr1_diccionario_atributos', path: __dirname},
            {name: 'relpre_control_atr2_diccionario_atributos', path: __dirname},
            {name: 'control_rangos', path: __dirname},
            {name: 'control_hojas_ruta', path: __dirname},
            {name: 'control_grupos_para_cierre', path: __dirname},
            {name: 'control_anulados_recep', path: __dirname},
            {name: 'control_generacion_formularios', path: __dirname},
            {name: 'control_diccionario_atributos', path: __dirname},
            {name: 'vista_control_diccionario', path: __dirname},
            {name: 'periodos_vista_control_diccionario', path: __dirname},
            {name: 'control_productos_para_cierre', path: __dirname},
            {name: 'hdrexportar', path: __dirname},
            {name: 'hdrexportarteorica', path: __dirname},
            {name: 'reemplazosexportar', path: __dirname},
            {name: 'hdrexportarcierretemporal', path: __dirname},
            {name: 'informantesaltasbajas', path: __dirname},
            {name: 'informantesformulario', path: __dirname},
            {name: 'informantesrazon', path: __dirname},
            {name: 'informantesrubro', path: __dirname},
            {name: 'informantesactivos', path: __dirname},
            {name: 'informantes_altamanual', path: __dirname},
            {name: 'variaciones_minimas_vw', path: __dirname},
            {name: 'variaciones_maximas_vw', path: __dirname},
            {name: 'parhog', path: __dirname},
            {name: 'parhoggru', path: __dirname},
            {name: 'hogparagr', path: __dirname},
            {name: 'relatr_tipico', path: __dirname},
            {name: 'periodos_freccambio_nivel0', path: __dirname},
            {name: 'periodos_freccambio_nivel1', path: __dirname},
            {name: 'periodos_freccambio_nivel3', path: __dirname},
            {name: 'periodos_freccambio_resto', path: __dirname},
            {name: 'periodos_freccambio_restorest', path: __dirname},
            {name: 'periodos_matrizresultados', path: __dirname},
            {name: 'freccambio_nivel0', path: __dirname},
            {name: 'freccambio_nivel1', path: __dirname},
            {name: 'freccambio_nivel3', path: __dirname},
            {name: 'freccambio_resto', path: __dirname},
            {name: 'freccambio_restorest', path: __dirname},
            {name: 'relpre_1_sn', path: __dirname},
            {name: 'control_verificar_precio', path: __dirname},
            {name: 'desvios', path: __dirname},
            {name: 'control_comentariosrelpre', path: __dirname},
            {name: 'control_comentariosrelvis', path: __dirname},
            {name: 'precios_porcentaje_positivos_y_anulados', path: __dirname},
            {name: 'precios_porcentaje_positivos_y_anulados_ref', path: __dirname},
            {name: 'matrizresultados', path: __dirname},
            {name: 'app_agrupaciones', path: __dirname},
            {name: 'app_calculo_grupos', path: __dirname},
            {name: 'app_calculo_productos', path: __dirname},
            {name: 'app_grupos', path: __dirname},
            {name: 'app_grupos_producto', path: __dirname},
            {name: 'app_periodos', path: __dirname},
            {name: 'app_productos', path: __dirname},
            {name: 'instalaciones', path: __dirname},
            {name: 'infreemp', path: __dirname},
            {name: 'infreempdir', path: __dirname},
            {name: 'misma_direccion', path: __dirname},
            {name: 'formulario_emergencia', path: __dirname},
            {name: 'relinf_fechassalida', path: __dirname},
            {name: 'cambiopantar_lote', path: __dirname},
            {name: 'cambiopantar_det', path: __dirname},
            {name: 'tercera_ausencia', path: __dirname},
            {name: 'periodos_submod', path: __dirname},
            {name: 'submod', path: __dirname}
        ]);
    }
}

new AppIpcba().start();