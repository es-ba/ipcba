set search_path = cvp;

create table "bp_bitacora" (
  "id" integer, 
  "procedure_name" text, 
  "parameters_definition" text, 
  "parameters" text, 
  "username" text, 
  "machine_id" text, 
  "navigator" text, 
  "init_date" timestamp, 
  "end_date" timestamp, 
  "has_error" boolean, 
  "end_status" text
, primary key ("id")
);
grant select, insert, update, delete on "bp_bitacora" to cvpowner;
grant select, insert, update  on "bp_bitacora" to cvpowner, cvp_usuarios;

CREATE SEQUENCE "secuencia_bitacora" START 1;
ALTER TABLE "bp_bitacora" ALTER COLUMN "id" SET DEFAULT nextval('secuencia_bitacora'::regclass);
GRANT USAGE, SELECT ON SEQUENCE "secuencia_bitacora" TO cvpowner;
GRANT USAGE, SELECT ON SEQUENCE "secuencia_bitacora" TO cvp_usuarios;

alter table "bp_bitacora" alter column "id" set not null;
alter table "bp_bitacora" add constraint "procedure_name<>''" check ("procedure_name"<>'');
alter table "bp_bitacora" alter column "procedure_name" set not null;
alter table "bp_bitacora" add constraint "parameters_definition<>''" check ("parameters_definition"<>'');
alter table "bp_bitacora" alter column "parameters_definition" set not null;
alter table "bp_bitacora" add constraint "parameters<>''" check ("parameters"<>'');
alter table "bp_bitacora" alter column "parameters" set not null;
alter table "bp_bitacora" add constraint "username<>''" check ("username"<>'');
alter table "bp_bitacora" alter column "username" set not null;
alter table "bp_bitacora" add constraint "machine_id<>''" check ("machine_id"<>'');
alter table "bp_bitacora" alter column "machine_id" set not null;
alter table "bp_bitacora" add constraint "navigator<>''" check ("navigator"<>'');
alter table "bp_bitacora" alter column "navigator" set not null;
alter table "bp_bitacora" alter column "init_date" set not null;
alter table "bp_bitacora" add constraint "end_status<>''" check ("end_status"<>'');