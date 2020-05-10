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
--Qty services provided--
SELECT count(*) AS sevices_provided FROM contract_service;
--Income per all period--
SELECT sum(rent_cost) AS income FROM event;
--Qty contract premises--
SELECT count(premises_id) AS qty_contracts_premises FROM event;
--Qty star invite--
SELECT count(*) AS qty_invites_stars FROM invite WHERE qty_events > 0;
--Qty dissolved contracts--
SELECT count(*) AS qty_dissolved_contracts FROM contract WHERE now() >= date_dissolve;