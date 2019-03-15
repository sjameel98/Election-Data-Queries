SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;


CREATE TABLE q5(
        countryName VARCHAR(50),
	year INT,
	participationRatio real
);


-- drop view stuff
DROP VIEW IF EXISTS partratios CASCADE;
DROP VIEW IF EXISTS temp CASCADE;
DROP VIEW IF EXISTS result5 CASCADE;




create view partratios as
	select avg(election.votes_cast/cast(election.electorate as float)) as ratio, date_part('year', election.e_date) as year, country.name as countryName, country.id as cid
	from election, country
	where date_part('year', election.e_date)<=2016 and date_part('year', election.e_date)>=2001 and election.country_id = country.id and election.electorate IS NOT NULL and election.votes_cast IS NOT NULL
	group by country.id, date_part('year', election.e_date);




create view temp as 
	(select distinct countryName
	from partratios)
	except ( 
	select distinct p1.countryName
	from partratios p1, partratios p2
	where p1.year < p2.year and p1.ratio > p2.ratio and p1.countryName = p2.countryName

	);


create view result5 as 
	select countryName, year, ratio as participationRatio
	from partratios
	where countryName in (select * from temp);




INSERT into q5(select * from result5);
			







