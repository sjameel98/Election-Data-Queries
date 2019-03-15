SET SEARCH_PATH TO parlgov;

SELECT * FROM q3
ORDER BY countryname, wonelections, partyname desc;
