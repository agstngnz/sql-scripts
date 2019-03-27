USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT
  first_name,
  last_name
FROM  actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT
  UPPER(CONCAT(first_name,' ',last_name)) AS 'Actor Name'
FROM  actor;

-- 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT
  actor_id,
  first_name,
  last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT
  actor_id,
  first_name,
  last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. Order the rows by last name and first name
SELECT
  actor_id,
  first_name,
  last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY
  last_name,
  first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT
  country_id,
  country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. Create a column in the table actor named description and use the data type BLOB
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_name`;

-- 3b. Delete the description column
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT
  last_name,
  count(*) AS cnt
FROM actor
GROUP BY
  last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
  last_name,
  count(*) AS cnt
FROM actor
GROUP BY
  last_name
HAVING cnt >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
/*
SELECT *
FROM actor
WHERE first_name = 'GROUCHO' 
  AND last_name = 'WILLIAMS';
*/

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' 
  AND last_name = 'WILLIAMS';

/*
SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';
*/

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172
  AND first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT
  a.first_name,
  a.last_name,
  b.address
FROM staff a
JOIN address b
  ON a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT
  a.first_name,
  a.last_name,
  SUM(b.amount) AS 'Total Amount'
FROM staff a
JOIN payment b
  ON a.staff_id = b.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY
  a.first_name,
  a.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT
  a.title,
  COUNT(*) AS 'Actor Count'
FROM film a
JOIN film_actor b
  ON a.film_id = b.film_id
GROUP BY
  a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
  a.title,
  COUNT(*) AS 'Inventory Count'
FROM film a
JOIN inventory b
  ON a.film_id = b.film_id
WHERE a.title = 'Hunchback Impossible'
GROUP BY
  a.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
SELECT
  a.first_name,
  a.last_name,
  SUM(b.amount) AS 'Total Amount'
FROM customer a
JOIN payment b
  ON a.customer_id = b.customer_id
GROUP BY
  a.first_name,
  a.last_name
ORDER BY
  a.last_name,
  a.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT
  title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
  AND language_id IN (SELECT language_id FROM language WHERE name = 'English');
  
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT
  first_name,
  last_name
FROM actor
WHERE actor_id IN 
  (SELECT actor_id 
   FROM film_actor 
   WHERE film_id IN
     (SELECT film_id
      FROM film
      WHERE title = 'Alone Trip'
      )
   )
ORDER BY
  last_name,
  first_name;
  
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT
  a.first_name,
  a.last_name,
  a.email
FROM customer a
JOIN address b
  ON a.address_id = b.address_id
JOIN city c
  ON b.city_id = c.city_id
JOIN country d
  ON c.country_id = d.country_id
WHERE d.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT
  a.title
FROM film a
WHERE a.film_id IN
  (SELECT b.film_id
   FROM film_category b
   JOIN category c
     ON b.category_id = c.category_id
   WHERE c.name = 'Family'
   );

-- 7e. Display the most frequently rented movies in descending order.
SELECT
  a.title,
  COUNT(*) AS cnt_rental
FROM film a
JOIN inventory b
  ON a.film_id = b.film_id
JOIN rental c
  ON b.inventory_id = c.inventory_id
GROUP BY
  a.title
ORDER BY
  cnt_rental DESC,
  a.title;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
/*
SELECT
  SUM(p.amount)
FROM payment p;

SELECT
  c.store_id,
  SUM(p.amount) AS 'Total Sales'
FROM customer c
JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY
  c.store_id;

-- Shows differences between sales allocation based on the source of store_id. These are due to data integrity issues in table payment.
SELECT
  c.store_id as customer_store_id,
  s.store_id as staff_store_id,
  SUM(p.amount) AS 'Total Sales'
FROM customer c
JOIN payment p
  ON c.customer_id = p.customer_id
JOIN staff s
  ON p.staff_id = s.staff_id
GROUP BY
  c.store_id,
  s.staff_id;
*/

SELECT
  s.store_id,
  SUM(p.amount) AS 'Total Sales'
FROM staff s
JOIN payment p
  ON s.staff_id = p.staff_id
GROUP BY
  s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT
  a.store_id,
  c.city,
  d.country
FROM store a
JOIN address b
  ON a.address_id = b.address_id
JOIN city c
  ON b.city_id = c.city_id
JOIN country d
  ON c.country_id = d.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
/*
SELECT COUNT(*)
FROM film;

SELECT 
  COUNT(*),
  COUNT(DISTINCT a.film_id)
FROM film a
JOIN film_category b
  ON a.film_id = b.film_id;

SELECT COUNT(*), COUNT(distinct rental_id)
FROM payment;

SELECT COUNT(*)
FROM rental;

SELECT f.*
FROM payment f
LEFT JOIN rental g
  ON f.rental_id = g.rental_id
WHERE f.rental_id IS NULL;

SELECT g.*
FROM payment f
RIGHT JOIN rental g
  ON f.rental_id = g.rental_id
WHERE g.rental_id IS NULL;
*/

SELECT
  a.name AS Genre,
  SUM(f.amount) AS Total_Sales
FROM category a
JOIN film_category b
  ON a.category_id = b.category_id
JOIN film c
  ON b.film_id = c.film_id
JOIN inventory d
  ON c.film_id = d.film_id
JOIN rental e
  ON d.inventory_id = e.inventory_id
JOIN payment f
  ON e.rental_id = f.rental_id
GROUP BY
  a.name
ORDER BY
  Total_Sales DESC,
  Genre
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Genre AS
SELECT
  a.name AS Genre,
  SUM(f.amount) AS Total_Sales
FROM category a
JOIN film_category b
  ON a.category_id = b.category_id
JOIN film c
  ON b.film_id = c.film_id
JOIN inventory d
  ON c.film_id = d.film_id
JOIN rental e
  ON d.inventory_id = e.inventory_id
JOIN payment f
  ON e.rental_id = f.rental_id
GROUP BY
  a.name
ORDER BY
  Total_Sales DESC,
  Genre
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM Top_Genre;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Genre;

