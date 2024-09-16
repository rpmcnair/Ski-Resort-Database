DROP TABLE PATRON cascade constraints;
DROP TABLE SkiInstructor cascade constraints;
DROP TABLE SkiLift cascade constraints;
DROP TABLE Class cascade constraints;
DROP TABLE Take cascade constraints;
DROP TABLE Rental2 cascade constraints;
DROP TABLE Rental3 cascade constraints;
DROP TABLE Rental4 cascade constraints;
DROP TABLE SkiRun cascade constraints;
DROP TABLE LiftTicket1 cascade constraints;
DROP TABLE LiftTicket2 cascade constraints;
DROP TABLE DayTicket cascade constraints;
DROP TABLE SeasonPass cascade constraints;
DROP TABLE Restaurant cascade constraints;
DROP TABLE EatsAt cascade constraints;
DROP TABLE Discount cascade constraints;
DROP TABLE Accesses cascade constraints;

CREATE TABLE Patron (
    patronID VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE SkiInstructor (
    employeeID VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    availability VARCHAR(50)
);

CREATE TABLE SkiLift (
    liftNumber VARCHAR(20) PRIMARY KEY,
    capacity INT,
    status VARCHAR(20)
);

CREATE TABLE Class (
    "Date" DATE,
    classLevel VARCHAR(20),
    capacity INT,
    instructorID VARCHAR(20),
    liftNumber VARCHAR(20),
    PRIMARY KEY ("Date", classLevel),
    FOREIGN KEY (instructorID) REFERENCES SkiInstructor(employeeID) 
        ON DELETE SET NULL,
    FOREIGN KEY (liftNumber) REFERENCES SkiLift(liftNumber) 
        ON DELETE SET NULL
);

CREATE TABLE Take (
    patronID VARCHAR(20),
    "Date" DATE,
    classLevel VARCHAR(20),
    PRIMARY KEY (patronID, "Date", classLevel),
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE,
    FOREIGN KEY ("Date", classLevel) REFERENCES Class("Date", classLevel) 
        ON DELETE CASCADE
);


CREATE TABLE Rental2 (
    patronID VARCHAR(20) PRIMARY KEY,
    height FLOAT,
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE
);

CREATE TABLE Rental3 (
    "Date" DATE,
    patronID VARCHAR(20),
    equipmentType VARCHAR(20),
    PRIMARY KEY (patronID, "Date"),
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE
);

CREATE TABLE Rental4 (
    patronID VARCHAR(20) PRIMARY KEY,
    footSize FLOAT,
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE
);

CREATE TABLE SkiRun (
    runNumber VARCHAR(20) PRIMARY KEY,
    difficulty VARCHAR(20),
    status VARCHAR(20)
);

CREATE TABLE LiftTicket2 (
    discountType VARCHAR(20) PRIMARY KEY,
    discountPercentage INT
);

CREATE TABLE LiftTicket1 (
    ticketNo VARCHAR(20) PRIMARY KEY,
    discountType VARCHAR(20),
    patronID VARCHAR(20),
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE,
    FOREIGN KEY (discountType) REFERENCES LiftTicket2(discountType) 
        ON DELETE CASCADE
);

CREATE TABLE DayTicket (
    ticketNo VARCHAR(20) PRIMARY KEY,
    "Date" DATE,
    FOREIGN KEY (ticketNo) REFERENCES LiftTicket1(ticketNo) 
        ON DELETE CASCADE
);

CREATE TABLE SeasonPass (
    ticketNo VARCHAR(20) PRIMARY KEY,
    season VARCHAR(20),
    FOREIGN KEY (ticketNo) REFERENCES LiftTicket1(ticketNo) 
        ON DELETE CASCADE
);

CREATE TABLE Restaurant (
    name VARCHAR(50) PRIMARY KEY,
    capacity INT,
    timing VARCHAR(50)
);

CREATE TABLE EatsAt (
    patronID VARCHAR(20),
    restaurantName VARCHAR(20),
    PRIMARY KEY (patronID, restaurantName),
    FOREIGN KEY (patronID) REFERENCES Patron(patronID) 
        ON DELETE CASCADE,
    FOREIGN KEY (restaurantName) REFERENCES Restaurant(name) 
        ON DELETE CASCADE
);

CREATE TABLE Discount (
    ticketNo VARCHAR(20),
    restaurantName VARCHAR(20),
    PRIMARY KEY (ticketNo, restaurantName),
    FOREIGN KEY (ticketNo) REFERENCES LiftTicket1(ticketNo) 
        ON DELETE CASCADE,
    FOREIGN KEY (restaurantName) REFERENCES Restaurant(name) 
        ON DELETE CASCADE
);

CREATE TABLE Accesses (
    runNumber VARCHAR(20),
    liftNumber VARCHAR(20),
    PRIMARY KEY (runNumber, liftNumber),
    FOREIGN KEY (runNumber) REFERENCES SkiRun(runNumber) 
        ON DELETE CASCADE,
    FOREIGN KEY (liftNumber) REFERENCES SkiLift(liftNumber) 
        ON DELETE CASCADE
);

alter session set nls_date_format = 'YYYY-MM-DD';

INSERT INTO Patron (patronID, name, email) VALUES ('P001', 'Jake John', 'jjohn2@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P002', 'Lili Henrik', 'lilihenn@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P003', 'Jasper Deasey', 'jasperstezy@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P004', 'Ella Krav', 'ellakrav@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P005', 'Blake Smith', 'smithblake@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P006', 'Emily Johnson', 'emily.j@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P007', 'Sarah Brown', 'sbrown@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P008', 'David Wilson', 'dave.r.wilson@gmail.com');
INSERT INTO Patron (patronID, name, email) VALUES ('P009', 'Jessica Martinez', 'jess.mrtnz@gmail.com');


INSERT INTO SkiInstructor (employeeID, name, availability) VALUES ('E001', 'Instructor One', 'Available');
INSERT INTO SkiInstructor (employeeID, name, availability) VALUES ('E002', 'Instructor Two', 'Available');
INSERT INTO SkiInstructor (employeeID, name, availability) VALUES ('E003', 'Instructor Three', 'Available');
INSERT INTO SkiInstructor (employeeID, name, availability) VALUES ('E004', 'Instructor Four', 'Available');
INSERT INTO SkiInstructor (employeeID, name, availability) VALUES ('E005', 'Instructor Five', 'Unavailable');

INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L001', 4, 'Operational');
COMMIT;
INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L002', 6, 'Operational');
COMMIT;
INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L003', 4, 'Under Maintenance'); 
COMMIT;
INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L004', 4, 'Operational');
COMMIT;
INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L005', 6, 'Operational');
COMMIT;
INSERT INTO SkiLift (liftNumber, capacity, status) VALUES ('L006', 4, 'Under Maintenance');
COMMIT;

INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-20', 'Beginner', 5, 'E001', 'L001');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-20', 'Intermediate', 10, 'E001', 'L002');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-21', 'Advanced', 10, 'E003', 'L004');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-22', 'Beginner', 10, 'E001', 'L001');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-22', 'Intermediate', 10, 'E004', 'L002');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-23', 'Intermediate', 3, 'E005', 'L005');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-27', 'Advanced', 5, 'E003', 'L002');
INSERT INTO Class ("Date", classLevel, capacity, instructorID, liftNumber) VALUES ('2024-12-27', 'Beginner', 10, 'E002', 'L004');

INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P001', '2024-12-20', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P003', '2024-12-20', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P006', '2024-12-20', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P007', '2024-12-20', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P001', '2024-12-22', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P002', '2024-12-21', 'Advanced');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P004', '2024-12-20', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P005', '2024-12-22', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P003', '2024-12-22', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P006', '2024-12-22', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P007', '2024-12-22', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P004', '2024-12-22', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P008', '2024-12-27', 'Advanced');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P002', '2024-12-27', 'Advanced');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P001', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P003', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P006', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P004', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P005', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P007', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P009', '2024-12-27', 'Beginner');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P009', '2024-12-23', 'Intermediate');
INSERT INTO Take (patronID, "Date", classLevel) VALUES ('P007', '2024-12-23', 'Intermediate');


INSERT INTO Rental3 ("Date", patronID, equipmentType) VALUES ('2024-12-20', 'P001', 'Skis+Boots');
INSERT INTO Rental3 ("Date", patronID, equipmentType) VALUES ('2024-12-22', 'P001', 'Skis+Boots');
INSERT INTO Rental3 ("Date", patronID, equipmentType) VALUES ('2024-12-20', 'P004', 'Skis+Boots');
INSERT INTO Rental3 ("Date", patronID, equipmentType) VALUES ('2024-12-22', 'P005', 'Boots');
INSERT INTO Rental3 ("Date", patronID, equipmentType) VALUES ('2024-12-27', 'P005', 'Boots');

INSERT INTO Rental2 (patronID, height) VALUES ('P001', 5.8);
INSERT INTO Rental2 (patronID, height) VALUES ('P004', 6.1);
INSERT INTO Rental2 (patronID, height) VALUES ('P005', 5.8);

INSERT INTO Rental4 (patronID, footSize) VALUES ('P001', 9.5);
INSERT INTO Rental4 (patronID, footSize) VALUES ('P004', 12.0);
INSERT INTO Rental4 (patronID, footSize) VALUES ('P005', 8.0);

INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R001', 'Green', 'Open');
COMMIT;
INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R002', 'Green', 'Open');
COMMIT;
INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R003', 'Black', 'Closed');
COMMIT;
INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R004', 'Double Black', 'Open');
COMMIT;
INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R005', 'Blue', 'Open');
COMMIT;
INSERT INTO SkiRun (runNumber, difficulty, status) VALUES ('R006', 'Black', 'Open');
COMMIT;

INSERT INTO LiftTicket2 (discountType, discountPercentage) VALUES ('None', 0);
INSERT INTO LiftTicket2 (discountType, discountPercentage) VALUES ('Student', 25);
INSERT INTO LiftTicket2 (discountType, discountPercentage) VALUES ('Senior', 30);

INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('D001', 'None', 'P001');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('D002', 'None', 'P002');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('D003', 'Student', 'P003');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('D004', 'None', 'P004');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('D005', 'Senior', 'P005');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('S001', 'Student', 'P006');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('S002', 'None', 'P007');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('S003', 'Senior', 'P008');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('S004', 'None', 'P009');
INSERT INTO LiftTicket1 (ticketNo, discountType, patronID) VALUES ('S005', 'None', 'P004');

INSERT INTO DayTicket (ticketNo, "Date") VALUES ('D001', '2024-12-20');
INSERT INTO DayTicket (ticketNo, "Date") VALUES ('D002', '2024-12-21');
INSERT INTO DayTicket (ticketNo, "Date") VALUES ('D003', '2024-12-22');
INSERT INTO DayTicket (ticketNo, "Date") VALUES ('D004', '2024-12-20');
INSERT INTO DayTicket (ticketNo, "Date") VALUES ('D005', '2024-12-21');

INSERT INTO SeasonPass (ticketNo, season) VALUES ('S001', '2024-2025');
INSERT INTO SeasonPass (ticketNo, season) VALUES ('S002', '2024-2025');
INSERT INTO SeasonPass (ticketNo, season) VALUES ('S003', '2024-2025');
INSERT INTO SeasonPass (ticketNo, season) VALUES ('S004', '2023-2024');
INSERT INTO SeasonPass (ticketNo, season) VALUES ('S005', '2023-2024');

INSERT INTO Restaurant (name, capacity, timing) VALUES ('Mountain Top', 100, '09:00-21:00');
INSERT INTO Restaurant (name, capacity, timing) VALUES ('Creekside', 75, '11:00-20:00');
INSERT INTO Restaurant (name, capacity, timing) VALUES ('Glacier Hut', 50, '09:00-15:00');
INSERT INTO Restaurant (name, capacity, timing) VALUES ('Peak View', 50, '09:00-15:00');
INSERT INTO Restaurant (name, capacity, timing) VALUES ('Round House', 250, '07:00-17:00');


INSERT INTO EatsAt (patronID, restaurantName) VALUES ('P002', 'Round House');
INSERT INTO EatsAt (patronID, restaurantName) VALUES ('P003', 'Creekside');
INSERT INTO EatsAt (patronID, restaurantName) VALUES ('P004', 'Mountain Top');
INSERT INTO EatsAt (patronID, restaurantName) VALUES ('P005', 'Creekside');
INSERT INTO EatsAt (patronID, restaurantName) VALUES ('P003', 'Glacier Hut');

INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S002', 'Mountain Top');
INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S002', 'Creekside');
INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S002', 'Glacier Hut');
INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S003', 'Mountain Top');
INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S003', 'Creekside');
INSERT INTO Discount (ticketNo, restaurantName) VALUES ('S003', 'Glacier Hut');

INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R001', 'L001');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R002', 'L001');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R006', 'L002');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R003', 'L003');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R004', 'L004');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R005', 'L005');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R002', 'L006');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R003', 'L006');
COMMIT;
INSERT INTO Accesses (runNumber, liftNumber) VALUES ('R001', 'L006');
COMMIT;
