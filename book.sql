-- Create the database
CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

-- Create tables
CREATE TABLE IF NOT EXISTS authors (
                                       author_id INT AUTO_INCREMENT PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL,
    birthdate DATE,
    nationality VARCHAR(50),
    UNIQUE (name, birthdate) -- Ensure uniqueness of authors to prevent duplicates
    );

CREATE TABLE IF NOT EXISTS books (
                                     book_id INT AUTO_INCREMENT PRIMARY KEY,
                                     title VARCHAR(200) NOT NULL,
    author_id INT,
    publication_date DATE,
    genre VARCHAR(50),
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE,
    INDEX (author_id), -- Index on author_id for query optimization
    INDEX (genre) -- Index on genre for query optimization
    );

CREATE TABLE IF NOT EXISTS readers (
                                       reader_id INT AUTO_INCREMENT PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    INDEX (email) -- Index on email for query optimization
    );

CREATE TABLE IF NOT EXISTS rentals (
                                       rental_id INT AUTO_INCREMENT PRIMARY KEY,
                                       reader_id INT,
                                       book_id INT,
                                       rental_date DATE,
                                       return_date DATE,
                                       FOREIGN KEY (reader_id) REFERENCES readers(reader_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    INDEX (reader_id), -- Index on reader_id for query optimization
    INDEX (book_id), -- Index on book_id for query optimization
    INDEX (rental_date) -- Index on rental_date for query optimization
    );

-- Insert data into authors table
INSERT INTO authors (name, birthdate, nationality) VALUES
                                                       ('J.K. Rowling', '1965-07-31', 'British'),
                                                       ('George R.R. Martin', '1948-09-20', 'American'),
                                                       ('J.R.R. Tolkien', '1892-01-03', 'British'),
                                                       ('Agatha Christie', '1890-09-15', 'British'),
                                                       ('Stephen King', '1947-09-21', 'American');

-- Insert data into books table
INSERT INTO books (title, author_id, publication_date, genre) VALUES
    ('Harry Potter and the Philosopher\'s Stone', 1, '1997-06-26', 'Fantasy'),
('A Game of Thrones', 2, '1996-08-06', 'Fantasy'),
('The Hobbit', 3, '1937-09-21', 'Fantasy'),
('Murder on the Orient Express', 4, '1934-01-01', 'Mystery'),
('The Shining', 5, '1977-01-28', 'Horror'),
('Harry Potter and the Chamber of Secrets', 1, '1998-07-02', 'Fantasy'),
('Harry Potter and the Prisoner of Azkaban', 1, '1999-07-08', 'Fantasy'),
('Harry Potter and the Goblet of Fire', 1, '2000-07-08', 'Fantasy'),
('A Clash of Kings', 2, '1998-11-16', 'Fantasy'),
('The Fellowship of the Ring', 3, '1954-07-29', 'Fantasy');

-- Insert data into readers table
INSERT INTO readers (name, email, phone) VALUES
('John Doe', 'johndoe@example.com', '123-456-7890'),
('Jane Smith', 'janesmith@example.com', '234-567-8901'),
('Alice Johnson', 'alicejohnson@example.com', '345-678-9012'),
('Bob Brown', 'bobbrown@example.com', '456-789-0123'),
('Charlie Davis', 'charliedavis@example.com', '567-890-1234');

-- Insert data into rentals table
INSERT INTO rentals (reader_id, book_id, rental_date, return_date) VALUES
(1, 1, '2024-06-01', NULL),
(2, 2, '2024-06-15', '2024-06-30'),
(3, 3, '2024-07-01', NULL),
(4, 4, '2024-07-05', NULL),
(5, 5, '2024-06-25', '2024-07-02');

-- Find all books of a specific genre (using a parameterized query)
PREPARE stmt_find_books_by_genre FROM
'SELECT * FROM books WHERE genre = ?';
SET @genre = 'Fantasy';
EXECUTE stmt_find_books_by_genre USING @genre;
DEALLOCATE PREPARE stmt_find_books_by_genre;

-- Find all books written by a specific author (using a parameterized query)
PREPARE stmt_find_books_by_author FROM
'SELECT * FROM books WHERE author_id = (SELECT author_id FROM authors WHERE name = ?)';
SET @auth_name = 'J.K. Rowling';
EXECUTE stmt_find_books_by_author USING @auth_name;
DEALLOCATE PREPARE stmt_find_books_by_author;

-- Find all readers who have borrowed books but have not yet returned them
PREPARE stmt_find_readers_with_unreturned_books FROM
'SELECT readers.name, readers.email, readers.phone FROM readers
JOIN rentals ON readers.reader_id = rentals.reader_id
WHERE rentals.return_date IS NULL';
EXECUTE stmt_find_readers_with_unreturned_books;
DEALLOCATE PREPARE stmt_find_readers_with_unreturned_books;

-- Find books that have been borrowed in the last month
PREPARE stmt_find_books_rented_last_month FROM
'SELECT books.title FROM books
JOIN rentals ON books.book_id = rentals.book_id
WHERE rentals.rental_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)';
EXECUTE stmt_find_books_rented_last_month;
DEALLOCATE PREPARE stmt_find_books_rented_last_month;

-- Find authors who have more than 3 books in the library
SELECT authors.name FROM authors
JOIN books ON authors.author_id = books.author_id
GROUP BY authors.name
HAVING COUNT(books.book_id) > 3;
