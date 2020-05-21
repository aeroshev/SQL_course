------------------------------------------------------------------------------------------------------------------------
--Exercise 1--
SELECT  count(DISTINCT user_id) AS qty_clients,
        count(contract_id) AS qty_contracts,
        count(DISTINCT c.event_id) AS qty_register_events,
        (SELECT count(DISTINCT service_id) AS sevices_provided FROM contract_service),
        (SELECT count(premises_id) FROM rental_agreement) AS qty_contracts_premises,
        sum(rent_cost) AS income,
        (SELECT sum(count_total_cost(contract_id)) FROM contract) AS total_money,
        (SELECT sum(total_payments) FROM invite) AS total_payed_stars,
        (SELECT sum(s.price) FROM contract_service AS cs JOIN service AS s ON cs.service_id = s.service_id)
            AS total_payed_service,
        (SELECT sum(p.price) FROM premises AS p JOIN rental_agreement AS ra ON ra.premises_id = p.premises_id)
            AS total_payed_premises,
        (SELECT count(*) AS qty_invites_stars FROM invite WHERE qty_events > 0),
        (SELECT count(*) AS qty_dissolved_contracts FROM contract WHERE now() >= date_dissolve)
        FROM contract AS c JOIN event AS e ON c.event_id = e.event_id;

------------------------------------------------------------------------------------------------------------------------
--Exercise 2--
WITH orders_clients (user_id, qty_orders) AS (
    SELECT user_id, count(*) FROM contract GROUP BY user_id
), data_client (user_id, name, address) AS (
    SELECT user_id, name, place_residence FROM individual
    UNION
    SELECT user_id, name_org, address_org FROM organization
), serv_services (user_id, qty_serv_services) AS (
    SELECT user_id, count(string_id) FROM contract c JOIN contract_service cs ON c.contract_id = cs.contract_id
        GROUP BY user_id
), diff_payment (user_id, contract_id, return_money) AS (
    SELECT user_id,
           c.contract_id,
           --Penalty 15%--
           sum(payed) * 0.85
    FROM payment p JOIN contract c ON p.contract_id = c.contract_id WHERE now() >= date_dissolve
        GROUP BY user_id, c.contract_id
)

SELECT
       c.user_id,
       name,
       address,
       count(*) AS qty_orders,
       count(DISTINCT event_id) AS diff_events,
       (SELECT qty_serv_services FROM serv_services WHERE user_id = c.user_id),
       (SELECT sum(rent_cost) FROM event e JOIN contract c_ ON e.event_id = c_.event_id WHERE c_.user_id = c.user_id)
            AS all_payed,
       --?--Alter table
       (SELECT count(*) AS qty_dissolved_contracts FROM contract WHERE now() >= date_dissolve AND user_id = c.user_id),
       coalesce((SELECT return_money FROM diff_payment WHERE user_id = c.user_id), 0.00::money) AS back_cash
    FROM contract c JOIN data_client dc ON c.user_id = dc.user_id GROUP BY c.user_id, name, address
    HAVING count(*) = (SELECT max(qty_orders) FROM orders_clients);

------------------------------------------------------------------------------------------------------------------------
--Exercise 3--
WITH bound_services (event_id, qty_bound_services) AS (
    SELECT e.event_id, count(e.event_id) FROM event AS e JOIN possible_service AS ps ON e.event_id = ps.event_id
        GROUP BY e.event_id
), quantity_services (event_id, contract_id, qty_service_ic) AS (
    SELECT event_id, contract_id, count(string_id) FROM contract_service GROUP BY event_id, contract_id
)

SELECT
    e.event_id,
    type,
    coalesce(qty_bound_services, 0) AS qty_bound_services,
    (SELECT count(contract_id) FROM contract WHERE event_id = e.event_id) AS qty_includes_contracts,
    coalesce(round(avg(qty_service_ic), 2), 0)  AS avg_qty_services_in_contract,
    (SELECT count(DISTINCT user_id) FROM contract WHERE event_id = e.event_id) AS qty_client_use,
    (SELECT count(DISTINCT star_id) FROM subsidiary_agreement WHERE event_id = e.event_id) AS qty_stars,
    rent_cost AS price_event,
    (SELECT count_money_for_all(e.event_id)) AS spending_money,
    rent_cost - (SELECT count_money_for_all(e.event_id)) AS profit,
    coalesce((SELECT sum(fee) FROM subsidiary_agreement sa JOIN star s ON sa.star_id = s.star_id
        WHERE sa.event_id = e.event_id), 0.00::money) AS all_payment_stars
    FROM event e LEFT JOIN bound_services bs ON e.event_id = bs.event_id LEFT JOIN quantity_services qs
        ON e.event_id = qs.event_id
    GROUP BY e.event_id, type, qty_bound_services;

------------------------------------------------------------------------------------------------------------------------
--Exercise 4--
WITH income_services (contract_id, description, price) AS (
    SELECT contract_id, description, price FROM contract_service AS cs JOIN service AS s ON cs.service_id = s.service_id
)
SELECT description, count(c.contract_id) AS qty_contracts, max(date_contract) AS last_mention, sum(price)
    FROM contract AS c JOIN income_services AS isr ON c.contract_id = isr.contract_id GROUP BY description;

------------------------------------------------------------------------------------------------------------------------
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
    (SELECT count_money_for_all(nn.event_id)) AS all_spending,
    price - (SELECT count_money_for_all(nn.event_id)) AS profit
    FROM contract AS c JOIN not_null_premises_event AS nn ON c.event_id = nn.event_id
        GROUP BY nn.event_id, name, qty_premises, price;
------------------------------------------------------------------------------------------------------------------------
