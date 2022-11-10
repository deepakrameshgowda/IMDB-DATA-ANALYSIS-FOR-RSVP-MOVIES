#1)
select count(*) from movie; #ans: 7997
select count(*) from genre; #ans: 14662
select count(*) from director_mapping; #ans: 3867
select count(*) from role_mapping; #ans: 15615
select count(*) from names; #ans: 25735
select count(*) from ratings; #ans: 7997

#2)
select * from movie where id is null;
select * from movie where title is null;
select * from movie where year is null;
select * from movie where date_published is null                                                                                                                                
select * from movie where duration is null;
select * from movie where country is null;
select * from movie where worlwide_gross_income is null;
select * from movie where languages is null;
select * from movie where production_company is null;

#3)
select year, count(id) as number_of_movies from movie group by year;
select month(date_published)as month_num, count(id) as number_of_movies from movie group by month_num;

#4)
select count(id) from movie where country in ('USA', 'India') and year='2019'; 
#or
select count(id) from movie where (country = 'USA' or country = 'India') and year='2019';

#5)
select distinct genre as unique_list_of_genre from genre;

#6)
select genre, count(movie_id) as number_of_movies from genre group by genre order by number_of_movies desc limit 1;

#7)

with common_table_expression as 
(
	select movie_id, count(movie_id) as cnt from genre group by movie_id
)
select count(movie_id) as number_of_movies_with_single_genre from common_table_expression as cte where cte.cnt=1;

#8)
select genre, avg(duration) as avg_duration from movie m inner join genre g where m.id=g.movie_id group by genre;

#9)
create view cte_view as 
with common_table_expression1 as 
(
	select genre, count(id) as movie_count from movie m inner join genre g where m.id=g.movie_id group by genre
)
select genre, movie_count, rank() over(order by movie_count desc) as genre_rank from common_table_expression1 cte1;

select * from cte_view where genre='Thriller';

#10)
select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating, min(total_votes) as min_total_votes, max(total_votes) as max_total_votes, min(median_rating) as min_median_rating, max(median_rating) as max_median_rating from ratings;

#11)
select title, avg_rating, dense_rank() over (order by avg_rating desc) as movie_rank from movie m inner join ratings r where m.id=r.movie_id limit 10;

#12)
select median_rating, count(movie_id) as movie_count from ratings group by median_rating order by movie_count desc;

#13)
with common_table_expression2 as 
(
	select production_company, count(id) as movie_count, avg(avg_rating) as avg_rating from movie m inner join ratings r where m.id=r.movie_id and avg_rating>8 group by production_company order by movie_count desc
)
select production_company, movie_count, dense_rank() over(order by movie_count desc) as prod_company_rank from common_table_expression2 as cte2 where production_company is not null order by movie_count desc;

#14)
select genre, count(id) as movie_count from movie m inner join genre g on m.id=g.movie_id inner join ratings r on m.id=r.movie_id where month(date_published) = 3 and year = 2017 and country = 'USA' and total_votes > 1000 group by genre order by movie_count desc;

#15)
select title, avg_rating, genre from movie m inner join genre g on m.id=g.movie_id inner join ratings r on m.id=r.movie_id where title like 'The%' and avg_rating>8;

#16)
select count(id) from movie m inner join ratings r on m.id=r.movie_id where date_published between '2018-04-01' and '2019-04-01' and median_rating = 8;

#17)
select country, sum(total_votes) as votes from movie m inner join ratings r on m.id=r.movie_id where country in ('Germany', 'Italy') group by country;

#18)
select * from names where name is null; #no null
select * from names where height is null; #null
select * from names where date_of_birth is null; #null
select * from names where known_for_movies is null; #null

#19)
with common_table_expression3 as 
(
	select genre, count(g.movie_id) as movie_count from genre g inner join ratings r on g.movie_id=r.movie_id where avg_rating >8 group by genre order by movie_count desc limit 3
)
select name as director_name, count(dm.movie_id) as movie_count from director_mapping dm inner join names n on dm.name_id = n.id inner join ratings r on dm.movie_id = r.movie_id inner join genre g on dm.movie_id = g.movie_id inner join common_table_expression3 as cte3 on g.genre = cte3.genre where avg_rating > 8 group by director_name order by movie_count desc limit 3;

#20)
with common_table_expression4 as 
(
	select name_id as nid, count(rp.movie_id) as movie_count from role_mapping rp inner join ratings r on rp.movie_id = r.movie_id where category = 'actor' and median_rating >= 8 group by nid
)
select name as actor_name, movie_count from common_table_expression4 as cte4 inner join names n on cte4.nid = n.id  order by movie_count desc limit 2;

#21) 
select production_company, sum(total_votes) as vote_count, dense_rank() over( order by sum(total_votes) desc) as prod_comp_rank from movie m inner join ratings r on m.id = r.movie_id group by production_company order by vote_count desc limit 3;

#22)
select name, sum(total_votes), count(rm.movie_id) as movie_count, sum(avg_rating  * total_votes)/ sum(total_votes) as actor_avg_rating, rank() over(order by sum(avg_rating  * total_votes)/ sum(total_votes) desc, total_votes desc) as actor_rank from role_mapping rm inner join ratings r on rm.movie_id = r.movie_id inner join movie m on rm.movie_id = m.id inner join names n on rm.name_id = n.id where category = 'actor' and country = 'India' group by name_id having count(rm.movie_id) >= '5';

#23)
select name, sum(total_votes) as total_votes, count(rm.movie_id) as movie_count, sum(avg_rating  * total_votes)/ sum(total_votes) as actress_avg_rating, rank() over(order by sum(avg_rating  * total_votes)/ sum(total_votes) desc, total_votes desc) as actress_rank from role_mapping rm inner join names n on rm.name_id = n.id inner join movie m on rm.movie_id = m.id inner join ratings r on rm.movie_id = r.movie_id  where category = 'actress' and country = 'India' and languages like '%Hindi%' group by name_id  having count(m.id) >= '3' limit 5;

#24)
select title as movie_name, avg_rating,
	case 
		when avg_rating > '8' then 'Superhit movies'
        when avg_rating between '7' and '8' then 'Hit movies'
		when avg_rating between '5' and '7' then  'One-time-watch movies'
		else 'Flop movies'
	end as thriller_movie_classification
from movie m inner join genre g on m.id=g.movie_id inner join ratings r on g.movie_id = r.movie_id where genre = 'Thriller';

#25)
select genre, round(avg(duration),3) as avg_duration, round(sum(avg(duration)) over( order by genre rows unbounded preceding),3) as running_total_duration, round(avg(avg(duration)) over( order by genre rows unbounded preceding),3) as moving_avg_duration  from movie m inner join genre g on m.id = g.movie_id group by genre order by genre;

#26)
select * from (
with common_table_expression4 as 
(
	select genre from genre group by genre order by count(movie_id) desc limit 3
)
select genre, year, title, worlwide_gross_income, dense_rank() over(partition by  genre, year order by convert(replace(trim(worlwide_gross_income), "$ ",""), unsigned int) desc) as movie_rank from movie m inner join genre g on m.id = g.movie_id where genre in (select * from common_table_expression4)
) as main where main.movie_rank < 6;

#27)
select production_company, count(id) as movie_count, dense_rank() over(order by count(id) desc) as prod_comp_rank from movie m inner join ratings r on m.id = r.movie_id where median_rating >= 8 and production_company is not null and languages like '%,%' group by production_company limit 2;

#28) 
select name as actress_name, sum(total_votes) as total_votes, count(rm.movie_id) as movie_count, sum((avg_rating) * total_votes) / sum(total_votes) as actress_avg_rating, row_number() over ( order by sum((avg_rating) * total_votes) / sum(total_votes) desc) as actress_rank from role_mapping rm inner join names n on rm.name_id = n.id inner join ratings r on rm.movie_id = r.movie_id inner join genre g on rm.movie_id = g.movie_id where category = 'actress' and genre = 'Drama' and avg_rating > 8 group by actress_name limit 3;

#29)
#select name_id as Director_id, name as director_name, count(dm.movie_id) as Number_of_movies, avg(avg_rating) as Average_movie_ratings, sum(total_votes) as Total_votes, min(avg_rating) as Min_rating, max(avg_rating) as Max_rating, sum(duration) as total_duration from director_mapping dm inner join names n on dm.name_id = n.id inner join ratings r on dm.movie_id = r.movie_id inner join movie m on dm.movie_id = m.id group by Director_id Order by Number_of_movies desc limit 9;
with common_table_expressionn as
(
	select name_id as director_id, name as director_name, dm.movie_id as movie_id, avg_rating, date_published, lead(date_published,1) over(partition by name_id order by date_published) as next_movie_date, datediff(lead(date_published,1) over(partition by name_id order by date_published),date_published) as inter_movie_days, duration, total_votes from director_mapping dm inner join movie m on dm.movie_id = m.id inner join names n on dm.name_id = n.id inner join ratings r on dm.movie_id = r.movie_id order by director_id
)
select director_id, director_name, count(movie_id) as number_of_movies, round(avg(inter_movie_days)) as avg_inter_movie_days, sum(avg_rating * total_votes)/sum(total_votes) as avg_rating, sum(total_votes) as total_votes, min(avg_rating) as Min_rating, max(avg_rating) as Max_rating, sum(duration) as total_duration from common_table_expressionn cten group by Director_id Order by number_of_movies desc limit 9;
