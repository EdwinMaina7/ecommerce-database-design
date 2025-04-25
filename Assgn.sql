CREATE DATABASE ECOMMERCE;
USE ECOMMERCE;

CREATE TABLE brand (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- PRODUCT CATEGORY
CREATE TABLE product_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- PRODUCT
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    brand_id INT,
    category_id INT,
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (category_id) REFERENCES product_category(category_id)
);


-- PRODUCT IMAGE
CREATE TABLE product_image (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);


-- COLOR
CREATE TABLE color (
    color_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


-- SIZE CATEGORY
CREATE TABLE size_category (
    size_category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- SIZE OPTION

CREATE TABLE size_option (
    size_option_id INT AUTO_INCREMENT PRIMARY KEY,
    value VARCHAR(50) NOT NULL,
    size_category_id INT NOT NULL,
    FOREIGN KEY (size_category_id) REFERENCES size_category(size_category_id)
);


-- PRODUCT VARIATION

CREATE TABLE product_variation (
    variation_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    color_id INT,
    size_option_id INT,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (color_id) REFERENCES color(color_id),
    FOREIGN KEY (size_option_id) REFERENCES size_option(size_option_id)
);


-- PRODUCT ITEM

CREATE TABLE product_item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    variation_id INT NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    stock_quantity INT NOT NULL,
    FOREIGN KEY (variation_id) REFERENCES product_variation(variation_id)
);


-- ATTRIBUTE TYPE

CREATE TABLE attribute_type (
    attribute_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- PRODUCT_ATTRIBUTE

CREATE TABLE `attribute_definitions` (
  `attribute_id`   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `attribute_name` VARCHAR(100)    NOT NULL UNIQUE,
  `data_type`      ENUM('int','decimal','varchar','text','date','json')
                    NOT NULL DEFAULT 'varchar',
  `created_at`     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE `product_attribute_values` (
  `product_id`     INT UNSIGNED  NOT NULL,
  `attribute_id`   INT UNSIGNED  NOT NULL,
  `value_int`      INT           NULL,
  `value_decimal`  DECIMAL(20,6) NULL,
  `value_varchar`  VARCHAR(255)  NULL,
  `value_text`     TEXT          NULL,
  `value_date`     DATE          NULL,
  `value_json`     JSON          NULL,
  `updated_at`     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`,`attribute_id`))
 ENGINE=InnoDB;

-- HOW TO USE

INSERT INTO attribute_definitions (attribute_name, data_type)
VALUES
  ('color',     'varchar'),
  ('weight',    'decimal'),
  ('release_at','date'),
  ('metadata',  'json');
   INSERT INTO attribute_definitions (attribute_name, data_type)
VALUES ('material', 'varchar');


  INSERT INTO product_attribute_values
  (product_id, attribute_id, value_varchar)
VALUES
  (123, 1, 'Red');

INSERT INTO product_attribute_values
  (product_id, attribute_id, value_decimal)
VALUES
  (123, 2, 1.75);

INSERT INTO product_attribute_values
  (product_id, attribute_id, value_json)
VALUES
  (123, 4, '{"size":"L","materials":["cotton","poly"]}');

   INSERT INTO product_attribute_values
  (product_id, attribute_id, value_varchar)
VALUES
  (123, 5, 'Cotton');

  
  SELECT
  ad.attribute_name,
  COALESCE(
    pav.value_int,
    pav.value_decimal,
    pav.value_varchar,
    pav.value_text,
    DATE_FORMAT(pav.value_date,'%Y-%m-%d'),
    JSON_PRETTY(pav.value_json)
  ) AS attribute_value
FROM product_attribute_values AS pav
JOIN attribute_definitions   AS ad
  ON pav.attribute_id = ad.attribute_id
WHERE pav.product_id = 123;

--- DONE WITH PRODUCT_ATTRIBUTE

--- ATTRIBUTE_CATEGORIES 

CREATE TABLE `attribute_categories` (
  `category_id`   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `category_name` VARCHAR(100)    NOT NULL UNIQUE,
  `description`   TEXT            NULL,
  `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE `attribute_category_map` (
  `attribute_id` INT UNSIGNED NOT NULL,
  `category_id`  INT UNSIGNED NOT NULL,
  PRIMARY KEY (`attribute_id`, `category_id`),
  FOREIGN KEY (`attribute_id`)
    REFERENCES `attribute_definitions`(`attribute_id`)
      ON DELETE CASCADE,
  FOREIGN KEY (`category_id`)
    REFERENCES `attribute_categories`(`category_id`)
      ON DELETE CASCADE
) ENGINE=InnoDB;

--- HOW TO USE
INSERT INTO attribute_categories (category_name, description)
VALUES
  ('Display',    'Attributes related to how the product appears'),
  ('Logistics',  'Weight, dimensions, shipping details'),
  ('Pricing',    'Any cost-related attributes'),
  ('Metadata',   'Extra info, tags, etc.');
  

  -- color → Display
INSERT INTO attribute_category_map (attribute_id, category_id)
VALUES (1, (SELECT category_id FROM attribute_categories WHERE category_name='Display'));

-- weight → Logistics
INSERT INTO attribute_category_map (attribute_id, category_id)
VALUES (2, (SELECT category_id FROM attribute_categories WHERE category_name='Logistics'));

-- release_at → Logistics
INSERT INTO attribute_category_map (attribute_id, category_id)
VALUES (3, (SELECT category_id FROM attribute_categories WHERE category_name='Logistics'));

-- metadata → Metadata
INSERT INTO attribute_category_map (attribute_id, category_id)
VALUES (4, (SELECT category_id FROM attribute_categories WHERE category_name='Metadata'));

SELECT
  ad.attribute_id,
  ad.attribute_name,
  ad.data_type
FROM attribute_definitions AS ad
JOIN attribute_category_map AS acm
  ON ad.attribute_id = acm.attribute_id
JOIN attribute_categories AS ac
  ON acm.category_id = ac.category_id
WHERE ac.category_name = 'Logistics';

--- DONE 
