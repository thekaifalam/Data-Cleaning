USE portfolioproject
SELECT * FROM portfolioproject..NashvilleHousing 

--STANDARIZE SALE DATE FROMAT
--update statement was not working directly so first added a new columnand then set it's value to the converted

SELECT saledate , CONVERT( DATE , saledate ) AS saledateconverted
FROM portfolioproject..NashvilleHousing 


UPDATE portfolioproject..NashvilleHousing 
SET saledate = CONVERT( DATE , saledate )

--SELECT saledate, saledateconverted FROM portfolioproject..NationalHousing

ALTER TABLE portfolioproject..NashvilleHousing 
ADD saledateconverted date 

UPDATE portfolioproject..NashvilleHousing 
SET saledateconverted = CONVERT( DATE , saledate )

--POPULATE PROPERTY ADRESS
--As there were two parcelID with same PropertAdress there were some nulls  , so we populated those nulls with the existing other same property adress of the same ParcelID
SELECT * FROM portfolioproject..NashvilleHousing 
WHERE PropertyAddress is NULL

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM portfolioproject..NashvilleHousing  a
JOIN portfolioproject..NashvilleHousing  b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM portfolioproject..NashvilleHousing  a
JOIN portfolioproject..NashvilleHousing  b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking Out columns into individual columns ( Adress,city,state )
--For PropertAdress
SELECT PropertyAddress
FROM portfolioproject..NashvilleHousing

SELECT PropertyAddress , SUBSTRING(PropertyAddress , 1 , CHARINDEX( ',' , PropertyAddress)-1) AS address 
		                , SUBSTRING(PropertyAddress ,CHARINDEX( ',' , PropertyAddress) + 1 ,LEN(PropertyAddress) ) AS state

FROM portfolioproject..NashvilleHousing


ALTER TABLE portfolioproject..NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255)

UPDATE portfolioproject..NashvilleHousing 
SET PropertySplitAddress  = SUBSTRING(PropertyAddress , 1 , CHARINDEX( ',' , PropertyAddress)-1) 


ALTER TABLE portfolioproject..NashvilleHousing 
ADD PropertySplitCity Nvarchar(255)

UPDATE portfolioproject..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX( ',' , PropertyAddress) + 1 ,LEN(PropertyAddress) ) 

SELECT * FROM  portfolioproject..NashvilleHousing




--For OwnerAddress

SELECT OwnerAddress
FROM portfolioproject..NashvilleHousing

SELECT 
	PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 1 ) As OwnerCityname,
	PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 2 ) As OwnerStatename,
	PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 3 ) As OwnerSplitAddress

FROM portfolioproject..NationalHousing


ALTER TABLE  portfolioproject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE  portfolioproject..NashvilleHousing
SET OwnerSplitAddress  = PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 3 ) 

ALTER TABLE  portfolioproject..NashvilleHousing
ADD OwnerCityname Nvarchar(255)

UPDATE  portfolioproject..NashvilleHousing
SET OwnerCityname  = PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 1 ) 


ALTER TABLE  portfolioproject..NashvilleHousing
ADD OwnerStatename Nvarchar(255)

UPDATE  portfolioproject..NashvilleHousing
SET OwnerStatename  = PARSENAME( REPLACE(OwnerAddress , ',' , '.') , 2 ) 


--Change Y and N to YES and NO in SoldAsVacant Feild

SELECT SoldAsVacant , COUNT(SoldAsVacant)
FROM  portfolioproject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--SELECT REPLACE(SoldAsVacant , 'Y' , 'Yes' ) , REPLACE(SoldAsVacant , 'N' , 'No' )
--FROM  portfolioproject..NashvilleHousing

SELECT SoldAsVacant ,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	END
FROM  portfolioproject..NashvilleHousing

UPDATE  portfolioproject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END

--REMOVE DUPLICATES
--We are going to remove duplicate rows even if it's uiqueid maybe same beacuse other importanfeilds such as owneraddress , ownername , propertyadrress are ssame.

WITH RowNumCTE AS (
SELECT * , ROW_NUMBER() OVER (
		   PARTITION BY ParcelID , PropertyAddress , SaleDate , SalePrice , LegalReference
		   ORDER BY UniqueID ) RowNum
FROM  portfolioproject..NashvilleHousing )

DELETE
FROM RowNumCTE
WHERE RowNum > 1

--DELETE UNUSED COLUMNS
SELECT *
FROM  portfolioproject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict











