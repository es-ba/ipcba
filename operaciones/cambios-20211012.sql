set role to cvpowner;
set search_path = ipcba;

GRANT SELECT, UPDATE ON TABLE usuarios TO cvp_usuarios;

ALTER TABLE "usuarios" ENABLE ROW LEVEL SECURITY;
CREATE POLICY bp_pol_select ON "usuarios" AS PERMISSIVE FOR select USING ( true );
CREATE POLICY bp_pol_update ON "usuarios" AS PERMISSIVE FOR update USING ( usu_usu = current_user ) WITH CHECK ( usu_usu = current_user );