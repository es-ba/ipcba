set search_path = cvp;
CREATE OR REPLACE VIEW cvp.calgru_promedios
 AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo,
    c.variacion,
    c.impgru,
    c.valorprel,
    c.valorgru,
    c.grupopadre,
    c.nivel,
    c.esproducto,
    c.ponderador,
    c.indice,
    c.indiceprel,
    c.incidencia,
    c.indiceredondeado,
    c.incidenciaredondeada,
    c.ponderadorimplicito,
    CASE WHEN p1.abierto = 'N' then (c0.valorgru + c1.valorgru + c.valorgru) / 3::double precision else null end AS valorgrupromedio
   FROM cvp.calgru c
     JOIN cvp.calculos_def cd ON c.calculo = cd.calculo
     JOIN cvp.calculos p ON c.periodo = p.periodo and c.calculo = p.calculo
     LEFT JOIN cvp.calgru c0 ON c0.periodo = p.periodoanterior AND p.calculoanterior = c0.calculo AND c.agrupacion = c0.agrupacion AND c.grupo = c0.grupo
     LEFT JOIN cvp.calgru c1 ON c1.periodo = cvp.moverperiodos(c.periodo, 1) AND c1.calculo = c.calculo AND c1.agrupacion = c.agrupacion AND c1.grupo = c.grupo
     LEFT JOIN cvp.calculos p1 ON c1.periodo = p1.periodo and c1.calculo = p1.calculo
  WHERE cd.principal;

-------------------------------------------------------
CREATE OR REPLACE FUNCTION validar_transmitir_canasta_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vesadministrador integer;
  vescoordinacion integer;
  vcalculoppal integer;
  vabiertosiguiente character varying(1):= null;
BEGIN

SELECT CASE WHEN usu_rol = 'analista' THEN 1 END, CASE WHEN usu_rol in ('coordinador','programador') THEN 1 END INTO vesadministrador, vescoordinacion
  FROM ipcba.usuarios
  WHERE usu_usu=current_user; 

SELECT calculo INTO vcalculoppal
  FROM cvp.calculos_def 
  WHERE principal;

SELECT abierto INTO vabiertosiguiente
  FROM cvp.calculos 
  WHERE periodo = cvp.moverperiodos(NEW.periodo,1) AND calculo = vcalculoppal;
  
IF OLD.transmitir_canastas IS DISTINCT FROM NEW.transmitir_canastas AND NEW.transmitir_canastas='N' THEN
   NEW.fechatransmitircanastas = null;
END IF;

IF OLD.transmitir_canastas IS DISTINCT FROM NEW.transmitir_canastas AND NEW.transmitir_canastas='S' THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
    IF NEW.abierto = 'N' THEN
        IF NEW.calculo <> vcalculoppal THEN
            RAISE EXCEPTION 'ERROR No se pueden transmitir canastas para cálculos provisorios';
        ELSE
            IF vabiertosiguiente = 'N' THEN
                NEW.fechatransmitircanastas = CURRENT_TIMESTAMP(3);
            ELSE
                RAISE EXCEPTION 'ERROR No se pueden transmitir canastas si el cálculo siguiente no está cerrado';
            END IF;
        END IF;
    ELSE
     RAISE EXCEPTION 'ERROR No se pueden transmitir canastas porque aún no se cerró el cálculo';
    END IF;
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY INVOKER;
------------------------------------------
