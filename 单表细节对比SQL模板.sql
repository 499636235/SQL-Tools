SELECT * FROM TABLE_KEYS where TABLE_NAME = 'BALY_LZCARDGENERQUERY'||'_DIFF';
call USER_DIFF.SP_TABLE_DIFF('BALY_LZCARDGENERQUERY','USERA','USERB','USER_DIFF');
call user_diff.SP_TABLE_DIFF_DETAIL('BALY_LZCARDGENERQUERY'||'_DIFF');
select * from USER_DIFF.RESULT_DIFF where TARGET_NAME = 'BALY_LZCARDGENERQUERY'||'_DIFF' order by id desc;
select * from USER_DIFF.RESULT_DIFF_DETAIL where TARGET_NAME = 'BALY_LZCARDGENERQUERY'||'_DIFF' order by id desc;
select * from USER_DIFF.TABLE_DIFF_DETAIL where table_name = 'BALY_LZCARDGENERQUERY'||'_DIFF' order by DIFF_NUM desc;

select * from usera.BALY_LZCARDGENERQUERY;
select * from userb.BALY_LZCARDGENERQUERY;
select * from BALY_LZCARDGENERQUERY_DIFF order by owner;


--truncate table usera.BALY_LZCARDGENERQUERY;
--truncate table userb.BALY_LZCARDGENERQUERY;
select max(acceptdate) from userb.BALY_LZCARDGENERQUERY;

select count(*) from usera.BALY_LZCARDGENERQUERY;
select count(*) from userb.BALY_LZCARDGENERQUERY;
select count(*) from BALY_LZCARDGENERQUERY_DIFF ;


--INSERT INTO TABLE_KEYS VALUES('BALY_LZCARDGENERQUERY_DIFF','CONTNO');
--COMMIT;
SELECT * FROM TABLE_KEYS where TABLE_NAME = 'BALY_LZCARDGENERQUERY_DIFF';



where dateid between date'2020-12-01' and date'2020-12-31';

where dateid between date'2020-11-01' and date'2020-11-30';

where dateid between date'2020-01-01'and  date'2020-12-31';

where dateid between date'2020-01-01 'and  date'2020-11-30';

where dateid = '202012';

where dateid = '202011';

where dateid = date'2020-12-01';

where dateid = date'2020-11-01';