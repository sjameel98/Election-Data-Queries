SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;



CREATE TABLE q1(
	countryId INT,
        alliedPartyId1 INT,
        alliedPartyId2 INT
);













DROP VIEW IF EXISTS monsterelection CASCADE;
DROP VIEW IF EXISTS partyalliances CASCADE;
DROP VIEW IF EXISTS dabigboi CASCADE;
DROP VIEW IF EXISTS countryelections CASCADE;
DROP VIEW IF EXISTS results CASCADE;




create view monsterelection as
	select election_result.party_id as party_id, election.country_id as country_id, election_result.election_id as election_id, election_result.alliance_id as alliance_id, election_result.id as eid 
	from country, election, election_result
	where country.id = election.country_id and election_result.election_id = election.id;



create view partyalliances as
(
(	select party_id, country_id, election_id, alliance_id as aid
	from monsterelection 
	where monsterelection.alliance_id IS NOT NULL
)
UNION 
(
	select party_id, country_id, election_id, eid as aid
	from monsterelection
	where monsterelection.alliance_id IS NULL
)
);




create view dabigboi as
	select pa1.party_id as alliedPartyId1, pa2.party_id as alliedPartyId2, pa2.country_id as countryId, count(*) as allycounts
	from partyalliances pa1, partyalliances pa2
	where pa1.aid = pa2.aid and pa1.election_id = pa2.election_id and pa1.country_id = pa2.country_id and pa1.party_id < pa2.party_id
	group by pa1.party_id, pa2.party_id, pa2.country_id;





create view countryelections as
	select country_id, count(*) as electioncount
	from election
	group by country_id;




create view results as
	select countryId, alliedPartyId1, alliedPartyId2
	from dabigboi, countryelections
 	where dabigboi.countryId = countryelections.country_id and dabigboi.allycounts >= 0.3*countryelections.electioncount;
	











INSERT into q1(select * from results);













