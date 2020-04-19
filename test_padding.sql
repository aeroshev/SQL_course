INSERT INTO client (type) VALUES
    ('individual'),
    ('individual'),
    ('organization'),
    ('organization');

INSERT INTO premises (type, address, square, name, price) VALUES
    ('flat', 'New York, Main street, build 42', 75.34, 'Main Hotel', 5000.00),
    ('hostel', 'Moskovskay oblast, Stupino, build 34', 39.11, 'U dady Stepu', 20.00);

INSERT INTO event (premises_id, rent_cost) VALUES
    (1, 75.34),
    (2, 39.11);

INSERT INTO contract (user_id, event_id, type, quantity_guest, date_dissolve) VALUES
    (1, 1, 'birthday', 20, '1/8/2021');

INSERT INTO service (description, price) VALUES
    ('taxi to place event', 25.00),
    ('horse ride', 15.00);

INSERT INTO possible_service (service_id, event_id) VALUES
    (1, 2),
    (2, 1);