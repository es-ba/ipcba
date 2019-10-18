CREATE OR REPLACE VIEW hojaderutasupervisor AS 
SELECT p.persona as supervisor, p.nombre||' ' ||p.apellido as nombresupervisor, h.*
FROM cvp.reltar r,
     cvp.hojaderuta h,
     cvp.personal p
WHERE r.periodo = h.periodo and r.panel = h.panel and r.tarea= h.tarea and r.encuestador = h.encuestador and r.supervisor is not null
      and r.supervisor = p.persona;

GRANT SELECT ON TABLE hojaderutasupervisor TO cvp_usuarios;