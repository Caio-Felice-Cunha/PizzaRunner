##################### Cleaning and Preparing Tables #####################

-- There are many empty strings and fields filled with "null" texts. This will get in the way of our analyses, so let's turn these fields into nulls themselves.
-- NOTE: Good practices dictate that it is not advisable to change the original database, but create another table in another environment. However, in this case, for the sake of my computer's memory and also not to create countless environments, I will change the original table.

-- The tables that will receive treatment are:
-- * runner_orders;
-- * customer_orders;

# runner_orders
UPDATE runner_orders
SET 
	cancellation = nullif(nullif(cancellation, ''), 'null'),
	duration = nullif(nullif(duration, ''), 'null'),
    distance = nullif(nullif(distance, ''), 'null'),
    pickup_time = nullif(nullif(pickup_time, ''), 'null');

# customer_orders
UPDATE customer_orders
SET 
	exclusions = nullif(nullif(exclusions, ''), 'null'),
	extras = nullif(nullif(extras, ''), 'null');
    
-- Now I will make some changes in some fields of some tables so that I can perform some analyzes in the future. 
-- Below I will show the fields that will be changed and why:    

# From runner_orders table:
## The "distance" column has the letters "km" in the fields, which prevents calculating sums, as the field is recognized as a string.
## Then I will remove the "km" from the field and bring it to the column heading.

UPDATE runner_orders
SET distance = replace(distance, 'km', '');

ALTER TABLE runner_orders CHANGE distance distance_km FLOAT;

## The "duration" column has the letters "minute", "minutes" and "mins" in the fields, which prevents calculating sums, as the field is recognized as a string.
## Then I will remove the "minutes" from the field and bring it to the column heading.

UPDATE runner_orders
SET duration = replace(replace(replace(replace(duration, ' ', ''), 'minutes', ''), 'mins', ''), 'minute', '');

ALTER TABLE runner_orders CHANGE duration duration_min FLOAT;



-- In order to be able to carry out analyzes involving ingredients, and also to be able to relate the 'pizza_recipes' table, I will create another table that will divide the two lines of recipes into more lines so that a better analysis is possible

CREATE TABLE new_pizza_recipes AS
	SELECT 
		pizza_recipes.pizza_id,
		trim(j.topping) AS topping_id
	FROM pizza_recipes
		JOIN 
		json_table(trim(replace(json_array(pizza_recipes.toppings), ',', '","')),
					'$[*]' columns (topping varchar(50) PATH '$')) j ;
