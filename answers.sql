-- Library Management System Database
-- Created by: Abrha Gebrehiwet
-- Date: 2025-09-25

-- Create the database
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- 1. Members table - Stores library member information
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    max_books_allowed INT DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Authors table - Stores book authors information
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Publishers table - Stores publisher information
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Categories table - Stores book categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- 5. Books table - Stores book information
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    edition VARCHAR(20),
    publication_year YEAR,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    pages INT,
    language VARCHAR(30) DEFAULT 'English',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- 6. Book-Authors junction table - Handles Many-to-Many relationship between books and authors
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- 7. Book copies table - Stores individual copies of books
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number INT NOT NULL,
    acquisition_date DATE NOT NULL,
    price DECIMAL(10,2),
    status ENUM('Available', 'Checked Out', 'Lost', 'Damaged', 'Under Maintenance') DEFAULT 'Available',
    location VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_book_copy (book_id, copy_number),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- 8. Loans table - Stores book lending information
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    late_fee DECIMAL(8,2) DEFAULT 0.00,
    loan_status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT
);

-- 9. Reservations table - Stores book reservation information
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME NOT NULL,
    reservation_status ENUM('Active', 'Fulfilled', 'Cancelled') DEFAULT 'Active',
    priority INT DEFAULT 1,
    expiry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 10. Fines table - Stores fine information for late returns or damages
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    loan_id INT NULL,
    fine_amount DECIMAL(8,2) NOT NULL,
    fine_date DATE NOT NULL,
    reason ENUM('Late Return', 'Book Damage', 'Book Lost', 'Other') NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    paid_date DATE NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL
);

-- 11. Staff table - Stores library staff information
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Audit log table - Tracks important system events
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    staff_id INT NULL,
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX idx_loans_member_status ON loans(member_id, loan_status);
CREATE INDEX idx_loans_due_date ON loans(due_date);
CREATE INDEX idx_book_copies_status ON book_copies(status);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_authors_name ON authors(last_name, first_name);
CREATE INDEX idx_reservations_status ON reservations(reservation_status);
CREATE INDEX idx_fines_status ON fines(payment_status);

-- Insert sample data for demonstration
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Imaginative literature including novels and short stories'),
('Science Fiction', 'Fiction based on imagined future scientific or technological advances'),
('Mystery', 'Fiction involving solving a crime or unusual event'),
('Biography', 'Accounts of peoples lives'),
('Science', 'Books about scientific topics'),
('History', 'Historical accounts and analysis');

INSERT INTO publishers (publisher_name, established_year) VALUES
('Penguin Random House', 2013),
('HarperCollins', 1817),
('Macmillan Publishers', 1843);

INSERT INTO authors (first_name, last_name, nationality) VALUES
('George', 'Orwell', 'British'),
('Isaac', 'Asimov', 'American'),
('Agatha', 'Christie', 'British'),
('Stephen', 'Hawking', 'British');

INSERT INTO books (isbn, title, publication_year, publisher_id, category_id, pages) VALUES
('978-0451524935', '1984', 1949, 1, 1, 328),
('978-0553293357', 'Foundation', 1951, 2, 2, 255),
('978-0062073485', 'Murder on the Orient Express', 1934, 2, 3, 256),
('978-0553380163', 'A Brief History of Time', 1988, 3, 5, 256);

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

INSERT INTO book_copies (book_id, copy_number, acquisition_date, status) VALUES
(1, 1, '2023-01-15', 'Available'),
(1, 2, '2023-02-20', 'Available'),
(2, 1, '2023-03-10', 'Checked Out'),
(3, 1, '2023-01-05', 'Available'),
(4, 1, '2023-04-15', 'Under Maintenance');

 