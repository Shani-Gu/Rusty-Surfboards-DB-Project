--------------------PART 1------------------------------------

--------------------TASK 1------------------------------------
------------quary 1
SELECT		c.Email ,
		full_name= c.[name-first name] + ' ' + c.[name-last name],
		NumOfOrders = count(*)
from		ORDERS as o join CREDITCARDS as cc
		on o.[Credit Card] = cc.Number
		join CUSTOMERS as c
		on c.Email = cc.EMAIL
WHERE	  	DATEDIFF(YY , O.[Order DT] , GETDATE()) <=1
group by 	c.Email,
		c.[name-first name],
		c.[name-last name]
HAVING 	COUNT(*) > 1
order by      NumOfOrders DESC

----------quary 2

SELECT		O.[Order ID],
			cc.Email,
			O.[Delivery Method],
			S.[Supply date]
FROM		ORDERS as o join CREDITCARDS as cc
			ON o.[Credit Card] = cc.Number
			JOIN SHIPPING AS S
			ON O.[Order ID] = S.[Order ID]
WHERE   	O.[Delivery Method] IN ('regular delivery' ,  'express dalivery') AND 
        	DATEDIFF (mm , S.[Supply date] , GETDATE() ) <= 1
ORDER BY	O.[Order ID]

-----------------------TASK 2--------------------------

-------quary 1

SELECT  	AllOrders = count(*),
	 		SelfPickUpOrders = (SELECT 		COUNT(*)
								FROM 		ORDERS as O
							    WHERE 		O.[Delivery Method] = 'self-pick up' AND 
											DATEDIFF(yy,O.[Order DT],GETDATE())<= 1),
	  		proportion = ROUND(CAST(CAST((SELECT 	COUNT(*)
				            			  FROM   	ORDERS as O
				            			  WHERE  	O.[Delivery Method]='self-pick up' 
													AND 
													DATEDIFF(yy,O.[Order DT], GETDATE())<= 1)
										 AS REAL)/CAST(COUNT(*) AS REAL) AS REAL),3)
FROM		ORDERS as O   
WHERE       DATEDIFF(yy ,O.[Order DT],GETDATE()) <= 1


--------quary 2

SELECT    TOP	5 CU.Email , 
				FullName = CU.[name-first name] + ' ' + CU.[name-last name],
				O.[Order ID],
				Total_Revenue = ISNULL( TOTALS_V.VersionTotalCost ,0) + ISNULL (TOTALS_P.PersonalTotalCost,0)

FROM   		dbo.CUSTOMERS AS CU JOIN CREDITCARDS AS CC ON CU.Email = CC.EMAIL
			JOIN ORDERS AS O ON O.[Credit Card] = CC.Number
		  
       		JOIN (SELECT 		C.[Order ID] ,
								VersionTotalCost=SUM(C.quantity * V.[Version Price])
				   FROM 		VERSIONS AS V JOIN CONTAIN AS C 
								ON V.[Surfboard ID] = C.[Surfboard ID] AND V.[Version ID]=C.[Version ID] 
				   GROUP BY		C.[Order ID]) AS TOTALS_V 
			ON O.[Order ID]=TOTALS_V.[Order ID]
 
			JOIN (SELECT	I.[Order ID], PersonalTotalCost = SUM(I.Units * P.[PD Price])
	      	      FROM		PERSONALDESIGNS AS P JOIN [INCLUDE] AS I 
							ON P.[Surfboard ID]=I.[Surfboard ID] AND
							P.[Version ID]=I.[Version ID] AND P.Email=I.Email AND
							P.[Fin system]=I.[Fin system] AND P.[Deck color]=I.[Deck color]       
							AND P.[Bottom color]=I.[Bottom color] AND P.[Rail color]=I.[Rail color] 
							AND P.[Band color] = I.[Band color] AND P.Gear = I.Gear 
				  GROUP BY	I.[Order ID]) AS TOTALS_P 
			 ON O.[Order ID] = TOTALS_P.[Order ID] 

ORDER BY Total_Revenue DESC

---------------------TASK 3---------------------------

----------quary 1 - update
--ALTER TABLE dbo.ORDERS
--DROP COLUMN TotalCost

ALTER TABLE dbo.ORDERS ADD TotalCost MONEY

UPDATE	dbo.ORDERS
		SET TotalCost = ( 
						SELECT		Total_Revenue = ISNULL( TOTALS_V.VersionTotalCost ,0) + 
   													ISNULL (TOTALS_P.PersonalTotalCost,0)

    					FROM		dbo.CUSTOMERS AS CU JOIN CREDITCARDS AS CC 
									ON CU.Email = CC.EMAIL JOIN ORDERS AS O
									ON O.[Credit Card] = CC.Number
									JOIN (SELECT	C.[Order ID] , 
  		  			    							VersionTotalCost = SUM(C.quantity * V.[Version Price])
      		      						  FROM     	VERSIONS AS V JOIN CONTAIN AS C ON
 													V.[Surfboard ID] = C.[Surfboard ID] 
													AND V.[Version ID] =  C.[Version ID] 
										  GROUP BY	C.[Order ID]) 
									 AS TOTALS_V ON O.[Order ID] = TOTALS_V.[Order ID]
		  							JOIN (SELECT	I.[Order ID], 
 					     							PersonalTotalCost = SUM(I.Units * P.[PD Price])
										  FROM 		PERSONALDESIGNS AS P JOIN [INCLUDE] AS I 
					   								ON P.[Surfboard ID]=I.[Surfboard ID] 
													AND P.[Version ID]=I.[Version ID] 
													AND P.Email=I.Email 
													AND P.[Fin system]=I.[Fin system] 
													AND P.[Deck color]=I.[Deck color]
													AND P.[Bottom color]=I.[Bottom color] 
													AND P.[Rail color]=I.[Rail color] 
													AND P.[Band color] = I.[Band color] 
													AND P.Gear = I.Gear 
										 GROUP BY	I.[Order ID]) 
									AS TOTALS_P ON O.[Order ID] = TOTALS_P.[Order ID] 

						WHERE orders.[Order ID] = O.[Order ID]
)



-------quary 2 - except

SELECT  	Email , 
			full_name = [name-first name]+ ' ' + [name-last name]
FROM 		dbo.CUSTOMERS

EXCEPT

SELECT 		C.Email ,
			full_name= C.[name-first name] + ' ' + C.[name-last name]
FROM 		ORDERS AS O JOIN CREDITCARDS AS CC
			ON O.[Credit Card] = CC.Number
			JOIN CUSTOMERS AS C
			ON C.Email = CC.EMAIL
GROUP BY    c.Email,
			c.[name-first name],
			c.[name-last name]
HAVING  	COUNT(*) > (SELECT 	AvgNumOfOrders = AVG(NumOfOrders)
						 FROM	(SELECT		C.Email ,
											full_name= C.[name-first name] + ' ' + C.[name-last name],
											NumOfOrders = COUNT(*)
								  FROM	    ORDERS AS O JOIN CREDITCARDS AS CC
											ON O.[Credit Card] = CC.Number
											JOIN CUSTOMERS AS C ON C.Email = CC.EMAIL
								  GROUP BY 	c.Email,
											c.[name-first name],
											c.[name-last name]) AS A)

-----------------------------PART 2 --------------------------------------------

------VIEW----------

--DROP VIEW StockKeeper_VIEW

CREATE VIEW StockKeeper_VIEW AS
 
SELECT   	O.[Order ID] , 
			O.[Order DT] , 
			CatalogNumber = CAST(C.[Surfboard ID] AS VARCHAR)  + '.' + CAST(c.[Version ID] AS VARCHAR), 
			C.quantity

FROM		dbo.ORDERS AS O JOIN dbo.CONTAIN AS C ON O.[Order ID] = C.[Order ID]

WHERE		DATEDIFF (mm , O.[Order DT] , GETDATE() ) <= 1
---USE EXAMPLE

SELECT *
FROM StockKeeper_VIEW

--------table function---------------
--DROP FUNCTION Orders_Customers_table

CREATE FUNCTION Orders_Customers_table (@OrderID INT)
RETURNS TABLE
AS RETURN
SELECT		O.[Order ID] , 
			O.[Order DT] ,	
			O.[Delivery Method], 
			C.Email , 
			FullName = C.[name-first name] + ' ' + C.[name-last name]
FROM		dbo.ORDERS AS O JOIN dbo.CREDITCARDS AS CC 
			ON CC.Number = O.[Credit Card]
			JOIN dbo.CUSTOMERS AS C ON C.Email = CC.EMAIL
WHERE		O.[Order ID] = @OrderID

---USE EXAMPLE

SELECT *
FROM dbo.Orders_Customers_table(1)

---------scalar function------------------

-- DROP FUNCTION UnitsSold

CREATE FUNCTION UnitsSold (@SurfboardID INT , @fromDate DATE)
RETURNS INT
AS BEGIN
	  DECLARE	@Amount INT
	  SELECT	@Amount = SUM(C.quantity)
	  FROM		dbo.CONTAIN AS C JOIN dbo.ORDERS AS O 
				ON O.[Order ID] = C.[Order ID]
	  WHERE		@SurfboardID = C.[Surfboard ID] AND 
				O.[Order DT] BETWEEN @fromDate AND GETDATE() 
	  GROUP BY  C.[Surfboard ID]
	  RETURN   ISNULL(@Amount,0)
END

---USE EXAMPLE
SELECT UnitsSold = dbo.UnitsSold (47 , '2021-10-27')

-------TRIGGER-----------------
DROP TRIGGER UPDATE_TotalCost

CREATE	TRIGGER  UPDATE_TotalCost
ON		dbo.CONTAIN
FOR		INSERT , DELETE , UPDATE
AS
UPDATE		dbo.ORDERS
SET		TotalCost = ( 
					SELECT   Total_Revenue = ISNULL( TOTALS_V.VersionTotalCost ,0) + 
											 ISNULL(TOTALS_P.PersonalTotalCost,0)

    				FROM    dbo.CUSTOMERS AS CU JOIN CREDITCARDS AS CC 
							ON CU.Email = CC.EMAIL JOIN ORDERS AS O 
							ON O.[Credit Card] = CC.Number
							JOIN (SELECT	 	C.[Order ID] , 
												VersionTotalCost = SUM(C.quantity *V.[Version Price])
      		      				  FROM	 		VERSIONS AS V JOIN CONTAIN AS C 
							 					ON V.[Surfboard ID]= C.[Surfboard ID] 
												AND V.[Version ID]=C.[Version ID] 
								  GROUP BY		C.[Order ID]) 
							AS TOTALS_V ON O.[Order ID] = TOTALS_V.[Order ID]
		   					JOIN (SELECT  		I.[Order ID], 
							  					PersonalTotalCost = SUM(I.Units *P.[PD Price])
								  FROM			PERSONALDESIGNS AS P JOIN [INCLUDE] AS I 
												ON P.[Surfboard ID]= I.[Surfboard ID] AND 
												P.[Version ID]=I.[Version ID] 
												AND P.Email=I.Email 	
												AND P.[Fin system]=I.[Fin system] 
												AND P.[Deck color]=I.[Deck color]
												AND P.[Bottom color]= I.[Bottom color]	
												AND P.[Rail color]=I.[Rail color] 
												AND P.[Band color]=I.[Band color] 
												AND P.Gear = I.Gear 
								   GROUP BY 	I.[Order ID]) 
							AS TOTALS_P ON O.[Order ID] = TOTALS_P.[Order ID] 
				    WHERE	orders.[Order ID] = O.[Order ID]
				    )

WHERE		dbo.ORDERS.[Order ID] IN (SELECT	   DISTINCT [Order ID]
									  FROM			INSERTED
									  UNION
									  SELECT	   DISTINCT [Order ID]
									  FROM        Deleted)

---USE EXAMPLE

DELETE FROM dbo.CONTAIN WHERE [Version ID]=121 AND [Surfboard ID] = 1 AND [Order ID] = 2

SELECT * 
FROM dbo.ORDERS
WHERE [Order ID]=2

INSERT INTO dbo.CONTAIN
(
    [Surfboard ID],
    [Version ID],
    [Order ID],
    quantity
)
VALUES
(   1, -- Surfboard ID - int
    121, -- Version ID - int
    2, -- Order ID - int
    2  -- quantity - int
)

SELECT * 
FROM dbo.ORDERS
WHERE [Order ID] =2 

--------------Stored Procedure-----------------

--ALTER TABLE dbo.CUSTOMERS 
--DROP COLUMN [Num Of Orders]

ALTER TABLE dbo.CUSTOMERS ADD [Num Of Orders] int

--DROP PROCEDURE dbo.SP_UpdateNumOfOrders

CREATE 	PROCEDURE 	SP_UpdateNumOfOrders		@Email	VARCHAR(30)
AS
UPDATE		dbo.CUSTOMERS
SET			[Num Of Orders] = 
				  (SELECT  	COUNT(*)
	        	   FROM		ORDERS AS O JOIN dbo.CREDITCARDS AS CC 
     						ON O.[Credit Card] = CC.Number
				     		JOIN dbo.CUSTOMERS AS C ON C.Email = CC.EMAIL
				   WHERE 	C.Email = @Email
				   GROUP BY	C.Email)	
WHERE		dbo.CUSTOMERS.Email = @Email

--BEFORE 
SELECT *
FROM dbo.CUSTOMERS
WHERE Email = '00EGIA6Y@8JTG2X.WHECCWWGR'

--USE EXAMPLE 
EXECUTE dbo.SP_UpdateNumOfOrders @Email = '00EGIA6Y@8JTG2X.WHECCWWGR'

--AFTER
SELECT *
FROM dbo.CUSTOMERS
WHERE Email = '00EGIA6Y@8JTG2X.WHECCWWGR'

------------------PART 3 --------------------------
---sumary view
DROP VIEW Summary_view

CREATE VIEW Summary_view
AS 
SELECT		o.[Order ID],
			o.[Order DT],
			o.[Credit Card],
			[Address – country] = ISNULL( s.[Address – country], 'United States'),
			o.TotalCost,
			CatalogNumber = CAST(dbo.CONTAIN.[Surfboard ID] as varchar(20)) + '.' + 
							CAST(dbo.CONTAIN.[Version ID] AS varchar(20)),
			vertion_quantity = dbo.CONTAIN.quantity,
			personal_design_units = dbo.[INCLUDE].Units

FROM 		orders AS o LEFT JOIN dbo.SHIPPING AS s ON s.[Order ID] = o.[Order ID]
			JOIN dbo.CONTAIN ON CONTAIN.[Order ID] = O.[Order ID]
			JOIN dbo.[INCLUDE] ON [INCLUDE].[Order ID] = O.[Order ID]

------targets views

--DROP VIEW Target_orders_view
--DROP VIEW Target_Customers_view
--DROP VIEW Target_revenue_view


CREATE VIEW Target_orders_view
AS
SELECT Orders_Target = CAST((COUNT([Order ID])*1.1) AS int)
FROM dbo.ORDERS

CREATE VIEW Target_Customers_view
AS
SELECT Customers_Target = CAST((COUNT(DISTINCT[Credit Card])*1.1) AS int)
FROM dbo.ORDERS


CREATE VIEW Target_revenue_view
AS
SELECT TotalCostTarget = (SUM(TotalCost)*1.1)
FROM dbo.ORDERS


------------------PART 4 --------------------------

-----WINDOWS FUNCTIONS

------QUARY 1

SELECT		R.[PRICE-RANGE],
			R.UnitSoldFromCategory,
			RANK () OVER ( 
				ORDER BY UnitSoldFromCategory DESC
				) sales_rank 
FROM 
			(SELECT 	B.[PRICE-RANGE],
						UnitSoldFromCategory = SUM(C.quantity)

			FROM		dbo.CONTAIN AS C JOIN (SELECT	[Surfboard ID],
														[Version ID],
														[Version Price],
														NTILE (5) OVER (
															ORDER BY [Version Price]
														 ) [PRICE-RANGE]
											    FROM	dbo.VERSIONS) AS B 
						 ON B.[Surfboard ID] = C.[Surfboard ID] 
						 AND B.[Version ID] = C.[Version ID]
		   	 GROUP BY    B.[PRICE-RANGE]) AS R		    

----QUARY 2

DROP FUNCTION QUARTER_PROFITS

CREATE FUNCTION QUARTER_PROFITS(@MONTH INT , @YEAR INT)
RETURNS TABLE
AS RETURN
SELECT  	K.[Month] , 
			[previous month Profit] , 
			[Monthly profit], 
			[Next Month Destenation], 
			[next month Profit]
FROM		(SELECT	[Month] , 
					LAG([Monthly profit],1) OVER (
					ORDER BY month
					) [previous month Profit],
					[Monthly profit] ,
					[Next Month Destenation] = [Monthly profit]*1.05,					
					LEAD([Monthly profit],1) OVER (									
					ORDER BY month
					) [next month Profit]

			  FROM	(SELECT	[Month] = MONTH([Order DT]) , 
							[Monthly profit] =  SUM(TotalCost)
					 FROM		ORDERS 
					 WHERE		YEAR([Order DT]) = @YEAR
					 GROUP BY	MONTH([Order DT])) AS R) AS K
WHERE         [Month] = @MONTH

--USE EXAMPLE
SELECT * 
FROM dbo.QUARTER_PROFITS(4,2021)

-----------TOOLS COMBINE

----CREATING THE RELEVANT TABLE

--DROP TABLE DeletedOrders

CREATE TABLE DeletedOrders  (
	[ORDER ID]  INT NOT NULL,
	[Order DT] DATETIME NOT NULL,
    [Delivery Method] VARCHAR(20) null,
   	[Credit Card]	VARCHAR(20) null,
	[TotalCost]	MONEY	NULL,
	[cancellation Date]  datetime  NULL,
	[Customer email] varchar(30) NULL

CONSTRAINT pk_DeletedOrders PRIMARY KEY ([ORDER ID], [Order DT])
)


----CREATING THE RELEVANT FUNCTIONS 

--DROP FUNCTION CHECK_DETAILS
CREATE FUNCTION CHECK_DETAILS (@orderID INT , @CC_number VARCHAR(20))
RETURNS INT
AS BEGIN
			DECLARE @answer INT
			SELECT @answer = COUNT([Order ID])
			FROM dbo.ORDERS
			WHERE [Order ID] = @orderID AND [Credit Card] = @CC_number
			RETURN ISNULL(@answer,0)
END

--DROP FUNCTION checkDaysFromOrder

CREATE FUNCTION checkDaysFromOrder (@orderID INT)
RETURNS INT 
AS BEGIN 
			DECLARE @answer INT
			SELECT @answer = DATEDIFF(DD ,O.[Order DT] , GETDATE())
			FROM  dbo.ORDERS AS O
			WHERE O.[Order ID] = @orderID
			RETURN @answer
END


--DROP FUNCTION getEmailFromCCnumber

CREATE FUNCTION getEmailFromCCnumber (@CCnumber VARCHAR(20))
RETURNS VARCHAR(30) 
AS BEGIN 
			DECLARE @email VARCHAR(30)
			SELECT @email  = c.Email
			FROM  dbo.CREDITCARDS AS cc JOIN dbo.CUSTOMERS AS c ON c.Email = cc.EMAIL
			WHERE cc.Number = @CCnumber
			RETURN @email
END

----CREATING THE RELEVANT TRIGER

--DROP TRIGGER Update_deleted_orders

CREATE TRIGGER Update_deleted_orders 
ON dbo.ORDERS
FOR DELETE
AS
INSERT INTO DeletedOrders
SELECT	Deleted.[Order ID] , Deleted.[Order DT] , Deleted.[Delivery Method],
		Deleted.[Credit Card] , Deleted.TotalCost , NULL,NULL
FROM	Deleted

----creating the SP

DROP PROCEDURE DELETE_ORDER

CREATE PROCEDURE DELETE_ORDER (@ORDERID INT , @CCnumber VARCHAR(20))
AS
IF (  [dbo].[CHECK_DETAILS](@ORDERID , @CCnumber) = 0) 
	BEGIN
	PRINT 'Wrong input or order does not exist,try again'
	END
ELSE IF ([dbo].[checkDaysFromOrder](@ORDERID) > 7)
	BEGIN
       PRINT 'More then 7 days left, please phone to customer service'
	END
ELSE 
	BEGIN 
	DELETE FROM dbo.ORDERS WHERE [Order ID] = @ORDERID
	PRINT 'Your order,' + CAST(@ORDERID AS VARCHAR(20)) +' ,has been successfully deleted'
	UPDATE 	[dbo].[DeletedOrders] 
	SET 	[Customer email] = (dbo.getEmailFromCCnumber (@CCnumber)),
			[cancellation Date] = GETDATE()
	WHERE	[dbo].[DeletedOrders].[ORDER ID] = @ORDERID
END

---USE EXAMPLE

--INSERTING AN ORDER
INSERT INTO dbo.ORDERS
(
    [Order ID],
    [Order DT],
    [Delivery Method],
    [Credit Card],
    TotalCost
)
VALUES
(   505,         -- Order ID - int
    GETDATE(), -- Order DT - datetime
    'self-pick up',        -- Delivery Method - varchar(20)
    '0006 2813 8918 0945',        -- Credit Card - varchar(20)
    1400       -- TotalCost - money
 )


 SELECT *
 FROM dbo.ORDERS
 
 ---EXCECUTING THE SP

 EXECUTE [dbo].[DELETE_ORDER] 505 , '0006 2813 8918 0945'

 ----checking the tables

  SELECT *
 FROM dbo.ORDERS

 SELECT *
 FROM dbo.DeletedOrders

 ----------------------REPORT--------------

 ---creating the functions

--DROP FUNCTION ORDERS_PER_MONTH

CREATE FUNCTION ORDERS_PER_MONTH (@month VARCHAR(2) , @year INT)
RETURNS INT
AS BEGIN
DECLARE @OrdersNum INT
SELECT	@OrdersNum = COUNT([Order ID])
FROM	ORDERS 
WHERE	MONTH([Order DT])= @month AND YEAR([Order DT])= @Year 
RETURN	@OrdersNum
END

--DROP FUNCTION TOTAL_REVENUE_PER_MONTH

CREATE FUNCTION TOTAL_REVENUE_PER_MONTH (@month VARCHAR(2) , @year INT)
RETURNS MONEY
AS BEGIN
DECLARE @revenue MONEY
SELECT	@revenue = SUM(TotalCost)
FROM	ORDERS 
WHERE	MONTH([Order DT])= @month AND YEAR([Order DT])= @Year 
RETURN	@revenue
END

--DROP FUNCTION Customers_per_month
CREATE FUNCTION Customers_per_month (@month VARCHAR(2) , @year INT)
RETURNS INT
AS BEGIN
DECLARE @customers INT
SELECT  @customers = COUNT (DISTINCT C.Email)
FROM	ORDERS AS O JOIN dbo.CREDITCARDS AS CC ON CC.Number = O.[Credit Card]
		JOIN dbo.CUSTOMERS AS C ON C.Email = CC.EMAIL
WHERE   MONTH([Order DT])= @month AND YEAR([Order DT])= @Year 
RETURN  @customers
END

--DROP FUNCTION PersonalDesigns_Sold_per_Month
CREATE FUNCTION PersonalDesigns_Sold_per_Month (@month VARCHAR(2) , @year INT)
RETURNS INT
AS BEGIN
DECLARE @UnitsSOLD INT
SELECT	 @UnitsSOLD = SUM(I.Units) 
FROM	 ORDERS AS O JOIN dbo.INCLUDE AS I ON I.[Order ID] = O.[Order ID]
WHERE	 MONTH([Order DT])= @month AND YEAR([Order DT])= @Year 
RETURN  @UnitsSOLD
END

--DROP FUNCTION CLIENT_OF_THE_MONTH
CREATE FUNCTION CLIENT_OF_THE_MONTH (@month VARCHAR(2) , @year INT)
RETURNS VARCHAR(30)
AS BEGIN
DECLARE 	@CLIENT VARCHAR(30)
SELECT		@CLIENT = C.EMAIL
FROM		ORDERS AS O JOIN dbo.CREDITCARDS AS CC ON CC.Number = O.[Credit Card]
		JOIN dbo.CUSTOMERS AS C ON C.Email = CC.EMAIL
WHERE 		(SELECT	maxCost = MAX(O.TotalCost)
	   	 FROM		ORDERS AS O JOIN dbo.CREDITCARDS AS CC ON CC.Number = 
O.[Credit Card] JOIN dbo.CUSTOMERS AS C ON C.Email = CC.EMAIL
		 WHERE MONTH([Order DT])= @month AND YEAR([Order DT])= @year) = O.TotalCost
RETURN 	 @CLIENT
END

------THE REPORT
SELECT		DISTINCT [Month] = MONTH(OD.[Order DT]) ,
		[Orders] = dbo.ORDERS_PER_MONTH (CAST (MONTH(OD.[Order DT]) AS VARCHAR(2)), 2021),
		[Customers] = dbo.Customers_per_month (CAST (MONTH(OD.[Order DT]) AS VARCHAR(2)), 2021),
		[Total Revenue] = dbo.TOTAL_REVENUE_PER_MONTH(CAST (MONTH(OD.[Order DT]) AS VARCHAR(2)), 2021),
		[Personal Designed products] = dbo.PersonalDesigns_Sold_per_Month(CAST (MONTH(OD.[Order DT]) AS VARCHAR(2)), 2021),
		[Best Client's Email] = dbo.CLIENT_OF_THE_MONTH(CAST (MONTH(OD.[Order DT]) AS VARCHAR(2)), 2021)
FROM		dbo.ORDERS AS OD JOIN dbo.CREDITCARDS AS CR ON CR.Number = OD.[Credit Card]
		JOIN dbo.CUSTOMERS AS CU ON CU.Email = CR.EMAIL 
ORDER BY      MONTH(OD.[Order DT])






