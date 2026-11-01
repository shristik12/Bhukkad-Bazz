CREATE OR REPLACE PROCEDURE PLACE_ORDER (
    P_STUDENT_ID IN NUMBER,
    P_FOOD_ID    IN NUMBER,
    P_QUANTITY   IN NUMBER,
    P_ORDER_ID   OUT NUMBER,
    P_TOTAL      OUT NUMBER
)
IS
    V_STUDENT_ID NUMBER;
    V_PRICE      NUMBER(10,2);
    V_STOCK      NUMBER;
    V_AVAILABLE  CHAR(1);
BEGIN
    SAVEPOINT ORDER_START;

    -- Validate quantity
    IF P_QUANTITY <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Quantity must be greater than zero.');
    END IF;

    -- Check student
    BEGIN
        SELECT STUDENT_ID
        INTO V_STUDENT_ID
        FROM STUDENTS
        WHERE STUDENT_ID = P_STUDENT_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002,
                'Student does not exist.');
    END;

    -- Check food item and lock its row
    BEGIN
        SELECT PRICE, STOCK_QUANTITY, IS_AVAILABLE
        INTO V_PRICE, V_STOCK, V_AVAILABLE
        FROM FOOD_ITEMS
        WHERE FOOD_ID = P_FOOD_ID
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003,
                'Food item does not exist.');
    END;

    -- Check availability
    IF V_AVAILABLE = 'N' OR V_STOCK < P_QUANTITY THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Food unavailable or insufficient stock.');
    END IF;

    -- Generate order ID
    P_ORDER_ID := SEQ_ORDER.NEXTVAL;

    -- Calculate bill
    P_TOTAL := V_PRICE * P_QUANTITY;

    -- Create order
    INSERT INTO ORDERS (
        ORDER_ID, STUDENT_ID,
        ORDER_DATE, TOTAL_AMOUNT, ORDER_STATUS
    )
    VALUES (
        P_ORDER_ID, P_STUDENT_ID,
        SYSDATE, P_TOTAL, 'PLACED'
    );

    -- Add order details
    INSERT INTO ORDER_DETAILS (
        DETAIL_ID, ORDER_ID, FOOD_ID,
        QUANTITY, PRICE_AT_ORDER
    )
    VALUES (
        SEQ_DETAIL.NEXTVAL, P_ORDER_ID,
        P_FOOD_ID, P_QUANTITY, V_PRICE
    );

    -- Update stock
    UPDATE FOOD_ITEMS
    SET STOCK_QUANTITY = STOCK_QUANTITY - P_QUANTITY,
        IS_AVAILABLE =
            CASE
                WHEN STOCK_QUANTITY - P_QUANTITY = 0 THEN 'N'
                ELSE 'Y'
            END
    WHERE FOOD_ID = P_FOOD_ID;

    -- Record inventory activity
    INSERT INTO INVENTORY_LOG (
        LOG_ID, FOOD_ID, QUANTITY_CHANGE,
        ACTION_TYPE, LOG_DATE, REMARKS
    )
    VALUES (
        SEQ_INVENTORY.NEXTVAL,
        P_FOOD_ID,
        -P_QUANTITY,
        'ORDER',
        SYSDATE,
        'Stock deducted for order ' || P_ORDER_ID
    );

    DBMS_OUTPUT.PUT_LINE('ORDER PLACED SUCCESSFULLY!');
    DBMS_OUTPUT.PUT_LINE('ORDER ID: ' || P_ORDER_ID);
    DBMS_OUTPUT.PUT_LINE('TOTAL BILL: Rs. ' || P_TOTAL);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO ORDER_START;
        RAISE;
END PLACE_ORDER;