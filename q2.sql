SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;



CREATE TABLE q2(
        countryName VARCHAR(50),
        partyName VARCHAR(50),
	partyFamily VARCHAR(50),
	stateMarket FLOAT
);



DROP VIEW IF EXISTS thiccboi CASCADE;
DROP VIEW IF EXISTS yeet1 CASCADE;
DROP VIEW IF EXISTS yeet2 CASCADE;
DROP VIEW IF EXISTS yeet3 CASCADE;
DROP VIEW IF EXISTS failures CASCADE;
DROP VIEW IF EXISTS success CASCADE;
DROP VIEW IF EXISTS results2 CASCADE;


create view thiccboi as
	select cabinet_id, party_id, party.country_id
	from cabinet, cabinet_party, party
	where cabinet.id = cabinet_party.cabinet_id and date_part('year', cabinet.start_date) >= 1999 and party.country_id = cabinet.country_id;


create view yeet1 as
	select cabinet_id, country_id
	from thiccboi;

create view yeet2 as
	select party_id, country_id
	from thiccboi;

create view yeet3 as
	select yeet1.cabinet_id, yeet2.party_id, yeet1.country_id
	from yeet1, yeet2
	where yeet1.country_id = yeet2.country_id;

create view failures as 
	(select * from yeet3) except (select * from thiccboi);

create view success as
	(select party_id, country_id from thiccboi) except (select party_id, country_id from failures);


create view results2 as
	select country.name as countryName, party.name as partyName, party_family.family as partyFamily, party_position.state_market as stateMarket
	from success, party, country, party_family, party_position
	where success.party_id = party.id and success.country_id = country.id and party_family.party_id = success.party_id and success.party_id = party_position.party_id;


INSERT into q2(select * from results2);





