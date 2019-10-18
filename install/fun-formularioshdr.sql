-- FUNCTION: cvp.formularioshdr(text, integer, integer, date, text)

-- DROP FUNCTION cvp.formularioshdr(text, integer, integer, date, text);

CREATE OR REPLACE FUNCTION cvp.formularioshdr(
	pperiodo text,
	pinformante integer,
	pvisita integer,
	pfechasalida date,
	pencuestador text)
    RETURNS text
    LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER 
AS $BODY$
declare
  vForm record;
  vRta text:='';
begin
  for vForm in 
    select f.formulario, f.nombreformulario
	  from cvp.relvis r inner join cvp.formularios f on r.formulario=f.formulario
	  where r.periodo=pPeriodo
	    and r.informante=pInformante
		and r.visita=pVisita
		and r.fechasalida = pFechasalida
		and r.encuestador = pEncuestador
	  order by f.formulario
  loop
    vRta:=vRta || chr(10) || vForm.formulario || ' ' || vForm.nombreformulario;
  end loop;  
  if vRta='' then
    return '';
  else
    return substr(vRta,2);
  end if;
end;
$BODY$;
