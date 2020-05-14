CREATE TABLE client (
    user_id serial NOT NULL PRIMARY KEY,
    type character varying(12) NOT NULL
);

CREATE TABLE individual (
    user_id serial NOT NULL,
    name character varying(20) NOT NULL,
    number_id int NOT NULL UNIQUE CHECK(number_id > 0),
    place_residence character varying(200) NOT NULL,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES client ON DELETE CASCADE
);

CREATE TABLE organization (
    user_id serial NOT NULL,
    name_org character varying(100) NOT NULL UNIQUE,
    address_org character varying(200) NOT NULL,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES client ON DELETE CASCADE
);

CREATE TABLE paydoc (
    paydoc_id serial NOT NULL PRIMARY KEY,
    user_id serial NOT NULL,
    pay_date date NOT NULL DEFAULT current_date,
    FOREIGN KEY (user_id) REFERENCES client ON DELETE NO ACTION
);

CREATE TABLE premises (
    premises_id serial NOT NULL PRIMARY KEY,
    type character varying(20) NOT NULL,
    address character varying(40) NOT NULL UNIQUE,
    square numeric(5, 2) NOT NULL,
    name character varying(40) NOT NULL,
    price money NOT NULL CHECK (price >= 0.0::money)
);

CREATE TABLE event (
    event_id serial NOT NULL PRIMARY KEY,
    premises_id serial NULL,
    type character varying (40) NOT NULL,
    rent_cost money NOT NULL CHECK (rent_cost >= 0.0::money),
    FOREIGN KEY (premises_id) REFERENCES premises ON DELETE NO ACTION
);

CREATE TABLE contract (
    contract_id serial NOT NULL PRIMARY KEY,
    user_id serial NOT NULL,
    event_id serial NOT NULL,
    quantity_guest smallint NOT NULL CHECK (quantity_guest >= 0),
    date_contract date NOT NULL DEFAULT current_date,
    date_dissolve date NOT NULL CHECK (date_dissolve > date_contract),
    FOREIGN KEY (user_id) REFERENCES client ON DELETE NO ACTION,
    FOREIGN KEY (event_id) REFERENCES event ON DELETE NO ACTION
);

CREATE TABLE payment (
    paydoc_id serial NOT NULL,
    contract_id serial NOT NULL,
    payed money NOT NULL CHECK (payed >= 0.0::money),
    PRIMARY KEY (paydoc_id, contract_id),
    FOREIGN KEY (paydoc_id) REFERENCES paydoc ON DELETE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES contract ON DELETE CASCADE
);

CREATE TABLE service (
    service_id serial NOT NULL PRIMARY KEY,
    description character varying(100) NULL,
    price money NOT NULL CHECK (price >= 0.0::money)
);

CREATE TABLE possible_service (
    service_id serial NOT NULL,
    event_id serial NOT NULL,
    PRIMARY KEY (service_id, event_id),
    FOREIGN KEY (service_id) REFERENCES service ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event ON DELETE CASCADE
);

CREATE TABLE contract_service (
    string_id serial NOT NULL PRIMARY KEY,
    contract_id serial NOT NULL,
    service_id serial NOT NULL,
    event_id serial NOT NULL,
    FOREIGN KEY (contract_id) REFERENCES contract ON DELETE CASCADE,
    FOREIGN KEY (service_id, event_id) REFERENCES possible_service ON DELETE CASCADE
);

CREATE TABLE star (
    star_id serial NOT NULL PRIMARY KEY,
    real_name character varying(20) NOT NULL,
    nick_name character varying(20) NULL,
    fee money NOT NULL CHECK (fee >= 0.0::money),
    contacts character varying(40) NOT NULL
);

CREATE TABLE subsidiary_agreement (
    event_id serial NOT NULL,
    star_id serial NOT NULL,
    PRIMARY KEY (event_id, star_id),
    FOREIGN KEY (event_id) REFERENCES event ON DELETE CASCADE,
    FOREIGN KEY (star_id) REFERENCES star ON DELETE CASCADE
);