CREATE OR REPLACE FUNCTION estadoinformante(
	pperiodo text,
	pinformante integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE 
AS $BODY$
DECLARE
vInformantes RECORD;
vEstado TEXT:='Inactivo';
mperiodo character varying(11);
mvisita integer;
vicierre cvp.sino_dom;

BEGIN

FOR vInformantes IN
  SELECT DISTINCT informante, formulario
    FROM cvp.relvis
    WHERE informante = pinformante
LOOP    
  SELECT max(periodo) INTO mperiodo
    FROM cvp.relvis
    WHERE informante = vInformantes.informante 
          AND formulario = vInformantes.formulario 
          AND periodo <= pperiodo;

  IF mperiodo is not null THEN
    SELECT max(visita) INTO mvisita
      FROM cvp.relvis
      WHERE informante = vInformantes.informante 
            AND formulario = vInformantes.formulario 
            AND periodo = mperiodo;

    SELECT z.escierredefinitivoinf INTO vicierre
      FROM cvp.relvis r
        LEFT JOIN cvp.razones z ON r.razon = z.razon           
      WHERE r.periodo = mperiodo 
            AND r.visita = mvisita 
            AND informante = vInformantes.informante  
            AND formulario = vInformantes.formulario;
    IF COALESCE(vicierre,'N') = 'S' THEN
      vEstado = 'De Baja';
      EXIT;
    ELSE
      vEstado = 'Activo';
    END IF;
  END IF;
END LOOP;

RETURN vEstado;
 
end;
$BODY$;
