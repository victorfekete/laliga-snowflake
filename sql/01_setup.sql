-- 01 setup
-- baza de date pentru proiect + 2 scheme:
-- raw = datele cum vin din csv, analytics = ce fac eu cu ele

use role sysadmin;

create warehouse if not exists laliga_wh
  warehouse_size = 'XSMALL'
  auto_suspend = 60
  auto_resume = true;

use warehouse laliga_wh;

create database if not exists laliga;
create schema if not exists laliga.raw;
create schema if not exists laliga.analytics;
