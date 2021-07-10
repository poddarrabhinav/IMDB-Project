

CREATE DATABASE dbmsproj;

CREATE TABLE public.person (
    nconst character varying(50) NOT NULL PRIMARY KEY,
    primaryname text NOT NULL,
    birthyear bigint,
    deathyear bigint,
    primaryprofession character varying(50)[],
    knownfortitles character varying(50)[]
);

COPY person
FROM '...person_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.product (
    tconst text NOT NULL PRIMARY KEY,
    titletype text,
    primarytitle text,
    originaltitle text,
    isadult boolean,
    startyear bigint,
    endyear bigint,
    runtime bigint,
    genres character varying(50)[]
);

COPY product
FROM '...product_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.ratings (
    tconst text NOT NULL PRIMARY KEY,
    averagerating numeric,
    numvotes integer
);

COPY ratings
FROM '...ratings_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.languages (
    tconst text NOT NULL,
    ordering integer NOT NULL,
    title text NOT NULL,
    region text,
    language text,
    types text,
    attributes text,
    isoriginaltitle boolean
);

COPY languages
FROM '...languages_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.dandw (
    tconst text NOT NULL,
    directors character varying(100)[],
    writers character varying(100)[]
);

COPY dandw
FROM '...dandw_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.castandcrew (
    tconst text NOT NULL,
    ordering integer NOT NULL,
    nconst text NOT NULL,
    category text,
    job text,
    characters text
);

COPY castandcrew
FROM '...castnadcrew_data.tsv' 
DELIMITER E'\t'
CSV HEADER;

CREATE TABLE public.episode(
    tconst text,
    parenttconst text,
    seasonnumber bigint,
    episodenumber bigint
);

COPY episode
FROM '...episode_data.tsv' 
DELIMITER E'\t'
CSV HEADER;


SELECT tconst,primarytitle 
INTO movieinfo FROM product
WHERE titletype='tvMovie' OR titletype='movie'; 


ALTER TABLE ONLY public.movieinfo
    ADD CONSTRAINT movieinfo_pkey PRIMARY KEY (tconst);


SELECT originaltitle,tconst INTO episodeinfo FROM product WHERE titletype='tvEpisode'
NATURAL JOIN episodes;


ALTER TABLE ONLY public.episodeinfo
    ADD CONSTRAINT episodeinfo_pkey PRIMARY KEY (tconst);


ALTER TABLE person
    ADD COLUMN age TYPE bigint;


UPDATE person 
SET age= person.deathyear-person.birthyear 
WHERE person.deathyear IS NOT NULL;


UPDATE person 
SET age= 2021-person.birthyear 
WHERE person.deathyear IS NULL;  


SELECT parenttconst,DISTINCT seasonnumber,COUNT(episodenumber) as totalepisodes
INTO tvseriesinfo
FROM episodes
GROUP BY parenttconst,seasonnumber;


ALTER TABLE ONLY public.tvseriesinfo
    ADD CONSTRAINT tvseriesinfo_pkey PRIMARY KEY (parenttconst);


SELECT region,language INTO regioninfo
FROM languages GROUP BY region,language ;


ALTER TABLE regioninfo
ADD COLUMN rconst TYPE SERIAL;


ALTER TABLE regioninfo
ADD PRIMARY KEY rconst;                                                              


SELECT * INTO languageinfo FROM regioninfo                                            
NATURAL JOIN  languages;


ALTER TABLE languageinfo
DROP COLUMN languages;


ALTER TABLE languageinfo
DROP COLUMN region;



DROP TABLE languages;



DROP TABLE episodes;



---------------------------------------------------------------------------



