CREATE OR REPLACE VIEW calobs_periodos AS
 SELECT c.producto,
    c.informante,
    c.observacion,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m01'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m01_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m01'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m01_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m02'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m02_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m02'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m02_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m03'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m03_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m03'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m03_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m04'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m04_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m04'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m04_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m05'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m05_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m05'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m05_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m06'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m06_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m06'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m06_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m07'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m07_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m07'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m07_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m08'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m08_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m08'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m08_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m09'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m09_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m09'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m09_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m10'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m10_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m10'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m10_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m11'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m11_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m11'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m11_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2011m12'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2011m12_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2011m12'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2011m12_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m01'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m01_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m01'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m01_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m02'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m02_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m02'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m02_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m03'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m03_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m03'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m03_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m04'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m04_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m04'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m04_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m05'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m05_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m05'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m05_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m06'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m06_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m06'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m06_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m07'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m07_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m07'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m07_imp,
    round(avg(
        CASE
            WHEN c.periodo::text = 'a2012m08'::text THEN c.promobs
            ELSE NULL::double precision
        END)::numeric, 2) AS a2012m08_prom,
    max(
        CASE
            WHEN c.periodo::text = 'a2012m08'::text THEN ((((
            CASE
                WHEN c.antiguedadexcluido > 0 THEN 'X'::text
                ELSE ''::text
            END || COALESCE(c.impobs, ''::character varying)::text) ||
            CASE
                WHEN r.tipoprecio IS NOT NULL THEN ':'::text
                ELSE ''::text
            END) || COALESCE(r.tipoprecio, ''::character varying)::text) ||
            CASE
                WHEN r.cambio IS NOT NULL THEN ','::text
                ELSE ''::text
            END) || COALESCE(r.cambio, ''::character varying)::text
            ELSE NULL::text
        END) AS a2012m08_imp
   FROM cvp.calobs c
     JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
     LEFT JOIN cvp.relpre r ON c.periodo::text = r.periodo::text AND c.producto::text = r.producto::text AND c.informante = r.informante AND c.observacion = r.observacion AND r.visita = 1
  WHERE cd.principal
  GROUP BY c.producto, c.informante, c.observacion
  ORDER BY c.producto, c.informante, c.observacion;

GRANT SELECT ON TABLE calobs_periodos TO cvp_administrador;
