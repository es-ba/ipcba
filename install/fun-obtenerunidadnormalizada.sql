CREATE OR REPLACE FUNCTION obtenerunidadnormalizada(pproducto TEXT)
  RETURNS text AS
$BODY$
DECLARE
  vatr RECORD;
  vcad TEXT:='';
 
BEGIN
  FOR vatr IN
    SELECT pa.atributo, a.unidaddemedida, a.nombreatributo, pa.valorNormal 
      FROM  cvp.prodatr pa 
	    JOIN cvp.atributos a ON pa.atributo = a.atributo
      WHERE pa.producto= pproducto 
        AND pa.normalizable='S' 
	  ORDER BY pa.orden
  LOOP
    vcad= vcad || vatr.valorNormal || COALESCE(vatr.unidaddemedida,vatr.nombreatributo,'') || ' '  ;
  END LOOP;
  vcad= TRIM(vcad);
 
  RETURN vcad;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  