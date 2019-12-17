USE COURSE
GO

-----------------------------------------------EXERCISE 1-----------------------------------------------
-----------------------------------------PROCEDURE INSERT INTO LEARNER TABLE-----------------------------------------------
CREATE PROCEDURE PR_InsertLearner
(
    @learner_ID  CHAR(10),
    @username  VARCHAR(20),
    @password  VARCHAR(12),
    @name  NVARCHAR(40), 
    @sex  VARCHAR(6),
    @birth_day  DATE,
    @email VARCHAR(50)
)
AS
BEGIN
    -- SET NOCOUNT ON turn off message (X row(s) affected)
    DECLARE @age INT
    SET @age = YEAR(GETDATE()) - YEAR(@birth_day)
    -- VALIDATE INPUT
    IF (LEN(@username) < 8 OR LEN(@password) < 8)
    BEGIN
        RAISERROR ('Username or password invalid. Length of username or password must be greater or equal 8', 11, 1)
        RETURN
    END

    IF NOT (@Sex = 'male' OR @Sex = 'female' OR @Sex = 'other')
    BEGIN
        RAISERROR ('Sex is invalid. Sex must be "male", "female" or "other"', 11, 2)
        RETURN
    END

    IF NOT @email LIKE '%_@%_._%'
    BEGIN
        RAISERROR ('Email is not valid', 11,3)
        RETURN
    END

    -- INSERT DATA INTO TABLE
    INSERT INTO Learner
    VALUES (@learner_ID, @username, @password, @name, @sex, @birth_day, @age, @email)
END
GO

--------------------------------------------PROCEDURE SHOW DATA LEARNER-----------------------------------------------
CREATE PROCEDURE PR_GetLearner(@age INT)
AS
BEGIN
    SELECT Learner_ID, Username, Name, Sex, Age, Birth_day, Email FROM Learner
    WHERE Age > @age
    ORDER BY Name 
END
GO

-------------------------------------------------EXERCISE 2-----------------------------------------------------
----------------------------------------------TRIGGER DELETE LEARNER--------------------------------------------
CREATE TRIGGER TR_DeleteLearner ON Learner
INSTEAD OF DELETE
AS 
BEGIN
    DECLARE @learner_ID CHAR(10)
    SELECT @learner_ID = d.Learner_ID FROM DELETED d
    -- DELETE INFO OF ENROLLED COURSE
    IF EXISTS(SELECT * FROM Enroll WHERE Learner_ID = @learner_ID)
    BEGIN
        UPDATE Enroll
        SET Active_ID = 1
        WHERE Learner_ID = @learner_ID

        DELETE FROM Enroll
        WHERE Learner_ID = @learner_ID
    END
    -- DELETE LEARNER
    DELETE FROM Learner
    WHERE Learner_ID = @learner_ID
    PRINT 'DELETED ON LEARNER'
END
GO


------------------------------------------- TRIGGER TRACK ACTION LEARNER-------------------------------------------
CREATE TRIGGER TR_TrackActionLearner
ON Learner
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @action as VARCHAR(10)
    DECLARE @learner_ID CHAR(10)
    DECLARE @learner_name NVARCHAR(40)
    SET @action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                        AND EXISTS(SELECT * FROM DELETED)
                        THEN 'UPDATE'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'INSERT'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'DELETE'  -- Set Action to Deleted.
                    END)
    IF @action IS NOT NULL
    BEGIN
        -- GETTING ID AND NAME
        IF  @action = 'DELETE'
        SELECT @learner_ID=d.Learner_ID, @learner_name=d.Name FROM DELETED d
        ELSE -- INSERT OR UPDATE
        SELECT @learner_ID=i.Learner_ID, @learner_name=i.Name FROM INSERTED i
        -- INSERT
        INSERT INTO Learner_Audit(Learner_ID, Learner_Name, Change_date, Action)
        VALUES(@learner_ID, @learner_name, GETDATE(), @action)
    END
END
GO

----------------------------------------------------EXERCISE 3--------------------------------------------
-- 1. GET LEARNER WITH SEX USE : WHERE, ORDER BY
CREATE PROCEDURE PR_GetLearnerWithSex
(   
    @sex VARCHAR(6)
)
AS
BEGIN
    IF (@sex = 'male' OR @sex = 'female' OR @sex = 'other')
    BEGIN
        SELECT * FROM Learner
        WHERE Sex = @sex
        ORDER BY Age
    END
END
GO


--2. GET LEARNERS OF COURSES USE: WHERE, ORDER BY, INNER JOIN
CREATE PROCEDURE PR_GetLearnerOfCourse
(
    @progress INT
)
AS
BEGIN
    IF (@progress >= 0 AND @progress <=100)
    BEGIN
        SELECT Ln.Name, Co.Title, En.Enroll_date, En.Progress, En.State
        FROM Learner AS Ln 
        INNER JOIN Enroll AS En ON Ln.Learner_ID = En.Learner_ID
        INNER JOIN Course As Co ON En.Course_ID = Co.Course_ID
        WHERE En.Progress >= @progress
        ORDER BY En.Progress DESC
    END
END
GO

--3. COURSE STATISTICS USE: AGGREGATE FUNCTION, GROUP BY, HAVING
CREATE PROCEDURE PR_CourseStatistics
(
    @number_learner INT
)
AS
BEGIN
    SELECT En.Course_ID, COUNT(*) AS Number_Learners, MAX(Progress) AS Max_Progress, MIN(Progress) AS Min_Progress
    FROM Enroll AS En
    WHERE En.State = 1
    GROUP BY En.Course_ID HAVING COUNT(*) > @number_learner
END
GO

--------------------------------------------------EXERCISE 4---------------------------------------------
-- GET LEARNER ENROLL IN THE TIME
CREATE FUNCTION FC_By_Time_Learner(@fromDate DATE, @toDate DATE)
RETURNS TABLE
AS
RETURN    
    SELECT Ln.Learner_ID, Ln.Name, Co.Title, En.Enroll_date, En.Progress
    FROM Learner AS Ln
    INNER JOIN Enroll AS En ON Ln.Learner_ID = En.Learner_ID
    INNER JOIN Course AS Co ON En.Course_ID = Co.Course_ID
    WHERE En.Enroll_date > @fromDate AND En.Enroll_date < @toDate
GO


--GET A NUMBER OF LEARNERS HAVE MOST PROGRESS
ALTER FUNCTION FC_Get_Best_Learner(@number INT)
RETURNS @result TABLE(
    Learner_ID CHAR(10),
    Name NVARCHAR(40),
    Title VARCHAR(100),
    Enroll_date DATE,
    Progress INT
)
AS
BEGIN
    DECLARE @learner_ID CHAR(10)
    DECLARE @name NVARCHAR(40)
    DECLARE @title VARCHAR(100)
    DECLARE @enroll_date DATE
    DECLARE @progress INT
    DECLARE @count INT
    SET @count = 0
    DECLARE Ln_Cursor CURSOR LOCAL FOR
        SELECT Ln.Learner_ID, Ln.Name, Co.Title, En.Enroll_date, En.Progress
        FROM Learner AS Ln 
        INNER JOIN Enroll AS En ON Ln.Learner_ID = En.Learner_ID
        INNER JOIN Course As Co ON En.Course_ID = Co.Course_ID
        ORDER BY En.Progress DESC
    
    OPEN Ln_Cursor
    FETCH NEXT FROM Ln_Cursor INTO @learner_ID, @name, @title, @enroll_date, @progress
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS(SELECT * FROM @result WHERE Title = @title) AND @count < @number
        BEGIN
            INSERT INTO @result
            VALUES(@learner_ID, @name, @title, @enroll_date, @progress)
            SET @count = @count + 1
        END
        IF @count = @number
        BEGIN
            CLOSE Ln_Cursor
            RETURN
        END
        FETCH NEXT FROM Ln_Cursor INTO @learner_ID, @name, @title, @enroll_date, @progress
    END
    CLOSE Ln_Cursor

    RETURN;
END
GO

-- GET LEARNER ENROLL IN THE TIME
SELECT * FROM FC_By_Time_Learner(DATEADD(DD,-1,GETDATE()), DATEADD(DD,1,GETDATE())) 
WHERE Progress > 50
GO
-- GET A NUMBER OF LEARNERS HAVE MOST PROGRESS
SELECT * FROM FC_Get_Best_Learner(3)
GO