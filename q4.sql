SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;


CREATE TABLE q4(
	year INT,
        countryName VARCHAR(50),
	voteRange VARCHAR(50),
	partyName VARCHAR(100)
);


-- drop view stuff

DROP VIEW IF EXISTS validvotes CASCADE;
DROP VIEW IF EXISTS groupedvotes CASCADE;
DROP VIEW IF EXISTS idsandranges CASCADE;
DROP VIEW IF EXISTS result4 CASCADE;







create view validvotes as
	select election.id as electionID, election.country_id as countryID, election_result.party_id, (cast(election_result.votes as decimal)/election.votes_valid)*100 as percentage , date_part('year', election.e_date) as year
	from election, election_result
	where election.id = election_result.election_id and date_part('year', election.e_date)<=2016 and date_part('year', election.e_date)>=1996 and election_result.votes is not NULL and election.votes_valid is not NULL;
	

create view groupedvotes as
	select countryID, party_id, year, avg(percentage) as avgpct
	from validvotes
	GROUP BY countryID, party_id, year;

create view idsandranges as
(
	select countryID, party_id, year, '(0-5]' as VoteRange
	from groupedvotes
	where avgpct>0 and avgpct<=5
)
UNION ALL
(
	select countryID, party_id, year, '(5-10]' as VoteRange
	from groupedvotes
	where avgpct>5 and avgpct<=10
)
UNION ALL
(
	select countryID, party_id, year, '(10-20]' as VoteRange
	from groupedvotes
	where avgpct>10 and avgpct<=20
)
UNION ALL
(
	select countryID, party_id, year, '(20-30]' as VoteRange
	from groupedvotes
	where avgpct>20 and avgpct<=30
)
UNION ALL
(
	select countryID, party_id, year, '(30-40]' as VoteRange
	from groupedvotes
	where avgpct>30 and avgpct<=40
)
UNION ALL
(
	select countryID, party_id, year, '(40-100]' as VoteRange
	from groupedvotes
	where avgpct>40
);

create view results4 as
	select year, country.name as countryName, idsandranges.VoteRange as voteRange, party.name_short as partyName
	from idsandranges, country, party
	where idsandranges.party_id = party.id and idsandranges.countryID = country.id;



INSERT into q4(select * from results4);







