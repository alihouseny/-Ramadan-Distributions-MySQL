-- Active: 1772107779560@@127.0.0.1@3306@ramadadan_distributions
 CREATE DATABASE ramadadan_distributions;
use ramadadan_distributions;

CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    max_capacity DECIMAL(10, 2) NOT NULL,
    current_status ENUM('Open', 'Full', 'Maintenance') NOT NULL DEFAULT 'Open',
    supervisor_id INT
);

CREATE TABLE food_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    food_type ENUM('Dry','Fresh','Cooked') NOT NULL,
    required_storage_temperature DECIMAL(5,2) NOT NULL
);

CREATE TABLE inventory_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL CHECK (quantity_kg >= 0),
    warehouse_id INT NOT NULL,
    category_id INT NOT NULL,
    expiry_date DATE NOT NULL,
    CONSTRAINT fk_item_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE ON DELETE RESTRICT,  
    CONSTRAINT fk_item_category FOREIGN KEY (category_id) REFERENCES food_categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE donations_log (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(150) NOT NULL,
    amount_value DECIMAL(12,2) NOT NULL CHECK (amount_value > 0),
    donation_type ENUM('Cash','Food') NOT NULL,
    org_type ENUM('Individual','Company','NGO') NOT NULL
);

INSERT INTO warehouses (name, location, max_capacity, current_status, supervisor_id) VALUES
('Zagazig Warehouse','Zagazig, Sharkia',50000.00,'Open',1),
('Abu Hammad Warehouse','Abu Hammad, Sharkia',40000.00,'Open',1),
('Minya Al-Qamh Warehouse','Minya Al-Qamh,Sharkia',30000.00,'Open',1),
('Belbeis Warehouse','Belbeis, Sharkia',20000.00,'Maintenance',1)

INSERT INTO food_categories (category_id, food_type, required_storage_temperature) VALUES
('Dry Goods','Dry',25.00),
('Fresh Goods','Fresh',4.00),
('Cooked Meals','Cooked',10.00)


INSERT INTO inventory_items (name, quantity_kg, warehouse_id, category_id, expiry_date) VALUES
('Rice',3000.00,1,1,DATE_ADD(CURDATE(),INTERVAL 60 DAY)),  
('Lentils',1500.00,1,1,DATE_ADD(CURDATE(),INTERVAL 45 DAY)),  
('Fresh Tomatoes',400.00,1,2,DATE_ADD(CURDATE(),INTERVAL 1 DAY)),  
('Fresh Chicken',600.00,1,2,DATE_ADD(CURDATE(),INTERVAL 2 DAY)),  
('Fish',1000.00,3,1,DATE_ADD(CURDATE(),INTERVAL 90 DAY)),  
('Meat',200.00,2,3,DATE_ADD(CURDATE(),INTERVAL 1 DAY)); 


INSERT INTO donations_log (donor_name, amount_value, donation_type, org_type) VALUES
('El-Hadad Company',50000.00,'Cash','Company'),
('Zag-Eng',80000.00,'Cash','NGO'),
('Ali Elhadad',5000.00,'Cash','Individual'),
('Ali Housseny',2000.00,'Cash','Individual'),
('El Zamalek',30000.00,'Cash','NGO'),
('Food Bank NGO',1000.00,'Food','NGO');



DELIMITER $$

CREATE TRIGGER trg_block_expired_item_shipment 
BEFORE UPDATE ON inventory_items 
FOR EACH ROW 
BEGIN 
    IF NEW.quantity_kg < OLD.quantity_kg AND OLD.expiry_date <= CURDATE() THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot ship expired food items.'; 
    END IF; 
END$$

CREATE TRIGGER trg_dry_box_expiry_check 
BEFORE INSERT ON inventory_items 
FOR EACH ROW 
BEGIN 
    DECLARE v_type ENUM('Dry','Fresh','Cooked'); 
    SELECT food_type INTO v_type FROM food_categories WHERE category_id = NEW.category_id; 
    IF v_type = 'Dry' AND DATEDIFF(NEW.expiry_date, CURDATE()) < 3 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Items expiring within 3 days cannot be assigned to Dry Boxes.'; 
    END IF; 
END$$

DELIMITER ;
