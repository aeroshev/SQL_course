INSERT INTO client (type) VALUES
    ('individual'),
    ('individual'),
    ('organization'),
    ('organization'),
    ('individual');

INSERT INTO individual (user_id, name, number_id, place_residence) VALUES
    (1, 'Johny Winson', 244235, 'Los Angeles, near beach'),
    (2, 'Mike Tayson', 11111, 'Los Angeles, Beverli Hills'),
    (5, 'Michael Sidorov', 451299, 'Voronez, ulitza Lenina');

INSERT INTO organization (user_id, name_org, address_org) VALUES
    (3, 'EC', 'New York, Mancheten'),
    (4, 'Lukoil', 'Moscow, Chistue Prudu');

INSERT INTO premises (type, address, square, name, price) VALUES
    ('flat', 'New York, Main street, build 42', 75.34, 'Main Hotel', 5000.00),
    ('hostel', 'Moskovskay oblast, Stupino, build 34', 39.11, 'U dady Stepu', 20.00),
    ('hotel', 'Moscow, red square, GUM', 120, 'U Putina', 3000.00);

INSERT INTO event (type, rent_cost) VALUES
    ('birthday', 75.34::money),
    ('corporativ', 39.11::money),
    ('wedding', 2000.00::money),
    ('happy end',200.00::money),
    ('happy start', 500.00::money),
    ('open store', 100.00::money),
    (300.00::money, 'meeting');

INSERT INTO rental_agreement (event_id, premises_id) VALUES
    (2, 1),
    (4, 1),
    (6, 2),
    (2, 3),
    (2, 2),
    (1, 1);

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
    ('horse ride', 15.00),
    ('minibus', 100.00::money),
    ('karaoke', 50.00::money),
    ('group invite', 20.00::money),
    ('toast-master', 120.00::money);

INSERT INTO possible_service (service_id, event_id) VALUES
    (1, 2),
    (2, 1),
    (1, 1),
    (1, 3),
    (1, 6),
    (5, 5),
    (5, 6),
    (5, 4),
    (6, 3);

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

CALL push_service_in_contract(1,1, 'OK');
CALL push_service_in_contract(2, 1,'OK');
CALL push_service_in_contract(7, 2, 'OK');
CALL push_service_in_contract(5, 5, 'OK');

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

CALL registration_paydoc(-1,3,4,2000.00::money,'OK');
