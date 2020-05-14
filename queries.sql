--Exercise 1--
SELECT  count(DISTINCT user_id) AS qty_clients,
        count(contract_id) AS qty_contracts,
        count(DISTINCT c.event_id) AS qty_register_events,
        (SELECT count(*) AS sevices_provided FROM contract_service),
        count(premises_id) AS qty_contracts_premises,
        sum(rent_cost) AS income,
        (SELECT sum(count_total_cost(contract_id)) FROM contract) AS total_money,
        (SELECT sum(total_payments) FROM invite) AS total_payed_stars,
        (SELECT sum(s.price) FROM contract_service AS cs JOIN service AS s ON cs.service_id = s.service_id) AS total_payed_service,
        (SELECT sum(p.price) FROM premises AS p JOIN event AS e ON e.premises_id = p.premises_id) AS total_payed_premises,
        (SELECT count(*) AS qty_invites_stars FROM invite WHERE qty_events > 0),
        (SELECT count(*) AS qty_dissolved_contracts FROM contract WHERE now() >= date_dissolve)
        FROM contract AS c JOIN event AS e ON c.event_id = e.event_id;

--Exercise 2--
--Create view with command--
// SELECT user_id AS const_client, count(*) AS qty_orders FROM contract GROUP BY user_id HAVING count(*) > 1;
CREATE OR REPLACE VIEW happy_time.public.orders_clients (const_client_id, qty_orders) AS
    SELECT user_id, count(*) FROM contract GROUP BY user_id;
--Create report--
SELECT c.user_id, oc.qty_orders, count(DISTINCT c.event_id) AS qty_dif_events FROM contract AS c JOIN
    orders_clients AS oc ON c.user_id = oc.const_client_id
    WHERE oc.qty_orders = (SELECT max(qty_orders) FROM orders_clients) GROUP BY c.user_id, oc.qty_orders;
