--��ѯ���������
select sess.sid,sess.serial#,lo.oracle_username,lo.os_user_name,ao.object_name,lo.locked_mode  from v$locked_object lo,dba_objects ao,v$session sess where ao.object_id = lo.object_id and lo.session_id = sess.sid;
--���������
alter system kill session '9,543';
  
--��ѯ��ռ��ʹ����� 
SELECT a.tablespace_name "��ռ���", 
total "��ռ��С", 
free "��ռ�ʣ���С", 
(total - free) "��ռ�ʹ�ô�С", 
total / (1024 * 1024 * 1024) "��ռ��С(G)", 
free / (1024 * 1024 * 1024) "��ռ�ʣ���С(G)", 
(total - free) / (1024 * 1024 * 1024) "��ռ�ʹ�ô�С(G)", 
round((total - free) / total, 4) * 100 "ʹ���� %" 
FROM (SELECT tablespace_name, SUM(bytes) free 
FROM dba_free_space 
GROUP BY tablespace_name) a, 
(SELECT tablespace_name, SUM(bytes) total 
FROM dba_data_files 
GROUP BY tablespace_name) b 
WHERE a.tablespace_name = b.tablespace_name;

--�����SQL
impdp BBZX130_CS/1@orcl directory=DUMP_DIR dumpfile=BBZX130.DMP REMAP_SCHEMA=BBZX130:BBZX130_CS  transform=oid:n logfile=impdp201703281140.log  remap_tablespace=YSSUCO130:YSSUCO;

expdp BBZX150/1@orcl schemas=BBZX150 directory=DUMP_DIR dumpfile =BBZX156.dmp logfile=BBZX156.log ;



--��ѯSGA���������С��SQL

 select pool,sum(bytes)/1024/1024||'MB' from v$sgastat where pool is not null group by pool;
 
 
 
