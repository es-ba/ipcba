-- FUNCTION: cvp.actualizacion_precionormalizado(text)

-- DROP FUNCTION cvp.actualizacion_precionormalizado(text);

CREATE OR REPLACE FUNCTION cvp.actualizacion_precionormalizado(
	pperiodo text)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$

DECLARE
vprecios RECORD;
vprecioatr RECORD;
vpnormalizado cvp.relpre.precionormalizado%TYPE;
cantnormalizados integer:=0;
vcant INTEGER;
BEGIN
 cantnormalizados=0;
 FOR vprecios IN
  SELECT informante, visita, producto, observacion, precio
    FROM  cvp.relpre 
    WHERE periodo=pperiodo
    ORDER BY informante,visita,producto,observacion 
 LOOP
   vpnormalizado=null;
   SELECT count(*) into vcant --utilizo count porque hay productos con dos atributos normalizables
     FROM  cvp.prodatr pa 
     WHERE pa.producto=vprecios.producto 
       AND pa.normalizable='S';
   --raise notice 'Primer cursor Inf % Vis % Producto % Obs % precio % atributonormalizable % ', vprecios.informante, vprecios.visita, vprecios.producto, vprecios.observacion, vprecios.precio, vcant;    
   IF vcant =0 THEN 
     vpnormalizado=vprecios.precio;
   ELSE
     FOR vprecioatr IN
       SELECT a.atributo,a.valor, pa.valornormal,pa.prioridad,pa.normalizable
         FROM  cvp.prodatr pa, cvp.relatr a 
         WHERE a.producto=pa.producto AND pa.atributo=a.atributo
           AND a.periodo=pperiodo AND vprecios.informante=a.informante AND vprecios.visita=a.visita AND vprecios.producto=a.producto AND vprecios.observacion=a.observacion 
           AND pa.normalizable='S'
         ORDER BY pa.prioridad
     LOOP
     --  raise notice 'Segundo cursor Inf % Vis % Producto % Obs % precio % valoratr % valornormal % ', vprecios.informante, vprecios.visita, vprecios.producto, vprecios.observacion, vprecios.precio, vprecioatr.valor, vprecioatr.valornormal;
       IF  vprecioatr.valor is not null THEN
         IF (vprecioatr.prioridad=1 OR vprecioatr.prioridad is null) THEN
           vpnormalizado=vprecios.precio/vprecioatr.valor::double precision*vprecioatr.ValorNormal;
         ELSE 
           vpnormalizado=vpnormalizado/vprecioatr.valor::double precision*vprecioatr.ValorNormal;
         END IF;
       ELSE 
         vpnormalizado=null;
       END IF;
     END LOOP;
     
  END IF;
     UPDATE cvp.relpre  SET precionormalizado=vpnormalizado
       WHERE periodo=pperiodo AND informante=vprecios.informante AND visita=vprecios.visita 
         AND producto=vprecios.producto 
         AND observacion=vprecios.observacion ;
     --raise notice 'Al actualizar Inf % Vis % Producto % Obs % precio %  precionormalizado % ', vprecios.informante, vprecios.visita, vprecios.producto, vprecios.observacion, vprecios.precio, vpnormalizado;     
     cantnormalizados=cantnormalizados +1;
 END LOOP;    
RETURN cantnormalizados;
END;

$BODY$;

ALTER FUNCTION cvp.actualizacion_precionormalizado(text)
    OWNER TO cvpowner;