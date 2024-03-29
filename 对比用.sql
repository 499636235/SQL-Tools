--堡垒机账号密码
zkrxuechengbin
Dw@1234567890

--USER_A和USER_DIFF数据库密码（手动改过）（USERA的原密码是usera123）
Dw@12345678
--USERB的数据库密码
userb123

--对比表存过
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'TTTTTTTTTTTT'||'_DIFF';
call USER_DIFF.SP_TABLE_DIFF('TTTTTTTTTTTT','USERA','USERB','USER_DIFF');
call user_diff.SP_TABLE_DIFF_DETAIL('TTTTTTTTTTTT'||'_DIFF');
select * from USER_DIFF.RESULT_DIFF where TARGET_NAME = 'TTTTTTTTTTTT'||'_DIFF' order by id desc;
select * from USER_DIFF.RESULT_DIFF_DETAIL where TARGET_NAME = 'TTTTTTTTTTTT'||'_DIFF' order by id desc;
select * from USER_DIFF.TABLE_DIFF_DETAIL where table_name = 'TTTTTTTTTTTT'||'_DIFF' order by DIFF_NUM desc;

--表名过长情况 对比表存过
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'TTTTTTTTTTTT'||'_D';
call USER_DIFF.SP_TABLE_D('TTTTTTTTTTTT','USERA','USERB','USER_DIFF');
call user_diff.SP_TABLE_DIFF_DETAIL('TTTTTTTTTTTT'||'_D');
select * from USER_DIFF.RESULT_DIFF where TARGET_NAME = 'TTTTTTTTTTTT'||'_D' order by id desc;
select * from USER_DIFF.RESULT_DIFF_DETAIL where TARGET_NAME = 'TTTTTTTTTTTT'||'_D' order by id desc;
select * from USER_DIFF.TABLE_DIFF_DETAIL where table_name = 'TTTTTTTTTTTT'||'_D' order by DIFF_NUM desc;

--如果格式不一样可以手动统一格式!!!
update userb.BALY_LAGRPCONTRESULTLIST set GRADENAME = substr(GRADENAME,instr(GRADENAME,'-')+1,50);

--查询各表的失败行数
SELECT TARGET_NAME,ROWS_OF_SUCC,SYN_TIME FROM USER_DIFF.RESULT_DIFF ORDER BY ROWS_OF_SUCC;

--查询两个表的差异
SELECT * FROM XXXXX_DIFF;

--查询两个表单列的差异行所对应的主键（生成SQL）
WITH TMP0 AS (
SELECT UPPER('TTTTT_DIFF') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT ('SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM '||(SELECT * FROM TMP0)||' ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''空字段njy'')) > 1 
') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME = 'CCCCCCCCCOL';


--根据对应的主键 查询两个表单列的差异（生成SQL）
with TMP0 as (
select UPPER('TTTTT_DIFF') as T from dual
)
select 
'with keys as(select * from (

) where rownum < 11)
select OWNER,'||'COL_NAME from '||(SELECT T FROM TMP0)||' diff where 1=1 and exists (select 1 from keys where 1=1 '||
(select
replace(wm_concat('and '||KEYS||' = '||'diff.'||KEYS),',',' ') AS CONDITIONS
FROM TABLE_KEYS 
WHERE TABLE_NAME = (SELECT T FROM TMP0))
||')
order by '||
(select
wm_concat(KEYS) AS CONDITIONS
FROM TABLE_KEYS 
WHERE TABLE_NAME = (SELECT T FROM TMP0))
||',owner ;'from dual;


--核对主键-----------------------------------------------------
select count(1) as 存在重复的主键数量,
	case when count(1)=0 then '是' else '否' end as 是否主键
	from (
		select 1
		from USER.ALY_LLTAXCLMLIST 
		group by keys
		having count(1) > 1 ) ;


--把表名和主键插入主键表-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_KEYS (
TABLE_NAME VARCHAR2(255),	--表名
KEYS VARCHAR2(255)			--主键
)
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','CLMNO');
COMMIT;
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'ALY_LLTAXCLMLIST_DIFF';


--空间不足时查看表占用空间1
SELECT OWNER,SEGMENT_NAME, SUM(BYTES) / 1024 / 1024 AS M
  FROM DBA_SEGMENTS
 WHERE OWNER IN( 'USERA','USERB')
 GROUP BY SEGMENT_NAME,OWNER
 ORDER BY M DESC;
 
--空间不足时查看表占用空间2
select df.tablespace_name "表空间名",
       totalspace "总空间M",
       freespace "剩余空间M",
       round((1 - freespace / totalspace) * 100, 2) "使用率%"
  from (select tablespace_name, round(sum(bytes) / 1024 / 1024) totalspace
          from dba_data_files
         group by tablespace_name) df,
       (select tablespace_name, round(sum(bytes) / 1024 / 1024) freespace
          from dba_free_space
         group by tablespace_name) fs
 where df.tablespace_name = fs.tablespace_name;



--多行对比日志 建表语句-----------------------------------------------------
CREATE TABLE USER_DIFF.RESULT_DIFF_DETAIL AS SELECT * FROM USER_DIFF.RESULT_DIFF;

--多行对比结果 建表语句-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_DIFF_DETAIL (
TABLE_NAME VARCHAR2(40),	--表名
COL VARCHAR2(100),			--列名
DIFF_NUM NUMBER,			--单列差异行数
ALL_DIFF_NUM NUMBER			--总差异行数
)

--多行全列对比整合版-----------------------------------------------------

WITH TMP0 /* 表名  'ALY_LCGRPLISTDETAIL_DIFF' */ AS (
SELECT UPPER('请在这里填写表名_diff') AS T FROM DUAL
),
TMP1 /* 主键序列  'key1,key2,key3' */ AS (
SELECT WM_CONCAT(KEYS) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP2 /* 主键序列  ' and TMP0.key1 = DIFF.key1' */ AS (
SELECT replace(WM_CONCAT(' and TMP0.'||KEYS||' = DIFF.'||KEYS),',','') AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP3 /* 每列SQL */ AS (
SELECT WITH_SQL AS WITH_SQL,
substr(COL_SQL,0,length(COL_SQL)-9) AS COL_SQL from (
SELECT 
replace(wm_concat(
', TMP_'||COLUMN_NAME||' AS (
SELECT COUNT(1) AS DIFF_NUM FROM (
SELECT '||(SELECT KEYS FROM TMP1)||' 
	FROM (SELECT '||(SELECT KEYS FROM TMP1)||','||COLUMN_NAME||' FROM TMP1 ) A 
	GROUP BY '||(SELECT KEYS FROM TMP1)||' 
	HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''空字段njy'')) > 1 
	)
)'
),',,',',') AS WITH_SQL,
replace(wm_concat(
'(SELECT 
CASE 
WHEN 0 <>
	(SELECT DIFF_NUM FROM TMP_'||COLUMN_NAME||') 
THEN '''||COLUMN_NAME||'''	
ELSE NULL 
END AS COL,
(SELECT DIFF_NUM FROM TMP_'||COLUMN_NAME||') AS DIFF_NUM,
(SELECT COUNT(1) FROM TMP0) AS ALL_DIFF_NUM
FROM DUAL) 
UNION ALL'
),'UNION ALL,','UNION ALL ') AS COL_SQL 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT T FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)) 
AND COLUMN_NAME <> 'OWNER')
)
/* 最终SQL */
SELECT 
'WITH TMP0 AS(
SELECT '||(SELECT KEYS FROM TMP1)||'
 FROM '||(SELECT T FROM TMP0)||'
 GROUP BY '||(SELECT KEYS FROM TMP1)||'
 HAVING COUNT(OWNER)=2 AND COUNT(DISTINCT OWNER)=2
),
TMP1 AS (
SELECT DIFF.* FROM '||(SELECT T FROM TMP0)||' DIFF  
	inner join TMP0 on 1=1'||(SELECT KEYS FROM TMP2)||'
)'||TMP3.WITH_SQL||'
SELECT * FROM ('
||TMP3.COL_SQL||
')
WHERE COL IS NOT NULL;' AS FINAL_SQL
FROM TMP3
;




--多行单列对比整合版-----------------------------------------------------

WITH TMP0 /* 表名  'ALY_LCGRPLISTDETAIL_DIFF' */ AS (
SELECT UPPER('请在这里填写表名_diff') AS T FROM DUAL
),
TMP00 /* 列名  'PREM' */ AS (
SELECT UPPER('请在这里填写列名') AS C FROM DUAL
),
TMP1 /* 主键序列  'key1,key2,key3' */ AS (
SELECT WM_CONCAT(KEYS) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP2 /* 主键序列  ' and TMP0.key1 = DIFF.key1' */ AS (
SELECT replace(WM_CONCAT(' and TMP0.'||KEYS||' = DIFF.'||KEYS),',','') AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP3 /* 每列SQL */ AS (
SELECT 
'
, TMP_'||COLUMN_NAME||' AS (
SELECT COUNT(1) AS DIFF_NUM FROM (
SELECT '||(SELECT KEYS FROM TMP1)||' 
	FROM (SELECT '||(SELECT KEYS FROM TMP1)||','||COLUMN_NAME||' FROM TMP1 ) A 
	GROUP BY '||(SELECT KEYS FROM TMP1)||' 
	HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''空字段njy'')) > 1 
	)
)' AS WITH_SQL,
'SELECT 
CASE 
WHEN 0 <> 
	(SELECT DIFF_NUM FROM TMP_'||COLUMN_NAME||') 
THEN '''||COLUMN_NAME||'''	
ELSE NULL 
END AS COL,
(SELECT DIFF_NUM FROM TMP_'||COLUMN_NAME||') AS DIFF_NUM,
(SELECT COUNT(1) FROM TMP0) AS ALL_DIFF_NUM
FROM DUAL' AS COL_SQL
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT T FROM TMP0)
AND COLUMN_NAME = (SELECT C FROM TMP00)
)
/* 最终SQL */
SELECT 
'WITH TMP0 AS(
SELECT '||(SELECT KEYS FROM TMP1)||'
 FROM '||(SELECT T FROM TMP0)||'
 GROUP BY '||(SELECT KEYS FROM TMP1)||'
 HAVING COUNT(OWNER)=2 AND COUNT(DISTINCT OWNER)=2
),
TMP1 AS (
SELECT DIFF.* FROM '||(SELECT T FROM TMP0)||' DIFF  
	inner join TMP0 on 1=1'||(SELECT KEYS FROM TMP2)||'
)'||TMP3.WITH_SQL||'
SELECT * FROM ('
||TMP3.COL_SQL||
')
WHERE COL IS NOT NULL;' AS FINAL_SQL
FROM TMP3
;




--双行多列对比-----------------------------------------------------
--第一步-----------------------------------------------------
select
   key1,key2
  -- *
  from 
  xxxxxxx_diff
  --where owner = 'USERB'
  group by key1,key2
  having count(distinct owner)=2 and count(owner) =2
;
--第二步XXXXXX-----------------------------------------------------
select * from xxxxxx_diff where key1 = 'xxxx' AND key2 = 'xxxx'
;
--第三步-----------------------------------------------------

with TMP_TABLE_NAME AS (
SELECT UPPER('TTTTTTTTTT') AS NAME FROM DUAL
)
,TMP1 AS (
SELECT substr(COL_SQL,0,length(COL_SQL)-9) AS COL_SQL from (
SELECT replace(wm_concat('SELECT '|| ''''||A.COLUMN_NAME|| ''' AS KIND,'||
	'(SELECT '|| 'TO_CHAR('||A.COLUMN_NAME||')' || ' FROM TABLE1 WHERE OWNER = ''USERA'')AS COL_USERA,'||
	'(SELECT '|| 'TO_CHAR('||A.COLUMN_NAME ||')'|| ' FROM TABLE1 WHERE OWNER = ''USERB'')AS COL_USERB'||
	' FROM DUAL '||'UNION ALL'),'UNION ALL,','UNION ALL ') AS COL_SQL
	--,A.COLUMN_NAME
	--,ROWNUM
FROM DBA_TAB_COLS A
WHERE A.OWNER = 'USER_DIFF'
	AND A.TABLE_NAME = (SELECT NAME FROM TMP_TABLE_NAME))
)
/* 最终SQL */
SELECT 
'WITH TABLE1 AS(
XXXXXX
)
SELECT * FROM (
'||TMP1.COL_SQL||'
)WHERE NVL(COL_USERA,''XX'')<>NVL(COL_USERB,''XX'')' AS FINAL_SQL
FROM TMP1
;





--多行单列对比步骤版-----------------------------------------------------
--第一步：把表名和主键插入主键表-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_KEYS (
TABLE_NAME VARCHAR2(255),	--表名
KEYS VARCHAR2(255)			--主键
)
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','CLMNO');
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','GETDUTYNAME');
COMMIT;

--第二步：替换表名以生成每列SQL-----------------------------------------------------
WITH TMP0 AS (
SELECT UPPER('-----表名-----') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT substr(COL_SQL,0,length(COL_SQL)-9) from (
SELECT replace(wm_concat('(SELECT CASE WHEN EXISTS (SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM TMP ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''空字段njy'')) > 1 ) THEN '''||COLUMN_NAME||'''	ELSE NULL END AS COL FROM DUAL) UNION ALL'),'UNION ALL,','UNION ALL ') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME <> 'OWNER');

--第二.5步：替换表名列名以生成单列SQL-----------------------------------------------------
WITH TMP0 AS (
SELECT UPPER('-----表名-----') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT ('SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM '||(SELECT * FROM TMP0)||' ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''空字段njy'')) > 1 ') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME = '-----列名-----';

--第三步：复制列SQL填入下方-----------------------------------------------------
WITH
TMP_TABLE_NAME AS (
SELECT * FROM ALY_LLTAXCLMLIST_DIFF
),
TMP0 AS(
SELECT CLMNO,GETDUTYNAME
FROM (SELECT * FROM TMP_TABLE_NAME) 
GROUP BY CLMNO,GETDUTYNAME 
HAVING COUNT(OWNER) = 2 AND COUNT(DISTINCT OWNER) = 2
),
TMP AS (
SELECT * FROM (SELECT * FROM TMP_TABLE_NAME) DIFF  WHERE EXISTS( SELECT 1 FROM TMP0 WHERE 
CLMNO = DIFF.CLMNO AND 
GETDUTYNAME = DIFF.GETDUTYNAME ) AND ROWNUM <101
)
SELECT * FROM (

--填入列SQL

)
WHERE COL IS NOT NULL;
-----------------------------------------------------








--单独去掉列的查询方式
--select clmno,GETDUTYNAME from(
--select distinct a.* from (
--select CLMNO ,RCONTNO ,RGRPNAME ,SALECHNL ,CCONTNO ,CONTNO ,APPNTNAME ,APPNTNO ,APPNTIDTYPE ,APPNTIDNO ,INSUREDNAME ,INSUREDNO ,INSUREDIDTYPE ,INSUREDIDNO ,CUREDESC ,RISKCODE ,RISKNAME ,GETDUTYNAME ,ACCDENTDESC ,HOSPITALNAME ,ICDNAME ,TOTALAMNT ,SELFAMNT ,FACTORVALUE ,REALPAY ,GETKIND ,DECLINEAMNT ,CASESOURCE ,LITTLECLAIMFLAG ,SECONDSIGNCOM ,SIGNCOM ,CVALIDATE ,ACCIDENTDATE ,RPTDATE ,SECONDACCEPTCOM ,ACCEPTCOM ,ACCEPTER ,ACCEPTDATE ,/*INPUTCOM ,*/INPUTER ,INPUTTIME ,AUDITCOM ,AUDITPER ,AUDITTIME ,APPROVECOM ,APPROVER ,APPROVETIME ,GETDATE ,INQSTARTDATE ,INQENDDATE
--from ALY_LLTAXCLMLIST_DIFF  ) a) group by clmno,GETDUTYNAME having count(1) =2;




