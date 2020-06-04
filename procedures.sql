------------------------------------------------------------------------------------------------------------------------
--Procedure of insert new payment--
CREATE OR REPLACE PROCEDURE registration_paydoc(IN id_paydoc integer = 0, IN id_contract integer = 0,
                                                IN id_user integer = 0, IN payable money = 0.0,
                                                INOUT message character varying(50) = 'OK',
                                                INOUT return_value money = 0.0)
LANGUAGE plpgsql
AS $$
DECLARE
    already_paid money = 0.0;
    total_cost money = 0.0;
    paydoc_ integer = 0;
BEGIN
    IF (SELECT user_id FROM contract WHERE contract.contract_id = id_contract) <> id_user THEN
        message := 'The contract does not belong to the customer';
        RETURN;
    END IF;

    total_cost := (SELECT count_total_cost(id_contract));

    IF id_paydoc < 1 THEN
        INSERT INTO paydoc (user_id, pay_date) VALUES (id_user, now());
        COMMIT;
        paydoc_ := (SELECT currval('paydoc_paydoc_id_seq'));
    ELSE
        paydoc_ := (SELECT paydoc_id FROM paydoc WHERE paydoc.paydoc_id = id_paydoc AND paydoc.user_id = id_user);
        IF paydoc_ IS NULL THEN
            message := 'Paydoc do not belong to the customer';
            RETURN;
        END IF;
    END IF;

    already_paid := coalesce((SELECT sum(payed) FROM payment WHERE payment.contract_id = id_contract), 0.0::money);

    return_value := (total_cost - already_paid) - payable;

    INSERT INTO payment (paydoc_id, contract_id, payed) VALUES (paydoc_, id_contract, payable);
    COMMIT;
    message := 'OK';
END;
$$;

------------------------------------------------------------------------------------------------------------------------
--Create extra table--
CREATE TABLE invite (
    star_id serial NOT NULL PRIMARY KEY,
    last_update_date date NOT NULL DEFAULT current_date,
    qty_events integer NOT NULL DEFAULT 0,
    total_payments money NOT NULL DEFAULT 0.0::money
);
------------------------------------------------------------------------------------------------------------------------
--Procedure count of invite star--
CREATE OR REPLACE PROCEDURE count_invite_star(INOUT message character varying(20) = 'OK')
LANGUAGE plpgsql
AS $$
DECLARE
    ref_sub_agr refcursor;
    strID integer;
    smf money;
    fee_ money;
    qty_et integer;
BEGIN
    FOR strID, fee_ IN SELECT star_id, fee AS total_payments FROM star LOOP
        OPEN ref_sub_agr FOR SELECT count(*) AS qty_events FROM subsidiary_agreement
            WHERE star_id = strID;
        FETCH ref_sub_agr INTO qty_et;
        smf := fee_ * qty_et;

        IF (SELECT star_id FROM invite WHERE invite.star_id = strID) IS NULL THEN
            INSERT INTO invite (star_id, last_update_date, qty_events, total_payments) VALUES
                (strID, now(), coalesce(qty_et, 0), coalesce(smf, 0.0::money));
        ELSE
            UPDATE invite
            SET last_update_date = now(),
                qty_events = coalesce(qty_et, 0),
                total_payments = coalesce(smf, 0.0::money)
            WHERE
                invite.star_id = strID;
        END IF;
    END LOOP;

    message := 'OK';
END;
$$;
------------------------------------------------------------------------------------------------------------------------