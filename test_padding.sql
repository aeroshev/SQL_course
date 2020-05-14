INSERT INTO client (type) VALUES
    ('individual'),
    ('individual'),
    ('organization'),
    ('organization'),
    ('individual');

INSERT INTO premises (type, address, square, name, price) VALUES
    ('flat', 'New York, Main street, build 42', 75.34, 'Main Hotel', 5000.00),
    ('hostel', 'Moskovskay oblast, Stupino, build 34', 39.11, 'U dady Stepu', 20.00),
    ('hotel', 'Moscow, red square, GUM', 120, 'U Putina', 3000.00);

INSERT INTO event (premises_id, type, rent_cost) VALUES
    (1, 'birthday', 75.34::money),
    (2, 'corporativ', 39.11::money),
    (1, 'wedding', 2000.00::money),
    (2, 'happy end',200.00::money),
    (3, 'happy start', 500.00::money),
    (NULL, 'open store', 100.00::money),
    (2, 300.00::money, 'meeting');

INSERT INTO contract (user_id, event_id, quantity_guest, date_contract, date_dissolve) VALUES
    (1, 1, 20, now(), '1/8/2021'),
    (2, 2, 50, now(), '12/1/2020'),
    (4, 3, 30, '2/10/2019', '04/20/2020'),
    (1, 4,  5, '5/10/2020', '7/10/2020'),
    (2, 5, 10, '5/8/2020', '7/8/2020'),
    (3, 1, 5, now(), '10/5/2020'),
    (4, 6, 100, now(), '7/3/2020');

INSERT INTO service (description, price) VALUES
    ('taxi to place event', 25.00),
    ('horse ride', 15.00);

INSERT INTO possible_service (service_id, event_id) VALUES
    (1, 2),
    (2, 1);

INSERT INTO paydoc (user_id, pay_date) VALUES
    (1, now()),
    (2, '3/24/2020'),
    (2, now()),
    (4, now());

--Testting trigger for contract_service--
--False statement--
INSERT INTO contract_service (contract_id, service_id, event_id) VALUES
    (1, 1, 2);
--True statement--
INSERT INTO contract_service (contract_id, service_id, event_id) VALUES
    (1, 2, 1);

--Testing trigger payment--
--False statement--
INSERT INTO payment (paydoc_id, contract_id, payed) VALUES
    (1, 2, 10.00);
--True statement--
INSERT INTO payment (paydoc_id, contract_id, payed) VALUES
    (1, 1, 10.00);

INSERT INTO star (real_name, nick_name, fee, contacts) VALUES
    ('Kianu_Rivz', 'John Wick', 1000.00, 'Canada'),
    ('Genri Kavill', 'Witcher', 2000.00, 'California'),
    ('Bredli Cuper', 'Lebo', 800.00, 'New York');

INSERT INTO subsidiary_agreement (event_id, star_id) VALUES
    (1, 1),
    (1, 2),
    (2, 1);
