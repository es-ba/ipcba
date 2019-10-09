CREATE FUNCTION proddiv_ins_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_division text;
  v_incluye_supermercados boolean;
  v_incluye_tradicionales boolean;
  v_tipoinformante text;
  v_sindividir boolean;
/*
  incluye_supermercados boolean NOT NULL,
  incluye_tradicionales boolean NOT NULL,
  tipoinformante text,
  sindividir boolean,
  otradivision text,
*/
begin
  select division, 
    incluye_supermercados, 
    incluye_tradicionales, 
    tipoinformante, 
    sindividir
    into v_division, 
         v_incluye_supermercados, 
         v_incluye_tradicionales, 
         v_tipoinformante, 
         v_sindividir
    from cvp.divisiones
    where division=new.division;
   new.incluye_supermercados:=v_incluye_supermercados; 
   new.incluye_tradicionales:=v_incluye_tradicionales;
   new.tipoinformante:=v_tipoinformante;
   if v_division is not null then
     new.sindividir:=v_sindividir;
   end if;
  /*
  if new.incluye_supermercados is null then
    raise exception 'incluye_supermercados no puede ser null en % %', new.producto, new.division;
  end if;
  */
  return new;
end;
$$;

CREATE TRIGGER proddiv_ins_trg 
  BEFORE INSERT OR UPDATE 
  ON proddiv 
  FOR EACH ROW EXECUTE PROCEDURE proddiv_ins_trg();
