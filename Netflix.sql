-------Netflix Project----
create table netflix(show_id varchar(10),
type varchar(10),title varchar(130),
director varchar(230), casts varchar(800), 
country varchar(130),
date_added varchar(25),release_year int,
rating varchar(10),duration varchar(15),
listed_in varchar(90),description varchar(300));

copy netflix from 'C:\Program Files\PostgreSQL\16\netflix_titles.csv'
delimiter ',' csv header;


select * from netflix;
-- 15 Business Problems & Solutions

/*1. Count the number of Movies vs TV Shows*/
select type, count(show_id)
from netflix group by type;  

/*2. Find the most common rating for movies and TV shows*/
select type,rating from
(select type, rating, count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix group by type, rating
order by type, count(*) desc)as t1 where ranking = 1;

/*3. List all movies released in a specific year (e.g., 2020)*/
select * from netflix;
select * from netflix where type  = 'Movie'
and release_year = 2020;
/*4. Find the top 5 countries with the most content on Netflix*/
select unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content from netflix group by 
unnest(string_to_array(country, ','))
order by count(show_id) desc
limit 5;

/*5. Identify the longest movie*/
select * from netflix where
type = 'Movie'
and
duration  = (select max(duration ) from netflix);


/*6. Find content added in the last 5 years */
select * from netflix where
to_date(date_added, 'month, dd,yyyy' )>= current_date - interval
'5 years';



/*7. Find all the movies/TV shows by director 'Rajiv Chilaka'!*/
select * from netflix;
select type from netflix where director ilike '%Rajiv Chilaka%';

/*8. List all TV shows with more than 5 seasons*/
---note: select split_part('apple,banana,orange',',',1);------
Select *  
from  netflix where type ='TV Show'
and
split_part(duration, ' ', 1)::numeric > 5 ;


/*9. Count the number of content items in each genre*/
select unnest(string_to_array(listed_in, ',')),
count(show_id)
from netflix
group by unnest(string_to_array(listed_in, ','))
order by count(show_id) desc ;


/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/
select 
extract(year from to_date(date_added, 'month, dd,yyyy')) as year,
round(count(*):: numeric/ (select count(*) from netflix where country = 'India')::numeric*100,2)
as avg_content_per_year
from netflix
where country = 'India'
group by 1 order by  2 desc;


/*11. List all movies that are documentaries*/
select type, listed_in from netflix where  
listed_in ilike '%documentaries%';


/*12. Find all content without a director*/
select * from netflix where director is null;

/*13. Find how many movies actor 'Salman Khan' appeared in last 10 years!*/
select * from netflix where casts ilike '%Salman Khan%'
and   release_year > extract(year from current_date) -10;



/*14. Find the top 10 actors who have appeared in the highest number of movies produced in India.*/
select 
unnest(string_to_array(casts, ',')),
count(show_id) from
netflix
where country ilike '%india%' group by unnest(string_to_array(casts, ','))
order by count(show_id) desc limit 10;


/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
create table tab as
(select *, 
 case
   when
   description ilike '%kill%'
   or
   description ilike '%violence%' then 'bad_content'
   else 
   'good_content'
 end  category
from netflix)


select category, count(*) as total_content
from tab group by category;


















