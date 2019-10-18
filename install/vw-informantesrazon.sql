CREATE OR REPLACE VIEW informantesrazon AS
SELECT periodo, nullif(trim(replace(r.razon,chr(10),'')),'') as razon, 
  (z.nombrerazon||coalesce('~'||x.nombrerazon,''))::character varying(250) as nombrerazon, 
  sum(length(formularios)-length(replace(formularios,chr(10),''))+1)::integer as cantFormularios,
  count(distinct informante)::integer cantInformantes
  FROM cvp.hojaderuta r
  LEFT JOIN cvp.razones z ON  
   CASE WHEN strpos(r.razon,'~') > 0 THEN trim(substr(replace(r.razon,chr(10),''),1,strpos(replace(r.razon,chr(10),''),'~')-1)) ELSE trim(replace(r.razon,chr(10),'')) END = z.razon::text
  LEFT JOIN cvp.razones x ON 
   CASE WHEN strpos(r.razon,'~') > 0 THEN trim(substr(replace(r.razon,chr(10),''),strpos(replace(r.razon,chr(10),''),'~')+1)) ELSE '' END = x.razon::text
  WHERE r.visita = 1
  GROUP BY 1,2,3
  ORDER BY 1,2,3;

GRANT SELECT ON TABLE informantesrazon TO cvp_usuarios;
GRANT SELECT ON TABLE informantesrazon TO cvp_recepcionista;

