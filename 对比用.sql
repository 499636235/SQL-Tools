--���ݻ��˺�����
zkrxuechengbin
Dw@123456789

--�Աȱ���
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'TTTTTTTTTTTT'||'_DIFF';
call USER_DIFF.SP_TABLE_DIFF('TTTTTTTTTTTT','USERA','USERB','USER_DIFF');
call user_diff.SP_TABLE_DIFF_DETAIL('TTTTTTTTTTTT'||'_DIFF');
select * from USER_DIFF.RESULT_DIFF where TARGET_NAME = 'TTTTTTTTTTTT'||'_DIFF' order by id desc;
select * from USER_DIFF.RESULT_DIFF_DETAIL where TARGET_NAME = 'TTTTTTTTTTTT'||'_DIFF' order by id desc;
select * from USER_DIFF.TABLE_DIFF_DETAIL where table_name = 'TTTTTTTTTTTT'||'_DIFF' order by DIFF_NUM desc;

--����������� �Աȱ���
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'TTTTTTTTTTTT'||'_D';
call USER_DIFF.SP_TABLE_D('TTTTTTTTTTTT','USERA','USERB','USER_DIFF');
call user_diff.SP_TABLE_DIFF_DETAIL('TTTTTTTTTTTT'||'_D');
select * from USER_DIFF.RESULT_DIFF where TARGET_NAME = 'TTTTTTTTTTTT'||'_D' order by id desc;
select * from USER_DIFF.RESULT_DIFF_DETAIL where TARGET_NAME = 'TTTTTTTTTTTT'||'_D' order by id desc;
select * from USER_DIFF.TABLE_DIFF_DETAIL where table_name = 'TTTTTTTTTTTT'||'_D' order by DIFF_NUM desc;

--�����ʽ��һ�������ֶ�ͳһ��ʽ!!!
update userb.BALY_LAGRPCONTRESULTLIST set GRADENAME = substr(GRADENAME,instr(GRADENAME,'-')+1,50);

--��ѯ�����ʧ������
SELECT TARGET_NAME,ROWS_OF_SUCC,SYN_TIME FROM USER_DIFF.RESULT_DIFF ORDER BY ROWS_OF_SUCC;

--��ѯ������Ĳ���
SELECT * FROM XXXXX_DIFF;

--��ѯ�������еĲ���������Ӧ������������SQL��
WITH TMP0 AS (
SELECT UPPER('TTTTT_DIFF') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT ('SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM '||(SELECT * FROM TMP0)||' ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''���ֶ�njy'')) > 1 
') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME = 'CCCCCCCCCOL';


--���ݶ�Ӧ������ ��ѯ�������еĲ��죨����SQL��
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


--�˶�����-----------------------------------------------------
select count(1) as �����ظ�����������,
	case when count(1)=0 then '��' else '��' end as �Ƿ�����
	from (
		select 1
		from USER.ALY_LLTAXCLMLIST 
		group by keys
		having count(1) > 1 ) ;


--�ѱ�������������������-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_KEYS (
TABLE_NAME VARCHAR2(255),	--����
KEYS VARCHAR2(255)			--����
)
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','CLMNO');
COMMIT;
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'ALY_LLTAXCLMLIST_DIFF';


--�ռ䲻��ʱ�鿴��ռ�ÿռ�
SELECT OWNER,SEGMENT_NAME, SUM(BYTES) / 1024 / 1024 AS M
  FROM DBA_SEGMENTS
 WHERE OWNER IN( 'USERA','USERB')
 GROUP BY SEGMENT_NAME,OWNER
 ORDER BY M DESC;




--���жԱ���־ �������-----------------------------------------------------
CREATE TABLE USER_DIFF.RESULT_DIFF_DETAIL AS SELECT * FROM USER_DIFF.RESULT_DIFF;

--���жԱȽ�� �������-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_DIFF_DETAIL (
TABLE_NAME VARCHAR2(40),	--����
COL VARCHAR2(100),			--����
DIFF_NUM NUMBER,			--���в�������
ALL_DIFF_NUM NUMBER			--�ܲ�������
)

--����ȫ�жԱ����ϰ�-----------------------------------------------------

WITH TMP0 /* ����  'ALY_LCGRPLISTDETAIL_DIFF' */ AS (
SELECT UPPER('����������д����_diff') AS T FROM DUAL
),
TMP1 /* ��������  'key1,key2,key3' */ AS (
SELECT WM_CONCAT(KEYS) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP2 /* ��������  ' and TMP0.key1 = DIFF.key1' */ AS (
SELECT replace(WM_CONCAT(' and TMP0.'||KEYS||' = DIFF.'||KEYS),',','') AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP3 /* ÿ��SQL */ AS (
SELECT WITH_SQL AS WITH_SQL,
substr(COL_SQL,0,length(COL_SQL)-9) AS COL_SQL from (
SELECT 
replace(wm_concat(
', TMP_'||COLUMN_NAME||' AS (
SELECT COUNT(1) AS DIFF_NUM FROM (
SELECT '||(SELECT KEYS FROM TMP1)||' 
	FROM (SELECT '||(SELECT KEYS FROM TMP1)||','||COLUMN_NAME||' FROM TMP1 ) A 
	GROUP BY '||(SELECT KEYS FROM TMP1)||' 
	HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''���ֶ�njy'')) > 1 
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
/* ����SQL */
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




--���е��жԱ����ϰ�-----------------------------------------------------

WITH TMP0 /* ����  'ALY_LCGRPLISTDETAIL_DIFF' */ AS (
SELECT UPPER('����������д����_diff') AS T FROM DUAL
),
TMP00 /* ����  'PREM' */ AS (
SELECT UPPER('����������д����') AS C FROM DUAL
),
TMP1 /* ��������  'key1,key2,key3' */ AS (
SELECT WM_CONCAT(KEYS) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP2 /* ��������  ' and TMP0.key1 = DIFF.key1' */ AS (
SELECT replace(WM_CONCAT(' and TMP0.'||KEYS||' = DIFF.'||KEYS),',','') AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)
),
TMP3 /* ÿ��SQL */ AS (
SELECT 
'
, TMP_'||COLUMN_NAME||' AS (
SELECT COUNT(1) AS DIFF_NUM FROM (
SELECT '||(SELECT KEYS FROM TMP1)||' 
	FROM (SELECT '||(SELECT KEYS FROM TMP1)||','||COLUMN_NAME||' FROM TMP1 ) A 
	GROUP BY '||(SELECT KEYS FROM TMP1)||' 
	HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''���ֶ�njy'')) > 1 
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
/* ����SQL */
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




--˫�ж��жԱ�-----------------------------------------------------
--��һ��-----------------------------------------------------
select
   key1,key2
  -- *
  from 
  xxxxxxx_diff
  --where owner = 'USERB'
  group by key1,key2
  having count(distinct owner)=2 and count(owner) =2
;
--�ڶ���XXXXXX-----------------------------------------------------
select * from xxxxxx_diff where key1 = 'xxxx' AND key2 = 'xxxx'
;
--������-----------------------------------------------------

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
/* ����SQL */
SELECT 
'WITH TABLE1 AS(
XXXXXX
)
SELECT * FROM (
'||TMP1.COL_SQL||'
)WHERE NVL(COL_USERA,''XX'')<>NVL(COL_USERB,''XX'')' AS FINAL_SQL
FROM TMP1
;





--���е��жԱȲ����-----------------------------------------------------
--��һ�����ѱ�������������������-----------------------------------------------------
CREATE TABLE USER_DIFF.TABLE_KEYS (
TABLE_NAME VARCHAR2(255),	--����
KEYS VARCHAR2(255)			--����
)
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','CLMNO');
INSERT INTO TABLE_KEYS VALUES('ALY_LLTAXCLMLIST_DIFF','GETDUTYNAME');
COMMIT;

--�ڶ������滻����������ÿ��SQL-----------------------------------------------------
WITH TMP0 AS (
SELECT UPPER('-----����-----') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT substr(COL_SQL,0,length(COL_SQL)-9) from (
SELECT replace(wm_concat('(SELECT CASE WHEN EXISTS (SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM TMP ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''���ֶ�njy'')) > 1 ) THEN '''||COLUMN_NAME||'''	ELSE NULL END AS COL FROM DUAL) UNION ALL'),'UNION ALL,','UNION ALL ') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME <> 'OWNER');

--�ڶ�.5�����滻�������������ɵ���SQL-----------------------------------------------------
WITH TMP0 AS (
SELECT UPPER('-----����-----') FROM DUAL
),
TMP AS (
SELECT TO_CHAR(WM_CONCAT(KEYS)) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)
)
SELECT ('SELECT '||(SELECT KEYS FROM TMP)||' FROM (SELECT '||(SELECT KEYS FROM TMP)||','||COLUMN_NAME||' FROM '||(SELECT * FROM TMP0)||' ) A GROUP BY '||(SELECT KEYS FROM TMP)||' HAVING COUNT(DISTINCT NVL(TO_CHAR('||COLUMN_NAME||'),''���ֶ�njy'')) > 1 ') AS COL_SQL
--,COLUMN_NAME 
FROM DBA_TAB_COLS 
WHERE OWNER = 'USER_DIFF'  
AND TABLE_NAME = (SELECT * FROM TMP0)
AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT * FROM TMP0)) 
AND COLUMN_NAME = '-----����-----';

--��������������SQL�����·�-----------------------------------------------------
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

--������SQL

)
WHERE COL IS NOT NULL;
-----------------------------------------------------








--����ȥ���еĲ�ѯ��ʽ
--select clmno,GETDUTYNAME from(
--select distinct a.* from (
--select CLMNO ,RCONTNO ,RGRPNAME ,SALECHNL ,CCONTNO ,CONTNO ,APPNTNAME ,APPNTNO ,APPNTIDTYPE ,APPNTIDNO ,INSUREDNAME ,INSUREDNO ,INSUREDIDTYPE ,INSUREDIDNO ,CUREDESC ,RISKCODE ,RISKNAME ,GETDUTYNAME ,ACCDENTDESC ,HOSPITALNAME ,ICDNAME ,TOTALAMNT ,SELFAMNT ,FACTORVALUE ,REALPAY ,GETKIND ,DECLINEAMNT ,CASESOURCE ,LITTLECLAIMFLAG ,SECONDSIGNCOM ,SIGNCOM ,CVALIDATE ,ACCIDENTDATE ,RPTDATE ,SECONDACCEPTCOM ,ACCEPTCOM ,ACCEPTER ,ACCEPTDATE ,/*INPUTCOM ,*/INPUTER ,INPUTTIME ,AUDITCOM ,AUDITPER ,AUDITTIME ,APPROVECOM ,APPROVER ,APPROVETIME ,GETDATE ,INQSTARTDATE ,INQENDDATE
--from ALY_LLTAXCLMLIST_DIFF  ) a) group by clmno,GETDUTYNAME having count(1) =2;




