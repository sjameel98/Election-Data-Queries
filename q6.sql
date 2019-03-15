SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;




CREATE TABLE q6(
        countryName VARCHAR(50),
	r0_2 INT,
	r2_4 INT,
	r4_6 INT,
	r6_8 INT,
	r8_10 INT
);


-- drop view stuff
DROP VIEW IF EXISTS subset1 CASCADE;
DROP VIEW IF EXISTS subset2 CASCADE;
DROP VIEW IF EXISTS subset3 CASCADE;
DROP VIEW IF EXISTS subset4 CASCADE;
DROP VIEW IF EXISTS subset5 CASCADE;
DROP VIEW IF EXISTS results6 CASCADE;



create view subset1 as 
	select country.name, count(distinct party.id) as zero_two
	from country, party, party_position
	where country.id = party.country_id and party.id = party_position.party_id and party_position.left_right IS NOT NULL
	and party_position.left_right<2 and party_position.left_right>=0
	group by country.name;

create view subset2 as 
	select country.name, count(distinct party.id) as two_four
	from country, party, party_position
	where country.id = party.country_id and party.id = party_position.party_id and party_position.left_right IS NOT NULL
	and party_position.left_right<4 and party_position.left_right>=2
	group by country.name;


create view subset3 as 
	select country.name, count(distinct party.id) as four_six
	from country, party, party_position
	where country.id = party.country_id and party.id = party_position.party_id and party_position.left_right IS NOT NULL
	and party_position.left_right<6 and party_position.left_right>=4
	group by country.name;


create view subset4 as 
	select country.name, count(distinct party.id) as six_eight
	from country, party, party_position
	where country.id = party.country_id and party.id = party_position.party_id and party_position.left_right IS NOT NULL
	and party_position.left_right<8 and party_position.left_right>=6
	group by country.name;


create view subset5 as 
	select country.name, count(distinct party.id) as eight_ten
	from country, party, party_position
	where country.id = party.country_id and party.id = party_position.party_id and party_position.left_right IS NOT NULL
	and party_position.left_right<10 and party_position.left_right>=8
	group by country.name;


create view results6 as
	select subset1.name as countryName, subset1.zero_two as r0_2, subset2.two_four as r2_4, subset3.four_six as r3_6, subset4.six_eight as r6_8, subset5.eight_ten as r8_10
	from subset1, subset2, subset3, subset4, subset5
	where subset1.name = subset2.name and subset2.name = subset3.name and subset3.name = subset4.name and subset4.name = subset5.name;



















INSERT into q6(select * from results6);











