CREATE OR REPLACE FUNCTION periodo_igual_mes_anno_anterior(pperiodo text)
  RETURNS text AS $$
    SELECT 'a'||(substr($1,2,4)::integer-1)||'m'||substr($1,7,2)
  $$ 
  LANGUAGE SQL IMMUTABLE;
