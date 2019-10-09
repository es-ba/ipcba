CREATE OR REPLACE FUNCTION verificar_act_promedio()
  RETURNS trigger AS
$BODY$
DECLARE
 vpromdivant double precision;
 vvariacion double precision;
 vpromedioext double precision;
BEGIN
  IF TG_OP='UPDATE' THEN
     vvariacion:=OLD.variacion;
     vpromedioext = OLD.promedioext;
  ELSE
     vvariacion:=null;
  END IF;

  if vvariacion is distinct from NEW.variacion then
    SELECT promdiv INTO vpromdivant 
      FROM cvp.calculos c left join cvp.caldiv d on d.periodo = c.periodoanterior and d.calculo = c.calculoanterior 
      WHERE d.division = '0' and c.periodo = NEW.periodo and c.calculo = NEW.calculo and d.producto = NEW.producto;
    NEW.promedioext := (NEW.variacion+100)*vpromdivant/100;
  else
    if vpromedioext is distinct from NEW.promedioext then
        SELECT promdiv INTO vpromdivant 
          FROM cvp.calculos c left join cvp.caldiv d on d.periodo = c.periodoanterior and d.calculo = c.calculoanterior
                              left join cvp.productos p on d.producto = p.producto      
          WHERE d.division = '0' and c.periodo = NEW.periodo and c.calculo = NEW.calculo and d.producto = NEW.producto and p.tipoexterno = 'D';
        if vpromdivant is null then 
            RAISE EXCEPTION 'El producto % no es externo definitivo. Sólo se permite ingresar variación', NEW.producto;
        else
            NEW.variacion := ((NEW.promedioext*100)/vpromdivant)-100;
        end if;
    end if;
  end if;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER novprod_act_promedio_trg 
   BEFORE INSERT OR UPDATE 
   ON novprod 
   FOR EACH ROW EXECUTE PROCEDURE verificar_act_promedio();
