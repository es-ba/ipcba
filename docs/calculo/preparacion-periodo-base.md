# Preparaci�n del per�odo base

La funci�n periodobase() va a tomar como par�metro el per�odo y c�lculo hasta el
cual se quiere calcular. Para saber qu� per�odos tiene que calcular y c�mo puede
usar la sentencia `for v_calculo in select...` usando la siguiente consulta sql.
Esa consulta se para en el �ltimo mes a calcular y buscar el oriden del per�odo
base y desde all� va devolviendo cada uno de los renglones.

```sql
set search_path = cvp, public;

with recursive calculosr(periodo, calculo, esperiodobase, periodoanterior, calculoanterior) as
(
  select periodo, calculo, esperiodobase, periodoanterior, calculoanterior
    from calculos where periodo = 'a2016m01' and calculo = 0
  union
    select c.periodo, c.calculo, c.esperiodobase, c.periodoanterior, c.calculoanterior
	  from calculos c inner join calculosr r on r.calculoanterior = c.calculo and r.periodoanterior = c.periodo
)
select *
  from calculosr
  order by case when calculo < 0 then periodo else null end desc nulls last, case when calculo < 0 then null else periodo end;
```