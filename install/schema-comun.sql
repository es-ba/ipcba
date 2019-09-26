set role to cvpowner;
drop schema if exists "comun" cascade;

CREATE SCHEMA comun;
grant usage on schema "comun" to cvpowner;
set client_encoding = 'UTF8';

CREATE FUNCTION comun.a_texto(valor boolean) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF valor IS NULL THEN
    RETURN '';
  ELSIF valor=TRUE THEN
    RETURN 'TRUE';
  ELSE
    RETURN 'FALSE';
  END IF;
END;
$$;

CREATE FUNCTION comun.a_texto(valor double precision) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF valor IS NULL THEN
    RETURN '';
  ELSE
    RETURN valor::TEXT;
  END IF;
END;
$$;

CREATE FUNCTION comun.a_texto(valor integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF valor IS NULL THEN
    RETURN '';
  ELSE
    RETURN valor::TEXT;
  END IF;
END;
$$;

CREATE FUNCTION comun.a_texto(valor text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF valor IS NULL THEN
    RETURN '';
  ELSIF valor='' THEN
    RETURN '''''';
  ELSE
    RETURN valor;
  END IF;
END;
$$;

CREATE FUNCTION comun.a_texto(valor timestamp without time zone) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  IF valor IS NULL THEN
    RETURN '';
  ELSE
    RETURN TO_CHAR(valor,'dd/mm/yyyy');
  END IF;
END;
$$;

CREATE FUNCTION comun.cadena_normalizar(p_cadena text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
/*
-- Pruebas:
select entrada, esperado, comun.cadena_normalizar(entrada)
    , esperado is distinct from comun.cadena_normalizar(entrada)
  from (
  select 'hola' as entrada, 'HOLA' as esperado
  union select 'Cañuelas', 'CAÑUELAS'
  union select 'ÁCÉNTÍTÓSÚCü','ACENTITOSUCU'
  union select 'CON.SIGNOS/DE-PUNTUACION    Y MUCHOS ESPACIOS','CON SIGNOS DE-PUNTUACION Y MUCHOS ESPACIOS'
) casos
  where esperado is distinct from comun.cadena_normalizar(entrada);
*/   largo integer;
   expresion_regular_a text;
   caracteres_nopermitidos text:='ÁÉÍÓÚÜáéíóòúüçÇ¿¡!:;,?¿"./,()_'; 
   --caracteres_nopermitidos text:='ÁÉÍÓÚÜáéíóúüçÇ¿¡!:;,?¿".';
   i integer;
BEGIN
  expresion_regular_a:='^['||caracteres_nopermitidos||']*$';
  if p_cadena IS NOT NULL then
    largo := char_length(p_cadena);
   -- for i IN 1..largo loop
     i:=1;
     while  i <=largo loop
      if (substr(p_cadena,i,1) ~ expresion_regular_a) then
      --  raise notice 'valor no permitido %', i;
      --  raise notice 'El caracter % es invalido (%)', substr(p_cadena,i,1), ascii(substr(p_cadena,i,1));
           case when (substr(p_cadena,i,1)='Á' or  substr(p_cadena,i,1)='á') then p_cadena:=replace(p_cadena, substr(p_cadena,i,1), 'a');
                           i:=i+1;
                when (substr(p_cadena,i,1)='É' or  substr(p_cadena,i,1)='é') then p_cadena:=replace(p_cadena, substr(p_cadena,i,1), 'e');
                          i:=i+1;
                when (substr(p_cadena,i,1)='Í' or  substr(p_cadena,i,1)='í') then p_cadena:=replace(p_cadena, substr(p_cadena,i,1), 'i');
                          i:=i+1; 
                when (substr(p_cadena,i,1)='Ó' or  substr(p_cadena,i,1)='ó' or  substr(p_cadena,i,1)='ò') then p_cadena:=replace(p_cadena, substr(p_cadena,i,1), 'o');
                          i:=i+1;  
                when (substr(p_cadena,i,1)='Ú' or  substr(p_cadena,i,1)='ú' or substr(p_cadena,i,1)='Ü' or  substr(p_cadena,i,1)='ü')
                    then p_cadena:=replace(p_cadena, substr(p_cadena,i,1), 'u');
                          i:=i+1;              
                else p_cadena:=replace(p_cadena, substr(p_cadena,i,1), ' ');
                         i:=i+1;       
           end case;
      else
       i:=i+1;
      -- raise notice 'i %', i;   
      end if;
    end loop;
  end if; 
  p_cadena:=regexp_replace(p_cadena, ' {2,}',' ','g');  
  return upper(trim(p_cadena));
END;
$_$;

CREATE FUNCTION comun.cadena_valida(p_cadena text, p_version text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
  /*
  select comun.cadena_valida(entrada, version)=resultado as ok, entrada, version, resultado as esperado, comun.cadena_valida(entrada, version) as recibido
    from (
	  select 'Mauro01' as entrada, 'codigo' as version, true as resultado
	  union select '/xñz1', 'codigo', false
	  union select '/xñz1', 'castellano', true
	  union select '/xñz1', 'formula', false
	  union select '{"pepe":"\\esto;",[]}', 'formula', false
	  union select '{"pepe":"\\esto;",[]}', 'json', true
	  union select 'a<99-', 'formula', true
	  union select 'a<99-', 'codigo', false) x
    where comun.cadena_valida(entrada, version) is distinct from resultado 
  
  */
  caracteres_permitidos_codigo text:='A-Za-z0-9_';
  caracteres_permitidos_extendido text:='-'||caracteres_permitidos_codigo||' ,/*+().$@!#:%';
  caracteres_permitidos_castellano text:=caracteres_permitidos_extendido||'ÁÉÍÓÚÜÑñáéíóúüçÇ¿¡?!';
  caracteres_permitidos_formula text:=caracteres_permitidos_extendido||'<>=';
  caracteres_permitidos_castellano_formula text:=caracteres_permitidos_castellano||'<>=';
  caracteres_permitidos_json text:=caracteres_permitidos_formula||'{}"\[\]\\|&^~'';';
  caracteres_permitidos_amplio text:=caracteres_permitidos_castellano_formula||'{}"\[\]\\|&^~'';º³';
  caracteres_permitidos text;
  explicar boolean:=false;
  largo integer;
  expresion_regular text;
  v_juego_caracteres text:=p_version;
BEGIN
  if p_version like 'explicar%' then
    explicar:=true;
    v_juego_caracteres:=substr(p_version,length('explicar ')+1);
  end if;
  if v_juego_caracteres='cualquiera' then
    return true;
  end if;
  caracteres_permitidos:=case v_juego_caracteres
    when 'codigo' then caracteres_permitidos_codigo
    when 'extendido' then caracteres_permitidos_extendido
    when 'castellano' then caracteres_permitidos_castellano
    when 'formula' then caracteres_permitidos_formula
    when 'json' then caracteres_permitidos_json
    when 'castellano y formula' then caracteres_permitidos_castellano_formula
    when 'amplio' then caracteres_permitidos_amplio
  end;
  if caracteres_permitidos is null then
    raise exception 'Parametro invalido para p_version "%"',p_version;
  end if;
  expresion_regular:='^['||caracteres_permitidos||']*$';
  if explicar then
    largo := char_length(p_cadena);
    for i IN 1..largo LOOP
      if not (substr(p_cadena,i,1) ~ expresion_regular) THEN
        raise exception 'El caracter % es invalido (%)', substr(p_cadena,i,1), ascii(substr(p_cadena,i,1));
      END IF;
    END LOOP;
  end if;
  return p_cadena ~ expresion_regular;
END;
$_$;

CREATE FUNCTION comun.caracteres_invalidos(p_cadena text, p_version text DEFAULT NULL::text, p_forma text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$DECLARE
  caracteres_invalidos text := '';
  caracteres_permitidos_codigo text:='A-Za-z0-9_';
  caracteres_permitidos_extendido text:='-'||caracteres_permitidos_codigo||' ,/*().+$@!#:%';
  caracteres_permitidos_castellano text:=caracteres_permitidos_extendido||'ÁÉÍÓÚÜÑñáéíóúüçÇ¿¡?!';
  caracteres_permitidos_formula text:=caracteres_permitidos_extendido||'<>=';
  caracteres_permitidos_castellano_formula text:=caracteres_permitidos_castellano||'<>=';
  caracteres_permitidos_json text:=caracteres_permitidos_formula||'{}"\[\]\\|&^~'';';
  caracteres_permitidos_amplio text:=caracteres_permitidos_castellano_formula||'{}"\[\]\\|&^~'';º';
  caracteres_permitidos text;
  expresion_regular text;
  expresion_regular_codigo text;
  expresion_regular_extendido text;
  expresion_regular_castellano text;
  expresion_regular_formula text;
  expresion_regular_castellano_formula text;
  expresion_regular_json text;
  expresion_regular_amplio text;
  caracter_ascii int;
  largo int;
BEGIN/*
-- Pruebas:
select version, entrada, comun.caracteres_invalidos(entrada,version,forma)
     from (
  select '+?af'::text as entrada, 'codigo'::text as version, null as forma, 1 as caso
  union select '+?af', 'codigo', 'esc', 2 
  union select '+af', 'codigo', null, 3
  union select '+af', 'codigo', 'esc', 4 
  union select '☻☺defg', 'codigo', null, 5 
  union select '☻☺defg', 'codigo', 'esc', 6 
  union select 'defg', 'codigo', null, 7   
  union select 'defg', 'codigo', 'esc', 8 
  union select 'asdjfhasd', 'cualquiera', null, 9 
  union select 'asdjfhasd', 'cualquiera', 'esc', 10 
  union select 'Áñ= u', 'castellano', null, 11 
  union select 'Áñ= u', 'castellano', 'esc', 12
  union select 'á><=¿', 'formula', null, 13 
  union select 'á><=¿', 'formula', 'esc', 14
  union select 'úÑ=☻', 'castellano y formula', null, 15
  union select 'úÑ=☻', 'castellano y formula', null, 16
  union select 'sdfasd☺>Ñ?¿asdfas', null, null, 17
  union select 'sdfasd☺>Ñ?¿asdfas', null, 'esc', 18) casos order by caso;
*/
if (p_version = 'cualquiera') then
   return caracteres_invalidos;
end if;
if (p_version ISNULL) then
   expresion_regular_codigo:='^['||caracteres_permitidos_codigo||']*$';
   expresion_regular_extendido:='^['||caracteres_permitidos_extendido||']*$';
   expresion_regular_castellano:='^['||caracteres_permitidos_castellano||']*$';
   expresion_regular_formula:='^['||caracteres_permitidos_formula||']*$';
   expresion_regular_castellano_formula:='^['||caracteres_permitidos_castellano_formula||']*$';
   expresion_regular_json:='^['||caracteres_permitidos_json||']*$';
   expresion_regular_amplio:='^['||caracteres_permitidos_amplio||']*$';
   largo := char_length(p_cadena);
   for i in 1..largo LOOP
       if ((substr(p_cadena,i,1) !~ expresion_regular_codigo) and (substr(p_cadena,i,1) !~ expresion_regular_extendido) and (substr(p_cadena,i,1) !~ expresion_regular_castellano) and (substr(p_cadena,i,1) !~ expresion_regular_formula) and (substr(p_cadena,i,1) !~ expresion_regular_castellano_formula)) then
          if (p_forma = 'esc') then 
             caracteres_invalidos := caracteres_invalidos||chr(92)||chr(92)||'u'||to_hex(ascii(substr(p_cadena,i,1)));
          else
             caracteres_invalidos := caracteres_invalidos||substr(p_cadena,i,1);
          end if;
       end if;
   end loop;
   return caracteres_invalidos;
else
    case p_version
       when 'codigo' then caracteres_permitidos := caracteres_permitidos_codigo;
       when 'extendido' then caracteres_permitidos :=caracteres_permitidos_extendido;
       when 'castellano' then caracteres_permitidos := caracteres_permitidos_castellano;
       when 'formula' then caracteres_permitidos := caracteres_permitidos_formula;
       when 'castellano y formula' then caracteres_permitidos := caracteres_permitidos_castellano_formula;
       when 'json' then caracteres_permitidos := caracteres_permitidos_json;
       when 'amplio' then caracteres_permitidos := caracteres_permitidos_amplio;
       else raise exception 'Parametro invalido para "version" "%"',"p_version";
    end case;
    expresion_regular:='^['||caracteres_permitidos||']*$';
    largo := char_length(p_cadena);
    for i in 1..largo LOOP
        if (substr(p_cadena,i,1) !~ expresion_regular) then
           if (p_forma = 'esc') then 
              caracteres_invalidos := caracteres_invalidos||chr(92)||chr(92)||'u'||to_hex(ascii(substr(p_cadena,i,1)));
           else
              caracteres_invalidos := caracteres_invalidos||substr(p_cadena,i,1);
           end if;
        end if;
    end loop;
    return caracteres_invalidos;
end if;
end;$_$;

CREATE FUNCTION comun.concato_add(p_uno text, p_dos text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  if p_uno IS NULL OR p_uno='' then
    if p_dos IS NULL OR p_dos='' then
	  RETURN '';
	else
	  RETURN p_dos;
	end if;
  else 
    if p_dos IS NULL OR p_dos='' then
	  RETURN p_uno;
	else
	  RETURN p_uno || ' ' || p_dos;
	end if;
  end if;  
END;
$$;

CREATE FUNCTION comun.concato_fin(p_uno text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN trim(p_uno);
END;
$$;

CREATE FUNCTION comun.crear_genericas_maxlen(tipo text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
BEGIN

EXECUTE replace(
$ESTO$
CREATE OR REPLACE FUNCTION comun.maxlen_unir(p_uno _TIPO_, p_dos _TIPO_) returns _TIPO_
as
$$
BEGIN
  if length(coalesce(p_uno::text,''))>length(coalesce(p_dos::text,'')) then
    RETURN p_uno;
  else 
    RETURN p_dos;
  end if;  
END;
$$
  LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION comun.maxlen_fin(p_uno _TIPO_) returns _TIPO_
as
$$
BEGIN
  RETURN p_uno;
END;
$$
  LANGUAGE 'plpgsql' IMMUTABLE;

DROP AGGREGATE IF EXISTS comun.maxlen (_TIPO_);
CREATE AGGREGATE comun.maxlen (_TIPO_)
(
    sfunc = comun.maxlen_unir,
    stype = _TIPO_,
    finalfunc = comun.maxlen_fin
);

GRANT EXECUTE ON FUNCTION comun.maxlen(_TIPO_) TO public; 
GRANT EXECUTE ON FUNCTION comun.maxlen_unir(_TIPO_, _TIPO_) TO public; 
GRANT EXECUTE ON FUNCTION comun.maxlen_fin(_TIPO_) TO public; 

$ESTO$, '_TIPO_', tipo);

END;
$_$;

select comun.crear_genericas_maxlen('boolean');
select comun.crear_genericas_maxlen('date');
select comun.crear_genericas_maxlen('double precision');
select comun.crear_genericas_maxlen('integer');
select comun.crear_genericas_maxlen('text');

CREATE FUNCTION comun.cuantos_dias_mes(pperiodo text, pdia text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT count(*)::integer
    FROM (SELECT generate_series(0,30) + DATE_TRUNC('month', (substr(pperiodo,2,4)||'-'||substr(pperiodo,7,2)||'-01')::date)::date as date) d
    WHERE EXTRACT('month' from d.date) = EXTRACT('month' from DATE_TRUNC('month', (substr(pperiodo,2,4)||'-'||substr(pperiodo,7,2)||'-01')::date))
          AND EXTRACT('dow' from d.date)::integer = (CASE WHEN pdia in ('Lunes','LUNES','lunes') THEN '1'
                                                WHEN pdia in ('Martes','MARTES','martes') THEN '2'
                                                WHEN pdia in ('Miercoles','MIERCOLES','miercoles') THEN '3'
                                                WHEN pdia in ('Jueves','JUEVES','jueves') THEN '4'
                                                WHEN pdia in ('Viernes','VIERNES','viernes') THEN '5'
                                                WHEN pdia in ('Sabado','SABADO','sabado') THEN '6'
                                                WHEN pdia in ('Domingo','DOMINGO','domingo') THEN '0'
                                                ELSE NULL
                                                end)::integer;
$$;

CREATE FUNCTION comun.date_from_epoch(p_epoch integer) RETURNS timestamp with time zone
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  return TIMESTAMP WITH TIME ZONE 'epoch' + p_epoch * INTERVAL '1 second';
END;
$$;

CREATE FUNCTION comun.es_numero(valor text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  valor_numerico double precision;
BEGIN
  valor_numerico:=valor::double precision;
  RETURN true;
EXCEPTION
  WHEN invalid_text_representation THEN
    RETURN false;  
  WHEN numeric_value_out_of_range THEN     
    return false;
END;
$$;

CREATE FUNCTION comun.lanza(p_mensaje text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  raise exception 'lanza %',p_mensaje;
end;
$$;

CREATE FUNCTION comun.para_ordenar_numeros(texto_con_numeros text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  rta text='';
  vPar record;
begin
  for vPar in 
      select regexp_matches(texto_con_numeros, E'([^0-9.]*|\\.)([0-9]*)', 'g') as conjunto
  loop
      rta=rta||vPar.conjunto[1];
      if vPar.conjunto[1]='.' then
          rta=rta||vPar.conjunto[2];
      elsif(length(vPar.conjunto[2])>0) then
          rta=rta||lpad(vPar.conjunto[2],9);
      end if;
  end loop;
  return rta;
end;
$$;

CREATE FUNCTION comun.probar(p_sentencia text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  execute p_sentencia;
  return 'Ejecuto sin excepciones';
exception
  when others then
    return sqlstate || ': ' || sqlerrm;
end;
$$;

CREATE FUNCTION comun.rstrpos(pfrase text, pparte text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  select length($1)-nullif(strpos(reverse($1),$2),0)+1-length($2);
$_$;

CREATE FUNCTION comun.sin_el_ultimo(pfrase text, pparte text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  select substr($1,1,comun.rstrpos($1,$2));
$_$;

CREATE AGGREGATE comun.concato(text) (
    SFUNC = comun.concato_add,
    STYPE = text,
    INITCOND = '',
    FINALFUNC = comun.concato_fin
);