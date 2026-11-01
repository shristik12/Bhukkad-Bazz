SET SERVEROUTPUT ON;

DECLARE
    CURSOR C_DAILY_SALES IS
        SELECT
            TRUNC(ORDER_DATE) AS SALES_DATE,
            COUNT(ORDER_ID) AS TOTAL_ORDERS,
            SUM(TOTAL_AMOUNT) AS TOTAL_SALES
        FROM ORDERS
        WHERE ORDER_STATUS <> 'CANCELLED'
        GROUP BY TRUNC(ORDER_DATE)
        ORDER BY TRUNC(ORDER_DATE);

    V_DATE DATE;
    V_ORDERS NUMBER;
    V_SALES NUMBER(10,2);

BEGIN
    DBMS_OUTPUT.PUT_LINE('================================');
    DBMS_OUTPUT.PUT_LINE(' BHUKKAD BAZZ - DAILY SALES');
    DBMS_OUTPUT.PUT_LINE('================================');

    OPEN C_DAILY_SALES;

    LOOP
        FETCH C_DAILY_SALES
        INTO V_DATE, V_ORDERS, V_SALES;

        EXIT WHEN C_DAILY_SALES%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Date: ' || TO_CHAR(V_DATE,'DD-MON-YYYY')
        );

        DBMS_OUTPUT.PUT_LINE(
            'Total Orders: ' || V_ORDERS
        );

        DBMS_OUTPUT.PUT_LINE(
            'Total Sales: Rs. ' || V_SALES
        );

        DBMS_OUTPUT.PUT_LINE('--------------------------------');
    END LOOP;

    IF C_DAILY_SALES%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No sales records found.');
    END IF;

    CLOSE C_DAILY_SALES;

END;
/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR C_ORDER_HISTORY IS
        SELECT
            S.STUDENT_NAME,
            O.ORDER_ID,
            F.FOOD_NAME,
            D.QUANTITY,
            D.PRICE_AT_ORDER,
            D.QUANTITY * D.PRICE_AT_ORDER AS ITEM_TOTAL
        FROM STUDENTS S
        JOIN ORDERS O
            ON S.STUDENT_ID = O.STUDENT_ID
        JOIN ORDER_DETAILS D
            ON O.ORDER_ID = D.ORDER_ID
        JOIN FOOD_ITEMS F
            ON D.FOOD_ID = F.FOOD_ID
        ORDER BY O.ORDER_ID;

    V_NAME STUDENTS.STUDENT_NAME%TYPE;
    V_ORDER_ID ORDERS.ORDER_ID%TYPE;
    V_FOOD FOOD_ITEMS.FOOD_NAME%TYPE;
    V_QTY ORDER_DETAILS.QUANTITY%TYPE;
    V_PRICE ORDER_DETAILS.PRICE_AT_ORDER%TYPE;
    V_TOTAL NUMBER(10,2);

BEGIN
    DBMS_OUTPUT.PUT_LINE('BHUKKAD BAZZ ORDER HISTORY');
    DBMS_OUTPUT.PUT_LINE('==========================');

    OPEN C_ORDER_HISTORY;

    LOOP
        FETCH C_ORDER_HISTORY
        INTO V_NAME, V_ORDER_ID, V_FOOD,
             V_QTY, V_PRICE, V_TOTAL;

        EXIT WHEN C_ORDER_HISTORY%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Student: ' || V_NAME ||
            ' | Order: ' || V_ORDER_ID
        );

        DBMS_OUTPUT.PUT_LINE(
            'Food: ' || V_FOOD ||
            ' | Quantity: ' || V_QTY
        );

        DBMS_OUTPUT.PUT_LINE(
            'Price: Rs. ' || V_PRICE ||
            ' | Total: Rs. ' || V_TOTAL
        );

        DBMS_OUTPUT.PUT_LINE('--------------------------');
    END LOOP;

    CLOSE C_ORDER_HISTORY;

END;
/

SET SERVEROUTPUT ON;

BEGIN
    UPDATE FOOD_ITEMS
    SET PRICE = PRICE
    WHERE CATEGORY = 'Snacks';

    DBMS_OUTPUT.PUT_LINE(
        'Rows affected: ' || SQL%ROWCOUNT
    );

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE(
            'Food records were found.'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'No food records found.'
        );
    END IF;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE(
            'No records were updated.'
        );
    END IF;

    IF NOT SQL%ISOPEN THEN
        DBMS_OUTPUT.PUT_LINE(
            'Implicit cursor is closed automatically.'
        );
    END IF;

    ROLLBACK;
END;
/
SELECT
    F.FOOD_NAME,
    SUM(D.QUANTITY) AS TOTAL_SOLD,
    SUM(D.QUANTITY * D.PRICE_AT_ORDER) AS REVENUE
FROM FOOD_ITEMS F
JOIN ORDER_DETAILS D
    ON F.FOOD_ID = D.FOOD_ID
JOIN ORDERS O
    ON D.ORDER_ID = O.ORDER_ID
WHERE O.ORDER_STATUS <> 'CANCELLED'
GROUP BY F.FOOD_NAME
ORDER BY TOTAL_SOLD DESC;