SET SEARCH_PATH TO parlgov;

SELECT * FROM q1
ORDER BY countryId desc, alliedPartyId1 desc, alliedPartyId2 desc;
