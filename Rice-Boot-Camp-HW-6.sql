USE sakila;

SELECT * FROM actor;
SELECT * FROM country;

/*1a. Display the first and last names of all actors from the table actor.*/
SELECT first_name, last_name FROM actor;
-------------------------------------------------------------------------------

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
SELECT CONCAT(first_name,' ',last_name) AS "Actor Name" FROM actor;
-------------------------------------------------------------------------------

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
SELECT actor_id,first_name,last_name
FROM actor
WHERE first_name LIKE 'Joe';
-------------------------------------------------------------------------------

/*2b. Find all actors whose last name contain the letters GEN:*/
SELECT actor_id,first_name,last_name
FROM actor
WHERE last_name LIKE '%GEN%';
-------------------------------------------------------------------------------

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
SELECT actor_id,first_name,last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name,first_name;
-------------------------------------------------------------------------------

/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
-------------------------------------------------------------------------------

/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).*/
ALTER TABLE actor
  ADD description BLOB;

-------------------------------------------------------------------------------
/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
ALTER TABLE actor
  DROP COLUMN description;

-------------------------------------------------------------------------------
/*4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name AS 'Last Names', count(last_name) AS 'Number of Last Names'
FROM actor
GROUP BY last_name;

-------------------------------------------------------------------------------
/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
SELECT last_name AS 'Last Names', count(last_name) AS 'Number of Last Names'
FROM actor
GROUP BY last_name
HAVING count(last_name)>=2;

-------------------------------------------------------------------------------
/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'; and last_name = 'WILLIAMS';

-------------------------------------------------------------------------------
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor
SET first_name = 'GROUPO'
WHERE first_name = 'HARPO';

-------------------------------------------------------------------------------
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it? Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html*/
SHOW CREATE TABLE address;
SELECT * FROM address;
-------------------------------------------------------------------------------
/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-------------------------------------------------------------------------------
/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/
SELECT * FROM payment;
SELECT first_name, last_name, SUM(amount) AS 'Total Rung Up'
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date between '2005-08-01 00:00:00' and '2005-08-31 23:59:59'
GROUP BY staff.staff_id;

-------------------------------------------------------------------------------
/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
SELECT title, count(actor_id) AS 'Number of Actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

-------------------------------------------------------------------------------
/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
SELECT title, count(inventory_id)
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE title = 'Hunchback Impossible'
GROUP BY film.film_id;

-------------------------------------------------------------------------------
/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:*/
SELECT first_name, last_name, SUM(amount) AS 'Total Paid'
FROM customer
LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY last_name;

-------------------------------------------------------------------------------
/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT * FROM language;
/*SELECT language_id
FROM language
WHERE name = 'English';*/

SELECT title
FROM film
WHERE language_id IN (
	SELECT language_id
	FROM language
	WHERE name = 'English'
)
AND (title LIKE 'K%' OR title LIKE 'Q%');

-------------------------------------------------------------------------------
/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
SELECT * FROM film_actor;
/*SELECT film_id
FROM film
WHERE title = 'Alone Trip'; 
This finds the film_id
*/

/*SELECT actor_id
FROM film_actor
WHERE film_id IN (
	SELECT film_id
	FROM film
	WHERE title = 'Alone Trip'
);
This takes the film_id and finds the actor_id
*/

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
		)
);

-------------------------------------------------------------------------------
/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
SELECT email, first_name, last_name
FROM customer
LEFT JOIN address ON customer.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id
WHERE country = 'Canada';

/* The country table only had city_id, which I could link to table city which had address_id and then link to customer 
*/

-------------------------------------------------------------------------------
/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/
SELECT * FROM film_category;
SELECT * FROM category;

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id IN (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
	)
);
-------------------------------------------------------------------------------
/*7e. Display the most frequently rented movies in descending order.*/
SELECT * FROM rental;

SELECT count(title), title
FROM rental
LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film ON inventory.film_id = film.film_id
GROUP BY title
ORDER BY count(title) DESC;
-------------------------------------------------------------------------------
/*7f. Write a query to display how much business, in dollars, each store brought in.*/
SELECT SUM(amount), store.store_id
FROM store
LEFT JOIN customer ON store.store_id = customer.store_id
LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY store.store_id;

/*I found that joining the tables and then finding the information was easier than trying to do subqueries*/

-------------------------------------------------------------------------------
/*7g. Write a query to display for each store its store ID, city, and country.*/
SELECT store.store_id, country, city
FROM store
LEFT JOIN address ON store.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id;

-------------------------------------------------------------------------------
/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT name, SUM(amount)
FROM category
LEFT JOIN film_category ON category.category_id = film_category.category_id
LEFT JOIN inventory ON film_category.film_id = inventory.film_id
LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id
LEFT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-------------------------------------------------------------------------------
/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW Top_genres AS
SELECT name, SUM(amount)
FROM category
LEFT JOIN film_category ON category.category_id = film_category.category_id
LEFT JOIN inventory ON film_category.film_id = inventory.film_id
LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id
LEFT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-------------------------------------------------------------------------------
/*8b. How would you display the view that you created in 8a?*/
SELECT * FROM Top_genres;

-------------------------------------------------------------------------------
/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW Top_genres;

-------------------------------------------------------------------------------





