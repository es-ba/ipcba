set role to cvpowner;
drop schema if exists "his" cascade;

CREATE SCHEMA his;


ALTER SCHEMA his OWNER TO cvpowner;

SET default_tablespace = '';


CREATE TABLE his.his_campos_cvp (
    esquema text NOT NULL,
    tabla text NOT NULL,
    campo text NOT NULL,
    operacion character varying(1) NOT NULL,
    momento timestamp without time zone DEFAULT statement_timestamp() NOT NULL,
    usuario text DEFAULT "session_user"(),
    concated_pk text NOT NULL,
    change_value text,
    old_text text,
    new_text text,
    old_number double precision,
    new_number double precision,
    old_datetime timestamp without time zone,
    new_datetime timestamp without time zone,
    old_bool boolean,
    new_bool boolean,
    pk_number_1 double precision,
    pk_text_1 text,
    pk_number_2 double precision,
    pk_text_2 text,
    pk_number_3 double precision,
    pk_text_3 text,
    pk_number_4 double precision,
    pk_text_4 text,
    pk_number_5 double precision,
    pk_text_5 text,
    pk_number_6 double precision,
    pk_text_6 text,
    pk_bool_1 boolean
);


ALTER TABLE his.his_campos_cvp OWNER TO cvpowner;


CREATE TABLE his.novobs (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    calculo integer NOT NULL,
    producto character varying(8) NOT NULL,
    informante integer NOT NULL,
    observacion integer NOT NULL,
    estado character varying(18),
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    usuario character varying(30),
    revisar_recep boolean DEFAULT false,
    comentarios text,
    comentarios_recep text
);


ALTER TABLE his.novobs OWNER TO cvpowner;

CREATE TABLE his.novpre (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    producto character varying(8) NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    visita integer DEFAULT 1 NOT NULL,
    confirma boolean DEFAULT true NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    comentarios character varying(200),
    usuario character varying(30),
    revisar_recep boolean DEFAULT false,
    comentarios_recep text
);


ALTER TABLE his.novpre OWNER TO cvpowner;


CREATE TABLE his.novprod (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    calculo integer NOT NULL,
    producto character varying(8) NOT NULL,
    promedioext double precision NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    variacion double precision,
    tipoexterno character varying(1)
);


ALTER TABLE his.novprod OWNER TO cvpowner;


CREATE TABLE his.prerep (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    producto character varying(8) NOT NULL,
    informante integer NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1)
);


ALTER TABLE his.prerep OWNER TO cvpowner;


CREATE TABLE his.relatr (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    producto character varying(8) NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    atributo integer NOT NULL,
    valor character varying(250),
    visita integer DEFAULT 1 NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    validar_con_valvalatr boolean
);


ALTER TABLE his.relatr OWNER TO cvpowner;


CREATE TABLE his.relinf (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    observaciones text,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    panel integer,
    tarea integer,
    fechasalidadesde date,
    fechasalidahasta date
);


ALTER TABLE his.relinf OWNER TO cvpowner;

CREATE TABLE his.relmon (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    moneda character varying(10) NOT NULL,
    valor_pesos double precision,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1)
);


ALTER TABLE his.relmon OWNER TO cvpowner;


CREATE TABLE his.relpan (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(10) NOT NULL,
    panel integer NOT NULL,
    fechasalida date,
    fechageneracionpanel timestamp without time zone,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    periodoparapanelrotativo character varying(11),
    generacionsupervisiones timestamp without time zone,
    fechasalidadesde date,
    fechasalidahasta date
);


ALTER TABLE his.relpan OWNER TO cvpowner;

CREATE TABLE his.relpre (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    producto character varying(8) NOT NULL,
    observacion integer NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    precio double precision,
    tipoprecio character varying(10),
    visita integer DEFAULT 1 NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    comentariosrelpre text,
    cambio character varying(1),
    precionormalizado double precision,
    especificacion integer,
    ultima_visita boolean,
    observaciones text,
    esvisiblecomentarioendm boolean DEFAULT false
);


ALTER TABLE his.relpre OWNER TO cvpowner;

CREATE TABLE his.relsup (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(10) NOT NULL,
    panel integer NOT NULL,
    supervisor character varying(10) NOT NULL,
    disponible cvp.sino_dom,
    motivonodisponible character varying(200),
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1)
);


ALTER TABLE his.relsup OWNER TO cvpowner;

CREATE TABLE his.reltar (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    supervisor character varying(10),
    encuestador character varying(10),
    realizada cvp.sino_dom,
    resultado text,
    observaciones text,
    puntos integer,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    cargado timestamp without time zone,
    descargado timestamp without time zone,
    vencimiento_sincronizacion timestamp without time zone,
    id_instalacion integer,
    vencimiento_sincronizacion2 timestamp without time zone,
    archivo_manifiesto text,
    archivo_estructura text,
    archivo_hdr text,
    datos_descarga jsonb,
    fechasalidadesde date,
    fechasalidahasta date,
    archivo_cache text
);


ALTER TABLE his.reltar OWNER TO cvpowner;

CREATE TABLE his.relvis (
    nue_usu character varying(30),
    nue_ope character varying(1),
    periodo character varying(11) NOT NULL,
    informante integer NOT NULL,
    formulario integer NOT NULL,
    panel integer NOT NULL,
    tarea integer NOT NULL,
    fechasalida date,
    fechaingreso date,
    ingresador character varying(250),
    razon integer,
    fechageneracion timestamp without time zone,
    visita integer DEFAULT 1 NOT NULL,
    ultimavisita integer DEFAULT 1 NOT NULL,
    modi_usu character varying(30),
    modi_fec timestamp without time zone,
    modi_ope character varying(1),
    comentarios character varying(1000),
    encuestador character varying(10),
    supervisor character varying(10),
    recepcionista character varying(10),
    informantereemplazante integer,
    ultima_visita boolean,
    verificado_rec cvp.sino_dom DEFAULT 'N'::character varying,
    preciosgenerados boolean DEFAULT false NOT NULL,
    token_relevamiento text
);


ALTER TABLE his.relvis OWNER TO cvpowner;



ALTER TABLE ONLY his.his_campos_cvp
    ADD CONSTRAINT his_campos_cvp_pkey PRIMARY KEY (esquema, tabla, campo, momento, operacion, concated_pk);


GRANT USAGE ON SCHEMA his TO cvp_administrador;


GRANT SELECT ON TABLE his.his_campos_cvp TO cvp_administrador;


GRANT SELECT ON TABLE his.novobs TO cvp_administrador;


GRANT SELECT ON TABLE his.novpre TO cvp_administrador;


GRANT SELECT ON TABLE his.novprod TO cvp_administrador;

GRANT SELECT,UPDATE ON TABLE his.prerep TO cvp_usuarios;
GRANT SELECT ON TABLE his.prerep TO cvp_recepcionista;

GRANT SELECT ON TABLE his.relatr TO cvp_administrador;


GRANT SELECT ON TABLE his.relinf TO cvp_administrador;

GRANT SELECT ON TABLE his.relmon TO cvp_administrador;

GRANT SELECT ON TABLE his.relpan TO cvp_administrador;

GRANT SELECT ON TABLE his.relpre TO cvp_administrador;

GRANT SELECT,UPDATE ON TABLE his.relsup TO cvp_administrador;

GRANT SELECT ON TABLE his.reltar TO cvp_administrador;

GRANT SELECT ON TABLE his.relvis TO cvp_administrador;
