--查询死锁的语句
select sess.sid,sess.serial#,lo.oracle_username,lo.os_user_name,ao.object_name,lo.locked_mode  from v$locked_object lo,dba_objects ao,v$session sess where ao.object_id = lo.object_id and lo.session_id = sess.sid;
--解锁的语句
alter system kill session '9,543';
  
--查询表空间的使用情况 
SELECT a.tablespace_name "表空间名", 
total "表空间大小", 
free "表空间剩余大小", 
(total - free) "表空间使用大小", 
total / (1024 * 1024 * 1024) "表空间大小(G)", 
free / (1024 * 1024 * 1024) "表空间剩余大小(G)", 
(total - free) / (1024 * 1024 * 1024) "表空间使用大小(G)", 
round((total - free) / total, 4) * 100 "使用率 %" 
FROM (SELECT tablespace_name, SUM(bytes) free 
FROM dba_free_space 
GROUP BY tablespace_name) a, 
(SELECT tablespace_name, SUM(bytes) total 
FROM dba_data_files 
GROUP BY tablespace_name) b 
WHERE a.tablespace_name = b.tablespace_name;

--导库的SQL
impdp BBZX130_CS/1@orcl directory=DUMP_DIR dumpfile=BBZX130.DMP REMAP_SCHEMA=BBZX130:BBZX130_CS  transform=oid:n logfile=impdp201703281140.log  remap_tablespace=YSSUCO130:YSSUCO;

expdp BBZX150/1@orcl schemas=BBZX150 directory=DUMP_DIR dumpfile =BBZX156.dmp logfile=BBZX156.log ;



--查询SGA各个区域大小的SQL

 select pool,sum(bytes)/1024/1024||'MB' from v$sgastat where pool is not null group by pool;
 
 
 
