set search_path = cvp;
set role cvpowner;
--no vuelve a generar una vez generado

CREATE OR REPLACE FUNCTION verificar_generar_formulario()
  RETURNS trigger AS
$BODY$
DECLARE
  -- V080923
  -- Modif: V100707
  dummy text;
BEGIN
  IF TG_OP='UPDATE' THEN
    IF (OLD.razon IS DISTINCT FROM NEW.razon OR NEW.preciosgenerados) AND NEW.visita = 1 THEN
       NEW.fechageneracion:= current_timestamp(3);
       dummy:=cvp.generar_formulario(new.periodo,new.informante,new.formulario,new.fechageneracion); 
	   NEW.preciosgenerados:= false;
    END IF;
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

---------------------------------------------------

CREATE OR REPLACE FUNCTION validar_recepcion_trg()
    RETURNS trigger AS
$BODY$
DECLARE
  vesadministrador integer;
  vescoordinacion integer;
  vesrecepcion integer;
  vhaynormalizablessindato integer;
  vhayatributosfueraderango integer;
  vhaypreciosincompletos integer;
  vhayefectivasinprecio integer;
  vhayvigenciasincorrectas integer;
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
SELECT 1 INTO vesrecepcion
  FROM pg_roles p,  
    (SELECT r.rolname, r.oid,m.member, m.roleid  
       FROM pg_auth_members m, pg_roles r
       WHERE m.member=r.oid 
         AND r.rolname=current_user
    )a
  WHERE a.roleid=p.oid AND p.rolname='cvp_recepcionista' ;    
  
IF OLD.verificado_rec IS DISTINCT FROM NEW.verificado_rec THEN
  IF NEW.verificado_rec='S' AND (vesadministrador=1 OR vescoordinacion=1 OR vesrecepcion=1) THEN -- estoy verificando la recepción
      --Aqui van todos los controles:
      
      --Se ha ingresado la razon
      --Terminado de ingresar
      --Normalizables sin dato: control_normalizables_sindato
      --Inconsistencias de atributos: control_atributos
      --Efectivos sin precio: hdrexportarefectivossinprecio
      --Inconsistencias de precios ¿? :control_rangos (sólo como chequeo, no impide la verificación)
      --Control de atributo vigencia :controlvigencias
    IF OLD.razon IS NULL THEN
      RAISE EXCEPTION 'ERROR aún no se ha ingresado razón';
    ELSE
    SELECT 1 INTO vhaypreciosincompletos
      FROM cvp.relpre r LEFT JOIN cvp.tipopre t on r.tipoprecio = t.tipoprecio  
      WHERE NEW.razon = 1 and periodo = NEW.periodo and informante = NEW.informante and visita = NEW.visita and formulario = NEW.formulario and coalesce(t.inconsistente, true)
      LIMIT 1;
      IF vhaypreciosincompletos THEN
        RAISE EXCEPTION 'ERROR hay precios sin ingresar en formulario: % ', NEW.formulario;
      ELSE
        SELECT 1 INTO vhaynormalizablessindato
          FROM cvp.control_normalizables_sindato
          WHERE periodo = NEW.periodo and informante = NEW.informante and visita = NEW.visita and formulario = NEW.formulario
          LIMIT 1;
        IF vhaynormalizablessindato=1 THEN
          RAISE EXCEPTION 'ERROR hay normalizables sin dato en formulario: % ', NEW.formulario;
        ELSE
          SELECT 1 INTO vhayatributosfueraderango
            FROM cvp.control_atributos
            WHERE periodo = NEW.periodo and informante = NEW.informante and visita = NEW.visita and formulario = NEW.formulario
            LIMIT 1;
          IF vhayatributosfueraderango=1 THEN
            RAISE EXCEPTION 'ERROR hay atributos fuera de rango en formulario: % ', NEW.formulario;
          ELSE
            SELECT 1 INTO vhayefectivasinprecio
              FROM cvp.hdrexportarefectivossinprecio
              WHERE periodo = NEW.periodo and informante = NEW.informante and visita = NEW.visita and formulario = NEW.formulario
              LIMIT 1;
            IF vhayefectivasinprecio=1 THEN
              RAISE EXCEPTION 'ERROR hay respuesta efectiva sin precios en formulario: % ', NEW.formulario;
            ELSE
              SELECT 1 INTO vhayvigenciasincorrectas
                FROM cvp.controlvigencias
                WHERE periodo = NEW.periodo and informante = NEW.informante
              LIMIT 1;
              IF vhayvigenciasincorrectas=1 THEN
                  RAISE EXCEPTION 'ERROR hay vigencias incorrectas en informante: % ', NEW.informante;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;        
    END IF;
  ELSIF NEW.verificado_rec='S' OR not(vesadministrador=1 OR vescoordinacion=1 OR vesrecepcion=1) THEN --quiere verificar (o desverificar) pero no tiene los permisos
     RAISE EXCEPTION 'ERROR Perfil no autorizado para realizar esta operacion "%" ', current_user;
  END IF;     
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY INVOKER;

