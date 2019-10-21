create or replace view gru_prod as 
with recursive productos_de(agrupacion, grupo_padre, producto) as (
    select agrupacion, grupopadre as grupo_padre, grupo as producto
      from grupos 
      where esproducto='S'
    union all
    select p.agrupacion, g.grupopadre as grupo_padre, p.producto
      from productos_de p inner join grupos g on g.grupo=p.grupo_padre and g.agrupacion=p.agrupacion
      where g.grupopadre is not null
  )
select agrupacion, grupo_padre, producto
  from productos_de
  order by producto, agrupacion, grupo_padre;