

-- Select Statement 

SELECT * FROM source;
SELECT * FROM target;

-- Script to create table:

create table source(id int, name varchar(5))

create table target(id int, name varchar(5))

insert into source values(1,'A'),(2,'B'),(3,'C'),(4,'D')

insert into target values(1,'A'),(2,'B'),(4,'X'),(5,'F');

==============================================

-- Method-1 (here I handled null values in the starting only)

with cte as(
		select id, IFNULL(s.name,'NA') as nameS, IFNULL(tlj.name,'NA') as nameT
		from source s left join target tlj USING(id) 
	 UNION
		select id, IFNULL(s.name,'NA') as nameS, IFNULL(trj.name,'NA') as nameT
		from source s right join target trj USING(id) )

select id,
       case 
       when nameS = 'NA' then 'new in target'
       when nameT = 'NA' then 'new in source'
       else 'mis-match' end as comment
from cte where nameS != nameT;

=================================================

-- Method -2 (here handled null value at the end)
with cte as(
		select id, s.name as nameS, tlj.name as nameT
		from source s left join target tlj USING(id) 
        where s.name!=tlj.name or s.name IS NULL or tlj.name IS NULL
	UNION
		select id, s.name as nameS, trj.name as nameT
		from source s right join target trj USING(id) 
		where s.name!=trj.name or s.name IS NULL or trj.name IS NULL  )
select id,
       case 
       when nameS IS NULL then 'new in target'
       when nameT IS NULL then 'new in source'
       else 'mis-match' end as comment from cte ;
       
===============================================
	
-- Method -3  (a different approach)

with cte as(
	select *, 'source' as table_name from source
	UNION ALL
	select *, 'target' as table_name from target ),

	 cte1 as(
	 select id, count(*) as cnt, min(name) as min_name, max(name) as max_name,
            min(table_name) as min_tn, max(table_name) as max_tn from cte group by id
			having count(*)=1 or (count(*)=2 && min_name != max_name) )

select id, 
       case 
	   when cnt=1 then concat('new in ', min_tn) else 'mis-match' end as comment from cte1;


