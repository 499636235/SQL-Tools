

--1,dblink ����
--drop database link DC_TO_DIFF;
--create database link DC_TO_DIFF
-- connect to lis identified by dat
--  using '(DESCRIPTION =(ADDRESS_LIST =(ADDRESS =(PROTOCOL = TCP)(HOST = 10.1.217.51)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = oratest51)))';
  

--2,��ʱ�û� ���� ���ڴ�űȶ����ݵĲ�����Ϣ,���ݱȶ��꣬��ɾ��
--drop user USER_DIFF;
create user USER_DIFF
  identified by USER_DIFF
  default tablespace DC
  temporary tablespace TEMP
  profile DEFAULT;

grant CONNECT to USER_DIFF; --��������Ȩ��
grant RESOURCE to USER_DIFF; --������ԴȨ��
grant SELECT ANY TABLE to USER_DIFF;--��ѯ�κα�

--3,������ ���ڴ�����ݱȽϽ��������Ϣ
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
  is '���ݱȽϽ�������';
-- Add comments to the columns 
comment on column USER_DIFF.RESULT_DIFF.ID
  is '���';
comment on column USER_DIFF.RESULT_DIFF.DIFF_TYPE
  is '���� 001-�ɹ� 002-ʧ��';
comment on column USER_DIFF.RESULT_DIFF.TARGET_NAME
  is 'Ŀ������';
comment on column USER_DIFF.RESULT_DIFF.SYN_TIME
  is '����ʱ��';
comment on column USER_DIFF.RESULT_DIFF.TARGET_BEGIN_TIME
  is '��ʼʱ��';
comment on column USER_DIFF.RESULT_DIFF.TARGET_END_TIME
  is '����ʱ��';
comment on column USER_DIFF.RESULT_DIFF.ROWS_OF_SUCC
  is '�ɹ�ִ������';
comment on column USER_DIFF.RESULT_DIFF.FAIL_ERROR
  is '������Ϣ';
-- Grant/Revoke object privileges 
grant select, insert, update, delete, references, alter, index on USER_DIFF.RESULT_DIFF to DC;


-- 4,��������
--drop sequence USER_DIFF.SEQ_ID;
create sequence USER_DIFF.SEQ_ID
minvalue 1
maxvalue 999999999
start with 1
increment by 1
nocache
cycle
order;


--5,�й�Ȩ������
grant select any dictionary to dc; --��ǰ�û���
grant select any sequence to dc;   --��ǰ�û���
grant create any table to dc; ----��ǰ�û���
grant drop any table to dc; ----��ǰ�û���

grant select any table to dc; ----��ǰ�û���
grant insert any table to dc; ----��ǰ�û���
grant delete any table to dc; ----��ǰ�û���
grant update any table to dc; ----��ǰ�û���

--grant all on user_diff.result_diff to dc;--USER_DIFF�û���





