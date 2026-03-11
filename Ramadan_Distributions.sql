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




create table User_Master (
user_id int identity(1,1) primary key,
full_name varchar(100) not null,
gender varchar(15) check (gender in ('Male','Female')),
age int check (age >= 18),
phone varchar(11) unique,
address varchar(100) not null,
role varchar(20) check (role in ('Admin','Volunteer','Driver','Beneficiary'))
);



create table volunteer_skills (
skill_id int identity(1,1) primary key,
volunteer_id int not null,
skill_type varchar(50) check (skill_type in ('Cooking','Driving','Data Entry','food_distribution','packing')),
years_of_experience int check (years_of_experience >= 0),
foreign key (volunteer_id) references User_Master(user_id)

);


create table beneficiary_details (
beneficiary_id int identity(1,1) primary key,
user_id int not null,
family_members_count int check (family_members_count > 0),
poverty_score int check (poverty_score between 1 and 10),
last_received_date date  not null,
foreign key (user_id) references User_Master(user_id)

);



create table training_sessions (
session_id int identity(1,1) primary key,
session_name varchar(100) not null,
trainer_name varchar(100) not null,
session_date date not null

);

create table driver_training (
    driver_id int,
    session_id int,
    primary key (driver_id, session_id),
    foreign key (driver_id)references User_master(user_id),
    foreign key (session_id)references training_sessions(session_id)
);



insert into User_Master (full_name, gender, age, phone, address, role)
values
('Ahmed Ali','Male',30,'01012345678','Cairo','driver'),
('Sara Mohamed','Female',26,'01123456789','Giza','volunteer'),
('Omar Hassan','Male',27,'01234567890','Minya','beneficiary'),
('Mona Adel','Female',28,'01098765432','Alex','admin'),
('Mostafa Ali','Male',31,'01012345678','Fayoum','driver'),
('Reem Mohamed','Female',20,'01123456789','Giza','volunteer'),
('Esraa Hassan','Female',37,'01234567890','Sohag','volunteer'),
('Mona Mostafa','Female',25,'01098765432','Alex','admin');

select * from User_Master;


insert into volunteer_skills (volunteer_id, skill_type, years_of_experience)
values
(2,'cooking',3),
(2,'data_entry',2),
(3,'driving',4),
(1,'cooking',1),
(6,'food_distribution',2),
(4,'cooking',2),
(4,'data_entry',1),
(5,'driving',5);

select * from volunteer_skills;



insert into beneficiary_details (user_id, family_members_count, poverty_score, last_received_date)
values
(3,5,9,'2026-03-01'),
(4,4,8,'2026-03-03'),
(5,6,10,'2026-02-25'),
(6,3,7,'2026-03-02'),
(7,7,9,'2026-02-28'),
(8,5,8,'2026-03-04'),
(1,6,7,'2026-03-05'),
(2,6,9,'2026-03-01');

select * from beneficiary_details;


insert into training_sessions (session_name, trainer_name, session_date)
values
('safety first','captain ahmed','2026-03-05'),
('driving basics','captain mohamed','2026-03-10'),
('vehicle safety','captain ali','2026-03-12'),
('emergency response','captain hassan','2026-03-14'),
('route planning','captain mahmoud','2026-03-16'),
('food handling','captain ibrahim','2026-03-18'),
('team coordination','captain khaled','2026-03-20'),
('logistics management','captain sameh','2026-03-22');

select * from training_sessions;



insert into driver_training (driver_id, session_id)
values
(1,1),
(1,2),
(2,1),
(2,3),
(3,2),
(3,4),
(4,5),
(5,6);


select * from driver_training;




select * from User_Master;



select u.full_name, v.skill_type, v.years_of_experience
from User_Master u
join volunteer_skills v
on u.user_id = v.volunteer_id;



select user_id, family_members_count
from beneficiary_details
order by family_members_count desc;




select u.full_name
from User_Master u
where role = 'driver'
and u.user_id not in (
select driver_id
from driver_training dt
join training_sessions ts
on dt.session_id = ts.session_id
where ts.session_name = 'Safety First'
);




<<<<<<< HEAD

/*
CREATE TABLE beneficiary_details (
    beneficiary_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    family_members_count TINYINT NOT NULL CHECK (family_members_count >= 1),
    poverty_score TINYINT NOT NULL CHECK (poverty_score BETWEEN 1 AND 10),
    last_received_date DATE NULL,
    CONSTRAINT fk_beneficiary_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE volunteer_skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    volunteer_id INT NOT NULL,
    skill_type ENUM('Cooking','Driving','Data Entry') NOT NULL,
    years_of_experience TINYINT NOT NULL CHECK (years_of_experience >= 0),
    UNIQUE KEY uq_volunteer_skill (volunteer_id, skill_type),
    CONSTRAINT fk_skill_volunteer FOREIGN KEY (volunteer_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE training_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_name VARCHAR(150) NOT NULL,
    trainer_name VARCHAR(150) NOT NULL,
    session_date DATE NOT NULL
);



CREATE TABLE driver_training (
    driver_id INT NOT NULL,
    session_id INT NOT NULL,
    PRIMARY KEY (driver_id, session_id),
    CONSTRAINT fk_dt_driver FOREIGN KEY (driver_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dt_session FOREIGN KEY (session_id) REFERENCES training_sessions(session_id) ON UPDATE CASCADE ON DELETE CASCADE
);*/
=======
select u.full_name, b.poverty_score
from beneficiary_details b
join User_master u
on b.user_id = u.user_id
where b.poverty_score > 8;







GO
CREATE TRIGGER check_beneficiary_date
on beneficiary_details
instead of insert
as
begin

if exists (
select *
from beneficiary_details b
join inserted i
on b.user_id = i.user_id
where datediff(day, b.last_received_date, i.last_received_date) < 15
)

begin
print 'family cannot receive another box within 15 days'
rollback transaction
end

end
>>>>>>> 6a347e83e4d35a018e110dc75724ce0ee52bf69a
