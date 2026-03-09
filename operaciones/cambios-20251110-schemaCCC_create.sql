--NUEVAS CANASTAS 2025
DO
$$
BEGIN
    -- 1. Verifica si el rol 'mi_nuevo_rol' YA existe en el sistema
    IF NOT EXISTS (
        SELECT 1
        FROM   pg_roles
        WHERE  rolname = 'ccc_analista'
    ) THEN
        -- 2. Si NO existe, entonces procede a crearlo
        CREATE ROLE ccc_analista WITH NOLOGIN;
    END IF;
END
$$;
--CREATE ROLE ccc_analista WITH NOLOGIN;
SET role cvpowner;

DROP SCHEMA IF EXISTS ccc  CASCADE; ---canastas de consumo y crianza

CREATE SCHEMA IF NOT EXISTS ccc  AUTHORIZATION cvpowner; ---canastas de consumo y crianza

DROP TABLE IF EXISTS his."changes"; /* DONT ADD CASCADE HERE */

create table his."changes"(
  cha_schema text,
  cha_table text,
  cha_new_pk jsonb,
  cha_old_pk jsonb,
  cha_column text,
  cha_op text,
  cha_new_value jsonb,
  cha_old_value jsonb,
  cha_who text,
  cha_when timestamp,
  cha_context text
);

set search_path = ccc;

CREATE TABLE IF NOT EXISTS agrupaciones_ccc
(
    agrupacion text NOT NULL,
    nombreagrupacion text,
    paravarioshogares boolean NOT NULL DEFAULT false,
    calcular_junto_grupo text,
    valoriza boolean DEFAULT false,
    tipo_agrupacion text,
    PRIMARY KEY (agrupacion),
    CONSTRAINT "texto invalido en nombreagrupacion de tabla agrupaciones_ccc" CHECK (comun.cadena_valida(nombreagrupacion::text, 'castellano'::text))
);

DROP FUNCTION IF EXISTS his.changes_trg() /*CASCADE*/ /* REGEXP SECURE ADDABLE CASCADE */;

create or replace function his.changes_trg()
  returns trigger
  language plpgsql
  security definer
as
$BODY$
declare
  p_primary_key_values text[]:=regexp_split_to_array(tg_argv[0], ',');
  v_new_pk jsonb;
  v_old_pk jsonb;
  v_new_value jsonb;
  v_old_value jsonb;
  v_new_values jsonb;
  v_old_values jsonb;
  v_column text;
  v_new_pk_values jsonb:='{}';
  v_context text;
begin
  if tg_op = 'INSERT' or tg_op = 'UPDATE' then
    v_new_pk:='{}';
    v_new_values:=to_jsonb(new);
    foreach v_column in array p_primary_key_values
    loop
      v_new_pk:=jsonb_set(v_new_pk, array[v_column], v_new_values #> array[v_column]);
    end loop;
  else
    v_new_values:='{}';
  end if;
  if tg_op = 'DELETE' or tg_op = 'UPDATE' then
    v_old_pk:='{}';
    v_old_values:=to_jsonb(old);
    foreach v_column in array p_primary_key_values
    loop
      v_old_pk:=jsonb_set(v_old_pk, array[v_column], v_old_values -> v_column);
    end loop;
  else
    v_old_values:='{}';
  end if;
  select nullif(setting,'') into v_context from pg_settings where name='application_name';
  if tg_op = 'INSERT' OR tg_op = 'UPDATE' then
    for v_column in select jsonb_object_keys(v_new_values)
    loop
      v_new_value = v_new_values -> v_column;
      v_old_value = v_old_values -> v_column;
      if v_old_value is null then
        v_old_value:='null'::jsonb;
      end if;
      if v_new_value is distinct from v_old_value then
        insert into "his".changes
          (cha_schema     , cha_table    , cha_new_pk, cha_old_pk, cha_column, cha_op, cha_new_value, cha_old_value, cha_who      , cha_when         , cha_context) values
          (tg_table_schema, tg_table_name, v_new_pk  , v_old_pk  , v_column  , tg_op , v_new_value  , v_old_value  , session_user , clock_timestamp(), v_context  );
      end if;
    end loop;
    return new;
  else
    insert into "his".changes
      (cha_schema     , cha_table    , cha_old_pk, cha_op, cha_old_value, cha_who      , cha_when         , cha_context) values
      (tg_table_schema, tg_table_name, v_old_pk  , tg_op , v_old_values , session_user , clock_timestamp(), v_context  );
    return null;
  end if;
end;
$BODY$;

create or replace function enance_table(table_name text, primary_key_fields text, method text default 'iud') returns text
  language plpgsql security definer as
$BODY$
declare
  v_sql text;
begin
  v_sql=replace($sql$
    DROP TRIGGER IF EXISTS changes_trg ON table_name;
    DROP TRIGGER IF EXISTS changes_ud_trg ON table_name
  $sql$
    ,'table_name', table_name);
  execute v_sql;
  v_sql=replace(replace($sql$
    CREATE TRIGGER changes_trg
      AFTER INSERT OR UPDATE OR DELETE
      ON table_name
      FOR EACH ROW
      EXECUTE PROCEDURE his.changes_trg('primary_key_fields');
  $sql$
    ,'table_name', table_name)
    ,'primary_key_fields', primary_key_fields);
  if method = 'ud' then
    v_sql=replace(v_sql, 'AFTER INSERT OR UPDATE OR DELETE', 'AFTER UPDATE OR DELETE');
    v_sql=replace(v_sql, 'CREATE TRIGGER changes_trg', 'CREATE TRIGGER changes_ud_trg');
  end if;
  execute v_sql;
  return 'ok';
end;
$BODY$;

CREATE TABLE IF NOT EXISTS grupos_ccc
(
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    nombregrupo text,
    grupopadre text,
    ponderador double precision,
    nivel integer,
    esproducto text DEFAULT 'N',
    PRIMARY KEY (agrupacion, grupo),
    CONSTRAINT grupos_ccc_agrupacion_fkey FOREIGN KEY (agrupacion)
        REFERENCES ccc.agrupaciones_ccc (agrupacion),
    CONSTRAINT grupos_ccc_agrupacion_fkey1 FOREIGN KEY (agrupacion, grupopadre)
        REFERENCES ccc.grupos_ccc (agrupacion, grupo),
    CONSTRAINT "texto invalido en nombregrupo de tabla grupos_ccc" CHECK (comun.cadena_valida(nombregrupo::text, 'castellano'::text)),
    CONSTRAINT "Si esproducto=S => nombregrupo nulo" CHECK (NOT (esproducto = 'S') OR nombregrupo IS NULL)
);


CREATE TABLE IF NOT EXISTS productos_ccc
(
    producto text NOT NULL,
    nombreproducto text,
    unidad_normal text,
    cantidad double precision,
    factor_correccion double precision,
    unidad_de_medida text,
    esproducto_ipc boolean DEFAULT true,
    monto_promedio_may_18  double precision,
    PRIMARY KEY (producto),
    CONSTRAINT productos_ccc_unidades_fkey FOREIGN KEY (unidad_de_medida)
        REFERENCES cvp.unidades (unidad),
    CONSTRAINT "Si esproducto_ipc => nombreproducto nulo" CHECK (NOT esproducto_ipc OR nombreproducto IS NULL),
    CONSTRAINT "Si esproducto_ipc => unidad_normal no nulo" CHECK (NOT esproducto_ipc OR unidad_normal IS NOt NULL),
    CONSTRAINT "texto invalido en nombreproducto de tabla productos_ccc" CHECK (comun.cadena_valida(nombreproducto, 'castellano'::text))        
);

CREATE OR REPLACE FUNCTION extraer_rango_edad(rango_edad_str character varying)
RETURNS TABLE (
    edad_desde integer,
    edad_hasta integer,
    unidad_medida character varying
)
AS $$
DECLARE
    -- Normalizamos la entrada para evitar problemas con espacios en blanco.
    input_str text := TRIM(rango_edad_str);
    match_data text[];
BEGIN
    ----------------------------------------------------------
    -- 1. PATRÓN DE RANGO: '20-35 años'
    -- Captura: (Edad_Desde) - (Edad_Hasta) (Unidad)
    ----------------------------------------------------------
    match_data := REGEXP_MATCHES(input_str, '^(\d+)\s*-\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 3 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := match_data[2]::integer;
        unidad_medida := TRIM(match_data[3]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 2. PATRÓN DE LÍMITE INFERIOR (Desde/Mínimo): '≥ 60 años' o '>= 60 años'
    -- Captura: (Símbolo ≥ o >) (Edad_Desde) (Unidad)
    ----------------------------------------------------------
    -- El patrón (?:≥|[>]?=) coincide con ≥, > o >=
    match_data := REGEXP_MATCHES(input_str, '^(?:≥|[>]?=)\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := NULL; -- Límite superior abierto
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 3. PATRÓN DE LÍMITE SUPERIOR (Hasta/Máximo): '≤ 18 años' o '<= 18 años'
    -- Captura: (Símbolo ≤ o <) (Edad_Hasta) (Unidad)
    ----------------------------------------------------------
    -- El patrón (?:≤|[<]?=) coincide con ≤, < o <=
    match_data := REGEXP_MATCHES(input_str, '^(?:≤|[<]?=)\s*(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := NULL; -- Límite inferior abierto
        edad_hasta := match_data[1]::integer;
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 4. PATRÓN DE EDAD ÚNICA: '1 año' o '3 años'
    -- Captura: (Edad) (Unidad)
    ----------------------------------------------------------
    match_data := REGEXP_MATCHES(input_str, '^(\d+)\s*(\w.+$)', 'i');
    IF ARRAY_LENGTH(match_data, 1) = 2 THEN
        edad_desde := match_data[1]::integer;
        edad_hasta := match_data[1]::integer; -- Desde y Hasta son el mismo valor
        unidad_medida := TRIM(match_data[2]);
        RETURN NEXT;
        RETURN;
    END IF;

    ----------------------------------------------------------
    -- 5. NINGÚN PATRÓN ENCONTRADO
    ----------------------------------------------------------
    edad_desde := NULL;
    edad_hasta := NULL;
    unidad_medida := NULL;
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql;

-- 1. Función para extraer EDAD_DESDE (ENTERO)
CREATE OR REPLACE FUNCTION extraer_edad_desde(rango_edad_str character varying)
RETURNS integer
AS $$
SELECT (extraer_rango_edad(rango_edad_str)).edad_desde;
$$ LANGUAGE sql IMMUTABLE;


-- 2. Función para extraer EDAD_HASTA (ENTERO)
CREATE OR REPLACE FUNCTION extraer_edad_hasta(rango_edad_str character varying)
RETURNS integer
AS $$
SELECT (extraer_rango_edad(rango_edad_str)).edad_hasta;
$$ LANGUAGE sql IMMUTABLE;


-- 3. Función para extraer UNIDAD_MEDIDA (TEXTO)
CREATE OR REPLACE FUNCTION extraer_unidad_medida(rango_edad_str character varying)
RETURNS character varying
AS $$
SELECT (extraer_rango_edad(rango_edad_str)).unidad_medida;
$$ LANGUAGE sql IMMUTABLE;

CREATE TABLE IF NOT EXISTS perfiles
(
    --perfil text NOT NULL,
    perfil INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo text NOT NULL,
    genero text NOT NULL,
    edad text NOT NULL,
    energia  double precision,
    unidcons  double precision,
    edad_desde integer GENERATED ALWAYS AS (extraer_edad_desde(edad)) stored,
    edad_hasta integer GENERATED ALWAYS AS (extraer_edad_hasta(edad)) stored,
    edad_umed text GENERATED ALWAYS AS (extraer_unidad_medida(edad)) stored,
    descripcion text GENERATED ALWAYS AS (tipo||' '||genero||' '||edad) stored,
    equivalente boolean,
    --PRIMARY KEY (perfil),
    CONSTRAINT perfiles_uk UNIQUE (tipo, genero, edad),
    CONSTRAINT "tipo debe ser Lactante, Menor o Adulto" CHECK (tipo IN ('Lactante','Menor','Adulto')),
    CONSTRAINT "género debe ser Varón, Mujer, Embarazo o Lactancia" CHECK (genero IN ('Varón','Mujer','Embarazo', 'Lactancia')),
    --CONSTRAINT "edad_umed debe ser meses, años" CHECK (edad_umed IN ('meses','año','años')),
    CONSTRAINT "rango de edades válido" CHECK (edad  ~ '^(?:1\s+año|(?:[2-9]\d*|\d{2,})\s+años)$' OR edad ~ '^\d+-\d+\s+(?:años|meses)$' OR edad ~  '^≥\s\d+\s+(?:años)$')
);

CREATE TABLE IF NOT EXISTS prodperagr
(
    producto text NOT NULL,
    perfil integer NOT NULL,
    agrupacion text NOT NULL,
    peso_neto double precision,
    cantidad_ajuste double precision,
    calorias double precision,
    PRIMARY KEY (producto, perfil, agrupacion),
    CONSTRAINT prodperagr_productos_ccc_fkey FOREIGN KEY (producto)
        REFERENCES ccc.productos_ccc (producto),
    CONSTRAINT prodperagr_perfiles_fkey FOREIGN KEY (perfil)
        REFERENCES perfiles (perfil),
    CONSTRAINT prodperagr_agrupaciones_ccc_fkey FOREIGN KEY (agrupacion)
        REFERENCES ccc.agrupaciones_ccc (agrupacion)
);

--------------------------------------------------
do $SQL_ENANCE$
 begin
 PERFORM enance_table('agrupaciones_ccc','agrupacion');
 PERFORM enance_table('grupos_ccc','agrupacion, grupo');
 PERFORM enance_table('productos_ccc','producto');
 PERFORM enance_table('perfiles','perfil');
 PERFORM enance_table('prodperagr','producto,perfil,agrupacion');
 end
$SQL_ENANCE$;


CREATE TABLE IF NOT EXISTS calprodperagr
--valorización y parámetros calculados para productos por perfil
(
    periodo text NOT NULL,             --pk
    calculo integer NOT NULL,          --pk
    producto text NOT NULL,            --pk
    agrupacion text NOT NULL,          --pk
    perfil integer NOT NULL,              --pk
    peso_neto double precision,        --(insumo parametros)
    cantidad_ajuste double precision,  --(insumo parametros)
    calorias double precision,         --(insumo parametros)
    cantidad_canasta double precision, --(calculada)
    peso_bruto double precision,       --(calculada)
    valorprod double precision,        --(calculada)
    PRIMARY KEY (periodo, calculo, producto, agrupacion, perfil),
    CONSTRAINT calprodperagr_agrupacion_fkey FOREIGN KEY (agrupacion)
        REFERENCES ccc.agrupaciones_ccc (agrupacion),
    CONSTRAINT calprodperagr_calculo_fkey FOREIGN KEY (calculo)
        REFERENCES cvp.calculos_def (calculo),
    CONSTRAINT calprodperagr_periodo_fkey FOREIGN KEY (periodo)
        REFERENCES cvp.periodos (periodo),
    CONSTRAINT calprodperagr_periodo_fkey1 FOREIGN KEY (periodo, calculo)
        REFERENCES cvp.calculos (periodo, calculo),
    CONSTRAINT calprodperagr_producto_fkey FOREIGN KEY (producto)
        REFERENCES ccc.productos_ccc (producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT calprodperagr_perfiles_fkey FOREIGN KEY (perfil)
        REFERENCES perfiles (perfil)
);

CREATE TABLE IF NOT EXISTS calgruper
(
    periodo text NOT NULL,       --pk
    calculo integer NOT NULL,    --pk
    grupo text NOT NULL,         --pk
    agrupacion text NOT NULL,    --pk
    perfil integer NOT NULL,        --pk
    variacion double precision,  --(calculada)
    valorgru double precision,   --(calculada)
    ponderador double precision, --(insumo árbol de grupos)
    grupopadre text,             --(insumo árbol de grupos)
    nivel integer,               --(insumo árbol de grupos)
    esproducto text DEFAULT 'N', --(insumo árbol de grupos)
    PRIMARY KEY (periodo, calculo, grupo, agrupacion, perfil),
    CONSTRAINT calgruper_calculo_fkey FOREIGN KEY (calculo)
        REFERENCES cvp.calculos_def (calculo),
    CONSTRAINT calgruper_periodo_fkey FOREIGN KEY (periodo)
        REFERENCES cvp.periodos (periodo),
    CONSTRAINT calgruper_periodo_fkey1 FOREIGN KEY (periodo, calculo)
        REFERENCES cvp.calculos (periodo, calculo),
    CONSTRAINT calgruper_agrupacion_fkey FOREIGN KEY (agrupacion)
        REFERENCES ccc.agrupaciones_ccc (agrupacion),
    CONSTRAINT calgruper_perfiles_fkey FOREIGN KEY (perfil)
        REFERENCES perfiles (perfil),
    CONSTRAINT calgruper_grupos_ccc_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES ccc.grupos_ccc (agrupacion, grupo) --,
    --CONSTRAINT calgruper_grupos_ccc_fkey1 FOREIGN KEY (agrupacion, grupopadre)
    --    REFERENCES ccc.grupos_ccc (agrupacion, grupopadre)
);

--vista de árbol con nodos y hojas
CREATE OR REPLACE VIEW ccc.gru_grupos_ccc
 AS
 WITH RECURSIVE hijos_de(agrupacion, grupo_padre, grupo, esproducto) AS (
         SELECT agrupacion, grupopadre AS grupo_padre, grupo, esproducto
           FROM ccc.grupos_ccc
          WHERE grupopadre IS NOT NULL
        UNION ALL
         SELECT p.agrupacion, g.grupopadre AS grupo_padre, p.grupo, p.esproducto
           FROM hijos_de p
             JOIN ccc.grupos_ccc g ON g.grupo = p.grupo_padre AND g.agrupacion = p.agrupacion
          WHERE g.grupopadre IS NOT NULL
        )
 SELECT agrupacion, grupo_padre, grupo, esproducto
   FROM hijos_de
UNION ALL
 SELECT DISTINCT agrupacion, grupo AS grupo_padre, grupo, esproducto
   FROM ccc.grupos_ccc
  WHERE esproducto::text = 'N'
  ORDER BY 3, 2, 1;

--------------------------------------------------------------------------------------------------
set search_path = ccc;
--Cal_CCC: Cálculo de las Canastas de Consumo y Crianza
------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Cal_CCC_Borrar(pPeriodo Text, pCalculo Integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vAbierto character varying(1);
BEGIN
SET search_path = ccc, cvp, comun, public;

--los mensajes para bitácora de corridas los dejo en la tabla del esquema cvp
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', pTipo:='comenzo');

--Controles: Verificar que calculo no este cerrado
SELECT abierto INTO vAbierto
   FROM calculos
   WHERE periodo=pPeriodo AND calculo=pCalculo;
IF not (vAbierto='S') THEN
   EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='error',
                        pMensaje := 'ERROR no se puede recalcular CCC porque el calculo esta cerrado');
   RAISE EXCEPTION 'ERROR no se puede recalcular CCC porque el calculo esta cerrado';
END IF;
--

DELETE FROM CalProdPerAgr WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGruPer     WHERE periodo=pPeriodo AND calculo=pCalculo;
--Para ver luego, tablas para HOGARES
DELETE FROM CalHogParGru  WHERE periodo=pPeriodo AND calculo=pCalculo;
--DELETE FROM CalHogSubtotales  WHERE periodo=pPeriodo AND calculo=pCalculo;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Borrar', ptipo:='finalizo');

END;
$$;
------------------------------------------------------------------------------------------
CREATE or replace FUNCTION Cal_CCC_Copiar(pperiodo text, pcalculo integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vAgrupPrincipal character varying(10) ;
  vParaVariosHogares boolean;
  vmaxnivel integer;
  pGrupo text;

BEGIN

SET search_path = ccc, cvp, comun, public;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Copiar', pTipo:='comenzo');

--CalProdPerAgr
  INSERT INTO CalProdPerAgr(periodo, calculo, producto, agrupacion, perfil, peso_neto, cantidad_ajuste, calorias)

  (SELECT pPeriodo, pCalculo, p.producto, pa.agrupacion, pa.perfil, pa.peso_neto, pa.cantidad_ajuste, pa.calorias
     FROM Productos_ccc p
     INNER JOIN ProdPerAgr pa on p.producto = pa.producto
     INNER JOIN agrupaciones_ccc a ON pa.agrupacion = a.agrupacion
     WHERE a.valoriza
  );

--CalGruPer --hojas
INSERT INTO CalGruPer(periodo, calculo, agrupacion, grupo, perfil, grupopadre, nivel, esproducto, ponderador)
  (SELECT pPeriodo, pCalculo, g.agrupacion, g.grupo, perfil, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
     FROM Productos_ccc p
     INNER JOIN ProdPerAgr pa on p.producto = pa.producto
     INNER JOIN agrupaciones_ccc a ON pa.agrupacion = a.agrupacion
     INNER JOIN grupos_ccc g ON pa.agrupacion = g.agrupacion and pa.producto = g.grupo
   where a.valoriza
  );
--CalGruPer --nodos
INSERT INTO CalGruPer(periodo, calculo, agrupacion, grupo, perfil, grupopadre, nivel, esproducto, ponderador)
  (SELECT distinct pPeriodo, pCalculo, gg.agrupacion, gg.grupo_padre grupo , pa.perfil, g.grupoPadre, g.nivel, g.esProducto, g.ponderador
     FROM gru_grupos_ccc gg
     INNER JOIN agrupaciones_ccc a ON gg.agrupacion = a.agrupacion
    INNER JOIN prodperagr pa ON gg.grupo = pa.producto AND gg.agrupacion = pa.agrupacion
     INNER JOIN grupos_ccc g ON g.agrupacion = gg.agrupacion and g.grupo = gg.grupo_padre
   where a.valoriza
  );

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Copiar', pTipo:='finalizo');

 END;
$$;
---------------------------------------------------------------------------------------------
CREATE or replace FUNCTION calProd_CCC_valorizar(pperiodo text, pcalculo integer, pAgrupacion text default null) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vcalprod RECORD;

BEGIN
set search_path = ccc, cvp;

Raise Notice 'Hola calProd_CCC_valorizar ' /*, vcalprod.peso_neto * vcalprod.factor_correccion */;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='comenzo');

FOR vcalprod IN
  SELECT a.periodo, a.calculo, a.producto, a.agrupacion, a.perfil, a.peso_neto, a.calorias, p.factor_correccion, p.cantidad, c.promedioredondeado, a.cantidad_ajuste
    FROM CalDiv c
    INNER JOIN CalProdPerAgr a ON c.periodo = a.periodo and c.calculo = a.calculo and c.producto = a.producto
    INNER JOIN productos_ccc p ON a.producto = p.producto
    WHERE c.division = '0' and c.periodo=pPeriodo AND c.calculo=pCalculo AND a.agrupacion = pAgrupacion
LOOP
   --Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;

 UPDATE CalProdPerAgr
   SET peso_bruto       = vcalprod.peso_neto * vcalprod.factor_correccion
   , cantidad_canasta = coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad
   , valorProd        = 30*vcalprod.PromedioRedondeado * (coalesce(vcalprod.cantidad_ajuste, vcalprod.peso_neto * vcalprod.factor_correccion) / vcalprod.cantidad)
   WHERE periodo = vcalprod.periodo AND calculo = vcalprod.calculo AND producto = vcalprod.producto AND agrupacion = vcalprod.agrupacion AND perfil = vcalprod.perfil;
END LOOP;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalProd_CCC_Valorizar', pTipo:='finalizo', pagrupacion:=pagrupacion);
END;
$$;
--------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CalGru_CCC_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion TEXT) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vNivel record;

BEGIN
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='comenzo');
IF pAgrupacion IS NULL THEN
    EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='error', pmensaje:='Falta definir el parametro agrupacion', pagrupacion:=pAgrupacion);
ELSE
    --- se inserta todo el arbol de la agrupacion
    --EXECUTE Calgru_Insertar(pPeriodo, pCalculo, pAgrupacion); --ya están agregados
    -- PRODUCTOS
    UPDATE CalGruPer cg SET ValorGru=cp.ValorProd
        FROM CalProdPerAgr cp
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion= pAgrupacion AND cg.grupo=cp.producto AND cg.perfil = cp.perfil --PK verificada
          AND cg.periodo=cp.periodo AND cg.calculo=cp.calculo AND cg.agrupacion = cp.agrupacion --fk verificada
          AND cg.esproducto='S';
    --Hojas que no son producto y se construyen a partir de otra agrupacion
    --No hay
    -- GRUPOS
    FOR vNivel IN
      SELECT cg.nivel
        FROM Grupos_ccc cg
        WHERE cg.agrupacion = pAgrupacion AND cg.esProducto = 'N'
        GROUP BY cg.nivel
        ORDER BY cg.nivel DESC
    LOOP
      UPDATE CalGruPer cg SET ValorGru=SumValor
        FROM (SELECT ch.GrupoPadre, ch.perfil, sum(ch.ValorGru) AS SumValor
                FROM CalGruPer ch
                WHERE ch.periodo=pPeriodo AND ch.calculo=pCalculo  AND ch.agrupacion=pAgrupacion
                GROUP BY ch.GrupoPadre, ch.perfil) ch
        WHERE cg.periodo=pPeriodo AND cg.calculo=pCalculo AND cg.agrupacion=pAgrupacion  AND cg.grupo=ch.grupoPadre AND cg.perfil = ch.perfil -- PK verificada
          AND cg.nivel=vNivel.nivel AND cg.esproducto='N' ;
    END LOOP;
END IF;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'CalGru_CCC_Valorizar', pTipo:='finalizo');
END;
$$;
-------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION Cal_CCC_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion Text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
vindice double precision;
vparavariosHogares BOOLEAN;
BEGIN
SET search_path = ccc, cvp, comun, public;  --porque se corre suelto
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='comenzo');
SELECT indice INTO vindice
  FROM CalGru
  WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion='Z' and nivel=0 ;
IF vindice is null THEN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='error', pMensaje:='No está calculado el Indice para el nivel Z0', pAgrupacion:=pAgrupacion);
ELSE
  SELECT paravarioshogares INTO vparavariosHogares
    FROM agrupaciones_ccc
    WHERE agrupacion=pAgrupacion;

  EXECUTE CalProd_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);  --valoriza productos de ccc

  --EXECUTE Cal_Canasta_Borrar(pPeriodo, pCalculo, pAgrupacion);  ya se borró en Cal_CCC_Borrar, falta ver más adelante las tablas de hogares

  EXECUTE CalGru_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);

  --EXECUTE CalGru_Canasta_Variacion(pPeriodo, pCalculo, pAgrupacion); falta ver más adelante el cálculo de la variacion

  IF vparavariosHogares THEN      ---- falta ver más adelante las tablas de hogares
    EXECUTE CalHog_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);
  --  EXECUTE CalHog_Subtotalizar(pPeriodo, pCalculo, pAgrupacion);
  END IF;
END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Valorizar', pTipo:='finalizo');
END;
$$;
------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CalHog_ccc_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
 vmaxnivel integer;
 vhgru record;
 vhg RECORD;
BEGIN  

EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalHog_ccc_Valorizar', pTipo:='comenzo'); 
--insercion en calhogpargru

INSERT INTO calhogpargru (periodo, calculo, hogar, agrupacion, grupo, CoefHogGru, monto_may_18)
  (SELECT pPeriodo as Periodo, pcalculo as Calculo, hg.hogar, hg.agrupacion, hg.grupo, 
          sum(coeficiente * hg.cantidad) coefhoggru, 
          sum(coeficiente * hg.cantidad * COALESCE(pc.monto_promedio_may_18, p.monto_promedio_may_18)) monto_may_18
     FROM hogpargru hg
     join parametros_ccc pc on hg.parametro = pc.parametro 
     JOIN agrupaciones_ccc a ON hg.agrupacion = a.agrupacion 
     LEFT JOIN productos_ccc p ON p.producto = hg.grupo
   WHERE a.paravarioshogares
   GROUP BY periodo, calculo, hg.hogar, hg.agrupacion, hg.grupo
  );

-- sube por niveles
SELECT MAX(g.nivel) INTO vmaxnivel 
  FROM calhogpargru c, Grupos_CCC g
  WHERE c.periodo = pperiodo AND c.calculo = pcalculo AND c.agrupacion = g.agrupacion AND c.grupo = g.grupo AND c.agrupacion=pAgrupacion;
FOR i IN REVERSE vmaxnivel..1 LOOP
  INSERT INTO calhogpargru (periodo, calculo, hogar, agrupacion, grupo)
    (SELECT DISTINCT periodo, calculo, hogar, agrupacion, grupopadre
       FROM (SELECT c.*, g.grupopadre, g.nivel
               FROM calhogpargru c, Grupos_CCC g
               WHERE c.periodo = pperiodo AND c.calculo = pcalculo AND c.agrupacion = g.agrupacion AND c.grupo = g.grupo AND g.nivel = i AND c.agrupacion=pAgrupacion) AS x);
END LOOP;

 FOR vhgru IN --toma los grupos-Hoja de CalHogGru
   SELECT h.periodo, h.calculo, h.Hogar, h.agrupacion, h.grupo, c.indice/c_18.indice as coef_ajuste, h.coefhoggru, h.monto_may_18 
     FROM calhogpargru h 
          INNER JOIN Gruemp g ON g.grupo = h.grupo AND g.agrupacion = h.agrupacion  --PK verificada
          INNER JOIN calgru_ccc_b1112_b21_vw c ON c.grupo=g.grupo_b21 AND c.agrupacion = g.agrupacion_b21
                              AND c.agrupacion_b1112 = g.agrupacion_b1112 and c.grupo_b1112 = g.grupo_b1112
                              AND c.periodo = h.periodo AND c.calculo = h.calculo --PK verificada
          INNER JOIN cvp.parametros p on unicoregistro
          INNER JOIN calgru_ccc_b1112_b21_vw c_18 ON c_18.grupo=g.grupo_b21 AND c_18.agrupacion = g.agrupacion_b21
                              AND c_18.agrupacion_b1112 = g.agrupacion_b1112 and c_18.grupo_b1112 = g.grupo_b1112
                              AND c_18.periodo = p.periodo_ccc AND c_18.calculo = h.calculo --PK verificada
          --
     WHERE h.coefhoggru IS NOT NULL
       AND h.periodo = pperiodo 
       AND h.calculo = pcalculo
       AND h.agrupacion=pAgrupacion
 LOOP
   UPDATE calhogpargru x SET valorHogGru = vhgru.coef_ajuste * vhgru.monto_may_18
        --ver la cuenta para la valorización
     WHERE periodo = vhgru.periodo 
       AND calculo = vhgru.calculo 
       AND hogar = vhgru.Hogar 
       AND agrupacion = vhgru.agrupacion 
       AND grupo = vhgru.grupo;
 END LOOP;
 
 SELECT MAX(nivel) INTO vmaxnivel --para los niveles superiores
   FROM Grupos_ccc g 
        INNER JOIN calhogpargru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo --FK verificada
   WHERE h.valorhoggru IS NOT NULL
       AND h.periodo = pperiodo 
       AND h.calculo = pcalculo
       AND h.agrupacion=pAgrupacion;
 IF vmaxnivel is not null THEN
     FOR i IN REVERSE vmaxnivel-1..0 LOOP
       FOR vhg IN 
         SELECT h.periodo, h.calculo, h.Hogar, h.agrupacion, h.grupo
           FROM Grupos_ccc g 
                INNER JOIN calhogpargru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo --FK verificada
           WHERE g.nivel = i
             AND h.periodo = pperiodo 
             AND h.calculo = pcalculo
             AND h.ValorHogGru IS NULL
             AND h.agrupacion=pAgrupacion
       LOOP 
         UPDATE calhogpargru c SET valorhoggru = 
           (SELECT SUM(valorhoggru)
              FROM Grupos_ccc g
                  INNER JOIN calhogpargru h ON g.agrupacion = h.agrupacion AND g.grupo = h.grupo --FK verificada
              WHERE c.grupo = g.grupopadre
                AND c.periodo = h.periodo 
                AND c.calculo = h.calculo
                AND c.hogar = h.hogar
                AND c.agrupacion = h.agrupacion)
           WHERE periodo = vhg.periodo
             AND calculo = vhg.calculo
             AND hogar = vhg.hogar
             AND agrupacion = vhg.agrupacion
             AND grupo = vhg.grupo;       
       END LOOP;
     END LOOP;
 END IF;

EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'CalHog_ccc_Valorizar', pTipo:='finalizo');  
END;
$$;
------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CalcularCCCUnPeriodo(pPeriodo text, pCalculo integer) returns text
    LANGUAGE plpgsql SECURITY DEFINER
as
$BODY$
declare
   vEmpezo     time;
   vTermino    time;
   vEmpezo1    time;
   vTermino1   time;
  vError text; -- periodo anterior del cálculo
  vagrup_valorizar_indexar record;

begin
  vEmpezo:=clock_timestamp();
  set search_path = ccc, cvp, comun, public;
  Raise Notice '--------------- COMIENZA VALORIZACION DE LA CANASTA CCC % %',pPeriodo,pCalculo;
  select Calculo_ControlarAbierto(pPeriodo, pCalculo) into vError;
  if vError is not null then
      return vError;
  end if;
  execute Cal_CCC_Borrar(pPeriodo, pCalculo);
  execute Cal_CCC_Copiar(pPeriodo, pCalculo);

  analyze cvp.CalGru;
  vTermino1:=clock_timestamp();
  Raise Notice '%', 'analyze CalGru: EMPEZO '||cast(vEmpezo1 as text)||' TERMINO '||cast(vTermino1 as text)||' DEMORO '||(vTermino1 - vEmpezo1);
  if pCalculo=20 then
    for vagrup_valorizar_indexar IN
       select agrupacion, valoriza --, case when agrupacion='A' then true else false end AS actcalprod
         from agrupaciones_ccc
         where calcular_junto_grupo='Z'
         order by agrupacion
    loop
      if vagrup_valorizar_indexar.valoriza then
        execute Cal_CCC_Valorizar(pPeriodo, pCalculo, vagrup_valorizar_indexar.agrupacion/*, vagrup_valorizar_indexar.actcalprod*/);
      end if;
    end loop;
  end if;

  vTermino:=clock_timestamp();
  Raise Notice '%', 'CALCULO CCC COMPLETO: EMPEZO '||cast(vEmpezo as text)||' TERMINO '||cast(vTermino as text)||' DEMORO '||(vTermino - vEmpezo);
  return 'Calculo completo en '||(vTermino - vEmpezo);
end;
$BODY$;

---------------------------------------
GRANT USAGE ON SCHEMA ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.agrupaciones_ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.calgruper TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.calprodperagr TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.grupos_ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.perfiles TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.prodperagr TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE ccc.productos_ccc TO cvp_administrador, ccc_analista;
GRANT USAGE ON SCHEMA cvp TO ccc_analista;
GRANT SELECT ON TABLE cvp.periodos TO ccc_analista;
GRANT SELECT ON TABLE cvp.calculos TO ccc_analista;
GRANT SELECT ON TABLE cvp.calculos_def TO ccc_analista;
GRANT SELECT ON TABLE cvp.unidades TO ccc_analista;
GRANT SELECT ON TABLE cvp.productos TO ccc_analista;
GRANT SELECT ON TABLE cvp.paraimpresionformulariosenblanco TO ccc_analista;
GRANT SELECT ON TABLE cvp.cuadros TO ccc_analista;
GRANT SELECT ON TABLE cvp.hogares TO ccc_analista;

CREATE TABLE IF NOT EXISTS hogares_ccc
(
    hogar text NOT NULL,
    nombrehogar text,
    PRIMARY KEY (hogar),
    CONSTRAINT "texto invalido en nombrehogar de tabla hogares_ccc" CHECK (comun.cadena_valida(nombrehogar::text, 'castellano'::text))
);

CREATE TABLE IF NOT EXISTS perfiles_edad
(
    perfil_edad INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edad text NOT NULL,
    edad_desde integer GENERATED ALWAYS AS (extraer_edad_desde(edad)) stored,
    edad_hasta integer GENERATED ALWAYS AS (extraer_edad_hasta(edad)) stored,
    edad_umed text GENERATED ALWAYS AS (extraer_unidad_medida(edad)) stored,
    CONSTRAINT perfiles_edad_uk UNIQUE (edad),
    CONSTRAINT "rango de edades válido para perfiles_edad" CHECK (edad  ~ '^(?:1\s+año|(?:[02-9]\d*|\d{2,})\s+años)$' OR edad ~ '^\d+-\d+\s+(?:años|meses)$' OR edad ~ '^≥\s\d+\s+(?:años)$' OR edad ~ '^<\s\d+\s+(?:años)$' OR edad ~ '^>\s\d+\s+(?:años)$')
);

CREATE TABLE IF NOT EXISTS parametros_propiedades
(
    nombreparametro text,
    usa_perfil_edad boolean NOT NULL,
    usa_ambientes boolean NOT NULL,
    usa_miembros boolean NOT NULL,
    usa_es_jefe boolean NOT NULL,
    usa_monto_promedio_may_18 boolean NOT NULL,
    usa_horas_diarias boolean not null,
    usa_es_promedio boolean not null,
    PRIMARY KEY (nombreparametro)
);

CREATE TABLE IF NOT EXISTS parametros_ccc
(
    parametro INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombreparametro text,
    perfil_edad INTEGER,
    ambientes INTEGER,
    miembros INTEGER,
    es_jefe boolean,
    monto_promedio_may_18 double precision,
    horas_diarias INTEGER,
    es_promedio boolean,
    coeficiente double precision NOT NULL,
    CONSTRAINT parametros_ccc_perfiles_edad_fkey FOREIGN KEY (perfil_edad)
        REFERENCES ccc.perfiles_edad (perfil_edad),
    CONSTRAINT parametros_ccc_parametros_propiedades_fkey FOREIGN KEY (nombreparametro)
        REFERENCES ccc.parametros_propiedades (nombreparametro)
);
/*
CREATE TABLE IF NOT EXISTS pargru
(
    parametro integer NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    CONSTRAINT pargru_pkey PRIMARY KEY (parametro, agrupacion, grupo),
    CONSTRAINT pargru_agrupacion_grupo_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES grupos_ccc (agrupacion, grupo),
    CONSTRAINT pargru_parametro_fkey FOREIGN KEY (parametro)
        REFERENCES parametros_ccc (parametro)
);

CREATE TABLE IF NOT EXISTS hogparagr
(
    hogar text NOT NULL,
    parametro integer NOT NULL,
    agrupacion text NOT NULL,
    CONSTRAINT hogparagr_pkey PRIMARY KEY (hogar, parametro, agrupacion),
    CONSTRAINT hogparagr_hogar_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT hogparagr_agrupacion_fkey FOREIGN KEY (agrupacion)
        REFERENCES agrupaciones_ccc (agrupacion),
    CONSTRAINT hogparagr_parametro_fkey FOREIGN KEY (parametro)
        REFERENCES parametros_ccc (parametro)
);

CREATE TABLE IF NOT EXISTS hoggru
(
    hogar text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    perfil_edad INTEGER,
    cantidad INTEGER,
    monto_promedio_may_18  double precision,
    CONSTRAINT hoggru_pkey PRIMARY KEY (hogar, agrupacion, grupo),
    CONSTRAINT hoggru_agrupacion_grupo_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES grupos_ccc (agrupacion, grupo),
    CONSTRAINT hoggru_hogar_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT hoggru_perfiles_edad_fkey FOREIGN KEY (perfil_edad)
        REFERENCES perfiles_edad (perfil_edad)
);
*/
CREATE TABLE IF NOT EXISTS hogpargru
(
    hogar text NOT NULL,
    parametro integer NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    cantidad integer,
    CONSTRAINT hogpargru_pkey PRIMARY KEY (hogar, parametro, agrupacion, grupo),
    CONSTRAINT hogpargru_agrupacion_grupo_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES grupos_ccc (agrupacion, grupo),
    CONSTRAINT hogpargru_hogar_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT hogpargru_parametros_ccc_fkey FOREIGN KEY (parametro)
        REFERENCES parametros_ccc (parametro)
);
/*
CREATE TABLE IF NOT EXISTS calhoggru_ccc
(
    periodo text NOT NULL,
    calculo integer NOT NULL,
    hogar text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    coefhoggru double precision,
    monto_may_18  double precision,
    valorhoggru double precision,
    CONSTRAINT calhoggru_ccc_pkey PRIMARY KEY (periodo, calculo, hogar, agrupacion, grupo),
    CONSTRAINT calhoggru_ccc_hogar_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT calhoggru_ccc_hoggru_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES grupos_ccc (agrupacion, grupo),
    CONSTRAINT calhoggru_ccc_calculos_fkey FOREIGN KEY (periodo, calculo)
        REFERENCES cvp.calculos (periodo, calculo)
);
*/
CREATE TABLE IF NOT EXISTS calhogpargru
(
    periodo text NOT NULL,
    calculo integer NOT NULL,
    hogar text NOT NULL,
    --nombreparametro text NOT NULL,
    agrupacion text NOT NULL,
    grupo text NOT NULL,
    cantidad integer,
    coefhoggru double precision,
    monto_may_18 double precision,
    valorhoggru double precision,
    CONSTRAINT calhogpargru_pkey PRIMARY KEY (periodo, calculo, hogar, agrupacion, grupo),
    CONSTRAINT calhogpargru_hogar_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT calhogpargru_grupos_ccc_fkey FOREIGN KEY (agrupacion, grupo)
        REFERENCES grupos_ccc (agrupacion, grupo),
    CONSTRAINT calhoggru_ccc_calculos_fkey FOREIGN KEY (periodo, calculo)
        REFERENCES cvp.calculos (periodo, calculo)
);

--costo del servicio doméstico para el personal de cuidados 
CREATE TABLE IF NOT EXISTS novservdom (
    periodo text NOT NULL,
    monto_hora_general double precision,
    monto_hora_cuidado double precision,
    monto_mes_cuidado double precision,
    monto_hora_promedio double precision
       GENERATED ALWAYS AS (
          CASE 
            WHEN monto_hora_general IS NULL OR monto_hora_cuidado IS NULL THEN 0
            ELSE (monto_hora_general + monto_hora_cuidado) / 2.0
          END
       ) STORED,
    CONSTRAINT novservdom_pkey PRIMARY KEY (periodo),
    CONSTRAINT novservdom_periodos_fkey FOREIGN KEY (periodo)
        REFERENCES cvp.periodos (periodo)
);

CREATE TABLE IF NOT EXISTS hogper (
    hogar text NOT NULL,
    perfil INTEGER,
    perfil_equivalente INTEGER,
    cantidad integer,
    CONSTRAINT hogper_pkey PRIMARY KEY (hogar, perfil),
    CONSTRAINT hogper_hogares_ccc_fkey FOREIGN KEY (hogar)
        REFERENCES hogares_ccc (hogar),
    CONSTRAINT hogper_perfiles_fkey FOREIGN KEY (perfil)
        REFERENCES perfiles (perfil),
    CONSTRAINT hogper_perfiles_equi_fkey FOREIGN KEY (perfil_equivalente)
        REFERENCES perfiles (perfil)
);

GRANT SELECT ON TABLE hogares_ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE perfiles_edad TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE parametros_propiedades TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE parametros_ccc TO cvp_administrador, ccc_analista;
--GRANT SELECT ON TABLE pargru TO cvp_administrador, ccc_analista;
--GRANT SELECT ON TABLE hogparagr TO cvp_administrador, ccc_analista;
--GRANT SELECT ON TABLE hoggru TO cvp_administrador, ccc_analista;
--GRANT SELECT ON TABLE calhoggru_ccc TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE hogpargru TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE calhogpargru TO cvp_administrador, ccc_analista;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE novservdom TO cvp_administrador, ccc_analista;
GRANT SELECT ON TABLE hogper TO cvp_administrador, ccc_analista;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('hogares_ccc','hogar');
 PERFORM enance_table('perfiles_edad','perfil_edad');
 PERFORM enance_table('parametros_propiedades','nombreparametro');
 PERFORM enance_table('parametros_ccc','parametro');
 --PERFORM enance_table('pargru','parametro,agrupacion,grupo');
 --PERFORM enance_table('hogparagr','hogar,parametro,agrupacion');
 --PERFORM enance_table('hoggru','hogar,agrupacion,grupo');
 --PERFORM enance_table('calhoggru_ccc','periodo,calculo,hogar,agrupacion,grupo');
 PERFORM enance_table('hogpargru','hogar,parametro,agrupacion,grupo');
 PERFORM enance_table('calhogpargru','periodo,calculo,hogar,agrupacion,grupo');
 PERFORM enance_table('novservdom','periodo');
 PERFORM enance_table('hogper','hogar,perfil');
 end
$SQL_ENANCE$;

--integridad de las propiedades de los parametros
CREATE OR REPLACE FUNCTION verificar_usa_propiedad() RETURNS trigger
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = ccc
AS
$$
DECLARE
  v_parprod record;
  v_new_json jsonb;
  v_meta_json jsonb;
  v_columna_config text;
  v_valor_config text;
  v_propiedad_real text;
  v_errores text[] := '{}';
BEGIN
  -- 1. Obtener la fila de configuración
  SELECT * INTO v_parprod 
  FROM parametros_propiedades 
  WHERE nombreparametro = NEW.nombreparametro;

  -- 2. Convertir registros a JSONB
  v_new_json := to_jsonb(NEW);
  v_meta_json := to_jsonb(v_parprod);

  -- 3. Recorrer DINÁMICAMENTE todas las columnas de la tabla de configuración
  -- key (v_columna_config) será el nombre del campo, value (v_valor_config) su valor
  FOR v_columna_config, v_valor_config IN SELECT * FROM jsonb_each_text(v_meta_json)
  LOOP
    -- Filtramos: ¿La columna empieza con 'usa_'?
    IF v_columna_config LIKE 'usa_%' THEN
      -- Extraemos el nombre de la propiedad real (quitando el 'usa_')
      -- Ejemplo: 'usa_perfil_edad' -> 'perfil_edad'
      v_propiedad_real := substr(v_columna_config, 5);
      -- verificamos la integridad
      IF v_valor_config = 'true' THEN
        IF (v_new_json->>v_propiedad_real) IS NULL THEN
            v_errores := array_append(v_errores, format('La propiedad "%s" es obligatoria', v_propiedad_real));
        END IF;
      ELSIF v_valor_config = 'false' THEN
        IF (v_new_json->>v_propiedad_real) IS NOT NULL THEN
            v_errores := array_append(v_errores, format('La propiedad "%s" debe ser nula porque no está habilitada', v_propiedad_real));
        END IF;
      END IF;
    END IF;
  END LOOP;

  -- 4. Lanzar reporte de errores si existen
  IF array_length(v_errores, 1) > 0 THEN
    RAISE EXCEPTION 'Errores de integridad para el parámetro "%": %', 
      NEW.nombreparametro, 
      array_to_string(v_errores, ' | ');
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS verificar_usa_propiedad ON parametros_ccc;
CREATE TRIGGER verificar_usa_propiedad
    BEFORE INSERT OR UPDATE ON parametros_ccc
    FOR EACH ROW
    EXECUTE PROCEDURE verificar_usa_propiedad();


CREATE VIEW valorizacion_canasta_ccc AS
select * from
(select periodo, calculo, hogar, agrupacion, grupo, valorhoggru 
from calhogpargru 
union
select c.periodo, c.calculo, h.hogar, c.agrupacion , c.grupo, sum(c.valorgru*p.unidcons) valorhoggru
from hogper h 
left join perfiles p on h.perfil = p.perfil
left join calgruper c on c.perfil = h.perfil_equivalente
--where periodo = 'a2025m05'
group by c.periodo, c.calculo, h.hogar, c.agrupacion , c.grupo) Q;

GRANT SELECT ON TABLE valorizacion_canasta_ccc TO cvp_administrador, ccc_analista;