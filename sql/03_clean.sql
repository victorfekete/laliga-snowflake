-- 03 clean
-- data reala in loc de text, sezon frumos (2020/21), scot randurile goale

use role sysadmin;
use warehouse laliga_wh;
use schema laliga.analytics;

-- mai intai ma uit ce nume de echipe am (sa vad daca ceva e scris diferit)
select distinct home_team from laliga.raw.matches_raw order by 1;

create or replace table matches as
select
    replace(season, '_', '/')             as season,
    to_date(match_date, 'DD/MM/YYYY')     as match_date,
    trim(home_team)                       as home_team,
    trim(away_team)                       as away_team,
    home_goals,
    away_goals,
    result,
    ht_home_goals,
    ht_away_goals,
    home_shots,
    away_shots,
    home_shots_ot,
    away_shots_ot,
    home_yellow,
    away_yellow,
    home_red,
    away_red
from laliga.raw.matches_raw
where home_team is not null
  and home_goals is not null;

select * from matches order by match_date limit 20;
