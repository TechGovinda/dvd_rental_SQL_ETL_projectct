select * from actor;
select * from address;
select * from category;
select * from city;
select * from country;
select * from customer;
select * from film;
select * from film_actor;
select * from inventory;
select * from language;
select * from payment;
select * from rental;
select * from staff;
select * from store;



CREATE TABLE dimDate
(
	date_key integer NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint NOT NULL,
	day smallint NOT NULL,
	week smallint NOT NULL,
	is_weekend boolean
);

select column_name,data_type from information_schema.columns where table_name = 'dimDate'

CREATE TABLE dimCustomer
(
	customer_key SERIAL PRIMARY KEY,
	customer_id smallint NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(45),
	address varchar(45) NOT NULL,
	address2 varchar(45) NOT NULL,
	district varchar(45) NOT NULL,
	city varchar(45) NOT NULL,
	country varchar(45) NOT NULL,
	postal_code varchar(10),
	phone varchar(20) NOT NULL,
	active smallint NOT NULL,
	create_date date NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);

CREATE TABLE dimMovie
(
	movie_key SERIAL PRIMARY KEY,
	film_id smallint NOT NULL,
	title varchar(256) NOT NULL,
	discription text,
	release_year year,
	language varchar(20) NOT NULL,
	original_language varchar(20),
	rental_duration smallint NOT NULL,
	length smallint NOT NULL,
	rating varchar(5) NOT NULL,
	special_Features varchar(60) NOT NULL
	
);

CREATE TABLE dimStore
(
	store_key SERIAL PRIMARY KEY,
	store_id smallint NOT NULL,
	address varchar(50),
	address2 varchar(20),
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(10),
	manager_first_name varchar(50) NOT NULL,
	manager_last_name varchar(50) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);
DROP Table dimStore




-- inserting data in dimDate table---
INSERT INTO dimDate
(date_key,date,year,quarter,month,day,week,is_weekend) 
SELECT
	DISTINCT(TO_CHAR(payment_date :: DATE, 'yyyMMDD')::integer) as date_key,
	date(payment_date) as date,
	EXTRACT(year from payment_date) as year,
	EXTRACT(quarter from payment_date) as quarter,
	EXTRACT(month from payment_date) as month,
	EXTRACT(day from payment_date) as day,
	EXTRACT(week from payment_date) as week,
	-- week start countfrom monday end to sunday so weekend days only count of 6th and 7th days of a week--
	CASE 
		WHEN EXTRACT (ISODOW FROM payment_date) IN (6,7) then true 
			else false 
	end as is_weekend 
from payment;

select * from dimDate;


-- insert data into dimCustomer table--
INSERT INTO dimCustomer
(customer_key,customer_id,first_name,last_name,email,address,address2,district,city,country,postal_code,phone,active,create_date,start_date,end_date)
SELECT 
	c.customer_id as customer_key,
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	cy.city,
	co.country,
	a.postal_code,
	a.phone,
	c.active,
	c.create_date,
	now() as start_date,
	now() as end_date
from customer c
JOIN address a ON (c.address_id=a.address_id)
JOIN city cy ON (a.city_id=cy.city_id)
JOIN country co ON (cy.country_id=co.country_id)
	
select * from dimCustomer
select * from address

-- insert value into dimMovie table--
INSERT INTO dimMovie
(
	movie_key,
	film_id,
	title,
	discription,
	release_year,
	language,
	original_language,
	rental_duration,
	length,
	rating,
	special_Features
	)
SELECT
	f.film_id as movie_key,
	f.film_id,
	f.title,
	f.description as discription,
	f.release_year,
	l.name as language,
	l.name as original_language,
	f.rental_duration,
	f.length,
	f.rating,
	f.special_features
from film f
JOIN language l ON (f.language_id=l.language_id)

select * from dimMovie


-- insert value into dimStore table--
INSERT INTO dimStore
(	
	store_key,
	store_id,
	address,
	address2,
	city,
	country,
	postal_code,
	manager_first_name,
	manager_last_name,
	start_date,
	end_date
)
SELECT
	s.store_id as store_key,
	s.store_id,
	a.address,
	a.address2,
	cy.city,
	co.country,
	a.postal_code,
	staff.first_name as manager_first_name,
	staff.last_name as manager_last_name,
	now()   as start_date,
	now() as end_date
from store s
JOIN staff  ON (s.manager_staff_id=staff.staff_id)
JOIN address a ON (staff.address_id=a.address_id)
JOIN city cy ON (a.city_id=cy.city_id)
JOIN country co ON (cy.country_id=co.country_id)

select * from dimStore




CREATE TABLE factSales
(
	sales_key SERIAL PRIMARY KEY,
	date_key integer REFERENCES dimDate (date_key),
	customer_key integer REFERENCES dimCustomer (customer_key),
	movie_key integer REFERENCES dimMovie (movie_key),
	store_key integer REFERENCES dimStore (store_key),
	sales_amount numeric
);
drop table factSales


-- insert value into factSales--
INSERT INTO factSales
(
	sales_key,
	date_key,
	customer_key,
	movie_key,
	store_key,
	sales_amount
)
select 
	r.rental_id as sales_key,
	DISTINCT(TO_CHAR(payment_date :: DATE, 'YYYYMMDD')::integer) as date_key,
	p.customer_id as customer_key,
	i.film_id as movie_key,
	i.store_id as store_key,
	p.amount as sales_amount
from rental r
JOIN payment p ON (r.rental_id=p.rental_id)
JOIN inventory i ON (i.inventory_id=r.inventory_id)


	
