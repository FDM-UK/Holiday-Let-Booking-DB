/* 
The Holidays Lets Database is designed to manage holiday accomadation, allowing hosts to list their properties, and guests to book stays.
It allows the hosts to manage their properties and view their revenue.
Guests can manage their bookings and payments.
*/

CREATE DATABASE holiday_lets ;

USE holiday_lets ;

-- create tables for Users, Properties, Bookings and Payments

CREATE TABLE Users (
    user_id INT(4) AUTO_INCREMENT PRIMARY KEY,
	first_name  VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    UserType ENUM('Guest', 'Host') NOT NULL
);


INSERT INTO Users (first_name, last_name, user_email, phone, UserType)
VALUES ('Sandra', 'Dee', 'SandyD@netbox.com', '05700 123456', 'Guest'),
       ('Dennis', 'Menance', 'DMan@hmail.co.uk', '04678 987654', 'Host'),
       ('Saoirse', 'Devlin', 'MyHols@holiday.com', '09834 874121', 'Guest'),
       ('Ann', 'Cleaves', 'Arragon@jMail.net', '04310 953046', 'Guest'),
       ('George', 'Michaels', 'Notham@neetbox.com', '08787 655231', 'Host'),
       ('Elizabeth', 'Tudor', 'Queenie@royal.co.uk', '09321 558814', 'Host'),
       ('Rebecca', 'Van Helsing', 'vamp1234@jmail.net', '01919 666888', 'Guest'),
       ('Grayson', 'Waller', 'fightnight@holiday.com', '04366 99134', 'Host');


SELECT 
    *
FROM
    Users;


CREATE TABLE properties (
    property_id INT(5) ZEROFILL AUTO_INCREMENT PRIMARY KEY,
    property_name VARCHAR(100) NOT NULL,
    property_location VARCHAR(255) NOT NULL,
    bedrooms INT NOT NULL CHECK (bedrooms > 0),
    bathrooms INT NOT NULL CHECK (bathrooms > 0),
    price_per_night DECIMAL(10 , 2 ) CHECK (price_per_night > 0),
    host_id INT NOT NULL,
    FOREIGN KEY (host_id)
        REFERENCES Users (user_id)
);

-- Create a proceadure that allows properties to be added 
-- The Host's User_ID must be defined as 'Host' in the UserType in Users Table

DELIMITER //
CREATE PROCEDURE insert_property (
IN prop_name VARCHAR(100), 
IN prop_loc VARCHAR(255), 
IN prop_beds INT, 
IN prop_bath INT, 
IN prop_price DECIMAL(10, 2), 
IN prop_host INT
) 
BEGIN 
DECLARE user_type VARCHAR(10);-- check if the HostID exsists and is a 'Host'

SELECT 
    UserType
INTO user_type FROM
    Users
WHERE
    user_id = prop_host; 
    IF user_type <> 'Host' THEN -- brings up a specific error message

  SELECT 'Error: host_id must belong to a user with UserType = Host' AS MESSAGE; 
  ELSE -- inserts data INTo the table

  INSERT INTO properties (property_name, property_location, bedrooms, bathrooms, price_per_night, host_id)
  VALUES (prop_name,
          prop_loc,
          prop_beds,
          prop_bath,     
          prop_price,
          prop_host); END IF; 
END//
DELIMITER ;

CALL insert_property('The Hayloft', 'Peak District, UK', 2, 2, 80.00, 6);

-- test it's worked

SELECT 
    *
FROM
    properties;

CALL insert_property('The Old Barn', 'Lake District, UK', 3, 1, 105.50, 7);
CALL insert_property('The Priory', 'Oxford, UK', 4, 2, 155.75, 5);
CALL insert_property('Outback Ridge', 'New South Wales, Austrailia', 6, 4, 385.00, 8);
CALL insert_property('No. 1 The Mews', 'London, UK', 2, 1, 275.50, 2);
CALL insert_property('The Old Barn', 'Lake District, UK', 3, 1, 105.50, 6);
CALL insert_property("Heidi's Hideaway", 'Grindlewald, Switzerland', 1, 1, 90.00, 5);
CALL insert_property('Tower View', 'Paris, France', 3, 2, 300, 2);
CALL insert_property('Opera Terrace', 'Sydney, Austrailia', 2, 3, 156.80, 8);


SELECT 
    *
FROM
    properties;


CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT UNSIGNED NOT NULL,
    guest_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10 , 2 ) NOT NULL CHECK (total_price > 0),
    booking_status ENUM('Pending', 'Confirmed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (property_id)
        REFERENCES properties (property_id),
    FOREIGN KEY (guest_id)
        REFERENCES Users (user_id)
)  AUTO_INCREMENT=5000;


SELECT 
    *
FROM
    bookings;

-- CREATE a proceadure to automatically work out total cost when booking

DELIMITER //
CREATE PROCEDURE insert_bookings(
	IN prop_id INT, 
    IN guestID INT, 
    IN check_in date, 
    IN check_out date
    ) 
    
BEGIN 
	DECLARE num_nights INT; 
    DECLARE PricePerNight DECIMAL(10, 0); 
    DECLARE total DECIMAL(10, 2);
SET num_nights = DATEDIFF(check_out, check_in); -- define the number of nights stayed
SELECT 
    price_per_night
INTO PricePerNight FROM
    properties
WHERE
    property_id = prop_id;

  SET total = num_nights * PricePerNight; -- work out the total cost
  INSERT INTO bookings (property_id, guest_id, check_in_date, check_out_date, total_price, booking_status)
VALUES (prop_id,
        guestID,
        check_in,
        check_out,
        total,
        'Pending'); -- default as 'Pending' until Host confirms booking
END//
DELIMITER ;

CALL insert_bookings(3, 2, '2025-04-19', '2025-04-25');


SELECT 
    *
FROM
    bookings;

CALL insert_bookings(8, 2, '2025-04-25', '2025-04-30');
CALL insert_bookings(7, 1, '2025-07-13', '2025-07-18');
CALL insert_bookings(2, 3, '2025-05-27', '2025-06-1');
CALL insert_bookings(5, 7, '2025-08-03', '2025-08-05');
CALL insert_bookings(4, 8, '2025-11-20', '2025-11-23');
CALL insert_bookings(1, 4, '2025-12-20', '2025-12-27');
CALL insert_bookings(2, 6, '2025-06-01', '2025-06-05');
CALL insert_bookings(6, 5, '2025-08-04', '2025-08-10');
CALL insert_bookings(5, 1, '2025-10-21', '2025-10-25');
CALL insert_bookings(7, 3, '2025-09-04', '2025-09-05');
CALL insert_bookings(4, 7, '2025=12=28', '2026=01-02');
CALL insert_bookings(8, 5, '2025-10-28', '2025-11-04');
CALL insert_bookings(1, 1, '2025-12-29', '2026-12-01');


-- QUERY DEMO - TABLE CORRECTION 
-- An error was made when booking 5013 was made - the checkout date says December 2026 instead of January 2026
-- correct check_out_date error in bookings table

UPDATE bookings 
SET 
    check_out_date = '2026-01-01'
WHERE
    booking_id = 5013;

-- correct total price now date has been changed

UPDATE bookings 
SET 
    total_price = (DATEDIFF(check_out_date, check_in_date) * (SELECT 
            price_per_night
        FROM
            properties
        WHERE
            properties.property_id = bookings.property_id))
WHERE
    booking_id = 5013;


CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_method ENUM('Card', 'Paypal', 'Apple Pay', 'Google Pay') DEFAULT 'Card',
    total_paid DECIMAL(10 , 2 ) NOT NULL CHECK (total_paid >= 0),
    FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id)
)  AUTO_INCREMENT=001;

-- 	All bookings are made with a 10% deposit
-- insert all bookings with 10% deposit paid

INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Apple Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5000;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Apple Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5001;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Card',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5002;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'PayPal',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5003;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Google Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5004;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Card',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5005;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'PayPal',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5006;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Card',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5007;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Apple Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5008;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Card',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5009;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'PayPal',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5010;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Google Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5011;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'Apple Pay',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5012;


INSERT INTO payments (booking_id, payment_method, total_paid)
SELECT booking_id,
       'card',
       total_price * 0.1
FROM bookings
WHERE booking_id = 5013;


SELECT 
    *
FROM
    payments;
    

-- create view of bookings for each Proprty Host

CREATE VIEW vw_host_bookings AS
    SELECT 
        b.booking_id,
        b.property_id,
        b.check_in_date,
        b.check_out_date,
        p.host_id
    FROM
        bookings AS b
            JOIN
        properties AS p ON b.property_id = p.property_id;

-- view indiviual hosts bookings

SELECT * FROM vw_host_bookings WHERE host_id = 2;
SELECT * FROM vw_host_bookings WHERE host_id = 5;
SELECT * FROM vw_host_bookings WHERE host_id = 6;
SELECT * FROM vw_host_bookings WHERE host_id = 8;

-- The hosts feed bcak that, whilst the view is useful, they would like more information included
-- amend the View

CREATE OR REPLACE VIEW vw_host_bookings AS
    SELECT 
        b.booking_id,
        p.property_id,
        p.property_name,
        b.check_in_date,
        b.check_out_date,
        b.total_price,
        b.booking_status,
        p.host_id,
        u.first_name AS guest_first_name,
        u.last_name AS guest_last_name,
        u.user_email AS guest_email,
        (SELECT 
                SUM(b2.total_price)
            FROM
                bookings b2
                    JOIN
                properties p2 ON b2.property_id = p2.property_id
            WHERE
                p2.host_id = p.host_id) AS total_revenue,
        (SELECT 
                SUM(b2.total_price) * 0.85
            FROM
                bookings b2
                    JOIN
                properties p2 ON b2.property_id = p2.property_id
            WHERE
                p2.host_id = p.host_id) AS net_earnings
    FROM
        bookings AS b
            JOIN
        properties AS p ON b.property_id = p.property_id
            JOIN
        users AS u ON b.guest_id = u.user_id;

-- Host ID 8 wants to view their bookings and update the booking status

SELECT * FROM vw_host_bookings WHERE host_id = 8;

UPDATE bookings
SET booking_status = 'Confirmed'
WHERE booking_id IN (
    SELECT booking_id FROM vw_host_bookings WHERE host_id = 8
);

SELECT * FROM vw_host_bookings WHERE host_id = 8;

-- Create a bookings payment summery with date deadlines to pay the outstanding balance
-- Give the guest a payment schedule to split the cost into 3 payments

CREATE VIEW vw_all_booking_payments AS
SELECT 
    b.booking_id,
    b.guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.user_email AS guest_email,
    b.total_price,
    
    -- Amount already paid
    IFNULL(SUM(p.total_paid), 0) AS total_paid,
    
    -- Outstanding balance
    (b.total_price - IFNULL(SUM(p.total_paid), 0)) AS outstanding_payment,

    -- Amount & due date for second payment (50% due 3 months before check-in)
    (b.total_price * 0.5) AS second_payment_due,
    DATE_SUB(b.check_in_date, INTERVAL 3 MONTH) AS second_payment_due_date,

    -- Amount & due date for final payment (40% due 6 weeks before check-in)
    (b.total_price * 0.4) AS final_payment_due,
    DATE_SUB(b.check_in_date, INTERVAL 6 WEEK) AS final_payment_due_date

FROM bookings b
JOIN users u ON b.guest_id = u.user_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
GROUP BY b.booking_id, b.guest_id, u.first_name, u.last_name, u.user_email, b.total_price, b.check_in_date;

select * from vw_all_booking_payments;

-- Guest_id 6 wants to view her payment schedule and pay her 2nd payment

SELECT * FROM vw_all_booking_payments WHERE guest_id = 6;

update payments
set total_paid = total_paid + 312
	where booking_id = 5007;
  
-- She checks to see it has gone through
SELECT * FROM vw_all_booking_payments WHERE guest_id = 6;


-- Host ID 5 has sold their propertry in Switzerland
-- They need to cancel the booking and delete the property

UPDATE bookings
SET booking_status = 'Cancelled'
WHERE property_id = 6;

SELECT * FROM bookings;

DELETE FROM payments WHERE booking_id IN (SELECT booking_id FROM bookings WHERE property_id = 6);
delete from bookings where property_id = 6;
delete from properties where property_id = 6;

SELECT * FROM properties;

-- find the top 3 most expensive bookings

SELECT * FROM bookings ORDER BY total_price DESC LIMIT 3; 

-- find the properties with the most bookings

SELECT p.property_name, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN properties p ON b.property_id = p.property_id
GROUP BY p.property_name
ORDER BY total_bookings DESC;

-- find the booking with the longest stay

SELECT booking_id, DATEDIFF(check_out_date, check_in_date) AS duration
FROM bookings
ORDER BY duration DESC
LIMIT 1;

-- view all the bookings for guest_id 1

SELECT b.booking_id, p.property_name, b.check_in_date, b.check_out_date, b.total_price
FROM bookings AS b
JOIN properties AS p ON b.property_id = p.property_id
WHERE b.guest_id = 1;

