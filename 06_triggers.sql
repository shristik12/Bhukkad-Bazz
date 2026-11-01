CREATE OR REPLACE TRIGGER TRG_FOOD_AVAILABILITY
BEFORE INSERT OR UPDATE OF STOCK_QUANTITY
ON FOOD_ITEMS
FOR EACH ROW
BEGIN
    IF :NEW.STOCK_QUANTITY <= 0 THEN
        :NEW.IS_AVAILABLE := 'N';
    ELSE
        :NEW.IS_AVAILABLE := 'Y';
    END IF;
END;
/


CREATE OR REPLACE TRIGGER TRG_ORDER_AUDIT
AFTER INSERT OR UPDATE OF ORDER_STATUS
ON ORDERS
FOR EACH ROW
BEGIN

    IF INSERTING THEN

        INSERT INTO ORDER_AUDIT (
            AUDIT_ID,
            ORDER_ID,
            ACTION_TYPE,
            OLD_STATUS,
            NEW_STATUS,
            ACTION_DATE
        )
        VALUES (
            SEQ_AUDIT.NEXTVAL,
            :NEW.ORDER_ID,
            'ORDER_CREATED',
            NULL,
            :NEW.ORDER_STATUS,
            SYSDATE
        );

    ELSIF UPDATING THEN

        IF NVL(:OLD.ORDER_STATUS, 'UNKNOWN')
           <> NVL(:NEW.ORDER_STATUS, 'UNKNOWN') THEN

            INSERT INTO ORDER_AUDIT (
                AUDIT_ID,
                ORDER_ID,
                ACTION_TYPE,
                OLD_STATUS,
                NEW_STATUS,
                ACTION_DATE
            )
            VALUES (
                SEQ_AUDIT.NEXTVAL,
                :NEW.ORDER_ID,
                'STATUS_UPDATED',
                :OLD.ORDER_STATUS,
                :NEW.ORDER_STATUS,
                SYSDATE
            );

        END IF;

    END IF;

END;
/