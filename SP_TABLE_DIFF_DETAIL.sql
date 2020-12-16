create or replace procedure SP_TABLE_DIFF_DETAIL(tab_name0       in varchar2 --比对表名
                                          ) is
  --比对数据表的差异
  tab_name varchar2(40) := '';
  v_sql_field varchar2(4000) := '';
  v_sql_ddl1   varchar2(4000) := '';
  v_sql_ddl_d1 varchar2(4000) := '';
  v_sql_ddl2   varchar2(4000) := '';
  v_sql_ddl_d2 varchar2(4000) := '';
  v_sql_dml   clob := '';
  v_sql_dml2   varchar2(4000) := '';
  v_em        varchar2(4000); --错误信息

  v_count    integer;
  v_num      integer;
  v_diff_num integer;

  v_target_begin_time date;
begin
  v_target_begin_time := sysdate;
  v_diff_num          := 0;
  select upper(tab_name0) into tab_name from dual;
  
  --1,检查TABLE_FINAL_SQL是否存在
  select count(1)
    into v_count
    from dba_tables a
   where 1 = 1
     and a.OWNER = 'USER_DIFF'
     and a.TABLE_NAME = 'TABLE_FINAL_SQL';

  v_sql_ddl1 := 'create table USER_DIFF.TABLE_FINAL_SQL (TABLE_NAME VARCHAR2(40),FINAL_SQL CLOB)';

  if v_count = 0 then
    execute immediate v_sql_ddl1;
  end if;
  
  --2,检查TABLE_DIFF_DETAIL是否存在
  select count(1)
    into v_count
    from dba_tables a
   where 1 = 1
     and a.OWNER = 'USER_DIFF'
     and a.TABLE_NAME = 'TABLE_DIFF_DETAIL';

  v_sql_ddl1 := 'create table USER_DIFF.TABLE_DIFF_DETAIL (TABLE_NAME VARCHAR2(40),COL VARCHAR2(100),DIFF_NUM NUMBER,ALL_DIFF_NUM NUMBER)';

  if v_count = 0 then
    execute immediate v_sql_ddl1;
  end if;
  
  /*
  --2,检查RESULT_DIFF_DETAIL是否存在
  select count(1)
    into v_count
    from dba_tables a
   where 1 = 1
     and a.OWNER = 'USER_DIFF'
     and a.TABLE_NAME = 'RESULT_DIFF_DETAIL';

  v_sql_ddl2 := 'create table USER_DIFF.RESULT_DIFF_DETAIL AS SELECT * FROM USER_DIFF.RESULT_DIFF WHERE 1=2';

  if v_count = 0 then
    execute immediate v_sql_ddl2;
  else
    v_sql_ddl_d2 := 'drop table USER_DIFF.RESULT_DIFF_DETAIL';
    execute immediate v_sql_ddl_d2;
    execute immediate v_sql_ddl2;
  end if;
  */
  
  select count(1) into v_count from user_diff.TABLE_FINAL_SQL where table_name = tab_name;
  if v_count <>0 then
    delete from user_diff.TABLE_FINAL_SQL where table_name = tab_name;
    commit;
  end if;
  
  --3,插入 差异数据表
  v_sql_dml := ''||
'insert into user_diff.TABLE_FINAL_SQL (table_name,final_sql)'||
'WITH TMP0 AS ('||
'SELECT UPPER('''||tab_name||''') AS T FROM DUAL'||
'),'||
'TMP1 AS ('||
'SELECT WM_CONCAT(KEYS) AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)'||
'),'||
'TMP2 AS ('||
'SELECT replace(WM_CONCAT('' and TMP0.''||KEYS||'' = DIFF.''||KEYS),'','','''') AS KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)'||
'),'||
'TMP3 AS ('||
'SELECT WITH_SQL AS WITH_SQL,'||
'substr(COL_SQL,0,length(COL_SQL)-9) AS COL_SQL from ('||
'SELECT '||
'replace(wm_concat('||
-- user 'TXXX' if the length of 'TMP_XXX' is longer than 30
--''', TMP_''||COLUMN_NAME||'' AS ('||
''', T''||COLUMN_NAME||'' AS ('||
'SELECT COUNT(1) AS DIFF_NUM FROM ('||
'SELECT ''||(SELECT KEYS FROM TMP1)||'' '||
' FROM (SELECT ''||(SELECT KEYS FROM TMP1)||'',''||COLUMN_NAME||'' FROM TMP1 ) A '||
' GROUP BY ''||(SELECT KEYS FROM TMP1)||'' '||
' HAVING COUNT(DISTINCT NVL(TO_CHAR(''||COLUMN_NAME||''),''''空字段njy'''')) > 1 '||
' )'||
')'''||
'),'',,'','','') AS WITH_SQL,'||
'replace(wm_concat('||
'''(SELECT '''''||tab_name||''''' AS TABLE_NAME,'||
'CASE '||
'WHEN 0 <>'||
-- user 'TXXX' if the length of 'TMP_XXX' is longer than 30
--' (SELECT DIFF_NUM FROM TMP_''||COLUMN_NAME||'') '||
' (SELECT DIFF_NUM FROM T''||COLUMN_NAME||'') '||
'THEN ''''''||COLUMN_NAME||'''''' '||
'ELSE NULL '||
'END AS COL,'||
-- user 'TXXX' if the length of 'TMP_XXX' is longer than 30
--'(SELECT DIFF_NUM FROM TMP_''||COLUMN_NAME||'') AS DIFF_NUM,'||
'(SELECT DIFF_NUM FROM T''||COLUMN_NAME||'') AS DIFF_NUM,'||
'(SELECT COUNT(1) FROM TMP0) AS ALL_DIFF_NUM '||
'FROM DUAL) '||
'UNION ALL'''||
'),''UNION ALL,'',''UNION ALL '') AS COL_SQL '||
'FROM DBA_TAB_COLS '||
'WHERE OWNER = ''USER_DIFF''  '||
'AND TABLE_NAME = (SELECT T FROM TMP0)'||
'AND COLUMN_NAME NOT IN (SELECT KEYS FROM TABLE_KEYS WHERE TABLE_NAME = (SELECT T FROM TMP0)) '||
'AND COLUMN_NAME <> ''OWNER'')'||
')'||
'SELECT '''||tab_name||''' AS TABLE_NAME,'||
'''WITH TMP0 AS('||
'SELECT ''||(SELECT KEYS FROM TMP1)||'''||
' FROM ''||(SELECT T FROM TMP0)||'''||
' GROUP BY ''||(SELECT KEYS FROM TMP1)||'''||
' HAVING COUNT(OWNER)=2 AND COUNT(DISTINCT OWNER)=2'||
'),'||
'TMP1 AS ('||
'SELECT DIFF.* FROM ''||(SELECT T FROM TMP0)||'' DIFF  '||
' inner join TMP0 on 1=1''||(SELECT KEYS FROM TMP2)||'''||
')''||TMP3.WITH_SQL||'''||
'SELECT * FROM ('''||
'||TMP3.COL_SQL||'||
''')'||
'WHERE COL IS NOT NULL'' AS FINAL_SQL '||
'FROM TMP3';
 --dbms_output.put_line(v_sql_dml);
  execute immediate v_sql_dml;
  v_diff_num := sql%rowcount;
  commit;
  
  
  
  select count(1) into v_count from user_diff.TABLE_DIFF_DETAIL where table_name = tab_name;
  if v_count<>0then
    delete from user_diff.TABLE_DIFF_DETAIL where table_name = tab_name;
    commit;
  end if;
  
  select FINAL_SQL into v_sql_dml
  from user_diff.TABLE_FINAL_SQL where table_name=tab_name;
v_sql_dml:=  'insert into user_diff.TABLE_DIFF_DETAIL (TABLE_NAME,COL,DIFF_NUM,ALL_DIFF_NUM) '||v_sql_dml;
  dbms_output.put_line(v_sql_dml);
  execute immediate v_sql_dml;
  commit;
  
  

  --成功日志输出
  insert into user_diff.result_diff_detail
    (id,
     diff_type,
     target_name,
     target_begin_time,
     target_end_time,
     rows_of_succ,
     fail_error)
  values
    (user_diff.seq_id.nextval,
     '001', --成功
     upper(tab_name) ,
     v_target_begin_time,
     sysdate,
     v_diff_num,
     '');
  commit;

exception
  when others then
    v_em := 'error_code:' || dbms_utility.format_error_stack ||
            substr(dbms_utility.format_error_backtrace, 1, 1500);
    rollback;
    --错误日志输出
    insert into user_diff.result_diff_detail
      (id,
       diff_type,
       target_name,
       target_begin_time,
       target_end_time,
       rows_of_succ,
       fail_error)
    values
      (user_diff.seq_id.nextval,
       '002', --错误
       upper(tab_name) ,
       v_target_begin_time,
       sysdate,
       v_diff_num,
       v_em);
    commit;

end SP_TABLE_DIFF_DETAIL;
