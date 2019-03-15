SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;


CREATE TABLE q3(
	countryName VARCHAR(50),
        partyName VARCHAR(50),
	partyFamily VARCHAR(50),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT
);



DROP VIEW IF EXISTS winners CASCADE;
DROP VIEW IF EXISTS wincounts CASCADE;
DROP VIEW IF EXISTS neverwon CASCADE;
DROP VIEW IF EXISTS allpartycounts CASCADE;
DROP VIEW IF EXISTS countryavg CASCADE;
DROP VIEW IF EXISTS resultparties CASCADE;
DROP VIEW IF EXISTS partyview CASCADE;
DROP VIEW IF EXISTS relevantparties CASCADE;
DROP VIEW IF EXISTS result3 CASCADE;



create view winners as
	select a1.election_id, a1.party_id, e1.country_id as countryID, e1.e_date as e_date
	from election_result a1, election e1
	where votes = (
				select max(votes)
				from election_result a2, election e2
				where a1.election_id = a2.election_id and e1.country_id = e2.country_id
			)
			and a1.election_id = e1.id;


create view wincounts as
	select party_id, countryId, count(*) as count_elections
	from winners
	group by party_id, countryId;



create view neverwon as 
	select id as party_id, country_id as countryId, 0 as count_elections	
	from party
	where (id, country_id) not in (
						select party_id, countryID
						from wincounts
					);


create view allpartycounts as
	(select * from wincounts) UNION (select * from neverwon);



create view countryavg as
	select countryID, avg(count_elections) as average
	from allpartycounts
	group by countryID;


create view resultparties as 
	select allpartycounts.party_id, allpartycounts.countryID, allpartycounts.count_elections as wonElections
	from allpartycounts, countryavg
	where allpartycounts.countryID = countryavg.countryID and allpartycounts.count_elections > 3*countryavg.average;


-- Now just need to get all the attributes

create view partyview as
	select country.name as countryName, party.name as partyName, party_family.family as partyFamily, party.id as pid, country.id as cid
	from country, party left join party_family on party_family.party_id = party.id
	where country.id = party.country_id; -- and party_family.party_id = party.id;



create view relevantparties as
	select partyview.countryName, partyview.partyName, partyview.partyFamily, resultparties.wonElections, partyview.pid, partyview.cid
	from partyview, resultparties
	where partyview.pid = resultparties.party_id and partyview.cid = resultparties.countryID;


create view result3 as 
	select relevantparties.countryName, relevantparties.partyName, relevantparties.partyFamily, relevantparties.wonElections as wonElections, winners.election_id as mostRecentlyWonElectionId, date_part('year', winners.e_date) as mostRecentlyWonElectionYear
	from relevantparties, winners
	where relevantparties.pid = winners.party_id and relevantparties.cid = winners.countryID and winners.e_date = (
																select max(e_date)
																from winners w2
																where winners.party_id = w2.party_id and winners.countryID = w2.countryID
															);



INSERT into q3(select * from result3);













