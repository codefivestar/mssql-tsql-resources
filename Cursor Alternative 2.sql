----------------------------------------------------------------------------------------------------------
--Create Date : 2018-04-30 10:33 A.M.
--Author      : Hidequel Puga
--Mail        : bounty31k@outlook.com
--Reference   : https://www.sqlbook.com/advanced/sql-cursors-how-to-avoid-them/
--Description : Cursor Alternatives
----------------------------------------------------------------------------------------------------------
----------------------------------------------------
--Cursor Alternative 2: Using User Defined Functions
----------------------------------------------------

-- return a discount %age that the customer 
-- can recieve based on their no. and value
-- of purchases
CREATE FUNCTION dbo.GetDiscountLevel (@CustomerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @DiscountPercent INT
	DECLARE @NumberOrders INT
		,@SalesTotal FLOAT

	SELECT @NumberOrders = COUNT(OrderID)
		,@SalesTotal = SUM(TotalCost)
	FROM Sales
	WHERE CustomerID = @CustomerID

	IF @SalesTotal > 5000.00
		AND @NumberOrders > 5
		SET @DiscountPercent = 5
	ELSE
	BEGIN
		IF @SalesTotal > 3000.00
			AND @NumberOrders > 3
			SET @DiscountPercent = 3
		ELSE
			SET @DiscountPercent = 0
	END

	RETURN @DiscountPercent
END

