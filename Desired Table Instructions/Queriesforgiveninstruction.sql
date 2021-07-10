-- For the queries in which we donot have data respective queries has been made and is discussed in remarks of report
--1.
SELECT product.primarytitle,titletype,dandw.directors
FROM
product,dandw
WHERE
dandw.tconst = product.tconst and (product.titletype = 'movie' or product.titletype = 'tvMovie') and array_length(dandw.directors,1) >=2


--2.

select person.primaryname
             from
                 (
					select c.actorid,c.directorid,c.directorname as directorname,count(c.directorname) as countdirectors,row_number() over (partition by c.actorname order by count(c.directorname) desc) as rowranking
                           from (
							   	 select a.nconst as actorid,a.primaryname as actorname,a.tconst,b.nconst as directorid,b.primaryname as directorname
                                 from (
									   select castandcrew.nconst, castandcrew.tconst, person.primaryname
                                       from product,castandcrew,person
                                       where castandcrew.nconst=person.nconst
                                       and product.tconst=castandcrew.tconst
                                       and castandcrew.category='actor'
                                       and product.titletype='movie'
								     ) as a,
                                     (
									   select castandcrew.nconst, castandcrew.tconst, person.primaryname
                                       from product,castandcrew,person
                                       where castandcrew.nconst=person.nconst
                                       and product.tconst=castandcrew.tconst
                                       and castandcrew.category='director'
                                       and product.titletype='movie'
									 ) as b
                                where a.tconst=b.tconst
						   	   ) as c
                      group by c.actorid,c.directorid,c.directorname,c.actorname ) as d,person
              where d.directorname='Zack Snyder' and d.actorid = person.nconst and rowranking=1
--3.
SELECT product.primarytitle,product.award from product
Where array_length(product.award,1) <2;

--4

SELECT a.primaryname as actorname,b.primaryname as directorname,count(a.tconst)
	FROM
	(
		SELECT * FROM
		(
			SELECT castandcrew.tconst,castandcrew.nconst,castandcrew.category,person.primaryname
			FROM
			castandcrew,product,person
			where
			person.nconst =castandcrew.nconst
			and
			castandcrew.tconst = product.tconst
			and
			product.titletype = 'movie'
			and
			castandcrew.category = 'actor'
		)  as T
	)AS a,
	(
		SELECT * FROM
		(
			SELECT castandcrew.tconst,castandcrew.nconst,castandcrew.category,person.primaryname
			FROM
			castandcrew,product,person
			where
			person.nconst =castandcrew.nconst
			and
			castandcrew.tconst = product.tconst
			and
			product.titletype = 'movie'
			and
			castandcrew.category = 'director'
		)  as T
	)AS b,
	ratings
	where
	a.tconst = b.tconst
	and ratings.tconst = b.tconst
	and
	ratings.averagerating > 7
	group by
	a.nconst,b.nconst,actorname,directorname
	having
	count(a.tconst) <=2

--5.
SELECT product.primarytitle,temp.maxruntime,temp.titletype
FROM
(SELECT titletype,max(runtime) as maxruntime
FROM
product
WHERE
titletype = 'tvSeries' group by titletype
) as temp,product
WHERE
product.runtime = temp.maxruntime and product.titletype = 'tvSeries'


--6.
SELECT person.primaryname
FROM product,castandcrew,person
WHERE product.tconst = castandcrew.tconst
and
castandcrew.nconst = person.nconst
and
castandcrew.category = 'director'
and
product.startyear = 2020
and
product.titletype = 'movie'
and
product.runtime =
(SELECT min(product.runtime)
FROM product,castandcrew,person
WHERE product.tconst = castandcrew.tconst
and
castandcrew.nconst = person.nconst
and
castandcrew.category = 'director'
and
product.startyear = 2020
and
product.titletype = 'movie'
and
product.runtime not in
(SELECT min(product.runtime)
FROM product,castandcrew,person
WHERE product.tconst = castandcrew.tconst
and
castandcrew.nconst = person.nconst
and
castandcrew.category = 'director'
and
product.startyear = 2020
and
product.titletype = 'movie'))

--7.
SELECT product.tconst,product.primarytitle,product.titletype,ratings.averagerating
FROM
(
	SELECT min(ratings.averagerating) AS ratings,product.titletype
	FROM
	product,ratings
	WHERE
	product.tconst = ratings.tconst
	and
	(product.titletype = 'tvSeries' or product.titletype = 'movie')
	and isadult = True
	group by
	product.titletype
) as minratings,product,ratings
WHERE
product.tconst = ratings.tconst
and isadult = True
and
ratings.averagerating = minratings.ratings
and
product.titletype = minratings.titletype

--8.
SELECT castandcrew.nconst,avg(ratings.averagerating)
FROM
castandcrew,ratings,person,product
WHERE
castandcrew.nconst = person.nconst
and
castandcrew.tconst = ratings.tconst
and
castandcrew.category = 'director'
and
product.tconst = ratings.tconst
and
product.titletype = 'movie'
and
ratings.averagerating IN
(
	SELECT distinct(avg(ratings.averagerating))
	FROM
	castandcrew,ratings,person,product
	WHERE
	castandcrew.nconst = person.nconst
	and
	castandcrew.tconst = ratings.tconst
	and
	castandcrew.category = 'director'
	and
	product.tconst = ratings.tconst
	and
	product.titletype = 'movie'
	group by
	castandcrew.nconst
	order by avg(ratings.averagerating) desc
	limit 5
)
group by
castandcrew.nconst
order by avg(ratings.averagerating) desc


--9.

SELECT product.primarytitle,product.titletype,regionmorethan3.regioncount,prodmorethan2.productioncount
from
(
	SELECT productioncompany.tconst,count(name) as productioncount
	from
		(SELECT languages.tconst,count(region) as regioncount
		from
		languages
		group by
		tconst
		having
		count(region) >=3) as regionmorethan3,productioncompany
	where
	regionmorethan3.tconst = productioncompany.tconst
	group by
	prductioncompany.tconst
	having
	count(name) >=2
) as prodmorethan2,product
where
product.tconst =prodmorethan2.tconst and product.titletype = 'tvSeries'

--10.
(select castandcrew.tconst ,person.tconst , person.primaryname
from
castandcrew,movie_info,person
where
castandcrew.nconst = castandcrew.nconst
and
movie_info.tconst = castandcrew.tconst
and
castandcrew.category= 'actor'
)as movieactor

SELECT movieactor.primaryname,min(awards.year)
from
movieactor,awards
WHERE
movieactor.nconst = awards.nconst
and
awards.award = 'OSCAR'
group by
movieactor.name , awards.year
--11.
SELECT dirrating.nconst,person.primaryname,
0.3*count(dirrating.tconst)+0.7*(0.8*avg(case when dirrating.job = '\N' then dirrating.averagerating else 0 end ) + 0.2*avg(case when dirrating.job like '%assistant director' then dirrating.averagerating else 0 end)) as score
FROM
(SELECT castandcrew.nconst,ratings.averagerating,castandcrew.job,product.tconst
from
castandcrew,ratings,product
where
castandcrew.tconst = product.tconst
and
castandcrew.tconst =  ratings.tconst
and
castandcrew.category = 'director'
and
(castandcrew.job = '\N'  or castandcrew.job like '%assistant director' )
and
product.titletype = 'movie') as dirrating,person
where
person.nconst = dirrating.nconst
group by
dirrating.nconst,person.primaryname
order by
score desc
limit 1

--12.

select d.ranking as ranking,d.genre ,product.primarytitle,person.primaryname
 (select c.tconst as titleid,c.ranking,c.genre
      from (select product.tconst,unnest(genre) as genre,(movieinfo.boxofficecollection - movieinfo.budget) as earnings
                          row_number() over (partition by unnest(product.genre) order by (movieinfo.boxofficecollection - movieinfo.budget) desc) as ranking
           from product,movieinfo
           where product.tconst=movieinfo.tconst
           ) as c
 where ranking<=5
 order by c.tconst,c.ranking ) as d,product,dandw,person
 where d.tconst=product.tconst,dandw.tconst=product.tconst,dandw.director[1]=person.nconst
 order by d.genre,d.rankings asc

--13.

SELECT person.primaryname
from person,castandcrew,product
where
person.nconst = castandcrew.nconst
and
product.tconst = castandcrew.tconst
and
product.titletype = 'movie'
and
castandcrew.category = 'actor'
and
castandcrew.nconst in
(
 SELECT castandcrew.nconst
	from castandcrew,product
	where
	product.tconst = castandcrew.tconst
	and
	castandcrew.category = 'actor'
	and
	product.titletype = 'tvSeries'
)

--14.

SELECT product.startyear,product.primarytitle
FROM
(
	SELECT product.startyear,min(product.runtime) as duration
	FROM product
	where
	product.titletype = 'tvEpisode'
	and
	product.runtime is not null
	group by
	product.startyear

) as mindurations,product
where
mindurations.duration = product.runtime
and
product.titletype = 'tvEpisode'
and
mindurations.startyear = product.startyear
order by
product.startyear asc
--15.
select rankbygenre.primarytitle,rankbygenre.genre,rankbygenre.rank
from
(
	select product.tconst,primarytitle,unnest(product.genres) as genre,row_number() over (partition by unnest(product.genres) order by ratings.averagerating desc) as rank
    from product,ratings
    where titletype='movie'
    and ratings.tconst=product.tconst
	order by product.tconst
) as rankbygenre
where rankbygenre.rank<=3
order by rankbygenre.genre,rankbygenre.rank asc
--16.
SELECT product.primarytitle
FROM
(
SELECT distinct(epioseinfo.parenttconst)
FROM
episodeinfo,locations
where
episodeinfo.tconst = location.tconst
and
location.locationname = 'Switzerland'
) as swisstvseries,
(
    SELECT movieinfo.tconst
FROM
movieinfo,locations
where
movieinfo.tconst = location.tconst
and
location.locationname = 'Switzerland'
) as swissmovie,
product
where
product.tconst = swisstvseries.parenttconst
or
product.tconst = swissmovie.tconst
--17.
(
select
product.tconst , product.primarytitle
from products
where
isadult = true
and
startyear=1995
) as adult movies

select l1.primaryname,l2.primaryname
from
(
select *
from location , adultmovies
where
location.tconst = adultmovies.tconst
)
as l1,
(
select *
from location , adultmovies
where
location,tconst = adultmovies.tconst
) as l2
where
l1.location_name = l2.location_name
and
l1.primaryname!= l2.primary_name;

--18.

SELECT castandcrew.category,max(person.birthyear)
from person,castandcrew
where
person.nconst = castandcrew.nconst
group by
castandcrew.category

--19.

SELECT person.nconst,person.primaryname
FROM
(
SELECT castandcrew.nconst,count(castandcrew.tconst) as moviescount
	from castandcrew
	where
	castandcrew.category = 'composer'
	group by
	castandcrew.nconst
	having
	count(castandcrew.tconst) >= 5
) as experiencedcomposers,person
where
person.nconst = experiencedcomposers.nconst

--20.

SELECT castandcrew.nconst , count(castandcrew.tconst)
from castandcrew
where
castandcrew.category = 'actor'
group by
castandcrew.nconst
having
count(castandcrew.tconst) =
(
	SELECT count(castandcrew.nconst)
	from castandcrew
	where
	castandcrew.category != 'actor'
	and
	castandcrew.category != 'actress'
	and
	castandcrew.tconst = 'tt10240428'    --put movie id here
	group by
	castandcrew.tconst
)
order by  count(castandcrew.tconst) desc
