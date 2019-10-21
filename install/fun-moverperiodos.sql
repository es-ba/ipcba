CREATE OR REPLACE FUNCTION moverperiodos(DePeriodo text, CuantosPeriodos integer)
  RETURNS text AS
$BODY$
--Retorna el periodo resultante de mover CuantosPeriodos a partir de DePeriodo
declare
  DPeriodo date;
  PeriodoHasta date;
  HastaPeriodo text;
  HMes text;
begin
DPeriodo := substr(DePeriodo,2,4)||'-'||substr(DePeriodo,7,2)||'-01' as date; --primer día del periodo DePeriodo
PeriodoHasta := DPeriodo + CuantosPeriodos*'1  month'::interval; 
if date_part('month',PeriodoHasta) < 10 then
	HMes:='0'||date_part('month',PeriodoHasta) as text;
else
	HMes:=date_part('month',PeriodoHasta) as text;
end if;	  
HastaPeriodo := 'a'||date_part('year',PeriodoHasta)||'m'||HMes;
return HastaPeriodo;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE 
  SECURITY DEFINER;
