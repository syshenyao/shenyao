--常规

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

--查看某个表近期的操作情况
select SQL_TEXT,LAST_ACTIVE_TIME from v$sqlarea where LAST_ACTIVE_TIME >to_date('20140917 10:00:00','yyyymmdd hh24:mi:ss') and upper(SQL_TEXT) like '%T_PORT_INDEX%';


--恢复表的数据使用如下方法( 删除数据之后表结构没有发生变化)

alter  table tc_report_index enable row  movement    --开启行移动功能

 

flashback table tc_report_index to timestamp to_timestamp('2019-01-14 14:00:00','yyyy-mm-dd hh24:mi:ss')  --恢复数据到删除时间点之前的状态

 

Alter table tc_report_index disable row movement      --关闭行移动功能(一定不能忘记)


---使用如下方法( 删除数据之后表结构发生了变化)
select * from tc_report_index as of timestamp to_timestamp('2019-01-14 19:17:00','yyyy-mm-dd hh24:mi:ss')  --找出被删除的数据

 

insert into tc_report_index (select * from tc_report_index as of timestamp to_timestamp('2019-01-14 19:17:00','yyyy-mm-dd hh24:mi:ss'));--把删除的数据重新插回原表，但注意主键不要重复


--误删整个表

select object_name,original_name,partition_name,type,ts_name,createtime,droptime from recyclebin;

flashback table 表名 to before DROP;


--根据SCN恢复表的数据

select current_scn from v$database; --1、获得当前数据库的scn号   切换到sys用户或system用户查询



select * from 表名 as of scn 1499220; --2、查询当前scn号之前的scn(确定删除的数据是否存在，如果存在，则恢复数据；如果不是，则继续缩小scn号)



flashback table 表名 to scn 1499220;  --　　3、恢复删除且已提交的数据




















---优化

--查看SQL执行计划
--方法一：利用autotrace查看执行计划
		--注意：autotrace所查询的执行计划并不是真实的执行计划（这个计划是从PLAN_TABLE中来的），是CBO预估的

--方法二：注意：EXPLAIN PLAN FOR ......所查询的执行计划并不是真实的执行计划，是CBO预估的。（PLSQL F5调用的就是它）



--方法三:真正的SQL执行计划
ALTER SESSION SET STATISTICS_LEVEL=ALL; ---再运行SQL

--执行SQL

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));



--方法四:
--查看v$sql_plan表
--通过SQL语句的SQL_ID和子游标号，可以在V$SQL_PLAN表中查看到该SQL语句的执行计划。

SQL> select sql_id,sql_text from v$sqlarea where sql_text like '%from t1%';
SQL_ID         SQL_TEXT
------------- ----------------------------------------------------------------------------------------------------
27uhu2q2xuu7r select * from t1

SQL> select sql_id,child_number,sql_text from v$sql where sql_id='27uhu2q2xuu7r';
SQL_ID CHILD_NUMBER SQL_TEXT
------------- ------------ ----------------------------------------------------------------------------------------------------
27uhu2q2xuu7r 0 select * from t1
--通过以上两条查询语句，查得目标SQL语句的SQL_ID为 “27uhu2q2xuu7r”， ?子游标号为“0”.
SQL> select timestamp,operation,options,object_name,cost,id,parent_id from v$sql_plan where sql_id='27uhu2q2xuu7r' and child_number=0;



--方法五:

select * from  table(dbms_xplan.display_awr('bjqjt2dfvya84'));



--查询SGA各个区域大小的SQL

select pool,sum(bytes)/1024/1024||'MB' from v$sgastat where pool is not null group by pool;
 
--考虑是否存在过多的reloads和invalidations
SELECT NAMESPACE,GETS,GETHITS,round(GETHITRATIO*100,2) gethit_ratio,PINS,PINHITS,round(PINHITRATIO*100,2) pinhit_ratio,RELOADS,INVALIDATIONS FROM V$LIBRARYCACHE;

--库缓存的命中率应保持在95%，否则应考虑增大shared_pool_size
SELECT SUM(pins) "Executions",SUM(reloads) "CacheMisses while Executing",ROUND((SUM(pins)/(SUM(reloads)+SUM(pins)))*100,2) AS "HitRatio Ratio, %" FROM V$LIBRARYCACHE;
 
--查看共享池可用空间，当sharedpool有过多的可用空间，再调大shared pool则意义不大???????

SELECT pool,name,bytes/1024/1024 FROM v$sgastat WHERE name LIKE '%free memory%' AND pool='shared pool';

--根据硬解析排序，查询硬解析最多的SQL
select sql_text,SQL_FULLTEXT,parse_calls,executions,loads from v$sqlarea order by loads DESC;

--刷新共享池
alter system flush shared_pool;

--刷新内存中的数据，重新从硬盘中读取(set autotrace on可以查看是否发生了物理读)
alter system flush buffer_cache;




