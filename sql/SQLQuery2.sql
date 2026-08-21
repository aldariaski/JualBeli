USE JualBeliDb;
GO

-- ============================================================
-- Users
-- ============================================================

CREATE TABLE Users (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt DATETIME2(7) NOT NULL
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Users
        PRIMARY KEY (Id)
);
GO


-- ============================================================
-- Products
-- ============================================================

CREATE TABLE Products (
    Id INT IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Price DECIMAL(30,2) NOT NULL,
    Image NVARCHAR(1000) NULL,
    Category NVARCHAR(100) NOT NULL,
    SellerName NVARCHAR(255) NOT NULL,
    SellerEmail NVARCHAR(320) NOT NULL
        DEFAULT '',

    CONSTRAINT PK_Products
        PRIMARY KEY (Id)
);
GO


-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE Orders (
    id INT IDENTITY(1,1) NOT NULL,
    email VARCHAR(255) NOT NULL,
    total_amount DECIMAL(30,2) NOT NULL,
    status VARCHAR(30) NOT NULL
        DEFAULT 'Pending',
    created_at DATETIME2(7) NOT NULL
        DEFAULT GETDATE(),

    CONSTRAINT PK_Orders
        PRIMARY KEY (id)
);
GO


-- ============================================================
-- OrderItems
-- ============================================================

CREATE TABLE OrderItems (
    id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(30,2) NOT NULL,

    CONSTRAINT PK_OrderItems
        PRIMARY KEY (id)
);
GO


-- ============================================================
-- CartItems
-- ============================================================

CREATE TABLE CartItems (
    Id INT IDENTITY(1,1) NOT NULL,
    UserEmail NVARCHAR(320) NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL
        DEFAULT 1,

    CONSTRAINT PK_CartItems
        PRIMARY KEY (Id)
);
GO