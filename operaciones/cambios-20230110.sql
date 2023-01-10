set search_path = cvp;
CREATE OR REPLACE FUNCTION validar_transmitir_canasta_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vesadministrador integer;
  vescoordinacion integer;
  vcalculoppal integer;
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
SELECT calculo INTO vcalculoppal
  FROM cvp.calculos_def 
  WHERE principal;
IF OLD.transmitir_canastas IS DISTINCT FROM NEW.transmitir_canastas AND NEW.transmitir_canastas='S' THEN
  IF vesadministrador=1 OR vescoordinacion=1 THEN
    IF NEW.abierto = 'N' THEN
        IF NEW.calculo <> vcalculoppal THEN
            RAISE EXCEPTION 'ERROR No se pueden transmitir canastas para cálculos provisorios';
        ELSE
            NEW.fechatransmitircanastas = CURRENT_TIMESTAMP(3);
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