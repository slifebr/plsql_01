SELECT 'alter system disconnect session "' || l.sid || ',' || s.serial# ||'"  immediate;' COMANDO1 , 
       'alter system kill session "' || l.sid || ', ' || s.serial# || '"; '  COMANDO2, 
       s.USERNAME, s.STATUS, s.OSUSER 
    FROM gv$lock l, gv$session s 
   WHERE l.id1 = (
  SELECT o.object_id
    FROM all_objects o
   WHERE o.owner = 'GESTAO'
     AND o.object_name = 'T_PEND_ADIANT_AF') AND l.sid = s.sid;
