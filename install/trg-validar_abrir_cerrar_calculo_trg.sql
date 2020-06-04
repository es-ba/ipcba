CREATE OR REPLACE FUNCTION validar_abrir_cerrar_calculo_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vPeriodo_1  text;  
  vCalculo_1  integer;
  vAbierto_1  character varying(1);
  vIngresando character varying(1); 
  vrecsig     record;
  vesadministrador integer;
  vescoordinacion integer;
  vhayprovisorios integer;
  vNOestantodosextdef integer;
  vestimacion integer;

BEGIN

SELECT 1 INTO vesadministrador
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_administrador' ; 
SELECT 1 INTO vescoordinacion
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_coordinacion' ;    

IF OLD.abierto IS DISTINCT FROM NEW.abierto AND NEW.abierto='N' THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
      SELECT periodoanterior, calculoanterior, estimacion INTO vPeriodo_1, vCalculo_1, vestimacion
        FROM cvp.Calculos
        WHERE periodo=NEW.periodo AND calculo=NEW.calculo ;
      IF (vPeriodo_1 IS NULL AND vCalculo_1 IS NULL) OR (vPeriodo_1=NEW.periodo AND vCalculo_1=NEW.calculo) THEN -- periodo inicial
        vAbierto_1='N';
      ELSE 
        SELECT abierto INTO vAbierto_1
          FROM cvp.Calculos
          WHERE periodo=vPeriodo_1 AND calculo=vCalculo_1;
      END IF;
      SELECT ingresando INTO vIngresando
        FROM cvp.Periodos
        WHERE periodo=NEW.Periodo;
      SELECT DISTINCT 1 INTO vhayProvisorios
        FROM cvp.caldiv c 
        INNER JOIN cvp.novprod n ON c.producto = n.producto and c.calculo = n.calculo and c.periodo = n.periodo
        INNER JOIN cvp.productos p ON c.producto = p.producto
        WHERE c.periodo=NEW.periodo AND c.calculo=NEW.calculo AND coalesce(n.tipoexterno, p.tipoexterno) is distinct from 'D' AND c.division = '0';
      SELECT DISTINCT 1 INTO vNOestantodosextdef 
        FROM cvp.productos p LEFT JOIN cvp.novprod n ON p.producto = n.producto AND n.periodo = NEW.periodo AND n.calculo = NEW.calculo
        WHERE p.tipoexterno = 'D' and n.periodo is null;        
    --Si vAbierto_1 ='N' AND vIngresando='N' seria correcto permitir cerrar calculo
      IF vAbierto_1 ='S' THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si no esta cerrado el anterior';
      END IF;
      IF vIngresando='S'  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si no esta cerrado el periodo correspondinete';
      END IF;
      IF vhayProvisorios=1  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si hay externos provisorios el periodo correspondinete';
      END IF;
      IF vNOestantodosextdef=1 THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo si NO están todos los externos habituales el periodo correspondinete';
      END IF;
      IF vestimacion>0  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo con una estimación distinta de 0';
      END IF;
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
--Si vAbiertosig ='S' seria correcto abrir calculo
IF OLD.abierto IS DISTINCT FROM NEW.abierto AND NEW.abierto='S' THEN 
  IF vescoordinacion=1 THEN
      FOR vrecsig in
        SELECT periodo, calculo, abierto 
          FROM cvp.Calculos
          WHERE periodoanterior=NEW.Periodo AND calculoanterior=NEW.Calculo 
            AND (periodoanterior<>Periodo OR calculoanterior<>Calculo)
      LOOP
          IF vrecsig.abierto='N' THEN
            RAISE EXCEPTION 'ERROR no se puede reabrir porque el siguiente periodo "%" esta cerrado', vrecsig.periodo;
          END IF;
      END LOOP;   
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
RETURN NEW;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY INVOKER;

CREATE TRIGGER calculos_controlar_abrir_cerrar_calculo_trg 
   BEFORE UPDATE 
   ON calculos 
   FOR EACH ROW EXECUTE PROCEDURE validar_abrir_cerrar_calculo_trg();
