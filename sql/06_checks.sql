-- 06 checks
-- cateva verificari ca sa fiu sigur ca datele au sens

use role sysadmin;
use warehouse laliga_wh;
use schema laliga.analytics;

-- fiecare echipa trebuie sa aiba 38 de meciuri pe sezon
select season, team, count(*) as meciuri
from team_matches
group by season, team
having count(*) <> 38;
-- daca nu iese nimic e ok

-- golurile marcate = golurile primite (pe tot campionatul)
select season, sum(goals_for) as marcate, sum(goals_against) as primite
from team_matches
group by season
order by season;

-- meciuri duplicate? (aceeasi data, aceleasi echipe)
select match_date, home_team, away_team, count(*)
from matches
group by 1, 2, 3
having count(*) > 1;
