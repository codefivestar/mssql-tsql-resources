----------------------------------------------------------------------------------------------------------
--Create Date : 2020-02-27 02:05 P.M.
--Author      : Hidequel Puga
--Mail        : codefivestar@gmail.com
--Reference   : --
--Description : Cargar Imagenes a la BD
----------------------------------------------------------------------------------------------------------

-- Create table

CREATE TABLE [Images]
(
	[id]    [INT]       IDENTITY(1,1) NOT NULL,
	[image] [VARBINARY] (MAX)         NOT NULL
) 
ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

-- Insert data

INSERT INTO [Images]
(
	  [image]
)
SELECT (
		SELECT BulkColumn
		  FROM OPENROWSET(BULK 'C:\Imagen\image.png', SINGLE_BLOB) AS img_data -- Image data
		);