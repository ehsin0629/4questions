use db;
--1
select ca.user_id as StaffId, t.name as TeamName, d.title as Department, month (ins_ts) as 'Month', 
convert (varchar, FLOOR ((count(ca.log_id) + 0.0) / (select count(ca1.log_id) from customer_action ca1 where ca1.user_id=ca.user_id) * 100)) + '%' as 'Total Action Percentage'
from customer_action ca
inner join user_team ut on ca.user_id=ut.user_id
inner join team t on ut.team_id=t.id
inner join department d on t.department_id=d.id
where ca.user_id in (select top 3 user_id from customer_action order by ins_ts desc)
group by t.name, d.title, month (ins_ts), ca.user_id
order by 1, 4, 5;

--2
select TeamName, Department, Month, [Total Action Percentage] from
(
	select ROW_NUMBER()  OVER(Partition by t.name, d.title order by t.name, d.title) as 'RowNum',
	ca.user_id as StaffId, t.name as TeamName, d.title as Department, month (ins_ts) as 'Month', 
	convert (varchar, FLOOR ((count(ca.log_id) + 0.0) / (select count(ca1.log_id) from customer_action ca1 where ca1.user_id=ca.user_id) * 100)) + '%' as 'Total Action Percentage'
	from customer_action ca
	inner join user_team ut on ca.user_id=ut.user_id
	inner join team t on ut.team_id=t.id
	inner join department d on t.department_id=d.id
	group by t.name, d.title, month (ins_ts), ca.user_id
) as temp
where RowNum in (1,2,3)
order by 1,2,3;

--3
select top 3 convert (date, ins_ts) as Date, user_id as Staff_ID, customer_id, sum (convert (int, new_value)) as Summary
from
(
select *
from customer_action
where user_id=4462
and convert (date, ins_ts)<=convert (date, '12/14/2020')
) as temp
group by convert (date, ins_ts), user_id, customer_id
order by convert (date, ins_ts) desc;

--4
select t.id, t.name, sum (convert (int, user_count)) as HeadCount
from team t
inner join sales_team_head_count st on t.name=st.team_name
where convert (date, updated_at)<=convert (date, '12/14/2019')
group by t.id, t.name
order by 3 desc;