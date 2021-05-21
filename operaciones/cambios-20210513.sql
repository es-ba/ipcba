set search_path = cvp;

--se testea la consistencia de vigencias cuando hay una única visita, sólo si el tipoprecio es positivo
--cuando hay más de una visita, se testea con por lo menos un tipoprecio positivo

CREATE OR REPLACE VIEW controlvigencias as
 SELECT *
   FROM (SELECT a.periodo,
            a.informante,
            a.producto,
            u.nombreproducto,
            a.observacion,
            d.valor,
            COALESCE(comun.cuantos_dias_mes(a.periodo::text, d.valor::text), 0) AS cantdias,
            date_part('day'::text, ((((substr(moverperiodos(a.periodo::text, 1), 2, 4) || '-'::text) || substr(moverperiodos(a.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval) AS ultimodiadelmes,
            count(DISTINCT a.visita)::integer AS visitas,
            sum(a.valor::numeric)::integer AS vigencias,
            string_agg((COALESCE(p.comentariosrelpre, ' '::text) || ' '::text) || COALESCE(p.observaciones, ' '::text), ' '::text) AS comentarios,
            string_agg (COALESCE(p.tipoprecio, ' '::text), ' '::text order by p.visita) as tipoprecio,
		    sum(case when tp.espositivo = 'N' then 1 else 0 end) as cantnegativos,
		    sum(case when tp.espositivo = 'S' then 1 else 0 end) as cantpositivos			
           FROM relvis r
             LEFT JOIN relpre p ON r.periodo::text = p.periodo::text AND r.informante = p.informante AND r.visita = p.visita AND r.formulario = p.formulario
             LEFT JOIN relatr a ON p.periodo::text = a.periodo::text AND p.producto::text = a.producto::text AND p.observacion = a.observacion AND p.informante = a.informante AND p.visita = a.visita
             LEFT JOIN (SELECT *
                          FROM relatr
                          WHERE atributo = 196) d 
                        ON a.periodo = d.periodo AND a.producto = d.producto AND a.informante = d.informante AND a.observacion = d.observacion AND a.visita = d.visita
             LEFT JOIN atributos t ON a.atributo = t.atributo
             LEFT JOIN productos u ON a.producto = u.producto
             LEFT JOIN razones z on r.razon = z.razon
             LEFT JOIN tipopre tp on p.tipoprecio = tp.tipoprecio
          WHERE t.es_vigencia AND coalesce(z.espositivoformulario, 'N') = 'S' --and coalesce(tp.espositivo, 'N') = 'S' 
          GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, 
          (COALESCE(comun.cuantos_dias_mes(a.periodo::text, d.valor::text), 0)), 
          (date_part('day'::text, ((((substr(moverperiodos(a.periodo::text, 1), 2, 4) || '-'::text) || substr(moverperiodos(a.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval))
          ORDER BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion) f
  WHERE NOT ((f.visitas = 1 AND ((cantnegativos = 0 AND cantpositivos = 0) OR cantnegativos > 0 OR f.ultimodiadelmes = f.vigencias OR f.vigencias = f.cantdias)) OR 
			 (f.visitas > 1 AND (f.visitas = cantpositivos AND (f.ultimodiadelmes = f.vigencias OR f.cantdias = f.vigencias)))
			);


set role = cvpowner;
--calcula el valor del atributo vigencia, si el precio es positivo
CREATE OR REPLACE FUNCTION calcular_vigencia_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE 
vespositivo text;
vatributo integer;
vdiadelasemana text;
vvalornuevo text;

BEGIN
 SELECT espositivo INTO vespositivo
   FROM cvp.tipopre
   WHERE tipoprecio=NEW.tipoprecio;

 SELECT atributo INTO vatributo
   FROM prodatr pa left join atributos a using (atributo)
   WHERE pa.producto=NEW.producto and es_vigencia;
  
 SELECT valor INTO vdiadelasemana
   FROM cvp.relatr
   WHERE periodo=NEW.periodo AND 
        producto=NEW.producto AND
        observacion=NEW.observacion AND 
        informante=NEW.informante AND
        visita=NEW.visita AND
        atributo=196;
      
 IF vdiadelasemana is not null THEN
   vvalornuevo = comun.cuantos_dias_mes(new.periodo, vdiadelasemana);
 ELSE
   vvalornuevo = date_part('day', ((((substr(cvp.moverperiodos(new.periodo, 1), 2, 4) || '-') || substr(cvp.moverperiodos(new.periodo, 1), 7, 2)) || '-01')::date) - '1 day'::interval)::text;
 END IF;
 
 IF coalesce(vespositivo, 'N') = 'S' THEN
    UPDATE cvp.relatr 
      SET valor=vvalornuevo
    WHERE periodo=NEW.periodo AND 
          producto=NEW.producto AND
          observacion=NEW.observacion AND 
          informante=NEW.informante AND
          visita=NEW.visita AND
          atributo=vatributo AND
          valor IS DISTINCT FROM vvalornuevo;
 END IF;
 RETURN NEW;
 
END;
$BODY$;

DROP TRIGGER IF EXISTS relpre_calcula_vigencia_trg ON relpre;

CREATE TRIGGER relpre_calcula_vigencia_trg
    AFTER UPDATE OF tipoprecio
    ON cvp.relpre
    FOR EACH ROW
    EXECUTE PROCEDURE cvp.calcular_vigencia_trg();


--al insertar visitas, la vigencia se copia del valor anterior, como cualqier otro atributo
CREATE OR REPLACE FUNCTION insertar_atributos_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE
  vHay INTEGER; 
  vvisitaAnterior INTEGER;
BEGIN
IF new.visita>1 and NEW.ultima_visita = TRUE THEN
    vvisitaAnterior = new.visita -1;

    insert into cvp.relatr(periodo, producto, observacion, informante, visita, atributo, valor, validar_con_valvalatr)
     select r.periodo, r.producto, r.observacion, r.informante, new.visita, r.atributo,
              /*CASE WHEN a.Es_Vigencia THEN 0::text ELSE r.valor END,*/ r.valor, r.validar_con_valvalatr 
     from cvp.relatr r
          inner join cvp.atributos a on r.atributo = a.atributo
     where periodo = new.periodo and producto = new.producto and observacion = new.observacion and informante = new.informante and
         visita = vvisitaAnterior; 

END IF;
  
  RETURN NEW;
END;
$BODY$;
