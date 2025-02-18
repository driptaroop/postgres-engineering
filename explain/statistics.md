# Postgres Statistics and where to find them
## How to sample and guess like a pro

# Introduction

Postgres is a powerful database that can store and manage large amounts of data. It is also a complex system with many moving parts. 
One of the most important parts of Postgres is the statistics that it collects about the data in the database. These statistics are used by the query planner to make 
decisions about how to execute queries. In this article, we will explore the statistics that Postgres collects and how to access them.

We already discussed how statistics work in [the last post](https://blog.dripto.xyz/how-does-postgresql-query-planner-work). In this post, we will dive a little deeper to find out how it works in a bit more detailed way and how can we influence it.

# What are postgres statistics?
Postgres collects statistics about the data in the database to help the query planner make decisions about how to execute queries. 
These statistics include information about the distribution of values in columns, the number of distinct values in columns, and the 
correlation between columns. The query planner uses this information to estimate the number of rows that will be returned by a query 
and to choose the most efficient way to execute the query.
The statistics are stored in the tables called `pg_statistic`. Let's look at it with an example.

Let's create a table and insert some data into it. For this we will be using Geonames Zipcodes dataset. You can download it from [here](https://download.geonames.org/export/zip/).
Lets insert the dataset into a table called `zipcodes`. To make more data we will duplicate the data 50 times.
```sql
-- create temp table to load data
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

-- load data into temp table. run this in a psql shell.
\copy zipcodes_temp (country_code,postal_code,place_name,admin_name1,admin_code1,admin_name2,admin_code2,admin_name3,admin_code3,latitude,longitude,accuracy) from '<location>/allCountries_zipcode.txt' null as '';

-- create table to store data
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

-- analyze to create statistics
analyze zipcodes;
```

Now lets look at the statistics that Postgres has collected for the `zipcodes` table. But inspite of looking at the `pg_statistic` table directly, we will use the `pg_stats` view which is a more user friendly way to look at the statistics.

```sql
select * from pg_stats where tablename = 'zipcodes';
```

The output is quite big so feel free to skip to the definition of the most important columns in the next section.

| schemaname | tablename | attname | inherited | null\_frac | avg\_width | n\_distinct | most\_common\_vals | most\_common\_freqs | histogram\_bounds | correlation | most\_common\_elems | most\_common\_elem\_freqs | elem\_count\_histogram | range\_length\_histogram | range\_empty\_frac | range\_bounds\_histogram |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| public | zipcodes | id | false | 0 | 8 | -1 | null | null | {1476,831329,1803557,2755828,3441608,4302401,5197186,6170319,7027551,7888694,8706426,9619035,10526785,11443436,12328474,13202501,14052786,14924174,15803816,16752774,17630468,18491624,19265817,20126436,20904900,21836177,22778719,23638598,24495904,25383828,26236419,27174436,28077547,29033031,29915954,30783821,31694329,32564563,33423641,34337410,35274443,36128997,37025193,37810560,38683275,39494131,40354928,41191231,42087593,42927686,43790830,44635086,45468809,46263816,47141001,48092507,49015054,49859388,50739541,51619114,52387634,53251729,54071939,54958797,55826805,56614454,57545466,58462915,59417875,60342502,61222499,62081819,62983300,63803681,64698605,65563581,66367822,67189905,68070942,68854371,69685548,70512728,71330638,72145232,72972515,73849996,74766284,75636459,76571046,77507904,78319002,79165107,79951273,80853420,81798973,82766026,83593859,84513481,85505203,86342242,87196437} | -0.0052280542 | null | null | null | null | null | null |
| public | zipcodes | city\_name | false | 0 | 13 | 63965 | {Lisboa,Mirdif,"Al Thanyah  Fourth","Wadi Al Safa 6",Porto,"Hadaeq Sheikh Mohammed Bin Rashid","Al Hebiah Third","Al Thanyah Fifth",Warszawa,"Al Yalayis 1","Wadi Al Safa 3","Al Barsha South Fourth","Al Yalayis 2","Wadi Al Safa 7","Al Barsha South First","Jabal Ali First","Al Barsha Third","Al Mizhar First","Al Khwaneej First","Al Rashidiya","Jumeira First","Nadd Hessa",Maia,"Al Bada'",Hatta,"Madinat Al Mataar","Umm Suqeim Second","Al Awir First",Amadora,"Wadi Al Safa 5","Al Barsha South Fifth","Vila Nova de Gaia","Al Hebiah Fourth","Hor Al Anz","Nadd Al Shiba Third","Oud Al Muteena First","Warsan First","Al Qouz First","Abu Hail","Al Warqa'A Third","Al Barsha Second","Al Thanyah Third","Dubai Investment Park First",Setúbal,"Umm Suqeim First","Al Garhoud",Funchal,"Al Warqa'A Fourth","Nadd Al Hamar","Nadd Al Shiba First","Al Barsha First","Jumeira Third","Mena Jabal Ali","Jumeira Second","Umm Suqeim Third",Wrocław,Coimbra,Leiria,"Al Barsha South Second","Al Khwaneej Second",Luxembourg,"Nakhlat Jumeira",서구,"Al Qouze Ind.Fourth","Al Warqa'A Second",Vilnius,Évora,"Me'Aisem First","Nadd Al Shiba Fourth",Almada,"Al Safa First","Al Satwa","Al Twar Third",Łódź,Viseu,Braga,Kraków,"Muhaisnah First","Viana do Castelo",동구,"Al Lesaily","Al Manara","Al Merkadh","Al Qouz Second","Al Safa Second","Al Mizhar Second","Al Wuheida",중구,"Al Jafiliya","Al Muraqqabat",Guimarães,"Jabal Ali Industrial Second","Ras Al Khor Ind. Second",Stockholm,"Al Muteena","Al Qouze Ind.Second","Al Souq Al Kabeer","Al Wasl",Aveiro,Cluj-Napoca} | {0.005233333446085453,0.005133333150297403,0.004666666500270367,0.002733333269134164,0.0026666666381061077,0.002199999988079071,0.002133333357051015,0.0020000000949949026,0.0019666666630655527,0.0018666667165234685,0.0018333332845941186,0.0017999999690800905,0.0017333333380520344,0.0017333333380520344,0.0016333333915099502,0.0015666666440665722,0.001466666697524488,0.001466666697524488,0.00143333338201046,0.00139999995008111,0.00139999995008111,0.001366666634567082,0.0013333333190530539,0.0012666666880249977,0.0012333333725109696,0.0012333333725109696,0.0012333333725109696,0.0012000000569969416,0.0012000000569969416,0.0012000000569969416,0.0011666666250675917,0.0011666666250675917,0.0011333333095535636,0.0011333333095535636,0.0011333333095535636,0.0011333333095535636,0.0011333333095535636,0.0010999999940395355,0.0010666666785255075,0.0010666666785255075,0.0010333333630114794,0.0010333333630114794,0.0010000000474974513,0.0010000000474974513,0.0010000000474974513,0.0009666666737757623,0.0009666666737757623,0.0009333333582617342,0.0009333333582617342,0.0009333333582617342,0.0008999999845400453,0.0008999999845400453,0.0008999999845400453,0.0008666666690260172,0.0008666666690260172,0.0008333333535119891,0.0007999999797903001,0.0007999999797903001,0.0007666666642762721,0.0007666666642762721,0.0007666666642762721,0.0007666666642762721,0.000733333348762244,0.000733333348762244,0.000733333348762244,0.000733333348762244,0.000699999975040555,0.000699999975040555,0.000699999975040555,0.0006666666595265269,0.0006666666595265269,0.0006666666595265269,0.0006666666595265269,0.0006666666595265269,0.0006666666595265269,0.0006333333440124989,0.0006333333440124989,0.0006333333440124989,0.0006333333440124989,0.0006000000284984708,0.0006000000284984708,0.0006000000284984708,0.0006000000284984708,0.0006000000284984708,0.0006000000284984708,0.0005666666547767818,0.0005666666547767818,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005000000237487257,0.0005000000237487257,0.0005000000237487257,0.0005000000237487257,0.0005000000237487257,0.0005000000237487257} | {남구,수북면,"전주시 완산구",Aguiar,"Aldeia de Fidalgo","Al Qusais Third",Andabamba,Armstedt,Axton,Baltali,Baziaş,Bettoncourt,Bogusławice,Brimhall,"Bucureşti 75","Cajiga \(Ejido de Tultepec\)",Caputira,"Castle Bytham",Chalkari,Chilpacay,Cleveland,"Corvino San Quirico",Częstoniew,Dhabalpur,"Dubai Int'L Airport","El Cerro","El Sotolillo de Abajo","Estreito Calheta","Florence Road","Furukawa Mayose",Ghatboral,Grafton,Haag,Heimertingen,Höganäs,Huayllanhuayqo,"Innoshima Ohamacho","Jalan Isnin",Jardín,"Jumeira Bay",Kandasurugadai,Keçimen,Kirulapone,Korlapahad,"Kunimicho Kojiro Ko","La Fusión","La Palmita",Latbhabanipur,"Libertad Frontera",Longford,Loures,Mahadeshwarapura,Maqsoodapur,Mawatarimachi,Midorigaoka,Mitterndorf,Montlleo,Murtosa,"Narendra Nagar \(Tehri Garhwal\)","Niños Héroes de Chapultepec","Nuevo INFONAVIT","Olho Marinho","Otsukawa Takaramachi",Palhota,"Pasir Panjang Close",Perafita,Planèzes,Porzecze,"Puerta Real","Quinta dos Cascavelos","Rataje Karskie","Rincon De Los Francos",Ruprechtice,Sakae,"San Gregorio","Santa Catalina",Sanxay,Sayamba,Seppois-le-Bas,"Shivajinagar \(Nanded\)",Smilgiai,Sproul,Sundsvall,Takasagocho,Taxat-Senat,Timpoj,Toţeşti,Turuceachi,"Úrsulo Galván \(La Primavera\)","Varkališkių k.","Vila Meã",Viwandani,"Westwood Avenue",Yanagalan,Żądło,"Большой Сухояш",Зеленое,"Мала Кіндратівка \(Петрівська сільська рада\)",Петровка,Томызь,鹿部町役場} | -0.0057130232 | null | null | null | null | null | null |
| public | zipcodes | postal\_code | false | 0 | 7 | 145676 | {19000,04220,08420,21500,21825,08430,09000,10530,18400,33198,04180,04190,05700,06860,09100,10540,16310,19600,21215,25300,33637,33970,70000,85203,03475,03700,05500,05530,05610,05790,08300,09520,10220,10760,12565,12570,12770,13000,13780,16000,19310,20350,20470,21700,21895,28600,33195,45200,47250,52440,83303,85218} | {0.000366666674381122,0.00033333332976326346,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00023333333956543356,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503,0.00019999999494757503} | {0001,"020 25",0301,04135,05560,"067 01",08210,09260,10214,11-010,"120 87",1310,140702,15051,"15792 72126","16552 72489","174 49","18561 68206",195000,20340,210-0845,21530,22290,"23004 87424","23883 77314",2435-663,249125,2550-136,26103,"267 01",2720-254,"27710 66902","28217 65663","28779 66304",2955-114,30260,3090-705,31788,3250-295,"33181 79322",33825,34577,3520-044,36049,368621,37616,3830-032,38900,"39764 88772",4050-609,413101,"41957 87898",4250-551,4316,441215,4465-263,4535-178,"45929 CEDEX 9",466151,473613,48100,489-0893,4973,506356,5144,521213,531151,541170,"55339 84239",568463,578286,591234,6025,61230,6230-112,6302,64-000,65400,671-2106,68640,70144,71982,732208,7502,760928,77655,788155,801113,813104,83-262,85001,862067,882-0232,90617,930-0058,950-2155,969-6114,988-0077,EC1,LV-4636,ZE2} | 0.00088165567 | null | null | null | null | null | null |
| public | zipcodes | country\_code | false | 0 | 3 | 87 | {PT,AE,IN,JP,MX,SG,PE,PL,FR,RU,RO,US,ES,KR,TR,UA,GB,DE,LT,AR,IT,AU,SE,AT,DZ,CZ,HR,BR,LV,LU,NO,BG,SK,CH,EE,HU,NL,FI,CO,ZA,PK,CN,UY,BY,BE,MY,PH,MD,MA,LK,NZ,CA,CY,BD,DK,AZ,EC,RS,TH,DO,KE,PA} | {0.1216999962925911,0.10216666758060455,0.08709999918937683,0.0846666693687439,0.08336666971445084,0.06973333656787872,0.057366665452718735,0.039500001817941666,0.031433332711458206,0.025466667488217354,0.023333333432674408,0.023233333602547646,0.021566666662693024,0.020633332431316376,0.0203000009059906,0.015699999406933784,0.014566666446626186,0.013399999588727951,0.012033333070576191,0.011733333580195904,0.010900000110268593,0.010266666300594807,0.01003333367407322,0.009100000374019146,0.009100000374019146,0.008666666224598885,0.0037666666321456432,0.0034000000450760126,0.0032333333510905504,0.003100000089034438,0.0030666666571050882,0.0027666667010635138,0.0025333333760499954,0.0024333333130925894,0.0024333333130925894,0.0023333332501351833,0.0023333332501351833,0.002233333420008421,0.0020000000949949026,0.0020000000949949026,0.0018666667165234685,0.0017000000225380063,0.0015333333285525441,0.001500000013038516,0.001466666697524488,0.00143333338201046,0.00139999995008111,0.0011666666250675917,0.0010999999940395355,0.0010333333630114794,0.0010333333630114794,0.0009333333582617342,0.0009333333582617342,0.0008666666690260172,0.0007666666642762721,0.000733333348762244,0.000733333348762244,0.0006333333440124989,0.0006000000284984708,0.00039999998989515007,0.00039999998989515007,0.000366666674381122} | {AL,AL,AX,CL,CL,CR,CR,FO,GL,GT,HT,HT,IE,IM,IS,MQ,MW,MW,MW,PF,PM,PR,SI,SI,SM} | 0.055834055 | null | null | null | null | null | null |
| public | zipcodes | latitude | false | 0 | 8 | 57698 | {38.7167,44.418,41.1496,44.4914,41.2357,38.7538,41.1336,38.5244,32.6333,44.3819,35.6938,44.4378,35.65,39.7436,40.2056,35.694,44.4022,38.5667,39.4667,38.679,40.661,41.2004,41.5503,41.6932,55.7522,38.5558,41.4444,46.7667,47.1667,59.3326,38.0151,40.6443,22.7611,38.7927,41.0076,38.6142,38.6206,38.7566,39.2333,43.8833,57.7072,59.9127,16.703,22.4143,23.141,38.5167,41.1821,41.3016,44.3167,21.4898,35.6699,38.6501,38.7833,38.8188,41.3834,44.95,47.0458,55.6059,13.2257,23.4827,34.7052,35.3314,38.5424,38.5594,38.645,38.7067,38.7271,41.1551,41.3006,45.1,45.7537,46.5667,55.0667,-14.6508,1.3236,17.2734,17.9218,18.376,19.5158,21.5717,37.1377,37.7167,38.6496,38.767,38.801,38.8218,39.8222,41.2104,41.5388,41.8058,46.0667,46.1833,55.6,55.9333,-15.8309,-14.549,1.3182,18.696,21.2623,21.3729} | {0.0052999998442828655,0.00279999990016222,0.0026666666381061077,0.0019666666630655527,0.0013000000035390258,0.0012000000569969416,0.0011666666250675917,0.0010333333630114794,0.0009666666737757623,0.0009333333582617342,0.0008999999845400453,0.0008999999845400453,0.0008666666690260172,0.0007999999797903001,0.0007999999797903001,0.0007666666642762721,0.0007666666642762721,0.000733333348762244,0.000699999975040555,0.0006666666595265269,0.0006666666595265269,0.0006333333440124989,0.0006333333440124989,0.0006333333440124989,0.0006000000284984708,0.0005666666547767818,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005000000237487257,0.0005000000237487257,0.0004666666791308671,0.0004666666791308671,0.0004666666791308671,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686} | {-51.0983,-34.125,-28.9033,-17.674,-14.8158,-13.8134,-12.5996,-10.0014,-7.6,-4.825,1.3009,1.3145,1.323,1.3349,1.3543,1.3679,1.3901,6.0167,11.3598,14.8777,16.857,17.8322,18.6081,19.2852,19.81,20.4281,20.9631,21.839,22.7306,23.8903,24.817,25.0062,25.0374,25.0581,25.0897,25.1209,25.1538,25.1815,25.2178,25.236,25.2617,25.288,25.809,26.5605,27.4696,28.7643,30.6451,32.5074,33.5462,34.324,34.7502,35.0159,35.2393,35.5318,35.896,36.3062,36.6648,37.1174,37.4365,37.6983,38.109,38.5958,38.7863,39.0394,39.3777,39.7376,40.1402,40.505,40.7993,41.0608,41.2345,41.408,41.6858,42.2625,42.9842,43.3597,43.9833,44.9181,45.6368,46.3329,46.976,47.6181,48.1769,48.6242,49.0489,49.5347,49.8829,50.2723,50.7577,51.2217,51.7454,52.2011,52.62,53.1768,53.8397,54.6,55.4255,56.1201,57.6342,59.4032,70.6047} | -0.003896905 | null | null | null | null | null | null |
| public | zipcodes | longitude | false | 0 | 8 | 65712 | {-9.1333,26.1691,-8.611,26.0602,-8.6199,-9.2308,-8.6174,-8.8882,-16.9,26.1227,26.0174,139.7035,139.7333,-8.8071,-8.4196,-7.9,26.0624,139.7536,-9.1569,-8.4201,-7.9097,-8.8329,37.6156,-9.0676,27.6,-8.6025,-8.2962,18.0649,23.6,23.8,-9.1838,-8.6455,-7.8632,-8.6413,-9.2545,-9.1915,10.7461,11.9668,25.9667,-9.13,-9.0167,-8.6891,-8.6833,-8.5498,-8.3802,24.3667,26.0167,72.2477,77.8097,87.135,-28.1302,-9.0939,-8.7636,-8.2,13.0007,21.9183,86.917,87.267,139.777,-9.2467,-9.1484,-9.0537,-8.9739,-8.5041,21.2257,77.575,79.7582,88.5215,135.5019,136.8708,141.0997,-72.2087,-9.3783,-9.2979,-9.1898,-9.0908,-8.6151,-8.0197,-7.7441,-7.4909,-7.1869,-6.7572,23.5833,24.35,25.65,71.9007,73.4573,78.574,79.2449,-71.8492,-71.0975,-7.6486,-7.504,-7.4688,-7.4312,23.7833,24.5575,25.85,26.8203,70.4136} | {0.005233333446085453,0.00279999990016222,0.0026666666381061077,0.0019666666630655527,0.0013000000035390258,0.0012000000569969416,0.0011666666250675917,0.0010333333630114794,0.0009666666737757623,0.0009333333582617342,0.0008999999845400453,0.0008666666690260172,0.0008666666690260172,0.0007999999797903001,0.0007999999797903001,0.0007666666642762721,0.0007666666642762721,0.0007666666642762721,0.0006666666595265269,0.0006666666595265269,0.0006666666595265269,0.0006333333440124989,0.0006000000284984708,0.0005666666547767818,0.0005666666547767818,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005333333392627537,0.0005000000237487257,0.0005000000237487257,0.0005000000237487257,0.0004666666791308671,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.0004333333345130086,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.00039999998989515007,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.000366666674381122,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.00033333332976326346,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.0003000000142492354,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686,0.00026666666963137686} | {-169.8667,-109.6646,-105.7423,-103.2431,-101.3381,-100.3971,-99.4403,-98.5003,-97.0476,-93.261,-88.656,-79.6685,-77.9304,-76.7017,-75.6996,-74.4231,-72.9084,-71.0469,-66.3333,-58.2283,-17.1074,-9.2578,-8.9735,-8.7064,-8.564,-8.467,-8.3523,-8.168,-7.8879,-7.4698,-6.2597,-3.9638,-2.0232,-0.6132,0.9023,2.3876,4.234,5.7478,6.8706,8.7441,10.8807,12.9401,14.05,15.0838,16.1751,17.2137,18.3349,19.7238,20.9633,22.1588,23.1588,24.4844,25.5205,27.0266,28.628,31.9473,34.6353,37.5124,41.14,49.5147,55.1578,55.189,55.2153,55.2452,55.2686,55.2946,55.3275,55.3728,55.4112,55.4408,56.1271,73.0694,75.1036,76.3667,77.4143,78.5378,79.7668,82.1924,84.862,88.0676,101.6869,103.7639,103.8036,103.8346,103.8598,103.8789,103.9061,103.9467,125.2506,127.1167,128.7384,130.896,133.7304,135.5669,136.5508,137.288,139.1888,139.8757,140.6497,143.6103,176.7} | 0.0046742214 | null | null | null | null | null | null |

### Column definitions for `pg_stats` view
- `schemaname`: The schema name of the table.
- `tablename`: The name of the table. In this case, it is `zipcodes`.
- `attname`: The name of the column. 
- `inherited`: Whether the column is inherited from a parent table.
- `null_frac`: The fraction of NULL values in the column. The range is from 0 to 1. A value of 0 means that there are no NULL values in the column. A value of 1 means that all the values in the column are NULL.
- `avg_width`: The average size of the values in the column. This is used to calculate the size of the rows in the table.
- `n_distinct`: the estimated number of distinct values in the column. If less than zero, the negative of the number of distinct values divided by the number of rows. (The negated form is used when ANALYZE believes that the number of distinct values is likely to increase as the table grows; the positive form is used when the column seems to have a fixed number of possible values.) For example, -1 indicates a unique column in which the number of distinct values is the same as the number of rows.
- `most_common_vals`: A list of the most common values in the column. (Null if no values seem to be more common than any others. This is an array. Values in this column will typically have low selectivity, i.e., they will match a large fraction of the rows.
- `most_common_freqs`: A list of the frequencies of the most common values, i.e., number of occurrences of each divided by total number of rows. This is an array and has the same number of elements as the `most_common_vals` array presenting the frequency of the corresponding value. This is the selectivity of the value.
- `histogram_bounds`: A list of values that divide the column's values into groups of approximately equal population. The values in most_common_vals, if present, are omitted from this histogram calculation.
- `correlation`: Statistical correlation between physical row ordering and logical ordering of the column values. This ranges from -1 to +1. When the value is near -1 or +1, an index scan on the column will be estimated to be cheaper than when it is near zero, due to reduction of random access to the disk.

## Why do Postgres collect statistics?
Postgres collects statistics to estimate the number of rows that will be returned by a query. This is important because the number of rows 
returned by a query can affect the query plan that Postgres chooses to execute the query. The query plan can affect the performance of the query. 
If Postgres estimates the number of rows returned by a query incorrectly, it may affect selectivity and the query plan. 

For example, if Postgres estimates that a query will return a large subset of rows, it may choose a query plan that uses a sequential scan of the table.
On the other hand, if Postgres estimates that a query will return a small subset of rows, it may choose a query plan that uses an index scan of the table.
For more information on query plans, [see my previous article on query plans](how-does-query-planner-work.md).

## Statistics Sampling
Postgres collects statistics by sampling the data in the table. That means that Postgres does not look at every row in the table to collect statistics, but rather looks at a subset of the rows. 
The number of rows that Postgres samples is determined by the formula `300 * default_statistics_target` where `default_statistics_target` is a configuration parameter.
The default value of `default_statistics_target` is 100. This means that Postgres will sample 300 * 100 = 30,000 rows to collect statistics with the default configuration per table.
We can tune this parameter to collect statistics on more or fewer sampled rows. This parameter can be set on entire database or on a per-column basis:

```sql
-- entire database
ALTER DATABASE mydb SET default_statistics_target = 1000;

-- per column
ALTER TABLE mytable ALTER COLUMN mycolumn SET STATISTICS 1000;
```

As with everything, this comes with certain trade-offs. Sampling fewer rows will result in faster statistics collection, but may result in less accurate statistics. Sampling more rows will result in more accurate statistics, but may take longer to collect statistics.

## When does Postgres collect statistics?
Postgres collects statistics when the `ANALYZE` command is run on a table. The `ANALYZE` command collects statistics on the table and its columns.
The `ANALYZE` command can be run manually by a user, or it can be run automatically by Postgres (as part of the `AutoVacuum` process). 
By default, Postgres runs `ANALYZE` automatically when a table is created or when a large number of rows are inserted or updated into a table.

# Row estimations with statistics
Postgres uses statistics to estimate the number of rows that will be returned by a query. Lets look at some examples of how Postgres uses statistics to estimate the number of rows returned by a query with a single where clause.
We will the same `zipcodes` table that we used in the previous section.

## Row estimation with single where clause

```sql
explain analyze Select * from zipcodes where country_code='GB';

-- result
Gather  (cost=1000.00..1433109.61 rows=1270164 width=47) (actual time=33.996..4936.894 rows=1372500 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on zipcodes  (cost=0.00..1305093.21 rows=529235 width=47) (actual time=161.649..4848.562 rows=457500 loops=3)
        Filter: (country_code = 'GB'::bpchar)
        Rows Removed by Filter: 28608050
Planning Time: 0.390 ms
JIT:
  Functions: 6
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 4.623 ms (Deform 2.235 ms), Inlining 421.647 ms, Optimization 33.980 ms, Emission 25.874 ms, Total 486.124 ms"
Execution Time: 4966.751 ms
```
Here we can see that Postgres estimates that the query will return 1270164 rows. The actual number of rows returned by the query is 1372500. SO the postgres estimate was off by 102,336 rows. This is a difference of 8% from the actual number of rows returned by the query.
This is still somewhat acceptable, but it is not perfect. The accuracy of the estimate can be improved by collecting more accurate statistics on the table like we discussed in the last section. Therefore, we change the statistics target for the `country_code` column to 1000 and run the `ANALYZE` command on the table.

```sql
ALTER TABLE zipcodes ALTER COLUMN country_code SET STATISTICS 1000;
ALTER TABLE zipcodes ALTER COLUMN city_name SET STATISTICS 1000;

ANALYZE zipcodes;
```

Now if we run the same query plan again, we get the following result:

```sql
explain analyze Select * from zipcodes where country_code='GB';

-- result
Gather  (cost=1000.00..1437847.53 rows=1317542 width=47) (actual time=33.037..4925.569 rows=1372500 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on zipcodes  (cost=0.00..1305093.33 rows=548976 width=47) (actual time=152.938..4849.513 rows=457500 loops=3)
        Filter: (country_code = 'GB'::bpchar)
        Rows Removed by Filter: 28608050
Planning Time: 0.386 ms
JIT:
  Functions: 6
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 2.170 ms (Deform 0.798 ms), Inlining 398.676 ms, Optimization 33.396 ms, Emission 25.916 ms, Total 460.158 ms"
Execution Time: 4955.093 ms
```

Now Postgres estimates that the query will return 1317542 rows. The actual number of rows returned by the query is 1372500. So the postgres estimate was off by 54958 rows. This is a difference of 4% from the actual number of rows returned by the query. This is a significant improvement from the previous estimate.

> I would like to point out that even though the performance of the query can be increased by using the index, the row estimation will not change whether an index is used. The row estimation is based on the statistics collected on the table and its columns, not on the indexes that are present on the table.

## Row estimation with multiple where clauses
This look a bit different when we have multiple where clauses in the query. Lets look at an example:

```sql
explain analyze Select * from zipcodes where country_code='DE' and city_name='Berlin';

-- result
Gather  (cost=1000.00..1396923.60 rows=4 width=47) (actual time=121.924..4844.975 rows=9100 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on zipcodes  (cost=0.00..1395923.20 rows=2 width=47) (actual time=236.078..4752.393 rows=3033 loops=3)
        Filter: ((country_code = 'DE'::bpchar) AND (city_name = 'Berlin'::text))
        Rows Removed by Filter: 29062517
Planning Time: 0.838 ms
JIT:
  Functions: 6
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 4.606 ms (Deform 1.389 ms), Inlining 429.158 ms, Optimization 39.585 ms, Emission 91.548 ms, Total 564.897 ms"
Execution Time: 4850.100 ms
```

This looks bad. Postgres estimates that the query will return 4 rows. The actual number of rows returned by the query is 9100. So the postgres estimate was off by 9096 rows. This is a difference of 2274% from the actual number of rows returned by the query. This is a very bad estimate. 
What went wrong? To understand this, we have to understand how postgres estimates multivariate queries.

## `and` filters and row estimation
When we have multiple where clauses in a query, Postgres estimates the number of rows returned by the query by multiplying the selectivity of each where clause.
For example, in the above query `Select * from zipcodes where country_code='DE' and city_name='Berlin';`, Postgres estimates the number of rows returned by the query by multiplying the selectivity of the `country_code='DE'` where clause with the selectivity of the `city_name='Berlin'` where clause.
So, in essence the row estimation is done as follows:

```
selectivity of multiple where clause = selectivity(country_code='DE') * selectivity(city_name='Berlin')
```
selectivity is the fraction of rows that match the where clause. [In the last article](how-does-query-planner-work.md), we saw how to calculate the selectivity of a where clause from the statistics. 
So for example, if the selectivity of the `country_code='DE'` where clause is 0.1 and the selectivity of the `city_name='Berlin'` where clause is 0.1, then the selectivity of the multiple where clause is 0.1 * 0.1 = 0.01.
This works well when the where clauses are independent of each other. But in this case, the `country_code` and `city_name` columns are not independent of each other. The `city_name` column is dependent on the `country_code` column. (i.e. most of the zip codes returned are from Berlin which is the capital and biggest city of Germany).
This is a typical case of underestimation by the query planner when the columns are dependent on each other. 

It is common to see slow queries running bad execution plans because multiple columns used in the query clauses are correlated. The planner normally assumes that multiple conditions are independent of each other, an assumption that does not hold when column values are correlated. 
Regular statistics, because of their per-individual-column nature, cannot capture any knowledge about cross-column correlation. However, PostgreSQL has the ability to compute multivariate statistics, which can capture such information.

# Extended statistics
Postgres has a feature called extended statistics that can be used to capture cross-column correlation. Extended statistics are statistics that are collected on multiple columns in a table.
Extended Statistics objects are created using the `CREATE STATISTICS` command. Creation of such an object merely creates a catalog entry expressing interest in the statistics. 
Actual data collection is performed by `ANALYZE` (either a manual command, or background auto-analyze). The collected values can be examined in the `pg_statistic_ext_data` catalog.
Because the number of possible column combinations is very large, it's impractical to compute multivariate statistics automatically.

There are 3 kinds of extended statistics that are supported by PostgreSQL:
- Functional dependencies
- Most common values
- Number of distinct values

## extended statistics: Functional dependencies
Functional dependencies are the simplest form of extended statistics. They capture the relationship between columns in a table. In a fully normalized database, functional dependencies should exist only on primary keys and superkeys. However, in practice many data sets are not fully normalized for various reasons; 
intentional denormalization for performance reasons is a common example. Even in a fully normalized database, there may be partial correlation between some columns, which can be expressed as partial functional dependency.
To inform the planner about functional dependencies, ANALYZE can collect measurements of cross-column dependency.

To create a functional dependency statistics object, you can use the `CREATE STATISTICS` command. For example, to create a functional dependency statistics object on the `country_code` and `city_name` columns in the `zipcodes` table, you can use the following command:

```sql
create statistics zipcodes_country_code_stats(dependencies) ON country_code, city_name FROM zipcodes;
analyze zipcodes;
```

Now, if we run the same query plan again, we get the following result:

```sql
explain analyze Select * from zipcodes where country_code='DE' and city_name='Berlin';

-- result
Gather  (cost=1000.00..1397810.15 rows=8861 width=47) (actual time=76.172..4926.686 rows=9100 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on zipcodes  (cost=0.00..1395924.05 rows=3692 width=47) (actual time=231.329..4871.890 rows=3033 loops=3)
        Filter: ((country_code = 'DE'::bpchar) AND (city_name = 'Berlin'::text))
        Rows Removed by Filter: 29062517
Planning Time: 0.925 ms
JIT:
  Functions: 6
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 4.403 ms (Deform 2.204 ms), Inlining 527.771 ms, Optimization 125.657 ms, Emission 27.181 ms, Total 685.013 ms"
Execution Time: 4931.307 ms
```

Heyo! This looks much better. Postgres estimates that the query will return 8861 rows. The actual number of rows returned by the query is 9100. 
So the postgres estimate was off by 239 rows. This is a difference of 2.6% from the actual number of rows returned by the query. This is a significant improvement from the previous estimate.

Lets see how does this extended statistics look like. This extended statistics are stored in the `pg_statistic_ext` and `pg_statistic_ext_data` tables. But we are more interested in the `pg_stats_ext` view becasue of its user friendliness.

```sql
select * from pg_stats_ext where tablename = 'zipcodes' and statistics_name = 'zipcodes_country_code_stats';
```

This will return the following result:

| schemaname | tablename | statistics\_schemaname | statistics\_name | statistics\_owner | attnames | exprs | kinds | inherited | n\_distinct | dependencies | most\_common\_vals | most\_common\_val\_nulls | most\_common\_freqs | most\_common\_base\_freqs |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| public | zipcodes | public | zipcodes\_country\_code\_stats | postgres | {city\_name,country\_code} | null | {f} | false | null | {"2 =&gt; 4": 0.945070, "4 =&gt; 2": 0.000017} | null | null | null | null |

This shows that there is a functional dependency between the `country_code` and `city_name` columns in the `zipcodes` table. The dependency is expressed as a fraction of rows that match the `country_code` column that also match the `city_name` column.

## Extended statistics: Most common values
An extension of the functional dependency statistics is the most common values statistics. This statistics object captures the most common values in a column. This can be useful for columns that have a small number of distinct values.
For this, `ANALYZE` can collect MCV lists on combinations of columns. Similarly to functional dependencies, it's impractical to do this for every possible column grouping. Even more so in this case, 
as the MCV list does store the common column values. So data is collected only for those groups of columns appearing together in a statistics object defined with the mcv option.

The mcv statistics for columns `city_name` and `country_code` in the `zipcodes` table can be created as follows:

```sql
create statistics zipcodes_country_code_city_name_stats_mcv(mcv) ON country_code, city_name FROM zipcodes;
analyze zipcodes;
```

Now, if we run the same query plan again, we get the following result:

```sql
explain analyze Select * from zipcodes where country_code='DE' and city_name='Berlin';

-- result
Gather  (cost=1000.00..1397861.85 rows=9288 width=47) (actual time=131.173..5059.160 rows=9100 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on zipcodes  (cost=0.00..1395923.05 rows=3912 width=47) (actual time=247.774..4956.574 rows=3033 loops=3)
        Filter: ((country_code = 'DE'::bpchar) AND (city_name = 'Berlin'::text))
        Rows Removed by Filter: 29062517
Planning Time: 2.753 ms
JIT:
  Functions: 6
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 4.720 ms (Deform 1.742 ms), Inlining 520.194 ms, Optimization 110.614 ms, Emission 104.087 ms, Total 739.615 ms"
Execution Time: 5063.572 ms
```

This looks much better. Postgres estimates that the query will return 9288 rows. The actual number of rows returned by the query is 9100. Postgres estimate was off by only 188 rows. MCV statistics generates very accurate row estimates for smaller number of distinct values.
Let's see how this looks like in the `pg_stats_ext` view:

```sql
select * from pg_stats_ext where tablename = 'zipcodes' and statistics_name = 'zipcodes_country_code_city_name_stats_mcv';
```

The result is (shortened for brevity):

| schemaname | tablename | statistics\_schemaname | statistics\_name | statistics\_owner | attnames | exprs | kinds | inherited | n\_distinct | dependencies | most\_common\_vals        | most\_common\_val\_nulls | most\_common\_freqs | most\_common\_base\_freqs                     |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |:--------------------------| :--- | :--- |:----------------------------------------------|
| public | zipcodes | public | zipcodes\_country\_code\_city\_name\_stats\_mcv | postgres | {city\_name,country\_code} | null | {m} | false | null | null | {{Mirdif,AE},{Lisboa,PT}} | {{false,false},{false,false}} | {0.005532666666666667,0.005260333333333333} | {0.0005653647644444444,0.0006253471600000001} |

Here you can see that postgres has collected the mcv values for most common possible combinations of `city_name` and `country_code` columns in the `zipcodes` table.
A better way to see this is to use the `pg_stats_ext_data` table:

```sql
SELECT m.* FROM pg_statistic_ext join pg_statistic_ext_data on (oid = stxoid),
                pg_mcv_list_items(stxdmcv) m WHERE stxname = 'zipcodes_country_code_city_name_stats_mcv' limit 2;
```

This will return the following result:

| index | values | nulls | frequency | base\_frequency |
| :--- | :--- | :--- | :--- | :--- |
| 0 | {Mirdif,AE} | {false,false} | 0.005532666666666667 | 0.0005653647644444444 |
| 1 | {Lisboa,PT} | {false,false} | 0.005260333333333333 | 0.0006253471600000001 |


## extended statistics: Number of distinct values

> Before continuing, since there are 87 million records in the `zipcodes` table, Lets increase the statistics target for the `country_code` and `city_name` columns to 10000 to get more accurate statistics.

```sql
alter table zipcodes alter column country_code set statistics 10000;
alter table zipcodes alter column city_name set statistics 10000;
analyze zipcodes;
```

### Single column aggregation queries
Lets shift our focus on aggregation queries. Lets try to estimate the number of rows returned by a query with a group by clause. For example, lets try to group by the `country_code` column and count the number of rows in each group.

```sql
explain analyze Select count(*) from zipcodes group by country_code;

-- result
Finalize GroupAggregate  (cost=1396911.45..1396937.29 rows=102 width=11) (actual time=12102.510..12108.319 rows=120 loops=1)
  Group Key: country_code
  ->  Gather Merge  (cost=1396911.45..1396935.25 rows=204 width=11) (actual time=12102.479..12108.252 rows=360 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=1395911.42..1395911.68 rows=102 width=11) (actual time=12062.235..12062.241 rows=120 loops=3)
              Sort Key: country_code
              Sort Method: quicksort  Memory: 28kB
              Worker 0:  Sort Method: quicksort  Memory: 28kB
              Worker 1:  Sort Method: quicksort  Memory: 28kB
              ->  Partial HashAggregate  (cost=1395907.00..1395908.02 rows=102 width=11) (actual time=12062.130..12062.139 rows=120 loops=3)
                    Group Key: country_code
                    Batches: 1  Memory Usage: 40kB
                    Worker 0:  Batches: 1  Memory Usage: 48kB
                    Worker 1:  Batches: 1  Memory Usage: 48kB
                    ->  Parallel Seq Scan on zipcodes  (cost=0.00..1214252.67 rows=36330867 width=3) (actual time=0.257..8118.513 rows=29065550 loops=3)
Planning Time: 0.321 ms
JIT:
  Functions: 21
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 2.451 ms (Deform 0.711 ms), Inlining 258.385 ms, Optimization 49.278 ms, Emission 82.620 ms, Total 392.734 ms"
Execution Time: 12110.665 ms
```

Postgres estimates that the query will return 102 rows. The actual number of rows returned by the query is 120. So the postgres estimate was off by 18 rows. 
This is a difference of 15% from the actual number of rows returned by the query. This is a quite a good estimation for a group by query.
PostgreSQL does this estimation by getting the distinct values of the `country_code` column from single column statistics (i.e. the `pg_statistic` table or the `pg_stats` view).
We can confirm this by looking at the `pg_stats` view for the `country_code` column:

```sql
SELECT n_distinct FROM pg_stats WHERE tablename = 'zipcodes' AND attname = 'country_code';
```
And the result is 102. So postgres estimates that the query will return 102 rows by using the number of distinct values in the `country_code` column.

### Multi column aggregation queries
So far so good right? But what if we have a multi column aggregation query? Lets try to group by the `country_code` and `city_name` columns and count the number of rows in each group.

```sql
explain analyze Select count(*) from zipcodes group by country_code, city_name;

-- result
Finalize HashAggregate  (cost=7116407.24..7407962.45 rows=8719408 width=24) (actual time=51600.871..51969.420 rows=824950 loops=1)
"  Group Key: country_code, city_name"
  Planned Partitions: 128  Batches: 129  Memory Usage: 8209kB  Disk Usage: 122768kB
  ->  Gather  (cost=3633526.00..5819395.30 rows=17438816 width=24) (actual time=45420.214..50682.119 rows=2474850 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial HashAggregate  (cost=3632526.00..4074513.70 rows=8719408 width=24) (actual time=45337.320..50330.206 rows=824950 loops=3)
"              Group Key: country_code, city_name"
              Planned Partitions: 128  Batches: 129  Memory Usage: 8209kB  Disk Usage: 646640kB
              Worker 0:  Batches: 129  Memory Usage: 8209kB  Disk Usage: 646512kB
              Worker 1:  Batches: 129  Memory Usage: 8209kB  Disk Usage: 646616kB
              ->  Parallel Seq Scan on zipcodes  (cost=0.00..1214252.67 rows=36330867 width=16) (actual time=0.955..10451.545 rows=29065550 loops=3)
Planning Time: 1.500 ms
JIT:
  Functions: 32
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 4.914 ms (Deform 1.445 ms), Inlining 554.478 ms, Optimization 358.107 ms, Emission 151.354 ms, Total 1068.854 ms"
Execution Time: 52004.619 ms
```

Postgres estimates that the query will return 8719408 rows. The actual number of rows returned by the query is 824950. So the postgres estimate was off by 7894458 rows or in other words, postgres overestimated by over ~957%. This is a very bad estimate.
This is because Postgres uses the number of distinct values in the `country_code` and `city_name` columns from statistics and multiplies them (capped at 10% of the number of total rows) to estimate the number of rows returned by the query.

What can we do to improve this? We can use `nDistinct` type extended statistics to capture the cross-column correlation between the `country_code` and `city_name` columns. 
Lets create an extended statistics object on the `country_code` and `city_name` columns in the `zipcodes` table:
```sql
create statistics zipcodes_country_code_city_name_stats_nDistinct(nDistinct) ON country_code, city_name FROM zipcodes;
analyze zipcodes;
```

Now, if we run the same query plan again, we get the following result:

```sql
explain analyze Select count(*) from zipcodes group by country_code, city_name;

-- result
Finalize GroupAggregate  (cost=4085086.32..4280004.65 rows=754475 width=24) (actual time=51181.840..53494.455 rows=824950 loops=1)
"  Group Key: country_code, city_name"
  ->  Gather Merge  (cost=4085086.32..4261142.78 rows=1508950 width=24) (actual time=51181.463..53083.522 rows=2474850 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=4084086.30..4085972.48 rows=754475 width=24) (actual time=50813.235..51487.745 rows=824950 loops=3)
"              Sort Key: country_code, city_name"
              Sort Method: external merge  Disk: 31376kB
              Worker 0:  Sort Method: external merge  Disk: 31352kB
              Worker 1:  Sort Method: external merge  Disk: 31368kB
              ->  Partial HashAggregate  (cost=3632607.92..3994956.75 rows=754475 width=24) (actual time=37954.630..47415.732 rows=824950 loops=3)
"                    Group Key: country_code, city_name"
                    Planned Partitions: 16  Batches: 17  Memory Usage: 8337kB  Disk Usage: 599096kB
                    Worker 0:  Batches: 17  Memory Usage: 8337kB  Disk Usage: 574472kB
                    Worker 1:  Batches: 17  Memory Usage: 8337kB  Disk Usage: 585744kB
                    ->  Parallel Seq Scan on zipcodes  (cost=0.00..1214263.37 rows=36331937 width=16) (actual time=1.261..10355.229 rows=29065550 loops=3)
Planning Time: 1.275 ms
JIT:
  Functions: 27
"  Options: Inlining true, Optimization true, Expressions true, Deforming true"
"  Timing: Generation 27.570 ms (Deform 2.146 ms), Inlining 603.080 ms, Optimization 417.432 ms, Emission 163.773 ms, Total 1211.855 ms"
Execution Time: 53579.558 ms
```

Here, Postgres estimates that the query will return 754475 rows. The actual number of rows returned by the query is 824950. So the postgres estimate was off by 70475 rows. This is a difference of ~9% from the actual number of rows returned by the query. This is a significant improvement from the previous estimate.

Lets see how does this extended statistics look like. Similar to last section, we will check the `pg_stats_ext` view.

```sql
select * from pg_stats_ext where tablename = 'zipcodes' and statistics_name = LOWER('zipcodes_country_code_city_name_stats_nDistinct');
```

This will return the following result:

| schemaname | tablename | statistics\_schemaname | statistics\_name | statistics\_owner | attnames | exprs | kinds | inherited | n\_distinct | dependencies | most\_common\_vals | most\_common\_val\_nulls | most\_common\_freqs | most\_common\_base\_freqs |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| public | zipcodes | public | zipcodes\_country\_code\_city\_name\_stats\_ndistinct | postgres | {city\_name,country\_code} | null | {d} | false | {"2, 4": 754475} | null | null | null | null | null |

This shows that there is a number of distinct values statistics object on the `country_code` and `city_name` columns in the `zipcodes` table. The number of distinct values is 754475 which is the value that Postgres used to estimate the number of rows returned by the query.

# Conclusion
In this article, we looked at PostgreSQL statistics, what they are, how they are used and how they can be used to improve query performance. We also looked at how Postgres collects statistics, when it collects statistics and how it uses statistics to estimate the number of rows returned by a query. 

We also looked at how Postgres uses statistics to estimate the number of rows returned by a query with a single where clause and with multiple where clauses. We also looked at how Postgres uses statistics to estimate the number of rows returned by a query with a group by clause and with a group by clause with multiple columns. 

We also looked at how extended statistics can be used to capture cross-column correlation and improve the accuracy of row estimates. We looked at three types of extended statistics: functional dependencies, most common values and number of distinct values. We saw how these extended statistics can be used to improve the accuracy of row estimates for queries with multiple columns. I hope this article was helpful in understanding how Postgres uses statistics to estimate the number of rows returned by a query and how extended statistics can be used to improve the accuracy of row estimates.

# References
- [Postgres documentation on statistics](https://www.postgresql.org/docs/current/planner-stats.html): Probably the most comprehensive resource on Postgres statistics. There were few lines so masterfully described there that I had to copy them verbatim.
- [CREATE STATISTICS - what is it for - Tomas Vondra: PGCon 2020](https://www.youtube.com/watch?v=xPorz6N8ogE)
- [Louise Grandjonc - A Deep Dive into Postgres Statistics (PGConf.EU 2024)](https://www.youtube.com/watch?v=ApAClPFJ_rU)
- https://www.crunchydata.com/blog/indexes-selectivity-and-statistics
- https://build.affinity.co/how-we-used-postgres-extended-statistics-to-achieve-a-3000x-speedup-ea93d3dcdc61
- https://aws.amazon.com/blogs/database/understanding-statistics-in-postgresql/

