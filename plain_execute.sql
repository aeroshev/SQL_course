SELECT DISTINCT e.event_id, rent_cost, e.type FROM event e JOIN rental_agreement ra on e.event_id = ra.event_id JOIN premises p on ra.premises_id = p.premises_id;
SELECT * FROM event WHERE event_id IN (SELECT rental_agreement.event_id FROM rental_agreement WHERE premises_id IN (SELECT premises.premises_id FROM premises));

CREATE INDEX ON event(event_id);
DROP INDEX event_event_id_idx;

CREATE INDEX ON service(price);
SELECT * FROM service WHERE price > 100.00::money;

CREATE TABLE test (
    id serial primary key,
    cost double precision NOT NULL
);

DROP TABLE test;

INSERT INTO test (cost) SELECT random() from generate_series(1, 1000000);
SELECT * FROM test WHERE cost > 0.9;
DROP INDEX test_cost_idx;
CREATE INDEX ON test(cost);
SELECT * FROM test WHERE cost > 0.9;

SET enable_seqscan TO on;
SET work_mem TO '32MB';

SHOW config_file;
