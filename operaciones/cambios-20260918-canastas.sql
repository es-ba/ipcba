--CALCULO DE LAS CANASTAS AISTADAS DEL CALCULO PRINCIPAL
set search_path = cvp;
set role cvpowner;

ALTER TABLE calculos ADD COLUMN fechacalculo_ccc timestamp without time zone; --fecha en que se calculó la canasta aislada del calculo principal 
ALTER TABLE calculos ADD COLUMN abierto_ccc cvp.sino_dom DEFAULT 'S'; 
--historico:
do $SQL_ENANCE$
 begin
 PERFORM ccc.enance_table('calculos','periodo,calculo');
 end
$SQL_ENANCE$;
--agrego nueva forma de registrar los cambios, deshabilito la forma anterior
ALTER TABLE calculos DISABLE TRIGGER hisc_trg;

----------------------------------------------------
CREATE OR REPLACE FUNCTION verificar_lanzamiento_calculo_ccc()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
DECLARE
  dummy text;
BEGIN
  if TG_OP='UPDATE' then
    if OLD.fechacalculo_ccc is null and NEW.fechacalculo_ccc is not null
       or OLD.fechacalculo_ccc<>NEW.fechacalculo_ccc
    then
       dummy:=ccc.CalcularCCCUnPeriodo(new.periodo,new.calculo); 
    end if;
  end if;
  RETURN NEW;
END;
$BODY$;

CREATE OR REPLACE TRIGGER calculos_ccc_lan_trg
    BEFORE INSERT OR UPDATE 
    ON calculos
    FOR EACH ROW
    EXECUTE FUNCTION verificar_lanzamiento_calculo_ccc();
----------------------------------------------------
CREATE OR REPLACE FUNCTION ccc.verificar_abierto_ccc()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    vabierto_ccc varchar(1);
    vPeriodo varchar(20);
    vtabla      varchar(100);
BEGIN
    vtabla= TG_TABLE_NAME;
    IF TG_OP='DELETE' THEN
       vPeriodo:=OLD.Periodo;
    ELSE
       vPeriodo:=NEW.Periodo;
    END IF;
    SELECT abierto_ccc INTO vabierto_ccc
      FROM cvp.calculos c 
      JOIN cvp.calculos_def cd ON c.calculo = cd.calculo
      WHERE c.periodo = vPeriodo and principal;
    IF vabierto_ccc = 'N' then
        RAISE EXCEPTION 'Calculo de Canasta Cerrado. Actualizacion no permitida en tabla %',vtabla;
        RETURN NULL;
    END IF;    
    if TG_OP='DELETE' then
       RETURN OLD;
    ELSE   
       RETURN NEW;
    END IF;
END;
$BODY$;

set search_path = ccc;

CREATE OR REPLACE TRIGGER novservdom_abi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON ccc.novservdom
    FOR EACH ROW
    EXECUTE FUNCTION ccc.verificar_abierto_ccc();
------------------------------------------------------------------
set search_path = cvp;

UPDATE calculos c SET abierto_ccc = cc.abierto
FROM calculos cc 
WHERE c.calculo = cc.calculo and c.periodo = cc.periodo;

-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION validar_abrir_cerrar_calculo_ccc_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vPeriodo_1  text;  
  vCalculo_1  integer;
  vAbierto_1  character varying(1);
  vrecsig     record;

BEGIN

IF OLD.abierto_ccc IS DISTINCT FROM NEW.abierto_ccc AND NEW.abierto_ccc='N' THEN
      SELECT periodoanterior, calculoanterior INTO vPeriodo_1, vCalculo_1
        FROM cvp.Calculos
        WHERE periodo=NEW.periodo AND calculo=NEW.calculo ;
      IF (vPeriodo_1 IS NULL AND vCalculo_1 IS NULL) OR (vPeriodo_1=NEW.periodo AND vCalculo_1=NEW.calculo) THEN -- periodo inicial
        vAbierto_1='N';
      ELSE 
        SELECT abierto_ccc INTO vAbierto_1
          FROM cvp.Calculos
          WHERE periodo=vPeriodo_1 AND calculo=vCalculo_1;
      END IF;
      IF vAbierto_1 ='S' THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo ccc si no esta cerrado el anterior';
      END IF;
      IF NEW.abierto='S'  THEN
        RAISE EXCEPTION 'ERROR no se puede cerrar un calculo ccc si no esta cerrado el calculo ipc correspondinete';
      END IF;
END IF;
IF OLD.abierto_ccc IS DISTINCT FROM NEW.abierto_ccc AND NEW.abierto_ccc='S' THEN 
      FOR vrecsig in
        SELECT periodo, calculo, abierto_ccc 
          FROM cvp.Calculos
          WHERE periodoanterior=NEW.Periodo AND calculoanterior=NEW.Calculo 
            AND (periodoanterior<>Periodo OR calculoanterior<>Calculo)
      LOOP
          IF vrecsig.abierto_ccc='N' THEN
            RAISE EXCEPTION 'ERROR no se puede reabrir porque el siguiente periodo "%" esta cerrado', vrecsig.periodo;
          END IF;
      END LOOP;   
END IF;
RETURN NEW;
END;

$BODY$
  LANGUAGE plpgsql;
  
ALTER FUNCTION validar_abrir_cerrar_calculo_ccc_trg()
    OWNER TO cvpowner;

CREATE TRIGGER calculos_controlar_abrir_cerrar_calculo_ccc_trg 
   BEFORE UPDATE 
   ON calculos 
   FOR EACH ROW EXECUTE PROCEDURE validar_abrir_cerrar_calculo_ccc_trg();

-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION validar_abrir_cerrar_calculo_trg()
  RETURNS trigger 
  LANGUAGE 'plpgsql'
AS
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
      IF NEW.abierto_ccc='N'  THEN
        RAISE EXCEPTION 'ERROR no se puede reabrir un calculo cuando el cálculo ccc está cerrado';
      END IF;
  ELSE
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;
END IF;
RETURN NEW;
END;
$BODY$;