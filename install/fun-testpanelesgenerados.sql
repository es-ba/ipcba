-- UTF8:Sí

CREATE OR REPLACE FUNCTION cvp.TestPanelesGenerados(PPeriodo text,PPanelDesde integer,PPanelHasta integer)
  RETURNS text   
  LANGUAGE 'plpgsql'
  SECURITY DEFINER
AS
$BODY$
declare
  vRta text;
  vpaneles RECORD;
begin
  vRta = 'N';
  
  FOR vpaneles IN
  select periodo, panel, fechageneracionpanel 
  from cvp.relpan
  where periodo = PPeriodo and PPanelDesde <= panel and panel <= PPanelHasta
  LOOP
    if vpaneles.fechageneracionpanel is not null then
      vRta = 'S';
    else
      vRta = 'N';
      EXIT;
    end if;
  END LOOP;
  return vRta;
end;
$BODY$
;