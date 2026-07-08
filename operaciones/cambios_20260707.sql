set search_path = cvp;
GRANT cvp_usuarios TO hvontschirnhaus;
GRANT cvp_usuarios TO pseivach;

SET role cvpowner;

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
    FROM ipcba.usuarios
    WHERE usu_usu = current_user and usu_rol in
    ('migracion','analista','programador','coordinador','ccc_analista');
    
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

set search_path = ccc, cvp;

--evita la edición de la tabla con el periodo cerrado
CREATE OR REPLACE TRIGGER novservdom_abi_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON novservdom
    FOR EACH ROW
    EXECUTE FUNCTION cvp.verificar_ingresando();

ALTER TABLE calhogpargru ADD COLUMN variacion double precision;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('calhogpargru','periodo,calculo,hogar,agrupacion,grupo');
 end
$SQL_ENANCE$;

CREATE OR REPLACE FUNCTION Cal_CCC_Variacion(pPeriodo TEXT, pCalculo INTEGER, pAgrupacion TEXT) RETURNS void  
     LANGUAGE plpgsql SECURITY DEFINER  
     AS $$      
 
BEGIN   
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='comenzo');
 
  UPDATE CalGruPer c
    SET variacion=CASE WHEN c0.valorgru=0 THEN null ELSE round((c.valorgru/c0.valorgru*100-100)::decimal,1) END
    FROM CalGruPer c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.perfil = c.perfil; --Pk verificada
  
  UPDATE calhogpargru c
    SET variacion=CASE WHEN c0.valorhoggru=0 THEN null ELSE round((c.valorhoggru/c0.valorhoggru*100-100)::decimal,1) END
    FROM calhogpargru c0,
         Calculos p   
    WHERE p.periodo=pPeriodo AND p.calculo=pCalculo --Pk verificada
      AND c.periodo=p.periodo AND c.calculo=p.calculo AND c.agrupacion=pAgrupacion
      AND c0.periodo=p.periodoAnterior AND c0.calculo=p.calculoAnterior AND c0.agrupacion=c.agrupacion AND c0.grupo=c.grupo and c0.hogar = c.hogar; --Pk verificada

  EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Variacion', pTipo:='finalizo');
END;  
$$;

------------------
CREATE OR REPLACE FUNCTION Cal_CCC_Valorizar(pPeriodo Text, pCalculo Integer, pAgrupacion Text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
vindice double precision;
vparavariosHogares BOOLEAN;
BEGIN
SET search_path = ccc, cvp, comun, public;  --porque se corre suelto
EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='comenzo');
SELECT indice INTO vindice
  FROM CalGru
  WHERE periodo=pPeriodo AND calculo=pCalculo AND agrupacion='Z' and nivel=0 ;
IF vindice is null THEN
  EXECUTE Cal_Mensajes(pPeriodo, pCalculo,'Cal_CCC_Valorizar', pTipo:='error', pMensaje:='No está calculado el Indice para el nivel Z0', pAgrupacion:=pAgrupacion);
ELSE
  SELECT paravarioshogares INTO vparavariosHogares
    FROM agrupaciones_ccc
    WHERE agrupacion=pAgrupacion;

  EXECUTE CalProd_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);  --valoriza productos de ccc

  --EXECUTE Cal_Canasta_Borrar(pPeriodo, pCalculo, pAgrupacion);  ya se borró en Cal_CCC_Borrar, falta ver más adelante las tablas de hogares

  EXECUTE CalGru_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);

  IF vparavariosHogares THEN      ---- falta ver más adelante las tablas de hogares
    EXECUTE CalHog_CCC_Valorizar(pPeriodo, pCalculo, pAgrupacion);
  --  EXECUTE CalHog_Subtotalizar(pPeriodo, pCalculo, pAgrupacion);
  END IF;
  
  EXECUTE Cal_CCC_Variacion(pPeriodo, pCalculo, pAgrupacion);

END IF;
EXECUTE Cal_Mensajes(pPeriodo, pCalculo, 'Cal_CCC_Valorizar', pTipo:='finalizo');
END;
$$;
