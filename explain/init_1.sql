-- Drop table if it exists
DROP TABLE IF EXISTS important_cities;

-- Create the table
CREATE TABLE important_cities (
                                  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
                                  city_name TEXT NOT NULL,
                                  country_name TEXT NOT NULL,
                                  latitude DECIMAL(8,6) NOT NULL,
                                  longitude DECIMAL(9,6) NOT NULL
);

-- Insert data
INSERT INTO important_cities (city_name, country_name, latitude, longitude)
VALUES
    -- United States
    ('New York', 'United States', 40.712776, -74.005974),
    ('Los Angeles', 'United States', 34.052235, -118.243683),
    ('Chicago', 'United States', 41.878113, -87.629799),
    ('Houston', 'United States', 29.760427, -95.369804),
    ('Phoenix', 'United States', 33.448376, -112.074036),
    ('Philadelphia', 'United States', 39.952583, -75.165222),
    ('San Antonio', 'United States', 29.424122, -98.493629),
    ('San Diego', 'United States', 32.715736, -117.161087),
    ('Dallas', 'United States', 32.776665, -96.796989),
    ('San Jose', 'United States', 37.338207, -121.886330),

    -- Canada
    ('Toronto', 'Canada', 43.651070, -79.347015),
    ('Vancouver', 'Canada', 49.282730, -123.120735),
    ('Montreal', 'Canada', 45.501690, -73.567253),
    ('Calgary', 'Canada', 51.044733, -114.071883),
    ('Edmonton', 'Canada', 53.546124, -113.493823),
    ('Ottawa', 'Canada', 45.421530, -75.697193),
    ('Winnipeg', 'Canada', 49.895077, -97.138451),
    ('Quebec City', 'Canada', 46.813878, -71.207981),
    ('Hamilton', 'Canada', 43.255722, -79.871101),
    ('Halifax', 'Canada', 44.648766, -63.575237),

    -- United Kingdom
    ('London', 'United Kingdom', 51.507351, -0.127758),
    ('Birmingham', 'United Kingdom', 52.486244, -1.890401),
    ('Manchester', 'United Kingdom', 53.483959, -2.244644),
    ('Glasgow', 'United Kingdom', 55.864239, -4.251806),
    ('Liverpool', 'United Kingdom', 53.408371, -2.991573),
    ('Leeds', 'United Kingdom', 53.800755, -1.549077),
    ('Edinburgh', 'United Kingdom', 55.953251, -3.188267),
    ('Bristol', 'United Kingdom', 51.454514, -2.587910),
    ('Sheffield', 'United Kingdom', 53.381129, -1.470085),
    ('Newcastle', 'United Kingdom', 54.978252, -1.617439),

    -- Germany
    ('Berlin', 'Germany', 52.520008, 13.404954),
    ('Hamburg', 'Germany', 53.551086, 9.993682),
    ('Munich', 'Germany', 48.135124, 11.581981),
    ('Cologne', 'Germany', 50.937531, 6.960279),
    ('Frankfurt', 'Germany', 50.110924, 8.682127),
    ('Stuttgart', 'Germany', 48.775846, 9.182932),
    ('Düsseldorf', 'Germany', 51.227741, 6.773456),
    ('Dortmund', 'Germany', 51.513400, 7.465298),
    ('Essen', 'Germany', 51.455643, 7.011555),
    ('Leipzig', 'Germany', 51.339695, 12.373075),

    -- France
    ('Paris', 'France', 48.856613, 2.352222),
    ('Marseille', 'France', 43.296482, 5.369780),
    ('Lyon', 'France', 45.764042, 4.835659),
    ('Toulouse', 'France', 43.604652, 1.444209),
    ('Nice', 'France', 43.710173, 7.261953),
    ('Nantes', 'France', 47.218371, -1.553621),
    ('Strasbourg', 'France', 48.573405, 7.752111),
    ('Montpellier', 'France', 43.610769, 3.876716),
    ('Bordeaux', 'France', 44.837789, -0.579180),
    ('Lille', 'France', 50.629250, 3.057256),

    -- Italy
    ('Rome', 'Italy', 41.902782, 12.496366),
    ('Milan', 'Italy', 45.464203, 9.189982),
    ('Naples', 'Italy', 40.851775, 14.268124),
    ('Turin', 'Italy', 45.070312, 7.686856),
    ('Palermo', 'Italy', 38.115690, 13.361486),
    ('Genoa', 'Italy', 44.405650, 8.946256),
    ('Bologna', 'Italy', 44.494887, 11.342616),
    ('Florence', 'Italy', 43.769562, 11.255814),
    ('Bari', 'Italy', 41.117143, 16.871871),
    ('Catania', 'Italy', 37.507877, 15.083030),

    -- Poland
    ('Warsaw', 'Poland', 52.229676, 21.012229),
    ('Kraków', 'Poland', 50.064651, 19.944981),
    ('Łódź', 'Poland', 51.759248, 19.455983),
    ('Wrocław', 'Poland', 51.107883, 17.038538),
    ('Poznań', 'Poland', 52.406374, 16.925168),
    ('Gdańsk', 'Poland', 54.352025, 18.646638),
    ('Szczecin', 'Poland', 53.428543, 14.552812),
    ('Bydgoszcz', 'Poland', 53.123482, 18.008438),
    ('Lublin', 'Poland', 51.246453, 22.568446),
    ('Katowice', 'Poland', 50.270908, 19.039993),

    -- Sweden
    ('Stockholm', 'Sweden', 59.329323, 18.068581),
    ('Gothenburg', 'Sweden', 57.708870, 11.974560),
    ('Malmö', 'Sweden', 55.605293, 13.000156),
    ('Uppsala', 'Sweden', 59.858564, 17.638927),
    ('Västerås', 'Sweden', 59.611099, 16.546369),
    ('Örebro', 'Sweden', 59.275262, 15.213410),
    ('Linköping', 'Sweden', 58.410810, 15.621372),
    ('Helsingborg', 'Sweden', 56.046467, 12.694512),
    ('Jönköping', 'Sweden', 57.781450, 14.156185),
    ('Norrköping', 'Sweden', 58.587745, 16.192421),

    -- Norway
    ('Oslo', 'Norway', 59.913868, 10.752245),
    ('Bergen', 'Norway', 60.391263, 5.322054),
    ('Trondheim', 'Norway', 63.430515, 10.395053),
    ('Stavanger', 'Norway', 58.969976, 5.733107),
    ('Drammen', 'Norway', 59.743890, 10.204490),
    ('Fredrikstad', 'Norway', 59.220535, 10.929161),
    ('Kristiansand', 'Norway', 58.146564, 7.995484),
    ('Tromsø', 'Norway', 69.649571, 18.956545),
    ('Sandnes', 'Norway', 58.853542, 5.735037),
    ('Ålesund', 'Norway', 62.472228, 6.154924),

    -- Denmark
    ('Copenhagen', 'Denmark', 55.676098, 12.568337),
    ('Aarhus', 'Denmark', 56.162939, 10.203921),
    ('Odense', 'Denmark', 55.403756, 10.402370),
    ('Aalborg', 'Denmark', 57.048820, 9.921747),
    ('Esbjerg', 'Denmark', 55.476167, 8.459405),
    ('Randers', 'Denmark', 56.462086, 10.036377),
    ('Kolding', 'Denmark', 55.490398, 9.472166),
    ('Vejle', 'Denmark', 55.705139, 9.532861),
    ('Horsens', 'Denmark', 55.860657, 9.850337),
    ('Roskilde', 'Denmark', 55.641519, 12.080347),

    -- Finland
    ('Helsinki', 'Finland', 60.169857, 24.938379),
    ('Espoo', 'Finland', 60.205490, 24.655899),
    ('Tampere', 'Finland', 61.498150, 23.761025),
    ('Vantaa', 'Finland', 60.293373, 25.037750),
    ('Oulu', 'Finland', 65.012088, 25.465077),
    ('Turku', 'Finland', 60.451813, 22.266630),
    ('Jyväskylä', 'Finland', 62.241470, 25.720880),
    ('Lahti', 'Finland', 60.982673, 25.661221),
    ('Kuopio', 'Finland', 62.892379, 27.677038),
    ('Pori', 'Finland', 61.485032, 21.797645),

    -- China
    ('Beijing', 'China', 39.904202, 116.407394),
    ('Shanghai', 'China', 31.230391, 121.473701),
    ('Guangzhou', 'China', 23.129110, 113.264385),
    ('Shenzhen', 'China', 22.542883, 114.062996),
    ('Chengdu', 'China', 30.572815, 104.066801),
    ('Chongqing', 'China', 29.431586, 106.912251),
    ('Tianjin', 'China', 39.125596, 117.190183),
    ('Wuhan', 'China', 30.592850, 114.305539),
    ('Hangzhou', 'China', 30.274150, 120.155150),
    ('Xian', 'China', 34.341574, 108.939770),

    -- India
    ('Mumbai', 'India', 19.076090, 72.877426),
    ('Delhi', 'India', 28.704060, 77.102493),
    ('Bangalore', 'India', 12.971599, 77.594566),
    ('Kolkata', 'India', 22.572646, 88.363895),
    ('Chennai', 'India', 13.082680, 80.270721),
    ('Hyderabad', 'India', 17.385044, 78.486671),
    ('Pune', 'India', 18.520430, 73.856743),
    ('Ahmedabad', 'India', 23.022505, 72.571362),
    ('Jaipur', 'India', 26.912434, 75.787271),
    ('Surat', 'India', 21.170240, 72.831062),

    -- Japan
    ('Tokyo', 'Japan', 35.689487, 139.691711),
    ('Yokohama', 'Japan', 35.443707, 139.638031),
    ('Osaka', 'Japan', 34.693737, 135.502167),
    ('Nagoya', 'Japan', 35.181446, 136.906398),
    ('Sapporo', 'Japan', 43.061936, 141.354292),
    ('Kobe', 'Japan', 34.690082, 135.195511),
    ('Kyoto', 'Japan', 35.011636, 135.768029),
    ('Fukuoka', 'Japan', 33.590355, 130.401716),
    ('Hiroshima', 'Japan', 34.385202, 132.455293),
    ('Sendai', 'Japan', 38.268223, 140.869356),

    -- South Korea
    ('Seoul', 'South Korea', 37.566536, 126.977966),
    ('Busan', 'South Korea', 35.179554, 129.075642),
    ('Incheon', 'South Korea', 37.456256, 126.705206),
    ('Daegu', 'South Korea', 35.871435, 128.601445),
    ('Daejeon', 'South Korea', 36.350411, 127.384548),
    ('Gwangju', 'South Korea', 35.159546, 126.852601),
    ('Suwon', 'South Korea', 37.263573, 127.028601),
    ('Ulsan', 'South Korea', 35.538377, 129.311360),
    ('Changwon', 'South Korea', 35.227190, 128.681157),
    ('Jeonju', 'South Korea', 35.824223, 127.148000),

    -- Indonesia
    ('Jakarta', 'Indonesia', -6.208763, 106.845599),
    ('Surabaya', 'Indonesia', -7.257472, 112.752090),
    ('Bandung', 'Indonesia', -6.914744, 107.609810),
    ('Medan', 'Indonesia', 3.595196, 98.672223),
    ('Semarang', 'Indonesia', -6.966667, 110.416664),
    ('Makassar', 'Indonesia', -5.147665, 119.432731),
    ('Palembang', 'Indonesia', -2.976073, 104.775430),
    ('Batam', 'Indonesia', 1.045626, 104.030457),
    ('Pekanbaru', 'Indonesia', 0.507067, 101.447779),
    ('Bogor', 'Indonesia', -6.597147, 106.806039),

    -- Saudi Arabia
    ('Riyadh', 'Saudi Arabia', 24.713552, 46.675297),
    ('Jeddah', 'Saudi Arabia', 21.285407, 39.237551),
    ('Mecca', 'Saudi Arabia', 21.389082, 39.857910),
    ('Medina', 'Saudi Arabia', 24.524654, 39.569184),
    ('Dammam', 'Saudi Arabia', 26.392667, 49.977714),
    ('Taif', 'Saudi Arabia', 21.437273, 40.512715),
    ('Tabuk', 'Saudi Arabia', 28.383800, 36.566800),
    ('Buraidah', 'Saudi Arabia', 26.325999, 43.974999),
    ('Khobar', 'Saudi Arabia', 26.280050, 50.196152),
    ('Abha', 'Saudi Arabia', 18.246468, 42.511725),

    -- Argentina
    ('Buenos Aires', 'Argentina', -34.603722, -58.381592),
    ('Córdoba', 'Argentina', -31.420083, -64.188776),
    ('Rosario', 'Argentina', -32.946819, -60.639317),
    ('Mendoza', 'Argentina', -32.889458, -68.845839),
    ('La Plata', 'Argentina', -34.921451, -57.954531),
    ('San Miguel de Tucumán', 'Argentina', -26.808285, -65.217590),
    ('Mar del Plata', 'Argentina', -38.005477, -57.542611),
    ('Salta', 'Argentina', -24.782932, -65.423197),
    ('Santa Fe', 'Argentina', -31.633329, -60.700000),
    ('San Juan', 'Argentina', -31.537500, -68.536389),

    -- Brazil
    ('São Paulo', 'Brazil', -23.550520, -46.633308),
    ('Rio de Janeiro', 'Brazil', -22.906847, -43.172897),
    ('Brasília', 'Brazil', -15.826691, -47.921822),
    ('Salvador', 'Brazil', -12.977749, -38.501630),
    ('Fortaleza', 'Brazil', -3.731862, -38.526669),
    ('Belo Horizonte', 'Brazil', -19.916681, -43.934493),
    ('Manaus', 'Brazil', -3.119028, -60.021731),
    ('Curitiba', 'Brazil', -25.428356, -49.273252),
    ('Recife', 'Brazil', -8.047562, -34.877052),
    ('Porto Alegre', 'Brazil', -30.034647, -51.217659),

    -- Chile
    ('Santiago', 'Chile', -33.448890, -70.669265),
    ('Valparaíso', 'Chile', -33.047237, -71.612688),
    ('Concepción', 'Chile', -36.820135, -73.044390),
    ('Antofagasta', 'Chile', -23.652361, -70.395403),
    ('Temuco', 'Chile', -38.735901, -72.590373),
    ('Rancagua', 'Chile', -34.170132, -70.744707),
    ('Iquique', 'Chile', -20.230703, -70.135669),
    ('La Serena', 'Chile', -29.902669, -71.251937),
    ('Puerto Montt', 'Chile', -41.469307, -72.941136),
    ('Talca', 'Chile', -35.426395, -71.655420),

    -- Colombia
    ('Bogotá', 'Colombia', 4.711000, -74.072092),
    ('Medellín', 'Colombia', 6.244203, -75.581215),
    ('Cali', 'Colombia', 3.451647, -76.531985),
    ('Barranquilla', 'Colombia', 10.968540, -74.781321),
    ('Cartagena', 'Colombia', 10.391049, -75.479426),
    ('Bucaramanga', 'Colombia', 7.119349, -73.122741),
    ('Pereira', 'Colombia', 4.813337, -75.696112),
    ('Santa Marta', 'Colombia', 11.240355, -74.211023),
    ('Cúcuta', 'Colombia', 7.893907, -72.507820),
    ('Ibagué', 'Colombia', 4.438889, -75.232222),

    -- Peru
    ('Lima', 'Peru', -12.046374, -77.042793),
    ('Arequipa', 'Peru', -16.409047, -71.537451),
    ('Trujillo', 'Peru', -8.112981, -79.029983),
    ('Chiclayo', 'Peru', -6.771374, -79.840881),
    ('Piura', 'Peru', -5.194490, -80.632825),
    ('Cusco', 'Peru', -13.531950, -71.967462),
    ('Iquitos', 'Peru', -3.749120, -73.253833),
    ('Huancayo', 'Peru', -12.066667, -75.233333),
    ('Tacna', 'Peru', -18.006569, -70.246273),
    ('Juliaca', 'Peru', -15.499687, -70.133122),

    -- Ecuador
    ('Quito', 'Ecuador', -0.180653, -78.467838),
    ('Guayaquil', 'Ecuador', -2.170998, -79.922359),
    ('Cuenca', 'Ecuador', -2.900128, -79.005897),
    ('Santo Domingo', 'Ecuador', -0.254571, -79.171010),
    ('Machala', 'Ecuador', -3.258111, -79.960536),
    ('Manta', 'Ecuador', -0.967653, -80.713707),
    ('Portoviejo', 'Ecuador', -1.052511, -80.454644),
    ('Ambato', 'Ecuador', -1.249080, -78.616742),
    ('Esmeraldas', 'Ecuador', 0.963097, -79.651742),
    ('Ibarra', 'Ecuador', 0.347570, -78.122330),
    -- Nigeria
    ('Lagos', 'Nigeria', 6.524379, 3.379206),
    ('Abuja', 'Nigeria', 9.057850, 7.495080),
    ('Kano', 'Nigeria', 12.002179, 8.591956),
    ('Ibadan', 'Nigeria', 7.377560, 3.947040),
    ('Port Harcourt', 'Nigeria', 4.824167, 7.033611),
    ('Benin City', 'Nigeria', 6.338153, 5.625749),
    ('Kaduna', 'Nigeria', 10.510460, 7.416530),
    ('Jos', 'Nigeria', 9.896527, 8.858331),
    ('Enugu', 'Nigeria', 6.524379, 7.518930),
    ('Aba', 'Nigeria', 5.105349, 7.366931),

    -- South Africa
    ('Johannesburg', 'South Africa', -26.204103, 28.047305),
    ('Cape Town', 'South Africa', -33.924869, 18.424055),
    ('Durban', 'South Africa', -29.858681, 31.021840),
    ('Pretoria', 'South Africa', -25.747868, 28.229271),
    ('Port Elizabeth', 'South Africa', -33.960840, 25.602180),
    ('Bloemfontein', 'South Africa', -29.085215, 26.159576),
    ('East London', 'South Africa', -33.015285, 27.911624),
    ('Kimberley', 'South Africa', -28.728238, 24.749916),
    ('Polokwane', 'South Africa', -23.896171, 29.448626),
    ('Nelspruit', 'South Africa', -25.474480, 30.970300),

    -- Egypt
    ('Cairo', 'Egypt', 30.044420, 31.235712),
    ('Alexandria', 'Egypt', 31.200092, 29.918739),
    ('Giza', 'Egypt', 30.013056, 31.208853),
    ('Sharm El Sheikh', 'Egypt', 27.915817, 34.329950),
    ('Luxor', 'Egypt', 25.687243, 32.639637),
    ('Aswan', 'Egypt', 24.088938, 32.899829),
    ('Suez', 'Egypt', 29.966834, 32.549807),
    ('Port Said', 'Egypt', 31.265289, 32.301866),
    ('Mansoura', 'Egypt', 31.036373, 31.380691),
    ('Tanta', 'Egypt', 30.793664, 31.000198),

    -- Kenya
    ('Nairobi', 'Kenya', -1.286389, 36.817223),
    ('Mombasa', 'Kenya', -4.043477, 39.668206),
    ('Kisumu', 'Kenya', -0.091702, 34.767956),
    ('Nakuru', 'Kenya', -0.303099, 36.080026),
    ('Eldoret', 'Kenya', 0.514277, 35.269780),
    ('Thika', 'Kenya', -1.033263, 37.069327),
    ('Malindi', 'Kenya', -3.219186, 40.116898),
    ('Garissa', 'Kenya', -0.463509, 39.646098),
    ('Kitale', 'Kenya', 1.016097, 35.004778),
    ('Nyeri', 'Kenya', -0.424859, 36.951252),

    -- Ghana
    ('Accra', 'Ghana', 5.603717, -0.187000),
    ('Kumasi', 'Ghana', 6.666600, -1.616700),
    ('Tamale', 'Ghana', 9.400800, -0.839300),
    ('Takoradi', 'Ghana', 4.893200, -1.750000),
    ('Sunyani', 'Ghana', 7.340500, -2.327300),
    ('Cape Coast', 'Ghana', 5.105350, -1.246600),
    ('Koforidua', 'Ghana', 6.100000, -0.266700),
    ('Ho', 'Ghana', 6.600000, 0.466700),
    ('Bolgatanga', 'Ghana', 10.7833, -0.8500),
    ('Wa', 'Ghana', 10.0607, -2.5019),

    -- Ethiopia
    ('Addis Ababa', 'Ethiopia', 9.145000, 40.489673),
    ('Dire Dawa', 'Ethiopia', 9.600000, 41.866110),
    ('Mekelle', 'Ethiopia', 13.496667, 39.475000),
    ('Gondar', 'Ethiopia', 12.600000, 37.466700),
    ('Bahir Dar', 'Ethiopia', 11.600000, 37.383300),
    ('Jimma', 'Ethiopia', 7.666700, 36.833300),
    ('Awasa', 'Ethiopia', 7.033300, 38.500000),
    ('Adama', 'Ethiopia', 8.540000, 39.269500),
    ('Harar', 'Ethiopia', 9.312000, 42.125700),
    ('Debre Birhan', 'Ethiopia', 9.679330, 39.532240);

-- Query to check the data
SELECT * FROM important_cities LIMIT 10;

drop table if exists mcdonalds_purchases;
CREATE TABLE mcdonalds_purchases (
                                     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
                                     item_name TEXT NOT NULL,
                                     price NUMERIC(6,2) NOT NULL,
                                     datetime TIMESTAMP NOT NULL,
                                     city TEXT NOT NULL,
                                     country TEXT NOT NULL,
                                     store_latitude DECIMAL(8,6) NOT NULL,
                                     store_longitude DECIMAL(9,6) NOT NULL,
                                     quantity INT NOT NULL CHECK (quantity > 0),
                                     discount NUMERIC(5,2) DEFAULT 0 CHECK (discount >= 0),
                                     is_veg BOOLEAN NOT NULL,
                                     category TEXT
);

WITH items AS (
    SELECT * FROM (
                      VALUES
                          ('Big Mac', 'Burger', FALSE),
                          ('McChicken', 'Burger', FALSE),
                          ('McVeggie', 'Burger', TRUE),
                          ('Filet-O-Fish', 'Burger', FALSE),
                          ('McMuffin', 'Breakfast', FALSE),
                          ('Egg McMuffin', 'Breakfast', TRUE),
                          ('Hash Browns', 'Breakfast', TRUE),
                          ('French Fries', 'Sides', TRUE),
                          ('Chicken Nuggets', 'Sides', FALSE),
                          ('Apple Pie', 'Dessert', TRUE),
                          ('McFlurry', 'Dessert', TRUE),
                          ('Coca-Cola', 'Beverage', TRUE),
                          ('Iced Coffee', 'Beverage', TRUE),
                          ('Milkshake', 'Beverage', TRUE),
                          ('Spicy McChicken', 'Burger', FALSE)
                  ) AS t(item_name, category, is_veg)
)
INSERT INTO mcdonalds_purchases (item_name, price, datetime, city, store_latitude, store_longitude, country, quantity, discount, is_veg, category)
SELECT
    i.item_name,
    ROUND((random() * (9.99 - 1.99) + 1.99)::NUMERIC, 2) AS price,  -- Prices between $1.99 - $9.99
    NOW() - INTERVAL '1 year' * random(),  -- Random timestamps from last year
    l.city_name,
    l.latitude + (random() - 0.5) / 100, -- Slight latitude variation
    l.longitude + (random() - 0.5) / 100, -- Slight longitude variation
    l.country_name,
    FLOOR(random() * 5) + 1 AS quantity,  -- Quantity between 1-5
    ROUND((random() * 2.00)::NUMERIC, 2) AS discount, -- Discounts up to $2
    i.is_veg,
    -- 1% values will be null for category
    CASE WHEN random() < 0.01 THEN NULL ELSE i.category END
FROM
    generate_series(1, 2000, 1) AS s(i)
         CROSS JOIN items i
         CROSS JOIN important_cities l
ORDER BY random()
LIMIT 1000000;

select * from mcdonalds_purchases order by price desc;


------------


-- check statistics
select * from pg_stats where tablename='mcdonalds_purchases' and attname='city';

-- total rows: 1000000
select count(*) from mcdonalds_purchases;

-- null frequency: 0.08426667

explain analyze
select * from mcdonalds_purchases where category='Sides';

explain analyze
select * from mcdonalds_purchases where city='Cairo' and item_name='French Fries';
set enable_indexscan = on;
set enable_bitmapscan = on;
set max_parallel_workers_per_gather = 0;

create index on mcdonalds_purchases (city);

SELECT relpages, reltuples FROM pg_class WHERE relname = 'mcdonalds_purchases_city_idx';
