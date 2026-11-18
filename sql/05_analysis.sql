-- 05 analysis
-- intrebarile pe care am vrut sa le aflu din date

use role sysadmin;
use warehouse laliga_wh;
use schema laliga.analytics;


-- 1) clasamentul pe fiecare sezon
create or replace view standings as
select
    season,
    team,
    count(*)                              as played,
    sum(iff(outcome = 'W', 1, 0))         as wins,
    sum(iff(outcome = 'D', 1, 0))         as draws,
    sum(iff(outcome = 'L', 1, 0))         as losses,
    sum(goals_for)                        as gf,
    sum(goals_against)                    as ga,
    sum(goals_for) - sum(goals_against)   as gd,
    sum(points)                           as pts,
    rank() over (partition by season order by sum(points) desc,
                 sum(goals_for) - sum(goals_against) desc) as position
from team_matches
group by season, team;

select * from standings where season = '2023/24' order by position;


-- 2) conteaza sa joci acasa? (2020/21 a fost fara spectatori din cauza covid)
create or replace view home_advantage as
select
    season,
    count(*)                                          as matches,
    round(100 * avg(iff(result = 'H', 1, 0)), 1)      as home_win_pct,
    round(100 * avg(iff(result = 'D', 1, 0)), 1)      as draw_pct,
    round(100 * avg(iff(result = 'A', 1, 0)), 1)      as away_win_pct
from matches
group by season;

select * from home_advantage order by season;


-- 3) barcelona pe fiecare sezon
create or replace view barca_seasons as
select
    season,
    position,
    pts,
    wins, draws, losses,
    gf, ga,
    pts - lag(pts) over (order by season) as pts_vs_last_season
from standings
where team = 'Barcelona';

select * from barca_seasons order by season;


-- 4) el clasico - toate meciurile barca vs real madrid
create or replace view el_clasico as
select
    season,
    match_date,
    venue                                    as barca_venue,
    goals_for || '-' || goals_against        as score_barca_first,
    outcome                                  as barca_result
from team_matches
where team = 'Barcelona'
  and opponent = 'Real Madrid';

select * from el_clasico order by match_date;

-- bilant total el clasico
select barca_result, count(*) as nr
from el_clasico
group by barca_result;


-- 5) cine transforma cel mai bine sansele (goluri la 100 suturi pe poarta)
create or replace view finishing as
select
    season,
    team,
    sum(goals_for)                                         as goals,
    sum(shots_ot)                                          as shots_on_target,
    round(100 * sum(goals_for) / nullif(sum(shots_ot), 0), 1) as goals_per_100_sot,
    rank() over (partition by season order by
                 sum(goals_for) / nullif(sum(shots_ot), 0) desc) as rnk
from team_matches
group by season, team;

select * from finishing where rnk <= 5 order by season, rnk;


-- 6) reveniri: echipa era condusa la pauza si a castigat
create or replace view comebacks as
select
    team,
    count(*) as comeback_wins
from team_matches
where ht_goals_for < ht_goals_against
  and outcome = 'W'
group by team;

select * from comebacks order by comeback_wins desc limit 10;


-- 7) forma barcelonei - puncte in ultimele 5 meciuri (sezonul 2023/24)
select
    match_date,
    opponent,
    venue,
    goals_for || '-' || goals_against as score,
    points,
    sum(points) over (order by match_date
                      rows between 4 preceding and current row) as pts_last_5
from team_matches
where team = 'Barcelona'
  and season = '2023/24'
order by match_date;
