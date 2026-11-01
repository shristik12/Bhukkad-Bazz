CREATE OR REPLACE PROCEDURE PROCESS_PAYMENT (
    P_ORDER_ID IN NUMBER,
    P_AMOUNT IN NUMBER,
    P_METHOD IN VARCHAR2,
    P_STATUS IN VARCHAR2
)
IS
    V_ORDER_ID NUMBER;
    V_EXPECTED_AMOUNT NUMBER(10,2);
    V_COUNT NUMBER;
    V_STATUS VARCHAR2(20);
BEGIN
    SAVEPOINT PAYMENT_START;

    -- Validate payment amount
    IF P_AMOUNT <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20031,
            'Payment amount must be greater than zero.'
        );
    END IF;

    -- Validate payment method
    IF UPPER(P_METHOD) NOT IN ('CASH', 'UPI', 'CARD') THEN
        RAISE_APPLICATION_ERROR(
            -20032,
            'Invalid payment method.'
        );
    END IF;

    -- Validate payment status
    IF UPPER(P_STATUS) NOT IN ('SUCCESS', 'FAILED') THEN
        RAISE_APPLICATION_ERROR(
            -20033,
            'Invalid payment status.'
        );
    END IF;

    -- Check order existence and lock it
    BEGIN
        SELECT ORDER_ID
        INTO V_ORDER_ID
        FROM ORDERS
        WHERE ORDER_ID = P_ORDER_ID
        AND ORDER_STATUS <> 'CANCELLED'
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20034,
                'Valid active order not found.'
            );
    END;

    -- Prevent duplicate payment
    SELECT COUNT(*)
    INTO V_COUNT
    FROM PAYMENTS
    WHERE ORDER_ID = P_ORDER_ID;

    IF V_COUNT > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20035,
            'Payment already exists for this order.'
        );
    END IF;

    -- Calculate expected payable amount
    V_EXPECTED_AMOUNT :=
        PKG_BILLING.GET_PAYABLE_AMOUNT(P_ORDER_ID);

    IF ROUND(P_AMOUNT, 2) <> V_EXPECTED_AMOUNT THEN
        RAISE_APPLICATION_ERROR(
            -20036,
            'Incorrect payment amount.'
        );
    END IF;

    V_STATUS := UPPER(P_STATUS);

    -- Insert payment record
    INSERT INTO PAYMENTS (
        PAYMENT_ID,
        ORDER_ID,
        PAYMENT_DATE,
        PAYMENT_AMOUNT,
        PAYMENT_METHOD,
        PAYMENT_STATUS
    )
    VALUES (
        SEQ_PAYMENT.NEXTVAL,
        P_ORDER_ID,
        SYSDATE,
        P_AMOUNT,
        UPPER(P_METHOD),
        V_STATUS
    );

    -- Update order only after successful payment
    IF V_STATUS = 'SUCCESS' THEN
        UPDATE ORDERS
        SET ORDER_STATUS = 'COMPLETED'
        WHERE ORDER_ID = P_ORDER_ID;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'PAYMENT ' || V_STATUS || '!'
    );

    DBMS_OUTPUT.PUT_LINE(
        'Amount: Rs. ' || P_AMOUNT
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO PAYMENT_START;
        RAISE;
END PROCESS_PAYMENT;
/