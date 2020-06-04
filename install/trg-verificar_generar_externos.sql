CREATE OR REPLACE FUNCTION verificar_generar_externos()
  RETURNS trigger AS
$BODY$
BEGIN
    if OLD.fechageneracionexternos is null and NEW.fechageneracionexternos is not null
       or OLD.fechageneracionexternos<>NEW.fechageneracionexternos
    then
        --NovProd (externos)
        INSERT INTO cvp.NovProd (periodo, calculo, producto, promedioext, variacion)
        (SELECT l.periodo, l.calculo, c.producto, c.promdiv, 0
            FROM cvp.calculos l
            LEFT JOIN cvp.caldiv c ON c.periodo = l.periodoanterior AND c.calculo = l.calculoanterior
            LEFT JOIN cvp.productos p ON c.producto = p.producto
            LEFT JOIN cvp.novprod n ON l.periodo = n.periodo AND l.calculo = n.calculo AND c.producto = n.producto 
            WHERE l.periodo = NEW.periodo AND l.calculo = NEW.calculo /*actual*/ 
                AND c.division = '0'
                AND p.tipoexterno IS NOT NULL /*productos seleccionados para ser externos, Definitivos o Provisorios*/ 
                AND n.producto IS NULL /*los que aún no están en novprod*/
        );
    end if;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER calculos_ext_trg 
   BEFORE UPDATE 
   ON calculos 
   FOR EACH ROW EXECUTE PROCEDURE verificar_generar_externos();
