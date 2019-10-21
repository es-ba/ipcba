CREATE OR REPLACE VIEW bienvenida AS 
 SELECT 9 AS orden,
    'version'::text AS codigo,
    'V160909'::text AS dato,
    'es la versión de la base de datos'::text AS explicacion,
    'N1'::text AS nivel
UNION
 SELECT 10 AS orden,
    'version_cliente'::text AS codigo,
    'V181227'::text AS dato, --'V180830'
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
          WHERE sql_implementation_info.implementation_info_id::text = '17'::text))::text) || ' '::text) || ((( SELECT sql_implementation_info.character_value
           FROM information_schema.sql_implementation_info
          WHERE sql_implementation_info.implementation_info_id::text = '18'::text))::text) AS dato,
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
    min(periodos.periodo::text) AS dato,
    'es el periodo abierto más antiguo'::text AS explicacion,
    'N3'::text AS nivel
   FROM periodos
  WHERE periodos.ingresando::text = 'S'::text
UNION
 SELECT 23 AS orden,
    'max_periodo'::text AS codigo,
    max(periodos.periodo::text) AS dato,
    'es el último periodo abierto '::text AS explicacion,
    'N1'::text AS nivel
   FROM periodos
  WHERE periodos.ingresando::text = 'S'::text
UNION
 SELECT 24 AS orden,
    'rol_user'::text AS codigo,
    r.listaroles AS dato,
        CASE
            WHEN r.listaroles ~~ '%,%'::text THEN 'son los roles '::text
            ELSE 'es el rol '::text
        END || 'del usuario conectado'::text AS explicacion,
    'N1'::text AS nivel
   FROM ( SELECT string_agg(pg_roles.rolname::text, ','::text) AS listaroles
           FROM pg_roles
          WHERE pg_has_role("session_user"(), pg_roles.oid, 'member'::text) AND pg_roles.rolname <> "session_user"()) r;

GRANT SELECT ON TABLE bienvenida TO cvp_usuarios;
GRANT SELECT ON TABLE bienvenida TO cvp_recepcionista;

