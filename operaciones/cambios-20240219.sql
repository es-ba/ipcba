
alter table cvp.bp_bitacora set schema his;
alter table cvp.tokens set schema his;
alter table his.bp_bitacora alter column id type bigint;
grant usage on schema his to cvpowner;
grant usage on schema his to cvp_recepcionista;
grant select, insert, update on his.bp_bitacora to cvpowner;
alter table his.bp_bitacora alter column parameters_definition drop not null;

ALTER TABLE his.bp_bitacora OWNER to cvpowner;

alter table ipcba.usuarios add column candownloadbackup boolean;