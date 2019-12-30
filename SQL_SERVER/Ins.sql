USE COURSE
GO

----------------------------------------------------------Insert Ins----------------------------------------------------
--Thủ tục Insert dữ liệu chứa thông tin về một Giảng viên(Instructor) gồm: mã giảng viên(Instructor_ID),tên tài khoản(username), mật khẩu(password), tên(name), giới tính(sex),ngày sinh,tuổi,bio,Field,Email
CREATE PROCEDURE InsertIns
    @Instructor_ID CHAR(10),
    @Username VARCHAR(20),
    @Password VARCHAR(12),
    @Name NVARCHAR(40),
    @Sex VARCHAR(6), 
    @Birth_day DATE,
    @Age INT, 
    @Bio TEXT,   
    @Field VARCHAR(50),
    @Email VARCHAR(50)
AS 
BEGIN
    IF (YEAR(GETDATE())-YEAR(@Birth_day)<22) 
    BEGIN PRINT 'Instructor must be older than 22 years old'
        RETURN
    END
INSERT INTO Instructor(Instructor_ID, Username, Password, Name, Sex, Birth_day, Age, Bio, Field, Email)
VALUES(@Instructor_ID, @Username, @Password, @Name, @Sex, @Birth_day, @Age, @Bio, @Field, @Email);
END
GO
----------------------------------------------------------EXERCISE 2----------------------------------------------------

------------------------------------------------------Trigger AfterInsert Ins------------------------------------------------
--  Mô tả chức năng: Mỗi khi thêm hoặc xóa dữ liệu trên bảng Instructor, số lượng Instructor sẽ tăng hoặc giảm trên bảng ThongKe
CREATE TRIGGER AID_Ins ON Instructor
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @count INT
    DECLARE @countCourse INT
    IF EXISTS(SELECT * FROM Inserted)
        BEGIN
            SELECT @count=COUNT(*) FROM INSERTED
            UPDATE ThongKe
            SET number_Ins = number_Ins + @count
        END
    IF EXISTS(SELECT * FROM DELETED)
        BEGIN
            SELECT @count=COUNT(*) FROM DELETED
            SELECT @countCourse = COUNT(*) FROM Course
            UPDATE ThongKE
            SET number_Ins = number_Ins - @count,
                number_Course = @countCourse
        END
END
GO
------------------------------------------------------Trigger BeforeDELETE Ins------------------------------------------------
-- Mô tả chức năng: Trước khi xóa một Instructor thì chúng ta cần xóa những Course của Instructor tạo ra trước.
CREATE TRIGGER BD_Ins ON Instructor
INSTEAD OF DELETE 
AS
BEGIN
    IF EXISTS(SELECT * FROM DELETED)
        BEGIN
            DECLARE @Id CHAR(10)
            DECLARE cursorDELETED CURSOR FOR
            SELECT Instructor_ID FROM DELETED
            OPEN cursorDELETED
            FETCH NEXT FROM cursorDELETED INTO @Id
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    DELETE FROM Course WHERE Ins_ID = @Id
                    DELETE FROM Instructor WHERE Instructor_ID = @Id
                    FETCH NEXT FROM cursorDELETED INTO @Id
                END
            CLOSE cursorDELETED
            DEALLOCATE cursorDELETED
        END
END
GO

----------------------------------------------------------EXERCISE 3----------------------------------------------------
--Truy xuất thông tin chi tiết của Giảng viên muốn xem
CREATE PROCEDURE getInfoIns
AS
BEGIN
    SELECT i.Instructor_ID, i.Name, i.Sex, i.Birth_day, i.Bio, i.Field, i.Email, r.Rank
    FROM Instructor i, Instructor_Rank r
    WHERE i.Instructor_ID =  r.Instructor_ID
    ORDER BY r.Rank ASC
END
GO
---------------------------------------------------------------------------
CREATE PROCEDURE sumCOST_Learner(@cost MONEY)
AS
BEGIN
    SELECT e.Learner_ID,SUM(c.Cost) AS sumCOST FROM Enroll e, Course c
    WHERE e.Course_ID = c.Course_ID
    GROUP BY e.Learner_ID
    HAVING SUM(c.Cost) >@cost
    ORDER BY SUM(c.Cost) DESC
END
GO
----------------------------------------------------------EXERCISE 4-----------------------------------------------------------
CREATE FUNCTION moneyFromCourse (@Course_ID CHAR(10))
RETURNS MONEY
AS
BEGIN
    IF ((SELECT LEN(@Course_ID)) >10)
    RETURN 0
    IF (NOT EXISTS(SELECT * FROM Course WHERE Course_ID=@Course_ID))
    RETURN 0
    DECLARE @moneyFromCourse MONEY = 0
    SELECT @moneyFromCourse = c.cost*c.number_Learner
    FROM Course c
    RETURN @moneyFromCourse
END
GO
-----------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION incomeInss (@Instructor_ID CHAR(10))
RETURNS MONEY
AS
BEGIN
    IF ((SELECT LEN(@Instructor_ID)) >10)
    RETURN 0
    IF (NOT EXISTS(SELECT * FROM Course WHERE Ins_ID=@Instructor_ID))
    RETURN 0
    DECLARE @incomeIns MONEY = 0
    DECLARE @Ins_ID CHAR(10),@cost MONEY,@num INT
    DECLARE cursorIns CURSOR FOR
    SELECT Ins_ID,cost,Number_Learner FROM Course
    OPEN cursorIns
    FETCH NEXT FROM cursorIns INTO @Ins_ID,@cost,@num
    WHILE @@FETCH_STATUS = 0
        BEGIN
        IF (@Ins_ID=@Instructor_ID) SELECT @incomeIns =  @incomeIns + @cost*@num
        FETCH NEXT FROM cursorIns INTO @Ins_ID,@cost,@num
        END
    CLOSE cursorIns
    DEALLOCATE cursorIns
    RETURN @incomeIns
END
GO

