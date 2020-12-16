

--1,dblink 创建
--drop database link DC_TO_DIFF;
--create database link DC_TO_DIFF
-- connect to lis identified by dat
--  using '(DESCRIPTION =(ADDRESS_LIST =(ADDRESS =(PROTOCOL = TCP)(HOST = 10.1.217.51)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = oratest51)))';
  

--2,临时用户 创建 用于存放比对数据的差异信息,数据比对完，可删除
--drop user USER_DIFF;
create user USER_DIFF
  identified by USER_DIFF
  default tablespace DC
  temporary tablespace TEMP
  profile DEFAULT;

grant CONNECT to USER_DIFF; --授予连接权限
grant RESOURCE to USER_DIFF; --授予资源权限
grant SELECT ANY TABLE to USER_DIFF;--查询任何表

--3,创建表 用于存放数据比较结果差异信息
-- Create table
create table USER_DIFF.RESULT_DIFF
(
  ID                NUMBER,
  DIFF_TYPE         CHAR(3),
  TARGET_NAME       VARCHAR2(128),
  SYN_TIME          DATE default CURRENT_TIMESTAMP,
  TARGET_BEGIN_TIME DATE,
  TARGET_END_TIME   DATE,
  ROWS_OF_SUCC      NUMBER,
  FAIL_ERROR        VARCHAR2(4000)
)
;
-- Add comments to the table 
comment on table USER_DIFF.RESULT_DIFF
  is '数据比较结果差异表';
-- Add comments to the columns 
comment on column USER_DIFF.RESULT_DIFF.ID
  is '序号';
comment on column USER_DIFF.RESULT_DIFF.DIFF_TYPE
  is '类型 001-成功 002-失败';
comment on column USER_DIFF.RESULT_DIFF.TARGET_NAME
  is '目标名称';
comment on column USER_DIFF.RESULT_DIFF.SYN_TIME
  is '操作时间';
comment on column USER_DIFF.RESULT_DIFF.TARGET_BEGIN_TIME
  is '开始时间';
comment on column USER_DIFF.RESULT_DIFF.TARGET_END_TIME
  is '结束时间';
comment on column USER_DIFF.RESULT_DIFF.ROWS_OF_SUCC
  is '成功执行条数';
comment on column USER_DIFF.RESULT_DIFF.FAIL_ERROR
  is '错误信息';
-- Grant/Revoke object privileges 
grant select, insert, update, delete, references, alter, index on USER_DIFF.RESULT_DIFF to DC;


-- 4,创建序列
--drop sequence USER_DIFF.SEQ_ID;
create sequence USER_DIFF.SEQ_ID
minvalue 1
maxvalue 999999999
start with 1
increment by 1
nocache
cycle
order;


--5,有关权限授予
grant select any dictionary to dc; --当前用户下
grant select any sequence to dc;   --当前用户下
grant create any table to dc; ----当前用户下
grant drop any table to dc; ----当前用户下

grant select any table to dc; ----当前用户下
grant insert any table to dc; ----当前用户下
grant delete any table to dc; ----当前用户下
grant update any table to dc; ----当前用户下

--grant all on user_diff.result_diff to dc;--USER_DIFF用户下





