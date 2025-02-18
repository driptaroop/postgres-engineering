create temporary table zipcodes_temp (
                         country_code char(2),
                         postal_code text,
                         place_name text,
                         admin_name1 text,
                         admin_code1 text,
                         admin_name2 text,
                         admin_code2 text,
                         admin_name3 text,
                         admin_code3 text,
                         latitude float,
                         longitude float,
                         accuracy int
);

\copy zipcodes_temp (country_code,postal_code,place_name,admin_name1,admin_code1,admin_name2,admin_code2,admin_name3,admin_code3,latitude,longitude,accuracy) from '/Users/driptaroop.das/Downloads/allCountries_zipcode.txt' null as '';

create table zipcodes as
select
    row_number() over() as id,
    place_name as city_name,
    postal_code as postal_code,
    country_code as country_code,
    latitude as latitude,
    longitude as longitude
from zipcodes_temp cross join generate_series(1, 50)
order by random();

analyze zipcodes;

create index idx_zipcodes_country_code_city_name on zipcodes (country_code, city_name);

explain analyze Select * from zipcodes where country_code='DE' and city_name='Berlin';

alter table zipcodes alter column country_code set statistics 10000;

select count(1) from zipcodes;

select * from pg_stats where tablename = 'zipcodes';


create statistics zipcodes_country_code_stats(dependencies) ON country_code, city_name FROM zipcodes;

SELECT stxname, stxkeys, stxddependencies
FROM pg_statistic_ext join pg_statistic_ext_data on (oid = stxoid)
WHERE stxname = 'zipcodes_country_code_stats';

select * from pg_stats_ext;

drop statistics zipcodes_country_code_stats;

--- ndistinct
explain analyze Select count(*) from zipcodes group by country_code;
explain analyze select count(*) from zipcodes group by country_code,city_name;

create statistics zipcodes_country_code_city_name_stats_nDistinct(ndistinct) ON country_code, city_name FROM zipcodes;
drop statistics zipcodes_country_code_city_name_stats_nDistinct;

-- mcv
explain (analyze, timing off) Select * from zipcodes where country_code='DE' and city_name='Berlin';

create statistics zipcodes_country_code_city_name_stats_mcv(mcv) ON country_code, city_name FROM zipcodes;
drop statistics zipcodes_country_code_city_name_stats_mcv;
analyze zipcodes;

alter statistics zipcodes_country_code_city_name_stats_mcv set STATISTICS 100000;

select * from pg_stats_ext where tablename = 'zipcodes' and statistics_name = 'zipcodes_country_code_city_name_stats_mcv';
SELECT m.* FROM pg_statistic_ext join pg_statistic_ext_data on (oid = stxoid),
                pg_mcv_list_items(stxdmcv) m WHERE stxname = 'zipcodes_country_code_city_name_stats_mcv' limit 2;