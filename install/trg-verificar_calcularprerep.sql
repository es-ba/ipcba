CREATE OR REPLACE FUNCTION verificar_CalcularPreRep()
  RETURNS trigger AS
$BODY$
DECLARE
  dummy text;
  hayPreRepLote1 integer;
  hayPreRepLote2 integer;
BEGIN
  if TG_OP='UPDATE' then
    SELECT distinct 1 INTO hayPreRepLote1
    FROM cvp.prerep p 
    LEFT JOIN cvp.relpre r on p.periodo = r.periodo and p.informante = r.informante and p.producto = r.producto
    LEFT JOIN cvp.relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
    WHERE p.periodo = NEW.periodo and v.panel >= 1 and v.panel <= 10;

    SELECT distinct 1 INTO hayPreRepLote2
    FROM cvp.prerep p 
    LEFT JOIN cvp.relpre r on p.periodo = r.periodo and p.informante = r.informante and p.producto = r.producto
    LEFT JOIN cvp.relvis v on r.periodo = v.periodo and r.informante = v.informante and r.visita = v.visita and r.formulario = v.formulario
    WHERE p.periodo = NEW.periodo and v.panel >= 11 and v.panel <= 20;
    
    if OLD.fechaCalculoPreRepLote1 is null and NEW.fechaCalculoPreRepLote1 is not null and hayPreRepLote1 is null
       --or OLD.fechaCalculoPreRepLote1<>NEW.fechaCalculoPreRepLote1 
       --27/11/17 no se va a recalcular la repregunta si ya se calculó una vez (Requerimiento IPCBA 371)
       --16/10/18 no se va a recalcular la repregunta si ya se calculó una vez para el bloque de 4 meses de impresión al que pertenece
       --el periodo (Requerimiento IPCBA 439)
    then
		dummy:=cvp.CalcularPreRep(new.periodo,1);
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,1),1);	   
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,2),1);	   
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,3),1);
    else
        if OLD.fechaCalculoPreRepLote1 is distinct from NEW.fechaCalculoPreRepLote1
        then --NO dejo que cambie la fecha de calculo de Prerep
           NEW.fechaCalculoPreRepLote1:=OLD.fechaCalculoPreRepLote1;
        end if;        
    end if;
    if OLD.fechaCalculoPreRepLote2 is null and NEW.fechaCalculoPreRepLote2 is not null and hayPreRepLote2 is null
       --or OLD.fechaCalculoPreRepLote2<>NEW.fechaCalculoPreRepLote2
       --27/11/17 no se va a recalcular la repregunta si ya se calculó una vez (Requerimiento IPCBA 371)
       --16/10/18 no se va a recalcular la repregunta si ya se calculó una vez para el bloque de 4 meses de impresión al que pertenece
       --el periodo (Requerimiento IPCBA 439)
    then
		dummy:=cvp.CalcularPreRep(new.periodo,2); 
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,1),2);	   
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,2),2);	   
		dummy:=cvp.CalcularPreRep(cvp.MoverPeriodos(new.periodo,3),2);	   
    else
        if OLD.fechaCalculoPreRepLote2 is distinct from NEW.fechaCalculoPreRepLote2
        then --NO dejo que cambie la fecha de calculo de Prerep
           NEW.fechaCalculoPreRepLote2:=OLD.fechaCalculoPreRepLote2;
        end if;        
    end if;
  end if;
  RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER periodos_PreRep_trg
  BEFORE INSERT OR UPDATE
  ON periodos
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_CalcularPreRep();
