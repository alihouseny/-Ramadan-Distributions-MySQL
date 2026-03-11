SELECT * FROM warehouses;
SELECT * FROM food_categories;
SELECT * FROM inventory_items;
SELECT * FROM donations_log;

select * from User_Master;
select * from volunteer_skills;
select * from beneficiary_details;
select * from training_sessions;
select * from driver_training;


SELECT ii.name, ii.expiry_date
FROM inventory_items ii
JOIN food_categories fc ON ii.category_id = fc.category_id
JOIN warehouses w ON ii.warehouse_id = w.id
WHERE fc.food_type = 'Fresh'
AND w.name = 'Zagazig Warehouse'
AND ii.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 2 DAY);
SELECT org_type, SUM(amount_value) AS total_cash
FROM donations_log
WHERE donation_type = 'Cash'
AND org_type IN ('Company', 'Individual')
GROUP BY org_type;

INSERT INTO inventory_items (name, quantity_kg, warehouse_id, category_id, expiry_date) VALUES
('Test Dry', 100.00, 1, 1, DATE_ADD(CURDATE(), INTERVAL 2 DAY));

UPDATE inventory_items SET expiry_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY) WHERE name = 'Rice';
SELECT w.name, SUM(ii.quantity_kg) AS total_kg
FROM warehouses w
LEFT JOIN inventory_items ii ON w.id = ii.warehouse_id
GROUP BY w.name;

SELECT ii.name, fc.food_type, ii.expiry_date, DATEDIFF(ii.expiry_date, CURDATE()) AS days_to_expiry
FROM inventory_items ii
JOIN food_categories fc ON ii.category_id = fc.category_id
ORDER BY days_to_expiry ASC;

-- volunteers and their skills
SELECT u.full_name, v.skill_type, v.years_of_experience
FROM User_Master u
JOIN volunteer_skills v
ON u.user_id = v.volunteer_id;

-- drivers and training sessions
SELECT u.full_name, t.session_name
FROM driver_training d
JOIN User_Master u
ON d.driver_id = u.user_id
JOIN training_sessions t
ON d.session_id = t.session_id;

-- poor families
SELECT u.full_name, b.poverty_score
FROM beneficiary_details b
JOIN User_Master u
ON b.user_id = u.user_id
WHERE b.poverty_score > 8;
