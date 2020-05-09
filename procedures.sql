--Procedure of insert new payment--
CREATE OR REPLACE PROCEDURE registration_paydoc(IN id_paydoc integer = 0, IN id_contract integer = 0,
                                                IN id_user integer = 0, IN payable money = 0.0)
LANGUAGE plpgsql
AS $$
DECLARE
    already_paid money = 0.0;
    total_cost money = 0.0;
    event_contract integer = 0;
    paydoc_ integer = 0;
BEGIN
    IF id_contract < 1 THEN
        RAISE EXCEPTION 'Illegal id contract';
    END IF;
    IF (SELECT user_id FROM contract WHERE contract.contract_id = id_contract) <> id_user THEN
        RAISE EXCEPTION 'The contract does not belong to the customer';
    END IF;

    event_contract := (SELECT event_id FROM contract WHERE contract.contract_id = id_contract);
    total_cost := total_cost + (SELECT sum(price) FROM contract_service AS cs JOIN possible_service AS ps
        ON cs.service_id = ps.service_id AND cs.event_id = ps.event_id JOIN service AS ser
            ON ps.service_id = ser.service_id WHERE cs.contract_id = id_contract);
    total_cost := total_cost + (SELECT sum(rent_cost) FROM event WHERE event.event_id = event_contract);
    total_cost := total_cost + (SELECT sum(price) FROM event JOIN premises ON event.premises_id = premises.premises_id
        WHERE event.event_id = event_contract);
    total_cost := total_cost + (SELECT sum(fee) FROM event JOIN subsidiary_agreement AS sa ON
        event.event_id = sa.event_id JOIN star ON sa.star_id = star .star_id WHERE event.event_id = event_contract);

    IF id_paydoc < 1 THEN
        INSERT INTO paydoc (user_id, pay_date) VALUES (id_user, now());
        COMMIT;
        paydoc_ := (SELECT currval('paydoc_paydoc_id_seq'));
    ELSE
        paydoc_ := (SELECT paydoc_id FROM paydoc WHERE paydoc.paydoc_id = id_paydoc);
    END IF;

    already_paid := (SELECT sum(payed) FROM payment WHERE payment.contract_id = id_contract);
    IF already_paid IS NULL THEN
        already_paid := 0.0;
    END IF;

    IF payable > (total_cost - already_paid) THEN
        RAISE EXCEPTION 'Too much payment';
    END IF;

    INSERT INTO payment (paydoc_id, contract_id, payed) VALUES (paydoc_, id_contract, payable);
    COMMIT;
END;
$$;

--Create extra table--
CREATE TABLE invite (
    star_id serial NOT NULL PRIMARY KEY,
    last_update_date date NOT NULL DEFAULT current_date,
    qty_events integer NOT NULL DEFAULT 0,
    total_payments money NOT NULL DEFAULT CAST(0.00 as money)
);
--Procedure count of invite star--
CREATE OR REPLACE PROCEDURE count_invite_star(IN id_star integer = 0) LANGUAGE plpgsql
AS $$
DECLARE
    ref_sub_agr refcursor;
    tlp money;
    qty_et integer;
BEGIN
    OPEN ref_sub_agr SCROLL FOR SELECT count(*) AS qty_events, sum(fee) AS total_payments FROM subsidiary_agreement
        AS sa JOIN star ON sa.star_id = star.star_id WHERE sa.star_id = id_star GROUP BY sa.star_id;
    FETCH ref_sub_agr INTO qty_et, tlp;

    IF (SELECT star_id FROM invite WHERE invite.star_id = id_star) IS NULL THEN
        INSERT INTO invite (star_id, last_update_date, qty_events, total_payments) VALUES
            (id_star, now(), CASE WHEN qty_et IS NULL THEN 0 END, CASE WHEN tlp IS NULL THEN CAST(0.0 as money) END);
        COMMIT;
    ELSE
        UPDATE invite
        SET last_update_date = now(),
            qty_events = CASE WHEN qty_et IS NULL THEN 0 END,
            total_payments = CASE WHEN tlp IS NULL THEN CAST(0.0 as money) END
        WHERE
            invite.star_id = id_star;
        COMMIT;
    END IF;
END;
$$;