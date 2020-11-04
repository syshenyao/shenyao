--����
select value as processes_max from v$parameter where name ='processes';  --���ݿ���������������  ���4000

select count(*) as process_now from v$process; --��ǰ����������

select value as session_max from v$parameter where name ='sessions'; --���ݿ����session��

select count(*) as session_now from v$session;  --��ǰ��session������
 
select count(*) as active_now from v$session where status='ACTIVE';��--����������

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


--�鿴��ʱ��ռ�ʹ�����
SELECT TU.TABLESPACE_NAME AS "TABLESPACE_NAME",
TT.TOTAL - TU.USED AS "FREE(G)",
TT.TOTAL AS "TOTAL(G)",
ROUND(NVL(TU.USED, 0) / TT.TOTAL * 100, 3) AS "USED(%)",
ROUND(NVL(TT.TOTAL - TU.USED, 0) * 100 / TT.TOTAL, 3) AS "FREE(%)"
FROM (SELECT TABLESPACE_NAME,
SUM(BYTES_USED) / 1024 / 1024 / 1024 USED
FROM V$TEMP_SPACE_HEADER
GROUP BY TABLESPACE_NAME) TU ,
(SELECT TABLESPACE_NAME,
SUM(BYTES) / 1024 / 1024 / 1024 AS TOTAL
FROM DBA_TEMP_FILES where tablespace_name = 'TEMP'
GROUP BY TABLESPACE_NAME) TT
WHERE TU.TABLESPACE_NAME = TT.TABLESPACE_NAME;

--�鿴��ʱ��ռ�ռ�ù��ߵ�SQL

select sql_id,operation_type as op, operation_id as id,
  round(estimated_optimal_size/1024/1024,2) as e_opt,  
  round(estimated_onepass_size/1024/1024,2) as e_one,
  round(last_memory_used/1024/1024,2) as l_mem,
  Last_execution as last,
  total_executions as tot, optimal_executions as opt,
  onepass_executions as one, 
  multipasses_executions as mult,
  round(active_time/1000000,2) as sec,   
  round(max_tempseg_size/1024/1024,2) as tmp_m, 
  round(last_tempseg_size/1024/1024,2) as tmp_L
from v$sql_workarea 
where 
  max_tempseg_size is not null 
order by max_tempseg_size desc;


--������ʱ��ռ�
ALTER TABLESPACE TEMP ADD TEMPFILE 'D:\MYORACLE\ORACLE\ORADATA\ORCL\TEMP03.DBF' SIZE 31G;

alter database tempfile 'D:\MYORACLE\ORACLE\ORADATA\ORCL\TEMP02.DBF' RESIZE 31G


--�����SQL
impdp BBZX130_CS/1@orcl directory=DUMP_DIR dumpfile=BBZX130.DMP REMAP_SCHEMA=BBZX130:BBZX130_CS  transform=oid:n logfile=impdp201703281140.log  remap_tablespace=YSSUCO130:YSSUCO;

expdp BBZX150/1@orcl schemas=BBZX150 directory=DUMP_DIR dumpfile =BBZX156.dmp logfile=BBZX156.log ;

--�鿴ĳ������ڵĲ������
select SQL_TEXT,LAST_ACTIVE_TIME from v$sqlarea where LAST_ACTIVE_TIME >to_date('20140917 10:00:00','yyyymmdd hh24:mi:ss') and upper(SQL_TEXT) like '%T_PORT_INDEX%';


--�ָ��������ʹ�����·���( ɾ������֮���ṹû�з����仯)

alter  table tc_report_index enable row  movement    --�������ƶ�����

 

flashback table tc_report_index to timestamp to_timestamp('2019-01-14 14:00:00','yyyy-mm-dd hh24:mi:ss')  --�ָ����ݵ�ɾ��ʱ���֮ǰ��״̬

 

Alter table tc_report_index disable row movement      --�ر����ƶ�����(һ����������)


---ʹ�����·���( ɾ������֮���ṹ�����˱仯)
select * from tc_report_index as of timestamp to_timestamp('2019-01-14 19:17:00','yyyy-mm-dd hh24:mi:ss')  --�ҳ���ɾ��������

 

insert into tc_report_index (select * from tc_report_index as of timestamp to_timestamp('2019-01-14 19:17:00','yyyy-mm-dd hh24:mi:ss'));--��ɾ�����������²��ԭ����ע��������Ҫ�ظ�


--��ɾ������

select object_name,original_name,partition_name,type,ts_name,createtime,droptime from recyclebin;

flashback table ���� to before DROP;


--����SCN�ָ��������

select current_scn from v$database; --1����õ�ǰ���ݿ��scn��   �л���sys�û���system�û���ѯ



select * from ���� as of scn 1499220; --2����ѯ��ǰscn��֮ǰ��scn(ȷ��ɾ���������Ƿ���ڣ�������ڣ���ָ����ݣ�������ǣ��������Сscn��)



flashback table ���� to scn 1499220;  --����3���ָ�ɾ�������ύ������




















---�Ż�

--�鿴SQLִ�мƻ�
--����һ������autotrace�鿴ִ�мƻ�
		--ע�⣺autotrace����ѯ��ִ�мƻ���������ʵ��ִ�мƻ�������ƻ��Ǵ�PLAN_TABLE�����ģ�����CBOԤ����

--��������ע�⣺EXPLAIN PLAN FOR ......����ѯ��ִ�мƻ���������ʵ��ִ�мƻ�����CBOԤ���ġ���PLSQL F5���õľ�������



--������:������SQLִ�мƻ�
ALTER SESSION SET STATISTICS_LEVEL=ALL; ---������SQL

--ִ��SQL

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL,NULL,'ALLSTATS LAST'));



--������:
--�鿴v$sql_plan��
--ͨ��SQL����SQL_ID�����α�ţ�������V$SQL_PLAN���в鿴����SQL����ִ�мƻ���

SQL> select sql_id,sql_text from v$sqlarea where sql_text like '%from t1%';
SQL_ID         SQL_TEXT
------------- ----------------------------------------------------------------------------------------------------
27uhu2q2xuu7r select * from t1

SQL> select sql_id,child_number,sql_text from v$sql where sql_id='27uhu2q2xuu7r';
SQL_ID CHILD_NUMBER SQL_TEXT
------------- ------------ ----------------------------------------------------------------------------------------------------
27uhu2q2xuu7r 0 select * from t1
--ͨ������������ѯ��䣬���Ŀ��SQL����SQL_IDΪ ��27uhu2q2xuu7r���� ?���α��Ϊ��0��.
SQL> select timestamp,operation,options,object_name,cost,id,parent_id from v$sql_plan where sql_id='27uhu2q2xuu7r' and child_number=0;



--������:

select * from  table(dbms_xplan.display_awr('bjqjt2dfvya84'));



--��ѯSGA���������С��SQL

select pool,sum(bytes)/1024/1024||'MB' from v$sgastat where pool is not null group by pool;
 
--�����Ƿ���ڹ����reloads��invalidations
SELECT NAMESPACE,GETS,GETHITS,round(GETHITRATIO*100,2) gethit_ratio,PINS,PINHITS,round(PINHITRATIO*100,2) pinhit_ratio,RELOADS,INVALIDATIONS FROM V$LIBRARYCACHE;

--�⻺���������Ӧ������95%������Ӧ��������shared_pool_size
SELECT SUM(pins) "Executions",SUM(reloads) "CacheMisses while Executing",ROUND((SUM(pins)/(SUM(reloads)+SUM(pins)))*100,2) AS "HitRatio Ratio, %" FROM V$LIBRARYCACHE;
 
--�鿴����ؿ��ÿռ䣬��sharedpool�й���Ŀ��ÿռ䣬�ٵ���shared pool�����岻��???????

SELECT pool,name,bytes/1024/1024 FROM v$sgastat WHERE name LIKE '%free memory%' AND pool='shared pool';

--����Ӳ�������򣬲�ѯӲ��������SQL
select sql_text,SQL_FULLTEXT,parse_calls,executions,loads from v$sqlarea order by loads DESC;

--ˢ�¹����
alter system flush shared_pool;

--ˢ���ڴ��е����ݣ����´�Ӳ���ж�ȡ(set autotrace on���Բ鿴�Ƿ����������)
alter system flush buffer_cache;



dir /B   �г��ļ���Ȼ�����@@ ��������ִ��SQL������:
@@20191023_3_�걨�м�����Ȩƽ������ݶ�����󡢱��ڼ�Ȩƽ����ֵ������.sql
@@20191023_4_�걨�м����ۼƾ�ֵҵ����׼.sql

