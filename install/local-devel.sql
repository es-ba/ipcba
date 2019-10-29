--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
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
    ingresando text DEFAULT 'S'::text,
    periodoanterior text,
    fechageneracionperiodo timestamp without time zone,
    comentariosper text,
    fechacalculoprereplote1 timestamp without time zone,
    fechacalculoprereplote2 timestamp without time zone,
    fecha_cierre_ingreso timestamp without time zone,
    cerraringresocampohastapanel integer DEFAULT 0 NOT NULL,
    habilitado text DEFAULT 'S'::text,
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
    'V181227'::text AS dato,
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
    min(periodos.periodo) AS dato,
    'es el periodo abierto más antiguo'::text AS explicacion,
    'N3'::text AS nivel
   FROM cvp.periodos
  WHERE (periodos.ingresando = 'S'::text)
UNION
 SELECT 23 AS orden,
    'max_periodo'::text AS codigo,
    max(periodos.periodo) AS dato,
    'es el último periodo abierto '::text AS explicacion,
    'N1'::text AS nivel
   FROM cvp.periodos
  WHERE (periodos.ingresando = 'S'::text)
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
-- Name: secuencia_bitacora; Type: SEQUENCE; Schema: cvp; Owner: cvpowner
--

CREATE SEQUENCE cvp.secuencia_bitacora
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cvp.secuencia_bitacora OWNER TO cvpowner;

--
-- Name: bitacora; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.bitacora (
    id integer DEFAULT nextval('cvp.secuencia_bitacora'::regclass) NOT NULL,
    procedure_name text NOT NULL,
    parameters_definition text NOT NULL,
    parameters text NOT NULL,
    username text NOT NULL,
    machine_id text NOT NULL,
    navigator text NOT NULL,
    init_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone,
    has_error boolean,
    end_status text,
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
    visita integer NOT NULL,
    validar_con_valvalatr boolean,
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
    precio numeric,
    tipoprecio text,
    visita integer NOT NULL,
    comentariosrelpre text,
    cambio text,
    precionormalizado numeric,
    especificacion integer NOT NULL,
    ultima_visita boolean,
);


ALTER TABLE cvp.blapre OWNER TO cvpowner;

--
-- Name: calculos; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calculos (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    estimacion integer DEFAULT 0 NOT NULL,
    abierto text DEFAULT 'N'::text NOT NULL,
    esperiodobase text DEFAULT 'N'::text,
    fechacalculo timestamp without time zone,
    fechageneracionexternos timestamp without time zone,
    periodoanterior text,
    calculoanterior integer,
    agrupacionprincipal text DEFAULT 'A'::text NOT NULL,
    valido text DEFAULT 'N'::text NOT NULL,
    pb_calculobase integer,
    motivocopia text,
    transmitir_canastas text DEFAULT 'N'::text NOT NULL,
    fechatransmitircanastas timestamp without time zone,
    hasta_panel integer,
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
    prompriimpact numeric,
    prompriimpant numeric,
    cantpriimp integer,
    promprel numeric,
    promdiv numeric,
    impdiv text,
    cantincluidos integer,
    cantrealesincluidos integer,
    cantrealesexcluidos integer,
    promvar numeric,
    cantaltas integer,
    promaltas numeric,
    cantbajas integer,
    prombajas numeric,
    cantimputados integer,
    ponderadordiv numeric,
    umbralpriimp integer,
    umbraldescarte integer,
    umbralbajaauto integer,
    cantidadconprecio integer,
    profundidad integer,
    divisionpadre text,
    tipo_promedio text,
    raiz boolean,
    cantexcluidos integer,
    promexcluidos numeric,
    promimputados numeric,
    promrealesincluidos numeric,
    promrealesexcluidos numeric,
    promedioredondeado numeric,
    cantrealesdescartados integer,
    cantpreciostotales integer,
    cantpreciosingresados integer,
    cantconprecioparacalestac integer,
    promsinimpext numeric,
    promrealessincambio numeric,
    promrealessincambioant numeric,
    promsinaltasbajas numeric,
    promsinaltasbajasant numeric,
);


ALTER TABLE cvp.caldiv OWNER TO cvpowner;

--
-- Name: calprodresp; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.calprodresp (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    responsable text NOT NULL,
    revisado text NOT NULL,
    observaciones text,
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
    ponderador numeric,
    nivel integer,
    esproducto text,
    nombrecanasta text,
    agrupacionorigen text,
    detallarcanasta text,
    explicaciongrupo text,
    responsable text,
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
             JOIN cvp.grupos g ON (((g.grupo = p.grupo_padre) AND (g.agrupacion = p.agrupacion))))
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
  WHERE (grupos.esproducto = 'N'::text)
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
    porc_adv_inf numeric,
    porc_adv_sup numeric,
    tipoexterno text,
    nombreparaformulario text,
    serepregunta boolean,
    nombreparapublicar text,
    calculo_desvios text DEFAULT 'N'::text,
    excluir_control_precios_maxmin boolean,
    controlar_precios_sin_normalizar boolean,
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
            WHEN ((c.prompriimpact > (0)::numeric) AND (c.prompriimpant > (0)::numeric)) THEN round((((c.prompriimpact / c.prompriimpant) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS varpriimp,
    c.cantpriimp,
    c.promprel,
    c.promdiv,
    c0.promdiv AS promdivant,
    c.promedioredondeado,
    c.impdiv,
        CASE
            WHEN ((c.division = '0'::text) AND (p.tipoexterno = 'D'::text)) THEN 1
            ELSE c.cantincluidos
        END AS cantincluidos,
        CASE
            WHEN ((c.division = '0'::text) AND (p.tipoexterno = 'D'::text)) THEN 1
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
            WHEN ((c.promdiv > (0)::numeric) AND (c0.promdiv > (0)::numeric)) THEN round((((c.promdiv / c0.promdiv) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS variacion,
    c.promsinimpext,
        CASE
            WHEN ((c.promsinimpext > (0)::numeric) AND (c0.promdiv > (0)::numeric)) THEN round((((c.promsinimpext / c0.promdiv) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS varsinimpext,
        CASE
            WHEN ((c.promrealessincambio > (0)::numeric) AND (c.promrealessincambioant > (0)::numeric)) THEN round((((c.promrealessincambio / c.promrealessincambioant) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS varsincambio,
        CASE
            WHEN ((c.promsinaltasbajas > (0)::numeric) AND (c.promsinaltasbajasant > (0)::numeric)) THEN round((((c.promsinaltasbajas / c.promsinaltasbajasant) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS varsinaltasbajas,
        CASE
            WHEN (gg.grupo IS NOT NULL) THEN true
            ELSE false
        END AS publicado,
    r.responsable
   FROM (((((cvp.caldiv c
     LEFT JOIN cvp.productos p ON ((c.producto = p.producto)))
     LEFT JOIN cvp.periodos l ON ((c.periodo = l.periodo)))
     LEFT JOIN cvp.caldiv c0 ON (((c0.periodo = l.periodoanterior) AND (((c.calculo = 0) AND (c0.calculo = c.calculo)) OR ((c.calculo > 0) AND (c0.calculo = 0))) AND (c.producto = c0.producto) AND (c.division = c0.division))))
     LEFT JOIN ( SELECT gru_grupos.grupo
           FROM cvp.gru_grupos
          WHERE ((gru_grupos.agrupacion = 'C'::text) AND (gru_grupos.grupo_padre = ANY (ARRAY['C1'::text, 'C2'::text])) AND (gru_grupos.esproducto = 'S'::text))) gg ON ((c.producto = gg.grupo)))
     LEFT JOIN cvp.calprodresp r ON (((c.periodo = r.periodo) AND (c.calculo = r.calculo) AND (c.producto = r.producto))));


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
    promobs numeric,
    impobs text,
    antiguedadconprecio integer,
    antiguedadsinprecio integer,
    antiguedadexcluido integer,
    antiguedadincluido integer,
    sindatosestacional integer,
    muestra integer,
);


ALTER TABLE cvp.calobs OWNER TO cvpowner;

--
-- Name: relpre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relpre (
    periodo text NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    visita integer NOT NULL,
    observacion integer NOT NULL,
    precio numeric,
    tipoprecio text,
    cambio text,
    comentariosrelpre text,
    esvisiblecomentarioendm boolean,
    precionormalizado numeric,
    especificacion integer,
    ultima_visita boolean,
    observaciones text,
    modi_fec timestamp without time zone,
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
            WHEN ((x.promdivant > (0)::numeric) AND (x.promdivsincambio > (0)::numeric)) THEN round((((x.promdivsincambio / x.promdivant) * (100)::numeric) - (100)::numeric), 1)
            ELSE NULL::numeric
        END AS varsincambio
   FROM ( SELECT c.periodo,
            c.calculo,
            c.producto,
            c.division,
            exp(avg(ln(
                CASE
                    WHEN ((c.promobs > (0)::numeric) AND (c.antiguedadincluido > 0) AND (c0.antiguedadincluido > 0) AND (r.periodo IS NULL)) THEN c.promobs
                    ELSE NULL::numeric
                END))) AS promdivsincambio,
            exp(avg(ln(
                CASE
                    WHEN ((c.promobs > (0)::numeric) AND (c.antiguedadincluido > 0) AND (c0.antiguedadincluido > 0) AND (r.periodo IS NULL)) THEN c0.promobs
                    ELSE NULL::numeric
                END))) AS promdivant
           FROM ((((cvp.calobs c
             LEFT JOIN ( SELECT DISTINCT relpre.periodo,
                    relpre.producto,
                    relpre.observacion,
                    relpre.informante
                   FROM cvp.relpre
                  WHERE (relpre.cambio = 'C'::text)) r ON (((c.periodo = r.periodo) AND (c.producto = r.producto) AND (c.observacion = r.observacion) AND (c.informante = r.informante))))
             LEFT JOIN cvp.calculos ca ON (((c.periodo = ca.periodo) AND (c.calculo = ca.calculo))))
             LEFT JOIN cvp.calobs c0 ON (((ca.periodoanterior = c0.periodo) AND (ca.calculoanterior = c0.calculo) AND (c.producto = c0.producto) AND (c.informante = c0.informante) AND (c.observacion = c0.observacion))))
             LEFT JOIN cvp.caldiv d ON (((c.periodo = d.periodo) AND (c.calculo = d.calculo) AND (c.producto = d.producto) AND (c.division = d.division))))
          WHERE ((c.calculo = 0) AND (c.impobs = ANY (ARRAY['R'::text, 'RA'::text])) AND (c0.impobs = ANY (ARRAY['R'::text, 'RA'::text])))
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
    variacion numeric,
    impgru text,
    valorprel numeric,
    valorgru numeric,
    grupopadre text,
    nivel integer,
    esproducto text,
    ponderador numeric,
    indice numeric,
    indiceprel numeric,
    incidencia numeric,
    indiceredondeado numeric,
    incidenciaredondeada numeric,
    ponderadorimplicito numeric,
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
    ((((c0.valorgru + c1.valorgru) + c.valorgru))::double precision / (3)::double precision) AS valorgrupromedio
   FROM (((cvp.calgru c
     LEFT JOIN cvp.periodos p ON ((c.periodo = p.periodo)))
     LEFT JOIN cvp.calgru c0 ON (((c0.periodo = p.periodoanterior) AND (c.calculo = c0.calculo) AND (c.agrupacion = c0.agrupacion) AND (c.grupo = c0.grupo))))
     LEFT JOIN cvp.calgru c1 ON (((c1.periodo = cvp.moverperiodos(c.periodo, 1)) AND (c1.calculo = c.calculo) AND (c1.agrupacion = c.agrupacion) AND (c1.grupo = c.grupo))))
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
    ((((c.indice - cb.indice) * c.ponderador) / pb.indice) * (100)::numeric) AS incidenciainteranual,
        CASE
            WHEN (c.nivel = 0) THEN round(((((round(c.indice, 2) - round(cb.indice, 2)) * c.ponderador) / round(pb.indice, 2)) * (100)::numeric), 1)
            WHEN (c.nivel = 1) THEN round(((((round(c.indice, 2) - round(cb.indice, 2)) * c.ponderador) / round(pb.indice, 2)) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS incidenciainteranualredondeada,
    ((((c.indice - ca.indice) * c.ponderador) / pa.indice) * (100)::numeric) AS incidenciaacumuladaanual,
    (round(
        CASE
            WHEN (c.nivel = ANY (ARRAY[0, 1])) THEN ((((round(c.indice, 2) - round(ca.indice, 2)) * c.ponderador) / round(pa.indice, 2)) * (100)::numeric)
            ELSE NULL::numeric
        END, 2))::double precision AS incidenciaacumuladaanualredondeada,
        CASE
            WHEN (cb.indiceredondeado = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.indiceredondeado / cb.indiceredondeado) * (100)::numeric) - (100)::numeric), 1)
        END AS variacioninteranualredondeada,
        CASE
            WHEN (cb.indice = (0)::numeric) THEN NULL::numeric
            ELSE (((c.indice / cb.indice) * (100)::numeric) - (100)::numeric)
        END AS variacioninteranual,
        CASE
            WHEN (c_3.indice = (0)::numeric) THEN NULL::numeric
            ELSE (((c.indice / c_3.indice) * (100)::numeric) - (100)::numeric)
        END AS variaciontrimestral,
        CASE
            WHEN (ca.indiceredondeado = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.indiceredondeado / ca.indiceredondeado) * (100)::numeric) - (100)::numeric), 1)
        END AS variacionacumuladaanualredondeada,
        CASE
            WHEN (ca.indice = (0)::numeric) THEN NULL::numeric
            ELSE (((c.indice / ca.indice) * (100)::numeric) - (100)::numeric)
        END AS variacionacumuladaanual,
    c.ponderadorimplicito,
    ('Z'::text || substr(c.grupo, 2)) AS ordenpor,
        CASE
            WHEN (gg.grupo IS NOT NULL) THEN true
            ELSE false
        END AS publicado,
    pr.responsable
   FROM ((((((((((cvp.calgru c
     LEFT JOIN cvp.calgru cb ON (((cb.agrupacion = c.agrupacion) AND (cb.grupo = c.grupo) AND (((c.calculo = 0) AND (cb.calculo = c.calculo)) OR ((c.calculo > 0) AND (cb.calculo = 0))) AND (cb.periodo = cvp.periodo_igual_mes_anno_anterior(c.periodo)))))
     LEFT JOIN cvp.calgru c_3 ON (((c_3.agrupacion = c.agrupacion) AND (c_3.grupo = c.grupo) AND (((c.calculo = 0) AND (c_3.calculo = c.calculo)) OR ((c.calculo > 0) AND (c_3.calculo = 0))) AND (c_3.periodo = cvp.moverperiodos(c.periodo, '-3'::integer)))))
     LEFT JOIN cvp.calgru pb ON (((((c.calculo = 0) AND (pb.calculo = c.calculo)) OR ((c.calculo > 0) AND (pb.calculo = 0))) AND (pb.agrupacion = c.agrupacion) AND (pb.periodo = cvp.periodo_igual_mes_anno_anterior(c.periodo)) AND (pb.nivel = 0))))
     LEFT JOIN cvp.calgru pa ON (((((c.calculo = 0) AND (pa.calculo = c.calculo)) OR ((c.calculo > 0) AND (pa.calculo = 0))) AND (pa.agrupacion = c.agrupacion) AND (pa.periodo = (('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm12'::text)) AND (pa.nivel = 0))))
     LEFT JOIN cvp.calgru ca ON (((ca.agrupacion = c.agrupacion) AND (ca.grupo = c.grupo) AND (((c.calculo = 0) AND (ca.calculo = c.calculo)) OR ((c.calculo > 0) AND (ca.calculo = 0))) AND (ca.periodo = (('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm12'::text)))))
     JOIN cvp.agrupaciones a ON ((a.agrupacion = c.agrupacion)))
     LEFT JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
     LEFT JOIN cvp.productos p ON ((c.grupo = p.producto)))
     LEFT JOIN ( SELECT gru_grupos.grupo
           FROM cvp.gru_grupos
          WHERE ((gru_grupos.agrupacion = 'C'::text) AND (gru_grupos.grupo_padre = ANY (ARRAY['C1'::text, 'C2'::text])) AND (gru_grupos.esproducto = 'S'::text))) gg ON ((c.grupo = gg.grupo)))
     LEFT JOIN cvp.calprodresp pr ON (((c.periodo = pr.periodo) AND (c.calculo = pr.calculo) AND (c.grupo = pr.producto))))
  WHERE (a.tipo_agrupacion = 'INDICE'::text);


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
    valorhoggru numeric,
    coefhoggru numeric,
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
    valorhogsub numeric,
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
            WHEN (c.periodo = 'a2011m01'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m01_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m01'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m01_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m02'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m02_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m02'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m02_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m03'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m03_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m03'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m03_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m04'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m04_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m04'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m04_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m05'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m05_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m05'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m05_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m06'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m06_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m06'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m06_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m07'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m07_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m07'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m07_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m08'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m08_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m08'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m08_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m09'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m09_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m09'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m09_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m10'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m10_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m10'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m10_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m11'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m11_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m11'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m11_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2011m12'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2011m12_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2011m12'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2011m12_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m01'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m01_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m01'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m01_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m02'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m02_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m02'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m02_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m03'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m03_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m03'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m03_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m04'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m04_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m04'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m04_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m05'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m05_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m05'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m05_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m06'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m06_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m06'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m06_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m07'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m07_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m07'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m07_imp,
    round((avg(
        CASE
            WHEN (c.periodo = 'a2012m08'::text) THEN (c.promobs)::double precision
            ELSE NULL::double precision
        END))::numeric, 2) AS a2012m08_prom,
    max(
        CASE
            WHEN (c.periodo = 'a2012m08'::text) THEN (((((
            CASE
                WHEN (c.antiguedadexcluido > 0) THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::text)) ||
            CASE
                WHEN (r.tipoprecio IS NOT NULL) THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::text)) ||
            CASE
                WHEN (r.cambio IS NOT NULL) THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::text))
            ELSE NULL::text
        END) AS a2012m08_imp
   FROM (cvp.calobs c
     LEFT JOIN cvp.relpre r ON (((c.periodo = r.periodo) AND (c.producto = r.producto) AND (c.informante = r.informante) AND (c.observacion = r.observacion) AND (r.visita = 1))))
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
    promprod numeric,
    impprod text,
    valorprod numeric,
    cantincluidos integer,
    promprel numeric,
    valorprel numeric,
    cantaltas integer,
    promaltas numeric,
    cantbajas integer,
    prombajas numeric,
    cantperaltaauto integer,
    cantperbajaauto integer,
    esexternohabitual text,
    imputacon text,
    cantporunidcons numeric,
    unidadmedidaporunidcons text,
    pesovolumenporunidad numeric,
    unidaddemedida text,
    indice numeric,
    indiceprel numeric,
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
    cantporunidcons numeric,
    valorprod numeric,
    unidadmedidaporunidcons text,
    unidaddemedida text,
    pesovolumenporunidad numeric,
);


ALTER TABLE cvp.calprodagr OWNER TO cvpowner;

--
-- Name: matrizperiodos6; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.matrizperiodos6 AS
 SELECT p.periodo AS periodo6,
        CASE
            WHEN (p.periodo = 'a2010m01'::text) THEN NULL::text
            ELSE a.periodo
        END AS periodo5,
        CASE
            WHEN (p.periodo <= 'a2010m02'::text) THEN NULL::text
            ELSE b.periodo
        END AS periodo4,
        CASE
            WHEN (p.periodo <= 'a2010m03'::text) THEN NULL::text
            ELSE c.periodo
        END AS periodo3,
        CASE
            WHEN (p.periodo <= 'a2010m04'::text) THEN NULL::text
            ELSE d.periodo
        END AS periodo2,
        CASE
            WHEN (p.periodo <= 'a2010m05'::text) THEN NULL::text
            ELSE e.periodo
        END AS periodo1
   FROM (((((cvp.calculos p
     LEFT JOIN cvp.calculos a ON (((a.periodo = p.periodoanterior) AND (a.calculo = 0))))
     LEFT JOIN cvp.calculos b ON (((b.periodo = a.periodoanterior) AND (b.calculo = 0))))
     LEFT JOIN cvp.calculos c ON (((c.periodo = b.periodoanterior) AND (c.calculo = 0))))
     LEFT JOIN cvp.calculos d ON (((d.periodo = c.periodoanterior) AND (d.calculo = 0))))
     LEFT JOIN cvp.calculos e ON (((e.periodo = d.periodoanterior) AND (e.calculo = 0))))
  WHERE (p.calculo = 0);


ALTER TABLE cvp.matrizperiodos6 OWNER TO cvpowner;

--
-- Name: canasta_alimentaria; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_alimentaria AS
 SELECT
        CASE
            WHEN ((x.agrupacion = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END AS grupo,
    x.nombregrupo,
    round(c1.valorgru, 2) AS valorgru1,
    round(c2.valorgru, 2) AS valorgru2,
    round(c3.valorgru, 2) AS valorgru3,
    round(c4.valorgru, 2) AS valorgru4,
    round(c5.valorgru, 2) AS valorgru5,
    round(c6.valorgru, 2) AS valorgru6,
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
             JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR (c.periodo >= a.periodo1)) AND (c.periodo <= a.periodo6))))
          WHERE ((c.calculo = 0) AND (c.agrupacion = ANY (ARRAY['A'::text, 'B'::text])) AND (g.nivel = ANY (ARRAY[2, 3])) AND (substr(g.grupopadre, 1, 2) = ANY (ARRAY['A1'::text, 'B1'::text])))) x ON ((x.periodo = p.periodo6)))
     LEFT JOIN cvp.calgru c1 ON (((x.agrupprincipal = c1.agrupacion) AND (x.grupo = c1.grupo) AND (c1.periodo = p.periodo1) AND (c1.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c2 ON (((x.agrupprincipal = c2.agrupacion) AND (x.grupo = c2.grupo) AND (c2.periodo = p.periodo2) AND (c2.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c3 ON (((x.agrupprincipal = c3.agrupacion) AND (x.grupo = c3.grupo) AND (c3.periodo = p.periodo3) AND (c3.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c4 ON (((x.agrupprincipal = c4.agrupacion) AND (x.grupo = c4.grupo) AND (c4.periodo = p.periodo4) AND (c4.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c5 ON (((x.agrupprincipal = c5.agrupacion) AND (x.grupo = c5.grupo) AND (c5.periodo = p.periodo5) AND (c5.calculo = x.calculo))))
     LEFT JOIN cvp.calgru c6 ON (((x.agrupprincipal = c6.agrupacion) AND (x.grupo = c6.grupo) AND (c6.periodo = p.periodo6) AND (c6.calculo = x.calculo))))
     LEFT JOIN cvp.periodos p0 ON (((p0.periodo = p.periodo1) AND (p0.periodoanterior <> p.periodo1))))
     LEFT JOIN cvp.calgru cl0 ON (((x.agrupacion = cl0.agrupacion) AND (x.grupo = cl0.grupo) AND (cl0.periodo = p0.periodoanterior) AND (cl0.calculo = x.calculo))))
  ORDER BY x.agrupacion, c6.periodo, x.nivel,
        CASE
            WHEN ((x.agrupacion = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END;


ALTER TABLE cvp.canasta_alimentaria OWNER TO cvpowner;

--
-- Name: canasta_alimentaria_var; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_alimentaria_var AS
 SELECT
        CASE
            WHEN ((x.agrupacion = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END AS grupo,
    x.nombregrupo,
    round(c0.valorgru, 2) AS valorgruant,
    round(c.valorgru, 2) AS valorgru,
    round(c.variacion, 1) AS variacion,
        CASE
            WHEN (ca.valorgru = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorgru / ca.valorgru) * (100)::numeric) - (100)::numeric), 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorgru = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorgru / cm.valorgru) * (100)::numeric) - (100)::numeric), 1)
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
             JOIN cvp.grupos g ON (((c_1.agrupacion = g.agrupacion) AND (c_1.grupo = g.grupo))))
             JOIN cvp.calculos p ON (((c_1.periodo = p.periodo) AND ('A'::text = p.agrupacionprincipal) AND (0 = p.calculo))))
          WHERE ((c_1.calculo = 0) AND (c_1.agrupacion = ANY (ARRAY['A'::text, 'B'::text])) AND (g.nivel = ANY (ARRAY[2, 3])) AND (substr(g.grupopadre, 1, 2) = ANY (ARRAY['A1'::text, 'B1'::text])))) x
     LEFT JOIN cvp.calgru c ON (((x.agrupprincipal = c.agrupacion) AND (x.grupo = c.grupo) AND (c.calculo = x.calculo) AND (c.periodo = x.periodo))))
     LEFT JOIN cvp.calgru c0 ON (((x.agrupprincipal = c0.agrupacion) AND (x.grupo = c0.grupo) AND (c0.calculo = x.calculoanterior) AND (c0.periodo = x.periodoanterior))))
     LEFT JOIN cvp.calgru ca ON (((x.agrupprincipal = ca.agrupacion) AND (x.grupo = ca.grupo) AND (ca.calculo = x.calculo) AND (ca.periodo = (('a'::text || ((substr(x.periodo, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calgru cm ON (((x.agrupprincipal = cm.agrupacion) AND (x.grupo = cm.grupo) AND (cm.calculo = x.calculo) AND (cm.periodo = ((('a'::text || ((substr(x.periodo, 2, 4))::integer - 1)) || 'm'::text) || substr(x.periodo, 7, 2))))))
  ORDER BY x.agrupacion, x.periodo, x.nivel,
        CASE
            WHEN ((x.agrupacion = 'B'::text) AND (x.nivel = 2)) THEN x.grupopadre
            ELSE x.grupo
        END;


ALTER TABLE cvp.canasta_alimentaria_var OWNER TO cvpowner;

--
-- Name: canasta_consumo; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.canasta_consumo AS
 SELECT x.hogar,
        CASE
            WHEN (x.nivel = 1) THEN (x.grupo || 'X'::text)
            ELSE x.grupo
        END AS grupo,
    x.nombre,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s1.valorhogsub
            ELSE c1.valorhoggru
        END, 2) AS valorgru1,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s2.valorhogsub
            ELSE c2.valorhoggru
        END, 2) AS valorgru2,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s3.valorhogsub
            ELSE c3.valorhoggru
        END, 2) AS valorgru3,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s4.valorhogsub
            ELSE c4.valorhoggru
        END, 2) AS valorgru4,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s5.valorhogsub
            ELSE c5.valorhoggru
        END, 2) AS valorgru5,
    round(
        CASE
            WHEN (x.nivel = 1) THEN s6.valorhogsub
            ELSE c6.valorhoggru
        END, 2) AS valorgru6,
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
             JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR (c.periodo >= a.periodo1)) AND (c.periodo <= a.periodo6))))
          WHERE ((c.calculo = 0) AND ((g.nivel = 2) AND (substr(g.grupopadre, 1, 2) <> ALL (ARRAY['A1'::text, 'B1'::text]))))
        UNION
         SELECT c.grupo,
            c.hogar,
            g.nombrecanasta AS nombre,
            c.agrupacion,
            c.calculo,
            a.periodo6,
            g.nivel
           FROM ((cvp.calhogsubtotales c
             JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR (c.periodo >= a.periodo1)) AND (c.periodo <= a.periodo6))))
          WHERE ((c.calculo = 0) AND (g.nivel = 1))
          GROUP BY c.grupo, c.hogar, g.nombrecanasta, c.agrupacion, c.calculo, a.periodo6, g.nivel) x ON ((x.periodo6 = p.periodo6)))
     LEFT JOIN cvp.calhoggru c1 ON (((x.agrupacion = c1.agrupacion) AND (x.grupo = c1.grupo) AND (x.hogar = c1.hogar) AND (c1.periodo = p.periodo1) AND (c1.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c2 ON (((x.agrupacion = c2.agrupacion) AND (x.grupo = c2.grupo) AND (x.hogar = c2.hogar) AND (c2.periodo = p.periodo2) AND (c2.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c3 ON (((x.agrupacion = c3.agrupacion) AND (x.grupo = c3.grupo) AND (x.hogar = c3.hogar) AND (c3.periodo = p.periodo3) AND (c3.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c4 ON (((x.agrupacion = c4.agrupacion) AND (x.grupo = c4.grupo) AND (x.hogar = c4.hogar) AND (c4.periodo = p.periodo4) AND (c4.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c5 ON (((x.agrupacion = c5.agrupacion) AND (x.grupo = c5.grupo) AND (x.hogar = c5.hogar) AND (c5.periodo = p.periodo5) AND (c5.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhoggru c6 ON (((x.agrupacion = c6.agrupacion) AND (x.grupo = c6.grupo) AND (x.hogar = c6.hogar) AND (c6.periodo = p.periodo6) AND (c6.calculo = x.calculo) AND (x.nivel = 2))))
     LEFT JOIN cvp.calhogsubtotales s1 ON (((x.agrupacion = s1.agrupacion) AND (x.grupo = s1.grupo) AND (x.hogar = s1.hogar) AND (s1.periodo = p.periodo1) AND (s1.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s2 ON (((x.agrupacion = s2.agrupacion) AND (x.grupo = s2.grupo) AND (x.hogar = s2.hogar) AND (s2.periodo = p.periodo2) AND (s2.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s3 ON (((x.agrupacion = s3.agrupacion) AND (x.grupo = s3.grupo) AND (x.hogar = s3.hogar) AND (s3.periodo = p.periodo3) AND (s3.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s4 ON (((x.agrupacion = s4.agrupacion) AND (x.grupo = s4.grupo) AND (x.hogar = s4.hogar) AND (s4.periodo = p.periodo4) AND (s4.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s5 ON (((x.agrupacion = s5.agrupacion) AND (x.grupo = s5.grupo) AND (x.hogar = s5.hogar) AND (s5.periodo = p.periodo5) AND (s5.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.calhogsubtotales s6 ON (((x.agrupacion = s6.agrupacion) AND (x.grupo = s6.grupo) AND (x.hogar = s6.hogar) AND (s6.periodo = p.periodo6) AND (s6.calculo = x.calculo) AND (x.nivel = 1))))
     LEFT JOIN cvp.periodos p0 ON (((p0.periodo = p.periodo1) AND (p0.periodoanterior <> p.periodo1))))
     LEFT JOIN cvp.calhoggru cl0 ON (((x.agrupacion = cl0.agrupacion) AND (x.grupo = cl0.grupo) AND (x.hogar = cl0.hogar) AND (cl0.periodo = p0.periodoanterior) AND (cl0.calculo = x.calculo))))
  ORDER BY x.agrupacion,
        CASE
            WHEN (x.nivel = 1) THEN s6.periodo
            ELSE c6.periodo
        END, x.hogar,
        CASE
            WHEN (x.nivel = 1) THEN (x.grupo || 'X'::text)
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
    round(c0.valorhoggru, 2) AS valorgruant,
    round(c.valorhoggru, 2) AS valorhg,
        CASE
            WHEN (c0.valorhoggru = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhoggru / c0.valorhoggru) * (100)::numeric) - (100)::numeric), 1)
        END AS variacion,
        CASE
            WHEN (ca.valorhoggru = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhoggru / ca.valorhoggru) * (100)::numeric) - (100)::numeric), 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorhoggru = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhoggru / cm.valorhoggru) * (100)::numeric) - (100)::numeric), 1)
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
     JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
     JOIN cvp.calculos p ON (((c.periodo = p.periodo) AND ('A'::text = p.agrupacionprincipal) AND (0 = p.calculo))))
     JOIN cvp.calhoggru c0 ON (((c.agrupacion = c0.agrupacion) AND (c.hogar = c0.hogar) AND (c.grupo = c0.grupo) AND (c0.calculo = p.calculoanterior) AND (c0.periodo = p.periodoanterior))))
     LEFT JOIN cvp.calhoggru ca ON (((c.agrupacion = ca.agrupacion) AND (c.hogar = ca.hogar) AND (c.grupo = ca.grupo) AND (c.calculo = ca.calculo) AND (ca.periodo = (('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calhoggru cm ON (((c.agrupacion = cm.agrupacion) AND (c.hogar = cm.hogar) AND (c.grupo = cm.grupo) AND (c.calculo = cm.calculo) AND (cm.periodo = ((('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm'::text) || substr(c.periodo, 7, 2))))))
  WHERE ((c.calculo = 0) AND ((g.nivel = 2) AND (substr(g.grupopadre, 1, 2) <> ALL (ARRAY['A1'::text, 'B1'::text]))))
UNION
 SELECT c.hogar,
    (c.grupo || 'X'::text) AS grupo,
    g.nombrecanasta AS nombre,
    round(c0.valorhogsub, 2) AS valorgruant,
    round(c.valorhogsub, 2) AS valorhg,
        CASE
            WHEN (c0.valorhogsub = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhogsub / c0.valorhogsub) * (100)::numeric) - (100)::numeric), 1)
        END AS variacion,
        CASE
            WHEN (ca.valorhogsub = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhogsub / ca.valorhogsub) * (100)::numeric) - (100)::numeric), 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.valorhogsub = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.valorhogsub / cm.valorhogsub) * (100)::numeric) - (100)::numeric), 1)
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
     JOIN cvp.grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
     JOIN cvp.calculos p ON (((c.periodo = p.periodo) AND ('A'::text = p.agrupacionprincipal) AND (0 = p.calculo))))
     JOIN cvp.calhogsubtotales c0 ON (((c.agrupacion = c0.agrupacion) AND (c.hogar = c0.hogar) AND (c.grupo = c0.grupo) AND (c0.calculo = p.calculoanterior) AND (c0.periodo = p.periodoanterior))))
     LEFT JOIN cvp.calhogsubtotales ca ON (((c.agrupacion = ca.agrupacion) AND (c.hogar = ca.hogar) AND (c.grupo = ca.grupo) AND (c.calculo = ca.calculo) AND (ca.periodo = (('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm12'::text)))))
     LEFT JOIN cvp.calhogsubtotales cm ON (((c.agrupacion = cm.agrupacion) AND (c.hogar = cm.hogar) AND (c.grupo = cm.grupo) AND (c.calculo = cm.calculo) AND (cm.periodo = ((('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm'::text) || substr(c.periodo, 7, 2))))))
  WHERE ((c.calculo = 0) AND (g.nivel = 1))
  ORDER BY 9, 11, 1, 2;


ALTER TABLE cvp.canasta_consumo_var OWNER TO cvpowner;

--
-- Name: hogparagr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.hogparagr (
    parametro text NOT NULL,
    hogar text NOT NULL,
    coefhogpar numeric NOT NULL,
    agrupacion text NOT NULL,
);


ALTER TABLE cvp.hogparagr OWNER TO cvpowner;

--
-- Name: parhog; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.parhog (
    parametro text NOT NULL,
    nombreparametro text NOT NULL,
);


ALTER TABLE cvp.parhog OWNER TO cvpowner;

--
-- Name: parhoggru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.parhoggru (
    parametro text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
);


ALTER TABLE cvp.parhoggru OWNER TO cvpowner;

--
-- Name: prodagr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prodagr (
    producto text NOT NULL,
    agrupacion text NOT NULL,
    cantporunidcons numeric,
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
    string_agg(ph.parametro, ', '::text) AS parametro,
    string_agg(o.nombreparametro, ', '::text) AS nombreparametro,
    hp.hogar,
        CASE
            WHEN (min(COALESCE(abs(hp.coefhogpar))) > (0)::numeric) THEN exp(sum(ln(NULLIF(hp.coefhogpar, (0)::numeric))))
            ELSE (0)::numeric
        END AS coefhoggru,
    (c.valorgru *
        CASE
            WHEN (min(COALESCE(abs(hp.coefhogpar))) > (0)::numeric) THEN exp(sum(ln(NULLIF(hp.coefhogpar, (0)::numeric))))
            ELSE (0)::numeric
        END) AS valorhogprod,
    substr(c.grupo, 2, 2) AS divisioncanasta,
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
     LEFT JOIN cvp.gru_grupos g ON (((c.agrupacion = g.agrupacion) AND (c.grupo = g.grupo))))
     LEFT JOIN cvp.productos p ON ((c.grupo = p.producto)))
     LEFT JOIN cvp.prodagr ag ON (((c.agrupacion = ag.agrupacion) AND (p.producto = ag.producto))))
     JOIN cvp.parhoggru ph ON (((c.agrupacion = ph.agrupacion) AND (g.grupo_padre = ph.grupo))))
     LEFT JOIN cvp.hogparagr hp ON (((ph.parametro = hp.parametro) AND (ph.agrupacion = hp.agrupacion))))
     LEFT JOIN cvp.parhog o ON ((ph.parametro = o.parametro)))
     LEFT JOIN ( SELECT g_1.agrupacion,
            g_1.grupo AS agrupo0,
            g4.grupo AS agrupo4,
            g3.grupo AS agrupo3,
            g2.grupo AS agrupo2,
            g1.grupo AS agrupo1
           FROM ((((cvp.grupos g_1
             JOIN cvp.grupos g4 ON (((g_1.grupopadre = g4.grupo) AND (g_1.agrupacion = g4.agrupacion) AND (g4.agrupacion = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g3 ON (((g4.grupopadre = g3.grupo) AND (g_1.agrupacion = g4.agrupacion) AND (g3.agrupacion = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g2 ON (((g3.grupopadre = g2.grupo) AND (g_1.agrupacion = g4.agrupacion) AND (g2.agrupacion = ANY (ARRAY['A'::text, 'D'::text])))))
             JOIN cvp.grupos g1 ON (((g2.grupopadre = g1.grupo) AND (g_1.agrupacion = g4.agrupacion) AND (g1.agrupacion = ANY (ARRAY['A'::text, 'D'::text])))))
          WHERE ((g_1.agrupacion = ANY (ARRAY['A'::text, 'D'::text])) AND (g_1.nivel = 5))) a ON (((c.grupo = a.agrupo0) AND (c.agrupacion = a.agrupacion))))
     LEFT JOIN ( SELECT g_1.grupo AS bgrupo0,
            g4.grupo AS bgrupo4,
            g3.grupo AS bgrupo3,
            g2.grupo AS bgrupo2,
            g1.grupo AS bgrupo1
           FROM ((((cvp.grupos g_1
             JOIN cvp.grupos g4 ON (((g_1.grupopadre = g4.grupo) AND (g4.agrupacion = 'B'::text))))
             JOIN cvp.grupos g3 ON (((g4.grupopadre = g3.grupo) AND (g3.agrupacion = 'B'::text))))
             JOIN cvp.grupos g2 ON (((g3.grupopadre = g2.grupo) AND (g2.agrupacion = 'B'::text))))
             JOIN cvp.grupos g1 ON (((g2.grupopadre = g1.grupo) AND (g1.agrupacion = 'B'::text))))
          WHERE ((g_1.agrupacion = 'B'::text) AND (g_1.nivel = 4))) b ON ((g.grupo_padre = b.bgrupo0)))
  WHERE ((c.calculo = 0) AND (c.agrupacion = ANY (ARRAY['A'::text, 'D'::text])) AND (g.esproducto = 'S'::text) AND (ag.cantporunidcons > (0)::numeric) AND (c.valorgru IS NOT NULL))
  GROUP BY c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar, a.agrupo1, a.agrupo2, a.agrupo3, a.agrupo4, b.bgrupo0, b.bgrupo1, b.bgrupo2, b.bgrupo3, b.bgrupo4
  ORDER BY c.periodo, c.calculo, c.agrupacion, c.grupo, p.nombreproducto, c.valorgru, c.grupopadre, g.grupo_padre, hp.hogar, a.agrupo1, a.agrupo2, a.agrupo3, a.agrupo4, b.bgrupo0, b.bgrupo1, b.bgrupo2, b.bgrupo3, b.bgrupo4;


ALTER TABLE cvp.canasta_producto OWNER TO cvpowner;

--
-- Name: conjuntomuestral; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.conjuntomuestral (
    conjuntomuestral integer NOT NULL,
    encuestador text,
    panel integer,
    tiponegociomuestra integer,
);


ALTER TABLE cvp.conjuntomuestral OWNER TO cvpowner;

--
-- Name: informantes; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.informantes (
    informante integer NOT NULL,
    nombreinformante text,
    estado text,
    tipoinformante text NOT NULL,
    rubroclanae text,
    cadena text,
    direccion text,
    altamanualperiodo text,
    altamanualpanel integer,
    altamanualtarea integer,
    altamanualconfirmar timestamp without time zone,
    razonsocial text,
    nombrecalle text,
    altura text,
    piso text,
    departamento text,
    cuit integer,
    naecba integer,
    totalpers integer,
    cp text,
    distrito integer,
    fraccion integer,
    radio integer,
    manzana integer,
    lado integer,
    obs_listador text,
    nr_listador text,
    fecha_listado date,
    grupo_listado text,
    conjuntomuestral integer,
    rubro integer NOT NULL,
    ordenhdr integer NOT NULL,
    cue integer,
    idlocal integer,
    muestra integer NOT NULL,
    contacto text,
    telcontacto text,
    modi_fec timestamp without time zone,
);


ALTER TABLE cvp.informantes OWNER TO cvpowner;

--
-- Name: relvis; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relvis (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    formulario integer NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    fechasalida date,
    fechaingreso date,
    encuestador text,
    ingresador text,
    recepcionista text,
    razon integer,
    ultimavisita integer NOT NULL,
    comentarios text,
    supervisor text,
    informantereemplazante integer,
    ultima_visita boolean,
    verificado_rec text,
    fechageneracion timestamp without time zone,
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
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 1) AS grupo_padre_1,
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 2) AS nombregrupo_1,
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 3) AS grupo_padre_2,
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 4) AS nombregrupo_2,
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 5) AS grupo_padre_3,
    split_part(string_agg(((gg_1.grupo_padre || '|'::text) || g_1.nombregrupo), '|'::text ORDER BY g_1.nivel), '|'::text, 6) AS nombregrupo_3,
    rp.producto,
    p.nombreproducto,
    rp.observacion,
    rp.precionormalizado,
    rp.tipoprecio,
    rp.cambio,
    (((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric) AS variacion_1,
    sign((((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric)) AS varia_1,
    rp_1.precionormalizado AS precionormalizado_1,
    rp_1.tipoprecio AS tipoprecio_1,
    rp_1.cambio AS cambio_1,
    (((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric) AS variacion_2,
    sign((((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric)) AS varia_2,
    rp_2.precionormalizado AS precionormalizado_2,
    rp_2.tipoprecio AS tipoprecio_2,
    rp_2.cambio AS cambio_2,
    ((COALESCE((sign((((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric)))::text, 'N'::text) || '_'::text) || COALESCE((sign((((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric)))::text, 'N'::text)) AS varia_ambos
   FROM ((((((((( SELECT periodos.periodo,
            periodos.periodoanterior,
            cvp.moverperiodos(periodos.periodoanterior, '-1'::integer) AS periodoanterioranterior
           FROM cvp.periodos
          WHERE (periodos.ingresando = 'S'::text)) per
     LEFT JOIN cvp.relpre rp ON ((per.periodo = rp.periodo)))
     LEFT JOIN cvp.relvis rv ON (((rv.periodo = rp.periodo) AND (rv.informante = rp.informante) AND (rv.visita = rp.visita) AND (rv.formulario = rp.formulario))))
     LEFT JOIN cvp.productos p USING (producto))
     LEFT JOIN cvp.informantes i ON ((rp.informante = i.informante)))
     LEFT JOIN cvp.relpre rp_1 ON (((rp_1.periodo = per.periodoanterior) AND (rp_1.producto = rp.producto) AND (rp_1.observacion = rp.observacion) AND (rp_1.informante = rp.informante) AND (rp_1.visita = rp.visita))))
     LEFT JOIN cvp.relpre rp_2 ON (((rp_2.periodo = per.periodoanterioranterior) AND (rp_2.producto = rp.producto) AND (rp_2.observacion = rp.observacion) AND (rp_2.informante = rp.informante) AND (rp_2.visita = rp.visita))))
     LEFT JOIN cvp.gru_grupos gg_1 ON ((rp.producto = gg_1.grupo)))
     LEFT JOIN cvp.grupos g_1 ON ((gg_1.grupo_padre = g_1.grupo)))
  WHERE ((gg_1.agrupacion = 'Z'::text) AND (gg_1.esproducto = 'S'::text) AND (g_1.nivel = ANY (ARRAY[1, 2, 3])))
  GROUP BY per.periodo, rv.panel, rv.tarea, rp.informante, i.tipoinformante, rp.visita, rp.formulario, rp.producto, p.nombreproducto, rp.observacion, rp.precionormalizado, rp.tipoprecio, rp.cambio, (((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric), (sign((((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric))), rp_1.precionormalizado, rp_1.tipoprecio, rp_1.cambio, (((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric), (sign((((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric))), rp_2.precionormalizado, rp_2.tipoprecio, rp_2.cambio, ((COALESCE((sign((((rp.precionormalizado / rp_1.precionormalizado) * 100.0) - (100)::numeric)))::text, 'N'::text) || '_'::text) || COALESCE((sign((((rp_1.precionormalizado / rp_2.precionormalizado) * 100.0) - (100)::numeric)))::text, 'N'::text));


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
    id_instalacion integer,
    ipad text,
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
    ((v.encuestador || ':'::text) || e.apellido) AS encuestador,
    v.recepcionista,
    v.formulario,
    r.comentariosrelpre
   FROM (((cvp.relpre r
     LEFT JOIN cvp.productos p ON ((r.producto = p.producto)))
     LEFT JOIN cvp.relvis v ON (((r.periodo = v.periodo) AND (r.informante = v.informante) AND (r.visita = v.visita) AND (r.formulario = v.formulario))))
     LEFT JOIN cvp.personal e ON ((v.encuestador = e.persona)))
  WHERE (r.tipoprecio = 'A'::text);


ALTER TABLE cvp.control_anulados_recep OWNER TO cvpowner;

--
-- Name: prodatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prodatr (
    producto text NOT NULL,
    atributo integer NOT NULL,
    valornormal numeric,
    orden integer NOT NULL,
    normalizable text DEFAULT 'N'::text,
    tiponormalizacion text,
    alterable text DEFAULT 'N'::text,
    prioridad integer,
    operacion text,
    rangodesde numeric,
    rangohasta numeric,
    orden_calculo_especial integer,
    tipo_promedio text,
    esprincipal text DEFAULT 'N'::text,
    visiblenombreatributo text,
    otraunidaddemedida text,
    opciones text,
);


ALTER TABLE cvp.prodatr OWNER TO cvpowner;

--
-- Name: relatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relatr (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    producto text NOT NULL,
    observacion integer NOT NULL,
    atributo integer NOT NULL,
    valor text,
    validar_con_valvalatr boolean,
);


ALTER TABLE cvp.relatr OWNER TO cvpowner;

--
-- Name: tipopre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tipopre (
    tipoprecio text NOT NULL,
    nombretipoprecio text NOT NULL,
    espositivo text NOT NULL,
    visibleparaencuestador text NOT NULL,
    registrablanqueo boolean DEFAULT false NOT NULL,
    activo text NOT NULL,
    puedecopiar text DEFAULT 'N'::text,
    orden integer,
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
    ((((((((('Valor Normal '::text || pa.valornormal) || ' '::text) || a.nombreatributo) || ' '::text) || v.valor) || ' Rango '::text) || pa.rangodesde) || ' a '::text) || pa.rangohasta) AS fueraderango
   FROM ((((((cvp.relatr v
     JOIN cvp.relpre r ON (((v.periodo = r.periodo) AND (v.producto = r.producto) AND (v.informante = r.informante) AND (v.observacion = r.observacion) AND (v.visita = r.visita))))
     JOIN cvp.productos f ON ((v.producto = f.producto)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND (v.periodo = vi.periodo) AND (v.visita = vi.visita) AND (r.formulario = vi.formulario))))
     LEFT JOIN cvp.prodatr pa ON (((v.producto = pa.producto) AND (v.atributo = pa.atributo))))
     LEFT JOIN cvp.atributos a ON ((pa.atributo = a.atributo)))
     LEFT JOIN cvp.tipopre t ON ((r.tipoprecio = t.tipoprecio)))
  WHERE ((t.espositivo = 'S'::text) AND comun.es_numero(v.valor) AND (pa.rangohasta IS NOT NULL) AND (pa.rangodesde IS NOT NULL) AND
        CASE
            WHEN comun.es_numero(v.valor) THEN ((((v.valor)::double precision > (pa.rangohasta)::double precision) OR ((v.valor)::double precision < (pa.rangodesde)::double precision)) AND ((v.valor)::double precision <> (pa.valornormal)::double precision))
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
    ponderadordiv numeric,
    incluye_supermercados boolean,
    incluye_tradicionales boolean,
    umbralpriimp integer,
    umbraldescarte integer,
    umbralbajaauto integer,
    tipoinformante text,
    sindividir boolean,
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
     JOIN cvp.grupos g ON ((c.grupo = g.grupo)))
     JOIN cvp.calculos a ON (((a.periodo = c.periodo) AND (a.calculo = c.calculo))))
     JOIN cvp.calculos_def cd ON ((a.calculo = cd.calculo)))
  WHERE ((c.calculo = 0) AND (c.agrupacion = cd.agrupacionprincipal) AND (c.esproducto = 'N'::text))
UNION
 SELECT c.producto AS codigo,
    p.nombreproducto AS nombre,
    c.division AS ti,
    g.nivel,
    cpa.valorprod AS valor,
        CASE
            WHEN (c.division = '0'::text) THEN g.variacion
            ELSE NULL::numeric
        END AS variacion,
    c.impdiv AS imp,
    cpa.cantporunidcons AS cant,
    cp.unidadmedidaporunidcons AS unidad,
    c.promdiv AS promedio,
    cvp.obtenerunidadnormalizada(p.producto) AS unidadnormal,
    c.cantincluidos,
    c.cantimputados,
    c.promvar,
    c.cantaltas,
    c.promaltas,
    c.cantbajas,
    c.prombajas,
    c.periodo,
    ((g.grupopadre || '-'::text) || g.grupo) AS ordenamiento,
    'S'::text AS esproducto,
    v.ponderadordiv,
    c_1.promdiv AS promedio_1,
    (((c.promdiv / c_1.promdiv) * (100)::numeric) - (100)::numeric) AS varprom,
    c.cantexcluidos,
    c.promexcluidos
   FROM (((((((((cvp.caldiv c
     JOIN cvp.productos p ON ((c.producto = p.producto)))
     JOIN cvp.calculos a ON (((a.periodo = c.periodo) AND (a.calculo = c.calculo))))
     JOIN cvp.calculos_def cd ON ((a.calculo = cd.calculo)))
     JOIN cvp.calgru g ON (((g.periodo = c.periodo) AND (g.calculo = c.calculo) AND (g.agrupacion = cd.agrupacionprincipal) AND (g.grupo = c.producto))))
     JOIN ( SELECT x.periodo,
            x.calculo,
            x.producto,
            count(*) AS canttipo
           FROM cvp.caldiv x
          GROUP BY x.periodo, x.calculo, x.producto) y ON (((y.periodo = c.periodo) AND (y.calculo = c.calculo) AND (y.producto = c.producto))))
     JOIN cvp.calprod cp ON (((c.periodo = cp.periodo) AND (c.calculo = cp.calculo) AND (c.producto = cp.producto))))
     JOIN cvp.calprodagr cpa ON (((c.periodo = cpa.periodo) AND (c.calculo = cpa.calculo) AND (c.producto = cpa.producto) AND (g.agrupacion = cpa.agrupacion))))
     LEFT JOIN cvp.proddiv v ON (((p.producto = v.producto) AND (c.division = v.division))))
     LEFT JOIN cvp.caldiv c_1 ON (((a.periodoanterior = c_1.periodo) AND (a.calculoanterior = c_1.calculo) AND (c.producto = c_1.producto) AND (c.division = c_1.division))))
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
            ELSE round(c.promobs, 2)
        END AS promobs,
        CASE
            WHEN (r.visita > 1) THEN NULL::text
            ELSE c.impobs
        END AS impobs,
        CASE
            WHEN (r.visita > 1) THEN NULL::numeric
            ELSE round(c_1.promobs, 2)
        END AS promobs_1,
        CASE
            WHEN ((r.visita > 1) OR (c_1.promobs = (0)::numeric)) THEN NULL::numeric
            ELSE round((((c.promobs / c_1.promobs) * (100)::numeric) - (100)::numeric), 1)
        END AS variacion,
    r.cambio,
    r.precionormalizado,
    r.precio,
    r.tipoprecio
   FROM (((cvp.relpre r
     FULL JOIN cvp.calobs c ON (((c.periodo = r.periodo) AND (c.producto = r.producto) AND (c.observacion = r.observacion) AND (c.informante = r.informante))))
     JOIN cvp.calculos ca ON (((ca.periodo = c.periodo) AND (ca.calculo = c.calculo))))
     LEFT JOIN cvp.calobs c_1 ON (((c_1.producto = c.producto) AND (c_1.calculo = ca.calculoanterior) AND (c_1.informante = c.informante) AND (c_1.observacion = c.observacion) AND (c_1.periodo = ca.periodoanterior))))
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
    activo text DEFAULT 'S'::text,
    despacho text,
    altamanualdesdeperiodo text,
    orden integer,
    pie text,
);


ALTER TABLE cvp.formularios OWNER TO cvpowner;

--
-- Name: forprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.forprod (
    formulario integer NOT NULL,
    producto text NOT NULL,
    orden integer,
    ordenimpresion integer,
);


ALTER TABLE cvp.forprod OWNER TO cvpowner;

--
-- Name: razones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.razones (
    razon integer NOT NULL,
    nombrerazon text NOT NULL,
    espositivoinformante text NOT NULL,
    espositivoformulario text NOT NULL,
    escierredefinitivoinf text NOT NULL,
    escierredefinitivofor text NOT NULL,
    visibleparaencuestador text NOT NULL,
    escierretemporalfor text,
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
            WHEN ((r.periodo IS NULL) AND (z.escierredefinitivoinf = 'N'::text) AND (z.escierredefinitivofor = 'N'::text)) THEN 'Falta generar'::text
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
     JOIN cvp.periodos p ON ((r_1.periodo = p.periodoanterior)))
     JOIN cvp.razones z ON ((r_1.razon = z.razon)))
     LEFT JOIN cvp.relvis r ON (((r.periodo = p.periodo) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
     LEFT JOIN ( SELECT DISTINCT relpre.periodo,
            relpre.informante,
            relpre.formulario,
            relpre.visita,
            1 AS tieneprecio
           FROM cvp.relpre) pr ON (((pr.periodo = r.periodo) AND (pr.informante = r.informante) AND (pr.formulario = r.formulario) AND (pr.visita = r.visita))))
     LEFT JOIN ( SELECT DISTINCT f_1.formulario,
            1 AS tiene_vigencia
           FROM ((cvp.forprod f_1
             JOIN cvp.prodatr pa ON ((f_1.producto = pa.producto)))
             JOIN cvp.atributos a ON (((a.atributo = pa.atributo) AND (a.es_vigencia = true))))
          GROUP BY f_1.formulario) e ON ((e.formulario = r_1.formulario)))
     LEFT JOIN ( SELECT DISTINCT f_1.formulario,
            1 AS tieneproductos
           FROM cvp.forprod f_1) fp ON ((fp.formulario = r_1.formulario)))
  WHERE ((((r.periodo IS NULL) AND (z.escierredefinitivoinf = 'N'::text) AND (z.escierredefinitivofor = 'N'::text) AND (e.tiene_vigencia IS DISTINCT FROM 1)) OR ((r.periodo IS NOT NULL) AND (r.razon IS NULL)) OR ((r.periodo IS NOT NULL) AND (r.razon IS NOT NULL) AND (pr.tieneprecio IS DISTINCT FROM 1))) AND (f.activo = 'S'::text))
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
          WHERE (grupos.esproducto = 'S'::text)
        UNION ALL
         SELECT p.agrupacion,
            g.grupopadre AS grupo_padre,
            p.producto
           FROM (productos_de p
             JOIN cvp.grupos g ON (((g.grupo = p.grupo_padre) AND (g.agrupacion = p.agrupacion))))
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
    ('Z'::text || substr(x.grupo, 2)) AS ordenpor
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
             LEFT JOIN cvp.gru_prod gp ON ((d.producto = gp.producto)))
             LEFT JOIN cvp.grupos g ON (((gp.grupo_padre = g.grupo) AND (gp.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.agrupaciones a ON ((gp.agrupacion = a.agrupacion)))
          WHERE ((d.division = '0'::text) AND (a.tipo_agrupacion = 'INDICE'::text) AND (d.calculo = 0))
          GROUP BY d.periodo, d.calculo, gp.agrupacion, gp.grupo_padre, g.nombregrupo, g.ponderador, g.nivel) x
     LEFT JOIN cvp.calgru_vw c ON (((c.periodo = x.periodo) AND (c.calculo = x.calculo) AND (c.agrupacion = x.agrupacion) AND (c.grupo = x.grupo))))
  ORDER BY ('Z'::text || substr(x.grupo, 2));


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
    COALESCE(p.apellido, NULL::text) AS nombreencuestador,
    v.recepcionista,
    COALESCE(s.apellido, NULL::text) AS nombrerecepcionista,
    v.ingresador,
    COALESCE(n.apellido, NULL::text) AS nombreingresador,
    v.supervisor,
    COALESCE(r.apellido, NULL::text) AS nombresupervisor,
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
     LEFT JOIN cvp.personal p ON ((v.encuestador = p.persona)))
     LEFT JOIN cvp.personal s ON ((v.recepcionista = s.persona)))
     LEFT JOIN cvp.personal n ON ((v.ingresador = n.persona)))
     LEFT JOIN cvp.personal r ON ((v.supervisor = r.persona)))
     LEFT JOIN cvp.periodos o ON ((v.periodo = o.periodo)))
     LEFT JOIN cvp.relvis r_1 ON (((r_1.periodo =
        CASE
            WHEN (v.visita > 1) THEN v.periodo
            ELSE o.periodoanterior
        END) AND (((r_1.ultima_visita = true) AND (v.visita = 1)) OR ((v.visita > 1) AND (r_1.visita = (v.visita - 1)))) AND (r_1.informante = v.informante) AND (r_1.formulario = v.formulario))))
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
            WHEN (NOT (i.tipoinformante IS DISTINCT FROM pd.divisionesdelproducto)) THEN date_trunc('second'::text, i.modi_fec)
            ELSE NULL::timestamp without time zone
        END AS fechamodificacioninformante
   FROM (((((( SELECT DISTINCT relpre.periodo,
            relpre.producto,
            relpre.informante,
            relpre.observacion,
            relpre.modi_fec
           FROM cvp.relpre
          WHERE (relpre.precionormalizado IS NOT NULL)) p
     JOIN cvp.productos o ON ((p.producto = o.producto)))
     JOIN cvp.informantes i ON ((p.informante = i.informante)))
     JOIN cvp.calculos a ON (((p.periodo = a.periodo) AND (a.calculo = 0))))
     LEFT JOIN ( SELECT proddiv.producto,
            string_agg(proddiv.division, ','::text ORDER BY proddiv.division) AS divisionesdelproducto
           FROM cvp.proddiv
          GROUP BY proddiv.producto) pd ON ((p.producto = pd.producto)))
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
          WHERE (calobs.calculo = 0)) c ON (((c.periodo = p.periodo) AND (c.producto = p.producto) AND (c.informante = p.informante) AND (c.observacion = p.observacion))))
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
     JOIN cvp.relpre p ON (((v.periodo = p.periodo) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
     LEFT JOIN cvp.relatr a ON (((a.periodo = p.periodo) AND (a.visita = p.visita) AND (a.informante = p.informante) AND (a.producto = p.producto) AND (a.observacion = p.observacion))))
     LEFT JOIN cvp.atributos atr ON ((atr.atributo = a.atributo)))
  WHERE (((p.precio)::double precision > (0.0)::double precision) AND (a.atributo IS NOT NULL) AND (v.periodo >= 'a2009m05'::text) AND ((a.valor IS NULL) OR ((atr.tipodato = 'N'::text) AND (NOT comun.es_numero(a.valor)))))
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
     LEFT JOIN cvp.relpre p ON (((v.periodo = p.periodo) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
  WHERE ((p.precio IS NULL) AND (p.tipoprecio IS NULL) AND (z.espositivoformulario = 'S'::text))
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
    ((v.encuestador || ':'::text) || pe.apellido) AS encuestador,
    v.recepcionista
   FROM ((((((cvp.relatr ra
     JOIN cvp.prodatr pa ON (((pa.atributo = ra.atributo) AND (pa.producto = ra.producto))))
     JOIN cvp.relpre rp ON (((rp.periodo = ra.periodo) AND (rp.visita = ra.visita) AND (rp.producto = ra.producto) AND (rp.observacion = ra.observacion) AND (rp.informante = ra.informante))))
     JOIN cvp.relvis v ON (((v.periodo = rp.periodo) AND (v.informante = rp.informante) AND (v.visita = rp.visita) AND (v.formulario = rp.formulario))))
     JOIN cvp.personal pe ON ((v.encuestador = pe.persona)))
     JOIN cvp.productos x ON ((x.producto = ra.producto)))
     JOIN cvp.atributos y ON ((y.atributo = ra.atributo)))
  WHERE ((pa.valornormal IS NOT NULL) AND (pa.normalizable = 'S'::text) AND (ra.valor IS NULL) AND (rp.precio IS NOT NULL))
  ORDER BY ra.periodo, ra.producto, ra.observacion, ra.informante, ra.atributo, ra.visita;


ALTER TABLE cvp.control_normalizables_sindato OWNER TO cvpowner;

--
-- Name: control_observaciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.control_observaciones (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    panel integer,
    tarea integer,
    encuestador text,
    nombreencuestador text,
    recepcionista text,
    nombrerecepcionista text,
    rubro integer,
    nombrerubro text,
    formulario integer NOT NULL,
    nombreformulario text,
    comentarios text,
);


ALTER TABLE cvp.control_observaciones OWNER TO cvpowner;

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
          WHERE ((pr.precio)::double precision > (0)::double precision)
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre p_min,
    cvp.relpre p_max,
    cvp.productos p
  WHERE ((p_min.periodo = x.periodo) AND (p_min.producto = x.producto) AND (p_min.precio = x.precio_min) AND (p_max.periodo = x.periodo) AND (p_max.producto = x.producto) AND (p_max.precio = x.precio_max) AND (p.producto = x.producto));


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
          WHERE ((pr.precio)::double precision > (0)::double precision)
          GROUP BY pr.periodo, pr.producto) x,
    cvp.relpre rp,
    cvp.productos p
  WHERE ((rp.periodo = x.periodo) AND (rp.producto = x.producto) AND ((rp.precio = x.precio_min) OR (rp.precio = x.precio_max)) AND (p.producto = x.producto))
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
    round((((round(s.promdiv, 2) / round(s0.promdiv, 2)) * (100)::numeric) - (100)::numeric), 1) AS s_variacion,
    s.cantincluidos AS s_cantincluidos,
    s.cantrealesincluidos AS s_cantrealesincluidos,
    s.cantimputados AS s_cantimputados,
    round((((round(t.promdiv, 2) / round(t0.promdiv, 2)) * (100)::numeric) - (100)::numeric), 1) AS t_variacion,
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
            caldiv.promsinimpext,
            caldiv.promrealessincambio,
            caldiv.promrealessincambioant,
            caldiv.promsinaltasbajas,
            caldiv.promsinaltasbajasant
           FROM cvp.caldiv
          WHERE ((caldiv.division = '0'::text) AND (caldiv.calculo = 0))) o
     LEFT JOIN cvp.periodos r ON ((o.periodo = r.periodo)))
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
            caldiv.promsinimpext,
            caldiv.promrealessincambio,
            caldiv.promrealessincambioant,
            caldiv.promsinaltasbajas,
            caldiv.promsinaltasbajasant
           FROM cvp.caldiv
          WHERE ((caldiv.division = 'S'::text) AND (caldiv.calculo >= 0))) s ON (((o.periodo = s.periodo) AND (o.calculo = s.calculo) AND (o.producto = s.producto))))
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
            caldiv.promsinimpext,
            caldiv.promrealessincambio,
            caldiv.promrealessincambioant,
            caldiv.promsinaltasbajas,
            caldiv.promsinaltasbajasant
           FROM cvp.caldiv
          WHERE ((caldiv.division = 'S'::text) AND (caldiv.calculo >= 0))) s0 ON (((s0.periodo = r.periodoanterior) AND (s0.calculo = s.calculo) AND (s0.producto = s.producto) AND (s0.division = s.division))))
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
            caldiv.promsinimpext,
            caldiv.promrealessincambio,
            caldiv.promrealessincambioant,
            caldiv.promsinaltasbajas,
            caldiv.promsinaltasbajasant
           FROM cvp.caldiv
          WHERE ((caldiv.division = 'T'::text) AND (caldiv.calculo >= 0))) t ON (((s.periodo = t.periodo) AND (s.calculo = t.calculo) AND (s.producto = t.producto))))
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
            caldiv.promsinimpext,
            caldiv.promrealessincambio,
            caldiv.promrealessincambioant,
            caldiv.promsinaltasbajas,
            caldiv.promsinaltasbajasant
           FROM cvp.caldiv
          WHERE ((caldiv.division = 'T'::text) AND (caldiv.calculo >= 0))) t0 ON (((t0.periodo = r.periodoanterior) AND (t.calculo = t0.calculo) AND (t.producto = t0.producto) AND (t.division = t0.division))))
     LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
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
          WHERE ((calgru.esproducto = 'S'::text) AND (calgru.agrupacion = 'Z'::text))) g ON (((g.periodo = o.periodo) AND (g.calculo = o.calculo) AND (g.grupo = o.producto))));


ALTER TABLE cvp.control_productos_para_cierre OWNER TO cvpowner;

--
-- Name: relpan; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relpan (
    periodo text NOT NULL,
    panel integer NOT NULL,
    fechasalida date,
    fechageneracionpanel timestamp without time zone,
    periodoparapanelrotativo text,
    generacionsupervisiones timestamp without time zone,
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
  WHERE ((vis.informante = v2.informante) AND (vis.periodo = v2.periodo) AND (vis.visita = v2.visita) AND (vis.formulario = v2.formulario) AND ((pa.periodoparapanelrotativo = v2.periodo) AND (vis.panel = pa.panel)))
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
    tamannodesvpre numeric DEFAULT 2.5 NOT NULL,
    tamannodesvvar numeric DEFAULT 2.5 NOT NULL,
    codigo text,
    formularionumeracionglobal text,
    soloingresaingresador text DEFAULT 'S'::text,
    pb_desde text,
    pb_hasta text,
    ph_desde text,
    pn_hasta text,
    sup_aleat_prob1 numeric,
    sup_aleat_prob2 numeric,
    sup_aleat_prob_per numeric,
    sup_aleat_prob_pantar numeric,
);


ALTER TABLE cvp.parametros OWNER TO cvpowner;

--
-- Name: prerep; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.prerep (
    periodo text NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
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
     LEFT JOIN cvp.periodos p ON ((r.periodo = p.periodo)))
     LEFT JOIN cvp.relpre r_1 ON (((r_1.periodo =
        CASE
            WHEN (r.visita > 1) THEN r.periodo
            ELSE p.periodoanterior
        END) AND (((r_1.ultima_visita = true) AND (r.visita = 1)) OR ((r.visita > 1) AND (r_1.visita = (r.visita - 1)))) AND (r_1.informante = r.informante) AND (r_1.producto = r.producto) AND (r_1.observacion = r.observacion))));


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
    ((vi.encuestador || ':'::text) || pe.apellido) AS encuestador,
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
    sum((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric)) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    (((vi2.razon)::text || ':'::text) || COALESCE(co.impobs, ' '::text)) AS razon_impobs_ant,
        CASE
            WHEN (min(pr.periodo) IS NOT NULL) THEN 'R'::text
            ELSE NULL::text
        END AS repregunta
   FROM ((((((((((((cvp.relpre_1 v
     JOIN cvp.productos f ON ((v.producto = f.producto)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND (v.periodo = vi.periodo) AND (v.visita = vi.visita) AND (v.formulario = vi.formulario))))
     LEFT JOIN cvp.personal pe ON ((vi.encuestador = pe.persona)))
     LEFT JOIN cvp.personal pc ON ((vi.recepcionista = pc.persona)))
     LEFT JOIN cvp.calobs co ON (((co.periodo = v.periodo_1) AND (co.calculo = 0) AND (co.producto = v.producto) AND (co.informante = v.informante) AND (co.observacion = v.observacion))))
     LEFT JOIN cvp.calobs c2 ON (((c2.periodo = v.periodo) AND (c2.calculo = 0) AND (c2.producto = v.producto) AND (c2.informante = v.informante) AND (c2.observacion = v.observacion))))
     JOIN ( SELECT avg((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::numeric) - (100)::numeric)) AS promvar,
            stddev((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)) * (100)::numeric) - (100)::numeric)) AS desvvar,
            va2.periodo,
            va2.producto
           FROM (cvp.relpre_1 va2
             LEFT JOIN cvp.calobs co2 ON (((co2.periodo = va2.periodo_1) AND (co2.calculo = 0) AND (co2.producto = va2.producto) AND (co2.informante = va2.informante) AND (co2.observacion = va2.observacion))))
          GROUP BY va2.periodo, va2.producto) avgvar ON (((v.periodo = avgvar.periodo) AND (v.producto = avgvar.producto))))
     JOIN cvp.panel_promrotativo avgprot ON (((v.periodo = avgprot.periodo) AND (v.producto = avgprot.producto))))
     JOIN cvp.parametros ON ((parametros.unicoregistro = true)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.prerep pr ON (((v.periodo = pr.periodo) AND (v.informante = pr.informante) AND (v.producto = pr.producto))))
     LEFT JOIN cvp.relvis vi2 ON (((v.informante = vi2.informante) AND (v.periodo_1 = vi2.periodo) AND (v.visita = vi2.visita) AND (v.formulario = vi2.formulario))))
  WHERE (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric) > (avgvar.promvar + (parametros.tamannodesvvar * avgvar.desvvar))) OR (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric) IS DISTINCT FROM (0)::numeric) AND ((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric) < (avgvar.promvar - (parametros.tamannodesvvar * avgvar.desvvar)))) OR (v.precionormalizado > (avgprot.promrotativo + (parametros.tamannodesvpre * avgprot.desvprot))) OR (v.precionormalizado < (avgprot.promrotativo - (parametros.tamannodesvpre * avgprot.desvprot))))
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, ((vi.encuestador || ':'::text) || pe.apellido), vi.recepcionista, pc.apellido, vi.tarea, v.formulario, v.precionormalizado, v.comentariosrelpre, v.observaciones, v.tipoprecio, v.cambio, c2.impobs, v.precionormalizado_1, co.promobs, v.tipoprecio_1, co.antiguedadsinprecio, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, avgprot.desvprot, co.impobs, vi2.razon
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
  WHERE ((vis.informante = v2.informante) AND (vis.periodo = v2.periodo) AND (vis.visita = v2.visita) AND (vis.formulario = v2.formulario) AND (pa.periodoparapanelrotativo = v2.periodo) AND (vis.panel = pa.panel))
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
    sum(((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)))::double precision * (100)::double precision) - (100)::double precision)) AS variac,
    avgvar.promvar,
    avgvar.desvvar,
    avgprot.promrotativo,
    avgprot.desvprot,
    co.impobs AS impobs_1
   FROM ((((((((cvp.relpre_1 v
     JOIN cvp.productos f ON ((v.producto = f.producto)))
     JOIN cvp.relvis vi ON (((v.informante = vi.informante) AND (v.periodo = vi.periodo) AND (v.visita = vi.visita) AND (v.formulario = vi.formulario))))
     LEFT JOIN cvp.calobs co ON (((co.periodo = v.periodo_1) AND (co.calculo = 0) AND (co.producto = v.producto) AND (co.informante = v.informante) AND (co.observacion = v.observacion))))
     LEFT JOIN cvp.calobs c2 ON (((c2.periodo = v.periodo) AND (c2.calculo = 0) AND (c2.producto = v.producto) AND (c2.informante = v.informante) AND (c2.observacion = v.observacion))))
     JOIN ( SELECT avg(((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)))::double precision * (100)::double precision) - (100)::double precision)) AS promvar,
            stddev(((((va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs)))::double precision * (100)::double precision) - (100)::double precision)) AS desvvar,
            va2.periodo,
            va2.producto
           FROM (cvp.relpre_1 va2
             LEFT JOIN cvp.calobs co2 ON (((co2.periodo = va2.periodo_1) AND (co2.calculo = 0) AND (co2.producto = va2.producto) AND (co2.informante = va2.informante) AND (co2.observacion = va2.observacion))))
          GROUP BY va2.periodo, va2.producto) avgvar ON (((v.periodo = avgvar.periodo) AND (v.producto = avgvar.producto))))
     JOIN cvp.panel_promrotativo_mod avgprot ON (((v.periodo = avgprot.periodo) AND (v.producto = avgprot.producto))))
     JOIN cvp.parametros ON ((parametros.unicoregistro = true)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
  WHERE ((((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)))::double precision * (100)::double precision) - (100)::double precision) > (avgvar.promvar + ((parametros.tamannodesvvar)::double precision * avgvar.desvvar))) OR ((((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)))::double precision * (100)::double precision) - (100)::double precision) IS DISTINCT FROM (0)::double precision) AND (((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)))::double precision * (100)::double precision) - (100)::double precision) < (avgvar.promvar - ((parametros.tamannodesvvar)::double precision * avgvar.desvvar)))) OR (v.precionormalizado > (avgprot.promrotativo + (parametros.tamannodesvpre * avgprot.desvprot))) OR (v.precionormalizado < (avgprot.promrotativo - (parametros.tamannodesvpre * avgprot.desvprot))))
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
    COALESCE(((((((i.nombrecalle || ' '::text) || i.altura) || ' '::text) || i.piso) || ' '::text) || i.departamento), i.direccion) AS direccion,
    r.visita,
    ((((r.encuestador || ':'::text) || p.nombre) || ' '::text) || p.apellido) AS encuestador,
    i.rubro,
    u.nombrerubro,
    string_agg((((r.formulario)::text || ':'::text) || f.nombreformulario), '; '::text) AS formularios
   FROM ((((cvp.relvis r
     LEFT JOIN cvp.formularios f ON ((r.formulario = f.formulario)))
     LEFT JOIN cvp.personal p ON ((r.encuestador = p.persona)))
     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
     LEFT JOIN cvp.rubros u ON ((i.rubro = u.rubro)))
  WHERE (u.telefonico = 'S'::text)
  GROUP BY r.periodo, r.panel, r.tarea, r.informante, i.nombreinformante, COALESCE(((((((i.nombrecalle || ' '::text) || i.altura) || ' '::text) || i.piso) || ' '::text) || i.departamento), i.direccion), r.visita, ((((r.encuestador || ':'::text) || p.nombre) || ' '::text) || p.apellido), i.rubro, u.nombrerubro
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
     JOIN cvp.relpre p0 ON (((p0.periodo = cvp.moverperiodos(p.periodo, '-1'::integer)) AND (p.informante = p0.informante) AND (p.visita = p0.visita) AND (p.observacion = p0.observacion) AND (p.producto = p0.producto) AND ((p0.tipoprecio = 'S'::text) OR (p0.tipoprecio IS NULL)))))
     JOIN cvp.relpre p1 ON (((p1.periodo = cvp.moverperiodos(p.periodo, '-2'::integer)) AND (p.informante = p1.informante) AND (p.visita = p1.visita) AND (p.observacion = p1.observacion) AND (p.producto = p1.producto) AND ((p1.tipoprecio = 'S'::text) OR (p1.tipoprecio IS NULL)))))
     JOIN cvp.relpre p2 ON (((p2.periodo = cvp.moverperiodos(p.periodo, '-3'::integer)) AND (p.informante = p2.informante) AND (p.visita = p2.visita) AND (p.observacion = p2.observacion) AND (p.producto = p2.producto) AND ((p2.tipoprecio = 'S'::text) OR (p2.tipoprecio IS NULL)))))
     LEFT JOIN cvp.relvis v ON (((p.periodo = v.periodo) AND (p.informante = v.informante) AND (p.visita = v.visita) AND (p.formulario = v.formulario))))
     LEFT JOIN cvp.informantes i ON ((p.informante = i.informante)))
     LEFT JOIN cvp.productos o ON ((p.producto = o.producto)))
  WHERE (p.tipoprecio = 'S'::text);


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
     JOIN ( SELECT periodos.periodo,
            periodos.ano,
            periodos.mes,
            periodos.visita,
            periodos.ingresando,
            periodos.periodoanterior,
            periodos.fechageneracionperiodo,
            periodos.comentariosper,
            periodos.fechacalculoprereplote1,
            periodos.fechacalculoprereplote2,
            periodos.fecha_cierre_ingreso,
            periodos.cerraringresocampohastapanel,
            periodos.habilitado
           FROM cvp.periodos
          WHERE (periodos.ingresando = 'S'::text)) p ON ((r.periodo = p.periodo)))
     LEFT JOIN cvp.relvis v ON (((r.periodo = v.periodo) AND (r.informante = v.informante) AND (r.formulario = v.formulario) AND (r.visita = v.visita))))
     LEFT JOIN cvp.relpre r_1 ON (((r_1.periodo = cvp.moverperiodos(r.periodo, '-1'::integer)) AND (r.informante = r_1.informante) AND (r.visita = r_1.visita) AND (r.observacion = r_1.observacion) AND (r.producto = r_1.producto))))
     LEFT JOIN cvp.relpre r_2 ON (((r_2.periodo = cvp.moverperiodos(r.periodo, '-2'::integer)) AND (r.informante = r_2.informante) AND (r.visita = r_2.visita) AND (r.observacion = r_2.observacion) AND (r.producto = r_2.producto))))
     LEFT JOIN cvp.relpre r_3 ON (((r_3.periodo = cvp.moverperiodos(r.periodo, '-3'::integer)) AND (r.informante = r_3.informante) AND (r.visita = r_3.visita) AND (r.observacion = r_3.observacion) AND (r.producto = r_3.producto))))
     LEFT JOIN cvp.relpre r_4 ON (((r_4.periodo = cvp.moverperiodos(r.periodo, '-4'::integer)) AND (r.informante = r_4.informante) AND (r.visita = r_4.visita) AND (r.observacion = r_4.observacion) AND (r.producto = r_4.producto))))
     LEFT JOIN cvp.relpre r_5 ON (((r_5.periodo = cvp.moverperiodos(r.periodo, '-5'::integer)) AND (r.informante = r_5.informante) AND (r.visita = r_5.visita) AND (r.observacion = r_5.observacion) AND (r.producto = r_5.producto))))
     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
     LEFT JOIN cvp.productos t ON ((r.producto = t.producto))),
    LATERAL ( SELECT count(*) AS cantprecios
           FROM cvp.relpre
          WHERE ((relpre.informante = r.informante) AND (relpre.producto = r.producto) AND (relpre.visita = r.visita) AND (relpre.observacion = r.observacion) AND (relpre.precionormalizado = r.precionormalizado))) pre
  WHERE ((r.precionormalizado > (0)::numeric) AND (r_1.precionormalizado > (0)::numeric) AND (r_2.precionormalizado > (0)::numeric) AND (r_3.precionormalizado > (0)::numeric) AND (r_4.precionormalizado > (0)::numeric) AND (r_5.precionormalizado > (0)::numeric) AND (r.precionormalizado = r_1.precionormalizado) AND (r_1.precionormalizado = r_2.precionormalizado) AND (r_2.precionormalizado = r_3.precionormalizado) AND (r_3.precionormalizado = r_4.precionormalizado) AND (r_4.precionormalizado = r_5.precionormalizado));


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
            x.visita,
            x.formulario,
            x.panel,
            x.tarea,
            x.fechasalida,
            x.fechaingreso,
            x.encuestador,
            x.ingresador,
            x.recepcionista,
            x.razon,
            x.ultimavisita,
            x.comentarios,
            x.supervisor,
            x.informantereemplazante,
            x.ultima_visita,
            x.verificado_rec,
            x.fechageneracion
           FROM (cvp.perfiltro p_1
             LEFT JOIN cvp.relvis x ON ((p_1.periodo = x.periodo)))
          WHERE (x.razon = 1)) v
     LEFT JOIN cvp.relpre p ON (((v.periodo = p.periodo) AND (v.informante = p.informante) AND (v.formulario = p.formulario) AND (v.visita = p.visita))))
     LEFT JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN cvp.productos o ON ((p.producto = o.producto)))
     LEFT JOIN cvp.tipopre t ON ((p.tipoprecio = t.tipoprecio)))
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
            COALESCE(comun.cuantos_dias_mes(a.periodo, d.valor), 0) AS cantdias,
            date_part('day'::text, (((((substr(cvp.moverperiodos(a.periodo, 1), 2, 4) || '-'::text) || substr(cvp.moverperiodos(a.periodo, 1), 7, 2)) || '-01'::text))::date - '1 day'::interval)) AS ultimodiadelmes,
            (count(DISTINCT a.visita))::integer AS visitas,
            (sum((a.valor)::numeric))::integer AS vigencias,
            string_agg(((COALESCE(p.comentariosrelpre, ' '::text) || ' '::text) || COALESCE(p.observaciones, ' '::text)), ' '::text) AS comentarios
           FROM (((((cvp.relvis r
             LEFT JOIN cvp.relpre p ON (((r.periodo = p.periodo) AND (r.informante = p.informante) AND (r.visita = p.visita) AND (r.formulario = p.formulario))))
             LEFT JOIN cvp.relatr a ON (((p.periodo = a.periodo) AND (p.producto = a.producto) AND (p.observacion = a.observacion) AND (p.informante = a.informante) AND (p.visita = a.visita))))
             LEFT JOIN ( SELECT relatr.periodo,
                    relatr.informante,
                    relatr.visita,
                    relatr.producto,
                    relatr.observacion,
                    relatr.atributo,
                    relatr.valor,
                    relatr.validar_con_valvalatr
                   FROM cvp.relatr
                  WHERE (relatr.atributo = 196)) d ON (((a.periodo = d.periodo) AND (a.producto = d.producto) AND (a.informante = d.informante) AND (a.observacion = d.observacion) AND (a.visita = d.visita))))
             LEFT JOIN cvp.atributos t ON ((a.atributo = t.atributo)))
             LEFT JOIN cvp.productos u ON ((a.producto = u.producto)))
          WHERE (t.es_vigencia AND (r.razon = 1))
          GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, COALESCE(comun.cuantos_dias_mes(a.periodo, d.valor), 0), (date_part('day'::text, (((((substr(cvp.moverperiodos(a.periodo, 1), 2, 4) || '-'::text) || substr(cvp.moverperiodos(a.periodo, 1), 7, 2)) || '-01'::text))::date - '1 day'::interval)))
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
);


ALTER TABLE cvp.cuadros OWNER TO cvpowner;

--
-- Name: cuagru; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.cuagru (
    cuadro text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    orden integer,
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
    sqrt(sum((expr.frec_n * ((co.promobs - expr.prom_aritmetico_pond) ^ (2)::numeric)))) AS desvio
   FROM ((cvp.calobs co
     JOIN cvp.productos prod ON ((prod.producto = co.producto)))
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
                            WHEN (c.division = '0'::text) THEN (1)::numeric
                            ELSE d.ponderadordiv
                        END / (count(*))::numeric) AS frec_n
                   FROM ((cvp.calobs c
                     JOIN ( SELECT gru_grupos.grupo
                           FROM cvp.gru_grupos
                          WHERE ((gru_grupos.agrupacion = 'C'::text) AND (gru_grupos.grupo_padre = ANY (ARRAY['C1'::text, 'C2'::text])) AND (gru_grupos.esproducto = 'S'::text))) gg ON ((c.producto = gg.grupo)))
                     LEFT JOIN cvp.caldiv d ON (((c.periodo = d.periodo) AND (c.calculo = d.calculo) AND (c.division = d.division) AND (c.producto = d.producto))))
                  WHERE ((c.calculo = 0) AND (c.antiguedadincluido > 0) AND (c.promobs <> (0)::numeric))
                  GROUP BY c.periodo, c.calculo, c.producto, c.division,
                        CASE
                            WHEN (c.division = '0'::text) THEN (1)::numeric
                            ELSE d.ponderadordiv
                        END
                  ORDER BY c.periodo, c.calculo, c.producto, c.division,
                        CASE
                            WHEN (c.division = '0'::text) THEN (1)::numeric
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
                                    WHEN (c.division = '0'::text) THEN (1)::numeric
                                    ELSE d.ponderadordiv
                                END AS ponderadordiv,
                            avg(c.promobs) AS prom_aritmetico_pond_div
                           FROM ((cvp.calobs c
                             JOIN ( SELECT gru_grupos.grupo
                                   FROM cvp.gru_grupos
                                  WHERE ((gru_grupos.agrupacion = 'C'::text) AND (gru_grupos.grupo_padre = ANY (ARRAY['C1'::text, 'C2'::text])) AND (gru_grupos.esproducto = 'S'::text))) gg ON ((c.producto = gg.grupo)))
                             LEFT JOIN cvp.caldiv d ON (((c.periodo = d.periodo) AND (c.calculo = d.calculo) AND (c.division = d.division) AND (c.producto = d.producto))))
                          WHERE ((c.calculo = 0) AND (c.antiguedadincluido > 0) AND (c.promobs <> (0)::numeric))
                          GROUP BY c.periodo, c.calculo, c.producto, c.division,
                                CASE
                                    WHEN (c.division = '0'::text) THEN (1)::numeric
                                    ELSE d.ponderadordiv
                                END
                          ORDER BY c.periodo, c.calculo, c.producto, c.division,
                                CASE
                                    WHEN (c.division = '0'::text) THEN (1)::numeric
                                    ELSE d.ponderadordiv
                                END) p
                  GROUP BY p.periodo, p.calculo, p.producto
                  ORDER BY p.periodo, p.calculo, p.producto) pp ON (((f.periodo = pp.periodo) AND (f.calculo = pp.calculo) AND (f.producto = pp.producto))))) expr ON (((co.periodo = expr.periodo) AND (co.calculo = expr.calculo) AND (co.producto = expr.producto) AND (co.division = expr.division))))
  WHERE ((co.antiguedadincluido > 0) AND (co.promobs <> (0)::numeric) AND (prod.calculo_desvios = 'N'::text))
  GROUP BY co.periodo, co.calculo, co.producto, prod.nombreproducto
UNION
 SELECT ca.periodo,
    ca.calculo,
    ca.producto,
    prod.nombreproducto,
    sqrt(sum((f2.frec_n * ((ca.promdiv - f2.prom_aritmetico) ^ (2)::numeric)))) AS desvio
   FROM ((cvp.caldiv ca
     JOIN cvp.productos prod ON ((prod.producto = ca.producto)))
     JOIN ( SELECT caldiv.periodo,
            caldiv.calculo,
            caldiv.producto,
            ((1)::numeric / (count(*))::numeric) AS frec_n,
            avg(caldiv.promdiv) AS prom_aritmetico
           FROM cvp.caldiv
          WHERE ((caldiv.calculo = 0) AND (caldiv.profundidad = 1))
          GROUP BY caldiv.periodo, caldiv.calculo, caldiv.producto) f2 ON (((ca.periodo = f2.periodo) AND (ca.calculo = f2.calculo) AND (ca.producto = f2.producto))))
  WHERE ((prod.calculo_desvios = 'E'::text) AND (ca.calculo = 0) AND (ca.profundidad = 1))
  GROUP BY ca.periodo, ca.calculo, ca.producto, prod.nombreproducto
  ORDER BY 1, 2, 3, 4;


ALTER TABLE cvp.desvios OWNER TO cvpowner;

--
-- Name: divisiones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.divisiones (
    division text NOT NULL,
    nombre_division text,
    incluye_supermercados boolean,
    incluye_tradicionales boolean,
    tipoinformante text,
    sindividir boolean,
    otradivision text,
);


ALTER TABLE cvp.divisiones OWNER TO cvpowner;

--
-- Name: especificaciones; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.especificaciones (
    producto text NOT NULL,
    especificacion integer NOT NULL,
    nombreespecificacion text,
    tamannonormal numeric,
    ponderadoresp numeric DEFAULT '1'::numeric NOT NULL,
    envase text,
    excluir text,
    cantidad numeric,
    unidaddemedida text,
    pesovolumenporunidad numeric,
    destacada boolean,
    mostrar_cant_um text,
    observaciones text,
);


ALTER TABLE cvp.especificaciones OWNER TO cvpowner;

--
-- Name: estadoinformantes; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.estadoinformantes AS
 SELECT periodos.periodo,
    informantes.informante,
    informantes.conjuntomuestral,
    cvp.estadoinformante(periodos.periodo, informantes.informante) AS estadoinformante
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
  WHERE ((fp.producto = p.producto) AND (generate_series.generate_series <= COALESCE(p.cantobs, 2)));


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
    altamanualperiodo text,
);


ALTER TABLE cvp.forinf OWNER TO cvpowner;

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
  WHERE ((fi.formulario = fp.formulario) AND (fp.producto = p.producto) AND (generate_series.generate_series <= COALESCE(fi.cantobs, COALESCE(p.cantobs, 2))));


ALTER TABLE cvp.forobsinf OWNER TO cvpowner;

--
-- Name: freccambio_nivel0; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel0 AS
 SELECT DISTINCT cvp.devolver_mes_anio(x.periodo) AS periodonombre,
    x.periodo,
    substr(x.grupo, 1, 2) AS grupo,
    u.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), u.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), u.nombregrupo, x.estado)) AS promgeoobsant,
    round((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), u.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), u.nombregrupo, x.estado))) * (100)::numeric) - (100)::numeric), 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), x.estado) AS cantobsporestado,
    count(substr(x.grupo, 1, 2)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2))) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2)), x.estado))::numeric / (count(substr(x.grupo, 1, 2)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 2))))::numeric) * (100)::numeric), 2) AS porcobs
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
             LEFT JOIN cvp.calculos c ON (((o.periodo = c.periodo) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON (((o1.periodo = c.periodoanterior) AND (o1.calculo = c.calculoanterior) AND (o.producto = o1.producto) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON ((o.producto = gg.grupo)))
             LEFT JOIN cvp.grupos g ON (((gg.grupo_padre = g.grupo) AND (gg.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
          WHERE ((o.calculo = 0) AND (g.agrupacion = 'Z'::text) AND (g.nivel = 0) AND (o.impobs = 'R'::text) AND (o1.impobs = 'R'::text) AND (g.grupo <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
     LEFT JOIN cvp.grupos u ON ((substr(x.grupo, 1, 2) = u.grupo)))
  WHERE ((x.cantobs > 6) AND (x.periodo >= 'a2017m01'::text))
  ORDER BY x.periodo, (substr(x.grupo, 1, 2)), u.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel0 OWNER TO cvpowner;

--
-- Name: freccambio_nivel1; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel1 AS
 SELECT DISTINCT cvp.devolver_mes_anio(x.periodo) AS periodonombre,
    x.periodo,
    substr(x.grupo, 1, 3) AS grupo,
    u.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), u.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), u.nombregrupo, x.estado)) AS promgeoobsant,
    round((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), u.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), u.nombregrupo, x.estado))) * (100)::numeric) - (100)::numeric), 1) AS variacion,
    count(x.producto) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), x.estado) AS cantobsporestado,
    count(substr(x.grupo, 1, 3)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3))) AS cantobsporgrupo,
    round((((count(x.producto) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3)), x.estado))::numeric / (count(substr(x.grupo, 1, 3)) OVER (PARTITION BY x.periodo, (substr(x.grupo, 1, 3))))::numeric) * (100)::numeric), 2) AS porcobs
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
             LEFT JOIN cvp.calculos c ON (((o.periodo = c.periodo) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON (((o1.periodo = c.periodoanterior) AND (o1.calculo = c.calculoanterior) AND (o.producto = o1.producto) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON ((o.producto = gg.grupo)))
             LEFT JOIN cvp.grupos g ON (((gg.grupo_padre = g.grupo) AND (gg.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
          WHERE ((o.calculo = 0) AND (g.agrupacion = 'Z'::text) AND (g.nivel = 3) AND (o.impobs = 'R'::text) AND (o1.impobs = 'R'::text) AND (g.grupo <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
     LEFT JOIN cvp.grupos u ON ((substr(x.grupo, 1, 3) = u.grupo)))
  WHERE ((x.cantobs > 6) AND (x.periodo >= 'a2017m01'::text))
  ORDER BY x.periodo, (substr(x.grupo, 1, 3)), u.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel1 OWNER TO cvpowner;

--
-- Name: freccambio_nivel3; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_nivel3 AS
 SELECT DISTINCT cvp.devolver_mes_anio(x.periodo) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::numeric) - (100)::numeric), 1) AS variacion,
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
             LEFT JOIN cvp.calculos c ON (((o.periodo = c.periodo) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON (((o1.periodo = c.periodoanterior) AND (o1.calculo = c.calculoanterior) AND (o.producto = o1.producto) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.gru_grupos gg ON ((o.producto = gg.grupo)))
             LEFT JOIN cvp.grupos g ON (((gg.grupo_padre = g.grupo) AND (gg.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
          WHERE ((o.calculo = 0) AND (g.agrupacion = 'Z'::text) AND (g.nivel = 3) AND (o.impobs = 'R'::text) AND (o1.impobs = 'R'::text) AND (g.grupo <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
  WHERE ((x.cantobs > 6) AND (x.periodo >= 'a2017m01'::text))
  ORDER BY x.periodo, x.grupo, x.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_nivel3 OWNER TO cvpowner;

--
-- Name: freccambio_resto; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_resto AS
 SELECT DISTINCT cvp.devolver_mes_anio(x.periodo) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::numeric) - (100)::numeric), 1) AS variacion,
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
             LEFT JOIN cvp.calculos c ON (((o.periodo = c.periodo) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON (((o1.periodo = c.periodoanterior) AND (o1.calculo = c.calculoanterior) AND (o.producto = o1.producto) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
             LEFT JOIN cvp.gru_grupos gu ON (((gu.agrupacion = 'R'::text) AND (gu.esproducto = 'S'::text) AND (gu.grupo = o.producto) AND (length(gu.grupo_padre) = 2))))
             LEFT JOIN cvp.grupos g ON (((gu.grupo_padre = g.grupo) AND (gu.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.gru_grupos gg ON (((gg.agrupacion = 'Z'::text) AND (gg.esproducto = 'S'::text) AND (gg.grupo = o.producto) AND (length(gg.grupo_padre) = 5))))
          WHERE ((o.calculo = 0) AND (g.grupo = 'R3'::text) AND (o.impobs = 'R'::text) AND (o1.impobs = 'R'::text) AND (gg.grupo_padre <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text])))) x
  WHERE ((x.cantobs > 6) AND (x.periodo >= 'a2017m01'::text))
  ORDER BY x.periodo, x.grupo, x.nombregrupo, x.estado;


ALTER TABLE cvp.freccambio_resto OWNER TO cvpowner;

--
-- Name: freccambio_restorest; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.freccambio_restorest AS
 SELECT DISTINCT cvp.devolver_mes_anio(x.periodo) AS periodonombre,
    x.periodo,
    x.grupo,
    x.nombregrupo,
    x.estado,
    exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobs,
    exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) AS promgeoobsant,
    round((((exp(avg(ln(x.promobs)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado)) / exp(avg(ln(x.promobsant)) OVER (PARTITION BY x.periodo, x.grupo, x.nombregrupo, x.estado))) * (100)::numeric) - (100)::numeric), 1) AS variacion,
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
             LEFT JOIN cvp.calculos c ON (((o.periodo = c.periodo) AND (o.calculo = c.calculo))))
             LEFT JOIN cvp.calobs o1 ON (((o1.periodo = c.periodoanterior) AND (o1.calculo = c.calculoanterior) AND (o.producto = o1.producto) AND (o.informante = o1.informante) AND (o.observacion = o1.observacion))))
             LEFT JOIN cvp.productos p ON ((o.producto = p.producto)))
             LEFT JOIN cvp.gru_grupos gu ON (((gu.agrupacion = 'R'::text) AND (gu.esproducto = 'S'::text) AND (gu.grupo = o.producto) AND (length(gu.grupo_padre) = 2))))
             LEFT JOIN cvp.grupos g ON (((gu.grupo_padre = g.grupo) AND (gu.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.gru_grupos gg ON (((gg.agrupacion = 'Z'::text) AND (gg.esproducto = 'S'::text) AND (gg.grupo = o.producto) AND (length(gg.grupo_padre) = 5))))
          WHERE ((o.calculo = 0) AND (g.grupo = 'R3'::text) AND (o.impobs = 'R'::text) AND (o1.impobs = 'R'::text) AND (gg.grupo_padre <> ALL (ARRAY['Z0411'::text, 'Z0431'::text, 'Z0432'::text, 'Z0441'::text, 'Z0442'::text, 'Z0533'::text, 'Z0551'::text, 'Z0552'::text, 'Z0562'::text, 'Z0611'::text, 'Z0621'::text, 'Z0622'::text, 'Z0623'::text, 'Z0711'::text, 'Z0721'::text, 'Z0722'::text, 'Z0723'::text, 'Z0811'::text, 'Z0821'::text, 'Z0822'::text, 'Z0831'::text, 'Z0832'::text, 'Z0833'::text, 'Z0912'::text, 'Z0914'::text, 'Z0915'::text, 'Z0923'::text, 'Z0942'::text, 'Z0951'::text, 'Z1012'::text, 'Z1121'::text, 'Z1212'::text, 'Z1261'::text, 'Z0631'::text, 'Z1011'::text])))) x
  WHERE ((x.cantobs > 6) AND (x.periodo >= 'a2017m01'::text))
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
    string_agg((((c.formulario)::text || ':'::text) || c.nombreformulario), '|'::text) AS formularios,
    ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)) AS contacto,
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
            max(control_hojas_ruta.periodo) AS maxperiodoinformado,
            min(control_hojas_ruta.periodo) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado;


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
    string_agg((((c.formulario)::text || ':'::text) || c.nombreformulario), '|'::text) AS formularios,
    ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)) AS contacto,
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
            max(control_hojas_ruta.periodo) AS maxperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  WHERE (c.razon = ANY (ARRAY[5, 6, 12]))
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, c.visita, c.nombreinformante, c.direccion, ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado;


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
    ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)) AS contacto,
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
            string_agg(DISTINCT COALESCE(relpre.tipoprecio, 'Sin Valor'::text), ';'::text) AS tipoprecios
           FROM cvp.relpre
          GROUP BY relpre.periodo, relpre.informante, relpre.visita, relpre.formulario) p ON (((c.periodo = p.periodo) AND (c.informante = p.informante) AND (c.visita = p.visita) AND (c.formulario = p.formulario))))
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max(control_hojas_ruta.periodo) AS maxperiodoinformado
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
    recepcionista text,
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
    ((((t.encuestador || ':'::text) || p.nombre) || ' '::text) || p.apellido) AS encuestador,
    COALESCE(string_agg(DISTINCT ((c.encuestador || ':'::text) || c.nombreencuestador), '|'::text), NULL::text) AS encuestadores,
    COALESCE(string_agg(DISTINCT ((c.recepcionista || ':'::text) || c.nombrerecepcionista), '|'::text), NULL::text) AS recepcionistas,
    COALESCE(string_agg(DISTINCT ((c.ingresador || ':'::text) || c.nombreingresador), '|'::text), NULL::text) AS ingresadores,
    COALESCE(string_agg(DISTINCT ((c.supervisor || ':'::text) || c.nombresupervisor), '|'::text), NULL::text) AS supervisores,
        CASE
            WHEN (min(c.razon) <> max(c.razon)) THEN ((min(c.razon) || '~'::text) || max(c.razon))
            ELSE COALESCE((min(c.razon) || ''::text), NULL::text)
        END AS razon,
    string_agg((((c.formulario)::text || ' '::text) || c.nombreformulario), chr(10) ORDER BY c.formulario) AS formularioshdr,
    lpad(' '::text, (count(*))::integer, chr(10)) AS espacio,
    c.visita,
    c.nombreinformante,
    c.direccion,
    string_agg((((c.formulario)::text || ':'::text) || c.nombreformulario), '|'::text) AS formularios,
    ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)) AS contacto,
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
     LEFT JOIN cvp.personal p ON ((p.persona = t.encuestador)))
     LEFT JOIN cvp.informantes i ON ((c.informante = i.informante)))
     LEFT JOIN cvp.rubros r ON ((i.rubro = r.rubro)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max(control_hojas_ruta.periodo) AS maxperiodoinformado,
            min(control_hojas_ruta.periodo) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((c.informante = a.informante) AND (c.visita = a.visita))))
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, ((((t.encuestador || ':'::text) || p.nombre) || ' '::text) || p.apellido), c.visita, c.nombreinformante, c.direccion, ((COALESCE(i.contacto, ''::text) || ' '::text) || COALESCE(i.telcontacto, ''::text)), c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida;


ALTER TABLE cvp.hdrexportarteorica OWNER TO cvpowner;

--
-- Name: hogares; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.hogares (
    hogar text NOT NULL,
    nombrehogar text NOT NULL,
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
    (COALESCE((p.nombre || ' '::text), ''::text) || COALESCE(p.apellido, ''::text)) AS nombreencuestador,
    (
        CASE
            WHEN (min(v.razon) <> max(v.razon)) THEN ((min(v.razon) || '~'::text) || max(v.razon))
            ELSE COALESCE((min(v.razon) || ''::text), ''::text)
        END || lpad(' '::text, (count(*))::integer, chr(10))) AS razon,
    v.visita,
    i.nombreinformante,
    i.direccion,
    cvp.formularioshdr(v.periodo, v.informante, v.visita, v.fechasalida, v.encuestador) AS formularios,
    lpad(' '::text, (count(*))::integer, chr(10)) AS espacio,
    ((COALESCE(i.contacto, ''::text) || chr(10)) || COALESCE(i.telcontacto, ''::text)) AS contacto,
    i.conjuntomuestral,
    i.ordenhdr,
    a.maxperiodoinformado,
    a.minperiodoinformado
   FROM (((cvp.relvis v
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     LEFT JOIN cvp.personal p ON ((v.encuestador = p.persona)))
     LEFT JOIN ( SELECT control_hojas_ruta.informante,
            control_hojas_ruta.visita,
            max(control_hojas_ruta.periodo) AS maxperiodoinformado,
            min(control_hojas_ruta.periodo) AS minperiodoinformado
           FROM cvp.control_hojas_ruta
          WHERE (control_hojas_ruta.razon = 1)
          GROUP BY control_hojas_ruta.informante, control_hojas_ruta.visita) a ON (((v.informante = a.informante) AND (v.visita = a.visita))))
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, i.tipoinformante, v.encuestador, v.visita, (COALESCE((p.nombre || ' '::text), ''::text) || COALESCE(p.apellido, ''::text)), ((COALESCE(i.contacto, ''::text) || chr(10)) || COALESCE(i.telcontacto, ''::text)), i.nombreinformante, i.direccion, i.conjuntomuestral, i.ordenhdr, a.maxperiodoinformado, a.minperiodoinformado;


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
    id_instalacion integer,
    cargado timestamp without time zone,
    descargado timestamp without time zone,
    vencimiento_sincronizacion timestamp without time zone,
    puntos integer,
);


ALTER TABLE cvp.reltar OWNER TO cvpowner;

--
-- Name: hojaderutasupervisor; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.hojaderutasupervisor AS
 SELECT p.persona AS supervisor,
    ((p.nombre || ' '::text) || p.apellido) AS nombresupervisor,
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
  WHERE ((r.periodo = h.periodo) AND (r.panel = h.panel) AND (r.tarea = h.tarea) AND (r.encuestador = h.encuestador) AND (r.supervisor IS NOT NULL) AND (r.supervisor = p.persona));


ALTER TABLE cvp.hojaderutasupervisor OWNER TO cvpowner;

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
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL) AND ((zr.escierredefinitivoinf = 'S'::text) OR (zr.escierredefinitivofor = 'S'::text))) THEN ('Alta-Baja en '::text || r.periodo)
                    WHEN ((zr.escierredefinitivoinf = 'S'::text) OR (zr.escierredefinitivofor = 'S'::text)) THEN ('Baja en '::text || r.periodo)
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'Alta'::text
                    WHEN ((zr_1.escierredefinitivoinf = 'S'::text) OR (zr_1.escierredefinitivofor = 'S'::text)) THEN ('Baja en '::text || r_1.periodo)
                    WHEN (r_1.razon IS NULL) THEN ('No ingresado '::text || r_1.periodo)
                    WHEN (r.razon IS NULL) THEN ('No ingresado '::text || r.periodo)
                    ELSE 'Continuo'::text
                END AS tipo,
            i.distrito,
            i.fraccion
           FROM (((((((cvp.relvis r
             LEFT JOIN cvp.periodos p ON ((p.periodo = r.periodo)))
             LEFT JOIN cvp.relvis r_1 ON (((r_1.periodo = p.periodoanterior) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
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
                    WHEN ((zr.escierredefinitivoinf = 'S'::text) OR (zr.escierredefinitivofor = 'S'::text)) THEN ('Baja en '::text || r.periodo)
                    WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'Alta'::text
                    WHEN ((zr_1.escierredefinitivoinf = 'S'::text) OR (zr_1.escierredefinitivofor = 'S'::text)) THEN ('Baja en '::text || r_1.periodo)
                    WHEN (r_1.razon IS NULL) THEN ('No ingresado '::text || r_1.periodo)
                    WHEN (r.razon IS NULL) THEN ('No ingresado '::text || r.periodo)
                    ELSE 'Continuo'::text
                END AS tipo,
            i.distrito,
            i.fraccion
           FROM (((((((cvp.relvis r_1
             LEFT JOIN cvp.periodos p ON ((p.periodoanterior = r_1.periodo)))
             LEFT JOIN cvp.relvis r ON (((r.periodo = p.periodo) AND (r.informante = r_1.informante) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita))))
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
          WHERE (NOT ((s.escierredefinitivoinf = 'S'::text) OR (s.escierredefinitivofor = 'S'::text)))
          GROUP BY v.periodo, v.informante, v.visita) ca ON (((x.periodo = ca.periodo) AND (x.informante = ca.informante) AND (x.visita = ca.visita))))
  WHERE ((x.tipo <> 'Continuo'::text) AND (x.tipo <> ('No ingresado '::text || x.periodo)))
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
                            WHEN ((COALESCE(z.escierredefinitivoinf, 'N'::text) = 'N'::text) AND (COALESCE(z.escierredefinitivofor, 'N'::text) = 'N'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS activos,
                        CASE
                            WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS altas,
                        CASE
                            WHEN ((COALESCE(z.escierredefinitivoinf, 'N'::text) = 'S'::text) OR (COALESCE(z.escierredefinitivofor, 'N'::text) = 'S'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS bajas
                   FROM (((((cvp.relvis r
                     LEFT JOIN cvp.informantes i ON ((r.informante = i.informante)))
                     LEFT JOIN cvp.periodos p ON ((r.periodo = p.periodo)))
                     LEFT JOIN cvp.relvis r_1 ON (((p.periodoanterior = r_1.periodo) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita) AND (r.informante = r_1.informante))))
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
    ((z.nombrerazon || COALESCE(('~'::text || x.nombrerazon), ''::text)))::text AS nombrerazon,
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
  GROUP BY r.periodo, NULLIF(btrim(replace(r.razon, chr(10), ''::text)), ''::text), (((z.nombrerazon || COALESCE(('~'::text || x.nombrerazon), ''::text)))::text)
  ORDER BY r.periodo, NULLIF(btrim(replace(r.razon, chr(10), ''::text)), ''::text), (((z.nombrerazon || COALESCE(('~'::text || x.nombrerazon), ''::text)))::text);


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
                            WHEN ((COALESCE(z.escierredefinitivoinf, 'N'::text) = 'N'::text) AND (COALESCE(z.escierredefinitivofor, 'N'::text) = 'N'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS activos,
                        CASE
                            WHEN ((r_1.periodo IS NULL) AND (r.periodo IS NOT NULL)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS altas,
                        CASE
                            WHEN ((COALESCE(z.escierredefinitivoinf, 'N'::text) = 'S'::text) OR (COALESCE(z.escierredefinitivofor, 'N'::text) = 'S'::text)) THEN 'S'::text
                            ELSE 'N'::text
                        END AS bajas
                   FROM (((((cvp.relvis r
                     LEFT JOIN cvp.periodos p ON ((r.periodo = p.periodo)))
                     LEFT JOIN cvp.relvis r_1 ON (((p.periodoanterior = r_1.periodo) AND (r.formulario = r_1.formulario) AND (r.visita = r_1.visita) AND (r.informante = r_1.informante))))
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
    id_informante_reemplazante integer DEFAULT nextval('cvp.secuencia_informantes_reemplazantes'::regclass) NOT NULL,
    informante integer NOT NULL,
    direccionalternativa text NOT NULL,
    nombreinformantealternativo text,
    comentariorecep text,
    comentarioana text,
    reemplazo integer,
    alta_fec timestamp without time zone,
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
    id_instalacion integer DEFAULT nextval('cvp.secuencia_instalaciones'::regclass) NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    encuestador text NOT NULL,
    ipad text NOT NULL,
    version_sistema text NOT NULL,
    token_original text NOT NULL,
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
    round(col1.promobs, 2) AS promobs_1,
    round(p1.precio, 2) AS precioobservado_1,
    col1.impobs AS impobs_1,
    col1.antiguedadexcluido AS antiguedadexcluido_1,
    col1.antiguedadsinprecio AS antiguedadsinprecio_1,
    col1.antiguedadconprecio AS antiguedadconprecio_1,
    (round((((col1.promobs / col0.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_1,
    p1.tipoprecio AS tipoprecio_1,
    v1.razon AS razon_1,
    round(col2.promobs, 2) AS promobs_2,
    round(p2.precio, 2) AS precioobservado_2,
    col2.impobs AS impobs_2,
    col2.antiguedadexcluido AS antiguedadexcluido_2,
    col2.antiguedadsinprecio AS antiguedadsinprecio_2,
    col2.antiguedadconprecio AS antiguedadconprecio_2,
    (round((((col2.promobs / col1.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_2,
    p2.tipoprecio AS tipoprecio_2,
    v2.razon AS razon_2,
    round(col3.promobs, 2) AS promobs_3,
    round(p3.precio, 2) AS precioobservado_3,
    col3.impobs AS impobs_3,
    col3.antiguedadexcluido AS antiguedadexcluido_3,
    col3.antiguedadsinprecio AS antiguedadsinprecio_3,
    col3.antiguedadconprecio AS antiguedadconprecio_3,
    (round((((col3.promobs / col2.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_3,
    p3.tipoprecio AS tipoprecio_3,
    v3.razon AS razon_3,
    round(col4.promobs, 2) AS promobs_4,
    round(p4.precio, 2) AS precioobservado_4,
    col4.impobs AS impobs_4,
    col4.antiguedadexcluido AS antiguedadexcluido_4,
    col4.antiguedadsinprecio AS antiguedadsinprecio_4,
    col4.antiguedadconprecio AS antiguedadconprecio_4,
    (round((((col4.promobs / col3.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_4,
    p4.tipoprecio AS tipoprecio_4,
    v4.razon AS razon_4,
    round(col5.promobs, 2) AS promobs_5,
    round(p5.precio, 2) AS precioobservado_5,
    col5.impobs AS impobs_5,
    col5.antiguedadexcluido AS antiguedadexcluido_5,
    col5.antiguedadsinprecio AS antiguedadsinprecio_5,
    col5.antiguedadconprecio AS antiguedadconprecio_5,
    (round((((col5.promobs / col4.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_5,
    p5.tipoprecio AS tipoprecio_5,
    v5.razon AS razon_5,
    round(col6.promobs, 2) AS promobs_6,
    round(p6.precio, 2) AS precioobservado_6,
    col6.impobs AS impobs_6,
    col6.antiguedadexcluido AS antiguedadexcluido_6,
    col6.antiguedadsinprecio AS antiguedadsinprecio_6,
    col6.antiguedadconprecio AS antiguedadconprecio_6,
    (round((((col6.promobs / col5.promobs) * (100)::numeric) - (100)::numeric), 1))::numeric(8,1) AS variacion_6,
    p6.tipoprecio AS tipoprecio_6,
    v6.razon AS razon_6,
    cvp.matrizresultados_atributos_fun(p.periodo1, x.informante, x.producto, x.observacion, 1) AS atributo_1,
    cvp.matrizresultados_atributos_fun(p.periodo2, x.informante, x.producto, x.observacion, 1) AS atributo_2,
    cvp.matrizresultados_atributos_fun(p.periodo3, x.informante, x.producto, x.observacion, 1) AS atributo_3,
    cvp.matrizresultados_atributos_fun(p.periodo4, x.informante, x.producto, x.observacion, 1) AS atributo_4,
    cvp.matrizresultados_atributos_fun(p.periodo5, x.informante, x.producto, x.observacion, 1) AS atributo_5,
    cvp.matrizresultados_atributos_fun(p.periodo6, x.informante, x.producto, x.observacion, 1) AS atributo_6,
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
          WHERE (((a.periodo1 IS NULL) OR (r.periodo >= a.periodo1)) AND (r.periodo <= a.periodo6) AND (r.informante = i.informante))
          GROUP BY r.producto, i.tipoinformante, r.informante, r.observacion, a.periodo6) x ON ((x.periodo6 = p.periodo6)))
     LEFT JOIN cvp.calobs col1 ON (((col1.informante = x.informante) AND (col1.observacion = x.observacion) AND (col1.producto = x.producto) AND (col1.periodo = p.periodo1) AND (col1.calculo = 0))))
     LEFT JOIN cvp.calobs col2 ON (((col2.informante = x.informante) AND (col2.observacion = x.observacion) AND (col2.producto = x.producto) AND (col2.periodo = p.periodo2) AND (col2.calculo = 0))))
     LEFT JOIN cvp.calobs col3 ON (((col3.informante = x.informante) AND (col3.observacion = x.observacion) AND (col3.producto = x.producto) AND (col3.periodo = p.periodo3) AND (col3.calculo = 0))))
     LEFT JOIN cvp.calobs col4 ON (((col4.informante = x.informante) AND (col4.observacion = x.observacion) AND (col4.producto = x.producto) AND (col4.periodo = p.periodo4) AND (col4.calculo = 0))))
     LEFT JOIN cvp.calobs col5 ON (((col5.informante = x.informante) AND (col5.observacion = x.observacion) AND (col5.producto = x.producto) AND (col5.periodo = p.periodo5) AND (col5.calculo = 0))))
     LEFT JOIN cvp.calobs col6 ON (((col6.informante = x.informante) AND (col6.observacion = x.observacion) AND (col6.producto = x.producto) AND (col6.periodo = p.periodo6) AND (col6.calculo = 0))))
     LEFT JOIN cvp.relpre p1 ON (((p1.informante = x.informante) AND (p1.observacion = x.observacion) AND (p1.producto = x.producto) AND (p1.visita = 1) AND (p1.periodo = p.periodo1))))
     LEFT JOIN cvp.relpre p2 ON (((p2.informante = x.informante) AND (p2.observacion = x.observacion) AND (p2.producto = x.producto) AND (p2.visita = 1) AND (p2.periodo = p.periodo2))))
     LEFT JOIN cvp.relpre p3 ON (((p3.informante = x.informante) AND (p3.observacion = x.observacion) AND (p3.producto = x.producto) AND (p3.visita = 1) AND (p3.periodo = p.periodo3))))
     LEFT JOIN cvp.relpre p4 ON (((p4.informante = x.informante) AND (p4.observacion = x.observacion) AND (p4.producto = x.producto) AND (p4.visita = 1) AND (p4.periodo = p.periodo4))))
     LEFT JOIN cvp.relpre p5 ON (((p5.informante = x.informante) AND (p5.observacion = x.observacion) AND (p5.producto = x.producto) AND (p5.visita = 1) AND (p5.periodo = p.periodo5))))
     LEFT JOIN cvp.relpre p6 ON (((p6.informante = x.informante) AND (p6.observacion = x.observacion) AND (p6.producto = x.producto) AND (p6.visita = 1) AND (p6.periodo = p.periodo6))))
     LEFT JOIN cvp.relvis v1 ON (((v1.informante = x.informante) AND (v1.formulario = p1.formulario) AND (v1.visita = 1) AND (v1.periodo = p.periodo1))))
     LEFT JOIN cvp.relvis v2 ON (((v2.informante = x.informante) AND (v2.formulario = p2.formulario) AND (v2.visita = 1) AND (v2.periodo = p.periodo2))))
     LEFT JOIN cvp.relvis v3 ON (((v3.informante = x.informante) AND (v3.formulario = p3.formulario) AND (v3.visita = 1) AND (v3.periodo = p.periodo3))))
     LEFT JOIN cvp.relvis v4 ON (((v4.informante = x.informante) AND (v4.formulario = p4.formulario) AND (v4.visita = 1) AND (v4.periodo = p.periodo4))))
     LEFT JOIN cvp.relvis v5 ON (((v5.informante = x.informante) AND (v5.formulario = p5.formulario) AND (v5.visita = 1) AND (v5.periodo = p.periodo5))))
     LEFT JOIN cvp.relvis v6 ON (((v6.informante = x.informante) AND (v6.formulario = p6.formulario) AND (v6.visita = 1) AND (v6.periodo = p.periodo6))))
     LEFT JOIN cvp.periodos p0 ON (((p0.periodo = p.periodo1) AND (p0.periodoanterior <> p.periodo1))))
     LEFT JOIN cvp.calobs col0 ON (((col0.informante = x.informante) AND (col0.observacion = x.observacion) AND (col0.producto = x.producto) AND (col0.periodo = p0.periodoanterior) AND (col0.calculo = 0))));


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
-- Name: monedas; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.monedas (
    moneda text NOT NULL,
    nombre_moneda text,
    es_nacional boolean,
);


ALTER TABLE cvp.monedas OWNER TO cvpowner;

--
-- Name: muestras; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.muestras (
    muestra integer NOT NULL,
    descripcion text,
    alta_inmediata_hasta_periodo text,
);


ALTER TABLE cvp.muestras OWNER TO cvpowner;

--
-- Name: novdelobs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novdelobs (
    periodo text NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    visita integer NOT NULL,
    modi_usu text,
    confirma boolean,
    comentarios text,
);


ALTER TABLE cvp.novdelobs OWNER TO cvpowner;

--
-- Name: novdelvis; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novdelvis (
    periodo text NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    formulario integer NOT NULL,
    modi_usu text,
    confirma boolean,
    comentarios text,
);


ALTER TABLE cvp.novdelvis OWNER TO cvpowner;

--
-- Name: novobs; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novobs (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    modi_usu text,
    estado text NOT NULL,
    revisar_recep boolean,
    comentarios text,
    comentarios_recep text,
);


ALTER TABLE cvp.novobs OWNER TO cvpowner;

--
-- Name: novpre; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novpre (
    periodo text NOT NULL,
    producto text NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    visita integer NOT NULL,
    modi_usu text,
    confirma boolean NOT NULL,
    revisar_recep boolean,
    comentarios text,
    comentarios_recep text,
);


ALTER TABLE cvp.novpre OWNER TO cvpowner;

--
-- Name: novprod; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.novprod (
    periodo text NOT NULL,
    calculo integer NOT NULL,
    producto text NOT NULL,
    promedioext numeric,
    variacion numeric,
);


ALTER TABLE cvp.novprod OWNER TO cvpowner;

--
-- Name: pantar; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.pantar (
    panel integer NOT NULL,
    tarea integer NOT NULL,
    grupozonal text,
    panel2009 integer,
    tamannosupervision integer,
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
     JOIN cvp.periodos per ON ((per.periodo = v.periodo)))
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.rubros rub ON ((rub.rubro = i.rubro)))
     JOIN cvp.forobsinf fo ON (((fo.formulario = v.formulario) AND (i.informante = fo.informante))))
     JOIN cvp.productos d ON ((fo.producto = d.producto)))
     JOIN cvp.especificaciones e ON (((fo.producto = e.producto) AND (fo.especificacion = e.especificacion))))
     LEFT JOIN cvp.relpre p ON (((1 = p.visita) AND (per.periodoanterior = p.periodo) AND (v.informante = p.informante) AND (fo.producto = p.producto) AND (fo.observacion = p.observacion))))
     LEFT JOIN cvp.prodatr t ON ((fo.producto = t.producto)))
     LEFT JOIN cvp.atributos a ON ((a.atributo = t.atributo)))
     LEFT JOIN cvp.relatr ra ON (((p.periodo = ra.periodo) AND (p.producto = ra.producto) AND (p.observacion = ra.observacion) AND (p.informante = ra.informante) AND (p.visita = ra.visita) AND (t.atributo = ra.atributo))))
  WHERE ((fo.dependedeldespacho = 'N'::text) OR (rub.despacho = 'A'::text) OR (fo.observacion = 1))
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
    (substr(fo.producto, 2))::text AS codigo_producto,
    p.cantobs,
    f.soloparatipo,
    f.despacho,
    (((COALESCE((btrim(e.nombreespecificacion) || '. '::text), ''::text) || COALESCE((NULLIF(btrim((COALESCE((btrim(e.envase) || ' '::text), ''::text) ||
        CASE
            WHEN (e.mostrar_cant_um = 'N'::text) THEN ''::text
            ELSE (COALESCE(((e.cantidad)::text || ' '::text), ''::text) || COALESCE(e.unidaddemedida, ''::text))
        END)), ''::text) || '. '::text), ''::text)) || string_agg(
        CASE
            WHEN ((a.tipodato = 'N'::text) AND (a.visible = 'S'::text) AND (t.rangodesde IS NOT NULL) AND (t.rangohasta IS NOT NULL)) THEN ((((((((
            CASE
                WHEN (t.visiblenombreatributo = 'S'::text) THEN (a.nombreatributo || ' '::text)
                ELSE ''::text
            END || 'de '::text) || t.rangodesde) || ' a '::text) || t.rangohasta) || ' '::text) || COALESCE(a.unidaddemedida, a.nombreatributo, ''::text)) ||
            CASE
                WHEN ((t.alterable = 'S'::text) AND (t.normalizable = 'S'::text) AND (NOT ((t.rangodesde <= t.valornormal) AND (t.valornormal <= t.rangohasta)))) THEN (((' ó '::text || t.valornormal) || ' '::text) || a.unidaddemedida)
                ELSE ''::text
            END) || '. '::text)
            ELSE ''::text
        END, ''::text ORDER BY t.orden)) || COALESCE((('Excluir '::text || btrim(e.excluir)) || '. '::text), ''::text)) AS especificacioncompleta,
    fo.dependedeldespacho,
    e.destacada
   FROM ((((((cvp.formularios f
     JOIN cvp.forobs fo ON ((f.formulario = fo.formulario)))
     JOIN cvp.forprod fp ON (((fo.formulario = fp.formulario) AND (fo.producto = fp.producto))))
     JOIN cvp.especificaciones e ON (((fo.producto = e.producto) AND (fo.especificacion = e.especificacion))))
     JOIN cvp.productos p ON ((e.producto = p.producto)))
     LEFT JOIN cvp.prodatr t ON ((fo.producto = t.producto)))
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
    substr(fo.producto, 2) AS codigo_producto,
    i.tipoinformante,
    NULLIF(v.razon, 1) AS razonimpresa,
    f.orden AS ordenformulario,
    (((COALESCE((btrim(e.nombreespecificacion) || '. '::text), ''::text) || COALESCE((NULLIF(btrim((COALESCE((btrim(e.envase) || ' '::text), ''::text) ||
        CASE
            WHEN (e.mostrar_cant_um = 'N'::text) THEN ''::text
            ELSE (COALESCE(((e.cantidad)::text || ' '::text), ''::text) || COALESCE(e.unidaddemedida, ''::text))
        END)), ''::text) || '. '::text), ''::text)) || string_agg(
        CASE
            WHEN ((a.tipodato = 'N'::text) AND (a.visible = 'S'::text) AND (t.rangodesde IS NOT NULL) AND (t.rangohasta IS NOT NULL)) THEN (((((((((
            CASE
                WHEN (t.visiblenombreatributo = 'S'::text) THEN (a.nombreatributo || ' '::text)
                ELSE ''::text
            END || 'de '::text) || t.rangodesde) || ' a '::text) || t.rangohasta) || ' '::text) || COALESCE(a.unidaddemedida, a.nombreatributo, ''::text)) ||
            CASE
                WHEN ((t.alterable = 'S'::text) AND (t.normalizable = 'S'::text) AND (NOT ((t.rangodesde <= t.valornormal) AND (t.valornormal <= t.rangohasta)))) THEN (((' ó '::text || t.valornormal) || ' '::text) || a.unidaddemedida)
                ELSE ''::text
            END) ||
            CASE
                WHEN (t.otraunidaddemedida IS NOT NULL) THEN (('/'::text || t.otraunidaddemedida) || '.'::text)
                ELSE ''::text
            END) || ' '::text)
            ELSE ''::text
        END, ''::text ORDER BY t.orden)) || COALESCE((('Excluir '::text || btrim(e.excluir)) || '. '::text), ''::text)) AS especificacioncompleta,
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
     JOIN cvp.periodos per ON ((per.periodo = v.periodo)))
     JOIN cvp.formularios f ON ((v.formulario = f.formulario)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.rubros rub ON ((rub.rubro = i.rubro)))
     JOIN cvp.forobsinf fo ON (((fo.formulario = v.formulario) AND (fo.informante = i.informante))))
     JOIN cvp.productos d ON ((fo.producto = d.producto)))
     JOIN cvp.especificaciones e ON (((fo.producto = e.producto) AND (fo.especificacion = e.especificacion))))
     LEFT JOIN cvp.relpre p ON (((1 = p.visita) AND (per.periodoanterior = p.periodo) AND (v.informante = p.informante) AND (fo.producto = p.producto) AND (fo.observacion = p.observacion))))
     LEFT JOIN cvp.prodatr t ON ((fo.producto = t.producto)))
     LEFT JOIN cvp.atributos a ON ((a.atributo = t.atributo)))
     LEFT JOIN cvp.prerep prp ON (((per.periodo = prp.periodo) AND (d.producto = prp.producto) AND (i.informante = prp.informante))))
     LEFT JOIN cvp.prerep prpmas1 ON (((cvp.moverperiodos(per.periodo, 1) = prpmas1.periodo) AND (d.producto = prpmas1.producto) AND (i.informante = prpmas1.informante))))
     LEFT JOIN cvp.prerep prpmas2 ON (((cvp.moverperiodos(per.periodo, 2) = prpmas2.periodo) AND (d.producto = prpmas2.producto) AND (i.informante = prpmas2.informante))))
     LEFT JOIN cvp.prerep prpmas3 ON (((cvp.moverperiodos(per.periodo, 3) = prpmas3.periodo) AND (d.producto = prpmas3.producto) AND (i.informante = prpmas3.informante))))
  WHERE ((fo.dependedeldespacho = 'N'::text) OR (rub.despacho = 'A'::text) OR (fo.observacion = 1))
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
                                    cvp.estadoinformante(p.periodo, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE (a.estado = 'Activo'::text)) ac ON (((pc.conjuntomuestral = ac.conjuntomuestral) AND (pc.periodo = ac.periodo))))
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
                                    cvp.estadoinformante(p.periodo, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE (a.estado = 'Inactivo'::text)) re ON (((pc.conjuntomuestral = re.conjuntomuestral) AND (pc.periodo = re.periodo))))) ccm;


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
             LEFT JOIN cvp.relpre_1 rp_1 ON (((rv.periodo = rp_1.periodo) AND (rv.informante = rp_1.informante) AND (rv.visita = rp_1.visita) AND (rv.formulario = rp_1.formulario))))) r
     LEFT JOIN ( SELECT r_2.periodo,
            r_2.informante,
            r_2.visita,
            'S'::text AS razonesnocoherentes
           FROM (cvp.relvis r_2
             LEFT JOIN cvp.razones z_2 ON ((r_2.razon = z_2.razon)))
          GROUP BY r_2.periodo, r_2.informante, r_2.visita
         HAVING (min((COALESCE((z_2.escierredefinitivoinf)::text, 'N'::text))::text) <> max((COALESCE((z_2.escierredefinitivoinf)::text, 'N'::text))::text))) i ON (((r.periodo = i.periodo) AND (r.informante = i.informante) AND (r.visita = i.visita))))
     LEFT JOIN cvp.relvis r_1 ON (((r.periodo_1 = r_1.periodo) AND (r.visita_1 = r_1.visita) AND (r.formulario = r_1.formulario) AND (r.informante = r_1.informante))))
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
                  GROUP BY relpre.periodo, relpre.informante, relpre.visita, relpre.formulario) a ON (((v.periodo = a.periodo) AND (v.informante = a.informante) AND (v.visita = a.visita) AND (v.formulario = a.formulario))))
             LEFT JOIN ( SELECT r_2.periodo,
                    r_2.informante,
                    r_2.visita,
                    r_2.formulario,
                    count(*) AS cantidadprecios
                   FROM (cvp.relpre r_2
                     JOIN cvp.tipopre t ON (((r_2.tipoprecio = t.tipoprecio) AND (((t.espositivo = 'S'::text) AND (r_2.precio IS NOT NULL)) OR ((t.espositivo = 'N'::text) AND (r_2.precio IS NULL))))))
                  GROUP BY r_2.periodo, r_2.informante, r_2.visita, r_2.formulario) b ON (((v.periodo = b.periodo) AND (v.informante = b.informante) AND (v.visita = b.visita) AND (v.formulario = b.formulario))))) c ON (((r.periodo = c.periodo) AND (r.informante = c.informante) AND (r.visita = c.visita) AND (r.formulario = c.formulario))))
     LEFT JOIN ( SELECT p.periodo,
            p.informante,
            p.visita,
            p.formulario,
            count(*) AS atributosnoingresados
           FROM (((cvp.relpre p
             JOIN cvp.relatr a ON (((a.periodo = p.periodo) AND (a.producto = p.producto) AND (a.observacion = p.observacion) AND (a.informante = p.informante) AND (a.visita = p.visita))))
             JOIN cvp.tipopre t ON ((p.tipoprecio = t.tipoprecio)))
             JOIN cvp.prodatr pa ON (((pa.atributo = a.atributo) AND (pa.producto = a.producto))))
          WHERE ((t.espositivo = 'S'::text) AND (a.valor IS NULL) AND (pa.normalizable = 'S'::text))
          GROUP BY p.periodo, p.informante, p.visita, p.formulario) j ON (((r.periodo = j.periodo) AND (r.informante = j.informante) AND (r.visita = j.visita) AND (r.formulario = j.formulario))));


ALTER TABLE cvp.paralistadodecontroldeinformantes OWNER TO cvpowner;

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
                  WHERE (NOT productos.excluir_control_precios_maxmin)) pr ON (true))) a
     LEFT JOIN cvp.periodo_maximos_precios(10) m(periodo, producto, nombreproducto, precios, informantes) ON (((a.periodo = m.periodo) AND (a.producto = m.producto) AND (a.nombreproducto = m.nombreproducto))))
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
                  WHERE (NOT productos.excluir_control_precios_maxmin)) pr ON (true))) a
     LEFT JOIN cvp.periodo_minimos_precios(10) m(periodo, producto, nombreproducto, precios, informantes) ON (((a.periodo = m.periodo) AND (a.producto = m.producto) AND (a.nombreproducto = m.nombreproducto))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.precios_minimos_vw OWNER TO cvpowner;

--
-- Name: precios_porcentaje_positivos_y_anulados; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.precios_porcentaje_positivos_y_anulados (
    periodo text NOT NULL,
    informante integer NOT NULL,
    panel integer,
    tarea integer,
    operativo text,
    formulario text,
    preciospotenciales integer,
    positivos integer,
    anulados integer,
    porcentaje text,
    atributospotenciales integer,
    atributospositivos integer,
    porcatributos text,
);


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
    round(c1.promdiv, 2) AS promprod1,
    round(c2.promdiv, 2) AS promprod2,
    round(c3.promdiv, 2) AS promprod3,
    round(c4.promdiv, 2) AS promprod4,
    round(c5.promdiv, 2) AS promprod5,
    round(c6.promdiv, 2) AS promprod6,
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
             JOIN cvp.grupos g ON (((c.calculo = 0) AND (g.grupo = c.producto) AND (g.esproducto = 'S'::text))))
             JOIN cvp.productos p_1 ON (((g.grupo = p_1.producto) AND (g.esproducto = 'S'::text))))
             JOIN cvp.matrizperiodos6 a ON ((((a.periodo1 IS NULL) OR (c.periodo >= a.periodo1)) AND (c.periodo <= a.periodo6))))
             LEFT JOIN cvp.grupos g2 ON (((g.grupopadre = g2.grupo) AND (g2.agrupacion = g.agrupacion))))
             LEFT JOIN cvp.grupos g3 ON (((g2.grupopadre = g3.grupo) AND (g3.agrupacion = g2.agrupacion))))
          WHERE ((c.calculo = 0) AND (g.esproducto = 'S'::text) AND (g.agrupacion = 'C'::text) AND (c.division = '0'::text))
          GROUP BY c.producto, p_1.nombreproducto, p_1.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre, g2.nombregrupo, g2.grupopadre, g3.nombregrupo) x ON ((x.periodo6 = p.periodo6)))
     LEFT JOIN cvp.caldiv c1 ON (((x.producto = c1.producto) AND (c1.periodo = p.periodo1) AND (c1.calculo = x.calculo) AND (c1.division = '0'::text))))
     LEFT JOIN cvp.caldiv c2 ON (((x.producto = c2.producto) AND (c2.periodo = p.periodo2) AND (c2.calculo = x.calculo) AND (c2.division = '0'::text))))
     LEFT JOIN cvp.caldiv c3 ON (((x.producto = c3.producto) AND (c3.periodo = p.periodo3) AND (c3.calculo = x.calculo) AND (c3.division = '0'::text))))
     LEFT JOIN cvp.caldiv c4 ON (((x.producto = c4.producto) AND (c4.periodo = p.periodo4) AND (c4.calculo = x.calculo) AND (c4.division = '0'::text))))
     LEFT JOIN cvp.caldiv c5 ON (((x.producto = c5.producto) AND (c5.periodo = p.periodo5) AND (c5.calculo = x.calculo) AND (c5.division = '0'::text))))
     LEFT JOIN cvp.caldiv c6 ON (((x.producto = c6.producto) AND (c6.periodo = p.periodo6) AND (c6.calculo = x.calculo) AND (c6.division = '0'::text))))
     LEFT JOIN cvp.periodos p0 ON (((p0.periodo = p.periodo1) AND (p0.periodoanterior <> p.periodo1))))
     LEFT JOIN cvp.caldiv cl0 ON (((x.producto = cl0.producto) AND (cl0.periodo = p0.periodoanterior) AND (cl0.calculo = x.calculo) AND (cl0.division = '0'::text))))
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
    COALESCE((p.nombreparapublicar)::text, (p.nombreproducto)::text) AS nombreproducto,
    p.unidadmedidaabreviada,
    round(c0.promdiv, 2) AS promprodant,
    round(c.promdiv, 2) AS promprod,
        CASE
            WHEN (c0.promdiv = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.promdiv / c0.promdiv) * (100)::numeric) - (100)::numeric), 1)
        END AS variacion,
        CASE
            WHEN (ca.promdiv = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.promdiv / ca.promdiv) * (100)::numeric) - (100)::numeric), 1)
        END AS variaciondiciembre,
        CASE
            WHEN (cm.promdiv = (0)::numeric) THEN NULL::numeric
            ELSE round((((c.promdiv / cm.promdiv) * (100)::numeric) - (100)::numeric), 1)
        END AS variacionmesanioanterior,
    g.agrupacion,
    c.calculo,
    c.periodo,
    c0.calculo AS calculoant,
    c0.periodo AS periodoant,
    ca.periodo AS periododiciembre,
    cm.periodo AS periodoaniooanterior
   FROM ((((((((cvp.caldiv c
     JOIN cvp.grupos g ON (((c.calculo = 0) AND (g.grupo = c.producto) AND (g.esproducto = 'S'::text))))
     JOIN cvp.productos p ON (((g.grupo = p.producto) AND (g.esproducto = 'S'::text))))
     JOIN cvp.calculos pa ON (((c.periodo = pa.periodo) AND ('A'::text = pa.agrupacionprincipal) AND (0 = pa.calculo))))
     JOIN cvp.caldiv c0 ON (((c.producto = c0.producto) AND (c0.calculo = pa.calculoanterior) AND (c0.periodo = pa.periodoanterior) AND (c0.division = '0'::text))))
     LEFT JOIN cvp.caldiv ca ON (((c.producto = ca.producto) AND (c.calculo = ca.calculo) AND (ca.periodo = (('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm12'::text)) AND (ca.division = '0'::text))))
     LEFT JOIN cvp.caldiv cm ON (((c.producto = cm.producto) AND (c.calculo = cm.calculo) AND (cm.periodo = ((('a'::text || ((substr(c.periodo, 2, 4))::integer - 1)) || 'm'::text) || substr(c.periodo, 7, 2))) AND (cm.division = '0'::text))))
     LEFT JOIN cvp.grupos g2 ON (((g.grupopadre = g2.grupo) AND (g2.agrupacion = g.agrupacion))))
     LEFT JOIN cvp.grupos g3 ON (((g2.grupopadre = g3.grupo) AND (g3.agrupacion = g2.agrupacion))))
  WHERE ((c.calculo = 0) AND ((g.esproducto = 'S'::text) AND (g.agrupacion = 'C'::text)) AND (c.division = '0'::text))
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
            string_agg(((s.formulario || ':'::text) || s.nombreformulario), '|'::text) AS formularios,
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
                    string_agg(((d.rubro || ':'::text) || d.nombrerubro), '; '::text) AS rubros,
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
                             LEFT JOIN cvp.prodagr pa ON (((p.producto = pa.producto) AND (pa.agrupacion = 'A'::text))))
                             LEFT JOIN cvp.forprod fp ON ((p.producto = fp.producto)))
                             LEFT JOIN ( SELECT DISTINCT r_1.formulario,
                                    i.rubro
                                   FROM ((cvp.relvis r_1
                                     JOIN cvp.informantes i ON ((r_1.informante = i.informante)))
                                     JOIN ( SELECT max(periodos.periodo) AS per
   FROM cvp.periodos
  WHERE (periodos.ingresando = 'N'::text)) p_1 ON ((r_1.periodo = p_1.per)))) rf ON ((fp.formulario = rf.formulario)))
                             LEFT JOIN cvp.formularios f ON ((fp.formulario = f.formulario)))
                             LEFT JOIN cvp.rubros r ON ((rf.rubro = r.rubro)))
                          WHERE (f.activo = 'S'::text)
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
    orden integer,
);


ALTER TABLE cvp.prodatrval OWNER TO cvpowner;

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
    round(exp(avg(ln(v.precionormalizado))), 2) AS avgp,
    round(min(v.precionormalizado), 2) AS minp,
    round(max(v.precionormalizado), 2) AS maxp,
    round(((exp(avg(ln((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs))))) * (100)::numeric) - (100)::numeric), 1) AS avgv,
    round(min((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric)), 1) AS minv,
    round(max((((v.precionormalizado / COALESCE(v.precionormalizado_1, co.promobs)) * (100)::numeric) - (100)::numeric)), 1) AS maxv,
    sum(
        CASE
            WHEN (ta.espositivo = 'S'::text) THEN 1
            ELSE 0
        END) AS cantreales,
    sum(
        CASE
            WHEN (ta.espositivo = 'N'::text) THEN 1
            ELSE 0
        END) AS cantnegativos,
    sum(
        CASE
            WHEN (COALESCE(v.cambio, '0'::text) = 'C'::text) THEN 1
            ELSE 0
        END) AS cantcambios,
    count(*) AS cantcasos,
    sum(
        CASE
            WHEN (( SELECT ta.espositivo
               FROM cvp.relvis vi
              WHERE ((ta.tipoprecio = COALESCE(v.tipoprecio, '0'::text)) AND (vi.informantereemplazante IS NOT NULL) AND (v.informante = vi.informantereemplazante) AND (v.periodo = vi.periodo) AND (v.visita = vi.visita))) = 'S'::text) THEN 1
            ELSE 0
        END) AS cantreemplazos,
    sum(
        CASE
            WHEN (v.tipoprecio IS NULL) THEN 1
            ELSE 0
        END) AS cantnulos
   FROM (((((cvp.relpre_1 v
     JOIN cvp.productos f ON ((v.producto = f.producto)))
     JOIN cvp.informantes n ON ((v.informante = n.informante)))
     JOIN cvp.rubros r ON ((n.rubro = r.rubro)))
     LEFT JOIN cvp.tipopre ta ON ((ta.tipoprecio = COALESCE(v.tipoprecio, '0'::text))))
     LEFT JOIN cvp.calobs co ON (((v.periodo_1 = co.periodo) AND (co.calculo = 0) AND (v.informante = co.informante) AND (v.producto = co.producto) AND (v.observacion = co.observacion))))
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
    (COALESCE((p.nombre || ' '::text), ''::text) || COALESCE(p.apellido, ''::text)) AS nombreencuestador,
    v.visita,
    regexp_replace(cvp.formularioshdr(v.periodo, v.informante, v.visita, v.fechasalida, v.encuestador), chr(10), ' | '::text, 'g'::text) AS formularios,
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
          WHERE (periodos.ingresando = 'N'::text)
          ORDER BY periodos.periodo DESC
         LIMIT 1) e ON ((v.periodo = e.periodo)))
     JOIN cvp.informantes i ON ((v.informante = i.informante)))
     JOIN cvp.informantes ii ON ((ii.conjuntomuestral = i.conjuntomuestral)))
     JOIN cvp.personal p ON ((v.encuestador = p.persona)))
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
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, ii.conjuntomuestral, v.encuestador, (COALESCE((p.nombre || ' '::text), ''::text) || COALESCE(p.apellido, ''::text)), v.visita,
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
     LEFT JOIN cvp.relpre p_1 ON (((p_1.periodo =
        CASE
            WHEN (r.visita > 1) THEN r.periodo
            ELSE ( SELECT max(relpre.periodo) AS max
               FROM cvp.relpre
              WHERE ((relpre.periodo < r.periodo) AND (relpre.producto = r.producto) AND (relpre.observacion = r.observacion) AND (relpre.informante = r.informante)))
        END) AND (((p_1.ultima_visita = true) AND (r.visita = 1)) OR ((r.visita > 1) AND (p_1.visita = (r.visita - 1)))) AND (p_1.informante = r.informante) AND (p_1.producto = r.producto) AND (p_1.observacion = r.observacion))))
     LEFT JOIN cvp.relatr r_1 ON (((r_1.periodo = p_1.periodo) AND (r_1.visita = p_1.visita) AND (r_1.informante = r.informante) AND (r_1.producto = r.producto) AND (r_1.observacion = r.observacion) AND (r_1.atributo = r.atributo))));


ALTER TABLE cvp.relatr_1 OWNER TO cvpowner;

--
-- Name: relenc; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relenc (
    periodo text NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    encuestador text NOT NULL,
);


ALTER TABLE cvp.relenc OWNER TO cvpowner;

--
-- Name: relinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relinf (
    periodo text NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    informante integer NOT NULL,
    observaciones text,
);


ALTER TABLE cvp.relinf OWNER TO cvpowner;

--
-- Name: relmon; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relmon (
    periodo text NOT NULL,
    moneda text NOT NULL,
    valor_pesos numeric,
);


ALTER TABLE cvp.relmon OWNER TO cvpowner;

--
-- Name: relsup; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.relsup (
    periodo text NOT NULL,
    panel integer NOT NULL,
    supervisor text NOT NULL,
    disponible text,
    motivonodisponible text,
);


ALTER TABLE cvp.relsup OWNER TO cvpowner;

--
-- Name: revisor_parametros; Type: VIEW; Schema: cvp; Owner: cvpowner
--

CREATE VIEW cvp.revisor_parametros AS
 SELECT 'V181010'::text AS versionexigida,
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
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 1) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo1_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 1) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 1) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 1) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo1_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN round((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 1) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END)) * (100)::numeric) - (100)::numeric), 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo1_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 2) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo2_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 2) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 2) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 2) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo2_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN round((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 2) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END)) * (100)::numeric) - (100)::numeric), 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo2_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 3) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo3_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 3) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 3) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 3) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo3_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN round((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 3) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END)) * (100)::numeric) - (100)::numeric), 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo3_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 4) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo4_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 4) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 4) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 4) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo4_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN round((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 4) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END)) * (100)::numeric) - (100)::numeric), 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo4_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 5) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo5_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 5) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 5) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 5) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo5_enc,
            replace((
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN round((((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) / avg(
                    CASE
                        WHEN ((pe.nroperiodo = 5) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END)) * (100)::numeric) - (100)::numeric), 1)
                    ELSE NULL::numeric
                END)::text, '.'::text, '.'::text) AS periodo5_var,
                CASE
                    WHEN (avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END) > (0)::numeric) THEN (max(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (substr(o.estado, 1, 1) = 'B'::text)) THEN (o.estado || 'Manual '::text)
                        ELSE ''::text
                    END) || replace((avg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadincluido > 0)) THEN c.promobs
                        ELSE NULL::numeric
                    END))::text, '.'::text, '.'::text))
                    ELSE ((max(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadexcluido > 0)) THEN 'X '::text
                        ELSE ''::text
                    END) || max(
                    CASE
                        WHEN (pe.nroperiodo = 6) THEN (substr(o.estado, 1, 1) || ' '::text)
                        ELSE ''::text
                    END)) || string_agg(
                    CASE
                        WHEN ((pe.nroperiodo = 6) AND (c.antiguedadexcluido > 0)) THEN replace(substr(comun.a_texto((round(r.precionormalizado, 6))::double precision), 1, (strpos(comun.a_texto((round(r.precionormalizado, 6))::double precision), '.'::text) + 6)), '.'::text, '.'::text)
                        ELSE NULL::text
                    END, ';'::text ORDER BY r.visita))
                END AS periodo6_pr,
            (max(
                CASE
                    WHEN (pe.nroperiodo = 6) THEN
                    CASE
                        WHEN (c.antiguedadincluido > 0) THEN (COALESCE(c.impobs, ''::text) || ':'::text)
                        ELSE 'X:'::text
                    END
                    ELSE NULL::text
                END) || COALESCE(string_agg((
                CASE
                    WHEN (pe.nroperiodo = 6) THEN (((COALESCE(r.tipoprecio, ''::text) || COALESCE((','::text || r.cambio), ''::text)) ||
                    CASE
                        WHEN (r.tipoprecio = 'M'::text) THEN ((COALESCE((' '::text || comun.a_texto((bp.precio)::double precision)), ''::text) || COALESCE((' '::text || bp.tipoprecio), ''::text)) || COALESCE((' '::text || ba.valores), ''::text))
                        ELSE ''::text
                    END) ||
                    CASE
                        WHEN (pat.valorprincipal IS NOT NULL) THEN (' '::text || pat.valorprincipal)
                        ELSE ''::text
                    END)
                    ELSE NULL::text
                END ||
                CASE
                    WHEN (o.estado IS NOT NULL) THEN ((' '::text || o.estado) || 'Manual '::text)
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
                    WHEN (pe.nroperiodo = 6) THEN ((v.encuestador || ':'::text) || per.apellido)
                    ELSE NULL::text
                END)) AS periodo6_enc
           FROM ((((((((cvp.calobs c
             LEFT JOIN ( SELECT (row_number() OVER (ORDER BY p.periodo))::integer AS nroperiodo,
                    p.periodo
                   FROM ( SELECT calculos.periodo
                           FROM cvp.calculos
                          WHERE (calculos.calculo = 0)
                          ORDER BY calculos.periodo DESC
                         LIMIT 6) p) pe ON ((c.periodo = pe.periodo)))
             LEFT JOIN cvp.relpre r ON (((r.informante = c.informante) AND (r.producto = c.producto) AND (r.periodo = c.periodo) AND (r.observacion = c.observacion))))
             LEFT JOIN cvp.relvis v ON (((v.informante = r.informante) AND (v.periodo = r.periodo) AND (v.visita = r.visita) AND (v.formulario = r.formulario))))
             LEFT JOIN cvp.blapre bp ON (((r.informante = bp.informante) AND (r.producto = bp.producto) AND (r.periodo = bp.periodo) AND (r.observacion = bp.observacion) AND (r.visita = bp.visita))))
             LEFT JOIN ( SELECT blaatr.periodo,
                    blaatr.producto,
                    blaatr.informante,
                    blaatr.observacion,
                    blaatr.visita,
                    string_agg(blaatr.valor, ','::text ORDER BY blaatr.atributo) AS valores
                   FROM cvp.blaatr
                  WHERE (blaatr.valor IS NOT NULL)
                  GROUP BY blaatr.periodo, blaatr.producto, blaatr.informante, blaatr.observacion, blaatr.visita) ba ON (((r.informante = ba.informante) AND (r.producto = ba.producto) AND (r.periodo = ba.periodo) AND (r.observacion = ba.observacion) AND (r.visita = ba.visita))))
             LEFT JOIN ( SELECT x_1.periodo,
                    x_1.producto,
                    x_1.informante,
                    x_1.observacion,
                    x_1.visita,
                    string_agg((COALESCE(x_1.valor, ''::text) || COALESCE(a.unidaddemedida, ''::text)), ';'::text ORDER BY x_1.atributo) AS valorprincipal
                   FROM ((cvp.relatr x_1
                     LEFT JOIN cvp.prodatr y ON (((x_1.producto = y.producto) AND (x_1.atributo = y.atributo))))
                     LEFT JOIN cvp.atributos a ON ((y.atributo = a.atributo)))
                  WHERE (y.esprincipal = 'S'::text)
                  GROUP BY x_1.periodo, x_1.producto, x_1.informante, x_1.observacion, x_1.visita) pat ON (((r.informante = pat.informante) AND (r.producto = pat.producto) AND (r.periodo = pat.periodo) AND (r.observacion = pat.observacion) AND (r.visita = pat.visita))))
             LEFT JOIN cvp.personal per ON ((v.encuestador = per.persona)))
             LEFT JOIN cvp.novobs o ON (((c.periodo = o.periodo) AND (c.calculo = o.calculo) AND (c.producto = o.producto) AND (c.informante = o.informante) AND (c.observacion = o.observacion)))),
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
-- Name: tipoinf; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.tipoinf (
    tipoinformante text NOT NULL,
    otrotipoinformante text NOT NULL,
    nombretipoinformante text,
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
-- Name: unidades; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.unidades (
    unidad text NOT NULL,
    magnitud text NOT NULL,
    factor numeric,
    morfologia text,
    abreviaturaestandar text,
);


ALTER TABLE cvp.unidades OWNER TO cvpowner;

--
-- Name: usuarios; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.usuarios (
    usu_usu text NOT NULL,
    usu_rol text,
    usu_clave text,
    usu_activo boolean,
    usu_interno text,
    usu_mail text,
);


ALTER TABLE cvp.usuarios OWNER TO cvpowner;

--
-- Name: valvalatr; Type: TABLE; Schema: cvp; Owner: cvpowner
--

CREATE TABLE cvp.valvalatr (
    producto text NOT NULL,
    atributo integer NOT NULL,
    valor text NOT NULL,
    validar boolean DEFAULT true NOT NULL,
    ponderadoratr numeric,
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
                  WHERE (NOT productos.excluir_control_precios_maxmin)) pr ON (true))) a
     LEFT JOIN cvp.periodo_maximas_variaciones(10) m(periodo, producto, nombreproducto, variaciones, informantes) ON (((a.periodo = m.periodo) AND (a.producto = m.producto) AND (a.nombreproducto = m.nombreproducto))))
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
                  WHERE (NOT productos.excluir_control_precios_maxmin)) pr ON (true))) a
     LEFT JOIN cvp.periodo_minimas_variaciones(10) m(periodo, producto, nombreproducto, variaciones, informantes) ON (((a.periodo = m.periodo) AND (a.producto = m.producto) AND (a.nombreproducto = m.nombreproducto))))
  ORDER BY a.periodo, a.producto, a.nombreproducto;


ALTER TABLE cvp.variaciones_minimas_vw OWNER TO cvpowner;

--
-- Name: agrupaciones agrupaciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.agrupaciones
    ADD CONSTRAINT agrupaciones_pkey PRIMARY KEY (agrupacion);


--
-- Name: atributos atributos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.atributos
    ADD CONSTRAINT atributos_pkey PRIMARY KEY (atributo);


--
-- Name: bitacora bitacora_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.bitacora
    ADD CONSTRAINT bitacora_pkey PRIMARY KEY (id);


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
-- Name: caldiv caldiv_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT caldiv_pkey PRIMARY KEY (periodo, calculo, producto, division);


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
-- Name: conjuntomuestral conjuntomuestral_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.conjuntomuestral
    ADD CONSTRAINT conjuntomuestral_pkey PRIMARY KEY (conjuntomuestral);


--
-- Name: control_observaciones control_observaciones_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.control_observaciones
    ADD CONSTRAINT control_observaciones_pkey PRIMARY KEY (periodo, informante, visita, formulario);


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
-- Name: divisiones divisiones_division_incluye_supermercados_incluye_tradicion_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT divisiones_division_incluye_supermercados_incluye_tradicion_key UNIQUE (division, incluye_supermercados, incluye_tradicionales);


--
-- Name: divisiones divisiones_incluye_supermercados_incluye_tradicionales_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.divisiones
    ADD CONSTRAINT divisiones_incluye_supermercados_incluye_tradicionales_key UNIQUE (incluye_supermercados, incluye_tradicionales);


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
-- Name: informantes informantes_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT informantes_pkey PRIMARY KEY (informante);


--
-- Name: infreemp infreemp_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infreemp
    ADD CONSTRAINT infreemp_pkey PRIMARY KEY (informante, direccionalternativa);


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
    ADD CONSTRAINT novdelobs_pkey PRIMARY KEY (periodo, producto, informante, observacion, visita);


--
-- Name: novdelvis novdelvis_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelvis
    ADD CONSTRAINT novdelvis_pkey PRIMARY KEY (periodo, informante, visita, formulario);


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
-- Name: pantar pantar_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pantar
    ADD CONSTRAINT pantar_pkey PRIMARY KEY (panel, tarea);


--
-- Name: pantar pantar_tarea_grupozonal_panel2009_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.pantar
    ADD CONSTRAINT pantar_tarea_grupozonal_panel2009_key UNIQUE (tarea, grupozonal, panel2009);


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
-- Name: periodos periodos_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.periodos
    ADD CONSTRAINT periodos_pkey PRIMARY KEY (periodo);


--
-- Name: personal personal_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT personal_pkey PRIMARY KEY (persona);


--
-- Name: personal personal_username_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT personal_username_key UNIQUE (username);


--
-- Name: precios_porcentaje_positivos_y_anulados precios_porcentaje_positivos_y_anulados_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.precios_porcentaje_positivos_y_anulados
    ADD CONSTRAINT precios_porcentaje_positivos_y_anulados_pkey PRIMARY KEY (periodo, informante);


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
-- Name: proddiv proddiv_producto_incluye_supermercados_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT proddiv_producto_incluye_supermercados_key UNIQUE (producto, incluye_supermercados);


--
-- Name: proddiv proddiv_producto_incluye_tradicionales_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT proddiv_producto_incluye_tradicionales_key UNIQUE (producto, incluye_tradicionales);


--
-- Name: proddiv proddiv_producto_sindividir_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT proddiv_producto_sindividir_key UNIQUE (producto, sindividir);


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
    ADD CONSTRAINT relinf_pkey PRIMARY KEY (periodo, informante, panel, tarea);


--
-- Name: relmon relmon_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT relmon_pkey PRIMARY KEY (periodo, moneda);


--
-- Name: relpan relpan_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpan
    ADD CONSTRAINT relpan_pkey PRIMARY KEY (periodo, panel);


--
-- Name: relpre relpre_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT relpre_pkey PRIMARY KEY (periodo, producto, observacion, informante, visita);


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
-- Name: rubfor rubfor_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT rubfor_pkey PRIMARY KEY (formulario, rubro);


--
-- Name: rubros rubros_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubros
    ADD CONSTRAINT rubros_pkey PRIMARY KEY (rubro);


--
-- Name: tareas tareas_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tareas
    ADD CONSTRAINT tareas_pkey PRIMARY KEY (tarea);


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
-- Name: unidades unidades_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.unidades
    ADD CONSTRAINT unidades_pkey PRIMARY KEY (unidad);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (usu_usu);


--
-- Name: valvalatr valvalatr_pkey; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT valvalatr_pkey PRIMARY KEY (producto, atributo, valor);


--
-- Name: valvalatr valvalatr_producto_atributo_valor_validar_key; Type: CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT valvalatr_producto_atributo_valor_validar_key UNIQUE (producto, atributo, valor, validar);


--
-- Name: agrupacion 4 calprodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion 4 calprodagr IDX" ON cvp.calprodagr USING btree (agrupacion);


--
-- Name: agrupacion 4 grupos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion 4 grupos IDX" ON cvp.grupos USING btree (agrupacion);


--
-- Name: agrupacion 4 hogparagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion 4 hogparagr IDX" ON cvp.hogparagr USING btree (agrupacion);


--
-- Name: agrupacion 4 prodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion 4 prodagr IDX" ON cvp.prodagr USING btree (agrupacion);


--
-- Name: agrupacion,grupo 4 calhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion,grupo 4 calhoggru IDX" ON cvp.calhoggru USING btree (agrupacion, grupo);


--
-- Name: agrupacion,grupo 4 calhogsubtotales IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion,grupo 4 calhogsubtotales IDX" ON cvp.calhogsubtotales USING btree (agrupacion, grupo);


--
-- Name: agrupacion,grupo 4 cuagru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion,grupo 4 cuagru IDX" ON cvp.cuagru USING btree (agrupacion, grupo);


--
-- Name: agrupacion,grupo 4 parhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion,grupo 4 parhoggru IDX" ON cvp.parhoggru USING btree (agrupacion, grupo);


--
-- Name: agrupacion,grupopadre 4 grupos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacion,grupopadre 4 grupos IDX" ON cvp.grupos USING btree (agrupacion, grupopadre);


--
-- Name: agrupacionorigen 4 grupos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacionorigen 4 grupos IDX" ON cvp.grupos USING btree (agrupacionorigen);


--
-- Name: agrupacionorigen,grupo 4 grupos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "agrupacionorigen,grupo 4 grupos IDX" ON cvp.grupos USING btree (agrupacionorigen, grupo);


--
-- Name: alta_inmediata_hasta_periodo 4 muestras IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "alta_inmediata_hasta_periodo 4 muestras IDX" ON cvp.muestras USING btree (alta_inmediata_hasta_periodo);


--
-- Name: atributo 4 blaatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "atributo 4 blaatr IDX" ON cvp.blaatr USING btree (atributo);


--
-- Name: atributo 4 prodatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "atributo 4 prodatr IDX" ON cvp.prodatr USING btree (atributo);


--
-- Name: atributo 4 relatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "atributo 4 relatr IDX" ON cvp.relatr USING btree (atributo);


--
-- Name: basado_en_extraccion_calculo 4 calculos_def IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "basado_en_extraccion_calculo 4 calculos_def IDX" ON cvp.calculos_def USING btree (basado_en_extraccion_calculo);


--
-- Name: basado_en_extraccion_muestra 4 calculos_def IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "basado_en_extraccion_muestra 4 calculos_def IDX" ON cvp.calculos_def USING btree (basado_en_extraccion_muestra);


--
-- Name: calculo 4 calculos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "calculo 4 calculos IDX" ON cvp.calculos USING btree (calculo);


--
-- Name: calculo 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "calculo 4 calobs IDX" ON cvp.calobs USING btree (calculo);


--
-- Name: calculo 4 calprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "calculo 4 calprod IDX" ON cvp.calprod USING btree (calculo);


--
-- Name: calculo 4 calprodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "calculo 4 calprodagr IDX" ON cvp.calprodagr USING btree (calculo);


--
-- Name: conjuntomuestral 4 informantes IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "conjuntomuestral 4 informantes IDX" ON cvp.informantes USING btree (conjuntomuestral);


--
-- Name: cuadro 4 cuagru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "cuadro 4 cuagru IDX" ON cvp.cuagru USING btree (cuadro);


--
-- Name: division 4 proddiv IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "division 4 proddiv IDX" ON cvp.proddiv USING btree (division);


--
-- Name: encuestador 4 instalaciones IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 instalaciones IDX" ON cvp.instalaciones USING btree (encuestador);


--
-- Name: encuestador 4 relenc IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 relenc IDX" ON cvp.relenc USING btree (encuestador);


--
-- Name: encuestador 4 reltar IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 reltar IDX" ON cvp.reltar USING btree (encuestador);


--
-- Name: encuestador 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 relvis IDX" ON cvp.relvis USING btree (encuestador);


--
-- Name: encuestador 4 tareas IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "encuestador 4 tareas IDX" ON cvp.tareas USING btree (encuestador);


--
-- Name: formulario 4 forinf IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "formulario 4 forinf IDX" ON cvp.forinf USING btree (formulario);


--
-- Name: formulario 4 forprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "formulario 4 forprod IDX" ON cvp.forprod USING btree (formulario);


--
-- Name: formulario 4 novdelvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "formulario 4 novdelvis IDX" ON cvp.novdelvis USING btree (formulario);


--
-- Name: formulario 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "formulario 4 relvis IDX" ON cvp.relvis USING btree (formulario);


--
-- Name: formulario 4 rubfor IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "formulario 4 rubfor IDX" ON cvp.rubfor USING btree (formulario);


--
-- Name: hogar 4 calhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "hogar 4 calhoggru IDX" ON cvp.calhoggru USING btree (hogar);


--
-- Name: hogar 4 calhogsubtotales IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "hogar 4 calhogsubtotales IDX" ON cvp.calhogsubtotales USING btree (hogar);


--
-- Name: hogar 4 hogparagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "hogar 4 hogparagr IDX" ON cvp.hogparagr USING btree (hogar);


--
-- Name: id_instalacion 4 personal IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "id_instalacion 4 personal IDX" ON cvp.personal USING btree (id_instalacion);


--
-- Name: id_instalacion 4 reltar IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "id_instalacion 4 reltar IDX" ON cvp.reltar USING btree (id_instalacion);


--
-- Name: informante 4 blaatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 blaatr IDX" ON cvp.blaatr USING btree (informante);


--
-- Name: informante 4 blapre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 blapre IDX" ON cvp.blapre USING btree (informante);


--
-- Name: informante 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 calobs IDX" ON cvp.calobs USING btree (informante);


--
-- Name: informante 4 forinf IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 forinf IDX" ON cvp.forinf USING btree (informante);


--
-- Name: informante 4 infreemp IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 infreemp IDX" ON cvp.infreemp USING btree (informante);


--
-- Name: informante 4 novdelobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 novdelobs IDX" ON cvp.novdelobs USING btree (informante);


--
-- Name: informante 4 novdelvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 novdelvis IDX" ON cvp.novdelvis USING btree (informante);


--
-- Name: informante 4 novobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 novobs IDX" ON cvp.novobs USING btree (informante);


--
-- Name: informante 4 relatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 relatr IDX" ON cvp.relatr USING btree (informante);


--
-- Name: informante 4 relinf IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 relinf IDX" ON cvp.relinf USING btree (informante);


--
-- Name: informante 4 relpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 relpre IDX" ON cvp.relpre USING btree (informante);


--
-- Name: informante 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "informante 4 relvis IDX" ON cvp.relvis USING btree (informante);


--
-- Name: ingresador 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "ingresador 4 relvis IDX" ON cvp.relvis USING btree (ingresador);


--
-- Name: magnitud 4 unidades IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "magnitud 4 unidades IDX" ON cvp.unidades USING btree (magnitud);


--
-- Name: moneda 4 relmon IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "moneda 4 relmon IDX" ON cvp.relmon USING btree (moneda);


--
-- Name: muestra 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "muestra 4 calobs IDX" ON cvp.calobs USING btree (muestra);


--
-- Name: muestra 4 informantes IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "muestra 4 informantes IDX" ON cvp.informantes USING btree (muestra);


--
-- Name: panel,tarea 4 relenc IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "panel,tarea 4 relenc IDX" ON cvp.relenc USING btree (panel, tarea);


--
-- Name: parametro 4 hogparagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "parametro 4 hogparagr IDX" ON cvp.hogparagr USING btree (parametro);


--
-- Name: parametro 4 parhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "parametro 4 parhoggru IDX" ON cvp.parhoggru USING btree (parametro);


--
-- Name: pb_calculobase 4 calculos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "pb_calculobase 4 calculos IDX" ON cvp.calculos USING btree (pb_calculobase);


--
-- Name: periodo 4 blaatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 blaatr IDX" ON cvp.blaatr USING btree (periodo);


--
-- Name: periodo 4 blapre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 blapre IDX" ON cvp.blapre USING btree (periodo);


--
-- Name: periodo 4 calculos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calculos IDX" ON cvp.calculos USING btree (periodo);


--
-- Name: periodo 4 caldiv IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 caldiv IDX" ON cvp.caldiv USING btree (periodo);


--
-- Name: periodo 4 calgru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calgru IDX" ON cvp.calgru USING btree (periodo);


--
-- Name: periodo 4 calhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calhoggru IDX" ON cvp.calhoggru USING btree (periodo);


--
-- Name: periodo 4 calhogsubtotales IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calhogsubtotales IDX" ON cvp.calhogsubtotales USING btree (periodo);


--
-- Name: periodo 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calobs IDX" ON cvp.calobs USING btree (periodo);


--
-- Name: periodo 4 calprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calprod IDX" ON cvp.calprod USING btree (periodo);


--
-- Name: periodo 4 calprodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calprodagr IDX" ON cvp.calprodagr USING btree (periodo);


--
-- Name: periodo 4 calprodresp IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 calprodresp IDX" ON cvp.calprodresp USING btree (periodo);


--
-- Name: periodo 4 novdelobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 novdelobs IDX" ON cvp.novdelobs USING btree (periodo);


--
-- Name: periodo 4 novdelvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 novdelvis IDX" ON cvp.novdelvis USING btree (periodo);


--
-- Name: periodo 4 novobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 novobs IDX" ON cvp.novobs USING btree (periodo);


--
-- Name: periodo 4 novprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 novprod IDX" ON cvp.novprod USING btree (periodo);


--
-- Name: periodo 4 relatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relatr IDX" ON cvp.relatr USING btree (periodo);


--
-- Name: periodo 4 relenc IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relenc IDX" ON cvp.relenc USING btree (periodo);


--
-- Name: periodo 4 relinf IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relinf IDX" ON cvp.relinf USING btree (periodo);


--
-- Name: periodo 4 relmon IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relmon IDX" ON cvp.relmon USING btree (periodo);


--
-- Name: periodo 4 relpan IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relpan IDX" ON cvp.relpan USING btree (periodo);


--
-- Name: periodo 4 relpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relpre IDX" ON cvp.relpre USING btree (periodo);


--
-- Name: periodo 4 relsup IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relsup IDX" ON cvp.relsup USING btree (periodo);


--
-- Name: periodo 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo 4 relvis IDX" ON cvp.relvis USING btree (periodo);


--
-- Name: periodo,calculo 4 caldiv IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 caldiv IDX" ON cvp.caldiv USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calgru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calgru IDX" ON cvp.calgru USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calhoggru IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calhoggru IDX" ON cvp.calhoggru USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calhogsubtotales IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calhogsubtotales IDX" ON cvp.calhogsubtotales USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calobs IDX" ON cvp.calobs USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calprod IDX" ON cvp.calprod USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calprodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calprodagr IDX" ON cvp.calprodagr USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 calprodresp IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 calprodresp IDX" ON cvp.calprodresp USING btree (periodo, calculo);


--
-- Name: periodo,calculo 4 novobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,calculo 4 novobs IDX" ON cvp.novobs USING btree (periodo, calculo);


--
-- Name: periodo,informante,visita,formulario 4 blapre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,informante,visita,formulario 4 blapre IDX" ON cvp.blapre USING btree (periodo, informante, visita, formulario);


--
-- Name: periodo,informante,visita,formulario 4 relpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,informante,visita,formulario 4 relpre IDX" ON cvp.relpre USING btree (periodo, informante, visita, formulario);


--
-- Name: periodo,panel 4 relsup IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,panel 4 relsup IDX" ON cvp.relsup USING btree (periodo, panel);


--
-- Name: periodo,panel 4 reltar IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,panel 4 reltar IDX" ON cvp.reltar USING btree (periodo, panel);


--
-- Name: periodo,panel 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,panel 4 relvis IDX" ON cvp.relvis USING btree (periodo, panel);


--
-- Name: periodo,producto,observacion,informante,visita 4 blaatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,producto,observacion,informante,visita 4 blaatr IDX" ON cvp.blaatr USING btree (periodo, producto, observacion, informante, visita);


--
-- Name: periodo,producto,observacion,informante,visita 4 novpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,producto,observacion,informante,visita 4 novpre IDX" ON cvp.novpre USING btree (periodo, producto, observacion, informante, visita);


--
-- Name: periodo,producto,observacion,informante,visita 4 relatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodo,producto,observacion,informante,visita 4 relatr IDX" ON cvp.relatr USING btree (periodo, producto, observacion, informante, visita);


--
-- Name: periodoanterior 4 periodos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodoanterior 4 periodos IDX" ON cvp.periodos USING btree (periodoanterior);


--
-- Name: periodoanterior,calculoanterior 4 calculos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "periodoanterior,calculoanterior 4 calculos IDX" ON cvp.calculos USING btree (periodoanterior, calculoanterior);


--
-- Name: producto 4 blaatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 blaatr IDX" ON cvp.blaatr USING btree (producto);


--
-- Name: producto 4 blapre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 blapre IDX" ON cvp.blapre USING btree (producto);


--
-- Name: producto 4 caldiv IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 caldiv IDX" ON cvp.caldiv USING btree (producto);


--
-- Name: producto 4 calobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 calobs IDX" ON cvp.calobs USING btree (producto);


--
-- Name: producto 4 calprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 calprod IDX" ON cvp.calprod USING btree (producto);


--
-- Name: producto 4 calprodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 calprodagr IDX" ON cvp.calprodagr USING btree (producto);


--
-- Name: producto 4 calprodresp IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 calprodresp IDX" ON cvp.calprodresp USING btree (producto);


--
-- Name: producto 4 especificaciones IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 especificaciones IDX" ON cvp.especificaciones USING btree (producto);


--
-- Name: producto 4 forprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 forprod IDX" ON cvp.forprod USING btree (producto);


--
-- Name: producto 4 novdelobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 novdelobs IDX" ON cvp.novdelobs USING btree (producto);


--
-- Name: producto 4 novobs IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 novobs IDX" ON cvp.novobs USING btree (producto);


--
-- Name: producto 4 novprod IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 novprod IDX" ON cvp.novprod USING btree (producto);


--
-- Name: producto 4 prerep IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 prerep IDX" ON cvp.prerep USING btree (producto);


--
-- Name: producto 4 prodagr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 prodagr IDX" ON cvp.prodagr USING btree (producto);


--
-- Name: producto 4 prodatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 prodatr IDX" ON cvp.prodatr USING btree (producto);


--
-- Name: producto 4 proddiv IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 proddiv IDX" ON cvp.proddiv USING btree (producto);


--
-- Name: producto 4 proddivestimac IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 proddivestimac IDX" ON cvp.proddivestimac USING btree (producto);


--
-- Name: producto 4 relatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 relatr IDX" ON cvp.relatr USING btree (producto);


--
-- Name: producto 4 relpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto 4 relpre IDX" ON cvp.relpre USING btree (producto);


--
-- Name: producto,atributo 4 prodatrval IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto,atributo 4 prodatrval IDX" ON cvp.prodatrval USING btree (producto, atributo);


--
-- Name: producto,atributo 4 valvalatr IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto,atributo 4 valvalatr IDX" ON cvp.valvalatr USING btree (producto, atributo);


--
-- Name: producto,division 4 proddivestimac IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "producto,division 4 proddivestimac IDX" ON cvp.proddivestimac USING btree (producto, division);


--
-- Name: razon 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "razon 4 relvis IDX" ON cvp.relvis USING btree (razon);


--
-- Name: recepcionista 4 relvis IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "recepcionista 4 relvis IDX" ON cvp.relvis USING btree (recepcionista);


--
-- Name: rubro 4 informantes IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "rubro 4 informantes IDX" ON cvp.informantes USING btree (rubro);


--
-- Name: rubro 4 rubfor IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "rubro 4 rubfor IDX" ON cvp.rubfor USING btree (rubro);


--
-- Name: soloparatipo 4 formularios IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "soloparatipo 4 formularios IDX" ON cvp.formularios USING btree (soloparatipo);


--
-- Name: supervisor 4 relsup IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "supervisor 4 relsup IDX" ON cvp.relsup USING btree (supervisor);


--
-- Name: supervisor 4 reltar IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "supervisor 4 reltar IDX" ON cvp.reltar USING btree (supervisor);


--
-- Name: tarea 4 reltar IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "tarea 4 reltar IDX" ON cvp.reltar USING btree (tarea);


--
-- Name: tipoinformante 4 informantes IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "tipoinformante 4 informantes IDX" ON cvp.informantes USING btree (tipoinformante);


--
-- Name: tipoinformante 4 rubros IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "tipoinformante 4 rubros IDX" ON cvp.rubros USING btree (tipoinformante);


--
-- Name: tipoprecio 4 blapre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "tipoprecio 4 blapre IDX" ON cvp.blapre USING btree (tipoprecio);


--
-- Name: tipoprecio 4 relpre IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "tipoprecio 4 relpre IDX" ON cvp.relpre USING btree (tipoprecio);


--
-- Name: token 4 locks IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "token 4 locks IDX" ON cvp.locks USING btree (token);


--
-- Name: unidaddemedida 4 atributos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "unidaddemedida 4 atributos IDX" ON cvp.atributos USING btree (unidaddemedida);


--
-- Name: unidaddemedida 4 especificaciones IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "unidaddemedida 4 especificaciones IDX" ON cvp.especificaciones USING btree (unidaddemedida);


--
-- Name: unidadmedidaporunidcons 4 productos IDX; Type: INDEX; Schema: cvp; Owner: cvpowner
--

CREATE INDEX "unidadmedidaporunidcons 4 productos IDX" ON cvp.productos USING btree (unidadmedidaporunidcons);


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
-- Name: calprodresp calprodresp_controlar_revision_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER calprodresp_controlar_revision_trg BEFORE UPDATE ON cvp.calprodresp FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_revision_trg();


--
-- Name: informantes informantes_direccion_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER informantes_direccion_trg BEFORE INSERT OR UPDATE ON cvp.informantes FOR EACH ROW EXECUTE PROCEDURE cvp.generar_direccion_informante_trg();


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
-- Name: novobs novobs_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novobs_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: novobs novobs_existe_observacion_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novobs_existe_observacion_trg BEFORE INSERT ON cvp.novobs FOR EACH ROW EXECUTE PROCEDURE cvp.novobs_validacion_trg();


--
-- Name: novpre novpre_blanquea_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER novpre_blanquea_trg BEFORE UPDATE ON cvp.novpre FOR EACH ROW EXECUTE PROCEDURE cvp.blanquear_precios_trg();


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
-- Name: periodos periodos_controlar_ingresando_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_controlar_ingresando_trg BEFORE UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.validar_ingresando_trg();


--
-- Name: periodos periodos_prerep_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER periodos_prerep_trg BEFORE INSERT OR UPDATE ON cvp.periodos FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_calcularprerep();


--
-- Name: prodatr prodatr_valornormal_mod_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER prodatr_valornormal_mod_trg BEFORE UPDATE ON cvp.prodatr FOR EACH ROW EXECUTE PROCEDURE cvp.prodatr_validamod_valornormal_trg();


--
-- Name: proddiv proddiv_ins_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER proddiv_ins_trg BEFORE INSERT OR UPDATE ON cvp.proddiv FOR EACH ROW EXECUTE PROCEDURE cvp.proddiv_ins_trg();


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
-- Name: relatr relatr_normaliza_precio_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relatr_normaliza_precio_trg AFTER UPDATE ON cvp.relatr FOR EACH ROW EXECUTE PROCEDURE cvp.calcular_precionormaliz_relatr_trg();


--
-- Name: relenc relenc_abi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relenc_abi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relenc FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


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
-- Name: relpan relpan_gen_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpan_gen_trg BEFORE INSERT OR UPDATE ON cvp.relpan FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_panel();


--
-- Name: relpre relpre_act_datos_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_act_datos_trg BEFORE UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_actualizacion_datos_trg();


--
-- Name: relpre relpre_dm_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_dm_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_cargado_dm();


--
-- Name: relpre relpre_existe_visita_1_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relpre_existe_visita_1_trg BEFORE INSERT ON cvp.relpre FOR EACH ROW EXECUTE PROCEDURE cvp.controlar_existencia_visita_1_trg();


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

CREATE TRIGGER reltar_abi_trg BEFORE INSERT OR DELETE OR UPDATE OF supervisor, encuestador, realizada, resultado, observaciones, puntos, cargado, descargado ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_ingresando();


--
-- Name: reltar reltar_modi_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER reltar_modi_trg BEFORE INSERT OR DELETE OR UPDATE ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.modi_trg();


--
-- Name: reltar reltar_verificar_sincronizacion; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER reltar_verificar_sincronizacion BEFORE UPDATE OF vencimiento_sincronizacion ON cvp.reltar FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_sincronizacion();


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


--
-- Name: relvis relvis_gen_trg; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_gen_trg BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.verificar_generar_formulario();


--
-- Name: relvis relvis_genera_reemplazante; Type: TRIGGER; Schema: cvp; Owner: cvpowner
--

CREATE TRIGGER relvis_genera_reemplazante BEFORE UPDATE ON cvp.relvis FOR EACH ROW EXECUTE PROCEDURE cvp.generar_visitas_reemplazo_trg();


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
-- Name: atributos atributos unidades REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.atributos
    ADD CONSTRAINT "atributos unidades REL" FOREIGN KEY (unidaddemedida) REFERENCES cvp.unidades(unidad) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr atributos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT "blaatr atributos REL" FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT "blaatr informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT "blaatr periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT "blaatr productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: blaatr blaatr relpre REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blaatr
    ADD CONSTRAINT "blaatr relpre REL" FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita) ON UPDATE CASCADE;


--
-- Name: blapre blapre informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT "blapre informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: blapre blapre periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT "blapre periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: blapre blapre productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT "blapre productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: blapre blapre relvis REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT "blapre relvis REL" FOREIGN KEY (periodo, informante, visita, formulario) REFERENCES cvp.relvis(periodo, informante, visita, formulario) ON UPDATE CASCADE;


--
-- Name: blapre blapre tipopre REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.blapre
    ADD CONSTRAINT "blapre tipopre REL" FOREIGN KEY (tipoprecio) REFERENCES cvp.tipopre(tipoprecio) ON UPDATE CASCADE;


--
-- Name: calculos calculos cal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT "calculos cal REL" FOREIGN KEY (periodoanterior, calculoanterior) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calculos calculos cal_def REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT "calculos cal_def REL" FOREIGN KEY (pb_calculobase) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos calculos calculos_def REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT "calculos calculos_def REL" FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos calculos periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos
    ADD CONSTRAINT "calculos periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calculos_def calculos_def caldef REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT "calculos_def caldef REL" FOREIGN KEY (basado_en_extraccion_calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calculos_def calculos_def muestras REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calculos_def
    ADD CONSTRAINT "calculos_def muestras REL" FOREIGN KEY (basado_en_extraccion_muestra) REFERENCES cvp.muestras(muestra) ON UPDATE CASCADE;


--
-- Name: caldiv caldiv calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT "caldiv calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: caldiv caldiv periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT "caldiv periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: caldiv caldiv productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.caldiv
    ADD CONSTRAINT "caldiv productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calgru calgru calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT "calgru calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calgru calgru periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calgru
    ADD CONSTRAINT "calgru periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calhoggru calhoggru calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT "calhoggru calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calhoggru calhoggru grupos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT "calhoggru grupos REL" FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: calhoggru calhoggru hogares REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT "calhoggru hogares REL" FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar) ON UPDATE CASCADE;


--
-- Name: calhoggru calhoggru periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhoggru
    ADD CONSTRAINT "calhoggru periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calhogsubtotales calhogsubtotales calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT "calhogsubtotales calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calhogsubtotales calhogsubtotales grupos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT "calhogsubtotales grupos REL" FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: calhogsubtotales calhogsubtotales hogares REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT "calhogsubtotales hogares REL" FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar) ON UPDATE CASCADE;


--
-- Name: calhogsubtotales calhogsubtotales periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calhogsubtotales
    ADD CONSTRAINT "calhogsubtotales periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calobs calobs calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calobs calobs calculos_def REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs calculos_def REL" FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calobs calobs informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: calobs calobs muestras REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs muestras REL" FOREIGN KEY (muestra) REFERENCES cvp.muestras(muestra) ON UPDATE CASCADE;


--
-- Name: calobs calobs periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calobs calobs productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calobs
    ADD CONSTRAINT "calobs productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calprod calprod calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT "calprod calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calprod calprod calculos_def REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT "calprod calculos_def REL" FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calprod calprod periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT "calprod periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calprod calprod productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprod
    ADD CONSTRAINT "calprod productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr agrupaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT "calprodagr agrupaciones REL" FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT "calprodagr calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr calculos_def REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT "calprodagr calculos_def REL" FOREIGN KEY (calculo) REFERENCES cvp.calculos_def(calculo) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT "calprodagr periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calprodagr calprodagr productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodagr
    ADD CONSTRAINT "calprodagr productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: calprodresp calprodresp calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT "calprodresp calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: calprodresp calprodresp periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT "calprodresp periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: calprodresp calprodresp productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.calprodresp
    ADD CONSTRAINT "calprodresp productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: cuagru cuagru cuadros REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuagru
    ADD CONSTRAINT "cuagru cuadros REL" FOREIGN KEY (cuadro) REFERENCES cvp.cuadros(cuadro) ON UPDATE CASCADE;


--
-- Name: cuagru cuagru grupos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.cuagru
    ADD CONSTRAINT "cuagru grupos REL" FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: especificaciones especificaciones productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.especificaciones
    ADD CONSTRAINT "especificaciones productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: especificaciones especificaciones unidades REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.especificaciones
    ADD CONSTRAINT "especificaciones unidades REL" FOREIGN KEY (unidaddemedida) REFERENCES cvp.unidades(unidad) ON UPDATE CASCADE;


--
-- Name: forinf forinf formularios REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT "forinf formularios REL" FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario) ON UPDATE CASCADE;


--
-- Name: forinf forinf informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forinf
    ADD CONSTRAINT "forinf informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: formularios formularios tipoinf REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.formularios
    ADD CONSTRAINT "formularios tipoinf REL" FOREIGN KEY (soloparatipo) REFERENCES cvp.tipoinf(tipoinformante) ON UPDATE CASCADE;


--
-- Name: forprod forprod formularios REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forprod
    ADD CONSTRAINT "forprod formularios REL" FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario) ON UPDATE CASCADE;


--
-- Name: forprod forprod productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.forprod
    ADD CONSTRAINT "forprod productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: grupos grupos agrup REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT "grupos agrup REL" FOREIGN KEY (agrupacionorigen) REFERENCES cvp.agrupaciones(agrupacion) ON UPDATE CASCADE;


--
-- Name: grupos grupos agrupaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT "grupos agrupaciones REL" FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion) ON UPDATE CASCADE;


--
-- Name: grupos grupos gru REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT "grupos gru REL" FOREIGN KEY (agrupacion, grupopadre) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: grupos grupos grup REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.grupos
    ADD CONSTRAINT "grupos grup REL" FOREIGN KEY (agrupacionorigen, grupo) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: hogparagr hogparagr agrupaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT "hogparagr agrupaciones REL" FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion) ON UPDATE CASCADE;


--
-- Name: hogparagr hogparagr hogares REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT "hogparagr hogares REL" FOREIGN KEY (hogar) REFERENCES cvp.hogares(hogar) ON UPDATE CASCADE;


--
-- Name: hogparagr hogparagr parhog REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.hogparagr
    ADD CONSTRAINT "hogparagr parhog REL" FOREIGN KEY (parametro) REFERENCES cvp.parhog(parametro) ON UPDATE CASCADE;


--
-- Name: informantes informantes conjuntomuestral REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT "informantes conjuntomuestral REL" FOREIGN KEY (conjuntomuestral) REFERENCES cvp.conjuntomuestral(conjuntomuestral) ON UPDATE CASCADE;


--
-- Name: informantes informantes muestras REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT "informantes muestras REL" FOREIGN KEY (muestra) REFERENCES cvp.muestras(muestra) ON UPDATE CASCADE;


--
-- Name: informantes informantes rubros REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT "informantes rubros REL" FOREIGN KEY (rubro) REFERENCES cvp.rubros(rubro) ON UPDATE CASCADE;


--
-- Name: informantes informantes tipoinf REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.informantes
    ADD CONSTRAINT "informantes tipoinf REL" FOREIGN KEY (tipoinformante) REFERENCES cvp.tipoinf(tipoinformante) ON UPDATE CASCADE;


--
-- Name: infreemp infreemp informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.infreemp
    ADD CONSTRAINT "infreemp informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


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
-- Name: muestras muestras periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.muestras
    ADD CONSTRAINT "muestras periodos REL" FOREIGN KEY (alta_inmediata_hasta_periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: novdelobs novdelobs informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelobs
    ADD CONSTRAINT "novdelobs informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: novdelobs novdelobs periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelobs
    ADD CONSTRAINT "novdelobs periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: novdelobs novdelobs productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelobs
    ADD CONSTRAINT "novdelobs productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: novdelvis novdelvis formularios REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelvis
    ADD CONSTRAINT "novdelvis formularios REL" FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario) ON UPDATE CASCADE;


--
-- Name: novdelvis novdelvis informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelvis
    ADD CONSTRAINT "novdelvis informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: novdelvis novdelvis periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novdelvis
    ADD CONSTRAINT "novdelvis periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: novobs novobs calculos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT "novobs calculos REL" FOREIGN KEY (periodo, calculo) REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE;


--
-- Name: novobs novobs informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT "novobs informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: novobs novobs periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT "novobs periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: novobs novobs productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novobs
    ADD CONSTRAINT "novobs productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: novpre novpre relpre REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novpre
    ADD CONSTRAINT "novpre relpre REL" FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita) ON UPDATE CASCADE;


--
-- Name: novprod novprod periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novprod
    ADD CONSTRAINT "novprod periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: novprod novprod productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.novprod
    ADD CONSTRAINT "novprod productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: parhoggru parhoggru grupos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhoggru
    ADD CONSTRAINT "parhoggru grupos REL" FOREIGN KEY (agrupacion, grupo) REFERENCES cvp.grupos(agrupacion, grupo) ON UPDATE CASCADE;


--
-- Name: parhoggru parhoggru parhog REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.parhoggru
    ADD CONSTRAINT "parhoggru parhog REL" FOREIGN KEY (parametro) REFERENCES cvp.parhog(parametro) ON UPDATE CASCADE;


--
-- Name: periodos periodos per REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.periodos
    ADD CONSTRAINT "periodos per REL" FOREIGN KEY (periodoanterior) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: personal personal instalaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.personal
    ADD CONSTRAINT "personal instalaciones REL" FOREIGN KEY (id_instalacion) REFERENCES cvp.instalaciones(id_instalacion) ON UPDATE CASCADE;


--
-- Name: prerep prerep productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prerep
    ADD CONSTRAINT "prerep productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: prodagr prodagr agrupaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodagr
    ADD CONSTRAINT "prodagr agrupaciones REL" FOREIGN KEY (agrupacion) REFERENCES cvp.agrupaciones(agrupacion) ON UPDATE CASCADE;


--
-- Name: prodagr prodagr productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodagr
    ADD CONSTRAINT "prodagr productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: prodatr prodatr atributos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT "prodatr atributos REL" FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo) ON UPDATE CASCADE;


--
-- Name: prodatr prodatr productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatr
    ADD CONSTRAINT "prodatr productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: prodatrval prodatrval prodatr REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.prodatrval
    ADD CONSTRAINT "prodatrval prodatr REL" FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo) ON UPDATE CASCADE;


--
-- Name: proddiv proddiv divisiones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "proddiv divisiones REL" FOREIGN KEY (division) REFERENCES cvp.divisiones(division) ON UPDATE CASCADE;


--
-- Name: proddiv proddiv productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddiv
    ADD CONSTRAINT "proddiv productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: proddivestimac proddivestimac proddiv REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddivestimac
    ADD CONSTRAINT "proddivestimac proddiv REL" FOREIGN KEY (producto, division) REFERENCES cvp.proddiv(producto, division) ON UPDATE CASCADE;


--
-- Name: proddivestimac proddivestimac productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.proddivestimac
    ADD CONSTRAINT "proddivestimac productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: productos productos unidades REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.productos
    ADD CONSTRAINT "productos unidades REL" FOREIGN KEY (unidadmedidaporunidcons) REFERENCES cvp.unidades(unidad) ON UPDATE CASCADE;


--
-- Name: relatr relatr atributos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT "relatr atributos REL" FOREIGN KEY (atributo) REFERENCES cvp.atributos(atributo) ON UPDATE CASCADE;


--
-- Name: relatr relatr informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT "relatr informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: relatr relatr periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT "relatr periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relatr relatr productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT "relatr productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: relatr relatr relpre REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relatr
    ADD CONSTRAINT "relatr relpre REL" FOREIGN KEY (periodo, producto, observacion, informante, visita) REFERENCES cvp.relpre(periodo, producto, observacion, informante, visita) ON UPDATE CASCADE;


--
-- Name: relenc relenc pantar REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT "relenc pantar REL" FOREIGN KEY (panel, tarea) REFERENCES cvp.pantar(panel, tarea) ON UPDATE CASCADE;


--
-- Name: relenc relenc periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT "relenc periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relenc relenc personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relenc
    ADD CONSTRAINT "relenc personal REL" FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: relinf relinf informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relinf
    ADD CONSTRAINT "relinf informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: relinf relinf periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relinf
    ADD CONSTRAINT "relinf periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relmon relmon monedas REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT "relmon monedas REL" FOREIGN KEY (moneda) REFERENCES cvp.monedas(moneda) ON UPDATE CASCADE;


--
-- Name: relmon relmon periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relmon
    ADD CONSTRAINT "relmon periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relpan relpan periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpan
    ADD CONSTRAINT "relpan periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relpre relpre informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT "relpre informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: relpre relpre periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT "relpre periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relpre relpre productos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT "relpre productos REL" FOREIGN KEY (producto) REFERENCES cvp.productos(producto) ON UPDATE CASCADE;


--
-- Name: relpre relpre relvis REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT "relpre relvis REL" FOREIGN KEY (periodo, informante, visita, formulario) REFERENCES cvp.relvis(periodo, informante, visita, formulario) ON UPDATE CASCADE;


--
-- Name: relpre relpre tipopre REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relpre
    ADD CONSTRAINT "relpre tipopre REL" FOREIGN KEY (tipoprecio) REFERENCES cvp.tipopre(tipoprecio) ON UPDATE CASCADE;


--
-- Name: relsup relsup periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT "relsup periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relsup relsup personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT "relsup personal REL" FOREIGN KEY (supervisor) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: relsup relsup relpan REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relsup
    ADD CONSTRAINT "relsup relpan REL" FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel) ON UPDATE CASCADE;


--
-- Name: reltar reltar instalaciones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT "reltar instalaciones REL" FOREIGN KEY (id_instalacion) REFERENCES cvp.instalaciones(id_instalacion) ON UPDATE CASCADE;


--
-- Name: reltar reltar pers REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT "reltar pers REL" FOREIGN KEY (supervisor) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: reltar reltar personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT "reltar personal REL" FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: reltar reltar relpan REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT "reltar relpan REL" FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel) ON UPDATE CASCADE;


--
-- Name: reltar reltar tareas REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.reltar
    ADD CONSTRAINT "reltar tareas REL" FOREIGN KEY (tarea) REFERENCES cvp.tareas(tarea) ON UPDATE CASCADE;


--
-- Name: relvis relvis formularios REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis formularios REL" FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario) ON UPDATE CASCADE;


--
-- Name: relvis relvis informantes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis informantes REL" FOREIGN KEY (informante) REFERENCES cvp.informantes(informante) ON UPDATE CASCADE;


--
-- Name: relvis relvis pering REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis pering REL" FOREIGN KEY (ingresador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: relvis relvis periodos REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis periodos REL" FOREIGN KEY (periodo) REFERENCES cvp.periodos(periodo) ON UPDATE CASCADE;


--
-- Name: relvis relvis perrec REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis perrec REL" FOREIGN KEY (recepcionista) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: relvis relvis personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis personal REL" FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: relvis relvis razones REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis razones REL" FOREIGN KEY (razon) REFERENCES cvp.razones(razon) ON UPDATE CASCADE;


--
-- Name: relvis relvis relpan REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.relvis
    ADD CONSTRAINT "relvis relpan REL" FOREIGN KEY (periodo, panel) REFERENCES cvp.relpan(periodo, panel) ON UPDATE CASCADE;


--
-- Name: rubfor rubfor formularios REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT "rubfor formularios REL" FOREIGN KEY (formulario) REFERENCES cvp.formularios(formulario) ON UPDATE CASCADE;


--
-- Name: rubfor rubfor rubros REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubfor
    ADD CONSTRAINT "rubfor rubros REL" FOREIGN KEY (rubro) REFERENCES cvp.rubros(rubro) ON UPDATE CASCADE;


--
-- Name: rubros rubros tipoinf REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.rubros
    ADD CONSTRAINT "rubros tipoinf REL" FOREIGN KEY (tipoinformante) REFERENCES cvp.tipoinf(tipoinformante) ON UPDATE CASCADE;


--
-- Name: tareas tareas personal REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.tareas
    ADD CONSTRAINT "tareas personal REL" FOREIGN KEY (encuestador) REFERENCES cvp.personal(persona) ON UPDATE CASCADE;


--
-- Name: unidades unidades magnitudes REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.unidades
    ADD CONSTRAINT "unidades magnitudes REL" FOREIGN KEY (magnitud) REFERENCES cvp.magnitudes(magnitud) ON UPDATE CASCADE;


--
-- Name: valvalatr valvalatr prodatr REL; Type: FK CONSTRAINT; Schema: cvp; Owner: cvpowner
--

ALTER TABLE ONLY cvp.valvalatr
    ADD CONSTRAINT "valvalatr prodatr REL" FOREIGN KEY (producto, atributo) REFERENCES cvp.prodatr(producto, atributo) ON UPDATE CASCADE;


--
-- Name: TABLE bienvenida; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.bienvenida TO cvp_usuarios;
GRANT SELECT ON TABLE cvp.bienvenida TO cvp_recepcionista;


--
-- Name: TABLE gru_grupos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.gru_grupos TO cvp_administrador;


--
-- Name: TABLE caldiv_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.caldiv_vw TO cvp_administrador;


--
-- Name: TABLE caldivsincambio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.caldivsincambio TO cvp_administrador;


--
-- Name: TABLE calgru_promedios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calgru_promedios TO cvp_administrador;


--
-- Name: TABLE calgru_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calgru_vw TO cvp_administrador;


--
-- Name: TABLE calobs_periodos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calobs_periodos TO cvp_administrador;


--
-- Name: TABLE calobs_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.calobs_vw TO cvp_administrador;


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
-- Name: TABLE canasta_producto; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.canasta_producto TO cvp_administrador;


--
-- Name: TABLE control_ajustes; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_ajustes TO cvp_administrador;


--
-- Name: TABLE control_anulados_recep; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_anulados_recep TO cvp_administrador;


--
-- Name: TABLE control_atributos; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_atributos TO cvp_usuarios;


--
-- Name: TABLE control_calculoresultados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE cvp.control_calculoresultados TO cvp_administrador;


--
-- Name: TABLE control_calobs; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_calobs TO cvp_administrador;


--
-- Name: TABLE control_generacion_formularios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_generacion_formularios TO cvp_usuarios;


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
-- Name: TABLE panel_promrotativo; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.panel_promrotativo TO cvp_usuarios;


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
-- Name: TABLE control_relev_telef; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_relev_telef TO cvp_usuarios;


--
-- Name: TABLE control_sinprecio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_sinprecio TO cvp_recepcionista;


--
-- Name: TABLE control_sinvariacion; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_sinvariacion TO cvp_administrador;


--
-- Name: TABLE perfiltro; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.perfiltro TO cvp_recepcionista;
GRANT SELECT ON TABLE cvp.perfiltro TO cvp_administrador;


--
-- Name: TABLE control_tipoprecio; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.control_tipoprecio TO cvp_administrador;


--
-- Name: TABLE controlvigencias; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.controlvigencias TO cvp_administrador;


--
-- Name: TABLE desvios; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.desvios TO cvp_administrador;


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
-- Name: TABLE hdrexportarteorica; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hdrexportarteorica TO cvp_usuarios;


--
-- Name: TABLE hojaderuta; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hojaderuta TO cvp_usuarios;


--
-- Name: TABLE hojaderutasupervisor; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.hojaderutasupervisor TO cvp_usuarios;


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
-- Name: TABLE matrizresultados; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.matrizresultados TO cvp_administrador;


--
-- Name: TABLE matrizresultadossinvariacion; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.matrizresultadossinvariacion TO cvp_administrador;


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
-- Name: TABLE precios_maximos_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.precios_maximos_vw TO cvp_administrador;


--
-- Name: TABLE precios_minimos_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.precios_minimos_vw TO cvp_administrador;


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
-- Name: TABLE variaciones_maximas_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.variaciones_maximas_vw TO cvp_administrador;


--
-- Name: TABLE variaciones_minimas_vw; Type: ACL; Schema: cvp; Owner: cvpowner
--

GRANT SELECT ON TABLE cvp.variaciones_minimas_vw TO cvp_administrador;


--
-- PostgreSQL database dump complete
--

