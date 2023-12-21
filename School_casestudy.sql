Create DATABASE School;
USE School;

CREATE TABLE CourseMaster (
    CID INT PRIMARY KEY,
    CourseName VARCHAR(40) NOT NULL,
    Category CHAR(1) NULL CHECK (Category IN ('B', 'M', 'A')),
    Fee SMALLMONEY NOT NULL CHECK (Fee >= 0)
);

CREATE TABLE StudentMaster (
    SID TINYINT PRIMARY KEY,
    StudentName VARCHAR(40) NOT NULL,
    Origin CHAR(1) NOT NULL CHECK (Origin IN ('L', 'F')),
    Type CHAR(1) NOT NULL CHECK (Type IN ('U', 'G'))
);
CREATE TABLE EnrollmentMaster (
    CID INT NOT NULL,
    SID TINYINT NOT NULL,
    DOE DATETIME NOT NULL,
    FWF BIT NOT NULL,
    Grade CHAR(1) CHECK (Grade IN ('O', 'A', 'B', 'C')),
    PRIMARY KEY (CID, SID),
    FOREIGN KEY (CID) REFERENCES CourseMaster(CID),
    FOREIGN KEY (SID) REFERENCES StudentMaster(SID)
);
-- Inserting data into CourseMaster table
INSERT INTO CourseMaster (CID, CourseName, Category, Fee)
VALUES
(1, 'Computer Science', 'A', 15000.00),
(2, 'Electrical Engineering', 'M', 12000.00),
(3, 'History', 'B', 8000.00),
(4, 'Mathematics', 'A', 13000.00),
(5, 'Physics', 'M', 11000.00),
(6, 'Economics', 'B', 8500.00),
(7, 'Chemistry', 'A', 12500.00),
(8, 'English Literature', 'B', 9000.00),
(9, 'Civil Engineering', 'M', 11500.00),
(10, 'Political Science', 'B', 8500.00);

INSERT INTO CourseMaster (CID, CourseName, Category, Fee)
VALUES
(11, 'Computer Science', 'B', 9000.00),
(12, 'Electrical Engineering', 'A', 14000.00),
(13, 'History', 'M', 10000.00),
(14, 'Mathematics', 'B', 9500.00),
(15, 'Physics', 'A', 13500.00);

-- Inserting data into StudentMaster table
INSERT INTO StudentMaster (SID, StudentName, Origin, Type)
VALUES
(1, 'Rahul Sharma', 'L', 'U'),
(2, 'Priya Patel', 'F', 'G'),
(3, 'Sandeep Singh', 'L', 'U'),
(4, 'Ananya Das', 'F', 'G'),
(5, 'Vikram Kumar', 'L', 'U'),
(6, 'Neha Gupta', 'F', 'G'),
(7, 'Arun Kapoor', 'L', 'U'),
(8, 'Mala Reddy', 'F', 'G'),
(9, 'Rajesh Mehta', 'L', 'U'),
(10, 'Sara Khan', 'F', 'G');


-- Inserting data into EnrollmentMaster table
INSERT INTO EnrollmentMaster (CID, SID, DOE, FWF, Grade)
VALUES
(1, 1, '2023-01-15 09:00:00', 0, 'A'),
(2, 2, '2023-02-20 10:30:00', 1, 'B'),
(3, 3, '2023-03-25 13:45:00', 0, 'C'),
(4, 4, '2023-04-10 14:15:00', 1, 'A'),
(5, 5, '2023-05-05 11:00:00', 0, 'B'),
(6, 6, '2023-06-12 09:30:00', 1, 'C'),
(7, 7, '2023-07-18 12:45:00', 0, 'B'),
(8, 8, '2023-08-22 15:00:00', 1, 'A'),
(9, 9, '2023-09-30 09:30:00', 0, 'C'),
(10, 10, '2023-10-05 10:15:00', 1, 'B');


--1.	List the course wise total no. of Students enrolled. Provide the information only for students of foreign origin and only if the total exceeds 10.
SELECT
    C.CourseName,
    COUNT(E.SID) AS TotalStudentsEnrolled
FROM
    CourseMaster C
JOIN
    EnrollmentMaster E ON C.CID = E.CID
JOIN
    StudentMaster S ON E.SID = S.SID
WHERE
    S.Origin = 'F'
GROUP BY
    C.CourseName
HAVING
    COUNT(E.SID) > 0;


--2.	List the names of the Students who have not enrolled for Java course.
SELECT * FROM CourseMaster WHERE CourseName NOT IN('Java','History');

--3.List the name of the advanced course where the enrollment by foreign students is the highest.	
SELECT TOP 1
    C.CourseName,
    C.TotalStudentsEnrolled
FROM (
    SELECT
        C.CourseName,
        COUNT(E.SID) AS TotalStudentsEnrolled
    FROM
        CourseMaster C
    JOIN
        EnrollmentMaster E ON C.CID = E.CID
    JOIN
        StudentMaster S ON E.SID = S.SID
    WHERE
        S.Origin = 'F'
    GROUP BY
        C.CourseName
) AS C
ORDER BY
    C.TotalStudentsEnrolled DESC;


--4.	List the names of the students who have enrolled for at least one basic course in the current month.
SELECT S.StudentName FROM StudentMaster S
JOIN
    EnrollmentMaster E ON S.SID = E.CID
JOIN
    CourseMaster C ON E.SID = C.CID
WHERE MONTH(E.DOE)=9; 

--5.	List the names of the Undergraduate, local students who have got a “C” grade in any basic course.
SELECT S.StudentName FROM StudentMaster S
JOIN
    EnrollmentMaster E ON S.SID = E.CID
WHERE S.Type='U' AND S.Origin='L' AND E.Grade='C';

--6.	List the names of the courses for which no student has enrolled in the month of May 2020.
SELECT DISTINCT C.CourseName
FROM CourseMaster C
LEFT JOIN EnrollmentMaster E ON C.CID = E.CID AND E.DOE BETWEEN '2020-05-01' AND '2020-05-31'
WHERE E.CID IS NULL;


--7.
SELECT
    C.CourseName,
    COUNT(E.SID) AS NumberOfEnrollments,
    CASE
        WHEN COUNT(E.SID) > 50 THEN 'High'
        WHEN COUNT(E.SID) >= 20 AND COUNT(E.SID) <= 50 THEN 'Medium'
        ELSE 'Low'
    END AS Popularity
FROM
    CourseMaster C
JOIN
    EnrollmentMaster E ON C.CID = E.CID
GROUP BY
    C.CourseName;


--8.	List the most recent enrollment details with information on Student Name, Course name and age of enrollment in days.
SELECT
    S.StudentName,
    C.CourseName,
    E.DOE AS EnrollmentDate,
    DATEDIFF(DAY, E.DOE, GETDATE()) AS AgeOfEnrollmentInDays
FROM
    EnrollmentMaster E
JOIN
    StudentMaster S ON E.SID = S.SID
JOIN
    CourseMaster C ON E.CID = C.CID
WHERE
    E.DOE = (SELECT MAX(DOE) FROM EnrollmentMaster WHERE SID = E.SID);


--9.	List the names of the Local students who have enrolled for exactly 3 basic courses. 
SELECT
    S.StudentName
FROM
    StudentMaster S
JOIN
    EnrollmentMaster E ON S.SID = E.SID
JOIN
    CourseMaster C ON E.CID = C.CID
WHERE
    S.Origin = 'L' AND C.Category = 'B'
GROUP BY
    S.StudentName
HAVING
    COUNT(DISTINCT C.CID) = 3;

--10.	List the names of the Courses enrolled by all (every) students.
SELECT DISTINCT CourseName FROM CourseMaster;

--11.	For those enrollments for which fee have been waived, provide the names of students who have got ‘O’ grade.
SELECT
    S.StudentName
FROM
    StudentMaster S
JOIN
    EnrollmentMaster E ON S.SID = E.SID
WHERE
    E.FWF = 1 AND E.Grade = 'O';


--12.	List the names of the foreign, undergraduate students who have got grade ‘C’ in any basic course.
SELECT
    S.StudentName
FROM
    StudentMaster S
JOIN
    EnrollmentMaster E ON S.SID = E.SID
JOIN
    CourseMaster C ON E.CID = C.CID
WHERE
    S.Origin = 'F' AND S.Type = 'U' AND C.Category = 'B' AND E.Grade = 'C';

--13.
SELECT
    C.CourseName,
    COUNT(E.SID) AS TotalEnrollments
FROM
    CourseMaster C
JOIN
    EnrollmentMaster E ON C.CID = E.CID
WHERE
    MONTH(E.DOE) = MONTH(GETDATE()) AND YEAR(E.DOE) = YEAR(GETDATE())
GROUP BY
    C.CourseName;









