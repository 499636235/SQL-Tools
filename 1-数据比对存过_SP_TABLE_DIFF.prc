create or replace procedure SP_TABLE_DIFF(tab_name       in varchar2, --�ȶԱ���
                                          user_name_from in varchar2, --Դ�� �ȶԱ������û�    DC-����
                                          user_name_to   in varchar2, --Ŀ��� �ȶԱ������û�  LIS-���� ��dblink��
                                          user_name_out  in varchar2 --�ȶԲ�������Ϣ�����û� USER_DIFF-����
                                          ) is
  --�ȶ����ݱ�Ĳ���
  v_sql_field varchar2(4000) := '';
  v_sql_ddl   varchar2(4000) := '';
  v_sql_ddl_d varchar2(4000) := '';
  v_sql_dml   varchar2(4000) := '';
  v_em        varchar2(4000); --������Ϣ

  v_count    integer;
  v_num      integer;
  v_diff_num integer;

  v_target_begin_time date;
begin
  v_target_begin_time := sysdate;
  v_diff_num          := 0;
  --0,���ȶԵı�Ľṹ�Ƿ�һ�£�����һ��,��ȡ��ͬ�Ľṹ���ȶԲ���
  select count(1)
    into v_num
    from (select a.column_name, a.data_type, a.data_length
            from dba_tab_cols a
           where a.owner = upper(user_name_from)
             and a.table_name = upper(tab_name)
          minus
          select a.column_name, a.data_type, a.data_length
            from dba_tab_cols a
           where a.owner = upper(user_name_to)
             and a.table_name = upper(tab_name));
  if v_num <> 0 then
    select wm_concat(column_name)
      into v_sql_field
      from (select a.column_name, a.data_type, a.data_length
              from dba_tab_cols a
             where a.owner = upper(user_name_from)
               and a.table_name = upper(tab_name)
            intersect
            select a.column_name, a.data_type, a.data_length
              from dba_tab_cols a
             where a.owner = upper(user_name_to)
               and a.table_name = upper(tab_name));
  else
    v_sql_field := '';
  end if;

  --1,�ж� ������Ϣ���Ƿ����
  select count(1)
    into v_count
    from dba_tables a
   where 1 = 1
     and a.OWNER = upper(user_name_out)
     and a.TABLE_NAME = upper(tab_name) || '_DIFF';

  v_sql_ddl := 'create table ' || user_name_out || '.' || upper(tab_name) ||
               '_DIFF' ||
               ' as select to_char(sysdate,''yyyy-mm-dd hh24:mi:ss'') as owner,t.* from ' ||
               user_name_from || '.' || upper(tab_name) || ' t where 1=2';

  if v_num <> 0 then
    v_sql_ddl := replace(v_sql_ddl, '*', v_sql_field);
  end if;

  if v_count = 0 then
    execute immediate v_sql_ddl;
  else
    v_sql_ddl_d := 'drop table ' || user_name_out || '.' || upper(tab_name) ||
                   '_DIFF';
    execute immediate v_sql_ddl_d;
    execute immediate v_sql_ddl;
  end if;

  --2,���� �������ݱ�
  v_sql_dml := 'insert into ' || user_name_out || '.' || upper(tab_name) ||
               '_DIFF ' || 'select ' || '''' || user_name_from || '''' ||
               ',t1.* from (select *
           from ' || user_name_from || '.' || upper(tab_name) || '
        minus
        select * from ' || user_name_to || '.' ||
               upper(tab_name) || ') t1' || ' union
  select ' || '''' || user_name_to || '''' ||
               ',t2.*
    from (select *
            from ' || user_name_to || '.' || upper(tab_name) ||
               '' || ' minus select * from ' || user_name_from || '.' ||
               upper(tab_name) || ') t2';
  if v_num <> 0 then
    execute immediate replace(v_sql_dml, '*', v_sql_field);
  else
    execute immediate v_sql_dml;
  end if;
  v_diff_num := sql%rowcount;
  commit;

  --�ɹ���־���
  insert into user_diff.result_diff
    (id,
     diff_type,
     target_name,
     target_begin_time,
     target_end_time,
     rows_of_succ,
     fail_error)
  values
    (user_diff.seq_id.nextval,
     '001', --�ɹ�
     upper(tab_name) || '_DIFF',
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
    --������־���
    insert into user_diff.result_diff
      (id,
       diff_type,
       target_name,
       target_begin_time,
       target_end_time,
       rows_of_succ,
       fail_error)
    values
      (user_diff.seq_id.nextval,
       '002', --����
       upper(tab_name) || '_DIFF',
       v_target_begin_time,
       sysdate,
       v_diff_num,
       v_em);
    commit;
  
end SP_TABLE_DIFF;
/
