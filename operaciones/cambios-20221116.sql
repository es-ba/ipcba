set search_path = cvp;

ALTER TABLE reltar ADD COLUMN backup jsonb;
ALTER TABLE his.reltar ADD COLUMN backup jsonb;

ALTER TABLE reltar ADD COLUMN fecha_backup timestamp;
ALTER TABLE his.reltar ADD COLUMN fecha_backup timestamp;