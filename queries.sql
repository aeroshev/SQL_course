--Exercise 1--
SELECT  count(DISTINCT user_id) AS qty_clients,
        count(contract_id) AS qty_contracts,
        count(DISTINCT c.event_id) AS qty_register_events,
        (SELECT count(DISTINCT service_id) AS sevices_provided FROM contract_service),
        (SELECT count(premises_id) FROM rental_agreement) AS qty_contracts_premises,
        sum(rent_cost) AS income,
        (SELECT sum(count_total_cost(contract_id)) FROM contract) AS total_money,
        (SELECT sum(total_payments) FROM invite) AS total_payed_stars,
        (SELECT sum(s.price) FROM contract_service AS cs JOIN service AS s ON cs.service_id = s.service_id) AS total_payed_service,
        (SELECT sum(p.price) FROM premises AS p JOIN rental_agreement AS ra ON ra.premises_id = p.premises_id) AS total_payed_premises,
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
--Exercise 3--


--Exercise 4--
WITH income_services (contract_id, description, price) AS (
    SELECT contract_id, description, price FROM contract_service AS cs JOIN service AS s ON cs.service_id = s.service_id
)
SELECT description, count(c.contract_id) AS qty_contracts, max(date_contract) AS last_mention, sum(price)
    FROM contract AS c JOIN income_services AS isr ON c.contract_id = isr.contract_id GROUP BY description;

--Exercise 5--
WITH not_null_premises_event (event_id, name, price, qty_premises) AS (
    SELECT e.event_id, type, rent_cost, count(*) FROM event AS e JOIN rental_agreement AS ra ON e.event_id = ra.event_id
        WHERE e.event_id IN (SELECT event_id FROM rental_agreement) GROUP BY e.event_id, type, rent_cost
)

SELECT
    name,
    count(*) AS qty_contracts,
    qty_premises,
    price,
    --Check this column--
    price - (SELECT sum(count_total_cost(contract_id))) AS profit
    FROM contract AS c JOIN not_null_premises_event AS nn ON c.event_id = nn.event_id
        GROUP BY name, qty_premises, price;
