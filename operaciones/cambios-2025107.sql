set search_path = cvp;
set role cvpowner;

create or replace procedure set_app_user(p_username text)
  security definer language plpgsql
as
$body$
declare
    
        "v_usu_usu" text;
        "v_usu_rol" text;
        "v_candownloadbackup" text;
begin
    if p_username = '!login' then
        
        set backend_plus._usu_usu = '!';
        set backend_plus._usu_rol = '!';
        set backend_plus._candownloadbackup = '!';

        set backend_plus._mode = login;
    else
        select "usu_usu", "usu_rol", "candownloadbackup"
            into "v_usu_usu", "v_usu_rol", "v_candownloadbackup"
            
            from "ipcba"."usuarios"
                where "usu_usu" = p_username;
        
        perform set_config('backend_plus._usu_usu', v_usu_usu, false);
        perform set_config('backend_plus._usu_rol', v_usu_rol, false);
        perform set_config('backend_plus._candownloadbackup', v_candownloadbackup, false);

        set backend_plus._mode = normal;
    end if;
    perform set_config('backend_plus._user', p_username, false);
end;    
$body$;

alter table ipcba.usuarios alter column usu_clave type text;


--select * from ipcba.usuarios where usu_usu = 'manuel'
