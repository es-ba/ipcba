set role to cvpowner;
drop schema if exists "ipcba" cascade;

CREATE SCHEMA ipcba;


ALTER SCHEMA ipcba OWNER TO cvpowner;

SET default_tablespace = '';

CREATE TABLE ipcba.bitacora (
    bit_ope text,
    bit_bit integer NOT NULL,
    bit_proceso text,
    bit_parametros text,
    bit_resultado text,
    bit_inicio timestamp without time zone DEFAULT now(),
    bit_fin timestamp without time zone,
    bit_valor_respuesta boolean,
    bit_tlg bigint NOT NULL
);


ALTER TABLE ipcba.bitacora OWNER TO cvpowner;

CREATE SEQUENCE ipcba.bitacora_bit_bit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ipcba.bitacora_bit_bit_seq OWNER TO cvpowner;

ALTER SEQUENCE ipcba.bitacora_bit_bit_seq OWNED BY ipcba.bitacora.bit_bit;

CREATE TABLE ipcba.http_user_agent (
    httpua_httpua integer NOT NULL,
    httpua_texto text NOT NULL
);


ALTER TABLE ipcba.http_user_agent OWNER TO cvpowner;

CREATE SEQUENCE ipcba.http_user_agent_httpua_httpua_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ipcba.http_user_agent_httpua_httpua_seq OWNER TO cvpowner;

ALTER SEQUENCE ipcba.http_user_agent_httpua_httpua_seq OWNED BY ipcba.http_user_agent.httpua_httpua;


CREATE TABLE ipcba.rol_rol (
    rolrol_principal character varying(30) NOT NULL,
    rolrol_delegado character varying(30) NOT NULL,
    rolrol_tlg bigint NOT NULL
);


ALTER TABLE ipcba.rol_rol OWNER TO cvpowner;

CREATE TABLE ipcba.roles (
    rol_rol character varying(30) NOT NULL,
    rol_descripcion character varying(200),
    rol_tlg bigint NOT NULL,
    rol_ver_con_hasta_nivel integer
);


ALTER TABLE ipcba.roles OWNER TO cvpowner;

CREATE TABLE ipcba.sesiones (
    ses_ses bigint NOT NULL,
    ses_usu character varying(30) NOT NULL,
    ses_momento timestamp without time zone DEFAULT now(),
    ses_borro_localstorage boolean NOT NULL,
    ses_activa boolean DEFAULT true NOT NULL,
    ses_phpsessid character varying(100) NOT NULL,
    ses_httpua integer NOT NULL,
    ses_remote_addr character varying(100) NOT NULL,
    ses_momento_finalizada timestamp without time zone,
    ses_razon_finalizada text
);


ALTER TABLE ipcba.sesiones OWNER TO cvpowner;

CREATE SEQUENCE ipcba.sesiones_ses_ses_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ipcba.sesiones_ses_ses_seq OWNER TO cvpowner;

ALTER SEQUENCE ipcba.sesiones_ses_ses_seq OWNED BY ipcba.sesiones.ses_ses;


CREATE TABLE ipcba.tiempo_logico (
    tlg_tlg bigint NOT NULL,
    tlg_ses bigint,
    tlg_momento timestamp without time zone DEFAULT now(),
    tlg_momento_finalizada timestamp without time zone
);


ALTER TABLE ipcba.tiempo_logico OWNER TO cvpowner;

CREATE SEQUENCE ipcba.tiempo_logico_tlg_tlg_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ipcba.tiempo_logico_tlg_tlg_seq OWNER TO cvpowner;

ALTER SEQUENCE ipcba.tiempo_logico_tlg_tlg_seq OWNED BY ipcba.tiempo_logico.tlg_tlg;


CREATE TABLE ipcba.usuarios (
    usu_usu character varying(30) NOT NULL,
    usu_rol character varying(30),
    usu_clave character varying(50),
    usu_activo boolean DEFAULT false NOT NULL,
    usu_nombre character varying(100),
    usu_apellido character varying(100),
    usu_blanquear_clave boolean DEFAULT false NOT NULL,
    usu_interno character varying(30),
    usu_mail character varying(200),
    usu_mail_alternativo character varying(200),
    usu_rol_secundario character varying(30),
    usu_tlg bigint NOT NULL
);


ALTER TABLE ipcba.usuarios OWNER TO cvpowner;

ALTER TABLE ONLY ipcba.bitacora ALTER COLUMN bit_bit SET DEFAULT nextval('ipcba.bitacora_bit_bit_seq'::regclass);


ALTER TABLE ONLY ipcba.http_user_agent ALTER COLUMN httpua_httpua SET DEFAULT nextval('ipcba.http_user_agent_httpua_httpua_seq'::regclass);

ALTER TABLE ONLY ipcba.sesiones ALTER COLUMN ses_ses SET DEFAULT nextval('ipcba.sesiones_ses_ses_seq'::regclass);


ALTER TABLE ONLY ipcba.tiempo_logico ALTER COLUMN tlg_tlg SET DEFAULT nextval('ipcba.tiempo_logico_tlg_tlg_seq'::regclass);

ALTER TABLE ONLY ipcba.bitacora
    ADD CONSTRAINT bitacora_pkey PRIMARY KEY (bit_bit);

ALTER TABLE ONLY ipcba.http_user_agent
    ADD CONSTRAINT http_user_agent_pkey PRIMARY KEY (httpua_httpua);


ALTER TABLE ONLY ipcba.http_user_agent
    ADD CONSTRAINT "httpua_texto debe ser unico" UNIQUE (httpua_texto);


ALTER TABLE ONLY ipcba.rol_rol
    ADD CONSTRAINT rol_rol_pkey PRIMARY KEY (rolrol_principal, rolrol_delegado);

ALTER TABLE ONLY ipcba.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (rol_rol);


ALTER TABLE ONLY ipcba.sesiones
    ADD CONSTRAINT sesiones_pkey PRIMARY KEY (ses_ses);

ALTER TABLE ONLY ipcba.tiempo_logico
    ADD CONSTRAINT tiempo_logico_pkey PRIMARY KEY (tlg_tlg);

ALTER TABLE ONLY ipcba.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (usu_usu);

ALTER TABLE ONLY ipcba.bitacora
    ADD CONSTRAINT bitacora_tiempo_logico_fk FOREIGN KEY (bit_tlg) REFERENCES ipcba.tiempo_logico(tlg_tlg);

ALTER TABLE ONLY ipcba.rol_rol
    ADD CONSTRAINT rol_rol_p_roles_fk FOREIGN KEY (rolrol_principal) REFERENCES ipcba.roles(rol_rol) ON UPDATE CASCADE;

ALTER TABLE ONLY ipcba.rol_rol
    ADD CONSTRAINT rol_rol_roles_fk FOREIGN KEY (rolrol_delegado) REFERENCES ipcba.roles(rol_rol);

ALTER TABLE ONLY ipcba.rol_rol
    ADD CONSTRAINT rol_rol_tiempo_logico_fk FOREIGN KEY (rolrol_tlg) REFERENCES ipcba.tiempo_logico(tlg_tlg);

ALTER TABLE ONLY ipcba.roles
    ADD CONSTRAINT roles_tiempo_logico_fk FOREIGN KEY (rol_tlg) REFERENCES ipcba.tiempo_logico(tlg_tlg);

ALTER TABLE ONLY ipcba.sesiones
    ADD CONSTRAINT sesiones_http_user_agent_fk FOREIGN KEY (ses_httpua) REFERENCES ipcba.http_user_agent(httpua_httpua) ON UPDATE CASCADE;

ALTER TABLE ONLY ipcba.sesiones
    ADD CONSTRAINT sesiones_usuarios_fk FOREIGN KEY (ses_usu) REFERENCES ipcba.usuarios(usu_usu);

ALTER TABLE ONLY ipcba.usuarios
    ADD CONSTRAINT usuarios_roles_fk FOREIGN KEY (usu_rol) REFERENCES ipcba.roles(rol_rol);

ALTER TABLE ONLY ipcba.usuarios
    ADD CONSTRAINT usuarios_tiempo_logico_fk FOREIGN KEY (usu_tlg) REFERENCES ipcba.tiempo_logico(tlg_tlg);


GRANT ALL ON SCHEMA ipcba TO cvp_usuarios;

GRANT SELECT ON TABLE ipcba.usuarios TO cvp_usuarios;