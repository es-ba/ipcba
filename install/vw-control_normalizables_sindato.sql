-- UTF8: Sí
CREATE OR REPLACE VIEW control_normalizables_sindato AS 
select ra.periodo, ra.producto, x.nombreproducto, ra.observacion, ra.informante, ra.atributo, ra.valor, ra.visita, ra.validar_con_valvalatr, 
          y.nombreatributo, pa.valornormal, pa.orden, pa.normalizable, pa.tiponormalizacion, pa.alterable, pa.prioridad,
          pa.operacion, pa.rangodesde, pa.rangohasta, pa.orden_calculo_especial,pa.tipo_promedio, 
          rp.formulario,rp.precio, rp.tipoprecio, rp.comentariosrelpre,
          rp.cambio,rp.precionormalizado, rp.especificacion, rp.ultima_visita
        , v.panel, v.tarea, v.encuestador||':'||pe.apellido as encuestador, v.recepcionista
  from cvp.relatr ra inner join cvp.ProdAtr pa on pa.atributo=ra.atributo and pa.producto=ra.producto -- FK:verificado
          inner join cvp.relpre rp on rp.periodo=ra.periodo and rp.visita=ra.visita and rp.producto=ra.producto and 
          rp.observacion=ra.observacion and rp.informante=ra.informante -- FK:verificada
          inner join cvp.relvis v on v.periodo=rp.periodo and v.informante=rp.informante and v.visita=rp.visita and v.formulario=rp.formulario -- PK:verificada
          join cvp.personal pe on v.encuestador = pe.persona
          join cvp.productos x on x.producto=ra.producto -- Fk verificada
          join cvp.atributos y on y.atributo=ra.atributo -- Fk verificada
  where pa.ValorNormal is not null
             and pa.normalizable='S' 
             and ra.Valor is null
             and rp.Precio is not null
  order by ra.periodo, ra.producto, ra.observacion, ra.informante, ra.atributo, ra.visita;

GRANT SELECT ON TABLE control_normalizables_sindato TO cvp_usuarios;
