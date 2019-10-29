--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4 (Ubuntu 11.4-1.pgdg18.04+1)
-- Dumped by pg_dump version 11.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agrupaciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.agrupaciones (
    agrupacion text NOT NULL,
    nombreagrupacion text,
    paravarioshogares boolean DEFAULT false NOT NULL,
    calcular_junto_grupo text,
    valoriza boolean DEFAULT false,
    tipo_agrupacion text,
    CONSTRAINT "texto invalido en nombreagrupacion de tabla agrupaciones" CHECK (comun.cadena_valida(nombreagrupacion, 'castellano'::text))
);


ALTER TABLE cvp.agrupaciones OWNER TO cvpowner;

--
-- Name: atributos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.atributos (
    atributo integer NOT NULL,
    nombreatributo text,
    tipodato text NOT NULL,
    abratributo text,
    escantidad text DEFAULT 'N'::text,
    unidaddemedida text,
    es_vigencia boolean,
    valorinicial text,
    visible text DEFAULT 'S'::text NOT NULL,
    CONSTRAINT "El tipo de atributo debe ser C (caracter) o N (número)" CHECK ((tipodato = ANY (ARRAY['C'::text, 'N'::text]))),
    CONSTRAINT atributos_es_vigencia_check CHECK (es_vigencia),
    CONSTRAINT "texto invalido en abratributo de tabla atributos" CHECK (comun.cadena_valida(abratributo, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombreatributo de tabla atributos" CHECK (comun.cadena_valida(nombreatributo, 'castellano'::text)),
    CONSTRAINT "texto invalido en unidaddemedida de tabla atributos" CHECK (comun.cadena_valida(unidaddemedida, 'extendido'::text)),
    CONSTRAINT "texto invalido en valorinicial de tabla atributos" CHECK (comun.cadena_valida(valorinicial, 'amplio'::text))
);


ALTER TABLE cvp.atributos OWNER TO cvpowner;

--
-- Name: periodos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.periodos (
    periodo text NOT NULL,
    ano integer NOT NULL,
    mes integer NOT NULL,
    visita integer DEFAULT 1 NOT NULL,
    ingresando text DEFAULT 'N'::text,
    periodoanterior text,
    fechageneracionperiodo timestamp without time zone,
    comentariosper text,
    fechacalculoprereplote1 timestamp without time zone,
    fechacalculoprereplote2 timestamp without time zone,
    fecha_cierre_ingreso timestamp without time zone,
    cerraringresocampohastapanel integer DEFAULT 0 NOT NULL,
    habilitado text DEFAULT 'S'::text,
    CONSTRAINT cerraringresocampohastapanel_invalido CHECK (((cerraringresocampohastapanel >= 0) AND (cerraringresocampohastapanel <= 20))),
    CONSTRAINT formato_periodo CHECK ((((substr((periodo)::text, 2, 4))::integer = ano) AND ((substr((periodo)::text, 7, 2))::integer = mes) AND (length((periodo)::text) = 8)))
);


ALTER TABLE cvp.periodos OWNER TO cvpowner;

--
-- Name: bienvenida; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.bienvenida AS
 SELECT 9 AS orden,
    'version'::text AS codigo,
    'V160909'::text AS dato,
    'es la versión de la base de datos'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 10 AS orden,
    'version_cliente'::text AS codigo,
    'V190813'::text AS dato,
    'es la versión necesaria en el cliente'::text AS explicacion,
    'N9'::text AS nivel
UNION
 SELECT 11 AS orden,
    'session_user'::text AS codigo,
    "session_user"() AS dato,
    'es el usuario conectado'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 12 AS orden,
    'nivel_usuario'::text AS codigo,
        CASE
            WHEN pg_has_role('cvp_administrador'::name, 'member'::text) THEN 'N3'::text
            WHEN pg_has_role('cvp_analistas'::name, 'member'::text) THEN 'N2'::text
            WHEN pg_has_role('cvp_usuarios'::name, 'member'::text) THEN 'N1'::text
            WHEN pg_has_role('cvp_recepcionista'::name, 'member'::text) THEN 'N1'::text
            ELSE 'N0'::text
        END AS dato,
    'es el nivel de permisos del usuario'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 13 AS orden,
    'current_timestamp'::text AS codigo,
    to_char(now(), 'DD/MM/YYYY HH24:MI:SS'::text) AS dato,
    'es la fecha del sistema'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 14 AS orden,
    'base_instalada'::text AS codigo,
    (((( SELECT sql_implementation_info.character_value
           FROM information_schema.sql_implementation_info
          WHERE ((sql_implementation_info.implementation_info_id)::text = '17'::text)))::text || ' '::text) || (( SELECT sql_implementation_info.character_value
           FROM information_schema.sql_implementation_info
          WHERE ((sql_implementation_info.implementation_info_id)::text = '18'::text)))::text) AS dato,
    'es la base de datos que está instalada'::text AS explicacion,
    'N3'::text AS nivel
UNION
 SELECT 21 AS orden,
    'separador'::text AS codigo,
    '- - - - - -'::text AS dato,
    '- - - - - - - - - - - - - - - - - - - - -'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 22 AS orden,
    'min_periodo'::text AS codigo,
    min((periodos.periodo)::text) AS dato,
    'es el periodo abierto más antiguo'::text AS explicacion,
    'N3'::text AS nivel
   FROM cvp.periodos
  WHERE ((periodos.ingresando)::text = 'S'::text)
UNION
 SELECT 23 AS orden,
    'max_periodo'::text AS codigo,
    max((periodos.periodo)::text) AS dato,
    'es el último periodo abierto '::text AS explicacion,
    'N1'::text AS nivel
   FROM cvp.periodos
  WHERE ((periodos.ingresando)::text = 'S'::text)
UNION
 SELECT 24 AS orden,
    'rol_user'::text AS codigo,
    r.listaroles AS dato,
    (
        CASE
            WHEN (r.listaroles ~~ '%,%'::text) THEN 'son los roles '::text
            ELSE 'es el rol '::text
        END || 'del usuario conectado'::text) AS explicacion,
    'N1'::text AS nivel
   FROM ( SELECT string_agg((pg_roles.rolname)::text, ','::text) AS listaroles
           FROM pg_roles
          WHERE (pg_has_role("session_user"(), pg_roles.oid, 'member'::text) AND (pg_roles.rolname <> "session_user"()))) r;


ALTER TABLE cvp.bienvenida OWNER TO cvpowner;

--
-- Name: bitacora; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.bitacora (
    cuando timestamp without time zone DEFAULT now(),
    que text
);


ALTER TABLE cvp.bitacora OWNER TO cvpowner;

--
-- Name: blaatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.blaatr (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    atributo integer NOT NULL,
    valor text,
    visita integer DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    validar_con_valvalatr boolean,
    CONSTRAINT "El valor de Validar_con_ValValAtr debe ser TRUE o nulo" CHECK (validar_con_valvalatr),
    CONSTRAINT "no se puede poner el sombrero en el atributo" CHECK ((valor !~~ '%~%'::text))
);


ALTER TABLE cvp.blaatr OWNER TO cvpowner;

--
-- Name: blapre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.blapre (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    precio double precision,
    tipoprecio text,
    visita integer DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentariosrelpre text,
    cambio text,
    precionormalizado double precision,
    especificacion integer NOT NULL,
    ultima_visita boolean,
    CONSTRAINT "El precio no puede ser 0 o negativo" CHECK ((precio > (0)::double precision)),
    CONSTRAINT "El valor del campo cambio debe ser C o nulo" CHECK ((cambio = 'C'::text))
);


ALTER TABLE cvp.blapre OWNER TO cvpowner;

--
-- Name: cal_mensajes; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.cal_mensajes (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    corrida timestamp without time zone DEFAULT now() NOT NULL,
    paso text NOT NULL,
    renglon integer NOT NULL,
    tipo text DEFAULT 'log'::text NOT NULL,
    mensaje text,
    producto text,
    division text,
    informante integer,
    observacion integer,
    formulario integer,
    grupo text,
    agrupacion text,
    fechahora timestamp without time zone,
    CONSTRAINT "tipo: error o log o comenzo o finalizo" CHECK ((tipo = ANY (ARRAY['error'::text, 'log'::text, 'comenzo'::text, 'finalizo'::text])))
);


ALTER TABLE cvp.cal_mensajes OWNER TO cvpowner;

--
-- Name: calbase_div; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calbase_div (
    calculo integer NOT NULL,
    producto text NOT NULL,
    division text NOT NULL,
    ultimo_mes_anterior_bajas text,
    CONSTRAINT "texto invalido en division de tabla calbase_div" CHECK (comun.cadena_valida(division, 'amplio'::text))
);


ALTER TABLE cvp.calbase_div OWNER TO cvpowner;

--
-- Name: calbase_obs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calbase_obs (
    calculo integer NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    periodo_aparicion text,
    incluido boolean,
    periodo_anterior_baja text
);


ALTER TABLE cvp.calbase_obs OWNER TO cvpowner;

--
-- Name: calbase_prod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calbase_prod (
    calculo integer NOT NULL,
    producto text NOT NULL,
    mes_inicio text
);


ALTER TABLE cvp.calbase_prod OWNER TO cvpowner;

--
-- Name: calculos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calculos (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    esperiodobase text DEFAULT 'N'::text,
    periodoanterior text,
    fechacalculo timestamp without time zone,
    calculoanterior integer,
    abierto text DEFAULT 'S'::text NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    agrupacionprincipal text DEFAULT 'A'::text NOT NULL,
    valido text DEFAULT 'N'::text NOT NULL,
    pb_calculobase integer,
    motivocopia text,
    fechageneracionexternos timestamp without time zone,
    estimacion integer DEFAULT 0 NOT NULL,
    transmitir_canastas text DEFAULT 'N'::text NOT NULL,
    fechatransmitircanastas timestamp without time zone,
    denominadordefinitivosegimp boolean DEFAULT true NOT NULL,
    descartedefinitivosegimp boolean DEFAULT true NOT NULL,
    hasta_panel integer,
    CONSTRAINT "Abierto debe ser S (Si) o N (No)" CHECK ((abierto = ANY (ARRAY['S'::text, 'N'::text]))),
    CONSTRAINT "Transmitir Canastas debe ser S (Si) o N (No)" CHECK ((transmitir_canastas = ANY (ARRAY['S'::text, 'N'::text]))),
    CONSTRAINT "texto invalido en motivocopia de tabla calculos" CHECK (comun.cadena_valida(motivocopia, 'amplio'::text))
);


ALTER TABLE cvp.calculos OWNER TO cvpowner;

--
-- Name: calculos_def; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calculos_def (
    calculo integer NOT NULL,
    definicion text,
    principal boolean,
    agrupacionprincipal text DEFAULT 'A'::text NOT NULL,
    basado_en_extraccion_calculo integer,
    basado_en_extraccion_muestra integer,
    para_rellenado_de_base boolean DEFAULT false NOT NULL,
    grupo_raiz text,
    rellenante_de integer,
    CONSTRAINT calculos_def_principal_check CHECK (principal),
    CONSTRAINT "texto invalido en definicion de tabla calculos_def" CHECK (comun.cadena_valida(definicion, 'amplio'::text))
);


ALTER TABLE cvp.calculos_def OWNER TO cvpowner;

--
-- Name: caldiv; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.caldiv (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    division text NOT NULL,
    prompriimpact double precision,
    prompriimpant double precision,
    cantpriimp integer,
    promprel double precision,
    promdiv double precision,
    impdiv text,
    cantincluidos integer,
    cantrealesincluidos integer,
    cantrealesexcluidos integer,
    promvar double precision,
    cantaltas integer,
    promaltas double precision,
    cantbajas integer,
    prombajas double precision,
    cantimputados integer,
    ponderadordiv double precision,
    umbralpriimp integer,
    umbraldescarte integer,
    umbralbajaauto integer,
    cantidadconprecio integer,
    profundidad integer,
    divisionpadre text,
    tipo_promedio text,
    raiz boolean,
    cantexcluidos integer,
    promexcluidos double precision,
    promimputados double precision,
    promrealesincluidos double precision,
    promrealesexcluidos double precision,
    promedioredondeado double precision,
    cantrealesdescartados integer,
    cantpreciostotales integer,
    cantpreciosingresados integer,
    cantconprecioparacalestac integer,
    promsinimpext double precision,
    promrealessincambio double precision,
    promrealessincambioant double precision,
    promsinaltasbajas double precision,
    promsinaltasbajasant double precision,
    CONSTRAINT "la division raiz debe ser 0" CHECK (((raiz IS TRUE) = ((division)::text = '0'::text))),
    CONSTRAINT "la division raiz debe tener profundidad 0" CHECK (((raiz IS TRUE) = (profundidad = 0))),
    CONSTRAINT "la division raiz no debe tener padre" CHECK ((((raiz IS TRUE) = (divisionpadre IS NULL)) OR (calculo < '-1'::integer))),
    CONSTRAINT "texto invalido en division de tabla caldiv" CHECK (comun.cadena_valida(division, 'amplio'::text)),
    CONSTRAINT "texto invalido en divisionpadre de tabla caldiv" CHECK (comun.cadena_valida(divisionpadre, 'amplio'::text))
);


ALTER TABLE cvp.caldiv OWNER TO cvpowner;

--
-- Name: calprodresp; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calprodresp (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    responsable text,
    revisado text DEFAULT 'N'::text,
    observaciones text
);


ALTER TABLE cvp.calprodresp OWNER TO cvpowner;

--
-- Name: grupos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.grupos (
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    nombregrupo text,
    grupopadre text,
    ponderador double precision,
    nivel integer,
    esproducto text DEFAULT 'N'::text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    nombrecanasta text,
    agrupacionorigen text,
    detallarcanasta text,
    explicaciongrupo text,
    responsable text,
    CONSTRAINT "Si esproducto=S o agrupacionorigen no nula => nombregrupo nulo" CHECK (((NOT (((esproducto)::text = 'S'::text) OR (agrupacionorigen IS NOT NULL))) OR (nombregrupo IS NULL))),
    CONSTRAINT "Solo se puede usar como origen la agrupacion A" CHECK ((agrupacionorigen = 'A'::text)),
    CONSTRAINT "texto invalido en explicaciongrupo de tabla grupos" CHECK (comun.cadena_valida(explicaciongrupo, 'amplio'::text)),
    CONSTRAINT "texto invalido en nombrecanasta de tabla grupos" CHECK (comun.cadena_valida(nombrecanasta, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombregrupo de tabla grupos" CHECK (comun.cadena_valida(nombregrupo, 'castellano'::text))
);


ALTER TABLE cvp.grupos OWNER TO cvpowner;

--
-- Name: gru_grupos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.gru_grupos AS
 WITH RECURSIVE hijos_de(agrupacion, grupo_padre, grupo, esproducto) AS (
         SELECT grupos.agrupacion,
            grupos.grupopadre AS grupo_padre,
            grupos.grupo,
            grupos.esproducto
           FROM cvp.grupos
          WHERE (grupos.grupopadre IS NOT NULL)
        UNION ALL
         SELECT p.agrupacion,
            g.grupopadre AS grupo_padre,
            p.grupo,
            p.esproducto
           FROM (hijos_de p
             JOIN cvp.grupos g ON ((((g.grupo)::text = (p.grupo_padre)::text) AND ((g.agrupacion)::text = (p.agrupacion)::text))))
          WHERE (g.grupopadre IS NOT NULL)
        )
 SELECT hijos_de.agrupacion,
    hijos_de.grupo_padre,
    hijos_de.grupo,
    hijos_de.esproducto
   FROM hijos_de
UNION ALL
 SELECT DISTINCT grupos.agrupacion,
    grupos.grupo AS grupo_padre,
    grupos.grupo,
    grupos.esproducto
   FROM cvp.grupos
  WHERE ((grupos.esproducto)::text = 'N'::text)
  ORDER BY 3, 2, 1;


ALTER TABLE cvp.gru_grupos OWNER TO cvpowner;

--
-- Name: productos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.productos (
    producto text NOT NULL,
    nombreproducto text,
    formula text DEFAULT 'General'::text NOT NULL,
    estacional text DEFAULT 'N'::text NOT NULL,
    imputacon text,
    cantperaltaauto integer,
    cantperbajaauto integer,
    unidadmedidaporunidcons text,
    esexternohabitual text,
    tipocalculo text DEFAULT 'D'::text NOT NULL,
    cantobs integer,
    unidadmedidaabreviada text,
    codigo_ccba text,
    porc_adv_inf double precision,
    porc_adv_sup double precision,
    tipoexterno text,
    nombreparaformulario text,
    serepregunta boolean DEFAULT false,
    nombreparapublicar text,
    calculo_desvios text DEFAULT 'N'::text,
    CONSTRAINT "TipoCalculo: D(Dividido) o A(Autoponderado)" CHECK ((tipocalculo = ANY (ARRAY['A'::text, 'D'::text]))),
    CONSTRAINT "Tipoexterno: D(Definitivo) o P(Provisorio)" CHECK ((tipoexterno = ANY (ARRAY['P'::text, 'D'::text]))),
    CONSTRAINT "calculo_desvios: N(Normal) o E(Especial)" CHECK ((calculo_desvios = ANY (ARRAY['N'::text, 'E'::text]))),
    CONSTRAINT "texto invalido en formula de tabla productos" CHECK (comun.cadena_valida(formula, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombreproducto de tabla productos" CHECK (comun.cadena_valida(nombreproducto, 'castellano'::text)),
    CONSTRAINT "texto invalido en unidadmedidaporunidcons de tabla productos" CHECK (comun.cadena_valida(unidadmedidaporunidcons, 'extendido'::text))
);


ALTER TABLE cvp.productos OWNER TO cvpowner;

--
-- Name: caldiv_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.caldiv_vw AS
 SELECT c.periodo,
    c.calculo,
    c.producto,
    p.nombreproducto,
    c.division,
    c.prompriimpact,
    c.prompriimpant,
        CASE
            WHEN ((c.prompriimpact > (0)::double precision) AND (c.prompriimpant > (0)::double precision)) THEN round(((((c.prompriimpact / c.prompriimpant) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp,
    c.promprel,
    c.promdiv,
    c0.promdiv AS promdivant,
    c.promedioredondeado,
    c.impdiv,
        CASE
            WHEN (((c.division)::text = '0'::text) AND ((p.tipoexterno)::text = 'D'::text)) THEN 1
            ELSE c.cantincluidos
        END AS cantincluidos,
        CASE
            WHEN (((c.division)::text = '0'::text) AND ((p.tipoexterno)::text = 'D'::text)) THEN 1
            ELSE c.cantrealesincluidos
        END AS cantrealesincluidos,
    c.cantrealesexcluidos,
    c.promvar,
    c.cantaltas,
    c.promaltas,
    c.cantbajas,
    c.prombajas,
    c.cantimputados,
    c.ponderadordiv,
    c.umbralpriimp,
    c.umbraldescarte,
    c.umbralbajaauto,
    c.cantidadconprecio,
    c.profundidad,
    c.divisionpadre,
    c.tipo_promedio,
    c.raiz,
    c.cantexcluidos,
    c.promexcluidos,
    c.promimputados,
    c.promrealesincluidos,
    c.promrealesexcluidos,
    c.cantrealesdescartados,
    c.cantpreciostotales,
    c.cantpreciosingresados,
    c.cantconprecioparacalestac,
        CASE
            WHEN ((c.promdiv > (0)::double precision) AND (c0.promdiv > (0)::double precision)) THEN round(((((c.promdiv / c0.promdiv) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promsinimpext,
        CASE
            WHEN ((c.promsinimpext > (0)::double precision) AND (c0.promdiv > (0)::double precision)) THEN round(((((c.promsinimpext / c0.promdiv) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS varsinimpext,
        CASE
            WHEN ((c.promrealessincambio > (0)::double precision) AND (c.promrealessincambioant > (0)::double precision)) THEN round(((((c.promrealessincambio / c.promrealessincambioant) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS varsincambio,
        CASE
            WHEN ((c.promsinaltasbajas > (0)::double precision) AND (c.promsinaltasbajasant > (0)::double precision)) THEN round(((((c.promsinaltasbajas / c.promsinaltasbajasant) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS varsinaltasbajas,
        CASE
            WHEN (gg.grupo IS NOT NULL) THEN true
            ELSE false
        END AS publicado,
    r.responsable
   FROM (((((cvp.caldiv c
     LEFT JOIN cvp.productos p ON (((c.producto)::text = (p.producto)::text)))
     LEFT JOIN cvp.periodos l ON (((c.periodo)::text = (l.periodo)::text)))
     LEFT JOIN cvp.caldiv c0 ON ((((c0.periodo)::text = (l.periodoanterior)::text) AND (((c.calculo = 0) AND (c0.calculo = c.calculo)) OR ((c.calculo > 0) AND (c0.calculo = 0))) AND ((c.producto)::text = (c0.producto)::text) AND ((c.division)::text = (c0.division)::text))))
     LEFT JOIN ( SELECT gru_grupos.grupo
           FROM cvp.gru_grupos
          WHERE (((gru_grupos.agrupacion)::text = 'C'::text) AND ((gru_grupos.grupo_padre)::text = ANY (ARRAY['C1'::text, 'C2'::text])) AND ((gru_grupos.esproducto)::text = 'S'::text))) gg ON (((c.producto)::text = (gg.grupo)::text)))
     LEFT JOIN cvp.calprodresp r ON ((((c.periodo)::text = (r.periodo)::text) AND (c.calculo = r.calculo) AND ((c.producto)::text = (r.producto)::text))));


ALTER TABLE cvp.caldiv_vw OWNER TO cvpowner;

--
-- Name: calobs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calobs (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    division text,
    promobs double precision,
    impobs text NOT NULL,
    antiguedadconprecio integer,
    antiguedadsinprecio integer,
    antiguedadexcluido integer,
    antiguedadincluido integer,
    sindatosestacional integer,
    muestra integer,
    CONSTRAINT "Ambos nulos o no nulos y SinDatosEstacional<=AntiguedadSinPreci" CHECK ((((sindatosestacional IS NULL) AND (antiguedadsinprecio IS NULL)) OR (sindatosestacional <= antiguedadsinprecio) OR (sindatosestacional >= 100))),
    CONSTRAINT "No pueden ser ambos no nulos: AntiguedadIncluido,AntiguedadExcl" CHECK (((antiguedadincluido IS NULL) OR (antiguedadexcluido IS NULL))),
    CONSTRAINT "No pueden ser ambos no nulos: AntiguedadSinPrecio, AntiguedadCo" CHECK (((antiguedadconprecio IS NULL) OR (antiguedadsinprecio IS NULL))),
    CONSTRAINT "texto invalido en division de tabla calobs" CHECK (comun.cadena_valida(division, 'amplio'::text))
);


ALTER TABLE cvp.calobs OWNER TO cvpowner;

--
-- Name: relpre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relpre (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    precio double precision,
    tipoprecio text,
    visita integer DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentariosrelpre text,
    cambio text,
    precionormalizado double precision,
    especificacion integer NOT NULL,
    ultima_visita boolean,
    observaciones text,
    esvisiblecomentarioendm boolean DEFAULT false,
    CONSTRAINT "El precio no puede ser 0 o negativo" CHECK ((precio > (0)::double precision)),
    CONSTRAINT "El valor del campo cambio debe ser C o nulo" CHECK ((cambio = 'C'::text)),
    CONSTRAINT "texto invalido en comentariosrelpre de tabla relpre" CHECK (((periodo < 'a2014m03'::text) OR comun.cadena_valida(comentariosrelpre, 'amplio'::text)))
);


ALTER TABLE cvp.relpre OWNER TO cvpowner;

--
-- Name: caldivsincambio; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.caldivsincambio AS
 SELECT x.periodo,
    x.calculo,
    x.producto,
    x.division,
    x.promdivsincambio,
    x.promdivant,
        CASE
            WHEN ((x.promdivant > (0)::double precision) AND (x.promdivsincambio > (0)::double precision)) THEN round(((((x.promdivsincambio / x.promdivant) * (100)::double precision) - (100)::double precision))::numeric, 1)
            ELSE NULL::numeric
        END AS varsincambio
   FROM ( SELECT c.periodo,
            c.calculo,
            c.producto,
            c.division,
            exp(avg(ln(
                CASE
                    WHEN ((c.promobs > (0)::double precision) AND (c.antiguedadincluido > 0) AND (c0.antiguedadincluido > 0) AND (r.periodo IS NULL)) THEN c.promobs
                    ELSE NULL::double precision
                END))) AS promdivsincambio,
            exp(avg(ln(
                CASE
                    WHEN ((c.promobs > (0)::double precision) AND (c.antiguedadincluido > 0) AND (c0.antiguedadincluido > 0) AND (r.periodo IS NULL)) THEN c0.promobs
                    ELSE NULL::double precision
                END))) AS promdivant
           FROM ((((cvp.calobs c
             LEFT JOIN ( SELECT DISTINCT relpre.periodo,
                    relpre.producto,
                    relpre.observacion,
                    relpre.informante
                   FROM cvp.relpre
                  WHERE ((relpre.cambio)::text = 'C'::text)) r ON ((((c.periodo)::text = (r.periodo)::text) AND ((c.producto)::text = (r.producto)::text) AND (c.observacion = r.observacion) AND (c.informante = r.informante))))
             LEFT JOIN cvp.calculos ca ON ((((c.periodo)::text = (ca.periodo)::text) AND (c.calculo = ca.calculo))))
             LEFT JOIN cvp.calobs c0 ON ((((ca.periodoanterior)::text = (c0.periodo)::text) AND (ca.calculoanterior = c0.calculo) AND ((c.producto)::text = (c0.producto)::text) AND (c.informante = c0.informante) AND (c.observacion = c0.observacion))))
             LEFT JOIN cvp.caldiv d ON ((((c.periodo)::text = (d.periodo)::text) AND (c.calculo = d.calculo) AND ((c.producto)::text = (d.producto)::text) AND ((c.division)::text = (d.division)::text))))
          WHERE ((c.calculo = 0) AND ((c.impobs)::text = ANY (ARRAY['R'::text, 'RA'::text])) AND ((c0.impobs)::text = ANY (ARRAY['R'::text, 'RA'::text])))
          GROUP BY c.periodo, c.calculo, c.producto, c.division) x;


ALTER TABLE cvp.caldivsincambio OWNER TO cvpowner;

--
-- Name: calgru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calgru (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    variacion double precision,
    impgru text,
    valorprel double precision,
    valorgru double precision,
    grupopadre text,
    nivel integer,
    esproducto text,
    ponderador double precision,
    indice double precision,
    indiceprel double precision,
    incidencia double precision,
    indiceredondeado double precision,
    incidenciaredondeada double precision,
    ponderadorimplicito double precision
);


ALTER TABLE cvp.calgru OWNER TO cvpowner;

--
-- Name: calgru_promedios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.calgru_promedios AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo,
    c.variacion,
    c.impgru,
    c.valorprel,
    c.valorgru,
    c.grupopadre,
    c.nivel,
    c.esproducto,
    c.ponderador,
    c.indice,
    c.indiceprel,
    c.incidencia,
    c.indiceredondeado,
    c.incidenciaredondeada,
    c.ponderadorimplicito,
    (((c0.valorgru + c1.valorgru) + c.valorgru) / (3)::double precision) AS valorgrupromedio
   FROM (((cvp.calgru c
     LEFT JOIN cvp.periodos p ON (((c.periodo)::text = (p.periodo)::text)))
     LEFT JOIN cvp.calgru c0 ON ((((c0.periodo)::text = (p.periodoanterior)::text) AND (c.calculo = c0.calculo) AND ((c.agrupacion)::text = (c0.agrupacion)::text) AND ((c.grupo)::text = (c0.grupo)::text))))
     LEFT JOIN cvp.calgru c1 ON ((((c1.periodo)::text = cvp.moverperiodos((c.periodo)::text, 1)) AND (c1.calculo = c.calculo) AND ((c1.agrupacion)::text = (c.agrupacion)::text) AND ((c1.grupo)::text = (c.grupo)::text))))
  WHERE (c.calculo = 0);


ALTER TABLE cvp.calgru_promedios OWNER TO cvpowner;

--
-- Name: calgru_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.calgru_vw AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo,
    COALESCE(g.nombregrupo, p.nombreproducto) AS nombre,
    c.variacion,
    c.impgru,
    c.grupopadre,
    c.nivel,
    c.esproducto,
    c.ponderador,
    c.indice,
    c.indiceprel,
    c.incidencia,
    c.indiceredondeado,
    c.incidenciaredondeada,
    ((((c.indice - cb.indice) * c.ponderador) / pb.indice) * (100)::double precision) AS incidenciainteranual,
        CASE
            WHEN (c.nivel = 0) THEN round(((((((round((c.indice)::numeric, 2) - round((cb.indice)::numeric, 2)))::double precision * c.ponderador) / (round((pb.indice)::numeric, 2))::double precision) * (100)::double precision))::numeric, 1)
            WHEN (c.nivel = 1) THEN round(((((((round((c.indice)::numeric, 2) - round((cb.indice)::numeric, 2)))::double precision * c.ponderador) / (round((pb.indice)::numeric, 2))::double precision) * (100)::double precision))::numeric, 2)
            ELSE NULL::numeric
        END AS incidenciainteranualredondeada,
    ((((c.indice - ca.indice) * c.ponderador) / pa.indice) * (100)::double precision) AS incidenciaacumuladaanual,
    (round((
        CASE
            WHEN (c.nivel = ANY (ARRAY[0, 1])) THEN (((((round((c.indice)::numeric, 2) - round((ca.indice)::numeric, 2)))::double precision * c.ponderador) / (round((pa.indice)::numeric, 2))::double precision) * (100)::double precision)
            ELSE NULL::double precision
        END)::numeric, 2))::double precision AS incidenciaacumuladaanualredondeada,
        CASE
            WHEN (cb.indiceredondeado = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.indiceredondeado)::numeric / (cb.indiceredondeado)::numeric) * (100)::numeric) - (100)::numeric), 1)
        END AS variacioninteranualredondeada,
        CASE
            WHEN (cb.indice = (0)::double precision) THEN NULL::numeric
            ELSE ((((c.indice)::numeric / (cb.indice)::numeric) * (100)::numeric) - (100)::numeric)
        END AS variacioninteranual,
        CASE
            WHEN (c_3.indice = (0)::double precision) THEN NULL::numeric
            ELSE ((((c.indice)::numeric / (c_3.indice)::numeric) * (100)::numeric) - (100)::numeric)
        END AS variaciontrimestral,
        CASE
            WHEN (ca.indiceredondeado = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.indiceredondeado / ca.indiceredondeado) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacionacumuladaanualredondeada,
        CASE
            WHEN (ca.indice = (0)::double precision) THEN NULL::double precision
            ELSE (((c.indice / ca.indice) * (100)::double precision) - (100)::double precision)
        END AS variacionacumuladaanual,
    c.ponderadorimplicito,
    ('Z'::text || substr((c.grupo)::text, 2)) AS ordenpor,
        CASE
            WHEN (gg.grupo IS NOT NULL) THEN true
            ELSE false
        END AS publicado,
    pr.responsable
   FROM ((((((((((cvp.calgru c
     LEFT JOIN cvp.calgru cb ON ((((cb.agrupacion)::text = (c.agrupacion)::text) AND ((cb.grupo)::text = (c.grupo)::text) AND (((c.calculo = 0) AND (cb.calculo = c.calculo)) OR ((c.calculo > 0) AND (cb.calculo = 0))) AND ((cb.periodo)::text = cvp.periodo_igual_mes_anno_anterior((c.periodo)::text)))))
     LEFT JOIN cvp.calgru c_3 ON ((((c_3.agrupacion)::text = (c.agrupacion)::text) AND ((c_3.grupo)::text = (c.grupo)::text) AND (((c.calculo = 0) AND (c_3.calculo = c.calculo)) OR ((c.calculo > 0) AND (c_3.calculo = 0))) AND ((c_3.periodo)::text = cvp.moverperiodos((c.periodo)::text, '-3'::integer)))))
     LEFT JOIN cvp.calgru pb ON (((((c.calculo = 0) AND (pb.calculo = c.calculo)) OR ((c.calculo > 0) AND (pb.calculo = 0))) AND ((pb.agrupacion)::text = (c.agrupacion)::text) AND ((pb.periodo)::text = cvp.periodo_igual_mes_anno_anterior((c.periodo)::text)) AND (pb.nivel = 0))))
     LEFT JOIN cvp.calgru pa ON (((((c.calculo = 0) AND (pa.calculo = c.calculo)) OR ((c.calculo > 0) AND (pa.calculo = 0))) AND ((pa.agrupacion)::text = (c.agrupacion)::text) AND ((pa.periodo)::text = (('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)) AND (pa.nivel = 0))))
     LEFT JOIN cvp.calgru ca ON ((((ca.agrupacion)::text = (c.agrupacion)::text) AND ((ca.grupo)::text = (c.grupo)::text) AND (((c.calculo = 0) AND (ca.calculo = c.calculo)) OR ((c.calculo > 0) AND (ca.calculo = 0))) AND ((ca.periodo)::text = (('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)))))
     JOIN cvp.agrupaciones a ON (((a.agrupacion)::text = (c.agrupacion)::text)))
     LEFT JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
     LEFT JOIN cvp.productos p ON (((c.grupo)::text = (p.producto)::text)))
     LEFT JOIN ( SELECT gru_grupos.grupo
           FROM cvp.gru_grupos
          WHERE (((gru_grupos.agrupacion)::text = 'C'::text) AND ((gru_grupos.grupo_padre)::text = ANY (ARRAY['C1'::text, 'C2'::text])) AND ((gru_grupos.esproducto)::text = 'S'::text))) gg ON (((c.grupo)::text = (gg.grupo)::text)))
     LEFT JOIN cvp.calprodresp pr ON ((((c.periodo)::text = (pr.periodo)::text) AND (c.calculo = pr.calculo) AND ((c.grupo)::text = (pr.producto)::text))))
  WHERE ((a.tipo_agrupacion)::text = 'INDICE'::text);


ALTER TABLE cvp.calgru_vw OWNER TO cvpowner;

--
-- Name: calhoggru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calhoggru (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    hogar text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    valorhoggru double precision,
    coefhoggru double precision
);


ALTER TABLE cvp.calhoggru OWNER TO cvpowner;

--
-- Name: calhogsubtotales; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calhogsubtotales (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    hogar text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    valorhogsub double precision
);


ALTER TABLE cvp.calhogsubtotales OWNER TO cvpowner;

--
-- Name: calobs_periodos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.calobs_periodos AS
 SELECT c.producto,
    c.informante,
    c.observacion,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m01'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m01_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m01'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m01_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m02'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m02_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m02'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m02_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m03'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m03_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m03'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m03_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m04'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m04_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m04'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m04_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m05'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m05_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m05'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m05_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m06'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m06_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m06'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m06_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m07'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m07_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m07'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m07_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m08'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m08_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m08'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m08_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m09'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m09_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m09'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m09_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m10'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m10_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m10'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m10_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m11'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m11_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m11'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m11_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2011m12'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m12_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2011m12'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2011m12_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m01'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m01_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m01'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m01_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m02'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m02_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m02'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m02_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m03'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m03_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m03'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m03_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m04'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m04_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m04'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m04_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m05'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m05_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m05'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m05_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m06'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m06_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m06'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m06_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m07'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m07_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m07'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m07_imp,
    round((avg(
        CASE
            WHEN ((c.periodo)::text = 'a2012m08'::text) THEN c.promobs
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m08_prom,
    max(
        CASE
            WHEN ((c.periodo)::text = 'a2012m08'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || (COALESCE(c.impobs, ''::text))::text) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || (COALESCE(r.tipoprecio, ''::text))::text) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || (COALESCE(r.cambio, ''::text))::text)
            ELSE NULL::text
        END) AS a2012m08_imp
   FROM (cvp.calobs c
     LEFT JOIN cvp.relpre r ON ((((c.periodo)::text = (r.periodo)::text) AND ((c.producto)::text = (r.producto)::text) AND (c.informante = r.informante) AND (c.observacion = r.observacion) AND (r.visita = 1))))
  WHERE (c.calculo = 0)
  GROUP BY c.producto, c.informante, c.observacion
  ORDER BY c.producto, c.informante, c.observacion;


ALTER TABLE cvp.calobs_periodos OWNER TO cvpowner;

--
-- Name: calobs_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.calobs_vw AS
 SELECT calobs.periodo,
    calobs.calculo,
    calobs.producto,
    calobs.informante,
    calobs.observacion,
    calobs.division,
    calobs.promobs,
    calobs.impobs,
    calobs.antiguedadconprecio,
    calobs.antiguedadsinprecio,
    calobs.antiguedadexcluido,
    calobs.antiguedadincluido,
    calobs.sindatosestacional,
    calobs.muestra
   FROM cvp.calobs
  WHERE (calobs.calculo = 0);


ALTER TABLE cvp.calobs_vw OWNER TO cvpowner;

--
-- Name: calprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calprod (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    promprod double precision,
    impprod text,
    valorprod double precision,
    cantincluidos integer,
    promprel double precision,
    valorprel double precision,
    cantaltas integer,
    promaltas double precision,
    cantbajas integer,
    prombajas double precision,
    cantperaltaauto integer,
    cantperbajaauto integer,
    esexternohabitual text,
    imputacon text NOT NULL,
    cantporunidcons double precision,
    unidadmedidaporunidcons text,
    pesovolumenporunidad double precision,
    cantidad numeric,
    unidaddemedida text,
    indice double precision,
    indiceprel double precision,
    CONSTRAINT "texto invalido en unidaddemedida de tabla calprod" CHECK (comun.cadena_valida(unidaddemedida, 'extendido'::text)),
    CONSTRAINT "texto invalido en unidadmedidaporunidcons de tabla calprod" CHECK (comun.cadena_valida(unidadmedidaporunidcons, 'extendido'::text))
);


ALTER TABLE cvp.calprod OWNER TO cvpowner;

--
-- Name: calprodagr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calprodagr (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    agrupacion text NOT NULL,
    cantporunidcons double precision,
    valorprod double precision,
    unidadmedidaporunidcons text,
    cantidad numeric,
    unidaddemedida text,
    pesovolumenporunidad double precision
);


ALTER TABLE cvp.calprodagr OWNER TO cvpowner;

--
-- Name: matrizperiodos6; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.matrizperiodos6 AS
 SELECT p.periodo AS periodo6,
        CASE
            WHEN ((p.periodo)::text = 'a2010m01'::text) THEN NULL::text
            ELSE a.periodo
        END AS periodo5,
        CASE
            WHEN ((p.periodo)::text <= 'a2010m02'::text) THEN NULL::text
            ELSE b.periodo
        END AS periodo4,
        CASE
            WHEN ((p.periodo)::text <= 'a2010m03'::text) THEN NULL::text
            ELSE c.periodo
        END AS periodo3,
        CASE
            WHEN ((p.periodo)::text <= 'a2010m04'::text) THEN NULL::text
            ELSE d.periodo
        END AS periodo2,
        CASE
            WHEN ((p.periodo)::text <= 'a2010m05'::text) THEN NULL::text
            ELSE e.periodo
        END AS periodo1
   FROM (((((cvp.calculos p
     LEFT JOIN cvp.calculos a ON ((((a.periodo)::text = (p.periodoanterior)::text) AND (a.calculo = 0))))
     LEFT JOIN cvp.calculos b ON ((((b.periodo)::text = (a.periodoanterior)::text) AND (b.calculo = 0))))
     LEFT JOIN cvp.calculos c ON ((((c.periodo)::text = (b.periodoanterior)::text) AND (c.calculo = 0))))
     LEFT JOIN cvp.calculos d ON ((((d.periodo)::text = (c.periodoanterior)::text) AND (d.calculo = 0))))
     LEFT JOIN cvp.calculos e ON ((((e.periodo)::text = (d.periodoanterior)::text) AND (e.calculo = 0))))
  WHERE (p.calculo = 0);


ALTER TABLE cvp.matrizperiodos6 OWNER TO cvpowner;

--
-- Name: canasta_alimentaria; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_alimentaria AS
 SELECT
        CASE
            WHEN (((x.agrupacion)::text = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END AS grupo,
    x.nombregrupo,
    round((c1.valorgru)::numeric, 2) AS valorgru1,
    round((c2.valorgru)::numeric, 2) AS valorgru2,
    round((c3.valorgru)::numeric, 2) AS valorgru3,
    round((c4.valorgru)::numeric, 2) AS valorgru4,
    round((c5.valorgru)::numeric, 2) AS valorgru5,
    round((c6.valorgru)::numeric, 2) AS valorgru6,
    c1.periodo AS periodo1,
    c2.periodo AS periodo2,
    c3.periodo AS periodo3,
    c4.periodo AS periodo4,
    c5.periodo AS periodo5,
    c6.periodo AS periodo6,
    x.agrupacion,
    x.calculo,
    x.nivel
   FROM (((((((((cvp.matrizperiodos6 p
     JOIN ( SELECT DISTINCT c.grupo,
            g.nombregrupo,
            c.agrupacion,
            c.calculo,
            c.periodo,
            g.nivel,
            c.agrupacion AS agrupprincipal,
            g.grupopadre
           FROM ((cvp.calgru c
             JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR ((c.periodo)::text >= (a.periodo1)::text)) AND ((c.periodo)::text <= (a.periodo6)::text))))
          WHERE ((c.calculo = 0) AND ((c.agrupacion)::text = ANY (ARRAY['A'::text, 'B'::text])) AND (g.nivel = ANY (ARRAY[2, 3])) AND (substr((g.grupopadre)::text, 1, 2) = ANY (ARRAY['A1'::text, 'B1'::text])))) x ON (((x.periodo)::text = (p.periodo6)::text)))
     LEFT JOIN cvp.calgru c1 ON ((((x.agrupprincipal)::text = (c1.agrupacion)::text) AND ((x.grupo)::text = (c1.grupo)::text) AND ((c1.periodo)::text = (p.periodo1)::text) AND (c1.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c2 ON ((((x.agrupprincipal)::text = (c2.agrupacion)::text) AND ((x.grupo)::text = (c2.grupo)::text) AND ((c2.periodo)::text = (p.periodo2)::text) AND (c2.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c3 ON ((((x.agrupprincipal)::text = (c3.agrupacion)::text) AND ((x.grupo)::text = (c3.grupo)::text) AND ((c3.periodo)::text = (p.periodo3)::text) AND (c3.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c4 ON ((((x.agrupprincipal)::text = (c4.agrupacion)::text) AND ((x.grupo)::text = (c4.grupo)::text) AND ((c4.periodo)::text = (p.periodo4)::text) AND (c4.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c5 ON ((((x.agrupprincipal)::text = (c5.agrupacion)::text) AND ((x.grupo)::text = (c5.grupo)::text) AND ((c5.periodo)::text = (p.periodo5)::text) AND (c5.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c6 ON ((((x.agrupprincipal)::text = (c6.agrupacion)::text) AND ((x.grupo)::text = (c6.grupo)::text) AND ((c6.periodo)::text = (p.periodo6)::text) AND (c6.calculo = x.calculo))))
     LEFT JOIN cvp.periodos p0 ON ((((p0.periodo)::text = (p.periodo1)::text) AND ((p0.periodoanterior)::text <> (p.periodo1)::text))))
     LEFT JOIN cvp.calgru cl0 ON ((((x.agrupacion)::text = (cl0.agrupacion)::text) AND ((x.grupo)::text = (cl0.grupo)::text) AND ((cl0.periodo)::text = (p0.periodoanterior)::text) AND (cl0.calculo = x.calculo))))
  ORDER BY x.agrupacion, c6.periodo, x.nivel,
        CASE
            WHEN (((x.agrupacion)::text = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END;


ALTER TABLE cvp.canasta_alimentaria OWNER TO cvpowner;

--
-- Name: canasta_alimentaria_var; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_alimentaria_var AS
 SELECT
        CASE
            WHEN (((x.agrupacion)::text = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END AS grupo,
    x.nombregrupo,
    round((c0.valorgru)::numeric, 2) AS valorgruant,
    round((c.valorgru)::numeric, 2) AS valorgru,
    round((c.variacion)::numeric, 1) AS variacion,
        CASE
            WHEN (ca.valorgru = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorgru / ca.valorgru) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorgru = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorgru / cm.valorgru) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacionmesanioanterior,
    x.agrupacion,
    x.calculo,
    x.periodo,
    c0.calculo AS calculoant,
    c0.periodo AS periodoant,
    ca.periodo AS periododiciembre,
    cm.periodo AS periodoaniooanterior,
    x.nivel
   FROM ((((( SELECT DISTINCT c_1.grupo,
            g.nombregrupo,
            c_1.agrupacion,
            c_1.calculo,
            c_1.periodo,
            g.nivel,
            c_1.agrupacion AS agrupprincipal,
            p.calculoanterior,
            p.periodoanterior,
            g.grupopadre
           FROM ((cvp.calgru c_1
             JOIN cvp.grupos g ON ((((c_1.agrupacion)::text = (g.agrupacion)::text) AND ((c_1.grupo)::text = (g.grupo)::text))))
             JOIN cvp.calculos p ON ((((c_1.periodo)::text = (p.periodo)::text) AND ('A'::text = (p.agrupacionprincipal)::text) AND (0 = p.calculo))))
          WHERE ((c_1.calculo = 0) AND ((c_1.agrupacion)::text = ANY (ARRAY['A'::text, 'B'::text])) AND (g.nivel = ANY (ARRAY[2, 3])) AND (substr((g.grupopadre)::text, 1, 2) = ANY (ARRAY['A1'::text, 'B1'::text])))) x
     LEFT JOIN cvp.calgru c ON ((((x.agrupprincipal)::text = (c.agrupacion)::text) AND ((x.grupo)::text = (c.grupo)::text) AND (c.calculo = x.calculo) AND ((c.periodo)::text = (x.periodo)::text))))
     LEFT JOIN cvp.calgru c0 ON ((((x.agrupprincipal)::text = (c0.agrupacion)::text) AND ((x.grupo)::text = (c0.grupo)::text) AND (c0.calculo = x.calculoanterior) AND ((c0.periodo)::text = (x.periodoanterior)::text))))
     LEFT JOIN cvp.calgru ca ON ((((x.agrupprincipal)::text = (ca.agrupacion)::text) AND ((x.grupo)::text = (ca.grupo)::text) AND (ca.calculo = x.calculo) AND ((ca.periodo)::text = (('a'::text || ((substr((x.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calgru cm ON ((((x.agrupprincipal)::text = (cm.agrupacion)::text) AND ((x.grupo)::text = (cm.grupo)::text) AND (cm.calculo = x.calculo) AND ((cm.periodo)::text = ((('a'::text || ((substr((x.periodo)::text, 2, 4))::integer - 1)) || 'm'::text) || substr((x.periodo)::text, 7, 2))))))
  ORDER BY x.agrupacion, x.periodo, x.nivel,
        CASE
            WHEN (((x.agrupacion)::text = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END;


ALTER TABLE cvp.canasta_alimentaria_var OWNER TO cvpowner;

--
-- Name: canasta_consumo; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_consumo AS
 SELECT x.hogar,
        CASE
            WHEN (x.nivel = 1) THEN (((x.grupo)::text || 'X'::text))::text
            ELSE x.grupo
        END AS grupo,
    x.nombre,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s1.valorhogsub
            ELSE c1.valorhoggru
        END)::numeric, 2) AS valorgru1,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s2.valorhogsub
            ELSE c2.valorhoggru
        END)::numeric, 2) AS valorgru2,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s3.valorhogsub
            ELSE c3.valorhoggru
        END)::numeric, 2) AS valorgru3,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s4.valorhogsub
            ELSE c4.valorhoggru
        END)::numeric, 2) AS valorgru4,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s5.valorhogsub
            ELSE c5.valorhoggru
        END)::numeric, 2) AS valorgru5,
    round((
        CASE
            WHEN (x.nivel = 1) THEN s6.valorhogsub
            ELSE c6.valorhoggru
        END)::numeric, 2) AS valorgru6,
        CASE
            WHEN (x.nivel = 1) THEN s1.periodo
            ELSE c1.periodo
        END AS periodo1,
        CASE
            WHEN (x.nivel = 1) THEN s2.periodo
            ELSE c2.periodo
        END AS periodo2,
        CASE
            WHEN (x.nivel = 1) THEN s3.periodo
            ELSE c3.periodo
        END AS periodo3,
        CASE
            WHEN (x.nivel = 1) THEN s4.periodo
            ELSE c4.periodo
        END AS periodo4,
        CASE
            WHEN (x.nivel = 1) THEN s5.periodo
            ELSE c5.periodo
        END AS periodo5,
        CASE
            WHEN (x.nivel = 1) THEN s6.periodo
            ELSE c6.periodo
        END AS periodo6,
    x.agrupacion,
    x.nivel,
    x.calculo
   FROM (((((((((((((((cvp.matrizperiodos6 p
     JOIN ( SELECT c.grupo,
            c.hogar,
            g.nombregrupo AS nombre,
            c.agrupacion,
            c.calculo,
            a.periodo6,
            g.nivel
           FROM ((cvp.calhoggru c
             JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR ((c.periodo)::text >= (a.periodo1)::text)) AND ((c.periodo)::text <= (a.periodo6)::text))))
          WHERE ((c.calculo = 0) AND ((g.nivel = 2) AND (substr((g.grupopadre)::text, 1, 2) <> ALL (ARRAY['A1'::text, 'B1'::text]))))
        UNION
         SELECT c.grupo,
            c.hogar,
            g.nombrecanasta AS nombre,
            c.agrupacion,
            c.calculo,
            a.periodo6,
            g.nivel
           FROM ((cvp.calhogsubtotales c
             JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR ((c.periodo)::text >= (a.periodo1)::text)) AND ((c.periodo)::text <= (a.periodo6)::text))))
          WHERE ((c.calculo = 0) AND (g.nivel = 1))
          GROUP BY c.grupo, c.hogar, g.nombrecanasta, c.agrupacion, c.calculo, a.periodo6, g.nivel) x ON (((x.periodo6)::text = (p.periodo6)::text)))
     LEFT JOIN cvp.calhoggru c1 ON ((((x.agrupacion)::text = (c1.agrupacion)::text) AND ((x.grupo)::text = (c1.grupo)::text) AND ((x.hogar)::text = (c1.hogar)::text) AND ((c1.periodo)::text = (p.periodo1)::text) AND (c1.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c2 ON ((((x.agrupacion)::text = (c2.agrupacion)::text) AND ((x.grupo)::text = (c2.grupo)::text) AND ((x.hogar)::text = (c2.hogar)::text) AND ((c2.periodo)::text = (p.periodo2)::text) AND (c2.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c3 ON ((((x.agrupacion)::text = (c3.agrupacion)::text) AND ((x.grupo)::text = (c3.grupo)::text) AND ((x.hogar)::text = (c3.hogar)::text) AND ((c3.periodo)::text = (p.periodo3)::text) AND (c3.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c4 ON ((((x.agrupacion)::text = (c4.agrupacion)::text) AND ((x.grupo)::text = (c4.grupo)::text) AND ((x.hogar)::text = (c4.hogar)::text) AND ((c4.periodo)::text = (p.periodo4)::text) AND (c4.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c5 ON ((((x.agrupacion)::text = (c5.agrupacion)::text) AND ((x.grupo)::text = (c5.grupo)::text) AND ((x.hogar)::text = (c5.hogar)::text) AND ((c5.periodo)::text = (p.periodo5)::text) AND (c5.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c6 ON ((((x.agrupacion)::text = (c6.agrupacion)::text) AND ((x.grupo)::text = (c6.grupo)::text) AND ((x.hogar)::text = (c6.hogar)::text) AND ((c6.periodo)::text = (p.periodo6)::text) AND (c6.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhogsubtotales s1 ON ((((x.agrupacion)::text = (s1.agrupacion)::text) AND ((x.grupo)::text = (s1.grupo)::text) AND ((x.hogar)::text = (s1.hogar)::text) AND ((s1.periodo)::text = (p.periodo1)::text) AND (s1.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s2 ON ((((x.agrupacion)::text = (s2.agrupacion)::text) AND ((x.grupo)::text = (s2.grupo)::text) AND ((x.hogar)::text = (s2.hogar)::text) AND ((s2.periodo)::text = (p.periodo2)::text) AND (s2.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s3 ON ((((x.agrupacion)::text = (s3.agrupacion)::text) AND ((x.grupo)::text = (s3.grupo)::text) AND ((x.hogar)::text = (s3.hogar)::text) AND ((s3.periodo)::text = (p.periodo3)::text) AND (s3.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s4 ON ((((x.agrupacion)::text = (s4.agrupacion)::text) AND ((x.grupo)::text = (s4.grupo)::text) AND ((x.hogar)::text = (s4.hogar)::text) AND ((s4.periodo)::text = (p.periodo4)::text) AND (s4.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s5 ON ((((x.agrupacion)::text = (s5.agrupacion)::text) AND ((x.grupo)::text = (s5.grupo)::text) AND ((x.hogar)::text = (s5.hogar)::text) AND ((s5.periodo)::text = (p.periodo5)::text) AND (s5.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s6 ON ((((x.agrupacion)::text = (s6.agrupacion)::text) AND ((x.grupo)::text = (s6.grupo)::text) AND ((x.hogar)::text = (s6.hogar)::text) AND ((s6.periodo)::text = (p.periodo6)::text) AND (s6.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.periodos p0 ON ((((p0.periodo)::text = (p.periodo1)::text) AND ((p0.periodoanterior)::text <> (p.periodo1)::text))))
     LEFT JOIN cvp.calhoggru cl0 ON ((((x.agrupacion)::text = (cl0.agrupacion)::text) AND ((x.grupo)::text = (cl0.grupo)::text) AND ((x.hogar)::text = (cl0.hogar)::text) AND ((cl0.periodo)::text = (p0.periodoanterior)::text) AND (cl0.calculo = x.calculo))))
  ORDER BY x.agrupacion,
        CASE
            WHEN (x.nivel = 1) THEN s6.periodo
            ELSE c6.periodo
        END, x.hogar,
        CASE
            WHEN (x.nivel = 1) THEN (((x.grupo)::text || 'X'::text))::text
            ELSE x.grupo
        END;


ALTER TABLE cvp.canasta_consumo OWNER TO cvpowner;

--
-- Name: canasta_consumo_var; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_consumo_var AS
 SELECT c.hogar,
    c.grupo,
    g.nombregrupo AS nombre,
    round((c0.valorhoggru)::numeric, 2) AS valorgruant,
    round((c.valorhoggru)::numeric, 2) AS valorhg,
        CASE
            WHEN (c0.valorhoggru = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhoggru / c0.valorhoggru) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacion,
        CASE
            WHEN (ca.valorhoggru = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhoggru / ca.valorhoggru) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorhoggru = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhoggru / cm.valorhoggru) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacionmesanioanterior,
    c.agrupacion,
    c.calculo,
    c.periodo,
    c0.calculo AS calculoant,
    c0.periodo AS periodoant,
    ca.periodo AS periododiciembre,
    cm.periodo AS periodoaniooanterior,
    g.nivel
   FROM (((((cvp.calhoggru c
     JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
     JOIN cvp.calculos p ON ((((c.periodo)::text = (p.periodo)::text) AND ('A'::text = (p.agrupacionprincipal)::text) AND (0 = p.calculo))))
     JOIN cvp.calhoggru c0 ON ((((c.agrupacion)::text = (c0.agrupacion)::text) AND ((c.hogar)::text = (c0.hogar)::text) AND ((c.grupo)::text = (c0.grupo)::text) AND (c0.calculo = p.calculoanterior) AND ((c0.periodo)::text = (p.periodoanterior)::text))))
     LEFT JOIN cvp.calhoggru ca ON ((((c.agrupacion)::text = (ca.agrupacion)::text) AND ((c.hogar)::text = (ca.hogar)::text) AND ((c.grupo)::text = (ca.grupo)::text) AND (c.calculo = ca.calculo) AND ((ca.periodo)::text = (('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calhoggru cm ON ((((c.agrupacion)::text = (cm.agrupacion)::text) AND ((c.hogar)::text = (cm.hogar)::text) AND ((c.grupo)::text = (cm.grupo)::text) AND (c.calculo = cm.calculo) AND ((cm.periodo)::text = ((('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm'::text) || substr((c.periodo)::text, 7, 2))))))
  WHERE ((c.calculo = 0) AND ((g.nivel = 2) AND (substr((g.grupopadre)::text, 1, 2) <> ALL (ARRAY['A1'::text, 'B1'::text]))))
UNION
 SELECT c.hogar,
    ((c.grupo)::text || 'X'::text) AS grupo,
    g.nombrecanasta AS nombre,
    round((c0.valorhogsub)::numeric, 2) AS valorgruant,
    round((c.valorhogsub)::numeric, 2) AS valorhg,
        CASE
            WHEN (c0.valorhogsub = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhogsub / c0.valorhogsub) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacion,
        CASE
            WHEN (ca.valorhogsub = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhogsub / ca.valorhogsub) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorhogsub = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.valorhogsub / cm.valorhogsub) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacionmesanioanterior,
    c.agrupacion,
    c.calculo,
    c.periodo,
    c0.calculo AS calculoant,
    c0.periodo AS periodoant,
    ca.periodo AS periododiciembre,
    cm.periodo AS periodoaniooanterior,
    g.nivel
   FROM (((((cvp.calhogsubtotales c
     JOIN cvp.grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
     JOIN cvp.calculos p ON ((((c.periodo)::text = (p.periodo)::text) AND ('A'::text = (p.agrupacionprincipal)::text) AND (0 = p.calculo))))
     JOIN cvp.calhogsubtotales c0 ON ((((c.agrupacion)::text = (c0.agrupacion)::text) AND ((c.hogar)::text = (c0.hogar)::text) AND ((c.grupo)::text = (c0.grupo)::text) AND (c0.calculo = p.calculoanterior) AND ((c0.periodo)::text = (p.periodoanterior)::text))))
     LEFT JOIN cvp.calhogsubtotales ca ON ((((c.agrupacion)::text = (ca.agrupacion)::text) AND ((c.hogar)::text = (ca.hogar)::text) AND ((c.grupo)::text = (ca.grupo)::text) AND (c.calculo = ca.calculo) AND ((ca.periodo)::text = (('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calhogsubtotales cm ON ((((c.agrupacion)::text = (cm.agrupacion)::text) AND ((c.hogar)::text = (cm.hogar)::text) AND ((c.grupo)::text = (cm.grupo)::text) AND (c.calculo = cm.calculo) AND ((cm.periodo)::text = ((('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm'::text) || substr((c.periodo)::text, 7, 2))))))
  WHERE ((c.calculo = 0) AND (g.nivel = 1))
  ORDER BY 9, 11, 1, 2;


ALTER TABLE cvp.canasta_consumo_var OWNER TO cvpowner;

--
-- Name: hogparagr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.hogparagr (
    parametro text NOT NULL,
    hogar text NOT NULL,
    coefhogpar double precision NOT NULL,
    agrupacion text NOT NULL
);


ALTER TABLE cvp.hogparagr OWNER TO cvpowner;

--
-- Name: parhog; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.parhog (
    parametro text NOT NULL,
    nombreparametro text NOT NULL,
    CONSTRAINT "texto invalido en nombreparametro de tabla parhog" CHECK (comun.cadena_valida(nombreparametro, 'amplio'::text)),
    CONSTRAINT "texto invalido en parametro de tabla parhog" CHECK (comun.cadena_valida(parametro, 'castellano'::text))
);


ALTER TABLE cvp.parhog OWNER TO cvpowner;

--
-- Name: parhoggru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.parhoggru (
    parametro text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL
);


ALTER TABLE cvp.parhoggru OWNER TO cvpowner;

--
-- Name: prodagr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prodagr (
    producto text NOT NULL,
    agrupacion text NOT NULL,
    cantporunidcons double precision
);


ALTER TABLE cvp.prodagr OWNER TO cvpowner;

--
-- Name: canasta_producto; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_producto AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo AS producto,
    p.nombreproducto,
    c.valorgru AS valorprod,
    c.grupopadre,
    g.grupo_padre AS grupoparametro,
    string_agg((ph.parametro)::text, ', '::text) AS parametro,
    string_agg((o.nombreparametro)::text, ', '::text) AS nombreparametro,
    hp.hogar,
        CASE
            WHEN (min(COALESCE(abs(hp.coefhogpar))) > (0)::double precision) THEN exp(sum(ln(NULLIF(hp.coefhogpar, (0)::double precision))))
            ELSE (0)::double precision
        END AS coefhoggru,
    (c.valorgru *
        CASE
            WHEN (min(COALESCE(abs(hp.coefhogpar))) > (0)::double precision) THEN exp(sum(ln(NULLIF(hp.coefhogpar, (0)::double precision))))
            ELSE (0)::double precision
        END) AS valorhogprod,
    substr((c.grupo)::text, 2, 2) AS divisioncanasta,
    a.agrupo1,
    a.agrupo2,
    a.agrupo3,
    a.agrupo4,
    b.bgrupo0,
    b.bgrupo1,
    b.bgrupo2,
    b.bgrupo3,
    b.bgrupo4
   FROM ((((((((cvp.calgru c
     LEFT JOIN cvp.gru_grupos g ON ((((c.agrupacion)::text = (g.agrupacion)::text) AND ((c.grupo)::text = (g.grupo)::text))))
     LEFT JOIN cvp.productos p ON (((c.grupo)::text = (p.producto)::text)))
     LEFT JOIN cvp.prodagr ag ON ((((c.agrupacion)::text = (ag.agrupacion)::text) AND ((p.producto)::text = (ag.producto)::text))))
     JOIN cvp.parhoggru ph ON ((((c.agrupacion)::text = (ph.agrupacion)::text) AND ((g.grupo_padre)::text = (ph.grupo)::text))))
     LEFT JOIN cvp.hogparagr hp ON ((((ph.parametro)::text = (hp.parametro)::text) AND ((ph.agrupacion)::text = (hp.agrupacion)::text))))
     LEFT JOIN cvp.parhog o ON (((ph.parametro)::text = (o.parametro)::text)))
     LEFT JOIN ( SELECT g_1.agrupacion,
            g_1.grupo AS agrupo0,
            g4.grupo AS agrupo4,
            g3.grupo AS agrupo3,
            g2.grupo AS agrupo2,
            g1.grupo AS agrupo1
           FROM ((((cvp.grupos g_1
             JOIN cvp.grupos g4 ON ((((g_1.grupopadre)::text = (g4.grupo)::text) AND ((g_1.agrupacion)::text = (g4.agrupacion)::text) AND ((g4.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g3 ON ((((g4.grupopadre)::text = (g3.grupo)::text) AND ((g_1.agrupacion)::text = (g4.agrupacion)::text) AND ((g3.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g2 ON ((((g3.grupopadre)::text = (g2.grupo)::text) AND ((g_1.agrupacion)::text = (g4.agrupacion)::text) AND ((g2.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g1 ON ((((g2.grupopadre)::text = (g1.grupo)::text) AND ((g_1.agrupacion)::text = (g4.agrupacion)::text) AND ((g1.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])))))
          WHERE (((g_1.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])) AND (g_1.nivel = 5))) a ON ((((c.grupo)::text = (a.agrupo0)::text) AND ((c.agrupacion)::text = (a.agrupacion)::text))))
     LEFT JOIN ( SELECT g_1.grupo AS bgrupo0,
            g4.grupo AS bgrupo4,
            g3.grupo AS bgrupo3,
            g2.grupo AS bgrupo2,
            g1.grupo AS bgrupo1
           FROM ((((cvp.grupos g_1
             JOIN cvp.grupos g4 ON ((((g_1.grupopadre)::text = (g4.grupo)::text) AND ((g4.agrupacion)::text = 'B'::text))))
             JOIN cvp.grupos g3 ON ((((g4.grupopadre)::text = (g3.grupo)::text) AND ((g3.agrupacion)::text = 'B'::text))))
             JOIN cvp.grupos g2 ON ((((g3.grupopadre)::text = (g2.grupo)::text) AND ((g2.agrupacion)::text = 'B'::text))))
             JOIN cvp.grupos g1 ON ((((g2.grupopadre)::text = (g1.grupo)::text) AND ((g1.agrupacion)::text = 'B'::text))))
          WHERE (((g_1.agrupacion)::text = 'B'::text) AND (g_1.nivel = 4))) b ON (((g.grupo_padre)::text = (b.bgrupo0)::text)))
  WHERE ((c.calculo = 0) AND ((c.agrupacion)::text = ANY (ARRAY['A'::text, 'D'::text])) AND ((g.esproducto)::text = 'S'::text) AND (ag.cantporunidcons > (0)::double precision) AND (c.valorgru IS NOT NULL))
  GROUP BY c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar, a.agrupo1, a.agrupo2, a.agrupo3, a.agrupo4, b.bgrupo0, b.bgrupo1, b.bgrupo2, b.bgrupo3, b.bgrupo4
  ORDER BY c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar, a.agrupo1, a.agrupo2, a.agrupo3, a.agrupo4, b.bgrupo0, b.bgrupo1, b.bgrupo2, b.bgrupo3, b.bgrupo4;


ALTER TABLE cvp.canasta_producto OWNER TO cvpowner;

--
-- Name: conjuntomuestral; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.conjuntomuestral (
    conjuntomuestral integer NOT NULL,
    panel integer,
    encuestador text,
    tiponegociomuestra integer
);


ALTER TABLE cvp.conjuntomuestral OWNER TO cvpowner;

--
-- Name: TABLE conjuntomuestral; Type: COMMENT; Schema: cvp; Owner: cvpowner
--

COMMENT ON TABLE cvp.conjuntomuestral IS 'Conjuntos Muestrales de Informantes de donde se elegirán reemplazantes';


--
-- Name: conjuntomuestral_conjuntomuestral_seq; Type: SEQUENCE; Schema: cvp; Owner: cvpowner
--

CREATE SEQUENCE cvp.conjuntomuestral_conjuntomuestral_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cvp.conjuntomuestral_conjuntomuestral_seq OWNER TO cvpowner;

--
-- Name: conjuntomuestral_conjuntomuestral_seq; Type: SEQUENCE OWNED BY; Schema: cvp; Owner: cvpowner
--

ALTER SEQUENCE cvp.conjuntomuestral_conjuntomuestral_seq OWNED BY cvp.conjuntomuestral.conjuntomuestral;


--
-- Name: informantes; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.informantes (
    informante integer DEFAULT cvp.proximonumeroinformante() NOT NULL,
    nombreinformante text,
    tipoinformante text NOT NULL,
    rubroclanae text,
    cadena text,
    direccion text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    altamanualperiodo text,
    altamanualpanel integer,
    altamanualtarea integer,
    altamanualconfirmar timestamp without time zone,
    razonsocial text,
    nombrecalle text,
    altura text,
    piso text,
    departamento text,
    cuit numeric(11,0),
    naecba numeric(9,0),
    totalpers numeric(3,0),
    cp text,
    distrito integer,
    fraccion integer,
    radio numeric(2,0),
    manzana numeric(3,0),
    lado numeric(1,0),
    obs_listador text,
    nr_listador character(1),
    fecha_listado date,
    grupo_listado text,
    conjuntomuestral integer,
    rubro integer NOT NULL,
    ordenhdr integer DEFAULT 100 NOT NULL,
    cue numeric(6,0),
    idlocal numeric(2,0),
    muestra integer DEFAULT 1 NOT NULL,
    contacto text,
    telcontacto text,
    estado text DEFAULT 'No usado'::text,
    CONSTRAINT "Estado: No usado, Nuevo, Activo, Inactivo" CHECK ((estado = ANY (ARRAY['No usado'::text, 'Nuevo'::text, 'Activo'::text, 'Inactivo'::text]))),
    CONSTRAINT "Muestra 1: muestra vieja; 2:muestra nueva" CHECK ((muestra = ANY (ARRAY[1, 2]))),
    CONSTRAINT "el código postal debe estar escrito en mayúscula" CHECK ((cp = upper((cp)::text))),
    CONSTRAINT "el informante debe ser positivo y tener 6 dígitos o menos" CHECK (((informante <= 999999) AND (informante > 0))),
    CONSTRAINT "el ordenhdr debe ser positivo ó 0" CHECK ((ordenhdr >= 0)),
    CONSTRAINT "texto invalido en altura de tabla informantes" CHECK (comun.cadena_valida(altura, 'extendido'::text)),
    CONSTRAINT "texto invalido en contacto de tabla informantes" CHECK (comun.cadena_valida(contacto, 'amplio'::text)),
    CONSTRAINT "texto invalido en cp de tabla informantes" CHECK (comun.cadena_valida(cp, 'codigo'::text)),
    CONSTRAINT "texto invalido en departamento de tabla informantes" CHECK (comun.cadena_valida(departamento, 'codigo'::text)),
    CONSTRAINT "texto invalido en direccion de tabla informantes" CHECK (comun.cadena_valida(direccion, 'amplio'::text)),
    CONSTRAINT "texto invalido en nombrecalle de tabla informantes" CHECK (comun.cadena_valida(nombrecalle, 'amplio'::text)),
    CONSTRAINT "texto invalido en nombreinformante de tabla informantes" CHECK (comun.cadena_valida(nombreinformante, 'amplio'::text)),
    CONSTRAINT "texto invalido en obs_listador de tabla informantes" CHECK (comun.cadena_valida(obs_listador, 'amplio'::text)),
    CONSTRAINT "texto invalido en piso de tabla informantes" CHECK (comun.cadena_valida(piso, 'amplio'::text)),
    CONSTRAINT "texto invalido en razonsocial de tabla informantes" CHECK (comun.cadena_valida(razonsocial, 'amplio'::text)),
    CONSTRAINT "texto invalido en telcontacto de tabla informantes" CHECK (comun.cadena_valida(telcontacto, 'amplio'::text))
);


ALTER TABLE cvp.informantes OWNER TO cvpowner;

--
-- Name: relvis; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relvis (
    periodo text NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    fechasalida date,
    fechaingreso date,
    ingresador text,
    razon integer,
    fechageneracion timestamp without time zone,
    visita integer DEFAULT 1 NOT NULL,
    ultimavisita integer DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentarios text,
    encuestador text,
    supervisor text,
    recepcionista text,
    informantereemplazante integer,
    ultima_visita boolean,
    verificado_rec text DEFAULT 'N'::text,
    CONSTRAINT "Visita mayor o igual que 1" CHECK ((visita >= 1)),
    CONSTRAINT "texto invalido en comentarios de tabla relvis" CHECK (comun.cadena_valida(comentarios, 'amplio'::text))
);


ALTER TABLE cvp.relvis OWNER TO cvpowner;

--
-- Name: control_ajustes; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_ajustes AS
 SELECT per.periodo,
    rv.panel,
    rv.tarea,
    rp.informante,
    i.tipoinformante,
    rp.visita,
    rp.formulario,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 1) AS grupo_padre_1,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 2) AS nombregrupo_1,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 3) AS grupo_padre_2,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 4) AS nombregrupo_2,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 5) AS grupo_padre_3,
    split_part(string_agg((((gg_1.grupo_padre)::text || '|'::text) || (g_1.nombregrupo)::text), '|'::text ORDER BY g_1.nivel), '|'::text, 6) AS nombregrupo_3,
    rp.producto,
    p.nombreproducto,
    rp.observacion,
    rp.precionormalizado,
    rp.tipoprecio,
    rp.cambio,
    (((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision) AS variacion_1,
    sign((((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision)) AS varia_1,
    rp_1.precionormalizado AS precionormalizado_1,
    rp_1.tipoprecio AS tipoprecio_1,
    rp_1.cambio AS cambio_1,
    (((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision) AS variacion_2,
    sign((((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision)) AS varia_2,
    rp_2.precionormalizado AS precionormalizado_2,
    rp_2.tipoprecio AS tipoprecio_2,
    rp_2.cambio AS cambio_2,
    ((COALESCE((sign((((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision)))::text, 'N'::text) || '_'::text) || COALESCE((sign((((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision)))::text, 'N'::text)) AS varia_ambos
   FROM ((((((((( SELECT periodos.periodo,
            periodos.periodoanterior,
            cvp.moverperiodos((periodos.periodoanterior)::text, '-1'::integer) AS periodoanterioranterior
           FROM cvp.periodos
          WHERE ((periodos.ingresando)::text = 'S'::text)) per
     LEFT JOIN cvp.relpre rp ON (((per.periodo)::text = (rp.periodo)::text)))
     LEFT JOIN cvp.relvis rv ON ((((rv.periodo)::text = (rp.periodo)::text) AND (rv.informante = rp.informante) AND (rv.visita = rp.visita) AND (rv.formulario = rp.formulario))))
     LEFT JOIN cvp.productos p USING (producto))
     LEFT JOIN cvp.informantes i ON ((rp.informante = i.informante)))
     LEFT JOIN cvp.relpre rp_1 ON ((((rp_1.periodo)::text = (per.periodoanterior)::text) AND ((rp_1.producto)::text = (rp.producto)::text) AND (rp_1.observacion = rp.observacion) AND (rp_1.informante = rp.informante) AND (rp_1.visita = rp.visita))))
     LEFT JOIN cvp.relpre rp_2 ON ((((rp_2.periodo)::text = per.periodoanterioranterior) AND ((rp_2.producto)::text = (rp.producto)::text) AND (rp_2.observacion = rp.observacion) AND (rp_2.informante = rp.informante) AND (rp_2.visita = rp.visita))))
     LEFT JOIN cvp.gru_grupos gg_1 ON (((rp.producto)::text = (gg_1.grupo)::text)))
     LEFT JOIN cvp.grupos g_1 ON (((gg_1.grupo_padre)::text = (g_1.grupo)::text)))
  WHERE (((gg_1.agrupacion)::text = 'Z'::text) AND ((gg_1.esproducto)::text = 'S'::text) AND (g_1.nivel = ANY (ARRAY[1, 2, 3])))
  GROUP BY per.periodo, rv.panel, rv.tarea, rp.informante, i.tipoinformante, rp.visita, rp.formulario, rp.producto, p.nombreproducto, rp.observacion, rp.precionormalizado, rp.tipoprecio, rp.cambio, (((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision), (sign((((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision))), rp_1.precionormalizado, rp_1.tipoprecio, rp_1.cambio, (((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision), (sign((((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision))), rp_2.precionormalizado, rp_2.tipoprecio, rp_2.cambio, ((COALESCE((sign((((rp.precionormalizado / rp_1.precionormalizado) * (100.0)::double precision) - (100)::double precision)))::text, 'N'::text) || '_'::text) || COALESCE((sign((((rp_1.precionormalizado / rp_2.precionormalizado) * (100.0)::double precision) - (100)::double precision)))::text, 'N'::text));


ALTER TABLE cvp.control_ajustes OWNER TO cvpowner;

--
-- Name: personal; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.personal (
    persona text NOT NULL,
    labor text NOT NULL,
    nombre text,
    apellido text,
    username text,
    activo text DEFAULT 'S'::text NOT NULL,
    super_labor text DEFAULT 'N'::text,
    ipad text,
    id_instalacion integer,
    CONSTRAINT "Activo= S (Activo); N (Inactivo)" CHECK ((activo = ANY (ARRAY['S'::text, 'N'::text]))),
    CONSTRAINT "Labor= E(Enc);S(Sup);R(Recep);I(Ingre);A(Anali);C(Coord)" CHECK ((labor = ANY (ARRAY['E'::text, 'S'::text, 'R'::text, 'I'::text, 'A'::text, 'C'::text]))),
    CONSTRAINT "Super_labor debe ser S (Si) o N (No) o P (Parcial)" CHECK ((super_labor = ANY (ARRAY['S'::text, 'N'::text, 'P'::text]))),
    CONSTRAINT "texto invalido en apellido de tabla personal" CHECK (comun.cadena_valida(apellido, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombre de tabla personal" CHECK (comun.cadena_valida(nombre, 'castellano'::text))
);


ALTER TABLE cvp.personal OWNER TO cvpowner;

--
-- Name: control_anulados_recep; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_anulados_recep AS
 SELECT r.periodo,
    r.producto,
    p.nombreproducto,
    r.informante,
    r.observacion,
    r.visita,
    v.panel,
    v.tarea,
    (((v.encuestador)::text || ':'::text) || (e.apellido)::text) AS encuestador,
    v.recepcionista,
    v.formulario,
    r.comentariosrelpre
   FROM (((cvp.relpre r
     LEFT JOIN cvp.productos p ON (((r.producto)::text = (p.producto)::text)))
     LEFT JOIN cvp.relvis v ON ((((r.periodo)::text = (v.periodo)::text) AND (r.informante = v.informante) AND (r.visita = v.visita) AND (r.formulario = v.formulario))))
     LEFT JOIN cvp.personal e ON (((v.encuestador)::text = (e.persona)::text)))
  WHERE ((r.tipoprecio)::text = 'A'::text);


ALTER TABLE cvp.control_anulados_recep OWNER TO cvpowner;

--
-- Name: prodatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prodatr (
    producto text NOT NULL,
    atributo integer NOT NULL,
    valornormal double precision,
    orden integer NOT NULL,
    normalizable text DEFAULT 'N'::text,
    tiponormalizacion text,
    alterable text DEFAULT 'N'::text,
    prioridad integer,
    operacion text,
    rangodesde double precision,
    rangohasta double precision,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    orden_calculo_especial integer,
    tipo_promedio text,
    esprincipal text DEFAULT 'N'::text,
    visiblenombreatributo text DEFAULT 'N'::text NOT NULL,
    otraunidaddemedida text,
    opciones text DEFAULT 'N'::text NOT NULL,
    CONSTRAINT "Opciones debe ser N (No), A (Abierta) o C (Cerrada)" CHECK ((opciones = ANY (ARRAY['N'::text, 'C'::text, 'A'::text]))),
    CONSTRAINT "texto invalido en tipo_promedio de tabla prodatr" CHECK (comun.cadena_valida(tipo_promedio, 'castellano'::text))
);


ALTER TABLE cvp.prodatr OWNER TO cvpowner;

--
-- Name: relatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relatr (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    atributo integer NOT NULL,
    valor text,
    visita integer DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    validar_con_valvalatr boolean,
    CONSTRAINT "El valor de Validar_con_ValValAtr debe ser TRUE o nulo" CHECK (validar_con_valvalatr),
    CONSTRAINT "no se puede poner el sombrero en el atributo" CHECK ((valor !~~ '%~%'::text)),
    CONSTRAINT "texto invalido en valor de tabla relatr" CHECK (((periodo < 'a2013m12'::text) OR comun.cadena_valida((valor)::text, 'amplio'::text)))
);


ALTER TABLE cvp.relatr OWNER TO cvpowner;

--
-- Name: tipopre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tipopre (
    tipoprecio text NOT NULL,
    nombretipoprecio text,
    espositivo text DEFAULT 'N'::text NOT NULL,
    visibleparaencuestador text DEFAULT 'S'::text NOT NULL,
    registrablanqueo boolean DEFAULT false NOT NULL,
    activo text DEFAULT 'S'::text,
    puedecopiar text DEFAULT 'N'::text,
    orden integer,
    CONSTRAINT "texto invalido en nombretipoprecio de tabla tipopre" CHECK (comun.cadena_valida(nombretipoprecio, 'castellano'::text))
);


ALTER TABLE cvp.tipopre OWNER TO cvpowner;

--
-- Name: control_atributos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_atributos AS
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    vi.formulario,
    v.informante,
    v.observacion,
    v.visita,
    vi.panel,
    vi.tarea,
    vi.encuestador,
    vi.recepcionista,
    ((((((((('Valor Normal '::text || pa.valornormal) || ' '::text) || (a.nombreatributo)::text) || ' '::text) || (v.valor)::text) || ' Rango '::text) || pa.rangodesde) || ' a '::text) || pa.rangohasta) AS fueraderango
   FROM ((((((cvp.relatr v
     JOIN cvp.relpre r ON ((((v.periodo)::text = (r.periodo)::text) AND ((v.producto)::text = (r.producto)::text) AND (v.informante = r.informante) AND (v.observacion = r.observacion) AND (v.visita = r.visita))))
     JOIN cvp.productos f ON (((v.producto)::text = (f.producto)::text)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND ((v.periodo)::text = (vi.periodo)::text) AND (v.visita = vi.visita) AND (r.formulario = vi.formulario))))
     LEFT JOIN cvp.prodatr pa ON ((((v.producto)::text = (pa.producto)::text) AND (v.atributo = pa.atributo))))
     LEFT JOIN cvp.atributos a ON ((pa.atributo = a.atributo)))
     LEFT JOIN cvp.tipopre t ON (((r.tipoprecio)::text = (t.tipoprecio)::text)))
  WHERE (((t.espositivo)::text = 'S'::text) AND comun.es_numero((v.valor)::text) AND (pa.rangohasta IS NOT NULL) AND (pa.rangodesde IS NOT NULL) AND
        CASE
            WHEN comun.es_numero((v.valor)::text) THEN ((((v.valor)::double precision > pa.rangohasta) OR ((v.valor)::double precision < pa.rangodesde)) AND ((v.valor)::double precision <> pa.valornormal))
            ELSE false
        END)
  ORDER BY v.periodo, vi.panel, vi.tarea, v.producto, v.informante, vi.formulario, v.observacion;


ALTER TABLE cvp.control_atributos OWNER TO cvpowner;

--
-- Name: proddiv; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.proddiv (
    producto text NOT NULL,
    division text NOT NULL,
    incluye_supermercados boolean,
    incluye_tradicionales boolean,
    tipoinformante text,
    sindividir boolean,
    ponderadordiv double precision,
    umbralpriimp integer,
    umbraldescarte integer,
    umbralbajaauto integer,
    CONSTRAINT "El ponderador debe ser positivo. Lo que se puede es eliminar el" CHECK ((ponderadordiv > (0)::double precision)),
    CONSTRAINT "El umbral de primera imputación debe ser mayor a cero" CHECK ((umbralpriimp > 0)),
    CONSTRAINT proddiv_sindividir_check CHECK (sindividir),
    CONSTRAINT "texto invalido en division de tabla proddiv" CHECK (comun.cadena_valida(division, 'amplio'::text))
);


ALTER TABLE cvp.proddiv OWNER TO cvpowner;

--
-- Name: control_calculoresultados; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_calculoresultados AS
 SELECT c.grupo AS codigo,
    g.nombregrupo AS nombre,
    NULL::text AS ti,
    c.nivel,
    c.valorgru AS valor,
    c.variacion,
    c.impgru AS imp,
    NULL::double precision AS cant,
    NULL::text AS unidad,
    NULL::double precision AS promedio,
    NULL::text AS unidadnormal,
    NULL::integer AS cantincluidos,
    NULL::integer AS cantimputados,
    NULL::double precision AS promvar,
    NULL::integer AS cantaltas,
    NULL::double precision AS promaltas,
    NULL::integer AS cantbajas,
    NULL::double precision AS prombajas,
    c.periodo,
    c.grupo AS ordenamiento,
    c.esproducto,
    NULL::double precision AS ponderadordiv,
    NULL::double precision AS promedio_1,
    NULL::double precision AS varprom,
    NULL::integer AS cantexcluidos,
    NULL::double precision AS promexcluidos
   FROM (((cvp.calgru c
     JOIN cvp.grupos g ON (((c.grupo)::text = (g.grupo)::text)))
     JOIN cvp.calculos a ON ((((a.periodo)::text = (c.periodo)::text) AND (a.calculo = c.calculo))))
     JOIN cvp.calculos_def cd ON ((a.calculo = cd.calculo)))
  WHERE ((c.calculo = 0) AND ((c.agrupacion)::text = (cd.agrupacionprincipal)::text) AND ((c.esproducto)::text = 'N'::text))
UNION
 SELECT c.producto AS codigo,
    p.nombreproducto AS nombre,
    c.division AS ti,
    g.nivel,
    cpa.valorprod AS valor,
        CASE
            WHEN ((c.division)::text = '0'::text) THEN g.variacion
            ELSE NULL::double precision
        END AS variacion,
    c.impdiv AS imp,
    cpa.cantporunidcons AS cant,
    cp.unidadmedidaporunidcons AS unidad,
    c.promdiv AS promedio,
    cvp.obtenerunidadnormalizada((p.producto)::text) AS unidadnormal,
    c.cantincluidos,
    c.cantimputados,
    c.promvar,
    c.cantaltas,
    c.promaltas,
    c.cantbajas,
    c.prombajas,
    c.periodo,
    (((g.grupopadre)::text || '-'::text) || (g.grupo)::text) AS ordenamiento,
    'S'::text AS esproducto,
    v.ponderadordiv,
    c_1.promdiv AS promedio_1,
    (((c.promdiv / c_1.promdiv) * (100)::double precision) - (100)::double precision) AS varprom,
    c.cantexcluidos,
    c.promexcluidos
   FROM (((((((((cvp.caldiv c
     JOIN cvp.productos p ON (((c.producto)::text = (p.producto)::text)))
     JOIN cvp.calculos a ON ((((a.periodo)::text = (c.periodo)::text) AND (a.calculo = c.calculo))))
     JOIN cvp.calculos_def cd ON ((a.calculo = cd.calculo)))
     JOIN cvp.calgru g ON ((((g.periodo)::text = (c.periodo)::text) AND (g.calculo = c.calculo) AND ((g.agrupacion)::text = (cd.agrupacionprincipal)::text) AND ((g.grupo)::text = (c.producto)::text))))
     JOIN ( SELECT x.periodo,
            x.calculo,
            x.producto,
            count(*) AS canttipo
           FROM cvp.caldiv x
          GROUP BY x.periodo, x.calculo, x.producto) y ON ((((y.periodo)::text = (c.periodo)::text) AND (y.calculo = c.calculo) AND ((y.producto)::text = (c.producto)::text))))
     JOIN cvp.calprod cp ON ((((c.periodo)::text = (cp.periodo)::text) AND (c.calculo = cp.calculo) AND ((c.producto)::text = (cp.producto)::text))))
     JOIN cvp.calprodagr cpa ON ((((c.periodo)::text = (cpa.periodo)::text) AND (c.calculo = cpa.calculo) AND ((c.producto)::text = (cpa.producto)::text) AND ((g.agrupacion)::text = (cpa.agrupacion)::text))))
     LEFT JOIN cvp.proddiv v ON ((((p.producto)::text = (v.producto)::text) AND ((c.division)::text = (v.division)::text))))
     LEFT JOIN cvp.caldiv c_1 ON ((((a.periodoanterior)::text = (c_1.periodo)::text) AND (a.calculoanterior = c_1.calculo) AND ((c.producto)::text = (c_1.producto)::text) AND ((c.division)::text = (c_1.division)::text))))
  WHERE (c.calculo = 0);


ALTER TABLE cvp.control_calculoresultados OWNER TO cvpowner;

--
-- Name: control_calobs; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_calobs AS
 SELECT c.producto,
    c.informante,
    c.observacion,
    c.periodo,
    r.visita,
        CASE
            WHEN (r.visita > 1) THEN NULL::numeric
            ELSE round((c.promobs)::numeric, 2)
        END AS promobs,
        CASE
            WHEN (r.visita > 1) THEN NULL::text
            ELSE c.impobs
        END AS impobs,
        CASE
            WHEN (r.visita > 1) THEN NULL::numeric
            ELSE round((c_1.promobs)::numeric, 2)
        END AS promobs_1,
        CASE
            WHEN ((r.visita > 1) OR (c_1.promobs = (0)::double precision)) THEN NULL::numeric
            ELSE round(((((c.promobs / c_1.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacion,
    r.cambio,
    r.precionormalizado,
    r.precio,
    r.tipoprecio
   FROM (((cvp.relpre r
     FULL JOIN cvp.calobs c ON ((((c.periodo)::text = (r.periodo)::text) AND ((c.producto)::text = (r.producto)::text) AND (c.observacion = r.observacion) AND (c.informante = r.informante))))
     JOIN cvp.calculos ca ON ((((ca.periodo)::text = (c.periodo)::text) AND (ca.calculo = c.calculo))))
     LEFT JOIN cvp.calobs c_1 ON ((((c_1.producto)::text = (c.producto)::text) AND (c_1.calculo = ca.calculoanterior) AND (c_1.informante = c.informante) AND (c_1.observacion = c.observacion) AND ((c_1.periodo)::text = (ca.periodoanterior)::text))))
  WHERE (c.calculo = 0);


ALTER TABLE cvp.control_calobs OWNER TO cvpowner;

--
-- Name: formularios; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.formularios (
    formulario integer NOT NULL,
    nombreformulario text,
    soloparatipo text,
    operativo text NOT NULL,
    activo text,
    despacho text,
    altamanualdesdeperiodo text,
    orden integer NOT NULL,
    pie text,
    CONSTRAINT "Operativo debe ser C (Campo), G (Gabinete) o A (Ambos)" CHECK ((operativo = ANY (ARRAY['C'::text, 'G'::text, 'A'::text]))),
    CONSTRAINT formularios_despacho_check CHECK ((despacho = ANY (ARRAY['A'::text, 'P'::text]))),
    CONSTRAINT "texto invalido en nombreformulario de tabla formularios" CHECK (comun.cadena_valida(nombreformulario, 'castellano'::text))
);


ALTER TABLE cvp.formularios OWNER TO cvpowner;

--
-- Name: forprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.forprod (
    formulario integer NOT NULL,
    producto text NOT NULL,
    orden integer,
    ordenimpresion integer
);


ALTER TABLE cvp.forprod OWNER TO cvpowner;

--
-- Name: razones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.razones (
    razon integer NOT NULL,
    nombrerazon text,
    espositivoinformante text NOT NULL,
    espositivoformulario text NOT NULL,
    escierredefinitivoinf text NOT NULL,
    escierredefinitivofor text NOT NULL,
    visibleparaencuestador text DEFAULT 'S'::text NOT NULL,
    escierretemporalfor text DEFAULT 'N'::text,
    CONSTRAINT "texto invalido en nombrerazon de tabla razones" CHECK (comun.cadena_valida(nombrerazon, 'castellano'::text))
);


ALTER TABLE cvp.razones OWNER TO cvpowner;

--
-- Name: control_generacion_formularios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_generacion_formularios AS
 SELECT p.periodo,
    r_1.panel,
    r_1.tarea,
    r_1.informante,
    r_1.formulario,
    r_1.visita,
    r_1.razon AS razonant,
    r.razon,
        CASE
            WHEN ((r.periodo IS NULL) AND ((z.escierredefinitivoinf)::text = 'N'::text) AND ((z.escierredefinitivofor)::text = 'N'::text)) THEN 'Falta generar'::text
            WHEN ((r.periodo IS NOT NULL) AND (r.razon IS NULL)) THEN 'Razon en blanco'::text
            WHEN ((r.razon IS NOT NULL) AND (pr.tieneprecio IS DISTINCT FROM 1)) THEN
            CASE
                WHEN (fp.tieneproductos = 1) THEN 'Sin precios'::text
                ELSE 'Sin productos'::text
            END
            ELSE 'Error no contemplado'::text
        END AS descripcion,
    r.panel AS panelactual,
    r.tarea AS tareaactual
   FROM (((((((cvp.relvis r_1
     JOIN cvp.formularios f ON ((r_1.formulario = f.formulario)))
     JOIN cvp.periodos p ON (((r_1.periodo)::text = (p.periodoanterior)::text)))
     JOIN cvp.razones z ON ((r_1.razon = z.razon)))
     LEFT JOIN cvp.relvis r ON ((((r.periodo)::text = (p.periodo)::text) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
     LEFT JOIN ( SELECT DISTINCT relpre.periodo,
            relpre.informante,
            relpre.formulario,
            relpre.visita,
            1 AS tieneprecio
           FROM cvp.relpre) pr ON ((((pr.periodo)::text = (r.periodo)::text) AND (pr.informante = r.informante) AND (pr.formulario = r.formulario) AND (pr.visita = r.visita))))
     LEFT JOIN ( SELECT DISTINCT f_1.formulario,
            1 AS tiene_vigencia
           FROM ((cvp.forprod f_1
             JOIN cvp.prodatr pa ON (((f_1.producto)::text = (pa.producto)::text)))
             JOIN cvp.atributos a ON (((a.atributo = pa.atributo) AND (a.es_vigencia = true))))
          GROUP BY f_1.formulario) e ON ((e.formulario = r_1.formulario)))
     LEFT JOIN ( SELECT DISTINCT f_1.formulario,
            1 AS tieneproductos
           FROM cvp.forprod f_1) fp ON ((fp.formulario = r_1.formulario)))
  WHERE ((((r.periodo IS NULL) AND ((z.escierredefinitivoinf)::text = 'N'::text) AND ((z.escierredefinitivofor)::text = 'N'::text) AND (e.tiene_vigencia IS DISTINCT FROM 1)) OR ((r.periodo IS NOT NULL) AND (r.razon IS NULL)) OR ((r.periodo IS NOT NULL) AND (r.razon IS NOT NULL) AND (pr.tieneprecio IS DISTINCT FROM 1))) AND ((f.activo)::text = 'S'::text))
  ORDER BY p.periodo, r_1.panel, r_1.tarea, r_1.informante, r_1.formulario, r_1.visita;


ALTER TABLE cvp.control_generacion_formularios OWNER TO cvpowner;

--
-- Name: gru_prod; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.gru_prod AS
 WITH RECURSIVE productos_de(agrupacion, grupo_padre, producto) AS (
         SELECT grupos.agrupacion,
            grupos.grupopadre AS grupo_padre,
            grupos.grupo AS producto
           FROM cvp.grupos
          WHERE ((grupos.esproducto)::text = 'S'::text)
        UNION ALL
         SELECT p.agrupacion,
            g.grupopadre AS grupo_padre,
            p.producto
           FROM (productos_de p
             JOIN cvp.grupos g ON ((((g.grupo)::text = (p.grupo_padre)::text) AND ((g.agrupacion)::text = (p.agrupacion)::text))))
          WHERE (g.grupopadre IS NOT NULL)
        )
 SELECT productos_de.agrupacion,
    productos_de.grupo_padre,
    productos_de.producto
   FROM productos_de
  ORDER BY productos_de.producto, productos_de.agrupacion, productos_de.grupo_padre;


ALTER TABLE cvp.gru_prod OWNER TO cvpowner;

--
-- Name: control_grupos_para_cierre; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_grupos_para_cierre AS
 SELECT x.periodo,
    x.calculo,
    x.agrupacion,
    x.grupo,
    x.nombregrupo AS nombre,
    x.nivel,
    c.variacion,
    c.incidencia,
    c.variacioninteranualredondeada,
    c.incidenciainteranual,
    x.ponderador,
    x.cantincluidos,
    x.cantrealesincluidos,
    x.cantimputados,
    ('Z'::text || substr((x.grupo)::text, 2)) AS ordenpor
   FROM (( SELECT d.periodo,
            d.calculo,
            gp.agrupacion,
            gp.grupo_padre AS grupo,
            g.nombregrupo,
            g.ponderador,
            g.nivel,
            sum(d.cantincluidos) AS cantincluidos,
            sum(d.cantrealesincluidos) AS cantrealesincluidos,
            sum(d.cantimputados) AS cantimputados
           FROM (((cvp.caldiv d
             LEFT JOIN cvp.gru_prod gp ON (((d.producto)::text = (gp.producto)::text)))
             LEFT JOIN cvp.grupos g ON ((((gp.grupo_padre)::text = (g.grupo)::text) AND ((gp.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.agrupaciones a ON (((gp.agrupacion)::text = (a.agrupacion)::text)))
          WHERE (((d.division)::text = '0'::text) AND ((a.tipo_agrupacion)::text = 'INDICE'::text) AND (d.calculo = 0))
          GROUP BY d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre, g.nombregrupo, g.ponderador, g.nivel) x
     LEFT JOIN cvp.calgru_vw c ON ((((c.periodo)::text = (x.periodo)::text) AND (c.calculo = x.calculo) AND ((c.agrupacion)::text = (x.agrupacion)::text) AND ((c.grupo)::text = (x.grupo)::text))))
  ORDER BY ('Z'::text || substr((x.grupo)::text, 2));


ALTER TABLE cvp.control_grupos_para_cierre OWNER TO cvpowner;

--
-- Name: control_hojas_ruta; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_hojas_ruta AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.fechasalida,
    v.informante,
    v.encuestador,
    (COALESCE(p.apellido, NULL::text))::text AS nombreencuestador,
    v.recepcionista,
    (COALESCE(s.apellido, NULL::text))::text AS nombrerecepcionista,
    v.ingresador,
    (COALESCE(n.apellido, NULL::text))::text AS nombreingresador,
    v.supervisor,
    (COALESCE(r.apellido, NULL::text))::text AS nombresupervisor,
    v.formulario,
    f.nombreformulario,
    f.operativo,
    v.razon,
    r_1.razon AS razonanterior,
    v.visita,
    i.nombreinformante,
    i.direccion,
    i.conjuntomuestral,
    i.ordenhdr
   FROM ((((((((cvp.relvis v
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     LEFT JOIN cvp.personal p ON (((v.encuestador)::text = (p.persona)::text)))
     LEFT JOIN cvp.personal s ON (((v.recepcionista)::text = (s.persona)::text)))
     LEFT JOIN cvp.personal n ON (((v.ingresador)::text = (n.persona)::text)))
     LEFT JOIN cvp.personal r ON (((v.supervisor)::text = (r.persona)::text)))
     LEFT JOIN cvp.periodos o ON (((v.periodo)::text = (o.periodo)::text)))
     LEFT JOIN cvp.relvis r_1 ON ((((r_1.periodo)::text = (
        CASE
            WHEN (v.visita > 1) THEN v.periodo
            ELSE o.periodoanterior
        END)::text) AND (((r_1.ultima_visita = true) AND (v.visita = 1)) OR ((v.visita > 1) AND (r_1.visita = (v.visita - 1)))) AND (r_1.informante = v.informante) AND (r_1.formulario = v.formulario))))
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario;


ALTER TABLE cvp.control_hojas_ruta OWNER TO cvpowner;

--
-- Name: control_ingresados_calculo; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_ingresados_calculo AS
 SELECT p.periodo,
    p.producto,
    o.nombreproducto,
    p.informante,
    i.nombreinformante,
    p.observacion,
    i.tipoinformante,
    pd.divisionesdelproducto,
        CASE
            WHEN (NOT ((i.tipoinformante)::text IS DISTINCT FROM pd.divisionesdelproducto)) THEN date_trunc('second'::text, i.modi_fec)
            ELSE NULL::timestamp without time zone
        END AS fechamodificacioninformante
   FROM (((((( SELECT DISTINCT relpre.periodo,
            relpre.producto,
            relpre.informante,
            relpre.observacion,
            relpre.modi_fec
           FROM cvp.relpre
          WHERE (relpre.precionormalizado IS NOT NULL)) p
     JOIN cvp.productos o ON (((p.producto)::text = (o.producto)::text)))
     JOIN cvp.informantes i ON ((p.informante = i.informante)))
     JOIN cvp.calculos a ON ((((p.periodo)::text = (a.periodo)::text) AND (a.calculo = 0))))
     LEFT JOIN ( SELECT proddiv.producto,
            string_agg((proddiv.division)::text, ','::text ORDER BY (proddiv.division)::text) AS divisionesdelproducto
           FROM cvp.proddiv
          GROUP BY proddiv.producto) pd ON (((p.producto)::text = (pd.producto)::text)))
     LEFT JOIN ( SELECT calobs.periodo,
            calobs.calculo,
            calobs.producto,
            calobs.informante,
            calobs.observacion,
            calobs.division,
            calobs.promobs,
            calobs.impobs,
            calobs.antiguedadconprecio,
            calobs.antiguedadsinprecio,
            calobs.antiguedadexcluido,
            calobs.antiguedadincluido,
            calobs.sindatosestacional,
            calobs.muestra
           FROM cvp.calobs
          WHERE (calobs.calculo = 0)) c ON ((((c.periodo)::text = (p.periodo)::text) AND ((c.producto)::text = (p.producto)::text) AND (c.informante = p.informante) AND (c.observacion = p.observacion))))
  WHERE ((c.division IS NULL) AND (p.modi_fec < a.fechacalculo))
  ORDER BY p.periodo, p.producto, p.informante, p.observacion;


ALTER TABLE cvp.control_ingresados_calculo OWNER TO cvpowner;

--
-- Name: control_ingreso_atributos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_ingreso_atributos AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.informante,
    v.formulario,
    v.visita,
    p.producto,
    p.observacion,
    a.atributo,
    atr.nombreatributo,
    a.valor,
    atr.tipodato
   FROM (((cvp.relvis v
     JOIN cvp.relpre p ON ((((v.periodo)::text = (p.periodo)::text) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
     LEFT JOIN cvp.relatr a ON ((((a.periodo)::text = (p.periodo)::text) AND (a.visita = p.visita) AND (a.informante = p.informante) AND ((a.producto)::text = (p.producto)::text) AND (a.observacion = p.observacion))))
     LEFT JOIN cvp.atributos atr ON ((atr.atributo = a.atributo)))
  WHERE ((p.precio > (0.0)::double precision) AND (a.atributo IS NOT NULL) AND ((v.periodo)::text >= 'a2009m05'::text) AND ((a.valor IS NULL) OR (((atr.tipodato)::text = 'N'::text) AND (NOT comun.es_numero((a.valor)::text)))))
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario, p.producto, p.observacion;


ALTER TABLE cvp.control_ingreso_atributos OWNER TO cvpowner;

--
-- Name: control_ingreso_precios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_ingreso_precios AS
 SELECT p.periodo,
    v.panel,
    v.tarea,
    p.informante,
    p.formulario,
    p.visita,
    v.razon,
    p.producto,
    p.observacion
   FROM ((cvp.relvis v
     JOIN cvp.razones z ON ((v.razon = z.razon)))
     LEFT JOIN cvp.relpre p ON ((((v.periodo)::text = (p.periodo)::text) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
  WHERE ((p.precio IS NULL) AND (p.tipoprecio IS NULL) AND ((z.espositivoformulario)::text = 'S'::text))
  ORDER BY p.periodo, v.panel, v.tarea, p.informante, p.formulario, p.visita, p.producto, p.observacion;


ALTER TABLE cvp.control_ingreso_precios OWNER TO cvpowner;

--
-- Name: control_normalizables_sindato; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_normalizables_sindato AS
 SELECT ra.periodo,
    ra.producto,
    x.nombreproducto,
    ra.observacion,
    ra.informante,
    ra.atributo,
    ra.valor,
    ra.visita,
    ra.validar_con_valvalatr,
    y.nombreatributo,
    pa.valornormal,
    pa.orden,
    pa.normalizable,
    pa.tiponormalizacion,
    pa.alterable,
    pa.prioridad,
    pa.operacion,
    pa.rangodesde,
    pa.rangohasta,
    pa.orden_calculo_especial,
    pa.tipo_promedio,
    rp.formulario,
    rp.precio,
    rp.tipoprecio,
    rp.comentariosrelpre,
    rp.cambio,
    rp.precionormalizado,
    rp.especificacion,
    rp.ultima_visita,
    v.panel,
    v.tarea,
    (((v.encuestador)::text || ':'::text) || (pe.apellido)::text) AS encuestador,
    v.recepcionista
   FROM ((((((cvp.relatr ra
     JOIN cvp.prodatr pa ON (((pa.atributo = ra.atributo) AND ((pa.producto)::text = (ra.producto)::text))))
     JOIN cvp.relpre rp ON ((((rp.periodo)::text = (ra.periodo)::text) AND (rp.visita = ra.visita) AND ((rp.producto)::text = (ra.producto)::text) AND (rp.observacion = ra.observacion) AND (rp.informante = ra.informante))))
     JOIN cvp.relvis v ON ((((v.periodo)::text = (rp.periodo)::text) AND (v.informante = rp.informante) AND (v.visita = rp.visita) AND (v.formulario = rp.formulario))))
     JOIN cvp.personal pe ON (((v.encuestador)::text = (pe.persona)::text)))
     JOIN cvp.productos x ON (((x.producto)::text = (ra.producto)::text)))
     JOIN cvp.atributos y ON ((y.atributo = ra.atributo)))
  WHERE ((pa.valornormal IS NOT NULL) AND ((pa.normalizable)::text = 'S'::text) AND (ra.valor IS NULL) AND (rp.precio IS NOT NULL))
  ORDER BY ra.periodo, ra.producto, ra.observacion, ra.informante, ra.atributo, ra.visita;


ALTER TABLE cvp.control_normalizables_sindato OWNER TO cvpowner;

--
-- Name: control_precios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_precios AS
 SELECT x.periodo,
    x.producto,
    p.nombreproducto,
    x.precio_min,
    p_min.observacion AS observacion_min,
    p_min.informante AS informante_min,
    p_min.formulario AS formulario_min,
    x.precio_max,
    p_max.observacion AS observacion_max,
    p_max.informante AS informante_max,
    p_max.formulario AS formulario_max
   FROM ( SELECT pr.periodo,
            pr.producto,
            max(pr.precio) AS precio_max,
            min(pr.precio) AS precio_min
           FROM cvp.relpre pr
          WHERE (pr.precio > (0)::double precision)
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre p_min,
    cvp.relpre p_max,
    cvp.productos p
  WHERE (((p_min.periodo)::text = (x.periodo)::text) AND ((p_min.producto)::text = (x.producto)::text) AND (p_min.precio = x.precio_min) AND ((p_max.periodo)::text = (x.periodo)::text) AND ((p_max.producto)::text = (x.producto)::text) AND (p_max.precio = x.precio_max) AND ((p.producto)::text = (x.producto)::text));


ALTER TABLE cvp.control_precios OWNER TO cvpowner;

--
-- Name: control_precios2; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_precios2 AS
 SELECT x.periodo,
    x.producto,
    p.nombreproducto,
    rp.observacion,
    rp.informante,
    rp.formulario,
        CASE
            WHEN (rp.precio = x.precio_min) THEN 'precio min'::text
            WHEN (rp.precio = x.precio_max) THEN 'PRECIO MAX'::text
            ELSE ''::text
        END AS categoria,
    rp.precio,
    rp.tipoprecio
   FROM ( SELECT pr.periodo,
            pr.producto,
            max(pr.precio) AS precio_max,
            min(pr.precio) AS precio_min
           FROM cvp.relpre pr
          WHERE (pr.precio > (0)::double precision)
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre rp,
    cvp.productos p
  WHERE (((rp.periodo)::text = (x.periodo)::text) AND ((rp.producto)::text = (x.producto)::text) AND ((rp.precio = x.precio_min) OR (rp.precio = x.precio_max)) AND ((p.producto)::text = (x.producto)::text))
  ORDER BY x.periodo, x.producto, rp.observacion, rp.precio;


ALTER TABLE cvp.control_precios2 OWNER TO cvpowner;

--
-- Name: control_productos_para_cierre; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_productos_para_cierre AS
 SELECT o.periodo,
    o.calculo,
    o.producto,
    p.nombreproducto,
    g.variacion,
    g.incidencia,
    o.cantincluidos,
    o.cantrealesincluidos,
    o.cantimputados,
    round((((round((s.promdiv)::numeric, 2) / round((s0.promdiv)::numeric, 2)) * (100)::numeric) - (100)::numeric), 1) AS s_variacion,
    s.cantincluidos AS s_cantincluidos,
    s.cantrealesincluidos AS s_cantrealesincluidos,
    s.cantimputados AS s_cantimputados,
    round((((round((t.promdiv)::numeric, 2) / round((t0.promdiv)::numeric, 2)) * (100)::numeric) - (100)::numeric), 1) AS t_variacion,
    t.cantincluidos AS t_cantincluidos,
    t.cantrealesincluidos AS t_cantrealesincluidos,
    t.cantimputados AS t_cantimputados
   FROM (((((((( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            caldiv.division,
            caldiv.prompriimpact,
            caldiv.prompriimpant,
            caldiv.cantpriimp,
            caldiv.promprel,
            caldiv.promdiv,
            caldiv.impdiv,
            caldiv.cantincluidos,
            caldiv.cantrealesincluidos,
            caldiv.cantrealesexcluidos,
            caldiv.promvar,
            caldiv.cantaltas,
            caldiv.promaltas,
            caldiv.cantbajas,
            caldiv.prombajas,
            caldiv.cantimputados,
            caldiv.ponderadordiv,
            caldiv.umbralpriimp,
            caldiv.umbraldescarte,
            caldiv.umbralbajaauto,
            caldiv.cantidadconprecio,
            caldiv.profundidad,
            caldiv.divisionpadre,
            caldiv.tipo_promedio,
            caldiv.raiz,
            caldiv.cantexcluidos,
            caldiv.promexcluidos,
            caldiv.promimputados,
            caldiv.promrealesincluidos,
            caldiv.promrealesexcluidos,
            caldiv.promedioredondeado,
            caldiv.cantrealesdescartados,
            caldiv.cantpreciostotales,
            caldiv.cantpreciosingresados,
            caldiv.cantconprecioparacalestac,
            caldiv.promsinimpext
           FROM cvp.caldiv
          WHERE (((caldiv.division)::text = '0'::text) AND (caldiv.calculo = 0))) o
     LEFT JOIN cvp.periodos r ON (((o.periodo)::text = (r.periodo)::text)))
     LEFT JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            caldiv.division,
            caldiv.prompriimpact,
            caldiv.prompriimpant,
            caldiv.cantpriimp,
            caldiv.promprel,
            caldiv.promdiv,
            caldiv.impdiv,
            caldiv.cantincluidos,
            caldiv.cantrealesincluidos,
            caldiv.cantrealesexcluidos,
            caldiv.promvar,
            caldiv.cantaltas,
            caldiv.promaltas,
            caldiv.cantbajas,
            caldiv.prombajas,
            caldiv.cantimputados,
            caldiv.ponderadordiv,
            caldiv.umbralpriimp,
            caldiv.umbraldescarte,
            caldiv.umbralbajaauto,
            caldiv.cantidadconprecio,
            caldiv.profundidad,
            caldiv.divisionpadre,
            caldiv.tipo_promedio,
            caldiv.raiz,
            caldiv.cantexcluidos,
            caldiv.promexcluidos,
            caldiv.promimputados,
            caldiv.promrealesincluidos,
            caldiv.promrealesexcluidos,
            caldiv.promedioredondeado,
            caldiv.cantrealesdescartados,
            caldiv.cantpreciostotales,
            caldiv.cantpreciosingresados,
            caldiv.cantconprecioparacalestac,
            caldiv.promsinimpext
           FROM cvp.caldiv
          WHERE (((caldiv.division)::text = 'S'::text) AND (caldiv.calculo >= 0))) s ON ((((o.periodo)::text = (s.periodo)::text) AND (o.calculo = s.calculo) AND ((o.producto)::text = (s.producto)::text))))
     LEFT JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            caldiv.division,
            caldiv.prompriimpact,
            caldiv.prompriimpant,
            caldiv.cantpriimp,
            caldiv.promprel,
            caldiv.promdiv,
            caldiv.impdiv,
            caldiv.cantincluidos,
            caldiv.cantrealesincluidos,
            caldiv.cantrealesexcluidos,
            caldiv.promvar,
            caldiv.cantaltas,
            caldiv.promaltas,
            caldiv.cantbajas,
            caldiv.prombajas,
            caldiv.cantimputados,
            caldiv.ponderadordiv,
            caldiv.umbralpriimp,
            caldiv.umbraldescarte,
            caldiv.umbralbajaauto,
            caldiv.cantidadconprecio,
            caldiv.profundidad,
            caldiv.divisionpadre,
            caldiv.tipo_promedio,
            caldiv.raiz,
            caldiv.cantexcluidos,
            caldiv.promexcluidos,
            caldiv.promimputados,
            caldiv.promrealesincluidos,
            caldiv.promrealesexcluidos,
            caldiv.promedioredondeado,
            caldiv.cantrealesdescartados,
            caldiv.cantpreciostotales,
            caldiv.cantpreciosingresados,
            caldiv.cantconprecioparacalestac,
            caldiv.promsinimpext
           FROM cvp.caldiv
          WHERE (((caldiv.division)::text = 'S'::text) AND (caldiv.calculo >= 0))) s0 ON ((((s0.periodo)::text = (r.periodoanterior)::text) AND (s0.calculo = s.calculo) AND ((s0.producto)::text = (s.producto)::text) AND ((s0.division)::text = (s.division)::text))))
     LEFT JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            caldiv.division,
            caldiv.prompriimpact,
            caldiv.prompriimpant,
            caldiv.cantpriimp,
            caldiv.promprel,
            caldiv.promdiv,
            caldiv.impdiv,
            caldiv.cantincluidos,
            caldiv.cantrealesincluidos,
            caldiv.cantrealesexcluidos,
            caldiv.promvar,
            caldiv.cantaltas,
            caldiv.promaltas,
            caldiv.cantbajas,
            caldiv.prombajas,
            caldiv.cantimputados,
            caldiv.ponderadordiv,
            caldiv.umbralpriimp,
            caldiv.umbraldescarte,
            caldiv.umbralbajaauto,
            caldiv.cantidadconprecio,
            caldiv.profundidad,
            caldiv.divisionpadre,
            caldiv.tipo_promedio,
            caldiv.raiz,
            caldiv.cantexcluidos,
            caldiv.promexcluidos,
            caldiv.promimputados,
            caldiv.promrealesincluidos,
            caldiv.promrealesexcluidos,
            caldiv.promedioredondeado,
            caldiv.cantrealesdescartados,
            caldiv.cantpreciostotales,
            caldiv.cantpreciosingresados,
            caldiv.cantconprecioparacalestac,
            caldiv.promsinimpext
           FROM cvp.caldiv
          WHERE (((caldiv.division)::text = 'T'::text) AND (caldiv.calculo >= 0))) t ON ((((s.periodo)::text = (t.periodo)::text) AND (s.calculo = t.calculo) AND ((s.producto)::text = (t.producto)::text))))
     LEFT JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            caldiv.division,
            caldiv.prompriimpact,
            caldiv.prompriimpant,
            caldiv.cantpriimp,
            caldiv.promprel,
            caldiv.promdiv,
            caldiv.impdiv,
            caldiv.cantincluidos,
            caldiv.cantrealesincluidos,
            caldiv.cantrealesexcluidos,
            caldiv.promvar,
            caldiv.cantaltas,
            caldiv.promaltas,
            caldiv.cantbajas,
            caldiv.prombajas,
            caldiv.cantimputados,
            caldiv.ponderadordiv,
            caldiv.umbralpriimp,
            caldiv.umbraldescarte,
            caldiv.umbralbajaauto,
            caldiv.cantidadconprecio,
            caldiv.profundidad,
            caldiv.divisionpadre,
            caldiv.tipo_promedio,
            caldiv.raiz,
            caldiv.cantexcluidos,
            caldiv.promexcluidos,
            caldiv.promimputados,
            caldiv.promrealesincluidos,
            caldiv.promrealesexcluidos,
            caldiv.promedioredondeado,
            caldiv.cantrealesdescartados,
            caldiv.cantpreciostotales,
            caldiv.cantpreciosingresados,
            caldiv.cantconprecioparacalestac,
            caldiv.promsinimpext
           FROM cvp.caldiv
          WHERE (((caldiv.division)::text = 'T'::text) AND (caldiv.calculo >= 0))) t0 ON ((((t0.periodo)::text = (r.periodoanterior)::text) AND (t.calculo = t0.calculo) AND ((t.producto)::text = (t0.producto)::text) AND ((t.division)::text = (t0.division)::text))))
     LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
     LEFT JOIN ( SELECT calgru.periodo,
            calgru.calculo,
            calgru.agrupacion,
            calgru.grupo,
            calgru.variacion,
            calgru.impgru,
            calgru.valorprel,
            calgru.valorgru,
            calgru.grupopadre,
            calgru.nivel,
            calgru.esproducto,
            calgru.ponderador,
            calgru.indice,
            calgru.indiceprel,
            calgru.incidencia,
            calgru.indiceredondeado,
            calgru.incidenciaredondeada,
            calgru.ponderadorimplicito
           FROM cvp.calgru
          WHERE (((calgru.esproducto)::text = 'S'::text) AND ((calgru.agrupacion)::text = 'Z'::text))) g ON ((((g.periodo)::text = (o.periodo)::text) AND (g.calculo = o.calculo) AND ((g.grupo)::text = (o.producto)::text))));


ALTER TABLE cvp.control_productos_para_cierre OWNER TO cvpowner;

--
-- Name: relpan; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relpan (
    periodo text NOT NULL,
    panel integer NOT NULL,
    fechasalida date,
    fechageneracionpanel timestamp without time zone,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    periodoparapanelrotativo text,
    generacionsupervisiones timestamp without time zone
);


ALTER TABLE cvp.relpan OWNER TO cvpowner;

--
-- Name: panel_promrotativo; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.panel_promrotativo AS
 SELECT pa.periodo,
    v2.producto,
    avg(v2.precionormalizado) AS promrotativo,
    stddev(v2.precionormalizado) AS desvprot
   FROM cvp.relvis vis,
    cvp.relpre v2,
    cvp.relpan pa
  WHERE ((vis.informante = v2.informante) AND ((vis.periodo)::text = (v2.periodo)::text) AND (vis.visita = v2.visita) AND (vis.formulario = v2.formulario) AND ((pa.periodoparapanelrotativo)::text = (vis.periodo)::text) AND (vis.panel = pa.panel))
  GROUP BY pa.periodo, v2.producto
  ORDER BY pa.periodo, v2.producto;


ALTER TABLE cvp.panel_promrotativo OWNER TO cvpowner;

--
-- Name: parametros; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.parametros (
    unicoregistro boolean DEFAULT true NOT NULL,
    nombreaplicacion text,
    titulo text,
    archivologo text,
    tamannodesvpre double precision DEFAULT 2.5 NOT NULL,
    tamannodesvvar double precision DEFAULT 2.5 NOT NULL,
    codigo text,
    formularionumeracionglobal text,
    estructuraversioncommit numeric,
    soloingresaingresador text DEFAULT 'S'::text,
    pb_desde text,
    pb_hasta text,
    ph_desde text,
    sup_aleat_prob1 double precision,
    sup_aleat_prob2 double precision,
    sup_aleat_prob_per double precision,
    sup_aleat_prob_pantar double precision,
    diferencia_horaria_tolerancia_ipad interval DEFAULT '01:15:00'::interval NOT NULL,
    diferencia_horaria_advertencia_ipad interval DEFAULT '00:15:00'::interval NOT NULL,
    puedeagregarvisita text,
    CONSTRAINT parametros_unicoregistro_check CHECK (unicoregistro)
);


ALTER TABLE cvp.parametros OWNER TO cvpowner;

--
-- Name: prerep; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prerep (
    periodo text NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text
);


ALTER TABLE cvp.prerep OWNER TO cvpowner;

--
-- Name: relpre_1; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.relpre_1 AS
 SELECT r.periodo,
    r.producto,
    r.observacion,
    r.informante,
    r.formulario,
    r.visita,
    r.precio,
    r.tipoprecio,
    r.cambio,
    r.comentariosrelpre,
    r.observaciones,
    r_1.precio AS precio_1,
    r_1.tipoprecio AS tipoprecio_1,
    r_1.cambio AS cambio_1,
    r_1.periodo AS periodo_1,
    r_1.visita AS visita_1,
    r.precionormalizado,
    r_1.precionormalizado AS precionormalizado_1,
    r_1.comentariosrelpre AS comentariosrelpre_1
   FROM ((cvp.relpre r
     LEFT JOIN cvp.periodos p ON (((r.periodo)::text = (p.periodo)::text)))
     LEFT JOIN cvp.relpre r_1 ON ((((r_1.periodo)::text = (
        CASE
            WHEN (r.visita > 1) THEN r.periodo
            ELSE p.periodoanterior
        END)::text) AND (((r_1.ultima_visita = true) AND (r.visita = 1)) OR ((r.visita > 1) AND (r_1.visita = (r.visita - 1)))) AND (r_1.informante = r.informante) AND ((r_1.producto)::text = (r.producto)::text) AND (r_1.observacion = r.observacion))));


ALTER TABLE cvp.relpre_1 OWNER TO cvpowner;

--
-- Name: control_rangos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_rangos AS
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    v.informante,
    i.tipoinformante,
    v.observacion,
    v.visita,
    vi.panel,
    vi.tarea,
    (((vi.encuestador)::text || ':'::text) || (pe.apellido)::text) AS encuestador,
    vi.recepcionista,
    pc.apellido AS nombrerecep,
    v.formulario,
    v.precionormalizado,
    v.comentariosrelpre,
    v.observaciones,
    v.tipoprecio,
    v.cambio,
    c2.impobs,
    COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
    v.tipoprecio_1 AS tipoprecioant,
    co.antiguedadsinprecio AS antiguedadsinprecioant,
    sum((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision)) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    (((vi2.razon)::text || ':'::text) || (COALESCE(co.impobs, ' '::text))::text) AS razon_impobs_ant,
        CASE
            WHEN (min((pr.periodo)::text) IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS repregunta
   FROM ((((((((((((cvp.relpre_1 v
     JOIN cvp.productos f ON (((v.producto)::text = (f.producto)::text)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND ((v.periodo)::text = (vi.periodo)::text) AND (v.visita = vi.visita) AND (v.formulario = vi.formulario))))
     LEFT JOIN cvp.personal pe ON (((vi.encuestador)::text = (pe.persona)::text)))
     LEFT JOIN cvp.personal pc ON (((vi.recepcionista)::text = (pc.persona)::text)))
     LEFT JOIN cvp.calobs co ON ((((co.periodo)::text = (v.periodo_1)::text) AND (co.calculo = 0) AND ((co.producto)::text = (v.producto)::text) AND (co.informante = v.informante) AND (co.observacion = v.observacion))))
     LEFT JOIN cvp.calobs c2 ON ((((c2.periodo)::text = (v.periodo)::text) AND (c2.calculo = 0) AND ((c2.producto)::text = (v.producto)::text) AND (c2.informante = v.informante) AND (c2.observacion = v.observacion))))
     JOIN ( SELECT avg((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::double precision) - (100)::double precision)) AS promvar,
            stddev((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::double precision) - (100)::double precision)) AS desvvar,
            va2.periodo,
            va2.producto
           FROM (cvp.relpre_1 va2
             LEFT JOIN cvp.calobs co2 ON ((((co2.periodo)::text = (va2.periodo_1)::text) AND (co2.calculo = 0) AND ((co2.producto)::text = (va2.producto)::text) AND (co2.informante = va2.informante) AND (co2.observacion = va2.observacion))))
          GROUP BY va2.periodo, va2.producto) avgvar ON ((((v.periodo)::text = (avgvar.periodo)::text) AND ((v.producto)::text = (avgvar.producto)::text))))
     JOIN cvp.panel_promrotativo avgprot ON ((((v.periodo)::text = (avgprot.periodo)::text) AND ((v.producto)::text = (avgprot.producto)::text))))
     JOIN cvp.parametros ON ((parametros.unicoregistro = true)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.prerep pr ON ((((v.periodo)::text = (pr.periodo)::text) AND (v.informante = pr.informante) AND ((v.producto)::text = (pr.producto)::text))))
     LEFT JOIN cvp.relvis vi2 ON (((v.informante = vi2.informante) AND ((v.periodo_1)::text = (vi2.periodo)::text) AND (v.visita = vi2.visita) AND (v.formulario = vi2.formulario))))
  WHERE (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) > (avgvar.promvar + (parametros.tamannodesvvar * avgvar.desvvar))) OR (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) IS DISTINCT FROM (0)::double precision) AND ((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) < (avgvar.promvar - (parametros.tamannodesvvar * avgvar.desvvar)))) OR (v.precionormalizado > (avgprot.promrotativo + (parametros.tamannodesvpre * avgprot.desvprot))) OR (v.precionormalizado < (avgprot.promrotativo - (parametros.tamannodesvpre * avgprot.desvprot))))
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, (((vi.encuestador)::text || ':'::text) || (pe.apellido)::text), vi.recepcionista, pc.apellido, vi.tarea, v.formulario, v.precionormalizado, v.comentariosrelpre, v.observaciones, v.tipoprecio, v.cambio, c2.impobs, v.precionormalizado_1, co.promobs, v.tipoprecio_1, co.antiguedadsinprecio, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, avgprot.desvprot, co.impobs, vi2.razon
  ORDER BY v.periodo, v.producto, vi.panel, vi.tarea, v.informante;


ALTER TABLE cvp.control_rangos OWNER TO cvpowner;

--
-- Name: panel_promrotativo_mod; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.panel_promrotativo_mod AS
 SELECT pa.periodo,
    v2.producto,
    avg(v2.precionormalizado) AS promrotativo,
    stddev(v2.precionormalizado) AS desvprot
   FROM cvp.relvis vis,
    cvp.relpre v2,
    cvp.relpan pa
  WHERE ((vis.informante = v2.informante) AND ((vis.periodo)::text = (v2.periodo)::text) AND (vis.visita = v2.visita) AND (vis.formulario = v2.formulario) AND ((pa.periodoparapanelrotativo)::text = (v2.periodo)::text) AND (vis.panel = pa.panel))
  GROUP BY pa.periodo, v2.producto
  ORDER BY pa.periodo, v2.producto;


ALTER TABLE cvp.panel_promrotativo_mod OWNER TO cvpowner;

--
-- Name: control_rangos_mod; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_rangos_mod AS
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    v.informante,
    i.tipoinformante,
    v.observacion,
    v.visita,
    vi.panel,
    vi.tarea,
    v.precionormalizado,
    v.tipoprecio,
    v.cambio,
    c2.impobs,
    COALESCE(v.precionormalizado_1, co.promobs) AS precioant,
    sum((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision)) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    co.impobs AS impobs_1
   FROM ((((((((cvp.relpre_1 v
     JOIN cvp.productos f ON (((v.producto)::text = (f.producto)::text)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND ((v.periodo)::text = (vi.periodo)::text) AND (v.visita = vi.visita) AND (v.formulario = vi.formulario))))
     LEFT JOIN cvp.calobs co ON ((((co.periodo)::text = (v.periodo_1)::text) AND (co.calculo = 0) AND ((co.producto)::text = (v.producto)::text) AND (co.informante = v.informante) AND (co.observacion = v.observacion))))
     LEFT JOIN cvp.calobs c2 ON ((((c2.periodo)::text = (v.periodo)::text) AND (c2.calculo = 0) AND ((c2.producto)::text = (v.producto)::text) AND (c2.informante = v.informante) AND (c2.observacion = v.observacion))))
     JOIN ( SELECT avg((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::double precision) - (100)::double precision)) AS promvar,
            stddev((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::double precision) - (100)::double precision)) AS desvvar,
            va2.periodo,
            va2.producto
           FROM (cvp.relpre_1 va2
             LEFT JOIN cvp.calobs co2 ON ((((co2.periodo)::text = (va2.periodo_1)::text) AND (co2.calculo = 0) AND ((co2.producto)::text = (va2.producto)::text) AND (co2.informante = va2.informante) AND (co2.observacion = va2.observacion))))
          GROUP BY va2.periodo, va2.producto) avgvar ON ((((v.periodo)::text = (avgvar.periodo)::text) AND ((v.producto)::text = (avgvar.producto)::text))))
     JOIN cvp.panel_promrotativo_mod avgprot ON ((((v.periodo)::text = (avgprot.periodo)::text) AND ((v.producto)::text = (avgprot.producto)::text))))
     JOIN cvp.parametros ON ((parametros.unicoregistro = true)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
  WHERE (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) > (avgvar.promvar + (parametros.tamannodesvvar * avgvar.desvvar))) OR (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) IS DISTINCT FROM (0)::double precision) AND ((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision) < (avgvar.promvar - (parametros.tamannodesvvar * avgvar.desvvar)))) OR (v.precionormalizado > (avgprot.promrotativo + (parametros.tamannodesvpre * avgprot.desvprot))) OR (v.precionormalizado < (avgprot.promrotativo - (parametros.tamannodesvpre * avgprot.desvprot))))
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, vi.tarea, v.precionormalizado, v.tipoprecio, v.cambio, c2.impobs, v.precionormalizado_1, co.promobs, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, avgprot.desvprot, co.impobs
  ORDER BY v.periodo, v.producto, vi.panel, vi.tarea, v.informante;


ALTER TABLE cvp.control_rangos_mod OWNER TO cvpowner;

--
-- Name: rubros; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.rubros (
    rubro integer NOT NULL,
    nombrerubro text NOT NULL,
    tipoinformante text NOT NULL,
    despacho text NOT NULL,
    grupozonal text,
    telefonico text DEFAULT 'N'::text,
    CONSTRAINT "Despacho debe ser A (Autoservicio) o P (Personalizado)" CHECK ((despacho = ANY (ARRAY['A'::text, 'P'::text]))),
    CONSTRAINT "texto invalido en nombrerubro de tabla rubros" CHECK (comun.cadena_valida(nombrerubro, 'castellano'::text))
);


ALTER TABLE cvp.rubros OWNER TO cvpowner;

--
-- Name: control_relev_telef; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_relev_telef AS
 SELECT r.periodo,
    r.panel,
    r.tarea,
    r.informante,
    i.nombreinformante,
    COALESCE((((((((i.nombrecalle)::text || ' '::text) || (i.altura)::text) || ' '::text) || (i.piso)::text) || ' '::text) || (i.departamento)::text), (i.direccion)::text) AS direccion,
    r.visita,
    (((((r.encuestador)::text || ':'::text) || (p.nombre)::text) || ' '::text) || (p.apellido)::text) AS encuestador,
    i.rubro,
    u.nombrerubro,
    string_agg((((r.formulario)::text || ':'::text) || (f.nombreformulario)::text), '; '::text) AS formularios
   FROM ((((cvp.relvis r
     LEFT JOIN cvp.formularios f ON ((r.formulario = f.formulario)))
     LEFT JOIN cvp.personal p ON (((r.encuestador)::text = (p.persona)::text)))
     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
     LEFT JOIN cvp.rubros u ON ((i.rubro = u.rubro)))
  WHERE ((u.telefonico)::text = 'S'::text)
  GROUP BY r.periodo, r.panel, r.tarea, r.informante, i.nombreinformante, COALESCE((((((((i.nombrecalle)::text || ' '::text) || (i.altura)::text) || ' '::text) || (i.piso)::text) || ' '::text) || (i.departamento)::text), (i.direccion)::text), r.visita, (((((r.encuestador)::text || ':'::text) || (p.nombre)::text) || ' '::text) || (p.apellido)::text), i.rubro, u.nombrerubro
  ORDER BY r.periodo, r.panel, r.tarea, r.informante;


ALTER TABLE cvp.control_relev_telef OWNER TO cvpowner;

--
-- Name: control_sinprecio; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_sinprecio AS
 SELECT p.periodo,
    p.informante,
    i.nombreinformante,
    i.tipoinformante,
    p.producto,
    o.nombreproducto,
    p.visita,
    p.observacion,
    v.panel,
    v.tarea,
    v.recepcionista
   FROM ((((((cvp.relpre p
     JOIN cvp.relpre p0 ON ((((p0.periodo)::text = cvp.moverperiodos((p.periodo)::text, '-1'::integer)) AND (p.informante = p0.informante) AND (p.visita = p0.visita) AND (p.observacion = p0.observacion) AND ((p.producto)::text = (p0.producto)::text) AND (((p0.tipoprecio)::text = 'S'::text) OR (p0.tipoprecio IS NULL)))))
     JOIN cvp.relpre p1 ON ((((p1.periodo)::text = cvp.moverperiodos((p.periodo)::text, '-2'::integer)) AND (p.informante = p1.informante) AND (p.visita = p1.visita) AND (p.observacion = p1.observacion) AND ((p.producto)::text = (p1.producto)::text) AND (((p1.tipoprecio)::text = 'S'::text) OR (p1.tipoprecio IS NULL)))))
     JOIN cvp.relpre p2 ON ((((p2.periodo)::text = cvp.moverperiodos((p.periodo)::text, '-3'::integer)) AND (p.informante = p2.informante) AND (p.visita = p2.visita) AND (p.observacion = p2.observacion) AND ((p.producto)::text = (p2.producto)::text) AND (((p2.tipoprecio)::text = 'S'::text) OR (p2.tipoprecio IS NULL)))))
     LEFT JOIN cvp.relvis v ON ((((p.periodo)::text = (v.periodo)::text) AND (p.informante = v.informante) AND (p.visita = v.visita) AND (p.formulario = v.formulario))))
     LEFT JOIN cvp.informantes i ON ((p.informante = i.informante)))
     LEFT JOIN cvp.productos o ON (((p.producto)::text = (o.producto)::text)))
  WHERE ((p.tipoprecio)::text = 'S'::text);


ALTER TABLE cvp.control_sinprecio OWNER TO cvpowner;

--
-- Name: control_sinvariacion; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_sinvariacion AS
 SELECT r.periodo,
    r.informante,
    i.nombreinformante,
    i.tipoinformante,
    r.producto,
    t.nombreproducto,
    r.visita,
    r.observacion,
    v.panel,
    v.tarea,
    v.recepcionista,
    r.precionormalizado,
    pre.cantprecios
   FROM (((((((((cvp.relpre r
     JOIN ( SELECT p_1.periodo,
            p_1.ano,
            p_1.mes,
            p_1.visita,
            p_1.ingresando,
            p_1.periodoanterior,
            p_1.fechageneracionperiodo,
            p_1.comentariosper,
            p_1.fechacalculoprereplote1,
            p_1.fechacalculoprereplote2,
            p_1.fecha_cierre_ingreso,
            p_1.cerraringresocampohastapanel,
            p_1.habilitado
           FROM (cvp.periodos p_1
             LEFT JOIN cvp.periodos p_sig ON (((p_sig.periodoanterior)::text = (p_1.periodo)::text)))
          WHERE (((p_1.ingresando)::text = 'S'::text) OR ((p_sig.ingresando)::text = 'S'::text))) p ON (((r.periodo)::text = (p.periodo)::text)))
     LEFT JOIN cvp.relvis v ON ((((r.periodo)::text = (v.periodo)::text) AND (r.informante = v.informante) AND (r.formulario = v.formulario) AND (r.visita = v.visita))))
     LEFT JOIN cvp.relpre r_1 ON ((((r_1.periodo)::text = cvp.moverperiodos((r.periodo)::text, '-1'::integer)) AND (r.informante = r_1.informante) AND (r.visita = r_1.visita) AND (r.observacion = r_1.observacion) AND ((r.producto)::text = (r_1.producto)::text))))
     LEFT JOIN cvp.relpre r_2 ON ((((r_2.periodo)::text = cvp.moverperiodos((r.periodo)::text, '-2'::integer)) AND (r.informante = r_2.informante) AND (r.visita = r_2.visita) AND (r.observacion = r_2.observacion) AND ((r.producto)::text = (r_2.producto)::text))))
     LEFT JOIN cvp.relpre r_3 ON ((((r_3.periodo)::text = cvp.moverperiodos((r.periodo)::text, '-3'::integer)) AND (r.informante = r_3.informante) AND (r.visita = r_3.visita) AND (r.observacion = r_3.observacion) AND ((r.producto)::text = (r_3.producto)::text))))
     LEFT JOIN cvp.relpre r_4 ON ((((r_4.periodo)::text = cvp.moverperiodos((r.periodo)::text, '-4'::integer)) AND (r.informante = r_4.informante) AND (r.visita = r_4.visita) AND (r.observacion = r_4.observacion) AND ((r.producto)::text = (r_4.producto)::text))))
     LEFT JOIN cvp.relpre r_5 ON ((((r_5.periodo)::text = cvp.moverperiodos((r.periodo)::text, '-5'::integer)) AND (r.informante = r_5.informante) AND (r.visita = r_5.visita) AND (r.observacion = r_5.observacion) AND ((r.producto)::text = (r_5.producto)::text))))
     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
     LEFT JOIN cvp.productos t ON (((r.producto)::text = (t.producto)::text))),
    LATERAL ( SELECT count(*) AS cantprecios
           FROM cvp.relpre
          WHERE ((relpre.informante = r.informante) AND ((relpre.producto)::text = (r.producto)::text) AND (relpre.visita = r.visita) AND (relpre.observacion = r.observacion) AND (relpre.precionormalizado = r.precionormalizado))) pre
  WHERE ((r.precionormalizado > (0)::double precision) AND (r_1.precionormalizado > (0)::double precision) AND (r_2.precionormalizado > (0)::double precision) AND (r_3.precionormalizado > (0)::double precision) AND (r_4.precionormalizado > (0)::double precision) AND (r_5.precionormalizado > (0)::double precision) AND (r.precionormalizado = r_1.precionormalizado) AND (r_1.precionormalizado = r_2.precionormalizado) AND (r_2.precionormalizado = r_3.precionormalizado) AND (r_3.precionormalizado = r_4.precionormalizado) AND (r_4.precionormalizado = r_5.precionormalizado));


ALTER TABLE cvp.control_sinvariacion OWNER TO cvpowner;

--
-- Name: perfiltro; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.perfiltro AS
 SELECT p.periodo
   FROM cvp.periodos p
  ORDER BY p.periodo DESC
 LIMIT 26;


ALTER TABLE cvp.perfiltro OWNER TO cvpowner;

--
-- Name: control_tipoprecio; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.control_tipoprecio AS
 SELECT p.periodo,
    p.producto,
    o.nombreproducto,
    i.tipoinformante,
    i.rubro,
    r.nombrerubro,
    p.tipoprecio,
    t.nombretipoprecio,
    (count(*))::integer AS cantidad
   FROM (((((( SELECT x.periodo,
            x.informante,
            x.formulario,
            x.panel,
            x.tarea,
            x.fechasalida,
            x.fechaingreso,
            x.ingresador,
            x.razon,
            x.fechageneracion,
            x.visita,
            x.ultimavisita,
            x.modi_usu,
            x.modi_fec,
            x.modi_ope,
            x.comentarios,
            x.encuestador,
            x.supervisor,
            x.recepcionista,
            x.informantereemplazante,
            x.ultima_visita,
            x.verificado_rec
           FROM (cvp.perfiltro p_1
             LEFT JOIN cvp.relvis x ON (((p_1.periodo)::text = (x.periodo)::text)))
          WHERE (x.razon = 1)) v
     LEFT JOIN cvp.relpre p ON ((((v.periodo)::text = (p.periodo)::text) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
     LEFT JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN cvp.productos o ON (((p.producto)::text = (o.producto)::text)))
     LEFT JOIN cvp.tipopre t ON (((p.tipoprecio)::text = (t.tipoprecio)::text)))
  WHERE (v.razon = 1)
  GROUP BY p.periodo, p.producto, o.nombreproducto, i.tipoinformante, i.rubro, r.nombrerubro, p.tipoprecio, t.nombretipoprecio
  ORDER BY p.periodo, p.producto, i.tipoinformante, i.rubro, p.tipoprecio;


ALTER TABLE cvp.control_tipoprecio OWNER TO cvpowner;

--
-- Name: controlvigencias; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.controlvigencias AS
 SELECT f.periodo,
    f.informante,
    f.producto,
    f.nombreproducto,
    f.observacion,
    f.valor,
    f.cantdias,
    f.ultimodiadelmes,
    f.visitas,
    f.vigencias,
    f.comentarios
   FROM ( SELECT a.periodo,
            a.informante,
            a.producto,
            u.nombreproducto,
            a.observacion,
            d.valor,
            COALESCE(comun.cuantos_dias_mes((a.periodo)::text, (d.valor)::text), 0) AS cantdias,
            date_part('day'::text, (((((substr(cvp.moverperiodos((a.periodo)::text, 1), 2, 4) || '-'::text) || substr(cvp.moverperiodos((a.periodo)::text, 1), 7, 2)) || '-01'::text))::date - '1 day'::interval)) AS ultimodiadelmes,
            (count(DISTINCT a.visita))::integer AS visitas,
            (sum((a.valor)::numeric))::integer AS vigencias,
            string_agg(((COALESCE(p.comentariosrelpre, ' '::text) || ' '::text) || COALESCE(p.observaciones, ' '::text)), ' '::text) AS comentarios
           FROM (((((cvp.relvis r
             LEFT JOIN cvp.relpre p ON ((((r.periodo)::text = (p.periodo)::text) AND (r.informante = p.informante) AND (r.visita = p.visita) AND (r.formulario = p.formulario))))
             LEFT JOIN cvp.relatr a ON ((((p.periodo)::text = (a.periodo)::text) AND ((p.producto)::text = (a.producto)::text) AND (p.observacion = a.observacion) AND (p.informante = a.informante) AND (p.visita = a.visita))))
             LEFT JOIN ( SELECT relatr.periodo,
                    relatr.producto,
                    relatr.observacion,
                    relatr.informante,
                    relatr.atributo,
                    relatr.valor,
                    relatr.visita,
                    relatr.modi_usu,
                    relatr.modi_fec,
                    relatr.modi_ope,
                    relatr.validar_con_valvalatr
                   FROM cvp.relatr
                  WHERE (relatr.atributo = 196)) d ON ((((a.periodo)::text = (d.periodo)::text) AND ((a.producto)::text = (d.producto)::text) AND (a.informante = d.informante) AND (a.observacion = d.observacion) AND (a.visita = d.visita))))
             LEFT JOIN cvp.atributos t ON ((a.atributo = t.atributo)))
             LEFT JOIN cvp.productos u ON (((a.producto)::text = (u.producto)::text)))
          WHERE (t.es_vigencia AND (r.razon = 1))
          GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, COALESCE(comun.cuantos_dias_mes((a.periodo)::text, (d.valor)::text), 0), (date_part('day'::text, (((((substr(cvp.moverperiodos((a.periodo)::text, 1), 2, 4) || '-'::text) || substr(cvp.moverperiodos((a.periodo)::text, 1), 7, 2)) || '-01'::text))::date - '1 day'::interval)))
          ORDER BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion) f
  WHERE (NOT (((f.visitas = 1) AND (f.vigencias = 1)) OR (f.ultimodiadelmes = (f.vigencias)::double precision) OR (f.cantdias = f.vigencias)));


ALTER TABLE cvp.controlvigencias OWNER TO cvpowner;

--
-- Name: cuadros; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.cuadros (
    cuadro text NOT NULL,
    descripcion text,
    funcion text,
    parametro1 text,
    periodo text,
    nivel integer,
    grupo text,
    agrupacion text,
    encabezado text,
    pie text,
    ponercodigos boolean,
    agrupacion2 text,
    hogares integer,
    pie1 text,
    cantdecimales integer,
    desde text,
    orden text,
    encabezado2 text,
    CONSTRAINT "texto invalido en descripcion de tabla cuadros" CHECK (comun.cadena_valida(descripcion, 'castellano'::text)),
    CONSTRAINT "texto invalido en parametro1 de tabla cuadros" CHECK (comun.cadena_valida(parametro1, 'castellano'::text)),
    CONSTRAINT "texto invalido en pie de tabla cuadros" CHECK (comun.cadena_valida(pie, 'amplio'::text))
);


ALTER TABLE cvp.cuadros OWNER TO cvpowner;

--
-- Name: cuadros_funciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.cuadros_funciones (
    funcion text NOT NULL,
    usa_parametro1 boolean,
    usa_periodo boolean,
    usa_nivel boolean,
    usa_grupo boolean,
    usa_agrupacion boolean,
    usa_ponercodigos boolean,
    usa_agrupacion2 boolean,
    usa_cuadro boolean,
    usa_hogares boolean,
    usa_cantdecimales boolean,
    usa_desde boolean,
    usa_orden boolean
);


ALTER TABLE cvp.cuadros_funciones OWNER TO cvpowner;

--
-- Name: cuagru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.cuagru (
    cuadro text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    orden integer
);


ALTER TABLE cvp.cuagru OWNER TO cvpowner;

--
-- Name: desvios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.desvios AS
 SELECT co.periodo,
    co.calculo,
    co.producto,
    prod.nombreproducto,
    sqrt(sum((expr.frec_n * ((co.promobs - expr.prom_aritmetico_pond) ^ (2)::double precision)))) AS desvio
   FROM ((cvp.calobs co
     JOIN cvp.productos prod ON (((prod.producto)::text = (co.producto)::text)))
     JOIN ( SELECT f.periodo,
            f.calculo,
            f.producto,
            f.division,
            f.frec_n,
            pp.prom_aritmetico_pond
           FROM (( SELECT c.periodo,
                    c.calculo,
                    c.producto,
                    c.division,
                    (
                        CASE
                            WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                            ELSE d.ponderadordiv
                        END / (count(*))::double precision) AS frec_n
                   FROM ((cvp.calobs c
                     JOIN ( SELECT gru_grupos.grupo
                           FROM cvp.gru_grupos
                          WHERE (((gru_grupos.agrupacion)::text = 'C'::text) AND ((gru_grupos.grupo_padre)::text = ANY (ARRAY['C1'::text, 'C2'::text])) AND ((gru_grupos.esproducto)::text = 'S'::text))) gg ON (((c.producto)::text = (gg.grupo)::text)))
                     LEFT JOIN cvp.caldiv d ON ((((c.periodo)::text = (d.periodo)::text) AND (c.calculo = d.calculo) AND ((c.division)::text = (d.division)::text) AND ((c.producto)::text = (d.producto)::text))))
                  WHERE ((c.calculo = 0) AND (c.antiguedadincluido > 0) AND (c.promobs <> (0)::double precision))
                  GROUP BY c.periodo, c.calculo, c.producto, c.division,
                        CASE
                            WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                            ELSE d.ponderadordiv
                        END
                  ORDER BY c.periodo, c.calculo, c.producto, c.division,
                        CASE
                            WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                            ELSE d.ponderadordiv
                        END) f
             JOIN ( SELECT p.periodo,
                    p.calculo,
                    p.producto,
                    sum((p.prom_aritmetico_pond_div * p.ponderadordiv)) AS prom_aritmetico_pond
                   FROM ( SELECT c.periodo,
                            c.calculo,
                            c.producto,
                            c.division,
                                CASE
                                    WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                                    ELSE d.ponderadordiv
                                END AS ponderadordiv,
                            avg(c.promobs) AS prom_aritmetico_pond_div
                           FROM ((cvp.calobs c
                             JOIN ( SELECT gru_grupos.grupo
                                   FROM cvp.gru_grupos
                                  WHERE (((gru_grupos.agrupacion)::text = 'C'::text) AND ((gru_grupos.grupo_padre)::text = ANY (ARRAY['C1'::text, 'C2'::text])) AND ((gru_grupos.esproducto)::text = 'S'::text))) gg ON (((c.producto)::text = (gg.grupo)::text)))
                             LEFT JOIN cvp.caldiv d ON ((((c.periodo)::text = (d.periodo)::text) AND (c.calculo = d.calculo) AND ((c.division)::text = (d.division)::text) AND ((c.producto)::text = (d.producto)::text))))
                          WHERE ((c.calculo = 0) AND (c.antiguedadincluido > 0) AND (c.promobs <> (0)::double precision))
                          GROUP BY c.periodo, c.calculo, c.producto, c.division,
                                CASE
                                    WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                                    ELSE d.ponderadordiv
                                END
                          ORDER BY c.periodo, c.calculo, c.producto, c.division,
                                CASE
                                    WHEN ((c.division)::text = '0'::text) THEN (1)::double precision
                                    ELSE d.ponderadordiv
                                END) p
                  GROUP BY p.periodo, p.calculo, p.producto
                  ORDER BY p.periodo, p.calculo, p.producto) pp ON ((((f.periodo)::text = (pp.periodo)::text) AND (f.calculo = pp.calculo) AND ((f.producto)::text = (pp.producto)::text))))) expr ON ((((co.periodo)::text = (expr.periodo)::text) AND (co.calculo = expr.calculo) AND ((co.producto)::text = (expr.producto)::text) AND ((co.division)::text = (expr.division)::text))))
  WHERE ((co.antiguedadincluido > 0) AND (co.promobs <> (0)::double precision) AND ((prod.calculo_desvios)::text = 'N'::text))
  GROUP BY co.periodo, co.calculo, co.producto, prod.nombreproducto
UNION
 SELECT ca.periodo,
    ca.calculo,
    ca.producto,
    prod.nombreproducto,
    sqrt(sum(((f2.frec_n)::double precision * ((ca.promdiv - f2.prom_aritmetico) ^ (2)::double precision)))) AS desvio
   FROM ((cvp.caldiv ca
     JOIN cvp.productos prod ON (((prod.producto)::text = (ca.producto)::text)))
     JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            ((1)::numeric / (count(*))::numeric) AS frec_n,
            avg(caldiv.promdiv) AS prom_aritmetico
           FROM cvp.caldiv
          WHERE ((caldiv.calculo = 0) AND (caldiv.profundidad = 1))
          GROUP BY caldiv.periodo, caldiv.calculo, caldiv.producto) f2 ON ((((ca.periodo)::text = (f2.periodo)::text) AND (ca.calculo = f2.calculo) AND ((ca.producto)::text = (f2.producto)::text))))
  WHERE (((prod.calculo_desvios)::text = 'E'::text) AND (ca.calculo = 0) AND (ca.profundidad = 1))
  GROUP BY ca.periodo, ca.calculo, ca.producto, prod.nombreproducto
  ORDER BY 1, 2, 3, 4;


ALTER TABLE cvp.desvios OWNER TO cvpowner;

--
-- Name: dicprodatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.dicprodatr (
    producto text NOT NULL,
    atributo integer NOT NULL,
    origen text NOT NULL,
    destino text,
    observaciones text,
    CONSTRAINT "texto invalido en destino de tabla dicprodatr" CHECK (comun.cadena_valida(destino, 'amplio'::text)),
    CONSTRAINT "texto invalido en observaciones de tabla dicprodatr" CHECK (comun.cadena_valida(observaciones, 'amplio'::text))
);


ALTER TABLE cvp.dicprodatr OWNER TO cvpowner;

--
-- Name: divisiones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.divisiones (
    division text NOT NULL,
    nombre_division text,
    incluye_supermercados boolean NOT NULL,
    incluye_tradicionales boolean NOT NULL,
    tipoinformante text,
    sindividir boolean,
    otradivision text,
    CONSTRAINT "La division sera igual a tipo de informante o sera sin dividir" CHECK (((NOT ((tipoinformante)::text IS DISTINCT FROM (division)::text)) OR ((tipoinformante IS NULL) AND (sindividir IS TRUE)))),
    CONSTRAINT divisiones_sindividir_check CHECK (sindividir),
    CONSTRAINT "la otra division es para los divididos y es otra" CHECK (((otradivision IS DISTINCT FROM (division)::text) OR sindividir)),
    CONSTRAINT "texto invalido en nombre_division de tabla divisiones" CHECK (comun.cadena_valida(nombre_division, 'castellano'::text))
);


ALTER TABLE cvp.divisiones OWNER TO cvpowner;

--
-- Name: especificaciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.especificaciones (
    producto text NOT NULL,
    especificacion integer NOT NULL,
    nombreespecificacion text,
    tamannonormal double precision,
    ponderadoresp double precision DEFAULT 1 NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    envase text,
    excluir text,
    cantidad numeric,
    unidaddemedida text,
    pesovolumenporunidad double precision,
    destacada boolean DEFAULT false,
    mostrar_cant_um text DEFAULT 'S'::text,
    observaciones text,
    CONSTRAINT "texto invalido en envase de tabla especificaciones" CHECK (comun.cadena_valida(envase, 'amplio'::text)),
    CONSTRAINT "texto invalido en excluir de tabla especificaciones" CHECK (comun.cadena_valida(excluir, 'amplio'::text)),
    CONSTRAINT "texto invalido en nombreespecificacion de tabla especificacione" CHECK (comun.cadena_valida(nombreespecificacion, 'amplio'::text)),
    CONSTRAINT "texto invalido en unidaddemedida de tabla especificaciones" CHECK (comun.cadena_valida(unidaddemedida, 'extendido'::text))
);


ALTER TABLE cvp.especificaciones OWNER TO cvpowner;

--
-- Name: estadoinformantes; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.estadoinformantes AS
 SELECT periodos.periodo,
    informantes.informante,
    informantes.conjuntomuestral,
    cvp.estadoinformante((periodos.periodo)::text, informantes.informante) AS estadoinformante
   FROM cvp.periodos,
    cvp.informantes;


ALTER TABLE cvp.estadoinformantes OWNER TO cvpowner;

--
-- Name: forobs; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.forobs AS
 SELECT fp.formulario,
    fp.producto,
    generate_series.generate_series AS observacion,
    1 AS especificacion,
    fp.orden,
    fp.ordenimpresion,
        CASE
            WHEN (p.cantobs IS NULL) THEN 'S'::text
            ELSE 'N'::text
        END AS dependedeldespacho
   FROM cvp.forprod fp,
    cvp.productos p,
    generate_series(1, 100) generate_series(generate_series)
  WHERE (((fp.producto)::text = (p.producto)::text) AND (generate_series.generate_series <= COALESCE(p.cantobs, 2)));


ALTER TABLE cvp.forobs OWNER TO cvpowner;

--
-- Name: foresp; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.foresp AS
 SELECT forobs.formulario,
    forobs.producto,
    forobs.observacion AS especificacion,
    forobs.orden
   FROM cvp.forobs;


ALTER TABLE cvp.foresp OWNER TO cvpowner;

--
-- Name: forinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.forinf (
    formulario integer NOT NULL,
    informante integer NOT NULL,
    cantobs integer,
    generar boolean DEFAULT true,
    altamanualperiodo text
);


ALTER TABLE cvp.forinf OWNER TO cvpowner;

--
-- Name: formulariosimportados; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.formulariosimportados (
    ano integer NOT NULL,
    mes integer NOT NULL,
    razon integer NOT NULL,
    informante integer NOT NULL,
    producto text NOT NULL,
    nombre text,
    observacion integer NOT NULL,
    atributo text NOT NULL,
    valor text,
    CONSTRAINT "texto invalido en atributo de tabla formulariosimportados" CHECK (comun.cadena_valida(atributo, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombre de tabla formulariosimportados" CHECK (comun.cadena_valida(nombre, 'castellano'::text)),
    CONSTRAINT "texto invalido en valor de tabla formulariosimportados" CHECK (comun.cadena_valida(valor, 'amplio'::text))
);


ALTER TABLE cvp.formulariosimportados OWNER TO cvpowner;

--
-- Name: forobsinf; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.forobsinf AS
 SELECT fi.informante,
    fp.formulario,
    fp.producto,
    generate_series.generate_series AS observacion,
    1 AS especificacion,
    fp.orden,
    fp.ordenimpresion,
        CASE
            WHEN (p.cantobs IS NULL) THEN 'S'::text
            ELSE 'N'::text
        END AS dependedeldespacho
   FROM cvp.forinf fi,
    cvp.forprod fp,
    cvp.productos p,
    generate_series(1, 100) generate_series(generate_series)
  WHERE ((fi.formulario = fp.formulario) AND ((fp.producto)::text = (p.producto)::text) AND (generate_series.generate_series <= COALESCE(fi.cantobs, COALESCE(p.cantobs, 2))));


ALTER TABLE cvp.forobsinf OWNER TO cvpowner;

--
-- Name: freccambio_nivel0; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel0 AS
 SELECT DISTINCT cvp.devolver_mes_anio((x.periodo)::text) AS periodonombre,
    x.periodo,
    substr((x.grupo)::text, 1, 2) AS grupo,
    u.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), u.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), u.nombregrupo, x.estado)) AS promgeoobsant,
    round(((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), u.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), u.nombregrupo, x.estado))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), x.estado) AS cantobsporestado,
    count(substr((x.grupo)::text, 1, 2)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2))) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2)), x.estado))::numeric / (count(substr((x.grupo)::text, 1, 2)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 2))))::numeric) * (100)::numeric), 2) AS porcobs
   FROM (( SELECT o.periodo,
            g.grupo,
                CASE
                    WHEN (o.promobs < o1.promobs) THEN 'Bajó'::text
                    WHEN (o.promobs > o1.promobs) THEN 'Subió'::text
                    ELSE 'Igual'::text
                END AS estado,
            o.producto,
            p.nombreproducto,
            o.informante,
            o.observacion,
            o.division,
            o.promobs,
            o.impobs,
            o1.promobs AS promobsant,
            o1.impobs AS impobsant,
            count(o.producto) OVER (PARTITION BY o.periodo, o.producto) AS cantobs
           FROM (((((cvp.calobs o
             LEFT JOIN cvp.calculos c ON ((((o.periodo)::text = (c.periodo)::text) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON ((((o1.periodo)::text = (c.periodoanterior)::text) AND (o1.calculo = c.calculoanterior) AND ((o.producto)::text = (o1.producto)::text) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON (((o.producto)::text = (gg.grupo)::text)))
             LEFT JOIN cvp.grupos g ON ((((gg.grupo_padre)::text = (g.grupo)::text) AND ((gg.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
          WHERE ((o.calculo = 0) AND ((g.agrupacion)::text = 'Z'::text) AND (g.nivel = 0) AND ((o.impobs)::text = 'R'::text) AND ((o1.impobs)::text = 'R'::text) AND ((g.grupo)::text <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
     LEFT JOIN cvp.grupos u ON ((substr((x.grupo)::text, 1, 2) = (u.grupo)::text)))
  WHERE ((x.cantobs > 6) AND ((x.periodo)::text >= 'a2017m01'::text))
  ORDER BY x.periodo, (substr((x.grupo)::text, 1, 2)), u.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel0 OWNER TO cvpowner;

--
-- Name: freccambio_nivel1; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel1 AS
 SELECT DISTINCT cvp.devolver_mes_anio((x.periodo)::text) AS periodonombre,
    x.periodo,
    substr((x.grupo)::text, 1, 3) AS grupo,
    u.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), u.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), u.nombregrupo, x.estado)) AS promgeoobsant,
    round(((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), u.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), u.nombregrupo, x.estado))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), x.estado) AS cantobsporestado,
    count(substr((x.grupo)::text, 1, 3)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3))) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3)), x.estado))::numeric / (count(substr((x.grupo)::text, 1, 3)) OVER (PARTITION BY x.periodo, (substr((x.grupo)::text, 1, 3))))::numeric) * (100)::numeric), 2) AS porcobs
   FROM (( SELECT o.periodo,
            g.grupo,
                CASE
                    WHEN (o.promobs < o1.promobs) THEN 'Bajó'::text
                    WHEN (o.promobs > o1.promobs) THEN 'Subió'::text
                    ELSE 'Igual'::text
                END AS estado,
            o.producto,
            p.nombreproducto,
            o.informante,
            o.observacion,
            o.division,
            o.promobs,
            o.impobs,
            o1.promobs AS promobsant,
            o1.impobs AS impobsant,
            count(o.producto) OVER (PARTITION BY o.periodo, o.producto) AS cantobs
           FROM (((((cvp.calobs o
             LEFT JOIN cvp.calculos c ON ((((o.periodo)::text = (c.periodo)::text) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON ((((o1.periodo)::text = (c.periodoanterior)::text) AND (o1.calculo = c.calculoanterior) AND ((o.producto)::text = (o1.producto)::text) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON (((o.producto)::text = (gg.grupo)::text)))
             LEFT JOIN cvp.grupos g ON ((((gg.grupo_padre)::text = (g.grupo)::text) AND ((gg.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
          WHERE ((o.calculo = 0) AND ((g.agrupacion)::text = 'Z'::text) AND (g.nivel = 3) AND ((o.impobs)::text = 'R'::text) AND ((o1.impobs)::text = 'R'::text) AND ((g.grupo)::text <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
     LEFT JOIN cvp.grupos u ON ((substr((x.grupo)::text, 1, 3) = (u.grupo)::text)))
  WHERE ((x.cantobs > 6) AND ((x.periodo)::text >= 'a2017m01'::text))
  ORDER BY x.periodo, (substr((x.grupo)::text, 1, 3)), u.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel1 OWNER TO cvpowner;

--
-- Name: freccambio_nivel3; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel3 AS
 SELECT DISTINCT cvp.devolver_mes_anio((x.periodo)::text) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round(((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado) AS cantobsporestado,
    count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))::numeric / (count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo))::numeric) * (100)::numeric), 2) AS porcobs
   FROM ( SELECT o.periodo,
            g.grupo,
            g.nombregrupo,
                CASE
                    WHEN (o.promobs < o1.promobs) THEN 'Bajó'::text
                    WHEN (o.promobs > o1.promobs) THEN 'Subió'::text
                    ELSE 'Igual'::text
                END AS estado,
            o.producto,
            p.nombreproducto,
            o.informante,
            o.observacion,
            o.division,
            o.promobs,
            o.impobs,
            o1.promobs AS promobsant,
            o1.impobs AS impobsant,
            count(o.producto) OVER (PARTITION BY o.periodo, o.producto) AS cantobs
           FROM (((((cvp.calobs o
             LEFT JOIN cvp.calculos c ON ((((o.periodo)::text = (c.periodo)::text) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON ((((o1.periodo)::text = (c.periodoanterior)::text) AND (o1.calculo = c.calculoanterior) AND ((o.producto)::text = (o1.producto)::text) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON (((o.producto)::text = (gg.grupo)::text)))
             LEFT JOIN cvp.grupos g ON ((((gg.grupo_padre)::text = (g.grupo)::text) AND ((gg.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
          WHERE ((o.calculo = 0) AND ((g.agrupacion)::text = 'Z'::text) AND (g.nivel = 3) AND ((o.impobs)::text = 'R'::text) AND ((o1.impobs)::text = 'R'::text) AND ((g.grupo)::text <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
  WHERE ((x.cantobs > 6) AND ((x.periodo)::text >= 'a2017m01'::text))
  ORDER BY x.periodo, x.grupo, x.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel3 OWNER TO cvpowner;

--
-- Name: freccambio_resto; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_resto AS
 SELECT DISTINCT cvp.devolver_mes_anio((x.periodo)::text) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round(((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado) AS cantobsporestado,
    count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))::numeric / (count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo))::numeric) * (100)::numeric), 2) AS porcobs
   FROM ( SELECT o.periodo,
            g.grupo,
            g.nombregrupo,
                CASE
                    WHEN (o.promobs < o1.promobs) THEN 'Bajó'::text
                    WHEN (o.promobs > o1.promobs) THEN 'Subió'::text
                    ELSE 'Igual'::text
                END AS estado,
            o.producto,
            p.nombreproducto,
            o.informante,
            o.observacion,
            o.division,
            o.promobs,
            o.impobs,
            o1.promobs AS promobsant,
            o1.impobs AS impobsant,
            count(o.producto) OVER (PARTITION BY o.periodo, o.producto) AS cantobs,
            gg.grupo_padre
           FROM ((((((cvp.calobs o
             LEFT JOIN cvp.calculos c ON ((((o.periodo)::text = (c.periodo)::text) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON ((((o1.periodo)::text = (c.periodoanterior)::text) AND (o1.calculo = c.calculoanterior) AND ((o.producto)::text = (o1.producto)::text) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
             LEFT JOIN cvp.gru_grupos gu ON ((((gu.agrupacion)::text = 'R'::text) AND ((gu.esproducto)::text = 'S'::text) AND ((gu.grupo)::text = (o.producto)::text) AND (length((gu.grupo_padre)::text) = 2))))
             LEFT JOIN cvp.grupos g ON ((((gu.grupo_padre)::text = (g.grupo)::text) AND ((gu.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.gru_grupos gg ON ((((gg.agrupacion)::text = 'Z'::text) AND ((gg.esproducto)::text = 'S'::text) AND ((gg.grupo)::text = (o.producto)::text) AND (length((gg.grupo_padre)::text) = 5))))
          WHERE ((o.calculo = 0) AND ((g.grupo)::text = 'R3'::text) AND ((o.impobs)::text = 'R'::text) AND ((o1.impobs)::text = 'R'::text) AND ((gg.grupo_padre)::text <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
  WHERE ((x.cantobs > 6) AND ((x.periodo)::text >= 'a2017m01'::text))
  ORDER BY x.periodo, x.grupo, x.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_resto OWNER TO cvpowner;

--
-- Name: freccambio_restorest; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_restorest AS
 SELECT DISTINCT cvp.devolver_mes_anio((x.periodo)::text) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round(((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado) AS cantobsporestado,
    count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))::numeric / (count(x.grupo) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo))::numeric) * (100)::numeric), 2) AS porcobs
   FROM ( SELECT o.periodo,
            g.grupo,
            g.nombregrupo,
                CASE
                    WHEN (o.promobs < o1.promobs) THEN 'Bajó'::text
                    WHEN (o.promobs > o1.promobs) THEN 'Subió'::text
                    ELSE 'Igual'::text
                END AS estado,
            o.producto,
            p.nombreproducto,
            o.informante,
            o.observacion,
            o.division,
            o.promobs,
            o.impobs,
            o1.promobs AS promobsant,
            o1.impobs AS impobsant,
            count(o.producto) OVER (PARTITION BY o.periodo, o.producto) AS cantobs,
            gg.grupo_padre
           FROM ((((((cvp.calobs o
             LEFT JOIN cvp.calculos c ON ((((o.periodo)::text = (c.periodo)::text) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON ((((o1.periodo)::text = (c.periodoanterior)::text) AND (o1.calculo = c.calculoanterior) AND ((o.producto)::text = (o1.producto)::text) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.productos p ON (((o.producto)::text = (p.producto)::text)))
             LEFT JOIN cvp.gru_grupos gu ON ((((gu.agrupacion)::text = 'R'::text) AND ((gu.esproducto)::text = 'S'::text) AND ((gu.grupo)::text = (o.producto)::text) AND (length((gu.grupo_padre)::text) = 2))))
             LEFT JOIN cvp.grupos g ON ((((gu.grupo_padre)::text = (g.grupo)::text) AND ((gu.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.gru_grupos gg ON ((((gg.agrupacion)::text = 'Z'::text) AND ((gg.esproducto)::text = 'S'::text) AND ((gg.grupo)::text = (o.producto)::text) AND (length((gg.grupo_padre)::text) = 5))))
          WHERE ((o.calculo = 0) AND ((g.grupo)::text = 'R3'::text) AND ((o.impobs)::text = 'R'::text) AND ((o1.impobs)::text = 'R'::text) AND ((gg.grupo_padre)::text <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text, 'Z0631'::text, 'Z1011'::text])))) x
  WHERE ((x.cantobs > 6) AND ((x.periodo)::text >= 'a2017m01'::text))
  ORDER BY x.periodo, x.grupo, x.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_restorest OWNER TO cvpowner;

--
-- Name: hdrexportar; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hdrexportar AS
 SELECT c.periodo,
    c.panel,
    c.tarea,
    c.fechasalida,
    c.informante,
    i.tipoinformante AS ti,
    c.encuestador,
    c.nombreencuestador,
    c.recepcionista,
    c.nombrerecepcionista,
    c.ingresador,
    c.nombreingresador,
    c.supervisor,
    c.nombresupervisor,
        CASE
            WHEN (min(c.razon) <> max(c.razon)) THEN ((min(c.razon) || '~'::text) || max(c.razon))
            ELSE COALESCE((min(c.razon) || ''::text), NULL::text)
        END AS razon,
    c.visita,
    c.nombreinformante,
    c.direccion,
    string_agg((((c.formulario)::text || ':'::text) || (c.nombreformulario)::text), '|'::text) AS formularios,
    (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text) AS contacto,
    c.conjuntomuestral,
    c.ordenhdr,
    i.distrito,
    i.fraccion,
    i.rubro,
    r.nombrerubro,
    a.maxperiodoinformado,
    a.minperiodoinformado
   FROM (((cvp.control_hojas_ruta c
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max((control_hojas_ruta.periodo)::text) AS maxperiodoinformado,
            min((control_hojas_ruta.periodo)::text) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado;


ALTER TABLE cvp.hdrexportar OWNER TO cvpowner;

--
-- Name: hdrexportarcierretemporal; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hdrexportarcierretemporal AS
 SELECT c.periodo,
    c.panel,
    c.tarea,
    c.fechasalida,
    c.informante,
    c.encuestador,
    c.nombreencuestador,
    c.recepcionista,
    c.nombrerecepcionista,
        CASE
            WHEN (min(c.razon) <> max(c.razon)) THEN ((min(c.razon) || '~'::text) || max(c.razon))
            ELSE COALESCE((min(c.razon) || ''::text), ''::text)
        END AS razon,
    c.visita,
    c.nombreinformante,
    c.direccion,
    string_agg((((c.formulario)::text || ':'::text) || (c.nombreformulario)::text), '|'::text) AS formularios,
    (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text) AS contacto,
    c.conjuntomuestral,
    c.ordenhdr,
    i.distrito,
    i.fraccion,
    i.rubro,
    r.nombrerubro,
    a.maxperiodoinformado
   FROM (((cvp.control_hojas_ruta c
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max((control_hojas_ruta.periodo)::text) AS maxperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  WHERE (c.razon = ANY (ARRAY[5, 6, 12]))
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, c.visita, c.nombreinformante, c.direccion, (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado;


ALTER TABLE cvp.hdrexportarcierretemporal OWNER TO cvpowner;

--
-- Name: hdrexportarefectivossinprecio; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hdrexportarefectivossinprecio AS
 SELECT c.periodo,
    c.panel,
    c.tarea,
    c.fechasalida,
    c.informante,
    c.encuestador,
    c.nombreencuestador,
    c.recepcionista,
    c.nombrerecepcionista,
    c.razon,
    c.visita,
    c.nombreinformante,
    c.direccion,
    c.formulario,
    c.nombreformulario,
    (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text) AS contacto,
    c.conjuntomuestral,
    c.ordenhdr,
    i.distrito,
    i.fraccion,
    i.rubro,
    r.nombrerubro,
    a.maxperiodoinformado,
    p.tipoprecios
   FROM ((((( SELECT control_hojas_ruta.periodo,
            control_hojas_ruta.panel,
            control_hojas_ruta.tarea,
            control_hojas_ruta.fechasalida,
            control_hojas_ruta.informante,
            control_hojas_ruta.encuestador,
            control_hojas_ruta.nombreencuestador,
            control_hojas_ruta.recepcionista,
            control_hojas_ruta.nombrerecepcionista,
            control_hojas_ruta.ingresador,
            control_hojas_ruta.nombreingresador,
            control_hojas_ruta.supervisor,
            control_hojas_ruta.nombresupervisor,
            control_hojas_ruta.formulario,
            control_hojas_ruta.nombreformulario,
            control_hojas_ruta.operativo,
            control_hojas_ruta.razon,
            control_hojas_ruta.razonanterior,
            control_hojas_ruta.visita,
            control_hojas_ruta.nombreinformante,
            control_hojas_ruta.direccion,
            control_hojas_ruta.conjuntomuestral,
            control_hojas_ruta.ordenhdr
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)) c
     JOIN ( SELECT relpre.periodo,
            relpre.informante,
            relpre.visita,
            relpre.formulario,
                CASE
                    WHEN ((min(relpre.precio) IS NULL) AND (max(relpre.precio) IS NULL)) THEN 'NO HAY PRECIO'::text
                    ELSE 'HAY PRECIO'::text
                END AS infoprecios,
            string_agg(DISTINCT (COALESCE(relpre.tipoprecio, 'Sin Valor'::text))::text, ';'::text) AS tipoprecios
           FROM cvp.relpre
          GROUP BY relpre.periodo, relpre.informante, relpre.visita, relpre.formulario) p ON ((((c.periodo)::text = (p.periodo)::text) AND (c.informante = p.informante) AND (c.visita = p.visita) AND (c.formulario = p.formulario))))
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max((control_hojas_ruta.periodo)::text) AS maxperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  WHERE (p.infoprecios = 'NO HAY PRECIO'::text);


ALTER TABLE cvp.hdrexportarefectivossinprecio OWNER TO cvpowner;

--
-- Name: tareas; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tareas (
    tarea integer NOT NULL,
    encuestador text,
    activa text DEFAULT 'S'::text,
    periodobaja text,
    operativo text,
    recepcionista text
);


ALTER TABLE cvp.tareas OWNER TO cvpowner;

--
-- Name: hdrexportarteorica; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hdrexportarteorica AS
 SELECT c.periodo,
    c.panel,
    c.tarea,
    c.informante,
    i.tipoinformante AS ti,
    (((((t.encuestador)::text || ':'::text) || (p.nombre)::text) || ' '::text) || (p.apellido)::text) AS encuestador,
    COALESCE(string_agg(DISTINCT (((c.encuestador)::text || ':'::text) || c.nombreencuestador), '|'::text), NULL::text) AS encuestadores,
    COALESCE(string_agg(DISTINCT (((c.recepcionista)::text || ':'::text) || c.nombrerecepcionista), '|'::text), NULL::text) AS recepcionistas,
    COALESCE(string_agg(DISTINCT (((c.ingresador)::text || ':'::text) || c.nombreingresador), '|'::text), NULL::text) AS ingresadores,
    COALESCE(string_agg(DISTINCT (((c.supervisor)::text || ':'::text) || c.nombresupervisor), '|'::text), NULL::text) AS supervisores,
        CASE
            WHEN (min(c.razon) <> max(c.razon)) THEN ((min(c.razon) || '~'::text) || max(c.razon))
            ELSE COALESCE((min(c.razon) || ''::text), NULL::text)
        END AS razon,
    string_agg((((c.formulario)::text || ' '::text) || (c.nombreformulario)::text), chr(10) ORDER BY c.formulario) AS formularioshdr,
    lpad(' '::text, (count(*))::integer, chr(10)) AS espacio,
    c.visita,
    c.nombreinformante,
    c.direccion,
    string_agg((((c.formulario)::text || ':'::text) || (c.nombreformulario)::text), '|'::text) AS formularios,
    (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text) AS contacto,
    c.conjuntomuestral,
    c.ordenhdr,
    i.distrito,
    i.fraccion,
    i.rubro,
    r.nombrerubro,
    a.maxperiodoinformado,
    a.minperiodoinformado,
    c.fechasalida
   FROM (((((cvp.control_hojas_ruta c
     LEFT JOIN cvp.tareas t ON ((c.tarea = t.tarea)))
     LEFT JOIN cvp.personal p ON (((p.persona)::text = (t.encuestador)::text)))
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max((control_hojas_ruta.periodo)::text) AS maxperiodoinformado,
            min((control_hojas_ruta.periodo)::text) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, (((((t.encuestador)::text || ':'::text) || (p.nombre)::text) || ' '::text) || (p.apellido)::text), c.visita, c.nombreinformante, c.direccion, (((COALESCE(i.contacto, ''::text))::text || ' '::text) || (COALESCE(i.telcontacto, ''::text))::text), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida;


ALTER TABLE cvp.hdrexportarteorica OWNER TO cvpowner;

--
-- Name: hogares; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.hogares (
    hogar text NOT NULL,
    nombrehogar text NOT NULL,
    CONSTRAINT "texto invalido en hogar de tabla hogares" CHECK (comun.cadena_valida(hogar, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombrehogar de tabla hogares" CHECK (comun.cadena_valida(nombrehogar, 'amplio'::text))
);


ALTER TABLE cvp.hogares OWNER TO cvpowner;

--
-- Name: hojaderuta; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hojaderuta AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.fechasalida,
    v.informante,
    i.tipoinformante,
    v.encuestador,
    (COALESCE(((p.nombre)::text || ' '::text), ''::text) || (COALESCE(p.apellido, ''::text))::text) AS nombreencuestador,
    (
        CASE
            WHEN (min(v.razon) <> max(v.razon)) THEN ((min(v.razon) || '~'::text) || max(v.razon))
            ELSE COALESCE((min(v.razon) || ''::text), ''::text)
        END || lpad(' '::text, (count(*))::integer, chr(10))) AS razon,
    v.visita,
    i.nombreinformante,
    i.direccion,
    cvp.formularioshdr((v.periodo)::text, v.informante, v.visita, v.fechasalida, (v.encuestador)::text) AS formularios,
    lpad(' '::text, (count(*))::integer, chr(10)) AS espacio,
    (((COALESCE(i.contacto, ''::text))::text || chr(10)) || (COALESCE(i.telcontacto, ''::text))::text) AS contacto,
    i.conjuntomuestral,
    i.ordenhdr,
    a.maxperiodoinformado,
    a.minperiodoinformado
   FROM (((cvp.relvis v
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.personal p ON (((v.encuestador)::text = (p.persona)::text)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max((control_hojas_ruta.periodo)::text) AS maxperiodoinformado,
            min((control_hojas_ruta.periodo)::text) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((v.informante = a.informante) AND (v.visita = a.visita))))
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, i.tipoinformante, v.encuestador, v.visita, (COALESCE(((p.nombre)::text || ' '::text), ''::text) || (COALESCE(p.apellido, ''::text))::text), (((COALESCE(i.contacto, ''::text))::text || chr(10)) || (COALESCE(i.telcontacto, ''::text))::text), i.nombreinformante, i.direccion, i.conjuntomuestral, i.ordenhdr, a.maxperiodoinformado, a.minperiodoinformado;


ALTER TABLE cvp.hojaderuta OWNER TO cvpowner;

--
-- Name: reltar; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.reltar (
    periodo text NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    supervisor text,
    encuestador text,
    realizada text,
    resultado text,
    observaciones text,
    puntos integer,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    cargado timestamp without time zone,
    descargado timestamp without time zone,
    vencimiento_sincronizacion timestamp without time zone,
    id_instalacion integer,
    CONSTRAINT "texto invalido en observaciones de tabla reltar" CHECK (comun.cadena_valida(observaciones, 'castellano'::text)),
    CONSTRAINT "texto invalido en resultado de tabla reltar" CHECK (comun.cadena_valida(resultado, 'castellano'::text))
);


ALTER TABLE cvp.reltar OWNER TO cvpowner;

--
-- Name: hojaderutasupervisor; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hojaderutasupervisor AS
 SELECT p.persona AS supervisor,
    (((p.nombre)::text || ' '::text) || (p.apellido)::text) AS nombresupervisor,
    h.periodo,
    h.panel,
    h.tarea,
    h.fechasalida,
    h.informante,
    h.tipoinformante,
    h.encuestador,
    h.nombreencuestador,
    h.razon,
    h.visita,
    h.nombreinformante,
    h.direccion,
    h.formularios,
    h.espacio,
    h.contacto,
    h.conjuntomuestral,
    h.ordenhdr,
    h.maxperiodoinformado,
    h.minperiodoinformado
   FROM cvp.reltar r,
    cvp.hojaderuta h,
    cvp.personal p
  WHERE (((r.periodo)::text = (h.periodo)::text) AND (r.panel = h.panel) AND (r.tarea = h.tarea) AND ((r.encuestador)::text = (h.encuestador)::text) AND (r.supervisor IS NOT NULL) AND ((r.supervisor)::text = (p.persona)::text));


ALTER TABLE cvp.hojaderutasupervisor OWNER TO cvpowner;

--
-- Name: infoextprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.infoextprod (
    producto text NOT NULL,
    ponderacion double precision,
    sigueexterno text,
    cantporunidcons double precision
);


ALTER TABLE cvp.infoextprod OWNER TO cvpowner;

--
-- Name: infoextvalor; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.infoextvalor (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    promedioext double precision,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    CONSTRAINT "PromedioExt en InfoExt >0" CHECK ((promedioext > (0)::double precision))
);


ALTER TABLE cvp.infoextvalor OWNER TO cvpowner;

--
-- Name: informantesaltasbajas; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.informantesaltasbajas AS
 SELECT x.periodoanterior,
    x.informante,
    x.visita,
    x.rubro,
    x.nombrerubro,
    x.formulario,
    x.nombreformulario,
    x.panelanterior,
    x.tareaanterior,
    x.razonanterior,
    x.nombrerazonanterior,
    x.periodo,
    x.panel,
    x.tarea,
    x.razon,
    x.nombrerazon,
    x.tipo,
    x.distrito,
    x.fraccion,
    ca.cantformactivos
   FROM (( SELECT r_1.periodo AS periodoanterior,
            r_1.informante AS informanteanterior,
            i.rubro,
            ru.nombrerubro,
            r_1.formulario AS formularioanterior,
            f.nombreformulario,
            r_1.visita AS visitaanterior,
            r_1.panel AS panelanterior,
            r_1.tarea AS tareaanterior,
            r_1.razon AS razonanterior,
            zr_1.nombrerazon AS nombrerazonanterior,
            r.periodo,
            r.informante,
            r.formulario,
            r.visita,
            r.panel,
            r.tarea,
            r.razon,
            zr.nombrerazon,
                CASE
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL) AND (((zr.escierredefinitivoinf)::text = 'S'::text) OR ((zr.escierredefinitivofor)::text = 'S'::text))) THEN ('Alta-Baja en '::text || (r.periodo)::text)
                    WHEN (((zr.escierredefinitivoinf)::text = 'S'::text) OR ((zr.escierredefinitivofor)::text = 'S'::text)) THEN ('Baja en '::text || (r.periodo)::text)
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'Alta'::text
                    WHEN (((zr_1.escierredefinitivoinf)::text = 'S'::text) OR ((zr_1.escierredefinitivofor)::text = 'S'::text)) THEN ('Baja en '::text || (r_1.periodo)::text)
                    WHEN (r_1.razon IS NULL) THEN ('No ingresado '::text || (r_1.periodo)::text)
                    WHEN (r.razon IS NULL) THEN ('No ingresado '::text || (r.periodo)::text)
                    ELSE 'Continuo'::text
                END AS tipo,
            i.distrito,
            i.fraccion
           FROM (((((((cvp.relvis r
             LEFT JOIN cvp.periodos p ON (((p.periodo)::text = (r.periodo)::text)))
             LEFT JOIN cvp.relvis r_1 ON ((((r_1.periodo)::text = (p.periodoanterior)::text) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
             LEFT JOIN cvp.razones zr ON ((r.razon = zr.razon)))
             LEFT JOIN cvp.razones zr_1 ON ((r_1.razon = zr_1.razon)))
             LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
             LEFT JOIN cvp.rubros ru ON ((i.rubro = ru.rubro)))
             LEFT JOIN cvp.formularios f ON ((r_1.formulario = f.formulario)))
        UNION
         SELECT r_1.periodo AS periodoanterior,
            r_1.informante AS informanteanterior,
            i.rubro,
            ru.nombrerubro,
            r_1.formulario AS formularioanterior,
            f.nombreformulario,
            r_1.visita AS visitaanterior,
            r_1.panel AS panelanterior,
            r_1.tarea AS tareaanterior,
            r_1.razon AS razonanterior,
            zr_1.nombrerazon AS nombrerazonanterior,
            r.periodo,
            r.informante,
            r.formulario,
            r.visita,
            r.panel,
            r.tarea,
            r.razon,
            zr.nombrerazon,
                CASE
                    WHEN (((zr.escierredefinitivoinf)::text = 'S'::text) OR ((zr.escierredefinitivofor)::text = 'S'::text)) THEN ('Baja en '::text || (r.periodo)::text)
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'Alta'::text
                    WHEN (((zr_1.escierredefinitivoinf)::text = 'S'::text) OR ((zr_1.escierredefinitivofor)::text = 'S'::text)) THEN ('Baja en '::text || (r_1.periodo)::text)
                    WHEN (r_1.razon IS NULL) THEN ('No ingresado '::text || (r_1.periodo)::text)
                    WHEN (r.razon IS NULL) THEN ('No ingresado '::text || (r.periodo)::text)
                    ELSE 'Continuo'::text
                END AS tipo,
            i.distrito,
            i.fraccion
           FROM (((((((cvp.relvis r_1
             LEFT JOIN cvp.periodos p ON (((p.periodoanterior)::text = (r_1.periodo)::text)))
             LEFT JOIN cvp.relvis r ON ((((r.periodo)::text = (p.periodo)::text) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
             LEFT JOIN cvp.razones zr ON ((r.razon = zr.razon)))
             LEFT JOIN cvp.razones zr_1 ON ((r_1.razon = zr_1.razon)))
             LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
             LEFT JOIN cvp.rubros ru ON ((i.rubro = ru.rubro)))
             LEFT JOIN cvp.formularios f ON ((r_1.formulario = f.formulario)))) x
     LEFT JOIN ( SELECT v.periodo,
            v.informante,
            v.visita,
            (count(*))::integer AS cantformactivos
           FROM (cvp.relvis v
             LEFT JOIN cvp.razones s ON ((v.razon = s.razon)))
          WHERE (NOT (((s.escierredefinitivoinf)::text = 'S'::text) OR ((s.escierredefinitivofor)::text = 'S'::text)))
          GROUP BY v.periodo, v.informante, v.visita) ca ON ((((x.periodo)::text = (ca.periodo)::text) AND (x.informante = ca.informante) AND (x.visita = ca.visita))))
  WHERE ((x.tipo <> 'Continuo'::text) AND (x.tipo <> ('No ingresado '::text || (x.periodo)::text)))
  ORDER BY x.periodoanterior, x.informanteanterior, x.visitaanterior, x.formularioanterior;


ALTER TABLE cvp.informantesaltasbajas OWNER TO cvpowner;

--
-- Name: informantesformulario; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.informantesformulario AS
 SELECT g.periodo,
    g.formulario,
    g.nombreformulario,
    (sum(
        CASE
            WHEN (g.activos ~~ '%S%'::text) THEN 1
            ELSE 0
        END))::integer AS cantactivos,
    (sum(
        CASE
            WHEN (g.altas ~~ '%S%'::text) THEN 1
            ELSE 0
        END))::integer AS cantaltas,
    (sum(
        CASE
            WHEN (g.bajas ~~ '%S%'::text) THEN 1
            ELSE 0
        END))::integer AS cantbajas
   FROM ( SELECT x.periodo,
            x.informante,
            x.formulario,
            x.nombreformulario,
            string_agg(DISTINCT x.activos, ','::text) AS activos,
            string_agg(DISTINCT x.altas, ','::text) AS altas,
            string_agg(DISTINCT x.bajas, ','::text) AS bajas
           FROM ( SELECT r.periodo,
                    r.informante,
                    r.visita,
                    r.formulario,
                    f.nombreformulario,
                    r.razon,
                    r_1.periodo AS periodoant,
                        CASE
                            WHEN (((COALESCE((z.escierredefinitivoinf)::text, 'N'::text))::text = 'N'::text) AND ((COALESCE((z.escierredefinitivofor)::text, 'N'::text))::text = 'N'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS activos,
                        CASE
                            WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS altas,
                        CASE
                            WHEN (((COALESCE((z.escierredefinitivoinf)::text, 'N'::text))::text = 'S'::text) OR ((COALESCE((z.escierredefinitivofor)::text, 'N'::text))::text = 'S'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS bajas
                   FROM (((((cvp.relvis r
                     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
                     LEFT JOIN cvp.periodos p ON (((r.periodo)::text = (p.periodo)::text)))
                     LEFT JOIN cvp.relvis r_1 ON ((((p.periodoanterior)::text = (r_1.periodo)::text) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita) AND (r.informante = r_1.informante))))
                     LEFT JOIN cvp.formularios f ON ((r.formulario = f.formulario)))
                     LEFT JOIN cvp.razones z ON ((r.razon = z.razon)))
                  WHERE (r.visita = 1)) x
          GROUP BY x.periodo, x.informante, x.formulario, x.nombreformulario
          ORDER BY x.periodo, x.informante, x.formulario, x.nombreformulario) g
  GROUP BY g.periodo, g.formulario, g.nombreformulario
  ORDER BY g.periodo, g.formulario, g.nombreformulario;


ALTER TABLE cvp.informantesformulario OWNER TO cvpowner;

--
-- Name: informantesrazon; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.informantesrazon AS
 SELECT r.periodo,
    NULLIF(btrim(replace(r.razon, chr(10), ''::text)), ''::text) AS razon,
    (((z.nombrerazon)::text || COALESCE(('~'::text || (x.nombrerazon)::text), ''::text)))::text AS nombrerazon,
    (sum(((length(r.formularios) - length(replace(r.formularios, chr(10), ''::text))) + 1)))::integer AS cantformularios,
    (count(DISTINCT r.informante))::integer AS cantinformantes
   FROM ((cvp.hojaderuta r
     LEFT JOIN cvp.razones z ON ((
        CASE
            WHEN (strpos(r.razon, '~'::text) > 0) THEN btrim(substr(replace(r.razon, chr(10), ''::text), 1, (strpos(replace(r.razon, chr(10), ''::text), '~'::text) - 1)))
            ELSE btrim(replace(r.razon, chr(10), ''::text))
        END = (z.razon)::text)))
     LEFT JOIN cvp.razones x ON ((
        CASE
            WHEN (strpos(r.razon, '~'::text) > 0) THEN btrim(substr(replace(r.razon, chr(10), ''::text), (strpos(replace(r.razon, chr(10), ''::text), '~'::text) + 1)))
            ELSE ''::text
        END = (x.razon)::text)))
  WHERE (r.visita = 1)
  GROUP BY r.periodo, NULLIF(btrim(replace(r.razon, chr(10), ''::text)), ''::text), ((((z.nombrerazon)::text || COALESCE(('~'::text || (x.nombrerazon)::text), ''::text)))::text)
  ORDER BY r.periodo, NULLIF(btrim(replace(r.razon, chr(10), ''::text)), ''::text), ((((z.nombrerazon)::text || COALESCE(('~'::text || (x.nombrerazon)::text), ''::text)))::text);


ALTER TABLE cvp.informantesrazon OWNER TO cvpowner;

--
-- Name: informantesrubro; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.informantesrubro AS
 SELECT g.periodo,
    g.rubro,
    g.nombrerubro,
    (sum(
        CASE
            WHEN (g.activos ~~ '%S%'::text) THEN 1
            ELSE 0
        END))::integer AS cantactivos,
    (sum(
        CASE
            WHEN ((g.altas ~~ '%S%'::text) AND (g.altas !~~ '%N%'::text)) THEN 1
            ELSE 0
        END))::integer AS cantaltas,
    (sum(
        CASE
            WHEN ((g.bajas ~~ '%S%'::text) AND (g.bajas !~~ '%N%'::text)) THEN 1
            ELSE 0
        END))::integer AS cantbajas
   FROM ( SELECT x.periodo,
            x.informante,
            x.rubro,
            x.nombrerubro,
            string_agg(DISTINCT x.activos, ','::text) AS activos,
            string_agg(DISTINCT x.altas, ','::text) AS altas,
            string_agg(DISTINCT x.bajas, ','::text) AS bajas
           FROM ( SELECT r.periodo,
                    r.informante,
                    r.visita,
                    r.formulario,
                    i.rubro,
                    u.nombrerubro,
                    r.razon,
                    r_1.periodo AS periodoant,
                        CASE
                            WHEN (((COALESCE((z.escierredefinitivoinf)::text, 'N'::text))::text = 'N'::text) AND ((COALESCE((z.escierredefinitivofor)::text, 'N'::text))::text = 'N'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS activos,
                        CASE
                            WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS altas,
                        CASE
                            WHEN (((COALESCE((z.escierredefinitivoinf)::text, 'N'::text))::text = 'S'::text) OR ((COALESCE((z.escierredefinitivofor)::text, 'N'::text))::text = 'S'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS bajas
                   FROM (((((cvp.relvis r
                     LEFT JOIN cvp.periodos p ON (((r.periodo)::text = (p.periodo)::text)))
                     LEFT JOIN cvp.relvis r_1 ON ((((p.periodoanterior)::text = (r_1.periodo)::text) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita) AND (r.informante = r_1.informante))))
                     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
                     LEFT JOIN cvp.rubros u ON ((i.rubro = u.rubro)))
                     LEFT JOIN cvp.razones z ON ((r.razon = z.razon)))
                  WHERE (r.visita = 1)) x
          GROUP BY x.periodo, x.informante, x.rubro, x.nombrerubro
          ORDER BY x.periodo, x.informante, x.rubro, x.nombrerubro) g
  GROUP BY g.periodo, g.rubro, g.nombrerubro
  ORDER BY g.periodo, g.rubro, g.nombrerubro;


ALTER TABLE cvp.informantesrubro OWNER TO cvpowner;

--
-- Name: secuencia_informantes_reemplazantes; Type: SEQUENCE; Schema: cvp; Owner: cvpowner
--

CREATE SEQUENCE cvp.secuencia_informantes_reemplazantes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cvp.secuencia_informantes_reemplazantes OWNER TO cvpowner;

--
-- Name: infreemp; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.infreemp (
    informante integer NOT NULL,
    direccionalternativa text,
    nombreinformantealternativo text,
    comentarioana text,
    comentariorecep text,
    reemplazo integer,
    alta_fec timestamp without time zone DEFAULT now(),
    id_informante_reemplazante integer DEFAULT nextval('cvp.secuencia_informantes_reemplazantes'::regclass) NOT NULL,
    CONSTRAINT "texto invalido en direccion alternativa de tabla infreemp" CHECK (comun.cadena_valida(direccionalternativa, 'amplio'::text))
);


ALTER TABLE cvp.infreemp OWNER TO cvpowner;

--
-- Name: secuencia_instalaciones; Type: SEQUENCE; Schema: cvp; Owner: cvpowner
--

CREATE SEQUENCE cvp.secuencia_instalaciones
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cvp.secuencia_instalaciones OWNER TO cvpowner;

--
-- Name: instalaciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.instalaciones (
    token_instalacion text NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    encuestador text NOT NULL,
    ipad text NOT NULL,
    version_sistema text NOT NULL,
    token_original text NOT NULL,
    id_instalacion integer DEFAULT nextval('cvp.secuencia_instalaciones'::regclass) NOT NULL,
);


ALTER TABLE cvp.instalaciones OWNER TO cvpowner;

--
-- Name: locks; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.locks (
    table_name text NOT NULL,
    record_pk jsonb NOT NULL,
    token text NOT NULL,
    lock_datetime timestamp without time zone NOT NULL,
    unlock_datetime timestamp without time zone,
);


ALTER TABLE cvp.locks OWNER TO cvpowner;

--
-- Name: magnitudes; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.magnitudes (
    magnitud text NOT NULL,
    nombremagnitud text,
    unidadprincipalsingular text,
    unidadprincipalplural text,
    CONSTRAINT "texto invalido en magnitud de tabla magnitudes" CHECK (comun.cadena_valida(magnitud, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombremagnitud de tabla magnitudes" CHECK (comun.cadena_valida(nombremagnitud, 'castellano'::text)),
    CONSTRAINT "texto invalido en unidadprincipalplural de tabla magnitudes" CHECK (comun.cadena_valida(unidadprincipalplural, 'extendido'::text)),
    CONSTRAINT "texto invalido en unidadprincipalsingular de tabla magnitudes" CHECK (comun.cadena_valida(unidadprincipalsingular, 'extendido'::text))
);


ALTER TABLE cvp.magnitudes OWNER TO cvpowner;

--
-- Name: matrizresultados; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.matrizresultados AS
 SELECT x.producto,
    x.tipoinformante,
    x.informante,
    x.observacion,
    round((col1.promobs)::numeric, 2) AS promobs_1,
    round((p1.precio)::numeric, 2) AS precioobservado_1,
    col1.impobs AS impobs_1,
    col1.antiguedadexcluido AS antiguedadexcluido_1,
    col1.antiguedadsinprecio AS antiguedadsinprecio_1,
    col1.antiguedadconprecio AS antiguedadconprecio_1,
    (round(((((col1.promobs / col0.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_1,
    p1.tipoprecio AS tipoprecio_1,
    v1.razon AS razon_1,
    round((col2.promobs)::numeric, 2) AS promobs_2,
    round((p2.precio)::numeric, 2) AS precioobservado_2,
    col2.impobs AS impobs_2,
    col2.antiguedadexcluido AS antiguedadexcluido_2,
    col2.antiguedadsinprecio AS antiguedadsinprecio_2,
    col2.antiguedadconprecio AS antiguedadconprecio_2,
    (round(((((col2.promobs / col1.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_2,
    p2.tipoprecio AS tipoprecio_2,
    v2.razon AS razon_2,
    round((col3.promobs)::numeric, 2) AS promobs_3,
    round((p3.precio)::numeric, 2) AS precioobservado_3,
    col3.impobs AS impobs_3,
    col3.antiguedadexcluido AS antiguedadexcluido_3,
    col3.antiguedadsinprecio AS antiguedadsinprecio_3,
    col3.antiguedadconprecio AS antiguedadconprecio_3,
    (round(((((col3.promobs / col2.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_3,
    p3.tipoprecio AS tipoprecio_3,
    v3.razon AS razon_3,
    round((col4.promobs)::numeric, 2) AS promobs_4,
    round((p4.precio)::numeric, 2) AS precioobservado_4,
    col4.impobs AS impobs_4,
    col4.antiguedadexcluido AS antiguedadexcluido_4,
    col4.antiguedadsinprecio AS antiguedadsinprecio_4,
    col4.antiguedadconprecio AS antiguedadconprecio_4,
    (round(((((col4.promobs / col3.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_4,
    p4.tipoprecio AS tipoprecio_4,
    v4.razon AS razon_4,
    round((col5.promobs)::numeric, 2) AS promobs_5,
    round((p5.precio)::numeric, 2) AS precioobservado_5,
    col5.impobs AS impobs_5,
    col5.antiguedadexcluido AS antiguedadexcluido_5,
    col5.antiguedadsinprecio AS antiguedadsinprecio_5,
    col5.antiguedadconprecio AS antiguedadconprecio_5,
    (round(((((col5.promobs / col4.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_5,
    p5.tipoprecio AS tipoprecio_5,
    v5.razon AS razon_5,
    round((col6.promobs)::numeric, 2) AS promobs_6,
    round((p6.precio)::numeric, 2) AS precioobservado_6,
    col6.impobs AS impobs_6,
    col6.antiguedadexcluido AS antiguedadexcluido_6,
    col6.antiguedadsinprecio AS antiguedadsinprecio_6,
    col6.antiguedadconprecio AS antiguedadconprecio_6,
    (round(((((col6.promobs / col5.promobs) * (100)::double precision) - (100)::double precision))::numeric, 1))::numeric(8,1) AS variacion_6,
    p6.tipoprecio AS tipoprecio_6,
    v6.razon AS razon_6,
    cvp.matrizresultados_atributos_fun((p.periodo1)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_1,
    cvp.matrizresultados_atributos_fun((p.periodo2)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_2,
    cvp.matrizresultados_atributos_fun((p.periodo3)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_3,
    cvp.matrizresultados_atributos_fun((p.periodo4)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_4,
    cvp.matrizresultados_atributos_fun((p.periodo5)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_5,
    cvp.matrizresultados_atributos_fun((p.periodo6)::text, x.informante, (x.producto)::text, x.observacion, 1) AS atributo_6,
    p.periodo6
   FROM (((((((((((((((((((((cvp.matrizperiodos6 p
     JOIN ( SELECT r.producto,
            i.tipoinformante,
            r.informante,
            r.observacion,
            a.periodo6
           FROM cvp.calobs r,
            cvp.matrizperiodos6 a,
            cvp.informantes i
          WHERE (((a.periodo1 IS NULL) OR ((r.periodo)::text >= (a.periodo1)::text)) AND ((r.periodo)::text <= (a.periodo6)::text) AND (r.informante = i.informante))
          GROUP BY r.producto, i.tipoinformante, r.informante, r.observacion, a.periodo6) x ON (((x.periodo6)::text = (p.periodo6)::text)))
     LEFT JOIN cvp.calobs col1 ON (((col1.informante = x.informante) AND (col1.observacion = x.observacion) AND ((col1.producto)::text = (x.producto)::text) AND ((col1.periodo)::text = (p.periodo1)::text) AND (col1.calculo = 0))))
     LEFT JOIN cvp.calobs col2 ON (((col2.informante = x.informante) AND (col2.observacion = x.observacion) AND ((col2.producto)::text = (x.producto)::text) AND ((col2.periodo)::text = (p.periodo2)::text) AND (col2.calculo = 0))))
     LEFT JOIN cvp.calobs col3 ON (((col3.informante = x.informante) AND (col3.observacion = x.observacion) AND ((col3.producto)::text = (x.producto)::text) AND ((col3.periodo)::text = (p.periodo3)::text) AND (col3.calculo = 0))))
     LEFT JOIN cvp.calobs col4 ON (((col4.informante = x.informante) AND (col4.observacion = x.observacion) AND ((col4.producto)::text = (x.producto)::text) AND ((col4.periodo)::text = (p.periodo4)::text) AND (col4.calculo = 0))))
     LEFT JOIN cvp.calobs col5 ON (((col5.informante = x.informante) AND (col5.observacion = x.observacion) AND ((col5.producto)::text = (x.producto)::text) AND ((col5.periodo)::text = (p.periodo5)::text) AND (col5.calculo = 0))))
     LEFT JOIN cvp.calobs col6 ON (((col6.informante = x.informante) AND (col6.observacion = x.observacion) AND ((col6.producto)::text = (x.producto)::text) AND ((col6.periodo)::text = (p.periodo6)::text) AND (col6.calculo = 0))))
     LEFT JOIN cvp.relpre p1 ON (((p1.informante = x.informante) AND (p1.observacion = x.observacion) AND ((p1.producto)::text = (x.producto)::text) AND (p1.visita = 1) AND ((p1.periodo)::text = (p.periodo1)::text))))
     LEFT JOIN cvp.relpre p2 ON (((p2.informante = x.informante) AND (p2.observacion = x.observacion) AND ((p2.producto)::text = (x.producto)::text) AND (p2.visita = 1) AND ((p2.periodo)::text = (p.periodo2)::text))))
     LEFT JOIN cvp.relpre p3 ON (((p3.informante = x.informante) AND (p3.observacion = x.observacion) AND ((p3.producto)::text = (x.producto)::text) AND (p3.visita = 1) AND ((p3.periodo)::text = (p.periodo3)::text))))
     LEFT JOIN cvp.relpre p4 ON (((p4.informante = x.informante) AND (p4.observacion = x.observacion) AND ((p4.producto)::text = (x.producto)::text) AND (p4.visita = 1) AND ((p4.periodo)::text = (p.periodo4)::text))))
     LEFT JOIN cvp.relpre p5 ON (((p5.informante = x.informante) AND (p5.observacion = x.observacion) AND ((p5.producto)::text = (x.producto)::text) AND (p5.visita = 1) AND ((p5.periodo)::text = (p.periodo5)::text))))
     LEFT JOIN cvp.relpre p6 ON (((p6.informante = x.informante) AND (p6.observacion = x.observacion) AND ((p6.producto)::text = (x.producto)::text) AND (p6.visita = 1) AND ((p6.periodo)::text = (p.periodo6)::text))))
     LEFT JOIN cvp.relvis v1 ON (((v1.informante = x.informante) AND (v1.formulario = p1.formulario) AND (v1.visita = 1) AND ((v1.periodo)::text = (p.periodo1)::text))))
     LEFT JOIN cvp.relvis v2 ON (((v2.informante = x.informante) AND (v2.formulario = p2.formulario) AND (v2.visita = 1) AND ((v2.periodo)::text = (p.periodo2)::text))))
     LEFT JOIN cvp.relvis v3 ON (((v3.informante = x.informante) AND (v3.formulario = p3.formulario) AND (v3.visita = 1) AND ((v3.periodo)::text = (p.periodo3)::text))))
     LEFT JOIN cvp.relvis v4 ON (((v4.informante = x.informante) AND (v4.formulario = p4.formulario) AND (v4.visita = 1) AND ((v4.periodo)::text = (p.periodo4)::text))))
     LEFT JOIN cvp.relvis v5 ON (((v5.informante = x.informante) AND (v5.formulario = p5.formulario) AND (v5.visita = 1) AND ((v5.periodo)::text = (p.periodo5)::text))))
     LEFT JOIN cvp.relvis v6 ON (((v6.informante = x.informante) AND (v6.formulario = p6.formulario) AND (v6.visita = 1) AND ((v6.periodo)::text = (p.periodo6)::text))))
     LEFT JOIN cvp.periodos p0 ON ((((p0.periodo)::text = (p.periodo1)::text) AND ((p0.periodoanterior)::text <> (p.periodo1)::text))))
     LEFT JOIN cvp.calobs col0 ON (((col0.informante = x.informante) AND (col0.observacion = x.observacion) AND ((col0.producto)::text = (x.producto)::text) AND ((col0.periodo)::text = (p0.periodoanterior)::text) AND (col0.calculo = 0))));


ALTER TABLE cvp.matrizresultados OWNER TO cvpowner;

--
-- Name: matrizresultadossinvariacion; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.matrizresultadossinvariacion AS
 SELECT m.periodo6 AS periodo,
    m.producto,
    m.tipoinformante,
    m.informante,
    m.observacion,
    m.promobs_1,
    m.precioobservado_1,
    m.impobs_1,
    m.antiguedadexcluido_1,
    m.antiguedadsinprecio_1,
    m.antiguedadconprecio_1,
    m.variacion_1,
    m.tipoprecio_1,
    m.razon_1,
    m.promobs_2,
    m.precioobservado_2,
    m.impobs_2,
    m.antiguedadexcluido_2,
    m.antiguedadsinprecio_2,
    m.antiguedadconprecio_2,
    m.variacion_2,
    m.tipoprecio_2,
    m.razon_2,
    m.promobs_3,
    m.precioobservado_3,
    m.impobs_3,
    m.antiguedadexcluido_3,
    m.antiguedadsinprecio_3,
    m.antiguedadconprecio_3,
    m.variacion_3,
    m.tipoprecio_3,
    m.razon_3,
    m.promobs_4,
    m.precioobservado_4,
    m.impobs_4,
    m.antiguedadexcluido_4,
    m.antiguedadsinprecio_4,
    m.antiguedadconprecio_4,
    m.variacion_4,
    m.tipoprecio_4,
    m.razon_4,
    m.promobs_5,
    m.precioobservado_5,
    m.impobs_5,
    m.antiguedadexcluido_5,
    m.antiguedadsinprecio_5,
    m.antiguedadconprecio_5,
    m.variacion_5,
    m.tipoprecio_5,
    m.razon_5,
    m.promobs_6,
    m.precioobservado_6,
    m.impobs_6,
    m.antiguedadexcluido_6,
    m.antiguedadsinprecio_6,
    m.antiguedadconprecio_6,
    m.variacion_6,
    m.tipoprecio_6,
    m.razon_6,
    m.atributo_1,
    m.atributo_2,
    m.atributo_3,
    m.atributo_4,
    m.atributo_5,
    m.atributo_6
   FROM cvp.matrizresultados m
  WHERE ((m.variacion_1 = (0)::numeric) AND (m.variacion_2 = (0)::numeric) AND (m.variacion_3 = (0)::numeric) AND (m.variacion_4 = (0)::numeric) AND (m.variacion_5 = (0)::numeric) AND (m.variacion_6 = (0)::numeric));


ALTER TABLE cvp.matrizresultadossinvariacion OWNER TO cvpowner;

--
-- Name: modulos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.modulos (
    formulario text NOT NULL,
    nombre text NOT NULL,
    zona text NOT NULL,
    tipo smallint,
    CONSTRAINT "texto invalido en formulario de tabla modulos" CHECK (comun.cadena_valida(formulario, 'castellano'::text)),
    CONSTRAINT "texto invalido en nombre de tabla modulos" CHECK (comun.cadena_valida(nombre, 'castellano'::text)),
    CONSTRAINT "texto invalido en zona de tabla modulos" CHECK (comun.cadena_valida(zona, 'castellano'::text))
);


ALTER TABLE cvp.modulos OWNER TO cvpowner;

--
-- Name: modulosusuarios; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.modulosusuarios (
    formulario text NOT NULL,
    nombre text NOT NULL,
    username text NOT NULL,
    zona text NOT NULL
);


ALTER TABLE cvp.modulosusuarios OWNER TO cvpowner;

--
-- Name: monedas; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.monedas (
    moneda text NOT NULL,
    nombre_moneda text,
    es_nacional boolean,
    CONSTRAINT "El valor del campo es_nacional debe ser siempre TRUE" CHECK (es_nacional),
    CONSTRAINT "texto invalido en moneda de tabla monedas" CHECK (comun.cadena_valida(moneda, 'amplio'::text)),
    CONSTRAINT "texto invalido en nombre_moneda de tabla monedas" CHECK (comun.cadena_valida(nombre_moneda, 'castellano'::text))
);


ALTER TABLE cvp.monedas OWNER TO cvpowner;

--
-- Name: muestras; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.muestras (
    muestra integer NOT NULL,
    descripcion text,
    alta_inmediata_hasta_periodo text,
    CONSTRAINT "texto invalido en descripcion de tabla muestras" CHECK (comun.cadena_valida(descripcion, 'castellano'::text))
);


ALTER TABLE cvp.muestras OWNER TO cvpowner;

--
-- Name: novdelobs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novdelobs (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    visita integer DEFAULT 1 NOT NULL,
    confirma boolean DEFAULT false NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentarios text,
    usuario text
);


ALTER TABLE cvp.novdelobs OWNER TO cvpowner;

--
-- Name: novdelvis; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novdelvis (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer DEFAULT 1 NOT NULL,
    formulario integer NOT NULL,
    confirma boolean DEFAULT false NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentarios text,
    usuario text
);


ALTER TABLE cvp.novdelvis OWNER TO cvpowner;

--
-- Name: novespinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novespinf (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    especificacion integer NOT NULL,
    informante integer NOT NULL,
    estado text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    CONSTRAINT estado_valido CHECK ((estado = ANY (ARRAY['Alta'::text, 'Baja'::text, 'Reemplazo'::text])))
);


ALTER TABLE cvp.novespinf OWNER TO cvpowner;

--
-- Name: novext; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novext (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    promedioext double precision,
    relativoimputacionext double precision,
    indiceext double precision,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text
);


ALTER TABLE cvp.novext OWNER TO cvpowner;

--
-- Name: novobs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novobs (
    periodo text NOT NULL,
    calculo integer DEFAULT 0 NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    estado text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    usuario text,
    revisar_recep boolean DEFAULT false,
    comentarios text,
    comentarios_recep text,
    CONSTRAINT novobs_estado_check CHECK ((estado = ANY (ARRAY['Alta'::text, 'Baja'::text, 'Reemplazo'::text])))
);


ALTER TABLE cvp.novobs OWNER TO cvpowner;

--
-- Name: novobs_base; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novobs_base (
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    hasta_periodo text NOT NULL
);


ALTER TABLE cvp.novobs_base OWNER TO cvpowner;

--
-- Name: novpre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novpre (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    confirma boolean DEFAULT false NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    comentarios text,
    usuario text,
    revisar_recep boolean DEFAULT false,
    comentarios_recep text
);


ALTER TABLE cvp.novpre OWNER TO cvpowner;

--
-- Name: novprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novprod (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    promedioext double precision NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    variacion double precision DEFAULT 0,
    CONSTRAINT "El promedioext debe ser >0" CHECK ((promedioext > (0)::double precision))
);


ALTER TABLE cvp.novprod OWNER TO cvpowner;

--
-- Name: numeros; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.numeros (
    numero integer NOT NULL,
    CONSTRAINT numeros_numero_check CHECK ((numero > 0))
);


ALTER TABLE cvp.numeros OWNER TO cvpowner;

--
-- Name: pantar; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.pantar (
    panel integer NOT NULL,
    tarea integer NOT NULL,
    grupozonal text,
    panel2009 integer,
    tamannosupervision integer
);


ALTER TABLE cvp.pantar OWNER TO cvpowner;

--
-- Name: parahojasderuta; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.parahojasderuta AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.informante,
    v.formulario,
    f.nombreformulario,
    v.fechasalida,
    v.razon,
    v.fechageneracion,
    v.visita,
    v.ultimavisita,
    NULLIF(v.razon, 1) AS razonimpresa,
    n.nombreinformante,
    n.tipoinformante,
    n.direccion
   FROM ((cvp.relvis v
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     JOIN cvp.informantes n ON ((v.informante = n.informante)))
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario;


ALTER TABLE cvp.parahojasderuta OWNER TO cvpowner;

--
-- Name: paraimpresionformulariosatributos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.paraimpresionformulariosatributos AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.informante,
    v.formulario,
    f.nombreformulario,
    v.fechasalida,
    v.razon,
    v.fechageneracion,
    v.visita,
    v.ultimavisita,
    fo.producto,
    COALESCE(d.nombreparaformulario, d.nombreproducto) AS nombreproducto,
    fo.observacion,
    p.precio,
    p.tipoprecio,
    t.atributo,
    a.nombreatributo,
    ra.valor,
    t.orden
   FROM (((((((((((cvp.relvis v
     JOIN cvp.periodos per ON (((per.periodo)::text = (v.periodo)::text)))
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.rubros rub ON ((rub.rubro = i.rubro)))
     JOIN cvp.forobsinf fo ON (((fo.formulario = v.formulario) AND (i.informante = fo.informante))))
     JOIN cvp.productos d ON (((fo.producto)::text = (d.producto)::text)))
     JOIN cvp.especificaciones e ON ((((fo.producto)::text = (e.producto)::text) AND (fo.especificacion = e.especificacion))))
     LEFT JOIN cvp.relpre p ON (((1 = p.visita) AND ((per.periodoanterior)::text = (p.periodo)::text) AND (v.informante = p.informante) AND ((fo.producto)::text = (p.producto)::text) AND (fo.observacion = p.observacion))))
     LEFT JOIN cvp.prodatr t ON (((fo.producto)::text = (t.producto)::text)))
     LEFT JOIN cvp.atributos a ON ((a.atributo = t.atributo)))
     LEFT JOIN cvp.relatr ra ON ((((p.periodo)::text = (ra.periodo)::text) AND ((p.producto)::text = (ra.producto)::text) AND (p.observacion = ra.observacion) AND (p.informante = ra.informante) AND (p.visita = ra.visita) AND (t.atributo = ra.atributo))))
  WHERE ((fo.dependedeldespacho = 'N'::text) OR ((rub.despacho)::text = 'A'::text) OR (fo.observacion = 1))
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario, fo.producto, fo.observacion, t.orden;


ALTER TABLE cvp.paraimpresionformulariosatributos OWNER TO cvpowner;

--
-- Name: paraimpresionformulariosenblanco; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.paraimpresionformulariosenblanco AS
 SELECT f.formulario,
    fo.producto,
    fo.ordenimpresion AS orden,
    fo.observacion,
    f.nombreformulario,
    e.tamannonormal,
    COALESCE(p.nombreparaformulario, p.nombreproducto) AS nombreproducto,
    (substr((fo.producto)::text, 2))::text AS codigo_producto,
    p.cantobs,
    f.soloparatipo,
    f.despacho,
    (((COALESCE((btrim((e.nombreespecificacion)::text) || '. '::text), ''::text) || COALESCE((NULLIF(btrim((COALESCE((btrim((e.envase)::text) || ' '::text), ''::text) ||
        CASE
            WHEN ((e.mostrar_cant_um)::text = 'N'::text) THEN ''::text
            ELSE (COALESCE(((e.cantidad)::text || ' '::text), ''::text) || (COALESCE(e.unidaddemedida, ''::text))::text)
        END)), ''::text) || '. '::text), ''::text)) || string_agg(
        CASE
            WHEN (((a.tipodato)::text = 'N'::text) AND ((a.visible)::text = 'S'::text) AND (t.rangodesde IS NOT NULL) AND (t.rangohasta IS NOT NULL)) THEN ((((((((
            CASE
                WHEN ((t.visiblenombreatributo)::text = 'S'::text) THEN ((a.nombreatributo)::text || ' '::text)
                ELSE ''::text
            END || 'de '::text) || t.rangodesde) || ' a '::text) || t.rangohasta) || ' '::text) || (COALESCE(a.unidaddemedida, a.nombreatributo, ''::text))::text) ||
            CASE
                WHEN (((t.alterable)::text = 'S'::text) AND ((t.normalizable)::text = 'S'::text) AND (NOT ((t.rangodesde <= t.valornormal) AND (t.valornormal <= t.rangohasta)))) THEN (((' ó '::text || t.valornormal) || ' '::text) || (a.unidaddemedida)::text)
                ELSE ''::text
            END) || '. '::text)
            ELSE ''::text
        END, ''::text ORDER BY t.orden)) || COALESCE((('Excluir '::text || btrim((e.excluir)::text)) || '. '::text), ''::text)) AS especificacioncompleta,
    fo.dependedeldespacho,
    e.destacada
   FROM ((((((cvp.formularios f
     JOIN cvp.forobs fo ON ((f.formulario = fo.formulario)))
     JOIN cvp.forprod fp ON (((fo.formulario = fp.formulario) AND ((fo.producto)::text = (fp.producto)::text))))
     JOIN cvp.especificaciones e ON ((((fo.producto)::text = (e.producto)::text) AND (fo.especificacion = e.especificacion))))
     JOIN cvp.productos p ON (((e.producto)::text = (p.producto)::text)))
     LEFT JOIN cvp.prodatr t ON (((fo.producto)::text = (t.producto)::text)))
     LEFT JOIN cvp.atributos a ON ((a.atributo = t.atributo)))
  GROUP BY f.formulario, fo.producto, fo.ordenimpresion, fo.observacion, f.nombreformulario, e.nombreespecificacion, e.tamannonormal, COALESCE(p.nombreparaformulario, p.nombreproducto), p.cantobs, f.soloparatipo, f.despacho, e.envase, e.cantidad, e.unidaddemedida, e.excluir, fo.dependedeldespacho, e.destacada, e.mostrar_cant_um
  ORDER BY f.formulario, fo.ordenimpresion, fo.observacion;


ALTER TABLE cvp.paraimpresionformulariosenblanco OWNER TO cvpowner;

--
-- Name: paraimpresionformulariosprecios; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.paraimpresionformulariosprecios AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    i.direccion,
    i.ordenhdr,
    v.informante,
    v.formulario,
    f.nombreformulario,
    v.fechasalida,
    v.razon,
    v.fechageneracion,
    v.visita,
    v.ultimavisita,
    fo.producto,
    fo.ordenimpresion AS orden,
    COALESCE(d.nombreparaformulario, d.nombreproducto) AS nombreproducto,
    fo.observacion,
    p.precio,
    p.tipoprecio,
    e.nombreespecificacion,
    substr((fo.producto)::text, 2) AS codigo_producto,
    i.tipoinformante,
    NULLIF(v.razon, 1) AS razonimpresa,
    f.orden AS ordenformulario,
    (((COALESCE((btrim((e.nombreespecificacion)::text) || '. '::text), ''::text) || COALESCE((NULLIF(btrim((COALESCE((btrim((e.envase)::text) || ' '::text), ''::text) ||
        CASE
            WHEN ((e.mostrar_cant_um)::text = 'N'::text) THEN ''::text
            ELSE (COALESCE(((e.cantidad)::text || ' '::text), ''::text) || (COALESCE(e.unidaddemedida, ''::text))::text)
        END)), ''::text) || '. '::text), ''::text)) || string_agg(
        CASE
            WHEN (((a.tipodato)::text = 'N'::text) AND ((a.visible)::text = 'S'::text) AND (t.rangodesde IS NOT NULL) AND (t.rangohasta IS NOT NULL)) THEN (((((((((
            CASE
                WHEN ((t.visiblenombreatributo)::text = 'S'::text) THEN ((a.nombreatributo)::text || ' '::text)
                ELSE ''::text
            END || 'de '::text) || t.rangodesde) || ' a '::text) || t.rangohasta) || ' '::text) || (COALESCE(a.unidaddemedida, a.nombreatributo, ''::text))::text) ||
            CASE
                WHEN (((t.alterable)::text = 'S'::text) AND ((t.normalizable)::text = 'S'::text) AND (NOT ((t.rangodesde <= t.valornormal) AND (t.valornormal <= t.rangohasta)))) THEN (((' ó '::text || t.valornormal) || ' '::text) || (a.unidaddemedida)::text)
                ELSE ''::text
            END) ||
            CASE
                WHEN (t.otraunidaddemedida IS NOT NULL) THEN (('/'::text || (t.otraunidaddemedida)::text) || '.'::text)
                ELSE ''::text
            END) || ' '::text)
            ELSE ''::text
        END, ''::text ORDER BY t.orden)) || COALESCE((('Excluir '::text || btrim((e.excluir)::text)) || '. '::text), ''::text)) AS especificacioncompleta,
        CASE
            WHEN (prp.periodo IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS indicacionrepreguntap,
        CASE
            WHEN (prpmas1.periodo IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS indicacionrepreguntapmas1,
        CASE
            WHEN (prpmas2.periodo IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS indicacionrepreguntapmas2,
        CASE
            WHEN (prpmas3.periodo IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS indicacionrepreguntapmas3,
    e.destacada,
    rub.rubro
   FROM ((((((((((((((cvp.relvis v
     JOIN cvp.periodos per ON (((per.periodo)::text = (v.periodo)::text)))
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.rubros rub ON ((rub.rubro = i.rubro)))
     JOIN cvp.forobsinf fo ON (((fo.formulario = v.formulario) AND (fo.informante = i.informante))))
     JOIN cvp.productos d ON (((fo.producto)::text = (d.producto)::text)))
     JOIN cvp.especificaciones e ON ((((fo.producto)::text = (e.producto)::text) AND (fo.especificacion = e.especificacion))))
     LEFT JOIN cvp.relpre p ON (((1 = p.visita) AND ((per.periodoanterior)::text = (p.periodo)::text) AND (v.informante = p.informante) AND ((fo.producto)::text = (p.producto)::text) AND (fo.observacion = p.observacion))))
     LEFT JOIN cvp.prodatr t ON (((fo.producto)::text = (t.producto)::text)))
     LEFT JOIN cvp.atributos a ON ((a.atributo = t.atributo)))
     LEFT JOIN cvp.prerep prp ON ((((per.periodo)::text = (prp.periodo)::text) AND ((d.producto)::text = (prp.producto)::text) AND (i.informante = prp.informante))))
     LEFT JOIN cvp.prerep prpmas1 ON (((cvp.moverperiodos((per.periodo)::text, 1) = (prpmas1.periodo)::text) AND ((d.producto)::text = (prpmas1.producto)::text) AND (i.informante = prpmas1.informante))))
     LEFT JOIN cvp.prerep prpmas2 ON (((cvp.moverperiodos((per.periodo)::text, 2) = (prpmas2.periodo)::text) AND ((d.producto)::text = (prpmas2.producto)::text) AND (i.informante = prpmas2.informante))))
     LEFT JOIN cvp.prerep prpmas3 ON (((cvp.moverperiodos((per.periodo)::text, 3) = (prpmas3.periodo)::text) AND ((d.producto)::text = (prpmas3.producto)::text) AND (i.informante = prpmas3.informante))))
  WHERE ((fo.dependedeldespacho = 'N'::text) OR ((rub.despacho)::text = 'A'::text) OR (fo.observacion = 1))
  GROUP BY v.periodo, v.panel, v.tarea, i.direccion, i.ordenhdr, v.informante, v.formulario, f.nombreformulario, v.fechasalida, v.razon, v.fechageneracion, v.visita, v.ultimavisita, fo.producto, fo.ordenimpresion, COALESCE(d.nombreparaformulario, d.nombreproducto), fo.observacion, p.precio, p.tipoprecio, e.nombreespecificacion, i.tipoinformante, e.envase, e.excluir, e.cantidad, e.unidaddemedida, prp.periodo, prpmas1.periodo, prpmas2.periodo, prpmas3.periodo, f.orden, e.destacada, rub.rubro, e.mostrar_cant_um
  ORDER BY v.periodo, v.panel, v.tarea, i.ordenhdr, i.direccion, v.informante, f.orden, fo.ordenimpresion, fo.observacion;


ALTER TABLE cvp.paraimpresionformulariosprecios OWNER TO cvpowner;

--
-- Name: paralistadodecontroldecm; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.paralistadodecontroldecm AS
 SELECT ccm.periodo,
    ccm.conjuntomuestral,
    ccm.tiposinformante,
    ccm.rubros,
    ccm.cantactivos,
    ccm.cantreemplazos,
        CASE
            WHEN (ccm.tiposinformante > 1) THEN 'CM con distintos tipos de informante'::text
            ELSE NULL::text
        END AS leyenda1,
        CASE
            WHEN (ccm.rubros > 1) THEN 'CM con distintos rubros'::text
            ELSE NULL::text
        END AS leyenda2,
        CASE
            WHEN (ccm.cantactivos > 1) THEN 'CM con más de un informante activo'::text
            WHEN (ccm.cantactivos = 0) THEN 'CM sin informante activo'::text
            ELSE NULL::text
        END AS leyenda3,
        CASE
            WHEN (ccm.cantreemplazos = 0) THEN 'CM sin informantes para reemplazos'::text
            ELSE NULL::text
        END AS leyenda4
   FROM ( SELECT pc.periodo,
            pc.conjuntomuestral,
            t.tiposinformante,
            r.rubros,
            COALESCE(ac.cantidadactivos, (0)::bigint) AS cantactivos,
            COALESCE(re.cantidadreemplazos, (0)::bigint) AS cantreemplazos
           FROM ((((( SELECT periodos.periodo,
                    conjuntomuestral.conjuntomuestral
                   FROM cvp.periodos,
                    cvp.conjuntomuestral) pc
             LEFT JOIN ( SELECT informantes.conjuntomuestral,
                    count(DISTINCT informantes.tipoinformante) AS tiposinformante
                   FROM cvp.informantes
                  GROUP BY informantes.conjuntomuestral) t ON ((pc.conjuntomuestral = t.conjuntomuestral)))
             LEFT JOIN ( SELECT informantes.conjuntomuestral,
                    count(DISTINCT informantes.rubro) AS rubros
                   FROM cvp.informantes
                  GROUP BY informantes.conjuntomuestral) r ON ((pc.conjuntomuestral = r.conjuntomuestral)))
             LEFT JOIN ( SELECT a.periodo,
                    a.conjuntomuestral,
                    a.cantidad AS cantidadactivos
                   FROM ( SELECT e.periodo,
                            e.conjuntomuestral,
                            e.estado,
                            count(*) AS cantidad
                           FROM ( SELECT p.periodo,
                                    i.conjuntomuestral,
                                    i.informante,
                                    cvp.estadoinformante((p.periodo)::text, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE (a.estado = 'Activo'::text)) ac ON (((pc.conjuntomuestral = ac.conjuntomuestral) AND ((pc.periodo)::text = (ac.periodo)::text))))
             LEFT JOIN ( SELECT a.periodo,
                    a.conjuntomuestral,
                    a.cantidad AS cantidadreemplazos
                   FROM ( SELECT e.periodo,
                            e.conjuntomuestral,
                            e.estado,
                            count(*) AS cantidad
                           FROM ( SELECT p.periodo,
                                    i.conjuntomuestral,
                                    i.informante,
                                    cvp.estadoinformante((p.periodo)::text, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE (a.estado = 'Inactivo'::text)) re ON (((pc.conjuntomuestral = re.conjuntomuestral) AND ((pc.periodo)::text = (re.periodo)::text))))) ccm;


ALTER TABLE cvp.paralistadodecontroldecm OWNER TO cvpowner;

--
-- Name: paralistadodecontroldeinformantes; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.paralistadodecontroldeinformantes AS
 SELECT DISTINCT r.periodo,
    r.informante,
    r.panel,
    r.tarea,
    r.visita,
    r.formulario,
    r.razon,
    COALESCE((z.escierredefinitivofor)::text, 'N'::text) AS escierredefinitivofor,
    COALESCE((z.espositivoformulario)::text, 'N'::text) AS espositivofor,
    r.periodo_1,
    r.visita_1,
    r_1.razon AS razon_1,
    COALESCE((z_1.escierredefinitivofor)::text, 'N'::text) AS escierredefinitivofor_1,
    COALESCE((z_1.espositivoformulario)::text, 'N'::text) AS espositivofor_1,
    c.cantidadregistros,
    c.cantidadprecios,
    COALESCE(j.atributosnoingresados, (0)::bigint) AS atributosnoing,
        CASE
            WHEN (r.razon IS NULL) THEN 'Falta ingresar'::text
            ELSE
            CASE
                WHEN (i.razonesnocoherentes = 'S'::text) THEN 'Razones incoherentes entre formularios'::text
                ELSE
                CASE
                    WHEN (((COALESCE((z_1.escierredefinitivofor)::text, 'N'::text))::text = 'S'::text) AND ((COALESCE((z.escierredefinitivofor)::text, 'N'::text))::text = 'N'::text)) THEN 'Razón incoherente respecto a la razón de la visita anterior'::text
                    WHEN (c.cantidadregistros = 0) THEN 'Falta generar renglones de precios'::text
                    WHEN (((COALESCE((z.espositivoformulario)::text, 'N'::text))::text = 'N'::text) AND (c.cantidadprecios > 0)) THEN 'Respuesta negativa con algún precio ingresado'::text
                    WHEN (((COALESCE((z.espositivoformulario)::text, 'N'::text))::text = 'S'::text) AND (c.cantidadprecios < c.cantidadregistros)) THEN 'Falta ingresar renglones de precios'::text
                    WHEN (COALESCE(j.atributosnoingresados, (0)::bigint) > 0) THEN 'Falta ingresar renglones de atributos'::text
                    ELSE NULL::text
                END
            END
        END AS leyenda
   FROM ((((((( SELECT rv.periodo,
            rv.informante,
            rv.visita,
            rv.formulario,
            rv.razon,
            rv.panel,
            rv.tarea,
            rp_1.producto,
            rp_1.observacion,
            rp_1.periodo_1,
            rp_1.visita_1
           FROM (cvp.relvis rv
             LEFT JOIN cvp.relpre_1 rp_1 ON ((((rv.periodo)::text = (rp_1.periodo)::text) AND (rv.informante = rp_1.informante) AND (rv.visita = rp_1.visita) AND (rv.formulario = rp_1.formulario))))) r
     LEFT JOIN ( SELECT r_2.periodo,
            r_2.informante,
            r_2.visita,
            'S'::text AS razonesnocoherentes
           FROM (cvp.relvis r_2
             LEFT JOIN cvp.razones z_2 ON ((r_2.razon = z_2.razon)))
          GROUP BY r_2.periodo, r_2.informante, r_2.visita
         HAVING (min((COALESCE((z_2.escierredefinitivoinf)::text, 'N'::text))::text) <> max((COALESCE((z_2.escierredefinitivoinf)::text, 'N'::text))::text))) i ON ((((r.periodo)::text = (i.periodo)::text) AND (r.informante = i.informante) AND (r.visita = i.visita))))
     LEFT JOIN cvp.relvis r_1 ON ((((r.periodo_1)::text = (r_1.periodo)::text) AND (r.visita_1 = r_1.visita) AND (r.formulario = r_1.formulario) AND (r.informante = r_1.informante))))
     LEFT JOIN cvp.razones z ON ((r.razon = z.razon)))
     LEFT JOIN cvp.razones z_1 ON ((r_1.razon = z_1.razon)))
     LEFT JOIN ( SELECT v.periodo,
            v.informante,
            v.visita,
            v.formulario,
            COALESCE(a.cantidadregistros, (0)::bigint) AS cantidadregistros,
            COALESCE(b.cantidadprecios, (0)::bigint) AS cantidadprecios
           FROM ((( SELECT relvis.periodo,
                    relvis.informante,
                    relvis.visita,
                    relvis.formulario
                   FROM cvp.relvis) v
             LEFT JOIN ( SELECT relpre.periodo,
                    relpre.informante,
                    relpre.visita,
                    relpre.formulario,
                    count(*) AS cantidadregistros
                   FROM cvp.relpre
                  GROUP BY relpre.periodo, relpre.informante, relpre.visita, relpre.formulario) a ON ((((v.periodo)::text = (a.periodo)::text) AND (v.informante = a.informante) AND (v.visita = a.visita) AND (v.formulario = a.formulario))))
             LEFT JOIN ( SELECT r_2.periodo,
                    r_2.informante,
                    r_2.visita,
                    r_2.formulario,
                    count(*) AS cantidadprecios
                   FROM (cvp.relpre r_2
                     JOIN cvp.tipopre t ON ((((r_2.tipoprecio)::text = (t.tipoprecio)::text) AND ((((t.espositivo)::text = 'S'::text) AND (r_2.precio IS NOT NULL)) OR (((t.espositivo)::text = 'N'::text) AND (r_2.precio IS NULL))))))
                  GROUP BY r_2.periodo, r_2.informante, r_2.visita, r_2.formulario) b ON ((((v.periodo)::text = (b.periodo)::text) AND (v.informante = b.informante) AND (v.visita = b.visita) AND (v.formulario = b.formulario))))) c ON ((((r.periodo)::text = (c.periodo)::text) AND (r.informante = c.informante) AND (r.visita = c.visita) AND (r.formulario = c.formulario))))
     LEFT JOIN ( SELECT p.periodo,
            p.informante,
            p.visita,
            p.formulario,
            count(*) AS atributosnoingresados
           FROM (((cvp.relpre p
             JOIN cvp.relatr a ON ((((a.periodo)::text = (p.periodo)::text) AND ((a.producto)::text = (p.producto)::text) AND (a.observacion = p.observacion) AND (a.informante = p.informante) AND (a.visita = p.visita))))
             JOIN cvp.tipopre t ON (((p.tipoprecio)::text = (t.tipoprecio)::text)))
             JOIN cvp.prodatr pa ON (((pa.atributo = a.atributo) AND ((pa.producto)::text = (a.producto)::text))))
          WHERE (((t.espositivo)::text = 'S'::text) AND (a.valor IS NULL) AND ((pa.normalizable)::text = 'S'::text))
          GROUP BY p.periodo, p.informante, p.visita, p.formulario) j ON ((((r.periodo)::text = (j.periodo)::text) AND (r.informante = j.informante) AND (r.visita = j.visita) AND (r.formulario = j.formulario))));


ALTER TABLE cvp.paralistadodecontroldeinformantes OWNER TO cvpowner;

--
-- Name: pasoatraves; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.pasoatraves (
    unicoregistro boolean DEFAULT true NOT NULL,
    tipo text,
    valor text,
    CONSTRAINT pasoatraves_unicoregistro_check CHECK (unicoregistro)
);


ALTER TABLE cvp.pasoatraves OWNER TO cvpowner;

--
-- Name: pb_calculos_reglas; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.pb_calculos_reglas (
    calculo integer NOT NULL,
    tipo_regla text NOT NULL,
    num_regla integer NOT NULL,
    desde text,
    hasta text,
    valor text,
    CONSTRAINT "texto invalido en tipo_regla de tabla pb_calculos_reglas" CHECK (comun.cadena_valida(tipo_regla, 'amplio'::text)),
    CONSTRAINT "texto invalido en valor de tabla pb_calculos_reglas" CHECK (comun.cadena_valida(valor, 'amplio'::text))
);


ALTER TABLE cvp.pb_calculos_reglas OWNER TO cvpowner;

--
-- Name: pb_externos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.pb_externos (
    producto text NOT NULL,
    periodo text NOT NULL,
    indice double precision
);


ALTER TABLE cvp.pb_externos OWNER TO cvpowner;

--
-- Name: personalmigtemp; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.personalmigtemp (
    usuario integer NOT NULL,
    tarea text NOT NULL,
    periodo text NOT NULL,
    persona text,
    activo text,
    obs text,
    CONSTRAINT "texto invalido en obs de tabla personalmigtemp" CHECK (comun.cadena_valida(obs, 'castellano'::text))
);


ALTER TABLE cvp.personalmigtemp OWNER TO cvpowner;

--
-- Name: TABLE personalmigtemp; Type: COMMENT; Schema: cvp; Owner: cvpowner
--

COMMENT ON TABLE cvp.personalmigtemp IS 'Tabla a utilizar en  la migracion de la tabla cba.personal';


--
-- Name: precios_maximos_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.precios_maximos_vw AS
 SELECT a.periodo,
    a.producto,
    a.nombreproducto,
        CASE
            WHEN (split_part(m.precios, '|'::text, 1) <> ''::text) THEN split_part(m.precios, '|'::text, 1)
            ELSE NULL::text
        END AS precio1,
        CASE
            WHEN (split_part(m.precios, '|'::text, 2) <> ''::text) THEN split_part(m.precios, '|'::text, 2)
            ELSE NULL::text
        END AS precio2,
        CASE
            WHEN (split_part(m.precios, '|'::text, 3) <> ''::text) THEN split_part(m.precios, '|'::text, 3)
            ELSE NULL::text
        END AS precio3,
        CASE
            WHEN (split_part(m.precios, '|'::text, 4) <> ''::text) THEN split_part(m.precios, '|'::text, 4)
            ELSE NULL::text
        END AS precio4,
        CASE
            WHEN (split_part(m.precios, '|'::text, 5) <> ''::text) THEN split_part(m.precios, '|'::text, 5)
            ELSE NULL::text
        END AS precio5,
        CASE
            WHEN (split_part(m.precios, '|'::text, 6) <> ''::text) THEN split_part(m.precios, '|'::text, 6)
            ELSE NULL::text
        END AS precio6,
        CASE
            WHEN (split_part(m.precios, '|'::text, 7) <> ''::text) THEN split_part(m.precios, '|'::text, 7)
            ELSE NULL::text
        END AS precio7,
        CASE
            WHEN (split_part(m.precios, '|'::text, 8) <> ''::text) THEN split_part(m.precios, '|'::text, 8)
            ELSE NULL::text
        END AS precio8,
        CASE
            WHEN (split_part(m.precios, '|'::text, 9) <> ''::text) THEN split_part(m.precios, '|'::text, 9)
            ELSE NULL::text
        END AS precio9,
        CASE
            WHEN (split_part(m.precios, '|'::text, 10) <> ''::text) THEN split_part(m.precios, '|'::text, 10)
            ELSE NULL::text
        END AS precio10,
    split_part(m.informantes, ';'::text, 1) AS informantes1,
    split_part(m.informantes, ';'::text, 2) AS informantes2,
    split_part(m.informantes, ';'::text, 3) AS informantes3,
    split_part(m.informantes, ';'::text, 4) AS informantes4,
    split_part(m.informantes, ';'::text, 5) AS informantes5,
    split_part(m.informantes, ';'::text, 6) AS informantes6,
    split_part(m.informantes, ';'::text, 7) AS informantes7,
    split_part(m.informantes, ';'::text, 8) AS informantes8,
    split_part(m.informantes, ';'::text, 9) AS informantes9,
    split_part(m.informantes, ';'::text, 10) AS informantes10
   FROM (( SELECT pe.periodo,
            pr.producto,
            pr.nombreproducto
           FROM (( SELECT periodos.periodo
                   FROM cvp.periodos
                  ORDER BY periodos.periodo DESC
                 LIMIT 12) pe
             JOIN ( SELECT productos.producto,
                    productos.nombreproducto
                   FROM cvp.productos
                  WHERE ((productos.nombreproducto)::text !~~ '%orrar%'::text)) pr ON (true))) a
     LEFT JOIN cvp.periodo_maximos_precios(10) m(periodo, producto, nombreproducto, precios, informantes) ON ((((a.periodo)::text = (m.periodo)::text) AND ((a.producto)::text = (m.producto)::text) AND ((a.nombreproducto)::text = (m.nombreproducto)::text))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.precios_maximos_vw OWNER TO cvpowner;

--
-- Name: precios_minimos_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.precios_minimos_vw AS
 SELECT a.periodo,
    a.producto,
    a.nombreproducto,
        CASE
            WHEN (split_part(m.precios, '|'::text, 1) <> ''::text) THEN split_part(m.precios, '|'::text, 1)
            ELSE NULL::text
        END AS precio1,
        CASE
            WHEN (split_part(m.precios, '|'::text, 2) <> ''::text) THEN split_part(m.precios, '|'::text, 2)
            ELSE NULL::text
        END AS precio2,
        CASE
            WHEN (split_part(m.precios, '|'::text, 3) <> ''::text) THEN split_part(m.precios, '|'::text, 3)
            ELSE NULL::text
        END AS precio3,
        CASE
            WHEN (split_part(m.precios, '|'::text, 4) <> ''::text) THEN split_part(m.precios, '|'::text, 4)
            ELSE NULL::text
        END AS precio4,
        CASE
            WHEN (split_part(m.precios, '|'::text, 5) <> ''::text) THEN split_part(m.precios, '|'::text, 5)
            ELSE NULL::text
        END AS precio5,
        CASE
            WHEN (split_part(m.precios, '|'::text, 6) <> ''::text) THEN split_part(m.precios, '|'::text, 6)
            ELSE NULL::text
        END AS precio6,
        CASE
            WHEN (split_part(m.precios, '|'::text, 7) <> ''::text) THEN split_part(m.precios, '|'::text, 7)
            ELSE NULL::text
        END AS precio7,
        CASE
            WHEN (split_part(m.precios, '|'::text, 8) <> ''::text) THEN split_part(m.precios, '|'::text, 8)
            ELSE NULL::text
        END AS precio8,
        CASE
            WHEN (split_part(m.precios, '|'::text, 9) <> ''::text) THEN split_part(m.precios, '|'::text, 9)
            ELSE NULL::text
        END AS precio9,
        CASE
            WHEN (split_part(m.precios, '|'::text, 10) <> ''::text) THEN split_part(m.precios, '|'::text, 10)
            ELSE NULL::text
        END AS precio10,
    split_part(m.informantes, ';'::text, 1) AS informantes1,
    split_part(m.informantes, ';'::text, 2) AS informantes2,
    split_part(m.informantes, ';'::text, 3) AS informantes3,
    split_part(m.informantes, ';'::text, 4) AS informantes4,
    split_part(m.informantes, ';'::text, 5) AS informantes5,
    split_part(m.informantes, ';'::text, 6) AS informantes6,
    split_part(m.informantes, ';'::text, 7) AS informantes7,
    split_part(m.informantes, ';'::text, 8) AS informantes8,
    split_part(m.informantes, ';'::text, 9) AS informantes9,
    split_part(m.informantes, ';'::text, 10) AS informantes10
   FROM (( SELECT pe.periodo,
            pr.producto,
            pr.nombreproducto
           FROM (( SELECT periodos.periodo
                   FROM cvp.periodos
                  ORDER BY periodos.periodo DESC
                 LIMIT 12) pe
             JOIN ( SELECT productos.producto,
                    productos.nombreproducto
                   FROM cvp.productos
                  WHERE ((productos.nombreproducto)::text !~~ '%orrar%'::text)) pr ON (true))) a
     LEFT JOIN cvp.periodo_minimos_precios(10) m(periodo, producto, nombreproducto, precios, informantes) ON ((((a.periodo)::text = (m.periodo)::text) AND ((a.producto)::text = (m.producto)::text) AND ((a.nombreproducto)::text = (m.nombreproducto)::text))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.precios_minimos_vw OWNER TO cvpowner;

--
-- Name: precios_porcentaje_positivos_y_anulados; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.precios_porcentaje_positivos_y_anulados AS
 SELECT v.periodo,
    v.informante,
    v.panel,
    v.tarea,
    ta.operativo,
    ((v.formulario || ':'::text) || (f.nombreformulario)::text) AS formulario,
    count(*) AS preciospotenciales,
    sum(
        CASE
            WHEN ((t.espositivo)::text = 'S'::text) THEN 1
            ELSE 0
        END) AS positivos,
    sum(
        CASE
            WHEN (((t.espositivo)::text = 'N'::text) AND ((t.visibleparaencuestador)::text = 'N'::text)) THEN 1
            ELSE 0
        END) AS anulados,
    (((((sum(
        CASE
            WHEN ((t.espositivo)::text = 'S'::text) THEN 1
            ELSE 0
        END) + sum(
        CASE
            WHEN (((t.espositivo)::text = 'N'::text) AND ((t.visibleparaencuestador)::text = 'N'::text)) THEN 1
            ELSE 0
        END)) * 100) / count(*)))::text || '%'::text) AS porcentaje,
    sum(a.atributospotenciales) AS atributospotenciales,
    sum(a.atributospositivos) AS atributospositivos,
        CASE
            WHEN (sum(a.atributospotenciales) > (0)::numeric) THEN ((round(((sum(a.atributospositivos) / sum(a.atributospotenciales)) * (100)::numeric)))::text || '%'::text)
            ELSE '0%'::text
        END AS porcatributos
   FROM ((((cvp.relvis v
     JOIN cvp.relpre r ON ((((v.periodo)::text = (r.periodo)::text) AND (v.informante = r.informante) AND (v.formulario = r.formulario) AND (v.visita = r.visita))))
     LEFT JOIN cvp.tareas ta ON ((v.tarea = ta.tarea)))
     LEFT JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     LEFT JOIN cvp.tipopre t ON (((r.tipoprecio)::text = (t.tipoprecio)::text))),
    LATERAL ( SELECT pro.producto,
            count(DISTINCT pa.atributo) AS atributospotenciales,
                CASE
                    WHEN ((t.espositivo)::text = 'S'::text) THEN count(DISTINCT pa.atributo)
                    ELSE (0)::bigint
                END AS atributospositivos
           FROM (cvp.productos pro
             LEFT JOIN cvp.prodatr pa ON (((pro.producto)::text = (pa.producto)::text)))
          WHERE ((r.producto)::text = (pro.producto)::text)
          GROUP BY pro.producto) a
  GROUP BY v.periodo, v.informante, v.panel, v.tarea, ta.operativo, ((v.formulario || ':'::text) || (f.nombreformulario)::text)
  ORDER BY v.periodo, v.informante, v.panel, v.tarea, ta.operativo, ((v.formulario || ':'::text) || (f.nombreformulario)::text);


ALTER TABLE cvp.precios_porcentaje_positivos_y_anulados OWNER TO cvpowner;

--
-- Name: preciosmedios_albs; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.preciosmedios_albs AS
 SELECT x.gruponivel1,
    x.nombregruponivel1,
    x.grupopadre,
    x.nombregrupopadre,
    x.producto,
    x.nombreproducto,
    x.unidadmedidaabreviada,
    round((c1.promdiv)::numeric, 2) AS promprod1,
    round((c2.promdiv)::numeric, 2) AS promprod2,
    round((c3.promdiv)::numeric, 2) AS promprod3,
    round((c4.promdiv)::numeric, 2) AS promprod4,
    round((c5.promdiv)::numeric, 2) AS promprod5,
    round((c6.promdiv)::numeric, 2) AS promprod6,
    c1.periodo AS periodo1,
    c2.periodo AS periodo2,
    c3.periodo AS periodo3,
    c4.periodo AS periodo4,
    c5.periodo AS periodo5,
    c6.periodo AS periodo6,
    x.agrupacion
   FROM (((((((((cvp.matrizperiodos6 p
     JOIN ( SELECT c.producto,
            p_1.nombreproducto,
            p_1.unidadmedidaabreviada,
            g.agrupacion,
            c.calculo,
            a.periodo6,
            g.nivel,
            g.grupopadre,
            g2.nombregrupo AS nombregrupopadre,
            g2.grupopadre AS gruponivel1,
            g3.nombregrupo AS nombregruponivel1
           FROM (((((cvp.caldiv c
             JOIN cvp.grupos g ON (((c.calculo = 0) AND ((g.grupo)::text = (c.producto)::text) AND ((g.esproducto)::text = 'S'::text))))
             JOIN cvp.productos p_1 ON ((((g.grupo)::text = (p_1.producto)::text) AND ((g.esproducto)::text = 'S'::text))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR ((c.periodo)::text >= (a.periodo1)::text)) AND ((c.periodo)::text <= (a.periodo6)::text))))
             LEFT JOIN cvp.grupos g2 ON ((((g.grupopadre)::text = (g2.grupo)::text) AND ((g2.agrupacion)::text = (g.agrupacion)::text))))
             LEFT JOIN cvp.grupos g3 ON ((((g2.grupopadre)::text = (g3.grupo)::text) AND ((g3.agrupacion)::text = (g2.agrupacion)::text))))
          WHERE ((c.calculo = 0) AND ((g.esproducto)::text = 'S'::text) AND ((g.agrupacion)::text = 'C'::text) AND ((c.division)::text = '0'::text))
          GROUP BY c.producto, p_1.nombreproducto, p_1.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre, g2.nombregrupo, g2.grupopadre, g3.nombregrupo) x ON (((x.periodo6)::text = (p.periodo6)::text)))
     LEFT JOIN cvp.caldiv c1 ON ((((x.producto)::text = (c1.producto)::text) AND ((c1.periodo)::text = (p.periodo1)::text) AND (c1.calculo = x.calculo) AND ((c1.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv c2 ON ((((x.producto)::text = (c2.producto)::text) AND ((c2.periodo)::text = (p.periodo2)::text) AND (c2.calculo = x.calculo) AND ((c2.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv c3 ON ((((x.producto)::text = (c3.producto)::text) AND ((c3.periodo)::text = (p.periodo3)::text) AND (c3.calculo = x.calculo) AND ((c3.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv c4 ON ((((x.producto)::text = (c4.producto)::text) AND ((c4.periodo)::text = (p.periodo4)::text) AND (c4.calculo = x.calculo) AND ((c4.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv c5 ON ((((x.producto)::text = (c5.producto)::text) AND ((c5.periodo)::text = (p.periodo5)::text) AND (c5.calculo = x.calculo) AND ((c5.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv c6 ON ((((x.producto)::text = (c6.producto)::text) AND ((c6.periodo)::text = (p.periodo6)::text) AND (c6.calculo = x.calculo) AND ((c6.division)::text = '0'::text))))
     LEFT JOIN cvp.periodos p0 ON ((((p0.periodo)::text = (p.periodo1)::text) AND ((p0.periodoanterior)::text <> (p.periodo1)::text))))
     LEFT JOIN cvp.caldiv cl0 ON ((((x.producto)::text = (cl0.producto)::text) AND ((cl0.periodo)::text = (p0.periodoanterior)::text) AND (cl0.calculo = x.calculo) AND ((cl0.division)::text = '0'::text))))
  ORDER BY x.agrupacion, c6.periodo, x.gruponivel1, x.grupopadre, x.producto;


ALTER TABLE cvp.preciosmedios_albs OWNER TO cvpowner;

--
-- Name: preciosmedios_albs_var; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.preciosmedios_albs_var AS
 SELECT g2.grupopadre AS gruponivel1,
    g3.nombregrupo AS nombregruponivel1,
    g.grupopadre,
    g2.nombregrupo AS nombregrupopadre,
    c.producto,
    COALESCE((p.nombreparapublicar)::text, p.nombreproducto) AS nombreproducto,
    p.unidadmedidaabreviada,
    round((c0.promdiv)::numeric, 2) AS promprodant,
    round((c.promdiv)::numeric, 2) AS promprod,
        CASE
            WHEN (c0.promdiv = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.promdiv / c0.promdiv) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacion,
        CASE
            WHEN (ca.promdiv = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.promdiv / ca.promdiv) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.promdiv = (0)::double precision) THEN NULL::numeric
            ELSE round(((((c.promdiv / cm.promdiv) * (100)::double precision) - (100)::double precision))::numeric, 1)
        END AS variacionmesanioanterior,
    g.agrupacion,
    c.calculo,
    c.periodo,
    c0.calculo AS calculoant,
    c0.periodo AS periodoant,
    ca.periodo AS periododiciembre,
    cm.periodo AS periodoaniooanterior
   FROM ((((((((cvp.caldiv c
     JOIN cvp.grupos g ON (((c.calculo = 0) AND ((g.grupo)::text = (c.producto)::text) AND ((g.esproducto)::text = 'S'::text))))
     JOIN cvp.productos p ON ((((g.grupo)::text = (p.producto)::text) AND ((g.esproducto)::text = 'S'::text))))
     JOIN cvp.calculos pa ON ((((c.periodo)::text = (pa.periodo)::text) AND ('A'::text = (pa.agrupacionprincipal)::text) AND (0 = pa.calculo))))
     JOIN cvp.caldiv c0 ON ((((c.producto)::text = (c0.producto)::text) AND (c0.calculo = pa.calculoanterior) AND ((c0.periodo)::text = (pa.periodoanterior)::text) AND ((c0.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv ca ON ((((c.producto)::text = (ca.producto)::text) AND (c.calculo = ca.calculo) AND ((ca.periodo)::text = (('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm12'::text)) AND ((ca.division)::text = '0'::text))))
     LEFT JOIN cvp.caldiv cm ON ((((c.producto)::text = (cm.producto)::text) AND (c.calculo = cm.calculo) AND ((cm.periodo)::text = ((('a'::text || ((substr((c.periodo)::text, 2, 4))::integer - 1)) || 'm'::text) || substr((c.periodo)::text, 7, 2))) AND ((cm.division)::text = '0'::text))))
     LEFT JOIN cvp.grupos g2 ON ((((g.grupopadre)::text = (g2.grupo)::text) AND ((g2.agrupacion)::text = (g.agrupacion)::text))))
     LEFT JOIN cvp.grupos g3 ON ((((g2.grupopadre)::text = (g3.grupo)::text) AND ((g3.agrupacion)::text = (g2.agrupacion)::text))))
  WHERE ((c.calculo = 0) AND (((g.esproducto)::text = 'S'::text) AND ((g.agrupacion)::text = 'C'::text)) AND ((c.division)::text = '0'::text))
  ORDER BY g.agrupacion, c.periodo, g2.grupopadre, g.grupopadre, c.producto;


ALTER TABLE cvp.preciosmedios_albs_var OWNER TO cvpowner;

--
-- Name: prod_for_rub; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.prod_for_rub AS
 SELECT x.producto,
    x.nombreproducto,
    split_part(x.formularios, '|'::text, 1) AS formulario1,
        CASE
            WHEN (split_part(x.formularios, '|'::text, 2) = ''::text) THEN NULL::text
            ELSE split_part(x.formularios, '|'::text, 2)
        END AS formulario2,
        CASE
            WHEN (split_part(x.formularios, '|'::text, 3) = ''::text) THEN NULL::text
            ELSE split_part(x.formularios, '|'::text, 3)
        END AS formulario3,
    split_part(x.rubros, '|'::text, 1) AS rubro1,
        CASE
            WHEN (split_part(x.rubros, '|'::text, 2) = ''::text) THEN NULL::text
            ELSE split_part(x.rubros, '|'::text, 2)
        END AS rubro2,
        CASE
            WHEN (split_part(x.rubros, '|'::text, 3) = ''::text) THEN NULL::text
            ELSE split_part(x.rubros, '|'::text, 3)
        END AS rubro3,
    x.formula,
    x.estacional,
    x.imputacon,
    x.cantperaltaauto,
    x.cantperbajaauto,
    x.cantporunidcons,
    x.unidadmedidaporunidcons,
    x.esexternohabitual,
    x.tipocalculo,
    x.cantobs,
    x.unidadmedidaabreviada,
    x.codigo_ccba,
    x.porc_adv_inf,
    x.porc_adv_sup
   FROM ( SELECT s.producto,
            s.nombreproducto,
            string_agg(((s.formulario || ':'::text) || (s.nombreformulario)::text), '|'::text) AS formularios,
            string_agg(s.rubros, '|'::text) AS rubros,
            s.formula,
            s.estacional,
            s.imputacon,
            s.cantperaltaauto,
            s.cantperbajaauto,
            s.cantporunidcons,
            s.unidadmedidaporunidcons,
            s.esexternohabitual,
            s.tipocalculo,
            s.cantobs,
            s.unidadmedidaabreviada,
            s.codigo_ccba,
            s.porc_adv_inf,
            s.porc_adv_sup
           FROM ( SELECT d.producto,
                    d.nombreproducto,
                    d.formulario,
                    d.nombreformulario,
                    string_agg(((d.rubro || ':'::text) || (d.nombrerubro)::text), '; '::text) AS rubros,
                    d.formula,
                    d.estacional,
                    d.imputacon,
                    d.cantperaltaauto,
                    d.cantperbajaauto,
                    d.cantporunidcons,
                    d.unidadmedidaporunidcons,
                    d.esexternohabitual,
                    d.tipocalculo,
                    d.cantobs,
                    d.unidadmedidaabreviada,
                    d.codigo_ccba,
                    d.porc_adv_inf,
                    d.porc_adv_sup
                   FROM ( SELECT p.producto,
                            p.nombreproducto,
                            fp.formulario,
                            f.nombreformulario,
                            rf.rubro,
                            r.nombrerubro,
                            p.formula,
                            p.estacional,
                            p.imputacon,
                            p.cantperaltaauto,
                            p.cantperbajaauto,
                            pa.cantporunidcons,
                            p.unidadmedidaporunidcons,
                            p.esexternohabitual,
                            p.tipocalculo,
                            p.cantobs,
                            p.unidadmedidaabreviada,
                            p.codigo_ccba,
                            p.porc_adv_inf,
                            p.porc_adv_sup
                           FROM (((((cvp.productos p
                             LEFT JOIN cvp.prodagr pa ON ((((p.producto)::text = (pa.producto)::text) AND ((pa.agrupacion)::text = 'A'::text))))
                             LEFT JOIN cvp.forprod fp ON (((p.producto)::text = (fp.producto)::text)))
                             LEFT JOIN ( SELECT DISTINCT r_1.formulario,
                                    i.rubro
                                   FROM ((cvp.relvis r_1
                                     JOIN cvp.informantes i ON ((r_1.informante = i.informante)))
                                     JOIN ( SELECT max((periodos.periodo)::text) AS per
   FROM cvp.periodos
  WHERE ((periodos.ingresando)::text = 'N'::text)) p_1 ON (((r_1.periodo)::text = p_1.per)))) rf ON ((fp.formulario = rf.formulario)))
                             LEFT JOIN cvp.formularios f ON ((fp.formulario = f.formulario)))
                             LEFT JOIN cvp.rubros r ON ((rf.rubro = r.rubro)))
                          WHERE ((f.activo)::text = 'S'::text)
                          ORDER BY p.producto, fp.formulario, rf.rubro) d
                  GROUP BY d.producto, d.nombreproducto, d.formulario, d.nombreformulario, d.formula, d.estacional, d.imputacon, d.cantperaltaauto, d.cantperbajaauto, d.cantporunidcons, d.unidadmedidaporunidcons, d.esexternohabitual, d.tipocalculo, d.cantobs, d.unidadmedidaabreviada, d.codigo_ccba, d.porc_adv_inf, d.porc_adv_sup
                  ORDER BY d.producto) s
          GROUP BY s.producto, s.nombreproducto, s.formula, s.estacional, s.imputacon, s.cantperaltaauto, s.cantperbajaauto, s.cantporunidcons, s.unidadmedidaporunidcons, s.esexternohabitual, s.tipocalculo, s.cantobs, s.unidadmedidaabreviada, s.codigo_ccba, s.porc_adv_inf, s.porc_adv_sup
          ORDER BY s.producto) x;


ALTER TABLE cvp.prod_for_rub OWNER TO cvpowner;

--
-- Name: prodatrval; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prodatrval (
    producto text NOT NULL,
    atributo integer NOT NULL,
    valor text NOT NULL,
    orden integer
);


ALTER TABLE cvp.prodatrval OWNER TO cvpowner;

--
-- Name: prodcantporunidcons; Type: TABLE; Schema: cvp; Owner: postgres
--

CREATE TABLE cvp.prodcantporunidcons (
    producto text,
    cantporunidcons double precision
);


ALTER TABLE cvp.prodcantporunidcons OWNER TO postgres;

--
-- Name: proddivestimac; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.proddivestimac (
    producto text NOT NULL,
    division text NOT NULL,
    estimacion integer NOT NULL,
    umbralpriimp integer,
    umbraldescarte integer,
    umbralbajaauto integer,
    CONSTRAINT "El umbral de primera imputación debe ser mayor a cero" CHECK ((umbralpriimp > 0)),
    CONSTRAINT "La estimación debe ser mayor a cero" CHECK ((estimacion > 0)),
    CONSTRAINT "texto invalido en division de tabla proddivestimac" CHECK (comun.cadena_valida(division, 'amplio'::text))
);


ALTER TABLE cvp.proddivestimac OWNER TO cvpowner;

--
-- Name: promedios_maximos_minimos; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.promedios_maximos_minimos AS
 SELECT v.periodo,
    v.producto,
    f.nombreproducto,
    n.tipoinformante,
    r.despacho,
    v.observacion,
    round((exp(avg(ln(v.precionormalizado))))::numeric, 2) AS avgp,
    round((min(v.precionormalizado))::numeric, 2) AS minp,
    round((max(v.precionormalizado))::numeric, 2) AS maxp,
    round((((exp(avg(ln((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs))))) * (100)::double precision) - (100)::double precision))::numeric, 1) AS avgv,
    round((min((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision)))::numeric, 1) AS minv,
    round((max((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::double precision) - (100)::double precision)))::numeric, 1) AS maxv,
    sum(
        CASE
            WHEN ((ta.espositivo)::text = 'S'::text) THEN 1
            ELSE 0
        END) AS cantreales,
    sum(
        CASE
            WHEN ((ta.espositivo)::text = 'N'::text) THEN 1
            ELSE 0
        END) AS cantnegativos,
    sum(
        CASE
            WHEN ((COALESCE(v.cambio, '0'::text))::text = 'C'::text) THEN 1
            ELSE 0
        END) AS cantcambios,
    count(*) AS cantcasos,
    sum(
        CASE
            WHEN ((( SELECT ta.espositivo
               FROM cvp.relvis vi
              WHERE (((ta.tipoprecio)::text = (COALESCE(v.tipoprecio, '0'::text))::text) AND (vi.informantereemplazante IS NOT NULL) AND (v.informante = vi.informantereemplazante) AND ((v.periodo)::text = (vi.periodo)::text) AND (v.visita = vi.visita))))::text = 'S'::text) THEN 1
            ELSE 0
        END) AS cantreemplazos,
    sum(
        CASE
            WHEN (v.tipoprecio IS NULL) THEN 1
            ELSE 0
        END) AS cantnulos
   FROM (((((cvp.relpre_1 v
     JOIN cvp.productos f ON (((v.producto)::text = (f.producto)::text)))
     JOIN cvp.informantes n ON ((v.informante = n.informante)))
     JOIN cvp.rubros r ON ((n.rubro = r.rubro)))
     LEFT JOIN cvp.tipopre ta ON (((ta.tipoprecio)::text = (COALESCE(v.tipoprecio, '0'::text))::text)))
     LEFT JOIN cvp.calobs co ON ((((v.periodo_1)::text = (co.periodo)::text) AND (co.calculo = 0) AND (v.informante = co.informante) AND ((v.producto)::text = (co.producto)::text) AND (v.observacion = co.observacion))))
  GROUP BY v.periodo, v.producto, f.nombreproducto, n.tipoinformante, r.despacho, v.observacion
  ORDER BY v.periodo, v.producto, n.tipoinformante, r.despacho, v.observacion;


ALTER TABLE cvp.promedios_maximos_minimos OWNER TO cvpowner;

--
-- Name: reemplazosexportar; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.reemplazosexportar AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.fechasalida,
    ii.conjuntomuestral,
    v.encuestador,
    (COALESCE(((p.nombre)::text || ' '::text), ''::text) || (COALESCE(p.apellido, ''::text))::text) AS nombreencuestador,
    v.visita,
    regexp_replace(cvp.formularioshdr((v.periodo)::text, v.informante, v.visita, v.fechasalida, (v.encuestador)::text), chr(10), ' | '::text, 'g'::text) AS formularios,
        CASE
            WHEN (ii.informante = v.informante) THEN 'Titular'::text
            ELSE 'Reemplazo'::text
        END AS tipoinformante,
    ii.informante,
    ii.nombreinformante,
    ii.direccion,
    ii.ordenhdr,
    ii.distrito,
    ii.fraccion,
    ii.rubro,
    r.nombrerubro
   FROM ((((((cvp.relvis v
     JOIN ( SELECT periodos.periodo
           FROM cvp.periodos
          WHERE ((periodos.ingresando)::text = 'N'::text)
          ORDER BY periodos.periodo DESC
         LIMIT 1) e ON (((v.periodo)::text = (e.periodo)::text)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.informantes ii ON ((ii.conjuntomuestral = i.conjuntomuestral)))
     JOIN cvp.personal p ON (((v.encuestador)::text = (p.persona)::text)))
     JOIN cvp.rubros r ON ((ii.rubro = r.rubro)))
     LEFT JOIN ( SELECT DISTINCT hojaderuta.informante,
            hojaderuta.conjuntomuestral,
            1 AS estaenhojaderuta
           FROM cvp.hojaderuta) h ON (((ii.conjuntomuestral = h.conjuntomuestral) AND (ii.informante = h.informante))))
  WHERE ((
        CASE
            WHEN (ii.informante = v.informante) THEN 'Titular'::text
            ELSE 'Reemplazo'::text
        END = 'Titular'::text) OR (h.estaenhojaderuta IS NULL))
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, ii.conjuntomuestral, v.encuestador, (COALESCE(((p.nombre)::text || ' '::text), ''::text) || (COALESCE(p.apellido, ''::text))::text), v.visita,
        CASE
            WHEN (ii.informante = v.informante) THEN 'Titular'::text
            ELSE 'Reemplazo'::text
        END, v.informante, ii.informante, ii.nombreinformante, ii.direccion, ii.ordenhdr, ii.distrito, ii.fraccion, ii.rubro, r.nombrerubro
  ORDER BY v.panel, v.tarea, ii.conjuntomuestral,
        CASE
            WHEN (ii.informante = v.informante) THEN 'Titular'::text
            ELSE 'Reemplazo'::text
        END DESC, ii.informante;


ALTER TABLE cvp.reemplazosexportar OWNER TO cvpowner;

--
-- Name: relatr_1; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.relatr_1 AS
 SELECT r.periodo,
    r.visita,
    r.producto,
    r.observacion,
    r.informante,
    r.atributo,
    r.valor,
    r_1.periodo AS periodo_1,
    r_1.visita AS visita_1,
    r_1.valor AS valor_1
   FROM ((cvp.relatr r
     LEFT JOIN cvp.relpre p_1 ON ((((p_1.periodo)::text =
        CASE
            WHEN (r.visita > 1) THEN (r.periodo)::text
            ELSE ( SELECT max((relpre.periodo)::text) AS max
               FROM cvp.relpre
              WHERE (((relpre.periodo)::text < (r.periodo)::text) AND ((relpre.producto)::text = (r.producto)::text) AND (relpre.observacion = r.observacion) AND (relpre.informante = r.informante)))
        END) AND (((p_1.ultima_visita = true) AND (r.visita = 1)) OR ((r.visita > 1) AND (p_1.visita = (r.visita - 1)))) AND (p_1.informante = r.informante) AND ((p_1.producto)::text = (r.producto)::text) AND (p_1.observacion = r.observacion))))
     LEFT JOIN cvp.relatr r_1 ON ((((r_1.periodo)::text = (p_1.periodo)::text) AND (r_1.visita = p_1.visita) AND (r_1.informante = r.informante) AND ((r_1.producto)::text = (r.producto)::text) AND (r_1.observacion = r.observacion) AND (r_1.atributo = r.atributo))));


ALTER TABLE cvp.relatr_1 OWNER TO cvpowner;

--
-- Name: relenc; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relenc (
    periodo text NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    encuestador text NOT NULL,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text
);


ALTER TABLE cvp.relenc OWNER TO cvpowner;

--
-- Name: relinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relinf (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    observaciones text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    panel integer NOT NULL,
    tarea integer NOT NULL
);


ALTER TABLE cvp.relinf OWNER TO cvpowner;

--
-- Name: relmon; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relmon (
    periodo text NOT NULL,
    moneda text NOT NULL,
    valor_pesos double precision,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    CONSTRAINT "texto invalido en moneda de tabla relmon" CHECK (comun.cadena_valida(moneda, 'amplio'::text))
);


ALTER TABLE cvp.relmon OWNER TO cvpowner;

--
-- Name: relpresemaforo; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relpresemaforo (
    periodo text NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    visita integer DEFAULT 1 NOT NULL
);


ALTER TABLE cvp.relpresemaforo OWNER TO cvpowner;

--
-- Name: relsup; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relsup (
    periodo text NOT NULL,
    panel integer NOT NULL,
    supervisor text NOT NULL,
    disponible text,
    motivonodisponible text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text,
    CONSTRAINT "texto invalido en motivonodisponible de tabla relsup" CHECK (comun.cadena_valida(motivonodisponible, 'castellano'::text))
);


ALTER TABLE cvp.relsup OWNER TO cvpowner;

--
-- Name: revisor_parametros; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.revisor_parametros AS
 SELECT 'V190813'::text AS versionexigida,
    'V130417'::text AS versionbase;


ALTER TABLE cvp.revisor_parametros OWNER TO cvpowner;

--
-- Name: revisor; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.revisor AS
 SELECT x.producto,
    x.division,
    x.informante,
    x.observacion,
    x.periodo1_pr,
    x.periodo1_tipo,
    x.periodo1_enc,
    x.periodo1_var,
    x.periodo2_pr,
    x.periodo2_tipo,
    x.periodo2_enc,
    x.periodo2_var,
    x.periodo3_pr,
    x.periodo3_tipo,
    x.periodo3_enc,
    x.periodo3_var,
    x.periodo4_pr,
    x.periodo4_tipo,
    x.periodo4_enc,
    x.periodo4_var,
    x.periodo5_pr,
    x.periodo5_tipo,
    x.periodo5_enc,
    x.periodo5_var,
    x.periodo6_pr,
    x.periodo6_tipo,
    x.periodo6_enc
   FROM ( SELECT c.producto,
            c.division,
            c.informante,
            c.observacion,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 1) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo1_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 1) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 1) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo1_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 1) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 1) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 1) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo1_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN round(((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END)) * (100)::double precision) - (100)::double precision))::numeric, 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo1_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 2) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo2_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 2) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 2) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo2_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 2) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 2) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 2) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo2_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN round(((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END)) * (100)::double precision) - (100)::double precision))::numeric, 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo2_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 3) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo3_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 3) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 3) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo3_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 3) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 3) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 3) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo3_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN round(((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END)) * (100)::double precision) - (100)::double precision))::numeric, 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo3_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 4) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo4_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 4) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 4) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo4_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 4) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 4) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 4) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo4_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN round(((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END)) * (100)::double precision) - (100)::double precision))::numeric, 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo4_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 5) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo5_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 5) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 5) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo5_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 5) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 5) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 5) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo5_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN round(((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END)) * (100)::double precision) - (100)::double precision))::numeric, 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo5_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END) > (0)::double precision) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (substr((o.estado)::text, 1, 1) = 'B'::text)) THEN ((o.estado)::text || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::double precision
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 6) THEN (substr((o.estado)::text, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), 1, (strpos(comun.a_texto((round((r.precionormalizado)::numeric, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo6_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 6) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN ((COALESCE(c.impobs, ''::text))::text || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 6) THEN ((((COALESCE(r.tipoprecio, ''::text))::text || COALESCE((','::text || (r.cambio)::text), ''::text)) ||
                    CASE
                        WHEN ((r.tipoprecio)::text = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto(bp.precio)), ''::text) || COALESCE((' '::text || (bp.tipoprecio)::text), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || (o.estado)::text) || 'Manual '::text)
                    ELSE ''::text
                END), ';'::text ORDER BY r.visita), ''::text)) AS periodo6_tipo,
            ((COALESCE(string_agg(
                CASE
                    WHEN (pe.nroperiodo = 6) THEN r.comentariosrelpre
                    ELSE NULL::text
                END, ';'::text ORDER BY r.visita), ''::text) ||
                CASE
                    WHEN (COALESCE(string_agg(
                    CASE
                        WHEN (pe.nroperiodo = 6) THEN r.comentariosrelpre
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita), ''::text) <> ''::text) THEN '/'::text
                    ELSE ''::text
                END) || min(
                CASE
                    WHEN (pe.nroperiodo = 6) THEN (((v.encuestador)::text || ':'::text) || (per.apellido)::text)
                    ELSE NULL::text
                END)) AS periodo6_enc
           FROM ((((((((cvp.calobs c
             LEFT JOIN ( SELECT (row_number() OVER (ORDER BY p.periodo))::integer AS nroperiodo,
                    p.periodo
                   FROM ( SELECT calculos.periodo
                           FROM cvp.calculos
                          WHERE (calculos.calculo = 0)
                          ORDER BY calculos.periodo DESC
                         LIMIT 6) p) pe ON (((c.periodo)::text = (pe.periodo)::text)))
             LEFT JOIN cvp.relpre r ON (((r.informante = c.informante) AND ((r.producto)::text = (c.producto)::text) AND ((r.periodo)::text = (c.periodo)::text) AND (r.observacion = c.observacion))))
             LEFT JOIN cvp.relvis v ON (((v.informante = r.informante) AND ((v.periodo)::text = (r.periodo)::text) AND (v.visita = r.visita) AND (v.formulario = r.formulario))))
             LEFT JOIN cvp.blapre bp ON (((r.informante = bp.informante) AND ((r.producto)::text = (bp.producto)::text) AND ((r.periodo)::text = (bp.periodo)::text) AND (r.observacion = bp.observacion) AND (r.visita = bp.visita))))
             LEFT JOIN ( SELECT blaatr.periodo,
                    blaatr.producto,
                    blaatr.informante,
                    blaatr.observacion,
                    blaatr.visita,
                    string_agg((blaatr.valor)::text, ','::text ORDER BY blaatr.atributo) AS valores
                   FROM cvp.blaatr
                  WHERE (blaatr.valor IS NOT NULL)
                  GROUP BY blaatr.periodo, blaatr.producto, blaatr.informante, blaatr.observacion, blaatr.visita) ba ON (((r.informante = ba.informante) AND ((r.producto)::text = (ba.producto)::text) AND ((r.periodo)::text = (ba.periodo)::text) AND (r.observacion = ba.observacion) AND (r.visita = ba.visita))))
             LEFT JOIN ( SELECT x_1.periodo,
                    x_1.producto,
                    x_1.informante,
                    x_1.observacion,
                    x_1.visita,
                    string_agg(((COALESCE(x_1.valor, ''::text))::text || (COALESCE(a.unidaddemedida, ''::text))::text), ';'::text ORDER BY x_1.atributo) AS valorprincipal
                   FROM ((cvp.relatr x_1
                     LEFT JOIN cvp.prodatr y ON ((((x_1.producto)::text = (y.producto)::text) AND (x_1.atributo = y.atributo))))
                     LEFT JOIN cvp.atributos a ON ((y.atributo = a.atributo)))
                  WHERE ((y.esprincipal)::text = 'S'::text)
                  GROUP BY x_1.periodo, x_1.producto, x_1.informante, x_1.observacion, x_1.visita) pat ON (((r.informante = pat.informante) AND ((r.producto)::text = (pat.producto)::text) AND ((r.periodo)::text = (pat.periodo)::text) AND (r.observacion = pat.observacion) AND (r.visita = pat.visita))))
             LEFT JOIN cvp.personal per ON (((v.encuestador)::text = (per.persona)::text)))
             LEFT JOIN cvp.novobs o ON ((((c.periodo)::text = (o.periodo)::text) AND (c.calculo = o.calculo) AND ((c.producto)::text = (o.producto)::text) AND (c.informante = o.informante) AND (c.observacion = o.observacion)))),
            cvp.revisor_parametros rr
          WHERE ((c.calculo = 0) AND ((rr.versionexigida <= 'V170111'::text) AND (rr.versionbase >= 'V130417'::text)))
          GROUP BY c.producto, c.division, c.informante, c.observacion) x
  ORDER BY x.producto, x.division, x.informante, x.observacion;


ALTER TABLE cvp.revisor OWNER TO cvpowner;

--
-- Name: rubfor; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.rubfor (
    formulario integer NOT NULL,
    rubro integer NOT NULL
);


ALTER TABLE cvp.rubfor OWNER TO cvpowner;

--
-- Name: selprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.selprod (
    producto text NOT NULL,
    sel_nro integer NOT NULL,
    descripcion text,
    rubro text,
    proveedor text,
    cantidad text,
    observaciones text,
    especificacion text,
    valordesde double precision,
    valorhasta double precision,
    excluir text,
    CONSTRAINT "texto invalido en cantidad de tabla selprod" CHECK (comun.cadena_valida(cantidad, 'extendido'::text)),
    CONSTRAINT "texto invalido en descripcion de tabla selprod" CHECK (comun.cadena_valida(descripcion, 'castellano'::text)),
    CONSTRAINT "texto invalido en especificacion de tabla selprod" CHECK (comun.cadena_valida(especificacion, 'amplio'::text)),
    CONSTRAINT "texto invalido en excluir de tabla selprod" CHECK (comun.cadena_valida(excluir, 'amplio'::text)),
    CONSTRAINT "texto invalido en observaciones de tabla selprod" CHECK (comun.cadena_valida(observaciones, 'amplio'::text)),
    CONSTRAINT "texto invalido en proveedor de tabla selprod" CHECK (comun.cadena_valida(proveedor, 'amplio'::text)),
    CONSTRAINT "texto invalido en rubro de tabla selprod" CHECK (comun.cadena_valida(rubro, 'castellano'::text))
);


ALTER TABLE cvp.selprod OWNER TO cvpowner;

--
-- Name: selprodatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.selprodatr (
    producto text NOT NULL,
    sel_nro integer NOT NULL,
    atributo integer NOT NULL,
    valor text,
    valorsinsimplificar text,
    CONSTRAINT "texto invalido en valor de tabla selprodatr" CHECK (comun.cadena_valida(valor, 'amplio'::text)),
    CONSTRAINT "texto invalido en valorsinsimplificar de tabla selprodatr" CHECK (comun.cadena_valida(valorsinsimplificar, 'amplio'::text))
);


ALTER TABLE cvp.selprodatr OWNER TO cvpowner;

--
-- Name: tipoinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tipoinf (
    tipoinformante text NOT NULL,
    otrotipoinformante text NOT NULL,
    nombretipoinformante text,
    CONSTRAINT "texto invalido en nombretipoinformante de tabla tipoinf" CHECK (comun.cadena_valida(nombretipoinformante, 'castellano'::text))
);


ALTER TABLE cvp.tipoinf OWNER TO cvpowner;

--
-- Name: tokens; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tokens (
    token text NOT NULL,
    date timestamp without time zone NOT NULL,
    username text NOT NULL,
    useragent jsonb NOT NULL,
);


ALTER TABLE cvp.tokens OWNER TO cvpowner;

--
-- Name: transf_info; Type: TABLE; Schema: cvp; Owner: postgres
--

CREATE TABLE cvp.transf_info (
    operativo text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL
);


ALTER TABLE cvp.transf_info OWNER TO postgres;

--
-- Name: transf_data; Type: VIEW; Schema: cvp; Owner: postgres
--

CREATE VIEW cvp.transf_data AS
 SELECT c.periodo,
    c.agrupacion,
    c.grupo,
    round((c.valorgru)::numeric, 2) AS valorgruredondeado,
    round((c.valorgrupromedio)::numeric, 2) AS valorgrupromedioredondeado
   FROM ((cvp.calgru_promedios c
     JOIN cvp.transf_info t ON (((t.operativo = 'val_can'::text) AND ((c.agrupacion)::text = t.agrupacion) AND ((c.grupo)::text = t.grupo))))
     JOIN cvp.calculos cal ON (((cal.calculo = c.calculo) AND ((cal.periodo)::text = (c.periodo)::text) AND ((cal.transmitir_canastas)::text = 'S'::text))))
  ORDER BY c.periodo, c.agrupacion, c.grupo, (round((c.valorgru)::numeric, 2)), (round((c.valorgrupromedio)::numeric, 2));


ALTER TABLE cvp.transf_data OWNER TO postgres;

--
-- Name: transf_data_orig; Type: VIEW; Schema: cvp; Owner: postgres
--

CREATE VIEW cvp.transf_data_orig AS
 SELECT c.periodo,
    c.agrupacion,
    c.grupo,
    round((c.valorgru)::numeric, 2) AS valorgruredondeado
   FROM ((cvp.calgru c
     JOIN cvp.transf_info t ON (((t.operativo = 'val_can'::text) AND ((c.agrupacion)::text = t.agrupacion) AND ((c.grupo)::text = t.grupo))))
     JOIN cvp.calculos cal ON (((cal.calculo = c.calculo) AND ((cal.periodo)::text = (c.periodo)::text) AND ((cal.transmitir_canastas)::text = 'S'::text))))
  ORDER BY c.periodo, c.agrupacion, c.grupo, (round((c.valorgru)::numeric, 2));


ALTER TABLE cvp.transf_data_orig OWNER TO postgres;

--
-- Name: unidades; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.unidades (
    unidad text NOT NULL,
    magnitud text NOT NULL,
    factor double precision,
    morfologia text,
    abreviaturaestandar text,
    CONSTRAINT "texto invalido en abreviaturaestandar de tabla unidades" CHECK (comun.cadena_valida(abreviaturaestandar, 'amplio'::text)),
    CONSTRAINT "texto invalido en magnitud de tabla unidades" CHECK (comun.cadena_valida(magnitud, 'amplio'::text)),
    CONSTRAINT "texto invalido en morfologia de tabla unidades" CHECK (comun.cadena_valida(morfologia, 'amplio'::text)),
    CONSTRAINT "texto invalido en unidad de tabla unidades" CHECK (comun.cadena_valida(unidad, 'castellano'::text))
);


ALTER TABLE cvp.unidades OWNER TO cvpowner;

--
-- Name: users; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.users (
    username text NOT NULL,
    md5pass text,
    active_until date,
    locked_since date,
    rol text
);


ALTER TABLE cvp.users OWNER TO cvpowner;

--
-- Name: valorizacion_canasta; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.valorizacion_canasta AS
 SELECT h.periodo,
    h.calculo,
    h.hogar,
    h.agrupacion,
    h.grupo,
    h.valorhoggru,
    c.nivel,
    c.grupopadre,
    substr((h.grupo)::text, 1, 2) AS grupo_n2
   FROM (cvp.calgru c
     JOIN cvp.calhoggru h ON ((((c.periodo)::text = (h.periodo)::text) AND (c.calculo = h.calculo) AND ((c.agrupacion)::text = (h.agrupacion)::text) AND ((c.grupo)::text = (h.grupo)::text))))
  WHERE (((c.nivel = 2) AND ((c.grupopadre)::text <> 'A1'::text) AND ((h.grupo)::text <> ALL (ARRAY['B11'::text, 'D11'::text]))) OR ((c.nivel = 3) AND ((c.grupopadre)::text = ANY (ARRAY['B11'::text, 'D11'::text]))))
UNION
 SELECT calhogsubtotales.periodo,
    calhogsubtotales.calculo,
    calhogsubtotales.hogar,
    calhogsubtotales.agrupacion,
    calhogsubtotales.grupo,
    calhogsubtotales.valorhogsub AS valorhoggru,
    NULL::integer AS nivel,
    NULL::text AS grupopadre,
    substr((calhogsubtotales.grupo)::text, 1, 2) AS grupo_n2
   FROM cvp.calhogsubtotales
  ORDER BY 9, 7 DESC, 5;


ALTER TABLE cvp.valorizacion_canasta OWNER TO cvpowner;

--
-- Name: valorizacion_canasta_cuadros; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.valorizacion_canasta_cuadros AS
 SELECT v.periodo,
    v.calculo,
    v.hogar,
    v.agrupacion,
        CASE
            WHEN ((v.grupo)::text = 'B118'::text) THEN 'B117'::text
            WHEN ((v.grupo)::text = 'B119'::text) THEN 'B118'::text
            ELSE v.grupo
        END AS grupo,
    sum(v.valorhoggru) AS valorhoggru,
    COALESCE(v.nivel, 1) AS nivel,
    v.grupopadre,
    v.grupo_n2,
        CASE
            WHEN (((g.nombregrupo)::text ~~ 'Bebidas%'::text) AND ((v.agrupacion)::text <> 'D'::text)) THEN 'Bebidas'::text
            ELSE g.nombregrupo
        END AS nombregrupo,
    g.nombrecanasta
   FROM (cvp.valorizacion_canasta v
     LEFT JOIN cvp.grupos g ON ((((v.agrupacion)::text = (g.agrupacion)::text) AND ((v.grupo)::text = (g.grupo)::text))))
  GROUP BY v.periodo, v.calculo, v.hogar, v.agrupacion,
        CASE
            WHEN ((v.grupo)::text = 'B118'::text) THEN 'B117'::text
            WHEN ((v.grupo)::text = 'B119'::text) THEN 'B118'::text
            ELSE v.grupo
        END, COALESCE(v.nivel, 1), v.grupopadre, v.grupo_n2,
        CASE
            WHEN (((g.nombregrupo)::text ~~ 'Bebidas%'::text) AND ((v.agrupacion)::text <> 'D'::text)) THEN 'Bebidas'::text
            ELSE g.nombregrupo
        END, g.nombrecanasta;


ALTER TABLE cvp.valorizacion_canasta_cuadros OWNER TO cvpowner;

--
-- Name: valvalatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.valvalatr (
    producto text NOT NULL,
    atributo integer NOT NULL,
    valor text NOT NULL,
    validar boolean DEFAULT true NOT NULL,
    ponderadoratr double precision,
    CONSTRAINT "El valor del campo validar debe ser siempre TRUE" CHECK (validar),
    CONSTRAINT "texto invalido en valor de tabla valvalatr" CHECK (comun.cadena_valida(valor, 'amplio'::text))
);


ALTER TABLE cvp.valvalatr OWNER TO cvpowner;

--
-- Name: variaciones_maximas_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.variaciones_maximas_vw AS
 SELECT a.periodo,
    a.producto,
    a.nombreproducto,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 1) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 1))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion1,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 2) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 2))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion2,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 3) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 3))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion3,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 4) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 4))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion4,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 5) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 5))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion5,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 6) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 6))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion6,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 7) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 7))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion7,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 8) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 8))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion8,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 9) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 9))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion9,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 10) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 10))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion10,
    NULLIF(split_part(m.informantes, ';'::text, 1), ''::text) AS informantes1,
    NULLIF(split_part(m.informantes, ';'::text, 2), ''::text) AS informantes2,
    NULLIF(split_part(m.informantes, ';'::text, 3), ''::text) AS informantes3,
    NULLIF(split_part(m.informantes, ';'::text, 4), ''::text) AS informantes4,
    NULLIF(split_part(m.informantes, ';'::text, 5), ''::text) AS informantes5,
    NULLIF(split_part(m.informantes, ';'::text, 6), ''::text) AS informantes6,
    NULLIF(split_part(m.informantes, ';'::text, 7), ''::text) AS informantes7,
    NULLIF(split_part(m.informantes, ';'::text, 8), ''::text) AS informantes8,
    NULLIF(split_part(m.informantes, ';'::text, 9), ''::text) AS informantes9,
    NULLIF(split_part(m.informantes, ';'::text, 10), ''::text) AS informantes10
   FROM (( SELECT pe.periodo,
            pr.producto,
            pr.nombreproducto
           FROM (( SELECT periodos.periodo
                   FROM cvp.periodos
                  ORDER BY periodos.periodo DESC
                 LIMIT 12) pe
             JOIN ( SELECT productos.producto,
                    productos.nombreproducto
                   FROM cvp.productos
                  WHERE ((productos.nombreproducto)::text !~~ '%orrar%'::text)) pr ON (true))) a
     LEFT JOIN cvp.periodo_maximas_variaciones(10) m(periodo, producto, nombreproducto, variaciones, informantes) ON ((((a.periodo)::text = (m.periodo)::text) AND ((a.producto)::text = (m.producto)::text) AND ((a.nombreproducto)::text = (m.nombreproducto)::text))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.variaciones_maximas_vw OWNER TO cvpowner;

--
-- Name: variaciones_minimas_vw; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.variaciones_minimas_vw AS
 SELECT a.periodo,
    a.producto,
    a.nombreproducto,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 1) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 1))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion1,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 2) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 2))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion2,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 3) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 3))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion3,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 4) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 4))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion4,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 5) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 5))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion5,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 6) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 6))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion6,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 7) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 7))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion7,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 8) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 8))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion8,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 9) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 9))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion9,
        CASE
            WHEN (split_part(m.variaciones, '|'::text, 10) <> ''::text) THEN round((split_part(m.variaciones, '|'::text, 10))::numeric, 2)
            ELSE NULL::numeric
        END AS variacion10,
    NULLIF(split_part(m.informantes, ';'::text, 1), ''::text) AS informantes1,
    NULLIF(split_part(m.informantes, ';'::text, 2), ''::text) AS informantes2,
    NULLIF(split_part(m.informantes, ';'::text, 3), ''::text) AS informantes3,
    NULLIF(split_part(m.informantes, ';'::text, 4), ''::text) AS informantes4,
    NULLIF(split_part(m.informantes, ';'::text, 5), ''::text) AS informantes5,
    NULLIF(split_part(m.informantes, ';'::text, 6), ''::text) AS informantes6,
    NULLIF(split_part(m.informantes, ';'::text, 7), ''::text) AS informantes7,
    NULLIF(split_part(m.informantes, ';'::text, 8), ''::text) AS informantes8,
    NULLIF(split_part(m.informantes, ';'::text, 9), ''::text) AS informantes9,
    NULLIF(split_part(m.informantes, ';'::text, 10), ''::text) AS informantes10
   FROM (( SELECT pe.periodo,
            pr.producto,
            pr.nombreproducto
           FROM (( SELECT periodos.periodo
                   FROM cvp.periodos
                  ORDER BY periodos.periodo DESC
                 LIMIT 12) pe
             JOIN ( SELECT productos.producto,
                    productos.nombreproducto
                   FROM cvp.productos
                  WHERE ((productos.nombreproducto)::text !~~ '%orrar%'::text)) pr ON (true))) a
     LEFT JOIN cvp.periodo_minimas_variaciones(10) m(periodo, producto, nombreproducto, variaciones, informantes) ON ((((a.periodo)::text = (m.periodo)::text) AND ((a.producto)::text = (m.producto)::text) AND ((a.nombreproducto)::text = (m.nombreproducto)::text))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.variaciones_minimas_vw OWNER TO cvpowner;

--
-- Name: variedades; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.variedades (
    producto text NOT NULL,
    especificacion integer NOT NULL,
    variedad integer NOT NULL,
    nombrevariedad text,
    tamanno double precision,
    unidad text,
    codigovariedad text,
    modi_usu text,
    modi_fec timestamp without time zone,
    modi_ope text
);


ALTER TABLE cvp.variedades OWNER TO cvpowner;

--
-- Name: conjuntomuestral conjuntomuestral; Type: DEFAULT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.conjuntomuestral ALTER COLUMN conjuntomuestral SET DEFAULT nextval('cvp.conjuntomuestral_conjuntomuestral_seq'::regclass);


--
-- Name: proddiv Puede existir solo una division sin tipo de informante; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "Puede existir solo una division sin tipo de informante" UNIQUE (producto, sindividir);


--
-- Name: agrupaciones agrupaciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.agrupaciones
    ADD CONSTRAINT agrupaciones_pkey PRIMARY KEY (agrupacion);


--
-- Name: atributos atributos_es_vigencia_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.atributos
    ADD CONSTRAINT atributos_es_vigencia_key UNIQUE (es_vigencia);


--
-- Name: atributos atributos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.atributos
    ADD CONSTRAINT atributos_pkey PRIMARY KEY (atributo);


--
-- Name: blaatr blaatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita, atributo);


--
-- Name: blapre blapre_periodo_producto_observacion_informante_ultima_visit_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_periodo_producto_observacion_informante_ultima_visit_key UNIQUE (periodo, producto, observacion, informante, ultima_visita);


--
-- Name: blapre blapre_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


--
-- Name: cal_mensajes cal_mensajes_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cal_mensajes
    ADD CONSTRAINT cal_mensajes_pkey PRIMARY KEY (periodo, calculo, corrida, paso, renglon);


--
-- Name: calbase_div calbase_div_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_div
    ADD CONSTRAINT calbase_div_pkey PRIMARY KEY (producto, calculo, division);


--
-- Name: calbase_obs calbase_obs_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_obs
    ADD CONSTRAINT calbase_obs_pkey PRIMARY KEY (calculo, producto, informante, observacion);


--
-- Name: calbase_prod calbase_prod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_prod
    ADD CONSTRAINT calbase_prod_pkey PRIMARY KEY (producto, calculo);


--
-- Name: calculos_def calculos_def_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT calculos_def_pkey PRIMARY KEY (calculo);


--
-- Name: calculos_def calculos_def_principal_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT calculos_def_principal_key UNIQUE (principal);


--
-- Name: calculos calculos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT calculos_pkey PRIMARY KEY (periodo, calculo);


--
-- Name: calgru calgru_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT calgru_pkey PRIMARY KEY (periodo, calculo, agrupacion, grupo);


--
-- Name: calhoggru calhoggru_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT calhoggru_pkey PRIMARY KEY (periodo, calculo, hogar, agrupacion, grupo);


--
-- Name: calhogsubtotales calhogsubtotales_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT calhogsubtotales_pkey PRIMARY KEY (periodo, calculo, hogar, agrupacion, grupo);


--
-- Name: calobs calobs_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_pkey PRIMARY KEY (periodo, calculo, producto, informante, observacion);


--
-- Name: calprod calprod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT calprod_pkey PRIMARY KEY (periodo, calculo, producto);


--
-- Name: calprodagr calprodagr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_pkey PRIMARY KEY (periodo, calculo, producto, agrupacion);


--
-- Name: calprodresp calprodresp_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT calprodresp_pkey PRIMARY KEY (periodo, calculo, producto);


--
-- Name: caldiv caltipoinf_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caltipoinf_pkey PRIMARY KEY (periodo, calculo, producto, division);


--
-- Name: conjuntomuestral conjuntomuestral_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.conjuntomuestral
    ADD CONSTRAINT conjuntomuestral_pkey PRIMARY KEY (conjuntomuestral);


--
-- Name: cuadros_funciones cuadros_funciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuadros_funciones
    ADD CONSTRAINT cuadros_funciones_pkey PRIMARY KEY (funcion);


--
-- Name: cuadros cuadros_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuadros
    ADD CONSTRAINT cuadros_pkey PRIMARY KEY (cuadro);


--
-- Name: cuagru cuagru_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuagru
    ADD CONSTRAINT cuagru_pkey PRIMARY KEY (cuadro, agrupacion, grupo);


--
-- Name: dicprodatr dicprodatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.dicprodatr
    ADD CONSTRAINT dicprodatr_pkey PRIMARY KEY (producto, atributo, origen);


--
-- Name: divisiones divisiones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT divisiones_pkey PRIMARY KEY (division);


--
-- Name: divisiones divisiones_sindividir_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT divisiones_sindividir_key UNIQUE (sindividir);


--
-- Name: especificaciones especificaciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.especificaciones
    ADD CONSTRAINT especificaciones_pkey PRIMARY KEY (producto, especificacion);


--
-- Name: forinf forinf_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT forinf_pkey PRIMARY KEY (formulario, informante);


--
-- Name: formularios formularios_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.formularios
    ADD CONSTRAINT formularios_pkey PRIMARY KEY (formulario);


--
-- Name: formulariosimportados formulariosimportados_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.formulariosimportados
    ADD CONSTRAINT formulariosimportados_pkey PRIMARY KEY (ano, mes, informante, producto, observacion, atributo);


--
-- Name: forprod forprod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forprod
    ADD CONSTRAINT forprod_pkey PRIMARY KEY (formulario, producto);


--
-- Name: grupos grupos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT grupos_pkey PRIMARY KEY (agrupacion, grupo);


--
-- Name: divisiones hay una division por cada combinacion de tipos de informante in; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT "hay una division por cada combinacion de tipos de informante in" UNIQUE (incluye_supermercados, incluye_tradicionales);


--
-- Name: hogares hogares_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogares
    ADD CONSTRAINT hogares_pkey PRIMARY KEY (hogar);


--
-- Name: hogparagr hogparagr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT hogparagr_pkey PRIMARY KEY (parametro, hogar, agrupacion);


--
-- Name: infoextvalor infoext_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infoextvalor
    ADD CONSTRAINT infoext_pkey PRIMARY KEY (periodo, calculo, producto);


--
-- Name: infoextprod infoextprod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infoextprod
    ADD CONSTRAINT infoextprod_pkey PRIMARY KEY (producto);


--
-- Name: informantes informantes_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informantes_pkey PRIMARY KEY (informante);


--
-- Name: infreemp infreemp_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infreemp
    ADD CONSTRAINT infreemp_pkey PRIMARY KEY (id_informante_reemplazante);


--
-- Name: instalaciones instalaciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.instalaciones
    ADD CONSTRAINT instalaciones_pkey PRIMARY KEY (id_instalacion);


--
-- Name: locks locks_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (table_name, record_pk);


--
-- Name: magnitudes magnitudes_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.magnitudes
    ADD CONSTRAINT magnitudes_pkey PRIMARY KEY (magnitud);


--
-- Name: modulos modulos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.modulos
    ADD CONSTRAINT modulos_pkey PRIMARY KEY (formulario, zona, nombre);


--
-- Name: modulosusuarios modulosusuarios_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.modulosusuarios
    ADD CONSTRAINT modulosusuarios_pkey PRIMARY KEY (formulario, zona, nombre, username);


--
-- Name: monedas monedas_es_nacional_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.monedas
    ADD CONSTRAINT monedas_es_nacional_key UNIQUE (es_nacional);


--
-- Name: monedas monedas_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.monedas
    ADD CONSTRAINT monedas_pkey PRIMARY KEY (moneda);


--
-- Name: muestras muestras_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.muestras
    ADD CONSTRAINT muestras_pkey PRIMARY KEY (muestra);


--
-- Name: novdelobs novdelobs_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelobs
    ADD CONSTRAINT novdelobs_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


--
-- Name: novdelvis novdelvis_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelvis
    ADD CONSTRAINT novdelvis_pkey PRIMARY KEY (periodo, informante, visita, formulario);


--
-- Name: novespinf novespinf_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novespinf
    ADD CONSTRAINT novespinf_pkey PRIMARY KEY (periodo, calculo, producto, especificacion, informante);


--
-- Name: novext novext_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novext
    ADD CONSTRAINT novext_pkey PRIMARY KEY (periodo, calculo, producto);


--
-- Name: novobs_base novobs_base_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs_base
    ADD CONSTRAINT novobs_base_pkey PRIMARY KEY (producto, informante, observacion);


--
-- Name: novobs novobs_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT novobs_pkey PRIMARY KEY (periodo, calculo, producto, informante, observacion);


--
-- Name: novpre novpre_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novpre
    ADD CONSTRAINT novpre_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


--
-- Name: novprod novprod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novprod
    ADD CONSTRAINT novprod_pkey PRIMARY KEY (periodo, calculo, producto);


--
-- Name: numeros numeros_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.numeros
    ADD CONSTRAINT numeros_pkey PRIMARY KEY (numero);


--
-- Name: pantar pantar_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pantar
    ADD CONSTRAINT pantar_pkey PRIMARY KEY (panel, tarea);


--
-- Name: pantar pantar_tarea_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pantar
    ADD CONSTRAINT pantar_tarea_key UNIQUE (tarea, grupozonal, panel2009);


--
-- Name: parametros parametros_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parametros
    ADD CONSTRAINT parametros_pkey PRIMARY KEY (unicoregistro);


--
-- Name: parhog parhog_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhog
    ADD CONSTRAINT parhog_pkey PRIMARY KEY (parametro);


--
-- Name: parhoggru parhoggru_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhoggru
    ADD CONSTRAINT parhoggru_pkey PRIMARY KEY (parametro, agrupacion, grupo);


--
-- Name: pasoatraves pasoatraves_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pasoatraves
    ADD CONSTRAINT pasoatraves_pkey PRIMARY KEY (unicoregistro);


--
-- Name: pb_calculos_reglas pb_calculos_reglas_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_calculos_reglas
    ADD CONSTRAINT pb_calculos_reglas_pkey PRIMARY KEY (calculo, tipo_regla, num_regla);


--
-- Name: pb_externos pb_externos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_externos
    ADD CONSTRAINT pb_externos_pkey PRIMARY KEY (producto, periodo);


--
-- Name: periodos periodos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.periodos
    ADD CONSTRAINT periodos_pkey PRIMARY KEY (periodo);


--
-- Name: personal persona_pk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT persona_pk PRIMARY KEY (persona);


--
-- Name: personal personal_username_uk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT personal_username_uk UNIQUE (username);


--
-- Name: personalmigtemp personalmigtemp_pk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personalmigtemp
    ADD CONSTRAINT personalmigtemp_pk PRIMARY KEY (usuario, periodo);


--
-- Name: prerep prerep_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prerep
    ADD CONSTRAINT prerep_pkey PRIMARY KEY (periodo, producto, informante);


--
-- Name: prodagr prodagr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodagr
    ADD CONSTRAINT prodagr_pkey PRIMARY KEY (producto, agrupacion);


--
-- Name: prodatr prodatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT prodatr_pkey PRIMARY KEY (producto, atributo);


--
-- Name: prodatrval prodatrval_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatrval
    ADD CONSTRAINT prodatrval_pkey PRIMARY KEY (producto, atributo, valor);


--
-- Name: proddiv proddiv_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT proddiv_pkey PRIMARY KEY (producto, division);


--
-- Name: proddivestimac proddivestimac_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddivestimac
    ADD CONSTRAINT proddivestimac_pkey PRIMARY KEY (producto, division, estimacion);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (producto);


--
-- Name: razones razones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.razones
    ADD CONSTRAINT razones_pkey PRIMARY KEY (razon);


--
-- Name: divisiones redundancia para garantizar la exclusion de divisiones no compa; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT "redundancia para garantizar la exclusion de divisiones no compa" UNIQUE (division, incluye_supermercados, incluye_tradicionales);


--
-- Name: relatr relatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita, atributo);


--
-- Name: relenc relenc_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT relenc_pkey PRIMARY KEY (periodo, panel, tarea);


--
-- Name: relinf relinf_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relinf
    ADD CONSTRAINT relinf_pkey PRIMARY KEY (periodo, informante, visita, panel, tarea);


--
-- Name: relmon relmon_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT relmon_pkey PRIMARY KEY (periodo, moneda);


--
-- Name: relpan relpan_pk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpan
    ADD CONSTRAINT relpan_pk PRIMARY KEY (periodo, panel);


--
-- Name: relpre relpre_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


--
-- Name: relpre relpre_ukey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_ukey UNIQUE (periodo, producto, observacion, informante, ultima_visita);


--
-- Name: relpresemaforo relpresemaforo_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpresemaforo
    ADD CONSTRAINT relpresemaforo_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


--
-- Name: relsup relsup_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT relsup_pkey PRIMARY KEY (periodo, panel, supervisor);


--
-- Name: reltar reltar_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_pkey PRIMARY KEY (periodo, panel, tarea);


--
-- Name: relvis relvis_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_pkey PRIMARY KEY (periodo, informante, visita, formulario);


--
-- Name: relvis relvis_ukey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_ukey UNIQUE (periodo, informante, formulario, ultima_visita);


--
-- Name: rubfor rubfor_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT rubfor_pkey PRIMARY KEY (formulario, rubro);


--
-- Name: rubros rubros_pk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubros
    ADD CONSTRAINT rubros_pk PRIMARY KEY (rubro);


--
-- Name: selprod selprod_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.selprod
    ADD CONSTRAINT selprod_pkey PRIMARY KEY (producto, sel_nro);


--
-- Name: selprodatr selprodatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.selprodatr
    ADD CONSTRAINT selprodatr_pkey PRIMARY KEY (producto, sel_nro, atributo);


--
-- Name: tareas tarea_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tareas
    ADD CONSTRAINT tarea_pkey PRIMARY KEY (tarea);


--
-- Name: tipoinf tipoinf_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tipoinf
    ADD CONSTRAINT tipoinf_pkey PRIMARY KEY (tipoinformante);


--
-- Name: tipopre tipopre_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tipopre
    ADD CONSTRAINT tipopre_pkey PRIMARY KEY (tipoprecio);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token);


--
-- Name: transf_info transf_info_pkey; Type: CONSTRAINT; Schema: cvp; Owner: postgres
--

ALTER TABLE ONLY cvp.transf_info
    ADD CONSTRAINT transf_info_pkey PRIMARY KEY (operativo, agrupacion, grupo);


--
-- Name: proddiv unica division que incluye supermercados; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "unica division que incluye supermercados" UNIQUE (producto, incluye_supermercados);


--
-- Name: proddiv unica division que incluye tradicionales; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "unica division que incluye tradicionales" UNIQUE (producto, incluye_tradicionales);


--
-- Name: unidades unidades_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.unidades
    ADD CONSTRAINT unidades_pkey PRIMARY KEY (unidad);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


--
-- Name: valvalatr valvalatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT valvalatr_pkey PRIMARY KEY (producto, atributo, valor);


--
-- Name: valvalatr valvalatr_uk; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT valvalatr_uk UNIQUE (producto, atributo, valor, validar);


--
-- Name: variedades variedades_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.variedades
    ADD CONSTRAINT variedades_pkey PRIMARY KEY (producto, especificacion, variedad);


--
-- Name: blaatr_producto_observacion_informante_atr_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX blaatr_producto_observacion_informante_atr_idx ON cvp.blaatr USING btree (producto, observacion, informante, atributo);


--
-- Name: blapre_producto_observacion_informante_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX blapre_producto_observacion_informante_idx ON cvp.blapre USING btree (producto, observacion, informante);


--
-- Name: blapre_relvis_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX blapre_relvis_idx ON cvp.blapre USING btree (informante, periodo, formulario, visita);


--
-- Name: calculos_ant_i; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX calculos_ant_i ON cvp.calculos USING btree (periodoanterior, calculo);


--
-- Name: calobs_producto_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX calobs_producto_idx ON cvp.calobs USING btree (producto);


--
-- Name: encuestador 4 instalaciones IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 instalaciones IDX" ON cvp.instalaciones USING btree (encuestador);


--
-- Name: encuestador_i; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX encuestador_i ON cvp.tareas USING btree (encuestador);


--
-- Name: fki_periodo_ant; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX fki_periodo_ant ON cvp.periodos USING btree (periodoanterior);


--
-- Name: grupos_ag_padres_i; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX grupos_ag_padres_i ON cvp.grupos USING btree (agrupacion, grupo, grupopadre);


--
-- Name: grupos_nivel_i; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX grupos_nivel_i ON cvp.grupos USING btree (nivel);


--
-- Name: grupos_padres_i; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX grupos_padres_i ON cvp.grupos USING btree (agrupacion, grupopadre);


--
-- Name: prodatr_normalizable_valornormal_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX prodatr_normalizable_valornormal_idx ON cvp.prodatr USING btree (normalizable, valornormal);


--
-- Name: relatr_producto_observacion_informante_atr_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX relatr_producto_observacion_informante_atr_idx ON cvp.relatr USING btree (producto, observacion, informante, atributo);


--
-- Name: relpre_producto_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX relpre_producto_idx ON cvp.relpre USING btree (producto);


--
-- Name: relpre_producto_observacion_informante_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX relpre_producto_observacion_informante_idx ON cvp.relpre USING btree (producto, observacion, informante);


--
-- Name: relpre_relvis_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX relpre_relvis_idx ON cvp.relpre USING btree (informante, periodo, formulario, visita);


--
-- Name: reltar_persona_habilitada_idx; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE UNIQUE INDEX reltar_persona_habilitada_idx ON cvp.reltar USING btree (encuestador, ((vencimiento_sincronizacion IS NOT NULL))) WHERE (vencimiento_sincronizacion IS NOT NULL);


--
-- Name: relenc actualizar_enc; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER actualizar_enc BEFORE INSERT OR UPDATE ON cvp.relenc FOR EACH ROW EXECUTE PROCEDURE cvp.actualizar_enc_trg();


--
-- Name: agrupaciones agrupaciones_fijas_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER agrupaciones_fijas_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.agrupaciones FOR EACH ROW EXECUTE PROCEDURE cvp.agrupaciones_fijas_trg();


--
-- Name: grupos agrupaciones_fijas_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER agrupaciones_fijas_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.grupos FOR EACH ROW EXECUTE PROCEDURE cvp.agrupaciones_fijas_trg();


--
-- Name: informantes altamanualdeinformantes_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER altamanualdeinformantes_trg BEFORE UPDATE ON cvp.informantes FOR EACH ROW EXECUTE PROCEDURE cvp.altamanualdeinformantes_trg();


--
-- Name: cal_mensajes cal_mensajes_setear_renglon_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER cal_mensajes_setear_renglon_trg BEFORE INSERT ON cvp.cal_mensajes FOR EACH ROW EXECUTE PROCEDURE cvp.setear_renglon_de_cal_mensajes_trg();


--
-- Name: calculos calculos_controlar_abrir_cerrar_calculo_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calculos_controlar_abrir_cerrar_calculo_trg BEFORE UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_abrir_cerrar_calculo_trg();


--
-- Name: calculos calculos_controlar_transmitir_canastas_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calculos_controlar_transmitir_canastas_trg BEFORE UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_transmitir_canasta_trg();


--
-- Name: calculos calculos_ext_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calculos_ext_trg BEFORE UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_externos();


--
-- Name: calculos calculos_lan_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calculos_lan_trg BEFORE INSERT OR UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_lanzamiento_calculo();


--
-- Name: calculos calculos_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calculos_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: calprodresp calprodresp_controlar_revision_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calprodresp_controlar_revision_trg BEFORE UPDATE ON cvp.calprodresp FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_revision_trg();


--
-- Name: especificaciones especificaciones_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER especificaciones_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.especificaciones FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: grupos grupos_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER grupos_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.grupos FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: formulariosimportados hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.formulariosimportados FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_formulariosimportados_trg();


--
-- Name: agrupaciones hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.agrupaciones FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_agrupaciones_trg();


--
-- Name: calculos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.calculos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_calculos_trg();


--
-- Name: forinf hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.forinf FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_forinf_trg();


--
-- Name: grupos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.grupos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_grupos_trg();


--
-- Name: novespinf hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novespinf FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_novespinf_trg();


--
-- Name: novext hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novext FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_novext_trg();


--
-- Name: prodatr hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.prodatr FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_prodatr_trg();


--
-- Name: variedades hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.variedades FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_variedades_trg();


--
-- Name: parametros hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.parametros FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_parametros_trg();


--
-- Name: pasoatraves hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.pasoatraves FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_pasoatraves_trg();


--
-- Name: tipopre hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.tipopre FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_tipopre_trg();


--
-- Name: personal hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.personal FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_personal_trg();


--
-- Name: tareas hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.tareas FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_tareas_trg();


--
-- Name: conjuntomuestral hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.conjuntomuestral FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_conjuntomuestral_trg();


--
-- Name: razones hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.razones FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_razones_trg();


--
-- Name: rubros hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.rubros FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_rubros_trg();


--
-- Name: pantar hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.pantar FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_pantar_trg();


--
-- Name: relatr hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relatr_trg();


--
-- Name: relvis hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relvis_trg();


--
-- Name: relpan hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpan FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relpan_trg();


--
-- Name: periodos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_periodos_trg();


--
-- Name: productos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.productos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_productos_trg();


--
-- Name: atributos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.atributos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_atributos_trg();


--
-- Name: tipoinf hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.tipoinf FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_tipoinf_trg();


--
-- Name: especificaciones hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.especificaciones FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_especificaciones_trg();


--
-- Name: informantes hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.informantes FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_informantes_trg();


--
-- Name: personalmigtemp hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.personalmigtemp FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_personalmigtemp_trg();


--
-- Name: relpre hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relpre_trg();


--
-- Name: formularios hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.formularios FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_formularios_trg();


--
-- Name: numeros hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.numeros FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_numeros_trg();


--
-- Name: novprod hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novprod FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_novprod_trg();


--
-- Name: novobs hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_novobs_trg();


--
-- Name: valvalatr hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.valvalatr FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_valvalatr_trg();


--
-- Name: pb_externos hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.pb_externos FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_pb_externos_trg();


--
-- Name: reltar hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_reltar_trg();


--
-- Name: relsup hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relsup FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relsup_trg();


--
-- Name: relmon hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relmon FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relmon_trg();


--
-- Name: novpre hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_novpre_trg();


--
-- Name: relenc hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relenc FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relenc_trg();


--
-- Name: prerep hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.prerep FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_prerep_trg();


--
-- Name: relinf hisc_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER hisc_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relinf FOR EACH ROW EXECUTE PROCEDURE cvp.hisc_relinf_trg();


--
-- Name: informantes informantes_direccion_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER informantes_direccion_trg BEFORE INSERT OR UPDATE ON cvp.informantes FOR EACH ROW EXECUTE PROCEDURE cvp.generar_direccion_informante_trg();


--
-- Name: informantes informantes_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER informantes_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.informantes FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novdelobs novdelobs_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelobs_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novdelobs FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novdelobs novdelobs_borrar_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelobs_borrar_trg BEFORE UPDATE ON cvp.novdelobs FOR EACH ROW EXECUTE PROCEDURE cvp.borrar_precios_trg();


--
-- Name: novdelobs novdelobs_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelobs_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novdelobs FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novdelvis novdelvis_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelvis_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novdelvis FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novdelvis novdelvis_borrar_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelvis_borrar_trg BEFORE UPDATE ON cvp.novdelvis FOR EACH ROW EXECUTE PROCEDURE cvp.borrar_visita_trg();


--
-- Name: novdelvis novdelvis_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novdelvis_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novdelvis FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novespinf novespinf_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novespinf_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novespinf FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novespinf novespinf_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novespinf_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novespinf FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novext novext_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novext_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novext FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novext novext_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novext_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novext FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novobs novobs_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novobs_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novobs novobs_existe_observacion_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novobs_existe_observacion_trg BEFORE INSERT ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.novobs_validacion_trg();


--
-- Name: novobs novobs_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novobs_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novpre novpre_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novpre_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novpre novpre_blanquea_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novpre_blanquea_trg BEFORE UPDATE ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.blanquear_precios_trg();


--
-- Name: novpre novpre_cambio_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novpre_cambio_trg AFTER INSERT ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.revisar_cambio_trg();


--
-- Name: novpre novpre_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novpre_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: novprod novprod_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novprod_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novprod FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novprod novprod_act_promedio_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novprod_act_promedio_trg BEFORE INSERT OR UPDATE ON cvp.novprod FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_act_promedio();


--
-- Name: novprod novprod_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novprod_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novprod FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: pasoatraves pasoatraves_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER pasoatraves_trg BEFORE UPDATE ON cvp.pasoatraves FOR EACH ROW EXECUTE PROCEDURE cvp.pasoatraves_trg();


--
-- Name: periodos periodos_controlar_habilitado_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_controlar_habilitado_trg BEFORE UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_habilitado_trg();


--
-- Name: periodos periodos_controlar_ingresando_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_controlar_ingresando_trg BEFORE UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_ingresando_trg();


--
-- Name: periodos periodos_gen_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_gen_trg BEFORE INSERT OR UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_periodo();


--
-- Name: periodos periodos_prerep_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_prerep_trg BEFORE INSERT OR UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_calcularprerep();


--
-- Name: prerep prerep_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER prerep_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.prerep FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: prodatr prodatr_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER prodatr_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.prodatr FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: prodatr prodatr_valornormal_mod_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER prodatr_valornormal_mod_trg BEFORE UPDATE ON cvp.prodatr FOR EACH ROW EXECUTE PROCEDURE cvp.prodatr_validamod_valornormal_trg();


--
-- Name: proddiv proddiv_ins_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER proddiv_ins_trg BEFORE INSERT OR UPDATE ON cvp.proddiv FOR EACH ROW EXECUTE PROCEDURE cvp.proddiv_ins_trg();


--
-- Name: productos productos_imputacon_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER productos_imputacon_trg BEFORE INSERT OR UPDATE ON cvp.productos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_imputacon_trg();


--
-- Name: relatr relatr_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relatr relatr_act_datos_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_act_datos_trg BEFORE UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_actualizacion_datos_trg();


--
-- Name: relatr relatr_actualizar_valor_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_actualizar_valor_trg BEFORE UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.permitir_actualizar_valor_trg();


--
-- Name: relatr relatr_dm_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_dm_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_cargado_dm();


--
-- Name: relatr relatr_esmoneda_valor_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_esmoneda_valor_trg BEFORE INSERT OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.relatr_valor_valida_moneda_trg();


--
-- Name: relatr relatr_esnumerico_valor_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_esnumerico_valor_trg BEFORE INSERT OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.relatr_valor_valida_numerico_trg();


--
-- Name: relatr relatr_existe_visita_1_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_existe_visita_1_trg BEFORE INSERT ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_existencia_visita_1_trg();


--
-- Name: relatr relatr_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relatr relatr_normaliza_precio_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_normaliza_precio_trg AFTER UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.calcular_precionormaliz_relatr_trg();


--
-- Name: relenc relenc_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relenc_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relenc FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relenc relenc_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relenc_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relenc FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relinf relinf_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relinf_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relinf FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relinf relinf_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relinf_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relinf FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relmon relmon_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relmon_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relmon FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relmon relmon_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relmon_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relmon FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relmon relmon_moneda_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relmon_moneda_trg BEFORE UPDATE ON cvp.relmon FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_valor_pesos_trg();


--
-- Name: relmon relmon_normaliza_moneda_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relmon_normaliza_moneda_trg AFTER UPDATE ON cvp.relmon FOR EACH ROW EXECUTE PROCEDURE cvp.correr_normalizacion_moneda_trg();


--
-- Name: relpan relpan_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpan_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpan FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relpan relpan_gen_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpan_gen_trg BEFORE INSERT OR UPDATE ON cvp.relpan FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_panel();


--
-- Name: relpan relpan_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpan_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpan FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relpre relpre_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relpre relpre_act_datos_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_act_datos_trg BEFORE UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_actualizacion_datos_trg();


--
-- Name: relpre relpre_actualiza_ultima_visita_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_actualiza_ultima_visita_trg BEFORE UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_insercion_ultima_visita_trg();


--
-- Name: relpre relpre_desp_actualiza_ultima_visita_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_desp_actualiza_ultima_visita_trg AFTER UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.desp_actualizar_ultima_visita_trg();


--
-- Name: relpre relpre_dm_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_dm_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_cargado_dm();


--
-- Name: relpre relpre_existe_visita_1_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_existe_visita_1_trg BEFORE INSERT ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_existencia_visita_1_trg();


--
-- Name: relpre relpre_inserta_atributos_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_inserta_atributos_trg AFTER INSERT ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.insertar_atributos_trg();


--
-- Name: relpre relpre_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relpre relpre_restaura_atributos_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_restaura_atributos_trg BEFORE UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.restaurar_atributos_trg();


--
-- Name: relpre relpre_senormaliza_precio_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_senormaliza_precio_trg BEFORE UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.calcular_precionormaliz_relpre_trg();


--
-- Name: relpre relpre_valida_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_valida_trg BEFORE INSERT OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.relpre_validacion_trg();


--
-- Name: relsup relsup_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relsup_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relsup FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relsup relsup_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relsup_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relsup FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: reltar reltar_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER reltar_abi_trg BEFORE INSERT OR DELETE OR UPDATE OF supervisor, encuestador, realizada, resultado, observaciones, puntos, cargado, descargado, id_instalacion ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: reltar reltar_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER reltar_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: reltar reltar_verificar_sincronizacion; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER reltar_verificar_sincronizacion BEFORE UPDATE OF vencimiento_sincronizacion ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_sincronizacion();


--
-- Name: relvis relvis_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: relvis relvis_actualiza_encuestador_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_actualiza_encuestador_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.actualizar_tarea_encuestador_trg();


--
-- Name: relvis relvis_actualiza_estado_informante_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_actualiza_estado_informante_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.actualizar_estado_informante_trg();


--
-- Name: relvis relvis_actualiza_periodo_panelrotativo; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_actualiza_periodo_panelrotativo BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.actualizar_periodo_panelrotativo_trg();


--
-- Name: relvis relvis_cambio_panel_tarea_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_cambio_panel_tarea_trg BEFORE UPDATE OF panel, tarea ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.cambio_panel_tarea_trg();


--
-- Name: relvis relvis_cambios_razon_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_cambios_razon_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.cambios_razon_trg();


--
-- Name: relvis relvis_controlar_recepcion_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_controlar_recepcion_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.validar_recepcion_trg();


--
-- Name: relvis relvis_dm_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_dm_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_cargado_dm();


--
-- Name: relvis relvis_existe_visita_1_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_existe_visita_1_trg BEFORE INSERT ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_existencia_visita_1_trg();


--
-- Name: relvis relvis_fechas_visita_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_fechas_visita_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.validar_fechas_visita_trg();

ALTER TABLE cvp.relvis DISABLE TRIGGER relvis_fechas_visita_trg;


--
-- Name: relvis relvis_gen_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_gen_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_formulario();


--
-- Name: relvis relvis_genera_reemplazante; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_genera_reemplazante BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.generar_visitas_reemplazo_trg();


--
-- Name: relvis relvis_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: relvis relvis_personal_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_personal_trg BEFORE INSERT OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.validar_personal_trg();


--
-- Name: relvis relvis_razon_cierre_definitivo_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_razon_cierre_definitivo_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.razon_cierre_definitivo_trg();


--
-- Name: relvis relvis_razon_cierre_temporal_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_razon_cierre_temporal_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.razon_cierre_temporal_trg();


--
-- Name: relvis relvis_valida_tarea_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_valida_tarea_trg BEFORE INSERT OR UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.relvis_tarea_trg();


--
-- Name: variedades variedades_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER variedades_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.variedades FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: atributos atributos_unidaddemedida_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.atributos
    ADD CONSTRAINT atributos_unidaddemedida_fkey FOREIGN KEY (unidaddemedida) REFERENCES cvp.unidades(unidad);


--
-- Name: blaatr blaatr_atributo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_atributo_fkey FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo);


--
-- Name: blaatr blaatr_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: blaatr blaatr_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: blaatr blaatr_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_periodo_fkey1 FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita);


--
-- Name: blaatr blaatr_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr_producto_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT blaatr_producto_fkey1 FOREIGN KEY (producto, atributo, valor, validar_con_valvalatr) REFERENCES cvp.valvalatr(producto, atributo, valor, validar);


--
-- Name: blapre blapre_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: blapre blapre_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: blapre blapre_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_periodo_fkey1 FOREIGN KEY (periodo, informante, visita, formulario) REFERENCES cvp.relvis(periodo, informante, visita, formulario);


--
-- Name: blapre blapre_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: blapre blapre_tipoprecio_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT blapre_tipoprecio_fkey FOREIGN KEY (tipoprecio) REFERENCES cvp.tipopre(tipoprecio);


--
-- Name: cal_mensajes cal_mensajes_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cal_mensajes
    ADD CONSTRAINT cal_mensajes_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calbase_div calbase_div_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_div
    ADD CONSTRAINT calbase_div_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calbase_div calbase_div_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_div
    ADD CONSTRAINT calbase_div_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: calbase_obs calbase_obs_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_obs
    ADD CONSTRAINT calbase_obs_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calbase_obs calbase_obs_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_obs
    ADD CONSTRAINT calbase_obs_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: calbase_obs calbase_obs_periodo_aparicion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_obs
    ADD CONSTRAINT calbase_obs_periodo_aparicion_fkey FOREIGN KEY (periodo_aparicion) REFERENCES cvp.periodos(periodo);


--
-- Name: calbase_obs calbase_obs_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_obs
    ADD CONSTRAINT calbase_obs_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: calbase_prod calbase_prod_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_prod
    ADD CONSTRAINT calbase_prod_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calbase_prod calbase_prod_mes_inicio_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_prod
    ADD CONSTRAINT calbase_prod_mes_inicio_fkey FOREIGN KEY (mes_inicio) REFERENCES cvp.periodos(periodo);


--
-- Name: calbase_prod calbase_prod_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calbase_prod
    ADD CONSTRAINT calbase_prod_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: calculos calculos_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT calculos_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos_def calculos_def_basado_en_extraccion_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT calculos_def_basado_en_extraccion_calculo_fkey FOREIGN KEY (basado_en_extraccion_calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos_def calculos_def_basado_en_extraccion_muestra_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT calculos_def_basado_en_extraccion_muestra_fkey FOREIGN KEY (basado_en_extraccion_muestra) REFERENCES cvp.muestras(muestra);


--
-- Name: calculos calculos_pb_calculobase_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT calculos_pb_calculobase_fkey FOREIGN KEY (pb_calculobase) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos calculos_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT calculos_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calculos calculos_periodoanterior_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT calculos_periodoanterior_fkey FOREIGN KEY (periodoanterior, calculoanterior) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: caldiv caldiv_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caldiv_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calgru calgru_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT calgru_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calgru calgru_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT calgru_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calgru calgru_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT calgru_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calhoggru calhoggru_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT calhoggru_agrupacion_fkey FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: calhoggru calhoggru_hogar_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT calhoggru_hogar_fkey FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar);


--
-- Name: calhoggru calhoggru_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT calhoggru_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calhoggru calhoggru_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT calhoggru_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calhogsubtotales calhogsubtotales_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT calhogsubtotales_agrupacion_fkey FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: calhogsubtotales calhogsubtotales_hogar_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT calhogsubtotales_hogar_fkey FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar);


--
-- Name: calhogsubtotales calhogsubtotales_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT calhogsubtotales_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calhogsubtotales calhogsubtotales_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT calhogsubtotales_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calobs calobs_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calobs calobs_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: calobs calobs_muestra_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_muestra_fkey FOREIGN KEY (muestra) REFERENCES cvp.muestras(muestra);


--
-- Name: calobs calobs_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calobs calobs_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calobs calobs_productos_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT calobs_productos_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calprod calprod_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT calprod_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calprod calprod_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT calprod_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calprod calprod_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT calprod_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calprod calprod_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT calprod_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_agrupacion_fkey FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion);


--
-- Name: calprodagr calprodagr_calculo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_calculo_fkey FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo);


--
-- Name: calprodagr calprodagr_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calprodagr calprodagr_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo);


--
-- Name: calprodagr calprodagr_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT calprodagr_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: calprodresp calprodresp_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT calprodresp_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: calprodresp calprodresp_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT calprodresp_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo);


--
-- Name: calprodresp calprodresp_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT calprodresp_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: caldiv caltipoinf_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caltipoinf_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: caldiv caltipoinf_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caltipoinf_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: caldiv caltipoinf_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caltipoinf_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: cuagru cuagru_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuagru
    ADD CONSTRAINT cuagru_agrupacion_fkey FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: cuagru cuagru_cuadro_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuagru
    ADD CONSTRAINT cuagru_cuadro_fkey FOREIGN KEY (cuadro) REFERENCES cvp.cuadros(cuadro);


--
-- Name: dicprodatr dicprodatr_prodatr_fk; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.dicprodatr
    ADD CONSTRAINT dicprodatr_prodatr_fk FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo);


--
-- Name: especificaciones especificaciones_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.especificaciones
    ADD CONSTRAINT especificaciones_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: especificaciones especificaciones_unidaddemedida_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.especificaciones
    ADD CONSTRAINT especificaciones_unidaddemedida_fkey FOREIGN KEY (unidaddemedida) REFERENCES cvp.unidades(unidad);


--
-- Name: forinf forinf_altamanualperiodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT forinf_altamanualperiodo_fkey FOREIGN KEY (altamanualperiodo) REFERENCES cvp.periodos(periodo);


--
-- Name: forinf forinf_formulario_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT forinf_formulario_fkey FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario);


--
-- Name: forinf forinf_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT forinf_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: formularios formulario_tipoinf_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.formularios
    ADD CONSTRAINT formulario_tipoinf_fkey FOREIGN KEY (soloparatipo) REFERENCES cvp.tipoinf(tipoinformante);


--
-- Name: forprod forprod_formulario_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forprod
    ADD CONSTRAINT forprod_formulario_fkey FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario);


--
-- Name: forprod forprod_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forprod
    ADD CONSTRAINT forprod_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: grupos grupos_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT grupos_agrupacion_fkey FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion);


--
-- Name: grupos grupos_agrupacion_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT grupos_agrupacion_fkey1 FOREIGN KEY (agrupacion, grupopadre) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: grupos grupos_agrupacionorigen_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT grupos_agrupacionorigen_fkey FOREIGN KEY (agrupacionorigen) REFERENCES cvp.agrupaciones(agrupacion);


--
-- Name: grupos grupos_agrupacionorigen_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT grupos_agrupacionorigen_fkey1 FOREIGN KEY (agrupacionorigen, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: hogparagr hogpar_hogar_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT hogpar_hogar_fkey FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar);


--
-- Name: hogparagr hogpar_parametro_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT hogpar_parametro_fkey FOREIGN KEY (parametro) REFERENCES cvp.parhog(parametro);


--
-- Name: hogparagr hogparagr_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT hogparagr_agrupacion_fkey FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion);


--
-- Name: infoextprod infoextprod_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infoextprod
    ADD CONSTRAINT infoextprod_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: informantes informante_conjuntomuestral_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informante_conjuntomuestral_fkey FOREIGN KEY (conjuntomuestral) REFERENCES cvp.conjuntomuestral(conjuntomuestral);


--
-- Name: informantes informante_rubro_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informante_rubro_fkey FOREIGN KEY (rubro) REFERENCES cvp.rubros(rubro);


--
-- Name: informantes informantes_muestra_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informantes_muestra_fkey FOREIGN KEY (muestra) REFERENCES cvp.muestras(muestra);


--
-- Name: informantes informantes_tipoinformante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informantes_tipoinformante_fkey FOREIGN KEY (tipoinformante) REFERENCES cvp.tipoinf(tipoinformante);


--
-- Name: infreemp infreemp_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infreemp
    ADD CONSTRAINT infreemp_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: instalaciones instalaciones personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.instalaciones
    ADD CONSTRAINT "instalaciones personal REL" FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: locks locks tokens REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.locks
    ADD CONSTRAINT "locks tokens REL" FOREIGN KEY (token) REFERENCES cvp.tokens(token) ON UPDATE CASCADE;


--
-- Name: modulosusuarios modulosusuarios_formulario_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.modulosusuarios
    ADD CONSTRAINT modulosusuarios_formulario_fkey FOREIGN KEY (formulario, zona, nombre) REFERENCES cvp.modulos(formulario, zona, nombre);


--
-- Name: modulosusuarios modulosusuarios_username_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.modulosusuarios
    ADD CONSTRAINT modulosusuarios_username_fkey FOREIGN KEY (username) REFERENCES cvp.personal(username);


--
-- Name: muestras muestras_alta_inmediata_hasta_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.muestras
    ADD CONSTRAINT muestras_alta_inmediata_hasta_periodo_fkey FOREIGN KEY (alta_inmediata_hasta_periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novespinf novespinf_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novespinf
    ADD CONSTRAINT novespinf_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: novespinf novespinf_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novespinf
    ADD CONSTRAINT novespinf_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novespinf novespinf_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novespinf
    ADD CONSTRAINT novespinf_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo);


--
-- Name: novespinf novespinf_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novespinf
    ADD CONSTRAINT novespinf_producto_fkey FOREIGN KEY (producto, especificacion) REFERENCES cvp.especificaciones(producto, especificacion) ON UPDATE CASCADE;


--
-- Name: novext novext_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novext
    ADD CONSTRAINT novext_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novext novext_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novext
    ADD CONSTRAINT novext_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo);


--
-- Name: novobs_base novobs_base_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs_base
    ADD CONSTRAINT novobs_base_periodo_fkey FOREIGN KEY (hasta_periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novobs_base novobs_base_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs_base
    ADD CONSTRAINT novobs_base_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: novobs novobs_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT novobs_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: novobs novobs_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT novobs_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novobs novobs_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT novobs_periodo_fkey1 FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: novobs novobs_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT novobs_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: novpre novpre_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novpre
    ADD CONSTRAINT novpre_periodo_fkey FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita);


--
-- Name: novprod novprod_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novprod
    ADD CONSTRAINT novprod_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: novprod novprod_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novprod
    ADD CONSTRAINT novprod_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: parhoggru parhoggru_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhoggru
    ADD CONSTRAINT parhoggru_agrupacion_fkey FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: parhoggru parhoggru_parametro_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhoggru
    ADD CONSTRAINT parhoggru_parametro_fkey FOREIGN KEY (parametro) REFERENCES cvp.parhog(parametro);


--
-- Name: pb_calculos_reglas pb_calculos_reglas_desde_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_calculos_reglas
    ADD CONSTRAINT pb_calculos_reglas_desde_fkey FOREIGN KEY (desde) REFERENCES cvp.periodos(periodo);


--
-- Name: pb_calculos_reglas pb_calculos_reglas_hasta_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_calculos_reglas
    ADD CONSTRAINT pb_calculos_reglas_hasta_fkey FOREIGN KEY (hasta) REFERENCES cvp.periodos(periodo);


--
-- Name: pb_externos pb_externos_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_externos
    ADD CONSTRAINT pb_externos_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: pb_externos pb_externos_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pb_externos
    ADD CONSTRAINT pb_externos_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: periodos periodo_ant; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.periodos
    ADD CONSTRAINT periodo_ant FOREIGN KEY (periodoanterior) REFERENCES cvp.periodos(periodo);


--
-- Name: personal personal_id_instalacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT personal_id_instalacion_fkey FOREIGN KEY (id_instalacion) REFERENCES cvp.instalaciones(id_instalacion);


--
-- Name: prerep prerep_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prerep
    ADD CONSTRAINT prerep_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: prodagr prodagr_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodagr
    ADD CONSTRAINT prodagr_agrupacion_fkey FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion);


--
-- Name: prodagr prodagr_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodagr
    ADD CONSTRAINT prodagr_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: prodatr prodatr_atributo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT prodatr_atributo_fkey FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo);


--
-- Name: prodatr prodatr_otraunidaddemedida_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT prodatr_otraunidaddemedida_fkey FOREIGN KEY (otraunidaddemedida) REFERENCES cvp.unidades(unidad);


--
-- Name: prodatr prodatr_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT prodatr_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: prodatrval prodatrval_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatrval
    ADD CONSTRAINT prodatrval_producto_fkey FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo);


--
-- Name: proddiv proddiv_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT proddiv_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: proddivestimac proddivestimac_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddivestimac
    ADD CONSTRAINT proddivestimac_producto_fkey FOREIGN KEY (producto, division) REFERENCES cvp.proddiv(producto, division);


--
-- Name: productos productos_unidadmedidaporunidcons_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.productos
    ADD CONSTRAINT productos_unidadmedidaporunidcons_fkey FOREIGN KEY (unidadmedidaporunidcons) REFERENCES cvp.unidades(unidad);


--
-- Name: proddiv redundancia para garantizar la exclusion de divisiones no compa; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "redundancia para garantizar la exclusion de divisiones no compa" FOREIGN KEY (division, incluye_supermercados, incluye_tradicionales) REFERENCES cvp.divisiones(division, incluye_supermercados, incluye_tradicionales);


--
-- Name: relatr relatr_atributo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_atributo_fkey FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo);


--
-- Name: relatr relatr_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: relatr relatr_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relatr relatr_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_periodo_fkey1 FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita);


--
-- Name: relatr relatr_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: relatr relatr_valvalatr_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT relatr_valvalatr_fkey FOREIGN KEY (producto, atributo, valor, validar_con_valvalatr) REFERENCES cvp.valvalatr(producto, atributo, valor, validar);


--
-- Name: relenc relenc_encuestador_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT relenc_encuestador_fkey FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona);


--
-- Name: relenc relenc_panel_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT relenc_panel_fkey FOREIGN KEY (panel, tarea) REFERENCES cvp.pantar(panel, tarea);


--
-- Name: relenc relenc_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT relenc_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relinf relinf_inf_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relinf
    ADD CONSTRAINT relinf_inf_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: relinf relinf_per_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relinf
    ADD CONSTRAINT relinf_per_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relmon relmon_monedas_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT relmon_monedas_fkey FOREIGN KEY (moneda) REFERENCES cvp.monedas(moneda);


--
-- Name: relmon relmon_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT relmon_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relpan relpan_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpan
    ADD CONSTRAINT relpan_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relpre relpre_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: relpre relpre_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relpre relpre_periodo_fkey1; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_periodo_fkey1 FOREIGN KEY (periodo, informante, visita, formulario) REFERENCES cvp.relvis(periodo, informante, visita, formulario);


--
-- Name: relpre relpre_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: relpre relpre_tipopre_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_tipopre_fkey FOREIGN KEY (tipoprecio) REFERENCES cvp.tipopre(tipoprecio);


--
-- Name: relpresemaforo relpresemaforo_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpresemaforo
    ADD CONSTRAINT relpresemaforo_producto_fkey FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: relpresemaforo relpresemaforo_relpre_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpresemaforo
    ADD CONSTRAINT relpresemaforo_relpre_fkey FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita);


--
-- Name: relsup relsup_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT relsup_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relsup relsup_personal_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT relsup_personal_fkey FOREIGN KEY (supervisor) REFERENCES cvp.personal(persona);


--
-- Name: relsup relsup_relpan_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT relsup_relpan_fkey FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel);


--
-- Name: reltar reltar_enc_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_enc_fkey FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona);


--
-- Name: reltar reltar_id_instalacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_id_instalacion_fkey FOREIGN KEY (id_instalacion) REFERENCES cvp.instalaciones(id_instalacion);


--
-- Name: reltar reltar_relpan_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_relpan_fkey FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel);


--
-- Name: reltar reltar_sup_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_sup_fkey FOREIGN KEY (supervisor) REFERENCES cvp.personal(persona);


--
-- Name: reltar reltar_tarea_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT reltar_tarea_fkey FOREIGN KEY (tarea) REFERENCES cvp.tareas(tarea);


--
-- Name: relvis relvis_formulario_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_formulario_fkey FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario);


--
-- Name: relvis relvis_informante_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_informante_fkey FOREIGN KEY (informante) REFERENCES cvp.informantes(informante);


--
-- Name: relvis relvis_periodo_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_periodo_fkey FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo);


--
-- Name: relvis relvis_personalenc_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_personalenc_fkey FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona);


--
-- Name: relvis relvis_personaling_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_personaling_fkey FOREIGN KEY (ingresador) REFERENCES cvp.personal(persona);


--
-- Name: relvis relvis_personalrec_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_personalrec_fkey FOREIGN KEY (recepcionista) REFERENCES cvp.personal(persona);


--
-- Name: relvis relvis_personalsup_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_personalsup_fkey FOREIGN KEY (supervisor) REFERENCES cvp.personal(persona);


--
-- Name: relvis relvis_razones_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_razones_fkey FOREIGN KEY (razon) REFERENCES cvp.razones(razon);


--
-- Name: relvis relvis_relpan_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT relvis_relpan_fkey FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel);


--
-- Name: rubfor rubfor_formulario_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT rubfor_formulario_fkey FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario);


--
-- Name: rubfor rubfor_rubro_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT rubfor_rubro_fkey FOREIGN KEY (rubro) REFERENCES cvp.rubros(rubro);


--
-- Name: rubros rubros_tipoinf_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubros
    ADD CONSTRAINT rubros_tipoinf_fkey FOREIGN KEY (tipoinformante) REFERENCES cvp.tipoinf(tipoinformante);


--
-- Name: selprod selprod_productos_fk; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.selprod
    ADD CONSTRAINT selprod_productos_fk FOREIGN KEY (producto) REFERENCES cvp.productos(producto);


--
-- Name: selprodatr selprodatr_prodatr_fk; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.selprodatr
    ADD CONSTRAINT selprodatr_prodatr_fk FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo);


--
-- Name: selprodatr selprodatr_selprod_fk; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.selprodatr
    ADD CONSTRAINT selprodatr_selprod_fk FOREIGN KEY (producto, sel_nro) REFERENCES cvp.selprod(producto, sel_nro);


--
-- Name: tareas tareas_encuestador_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tareas
    ADD CONSTRAINT tareas_encuestador_fkey FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona);


--
-- Name: transf_info transf_info_agrupacion_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: postgres
--

ALTER TABLE ONLY cvp.transf_info
    ADD CONSTRAINT transf_info_agrupacion_fkey FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo);


--
-- Name: unidades unidades_magnitud_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.unidades
    ADD CONSTRAINT unidades_magnitud_fkey FOREIGN KEY (magnitud) REFERENCES cvp.magnitudes(magnitud);


--
-- Name: valvalatr valvalatr_prodatr_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT valvalatr_prodatr_fkey FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo);


--
-- Name: variedades variedades_producto_fkey; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.variedades
    ADD CONSTRAINT variedades_producto_fkey FOREIGN KEY (producto, especificacion) REFERENCES cvp.especificaciones(producto, especificacion) ON UPDATE CASCADE;


--
-- Name: TABLE agrupaciones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.agrupaciones TO cvp_administrador;


--
-- Name: TABLE atributos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.atributos TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.atributos TO cvp_administrador;
GRANT SELECT ON TABLE cvp.atributos TO cvp_recepcionista;


--
-- Name: TABLE periodos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.periodos TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.periodos TO cvp_administrador;
GRANT SELECT ON TABLE cvp.periodos TO cvp_recepcionista;


--
-- Name: TABLE bienvenida; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.bienvenida TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.bienvenida TO cvp_recepcionista;


--
-- Name: TABLE bitacora; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.bitacora TO cvp_administrador;


--
-- Name: TABLE blaatr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.blaatr TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.blaatr TO cvp_recepcionista;
GRANT DELETE ON TABLE cvp.blaatr TO cvp_administrador;


--
-- Name: TABLE blapre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.blapre TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.blapre TO cvp_recepcionista;
GRANT DELETE ON TABLE cvp.blapre TO cvp_administrador;


--
-- Name: TABLE cal_mensajes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.cal_mensajes TO cvp_administrador;


--
-- Name: TABLE calbase_div; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calbase_div TO cvp_administrador;


--
-- Name: TABLE calbase_obs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calbase_obs TO cvp_administrador;


--
-- Name: TABLE calbase_prod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calbase_prod TO cvp_administrador;


--
-- Name: TABLE calculos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.calculos TO cvp_administrador;
GRANT SELECT ON TABLE cvp.calculos TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.calculos TO cvp_recepcionista;


--
-- Name: TABLE calculos_def; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT ALL ON TABLE cvp.calculos_def TO cvp_administrador;
GRANT SELECT ON TABLE cvp.calculos_def TO cvp_recepcionista;


--
-- Name: TABLE caldiv; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.caldiv TO cvp_administrador;


--
-- Name: TABLE calprodresp; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.calprodresp TO cvp_administrador;
GRANT SELECT ON TABLE cvp.calprodresp TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.calprodresp TO cvp_recepcionista;


--
-- Name: TABLE grupos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.grupos TO cvp_administrador;


--
-- Name: TABLE gru_grupos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.gru_grupos TO cvp_administrador;


--
-- Name: TABLE productos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.productos TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.productos TO cvp_recepcionista;


--
-- Name: TABLE caldiv_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.caldiv_vw TO cvp_administrador;


--
-- Name: TABLE calobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calobs TO cvp_administrador;
GRANT SELECT ON TABLE cvp.calobs TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.calobs TO cvp_recepcionista;


--
-- Name: TABLE relpre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relpre TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.relpre TO cvp_recepcionista;
GRANT ALL ON TABLE cvp.relpre TO cvp_administrador;
GRANT ALL ON TABLE cvp.relpre TO cvp_coordinacion;


--
-- Name: TABLE caldivsincambio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.caldivsincambio TO cvp_administrador;


--
-- Name: TABLE calgru; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calgru TO cvp_administrador;


--
-- Name: TABLE calgru_promedios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calgru_promedios TO cvp_administrador;


--
-- Name: TABLE calgru_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calgru_vw TO cvp_administrador;


--
-- Name: TABLE calhoggru; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calhoggru TO cvp_administrador;


--
-- Name: TABLE calhogsubtotales; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calhogsubtotales TO cvp_administrador;


--
-- Name: TABLE calobs_periodos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calobs_periodos TO cvp_administrador;


--
-- Name: TABLE calobs_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calobs_vw TO cvp_administrador;


--
-- Name: TABLE calprod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calprod TO cvp_administrador;


--
-- Name: TABLE calprodagr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calprodagr TO cvp_administrador;
GRANT SELECT ON TABLE cvp.calprodagr TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.calprodagr TO cvp_recepcionista;


--
-- Name: TABLE matrizperiodos6; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.matrizperiodos6 TO cvp_administrador;


--
-- Name: TABLE canasta_alimentaria; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_alimentaria TO cvp_administrador;


--
-- Name: TABLE canasta_alimentaria_var; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_alimentaria_var TO cvp_administrador;


--
-- Name: TABLE canasta_consumo; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_consumo TO cvp_administrador;


--
-- Name: TABLE canasta_consumo_var; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_consumo_var TO cvp_administrador;


--
-- Name: TABLE hogparagr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.hogparagr TO cvp_administrador;


--
-- Name: TABLE parhog; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.parhog TO cvp_administrador;


--
-- Name: TABLE parhoggru; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.parhoggru TO cvp_administrador;


--
-- Name: TABLE prodagr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.prodagr TO cvp_administrador;


--
-- Name: TABLE canasta_producto; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_producto TO cvp_administrador;


--
-- Name: TABLE conjuntomuestral; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.conjuntomuestral TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.conjuntomuestral TO cvp_administrador;
GRANT SELECT,INSERT,UPDATE ON TABLE cvp.conjuntomuestral TO cvp_recepcionista;


--
-- Name: SEQUENCE conjuntomuestral_conjuntomuestral_seq; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,USAGE ON SEQUENCE cvp.conjuntomuestral_conjuntomuestral_seq TO cvp_administrador;


--
-- Name: TABLE informantes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.informantes TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.informantes TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.informantes TO cvp_recepcionista;


--
-- Name: TABLE relvis; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relvis TO cvp_usuarios;
GRANT SELECT,UPDATE ON TABLE cvp.relvis TO cvp_recepcionista;
GRANT ALL ON TABLE cvp.relvis TO cvp_administrador;
GRANT ALL ON TABLE cvp.relvis TO cvp_coordinacion;


--
-- Name: TABLE control_ajustes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_ajustes TO cvp_administrador;


--
-- Name: TABLE personal; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.personal TO cvp_usuarios;
GRANT SELECT,UPDATE ON TABLE cvp.personal TO cvp_recepcionista;
GRANT SELECT,UPDATE ON TABLE cvp.personal TO cvp_administrador;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.personal TO cvp_personal;


--
-- Name: TABLE control_anulados_recep; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_anulados_recep TO cvp_administrador;
GRANT SELECT ON TABLE cvp.control_anulados_recep TO cvp_recepcionista;


--
-- Name: TABLE prodatr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.prodatr TO cvp_usuarios;
GRANT UPDATE ON TABLE cvp.prodatr TO cvp_administrador;
GRANT SELECT ON TABLE cvp.prodatr TO cvp_recepcionista;


--
-- Name: TABLE relatr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relatr TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.relatr TO cvp_recepcionista;
GRANT ALL ON TABLE cvp.relatr TO cvp_administrador;
GRANT ALL ON TABLE cvp.relatr TO cvp_coordinacion;


--
-- Name: TABLE tipopre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT ALL ON TABLE cvp.tipopre TO postgres;
GRANT SELECT ON TABLE cvp.tipopre TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.tipopre TO cvp_administrador;
GRANT SELECT ON TABLE cvp.tipopre TO cvp_recepcionista;


--
-- Name: TABLE control_atributos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_atributos TO cvp_usuarios;


--
-- Name: TABLE proddiv; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.proddiv TO cvp_administrador;


--
-- Name: TABLE control_calculoresultados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.control_calculoresultados TO cvp_administrador;


--
-- Name: TABLE control_calobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_calobs TO cvp_administrador;


--
-- Name: TABLE formularios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.formularios TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.formularios TO cvp_recepcionista;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.formularios TO cvp_administrador;


--
-- Name: TABLE forprod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.forprod TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.forprod TO cvp_recepcionista;


--
-- Name: TABLE razones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.razones TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.razones TO cvp_administrador;
GRANT SELECT ON TABLE cvp.razones TO cvp_recepcionista;


--
-- Name: TABLE control_generacion_formularios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_generacion_formularios TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_generacion_formularios TO cvp_recepcionista;


--
-- Name: TABLE control_grupos_para_cierre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_grupos_para_cierre TO cvp_administrador;


--
-- Name: TABLE control_hojas_ruta; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_hojas_ruta TO cvp_usuarios;


--
-- Name: TABLE control_ingresados_calculo; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_ingresados_calculo TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_ingresados_calculo TO cvp_recepcionista;


--
-- Name: TABLE control_ingreso_atributos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_ingreso_atributos TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_ingreso_atributos TO cvp_recepcionista;


--
-- Name: TABLE control_ingreso_precios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_ingreso_precios TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_ingreso_precios TO cvp_recepcionista;


--
-- Name: TABLE control_normalizables_sindato; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_normalizables_sindato TO cvp_usuarios;


--
-- Name: TABLE control_precios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.control_precios TO cvp_administrador;


--
-- Name: TABLE control_productos_para_cierre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_productos_para_cierre TO cvp_administrador;


--
-- Name: TABLE relpan; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relpan TO cvp_usuarios;
GRANT SELECT,UPDATE ON TABLE cvp.relpan TO cvp_recepcionista;


--
-- Name: TABLE panel_promrotativo; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.panel_promrotativo TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.panel_promrotativo TO cvp_recepcionista;


--
-- Name: TABLE parametros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.parametros TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.parametros TO cvp_administrador;
GRANT SELECT ON TABLE cvp.parametros TO cvp_recepcionista;


--
-- Name: TABLE prerep; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.prerep TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.prerep TO cvp_recepcionista;


--
-- Name: TABLE relpre_1; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.relpre_1 TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.relpre_1 TO cvp_administrador;


--
-- Name: TABLE control_rangos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_rangos TO cvp_usuarios;


--
-- Name: TABLE panel_promrotativo_mod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.panel_promrotativo_mod TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.panel_promrotativo_mod TO cvp_recepcionista;


--
-- Name: TABLE control_rangos_mod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_rangos_mod TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_rangos_mod TO cvp_recepcionista;


--
-- Name: TABLE rubros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.rubros TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.rubros TO cvp_administrador;
GRANT SELECT ON TABLE cvp.rubros TO cvp_recepcionista;


--
-- Name: TABLE control_relev_telef; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_relev_telef TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.control_relev_telef TO cvp_recepcionista;


--
-- Name: TABLE control_sinprecio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_sinprecio TO cvp_recepcionista;
GRANT ALL ON TABLE cvp.control_sinprecio TO cvp_coordinacion;
GRANT ALL ON TABLE cvp.control_sinprecio TO cvp_analistas;


--
-- Name: TABLE control_sinvariacion; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_sinvariacion TO cvp_administrador;


--
-- Name: TABLE perfiltro; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.perfiltro TO cvp_administrador;
GRANT SELECT ON TABLE cvp.perfiltro TO cvp_recepcionista;


--
-- Name: TABLE control_tipoprecio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_tipoprecio TO cvp_administrador;


--
-- Name: TABLE controlvigencias; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.controlvigencias TO cvp_administrador;
GRANT SELECT ON TABLE cvp.controlvigencias TO cvp_usuarios;


--
-- Name: TABLE cuadros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.cuadros TO cvp_administrador;


--
-- Name: TABLE cuadros_funciones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.cuadros_funciones TO cvp_administrador;


--
-- Name: TABLE cuagru; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT ON TABLE cvp.cuagru TO cvp_administrador;


--
-- Name: TABLE desvios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.desvios TO cvp_administrador;


--
-- Name: TABLE dicprodatr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT ALL ON TABLE cvp.dicprodatr TO cvp_administrador;
GRANT ALL ON TABLE cvp.dicprodatr TO cvp_coordinacion;


--
-- Name: TABLE divisiones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.divisiones TO cvp_administrador;


--
-- Name: TABLE especificaciones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.especificaciones TO cvp_administrador;
GRANT SELECT ON TABLE cvp.especificaciones TO cvp_recepcionista;


--
-- Name: TABLE estadoinformantes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.estadoinformantes TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.estadoinformantes TO cvp_recepcionista;


--
-- Name: TABLE forobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.forobs TO cvp_usuarios;


--
-- Name: TABLE foresp; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.foresp TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.foresp TO cvp_recepcionista;


--
-- Name: TABLE forinf; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT ON TABLE cvp.forinf TO cvp_administrador;
GRANT SELECT,INSERT,UPDATE ON TABLE cvp.forinf TO cvp_recepcionista;


--
-- Name: TABLE formulariosimportados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.formulariosimportados TO cvp_administrador;


--
-- Name: TABLE forobsinf; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.forobsinf TO cvp_usuarios;


--
-- Name: TABLE freccambio_nivel0; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.freccambio_nivel0 TO cvp_administrador;


--
-- Name: TABLE freccambio_nivel1; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.freccambio_nivel1 TO cvp_administrador;


--
-- Name: TABLE freccambio_nivel3; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.freccambio_nivel3 TO cvp_administrador;


--
-- Name: TABLE freccambio_resto; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.freccambio_resto TO cvp_administrador;


--
-- Name: TABLE freccambio_restorest; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.freccambio_restorest TO cvp_administrador;


--
-- Name: TABLE hdrexportar; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hdrexportar TO cvp_usuarios;


--
-- Name: TABLE hdrexportarcierretemporal; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hdrexportarcierretemporal TO cvp_usuarios;


--
-- Name: TABLE hdrexportarefectivossinprecio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hdrexportarefectivossinprecio TO cvp_usuarios;


--
-- Name: TABLE tareas; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.tareas TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.tareas TO cvp_administrador;
GRANT SELECT ON TABLE cvp.tareas TO cvp_recepcionista;


--
-- Name: TABLE hdrexportarteorica; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hdrexportarteorica TO cvp_usuarios;


--
-- Name: TABLE hogares; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hogares TO cvp_administrador;


--
-- Name: TABLE hojaderuta; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hojaderuta TO cvp_usuarios;


--
-- Name: TABLE reltar; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.reltar TO cvp_administrador;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.reltar TO cvp_recepcionista;
GRANT SELECT ON TABLE cvp.reltar TO cvp_usuarios;


--
-- Name: TABLE hojaderutasupervisor; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hojaderutasupervisor TO cvp_usuarios;


--
-- Name: TABLE infoextprod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.infoextprod TO cvp_administrador;


--
-- Name: TABLE infoextvalor; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.infoextvalor TO cvp_administrador;


--
-- Name: TABLE informantesaltasbajas; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.informantesaltasbajas TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.informantesaltasbajas TO cvp_recepcionista;


--
-- Name: TABLE informantesformulario; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.informantesformulario TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.informantesformulario TO cvp_recepcionista;


--
-- Name: TABLE informantesrazon; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.informantesrazon TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.informantesrazon TO cvp_recepcionista;


--
-- Name: TABLE informantesrubro; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.informantesrubro TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.informantesrubro TO cvp_recepcionista;


--
-- Name: SEQUENCE secuencia_informantes_reemplazantes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,USAGE ON SEQUENCE cvp.secuencia_informantes_reemplazantes TO cvp_administrador;
GRANT SELECT,USAGE ON SEQUENCE cvp.secuencia_informantes_reemplazantes TO cvp_recepcionista;


--
-- Name: TABLE infreemp; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.infreemp TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.infreemp TO cvp_administrador;
GRANT SELECT,INSERT,UPDATE ON TABLE cvp.infreemp TO cvp_recepcionista;


--
-- Name: SEQUENCE secuencia_instalaciones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,USAGE ON SEQUENCE cvp.secuencia_instalaciones TO cvp_administrador;
GRANT SELECT,USAGE ON SEQUENCE cvp.secuencia_instalaciones TO cvp_recepcionista;


--
-- Name: TABLE instalaciones; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.instalaciones TO cvp_administrador;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.instalaciones TO cvp_recepcionista;


--
-- Name: TABLE locks; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.locks TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.locks TO cvp_recepcionista;


--
-- Name: TABLE magnitudes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.magnitudes TO cvp_administrador;


--
-- Name: TABLE matrizresultados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.matrizresultados TO cvp_administrador;


--
-- Name: TABLE matrizresultadossinvariacion; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.matrizresultadossinvariacion TO cvp_administrador;


--
-- Name: TABLE modulos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,UPDATE ON TABLE cvp.modulos TO cvp_usuarios;
GRANT SELECT,INSERT,UPDATE ON TABLE cvp.modulos TO cvp_recepcionista;


--
-- Name: TABLE modulosusuarios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.modulosusuarios TO cvp_administrador;
GRANT SELECT ON TABLE cvp.modulosusuarios TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.modulosusuarios TO cvp_recepcionista;


--
-- Name: TABLE monedas; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.monedas TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.monedas TO cvp_administrador;
GRANT SELECT ON TABLE cvp.monedas TO cvp_recepcionista;


--
-- Name: TABLE muestras; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT ALL ON TABLE cvp.muestras TO cvp_administrador;
GRANT SELECT ON TABLE cvp.muestras TO cvp_recepcionista;


--
-- Name: TABLE novdelobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novdelobs TO cvp_administrador;


--
-- Name: TABLE novdelvis; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novdelvis TO cvp_administrador;


--
-- Name: TABLE novespinf; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novespinf TO cvp_administrador;


--
-- Name: TABLE novext; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novext TO cvp_administrador;


--
-- Name: TABLE novobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novobs TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.novobs TO cvp_recepcionista;


--
-- Name: TABLE novpre; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novpre TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.novpre TO cvp_recepcionista;


--
-- Name: TABLE novprod; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.novprod TO cvp_administrador;


--
-- Name: TABLE numeros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.numeros TO cvp_administrador;


--
-- Name: TABLE pantar; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.pantar TO cvp_administrador;
GRANT SELECT ON TABLE cvp.pantar TO cvp_usuarios;


--
-- Name: TABLE parahojasderuta; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.parahojasderuta TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.parahojasderuta TO cvp_recepcionista;


--
-- Name: TABLE paraimpresionformulariosatributos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.paraimpresionformulariosatributos TO cvp_usuarios;


--
-- Name: TABLE paraimpresionformulariosenblanco; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.paraimpresionformulariosenblanco TO cvp_usuarios;


--
-- Name: TABLE paraimpresionformulariosprecios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.paraimpresionformulariosprecios TO cvp_usuarios;


--
-- Name: TABLE paralistadodecontroldecm; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.paralistadodecontroldecm TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.paralistadodecontroldecm TO cvp_recepcionista;


--
-- Name: TABLE paralistadodecontroldeinformantes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.paralistadodecontroldeinformantes TO cvp_usuarios;


--
-- Name: TABLE pasoatraves; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.pasoatraves TO cvp_usuarios;
GRANT SELECT,UPDATE ON TABLE cvp.pasoatraves TO cvp_recepcionista;


--
-- Name: TABLE pb_calculos_reglas; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.pb_calculos_reglas TO cvp_administrador;


--
-- Name: TABLE pb_externos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.pb_externos TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.pb_externos TO cvp_administrador;
GRANT SELECT ON TABLE cvp.pb_externos TO cvp_recepcionista;


--
-- Name: TABLE personalmigtemp; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.personalmigtemp TO cvp_desarrollador;
GRANT SELECT ON TABLE cvp.personalmigtemp TO cvp_administrador;


--
-- Name: TABLE precios_maximos_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.precios_maximos_vw TO cvp_administrador;
GRANT SELECT ON TABLE cvp.precios_maximos_vw TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.precios_maximos_vw TO cvp_recepcionista;


--
-- Name: TABLE precios_minimos_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.precios_minimos_vw TO cvp_administrador;
GRANT SELECT ON TABLE cvp.precios_minimos_vw TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.precios_minimos_vw TO cvp_recepcionista;


--
-- Name: TABLE precios_porcentaje_positivos_y_anulados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.precios_porcentaje_positivos_y_anulados TO cvp_administrador;


--
-- Name: TABLE preciosmedios_albs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.preciosmedios_albs TO cvp_administrador;


--
-- Name: TABLE preciosmedios_albs_var; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.preciosmedios_albs_var TO cvp_administrador;


--
-- Name: TABLE prod_for_rub; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.prod_for_rub TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.prod_for_rub TO cvp_recepcionista;


--
-- Name: TABLE prodatrval; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.prodatrval TO cvp_administrador;
GRANT SELECT ON TABLE cvp.prodatrval TO cvp_recepcionista;


--
-- Name: TABLE proddivestimac; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.proddivestimac TO cvp_administrador;


--
-- Name: TABLE promedios_maximos_minimos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.promedios_maximos_minimos TO cvp_usuarios;


--
-- Name: TABLE reemplazosexportar; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.reemplazosexportar TO cvp_usuarios;


--
-- Name: TABLE relatr_1; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.relatr_1 TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.relatr_1 TO cvp_administrador;
GRANT SELECT ON TABLE cvp.relatr_1 TO cvp_recepcionista;


--
-- Name: TABLE relenc; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relenc TO cvp_administrador;


--
-- Name: TABLE relinf; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.relinf TO cvp_administrador;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.relinf TO cvp_recepcionista;


--
-- Name: TABLE relmon; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,UPDATE ON TABLE cvp.relmon TO cvp_administrador;
GRANT SELECT ON TABLE cvp.relmon TO cvp_recepcionista;


--
-- Name: TABLE relpresemaforo; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relpresemaforo TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.relpresemaforo TO cvp_recepcionista;


--
-- Name: TABLE relsup; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,UPDATE ON TABLE cvp.relsup TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.relsup TO cvp_recepcionista;


--
-- Name: TABLE revisor_parametros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.revisor_parametros TO cvp_administrador;


--
-- Name: TABLE revisor; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.revisor TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.revisor TO cvp_recepcionista;


--
-- Name: TABLE rubfor; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.rubfor TO cvp_administrador;


--
-- Name: TABLE tipoinf; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.tipoinf TO cvp_administrador;
GRANT SELECT ON TABLE cvp.tipoinf TO cvp_recepcionista;


--
-- Name: TABLE tokens; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.tokens TO cvp_administrador;
GRANT SELECT,UPDATE ON TABLE cvp.tokens TO cvp_recepcionista;


--
-- Name: TABLE transf_data; Type: ACL; Schema: cvp; Owner: postgres
--

GRANT SELECT ON TABLE cvp.transf_data TO sieh;


--
-- Name: TABLE transf_data_orig; Type: ACL; Schema: cvp; Owner: postgres
--

GRANT SELECT ON TABLE cvp.transf_data_orig TO sieh;


--
-- Name: TABLE unidades; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.unidades TO cvp_administrador;
GRANT SELECT ON TABLE cvp.unidades TO cvp_usuarios;


--
-- Name: TABLE valorizacion_canasta; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.valorizacion_canasta TO cvp_administrador;


--
-- Name: TABLE valorizacion_canasta_cuadros; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.valorizacion_canasta_cuadros TO cvp_administrador;


--
-- Name: TABLE valvalatr; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.valvalatr TO cvp_usuarios;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.valvalatr TO cvp_administrador;
GRANT SELECT ON TABLE cvp.valvalatr TO cvp_recepcionista;


--
-- Name: TABLE variaciones_maximas_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.variaciones_maximas_vw TO cvp_administrador;


--
-- Name: TABLE variaciones_minimas_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.variaciones_minimas_vw TO cvp_administrador;


--
-- Name: TABLE variedades; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.variedades TO cvp_administrador;


--
-- PostgreSQL database dump complete
--

