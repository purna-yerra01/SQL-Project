 --1.what is the total amount spent by each customer in zomato?
 select * from product
 select * from sales
 select userid,sum(price)as total_amt_spent from product p join sales s on p.product_id=s.product_id group by (userid)

 --2.how many days that each customer visted zomato?
 select * from sales
 select userid, count(distinct(created_date))as visited from sales group by userid
 --3.What is the first product purchased by each customer along with product name?
	 select userid,k.product_id,p.product_name from(
		select *,rank() over(partition by userid order by created_date) as rn from sales)as k join product p on p.product_id=k.product_id where k.rn=1

--4 what is the most frequent product purchased by each customers?
select userid,count(product_id) as cnt from sales where product_id=
(select top 1 product_id from sales group by product_id order by count(product_id) desc) group by userid

--5 which item is most popular for each customer?
select userid,product_id,cnt from(
	select *,dense_rank() over(partition by userid order by cnt desc) as rn from (
		select userid,product_id,count(product_id) as cnt from sales group by product_id,userid )a)b
where b.rn=1
-- 6 which item is purchased first by the customer after login ?
select * from sales
select userid,product_id from (
select *,rank() over(partition by userid order by created_date)rn from sales )b where b.rn=1
--7 which item is purchased first by the customer after becoming gold member ?
select * from(
	select *,dense_rank() over(partition by userid order by product_id) as rn from(
	  select g.userid,s.created_date,s.product_id,g.gold_signup_date from goldusers g join sales s on g.userid = s.userid and s.created_date>=g.gold_signup_date)b)a where a.rn=1
--8 which item is purchased by the customer just before they becoming gold member?
select * from(
	select *,dense_rank() over(partition by userid order by created_date desc) as rn from(
	  select g.userid,s.created_date,s.product_id,g.gold_signup_date from goldusers g join sales s on g.userid = s.userid and s.created_date<=g.gold_signup_date)b)a where a.rn=1

--9 what is the total orders and amount spent by each customer before becomming gold member?
select a.userid,count(created_date)as total_orders,sum(price) total from(
	select *,dense_rank() over(partition by userid order by created_date desc) as rn from(
	  select g.userid,s.created_date,s.product_id,g.gold_signup_date from goldusers g join sales s on g.userid = s.userid and s.created_date<=g.gold_signup_date)b)a join product p on a.product_id=p.product_id  group by userid

--10 allocate zomato points on each purchase for eg for P1 on Purchase Every 5rs they get 1 points for P2 they get 10rs 1point for P3 on 5rs they get 1point calculate how many point they get till now 

select * from sales 
select * from product 

select userid,sum(earned_points) as total_points_earned
from
(select a.*,total/points as earned_points
from (
select s.userid,p.product_id,sum(p.price)as total,
case when p.product_id=1 then 5 when
p.product_id=2 then 2 when p.product_id=3 then 5 else 0 end as points
from sales s join product p on p.product_id=s.product_id group by userid ,p.product_id )a)b group by userid

