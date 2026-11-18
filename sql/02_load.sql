-- 02 load
-- incarc csv-urile de pe football-data.co.uk (cate unul pe sezon)
-- fisierele le-am redenumit: laliga_2020_21.csv, laliga_2021_22.csv ...
-- sezonul nu e in fisier, asa ca il iau din numele fisierului

use role sysadmin;
use warehouse laliga_wh;
use schema laliga.raw;

create or replace file format csv_ff
  type = csv
  skip_header = 1
  field_optionally_enclosed_by = '"'
  empty_field_as_null = true;

create or replace stage laliga_stage
  file_format = csv_ff;

-- AICI: urc fisierele in laliga_stage din Snowsight (+ Files)

list @laliga_stage;

-- iau doar coloanele de care am nevoie
-- ordinea din csv (verificata in excel):
-- $2 Date, $4 HomeTeam, $5 AwayTeam, $6 FTHG, $7 FTAG, $8 FTR, $9 HTHG, $10 HTAG,
-- $12 HS, $13 AS, $14 HST, $15 AST, $20 HY, $21 AY, $22 HR, $23 AR
create or replace table matches_raw (
    season          string,
    match_date      string,   -- vine ca text dd/mm/yyyy, il convertesc mai tarziu
    home_team       string,
    away_team       string,
    home_goals      int,
    away_goals      int,
    result          string,   -- H / D / A
    ht_home_goals   int,
    ht_away_goals   int,
    home_shots      int,
    away_shots      int,
    home_shots_ot   int,      -- ot = on target
    away_shots_ot   int,
    home_yellow     int,
    away_yellow     int,
    home_red        int,
    away_red        int,
    file_name       string,
    loaded_at       timestamp
);

copy into matches_raw
from (
    select
        replace(replace(metadata$filename, 'laliga_', ''), '.csv', ''),
        $2, $4, $5, $6, $7, $8, $9, $10,
        $12, $13, $14, $15, $20, $21, $22, $23,
        metadata$filename,
        current_timestamp()
    from @laliga_stage
)
pattern = '.*laliga_.*[.]csv';

-- cate meciuri am pe sezon? (ar trebui 380, 20 echipe x 19 etape x 2 tururi)
select season, count(*) as nr_meciuri
from matches_raw
group by season
order by season;
