-- 04 team_matches
-- fiecare meci devine 2 randuri: unul pt gazde, unul pt oaspeti
-- asa pot face clasament / statistici pe echipa mult mai usor

use role sysadmin;
use warehouse laliga_wh;
use schema laliga.analytics;

create or replace table team_matches as

-- echipa de acasa
select
    season,
    match_date,
    home_team       as team,
    away_team       as opponent,
    'home'          as venue,
    home_goals      as goals_for,
    away_goals      as goals_against,
    ht_home_goals   as ht_goals_for,
    ht_away_goals   as ht_goals_against,
    home_shots      as shots,
    home_shots_ot   as shots_ot,
    home_yellow     as yellow,
    home_red        as red,
    case when result = 'H' then 'W' when result = 'D' then 'D' else 'L' end as outcome,
    case when result = 'H' then 3   when result = 'D' then 1   else 0   end as points
from matches

union all

-- echipa din deplasare
select
    season,
    match_date,
    away_team,
    home_team,
    'away',
    away_goals,
    home_goals,
    ht_away_goals,
    ht_home_goals,
    away_shots,
    away_shots_ot,
    away_yellow,
    away_red,
    case when result = 'A' then 'W' when result = 'D' then 'D' else 'L' end,
    case when result = 'A' then 3   when result = 'D' then 1   else 0   end
from matches;

-- verificare: trebuie sa fie fix dublu fata de matches
select
    (select count(*) from matches)      as meciuri,
    (select count(*) from team_matches) as randuri_echipe;
