----------------------------------------------------------------------------------------------------------
--Create Date : 2018-04-30 10:33 A.M.
--Author      : Hidequel Puga
--Mail        : bounty31k@outlook.com
--Reference   : https://www.sqlbook.com/advanced/sql-cursors-how-to-avoid-them/
--Description : Cursor Alternatives
----------------------------------------------------------------------------------------------------------

----------------------------------------------------
-- Cursor Alternative 1: Using the SQL WHILE loop
---------------------------------------------------- 

-- Create a temporary table, note the IDENTITY
-- column that will be used to loop through
-- the rows of this table
CREATE TABLE #ActiveCustomer 
(
	  RowID      INT IDENTITY(1, 1)
	, CustomerID INT
	, FirstName  VARCHAR(30)
	, LastName   VARCHAR(30)
);

DECLARE @NumberRecords INT
	  , @RowCount      INT;
	  
DECLARE @CustomerID INT
	  , @FirstName  VARCHAR(30)
	  , @LastName   VARCHAR(30);

-- Insert the resultset we want to loop through
-- into the temporary table
INSERT INTO #ActiveCustomer 
(
	  CustomerID
	, FirstName
	, LastName
)
SELECT CustomerID
	 , FirstName
	 , LastName
  FROM Customer
 WHERE Active = 1;

-- Get the number of records in the temporary table
SET @NumberRecords = @@ROWCOUNT;
SET @RowCount      = 1;

-- loop through all records in the temporary table
-- using the WHILE loop construct
WHILE @RowCount <= @NumberRecords
BEGIN

	SELECT @CustomerID = CustomerID
		 , @FirstName = FirstName
		 , @LastName = LastName
	  FROM #ActiveCustomer
	 WHERE RowID = @RowCount;

	EXEC MyStoredProc @CustomerID
	                , @FirstName
		            , @LastName;

	SET @RowCount = @RowCount + 1;
	
END

-- drop the temporary table
DROP TABLE #ActiveCustomer

-- *******************************************************************************************************************