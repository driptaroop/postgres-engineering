-- needed for uuid generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS process
(
    process_id     UUID                     NOT NULL,
    process_type   TEXT                     NOT NULL,
    process_status TEXT                     NOT NULL,
    mfa_id         TEXT                     NOT NULL,
    mfa_status     TEXT                     NOT NULL,
    mfa_type       TEXT                     NOT NULL,
    mfa_expiry     timestamp with time zone NOT NULL,
    user_id        TEXT                     NOT NULL,
    process_time   timestamp with time zone NOT NULL,
    CONSTRAINT process_pk PRIMARY KEY (process_id)
);

-- function to generate random values from process_status array where initialized status should have 10% frequency and others should have 30% frequency

CREATE OR REPLACE FUNCTION random_process_status()
    RETURNS TEXT AS $$
DECLARE
    random_value INT;
BEGIN
    random_value := floor(random() * 10 + 1);
    IF random_value <= 1 THEN
        RETURN 'initialized';
    ELSE
        RETURN (array ['successful', 'cancelled', 'failed'])[floor(random() * 3 + 1)];
    END IF;
END;
$$ LANGUAGE plpgsql;

-- function to generate random values from mfa_status array where created status should have 10% frequency and others should have 45% frequency
CREATE OR REPLACE FUNCTION random_mfa_status()
    RETURNS TEXT AS $$
DECLARE
    random_value INT;
BEGIN
    random_value := floor(random() * 10 + 1);
    IF random_value <= 1 THEN
        RETURN 'created';
    ELSE
        RETURN (array ['authorized', 'expired'])[floor(random() * 2 + 1)];
    END IF;
END;
$$ LANGUAGE plpgsql;

-- insert into mfa process with the following constraints
-- process_type in ('email', 'phone', 'sms')
-- process_status in ('successful', 'cancelled', 'failed', 'initialized')
-- mfa_status in ('created', 'authorized', 'expired')
-- mfa_type in ('sms', 'app')
-- mfa_expiry randomly generated in next 1 hour
-- user_id randomly generated
-- process_time randomly generated in last 1 year
-- process_id randomly generated
-- mfa_id randomly generated

insert into process (process_id, process_type, process_status, mfa_id, mfa_status, mfa_type, mfa_expiry, user_id,
                         process_time)
select uuid_generate_v4(),
       (array ['email', 'phone', 'sms'])[floor(random() * 3 + 1)],
       random_process_status(),
       uuid_generate_v4(),
       random_mfa_status(),
       (array ['sms', 'app'])[floor(random() * 2 + 1)],
       now() + (random() * interval '1 hour'),
       uuid_generate_v4(),
       now() - (random() * interval '1 year')
from generate_series(1, 5000000) i;