CREATE OR REPLACE FUNCTION verificar_ingresando()
  RETURNS trigger AS
$BODY$
DECLARE
    vIngresando varchar(1);
    vPeriodo varchar(20);
    vCerrarIngresoCampoHastaPanel integer;
    vpanel      INTEGER;
    vformulario INTEGER;
    vtabla      varchar(100);
    vinformante integer;
    vvisita     integer;
    vproducto   text;
    vobservacion integer;
    vatributo   integer;
    voperativo  text;
    vesadministrador integer;
    vescoordinacion integer;
    vhabilitado character varying(1);
    vconpermiso boolean;
    vverificado_rec character varying(1);
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
    IF vesadministrador=1 OR vescoordinacion=1 THEN 
       vconpermiso = true; 
    ELSE 
       vconpermiso = false; 
    END IF;    
    vtabla= TG_TABLE_NAME;
    IF TG_OP='DELETE' THEN
       vPeriodo:=OLD.Periodo;
    ELSE
       vPeriodo:=NEW.Periodo;
    END IF;
    SELECT Ingresando, CerrarIngresoCampoHastaPanel, habilitado 
            INTO vIngresando, vCerrarIngresoCampoHastaPanel, vhabilitado
        FROM cvp.periodos where Periodo=vPeriodo;
    --RAISE EXCEPTION 'Vconpermiso %',vconpermiso;
    IF vIngresando = 'N' OR (vhabilitado = 'N' and not vconpermiso) then
        RAISE EXCEPTION 'Periodo Cerrado. Actualizacion no permitida en tabla %',vtabla;
        RETURN NULL;
    ELSE
        CASE vtabla
           WHEN 'relvis' THEN
               IF TG_OP= 'DELETE' THEN
                   vformulario= old.formulario;   
                   vpanel= old.panel;   
               ELSE
                   vformulario=new.formulario;
                   vpanel= new.panel;   
               END IF;
           WHEN 'relpre' THEN
               IF TG_OP= 'DELETE' THEN
                   vformulario = OLD.formulario;  
                   vperiodo= OLD.periodo;
                   vinformante= OLD.informante;
                   vvisita= OLD.visita;
               ELSE    
                   vformulario=new.formulario;
                   vperiodo= NEW.periodo;
                   vinformante= NEW.informante;
                   vvisita= NEW.visita;
               END IF;
               SELECT panel INTO  vpanel
                  FROM cvp.relvis rv 
                  WHERE  rv.periodo=vperiodo AND
                                    rv.informante=vinformante AND
                                    rv.visita=vvisita AND
                                    rv.formulario=vformulario;
           WHEN 'relatr' THEN
                IF TG_OP='DELETE' then
                   vperiodo= OLD.periodo;
                   vproducto= OLD.producto;
                   vobservacion= OLD.observacion;
                   vinformante= OLD.informante;
                   vvisita= OLD.visita;
                   vatributo= OLD.atributo;
                ELSE   
                   vperiodo= NEW.periodo;
                   vproducto= NEW.producto;
                   vobservacion= NEW.observacion;
                   vinformante= NEW.informante;
                   vvisita= NEW.visita;
                   vatributo= NEW.atributo;
                END IF;              
               SELECT  rv.formulario, rv.panel
                  INTO  vformulario  , vpanel
                  FROM cvp.relatr ra 
                    JOIN cvp.relpre rp ON ra.periodo=rp.periodo AND
                                       ra.producto=rp.producto AND
                                       ra.observacion=rp.observacion AND
                                       ra.informante=rp.informante AND
                                       ra.visita=rp.visita
                    JOIN cvp.relvis rv ON ra.periodo=rv.periodo AND
                                          ra.informante=rv.informante AND
                                          ra.visita=rv.visita AND
                                          rp.formulario=rv.formulario
                  WHERE ra.periodo=vperiodo and ra.producto=vproducto and
                        ra.observacion=vobservacion and ra.informante=vinformante and
                        ra.visita=vvisita and ra.atributo=vatributo ;                    
           ELSE
               vformulario=null;   
               vpanel= null;   
        END CASE;   
        IF vpanel IS NOT NULL AND vformulario IS NOT NULL  THEN
            SELECT operativo INTO voperativo FROM cvp.formularios where formulario=vformulario;
            IF vIngresando='S' AND voperativo='C' AND vpanel <=vCerrarIngresoCampoHastaPanel THEN 
               RAISE EXCEPTION 'El panel % esta cerrado para ingreso de campo', vpanel;
               RETURN NULL;
            END IF;
        END IF;
        /* Se puede editar la encuesta después de verificar la recepción, comento esta parte
        IF vtabla = 'relvis' THEN
            IF TG_OP in ('UPDATE','DELETE') then
                IF NEW.verificado_rec = OLD.verificado_rec AND NEW.verificado_rec ='S' THEN
                    RAISE EXCEPTION 'Se ha verificado la recepción para periodo % informante % visita % formulario %', NEW.periodo, NEW.informante, NEW.visita, NEW.formulario;
                    RETURN NULL;
                END IF;
            END IF;
        ELSE
            IF vperiodo IS NOT NULL AND vinformante IS NOT NULL AND vvisita IS NOT NULL AND vformulario IS NOT NULL THEN
                SELECT verificado_rec INTO vverificado_rec 
                FROM cvp.relvis WHERE 
                periodo = vperiodo AND
                informante = vinformante AND
                visita = vvisita AND
                formulario = vformulario;
                IF vverificado_rec='S' THEN 
                    RAISE EXCEPTION 'Se ha verificado la recepción para periodo % informante % visita % formulario %', vperiodo, vinformante, vvisita, vformulario;
                    RETURN NULL;
                END IF;
            END IF;
        END IF;
        */
    END IF;    
    if TG_OP='DELETE' then
       RETURN OLD;
    ELSE   
       RETURN NEW;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER reltar_abi_trg
  BEFORE INSERT OR UPDATE OF supervisor, encuestador, realizada, resultado, observaciones, puntos, cargado, descargado, token_instalacion OR DELETE
  ON reltar
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER RelInf_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON RelInf
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER novdelobs_abi_trg 
  BEFORE INSERT OR DELETE OR UPDATE 
  ON novdelobs 
  FOR EACH ROW EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER novdelvis_abi_trg 
  BEFORE INSERT OR DELETE OR UPDATE 
  ON novdelvis 
  FOR EACH ROW EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER relenc_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relenc
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();
  
CREATE TRIGGER relmon_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relmon
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();
  
CREATE TRIGGER novobs_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON novobs
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER NovProd_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON NovProd
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();

CREATE TRIGGER relsup_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relsup
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();
    
CREATE TRIGGER relatr_abi_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_ingresando();