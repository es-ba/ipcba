CREATE OR REPLACE FUNCTION calcular_precionormaliz_relpre_trg()
  RETURNS trigger AS 
$BODY$
DECLARE
vprecioatr RECORD;
vcant INTEGER;
existesemaforo INTEGER;
vtope INTEGER;
vacumulador double precision ARRAY;
voperacion CHARACTER VARYING;
vitipo INTEGER;
vvalorpesos double precision;

BEGIN

 SELECT 1 INTO existesemaforo
   FROM cvp.relpresemaforo a
     WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
       AND a.producto=NEW.producto AND a.observacion=NEW.observacion; 
 vtope=1;       
IF OLD.precio IS DISTINCT FROM NEW.precio  OR existesemaforo=1 THEN
  IF NEW.precio IS NOT NULL THEN
    
    SELECT count(*) into vcant --utilizo count porque hay productos con dos atributos normalizables
      FROM  cvp.prodatr pa     --ahora no se está consultado el valor de la variable vcant, sería solo informativa
      WHERE pa.producto=NEW.producto 
        AND pa.normalizable='S';
    
    vacumulador[vtope]=NEW.precio;
    FOR vprecioatr IN
      SELECT a.atributo,a.valor, pa.valornormal,pa.prioridad,pa.normalizable, pa.tiponormalizacion
        FROM  cvp.prodatr pa, cvp.relatr a 
        WHERE a.producto=pa.producto AND pa.atributo=a.atributo
          AND a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita AND a.producto=NEW.producto AND a.observacion=NEW.observacion 
          AND pa.normalizable='S'
       ORDER BY pa.prioridad
      LOOP
        vtope=vtope+1;
        IF vprecioatr.tiponormalizacion = 'Moneda' THEN
          SELECT valor_pesos INTO vvalorpesos
            FROM cvp.relmon
            WHERE periodo = NEW.periodo AND moneda=vprecioatr.valor;
          vprecioatr.valor = vvalorpesos::text;
        END IF;
        IF comun.es_numero(vprecioatr.valor) THEN
          vacumulador[vtope]=vprecioatr.valor::double precision; 
        ELSE
          vacumulador[vtope]=null;
          --vtope=vtope-1;
        END IF;          
        vitipo=1;
        voperacion=split_part(vprecioatr.tiponormalizacion,',',vitipo);
        --raise notice ' voperacion %', voperacion;
        WHILE voperacion IS DISTINCT FROM '' LOOP   
          CASE 
            WHEN  voperacion= '+'  THEN
              vacumulador[vtope-1]=vacumulador[vtope-1]+vacumulador[vtope];
              vtope=vtope -1;
            WHEN  voperacion='*'  THEN
              vacumulador[vtope-1]=vacumulador[vtope-1]*vacumulador[vtope];
              vtope=vtope -1; 
            WHEN  voperacion='1#'  THEN
              vtope=vtope +1;
              vacumulador[vtope]=1;
            WHEN  voperacion='2/'  THEN
              vacumulador[vtope]=vacumulador[vtope]/2;
            WHEN  voperacion='6/'  THEN
              vacumulador[vtope]=vacumulador[vtope]/6;   
            WHEN  voperacion='12/'  THEN
              vacumulador[vtope]=vacumulador[vtope]/12;   
            WHEN  voperacion='100/'  THEN
              vacumulador[vtope]=vacumulador[vtope]/100;   
            WHEN  voperacion='Normal' THEN
              IF comun.es_numero(vacumulador[vtope]::text) and vacumulador[vtope]<>0 THEN
                vacumulador[vtope-1]=vacumulador[vtope-1]/vacumulador[vtope]*vprecioatr.ValorNormal;
                vtope=vtope-1;               
              ELSE 
                vacumulador[vtope-1]=null;
                vtope=vtope-1;
              END IF;
            WHEN  voperacion='Moneda' THEN
                vacumulador[vtope-1]=vacumulador[vtope-1]*vacumulador[vtope]*vprecioatr.ValorNormal;
                vtope=vtope-1;
            WHEN voperacion='Bonificar' THEN
                --raise notice ' vacumulador[vtope-1] % vacumulador[vtope] % ', vacumulador[vtope-1], vacumulador[vtope];
                vacumulador[vtope-1]=vacumulador[vtope-1]*(100.0 - coalesce(vacumulador[vtope],0))/100.0;
                vtope=vtope-1;
            WHEN voperacion='#' THEN null;  
            ELSE
              RAISE EXCEPTION 'calcular_precionormaliz_relpre_trg(): Operador no considerado %', voperacion;
          END CASE;
          
          vitipo=vitipo+1;          
          voperacion=split_part(vprecioatr.tiponormalizacion,',',vitipo);          
        END LOOP;       
       
      END LOOP; 
      
  ELSE
    vacumulador[vtope]=null;
  END IF;
  IF vtope is distinct from 1 THEN
    RAISE EXCEPTION 'calcular_precionormaliz_relpre_trg(): ERROR, Queda informacion en el acumulador que no fue utilizada %', vtope;
  END IF;
  
  NEW.precionormalizado:=vacumulador[vtope];
  --raise notice 'Valorcalculado % ', vacumulador[vtope];
  IF existesemaforo=1 THEN
    DELETE FROM cvp.relpresemaforo a
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND a.producto=NEW.producto AND a.observacion=NEW.observacion;
  END IF; 
END IF;  
RETURN NEW;
 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relpre_senormaliza_precio_trg
  BEFORE UPDATE
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE calcular_precionormaliz_relpre_trg();