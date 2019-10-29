CREATE OR REPLACE FUNCTION matrizresultados_atributos_fun(pperiodo TEXT, pinformante INTEGER, pproducto TEXT, pobs INTEGER, pvisita INTEGER)
  RETURNS text AS
$BODY$
DECLARE
  vatr RECORD;
  vcad TEXT:='';
  vmarca TEXT;
BEGIN
  SELECT ra.valor INTO vmarca
      FROM  cvp.prodatr pa, cvp.relatr ra , cvp.atributos a
      WHERE ra.producto=pa.producto AND ra.atributo=pa.atributo AND a.atributo= pa.atributo
        AND ra.periodo=pperiodo AND ra.informante=pinformante AND ra.visita=pvisita 
        AND ra.producto=pproducto AND ra.observacion=pobs AND ra.atributo=13 ;
  vcad= COALESCE(vmarca,'');
  FOR vatr IN
    SELECT ra.atributo,ra.valor, a.unidaddemedida, a.nombreatributo
      FROM  cvp.prodatr pa, cvp.relatr ra , cvp.atributos a
      WHERE ra.producto=pa.producto AND ra.atributo=pa.atributo AND a.atributo= pa.atributo
        AND ra.periodo=pperiodo AND ra.informante=pinformante AND ra.visita=pvisita AND ra.producto=pproducto AND ra.observacion=pobs 
        AND pa.normalizable='S' 
      ORDER BY pa.orden
  LOOP
    vcad=vcad || '- ' || vatr.valor || ' ' || COALESCE(vatr.unidaddemedida,vatr.nombreatributo,'') ;
  END LOOP;
  if substr(vcad,1,1)='-' THEN
     vcad= substr(vcad,2);
  end if;
  RETURN vcad;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
