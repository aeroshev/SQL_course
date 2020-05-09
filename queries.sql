--Exercise 1--
--Qty clients--
SELECT count(*) AS qty_clients FROM client;

--Qty contracts--
SELECT count(*) AS qty_contracts FROM contract;

--Qty different events for which conclude contract--
--First way--
CREATE OR REPLACE VIEW public.contract_event (_event_) AS SELECT event_id FROM contract;
SELECT count(event_id) AS event_in_contract FROM event JOIN contract_event ON event.event_id = contract_event._event_;
--or--
SELECT count(e.event_id) AS qty_register_events FROM event AS e JOIN contract AS c ON e.event_id = c.event_id;


