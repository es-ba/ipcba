CREATE OR REPLACE FUNCTION devolver_mes_anio(pperiodo text)
  RETURNS text AS $$
    SELECT REPLACE(TO_CHAR(TO_DATE(SUBSTR($1,7,2)||'/'||SUBSTR($1,2,4),'mm/yyyy'),'TMMonth yyyy'), ' ', ' de ') 
  $$ 
  LANGUAGE SQL;
