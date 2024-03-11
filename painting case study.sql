# 1. Fetch all the paintings which are not displayed on any museums
select count(*) from work where museum_id is null;

# 2. Are there museums without any paintings
select m.museum_id, name
from museum m
where m.museum_id not in(select distinct museum_id from work);

# 3. How many paintings have an asking price of more than their regular price
select count(size_id) from product_size
where sale_price >regular_price;

# 4. Identify the paintings whose asking price is less than 50% of its regular price
select *
from product_size
where sale_price<(regular_price*0.5);

# 5. Which canvas size cost the most
select label as canvas, p.sale_price 
from (
select *, rank() over(order by sale_price desc) as rn
from product_size) p
join canvas_size c
on c.size_id=p.size_id
where p.rn=1;

# 6. Delete duplicate records from work , product_size, subject and image_link tables
with cte as(
select work_id,
row_number() over(partition by work_id) as rn
from work)
delete from cte where rn > 1;

# 7. Identify the museums with invalid city information in the given dataset
select name as musuem_name, city
from museum
where city regexp '[0-9]' or city is null;
    
# 8. Museum_Hours table has 1 invalid entry. Identify it and remove it
with cte as(
select museum_id,day,
row_number() over(partition by museum_id, day) as rn
from museum_hours)
delete from cte where rn > 1;

# 9. Fetch the top 10 most famous painting subject (why combiming with work table-whats the logic behind this)
with cte as(
select s.subject, count(*) as total,
dense_rank() over(order by count(*) desc) as rnk
from work w
join subject s on s.work_id = w.work_id
group by s.subject)

select subject from cte where rnk < 11;


# 10. Identify the museums which are open on both sunday and monday. Display museum name, city
select distinct m.name as museum_name, m.city, m.state,m.country
	from museum_hours mh 
	join museum m on m.museum_id=mh.museum_id
	where day='Sunday'
	and exists (select 1 from museum_hours mh2 
				where mh2.museum_id=mh.museum_id 
			    and mh2.day='Monday');

# 11. How many museums are open every single day
select count(1)
from (select museum_id, count(1)
from museum_hours
group by museum_id
having count(1) = 7) x;

# 12. which are the top 5 most popular museum?(popularity is defined based on most no. of paintings in a museum)
select * from (
select m.museum_id,count(*) as no_of_paintings , rank() over(order by count(*) desc) as rn 
from work w
join museum m
on m.museum_id=w.museum_id
group by m.museum_id) a
where a.rn<=5;

# 13. Who are the top 5 most popular artist? (popularity is defined based on most no of paintings done by artist)
select * from (
select a.artist_id, count(*) as no_of_paintings , rank() over (order by count(*) desc) as rn
from work w
inner join artist a 
on a.artist_id= w.artist_id
group by a.artist_id)a 
where a.rn<=5;

# 14. Display the 3 least popular canvas sizes
with cte as(
select size_id, count(*) as cnt,
dense_rank() over(order by count(*)) as rnk
from product_size 
group by size_id)

select c.size_id, c2.label as canvas_name
from cte c
join canvas_size c2 on c2.size_id = c.size_id
where rnk <=3;

# 15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
with cte as(
select museum_id,
str_to_date(open, '%h:%i:%p') as open_time,
str_to_date(close, '%h:%i:%p') as close_time,
timediff(str_to_date(close, '%h:%i:%p'), str_to_date(open, '%h:%i:%p')) as open_duration,
dense_rank() over(order by timediff(str_to_date(close, '%h:%i:%p'), str_to_date(open, '%h:%i:%p')) desc) as rnk
from museum_hours)

select  m.name, m.state, open_duration
from cte c
join museum m on m.museum_id = c.museum_id
where rnk = 1;

# 16. Which museum has the most no of most popular painting style?
select * from (
select m.name as museum_name,style,count(*)
			,rank() over(order by count(1) desc) as rnk
			from work w 
            inner join museum m 
            on m.museum_id=w.museum_id
            group by style,m.name) a
            where a.rnk=1;
            
# 17. Identify the artists whose paintings are displayed in multiple countries
with cte as (
select w.artist_id, full_name, count(distinct country) as cnt
from work w 
join museum m on m.museum_id = w.museum_id
join artist a on a.artist_id = w.artist_id
group by w.artist_id, full_name)

select full_name,cnt as countries_displayed
from cte 
where cnt > 1
order by cnt desc;   

#18) Display the country and the city with most no of museums.
select country, city, count(museum_id) as total_museum
from museum
group by country,city;

#19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 

#most expensive
with cte as(
select work_id,sale_price,
dense_rank() over(order by sale_price desc) as rnk
from product_size)

select a.full_name, m.name as museum_name
from work w 
join artist a on a.artist_id = w.artist_id
join museum m on m.museum_id = w.museum_id
where work_id in (select work_id from cte where rnk = 1);


#20) Which country has the 5th highest no of paintings?
with cte as(
select m.country, 
count(*) as no_of_Paintings,
rank() over(order by count(*) desc) as rnk
from work w
join museum m on m.museum_id=w.museum_id
group by m.country)

select country, no_of_Paintings
from cte where rnk = 5;


      