-- ==========================================
-- INSERT STUDENT DATA
-- ==========================================

INSERT INTO STUDENTS VALUES
(SEQ_STUDENT.NEXTVAL, 'Aarav Sharma',
 'aarav@gmail.com', '9876543210', 'MCA', SYSDATE);

INSERT INTO STUDENTS VALUES
(SEQ_STUDENT.NEXTVAL, 'Priya Verma',
 'priya@gmail.com', '9876543211', 'MCA', SYSDATE);

INSERT INTO STUDENTS VALUES
(SEQ_STUDENT.NEXTVAL, 'Rahul Singh',
 'rahul@gmail.com', '9876543212', 'BCA', SYSDATE);

INSERT INTO STUDENTS VALUES
(SEQ_STUDENT.NEXTVAL, 'Ananya Gupta',
 'ananya@gmail.com', '9876543213', 'MBA', SYSDATE);

INSERT INTO STUDENTS VALUES
(SEQ_STUDENT.NEXTVAL, 'Kabir Mehta',
 'kabir@gmail.com', '9876543214', 'MCA', SYSDATE);


INSERT INTO ADMIN_USERS VALUES
(SEQ_ADMIN.NEXTVAL, 'Canteen Manager',
 'admin01', 'DEMO_HASH_001', SYSDATE);

INSERT INTO ADMIN_USERS VALUES
(SEQ_ADMIN.NEXTVAL, 'Food Supervisor',
 'supervisor01', 'DEMO_HASH_002', SYSDATE);

-- ==========================================
-- INSERT FOOD MENU
-- ==========================================

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Samosa', 'Snacks', 15, 100, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Veg Burger', 'Fast Food', 60, 40, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Masala Maggi', 'Fast Food', 40, 50, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Cold Coffee', 'Beverages', 50, 35, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Masala Chai', 'Beverages', 10, 100, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Veg Sandwich', 'Snacks', 45, 30, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'French Fries', 'Fast Food', 50, 25, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Paneer Roll', 'Snacks', 70, 20, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Chocolate Shake', 'Beverages', 65, 25, 'Y');

INSERT INTO FOOD_ITEMS VALUES
(SEQ_FOOD.NEXTVAL, 'Pizza Slice', 'Fast Food', 80, 15, 'Y');
COMMIT;

SELECT * FROM STUDENTS;
SELECT * FROM ADMIN_USERS;
SELECT
    FOOD_ID,
    FOOD_NAME,
    CATEGORY,
    PRICE,
    STOCK_QUANTITY,
    IS_AVAILABLE
FROM FOOD_ITEMS
ORDER BY FOOD_ID;

SELECT
    COUNT(*) AS TOTAL_FOOD_ITEMS,
    SUM(STOCK_QUANTITY) AS TOTAL_STOCK,
    SUM(PRICE * STOCK_QUANTITY) AS STOCK_VALUE
FROM FOOD_ITEMS;