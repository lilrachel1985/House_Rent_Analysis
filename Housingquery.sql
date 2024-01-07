SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [SQLPortfolio].[dbo].[Sheet1$]

  /*
  Cleaning Data in SQL 

*/

/*
Standardize Date Format 
*/

Select *
from SQLPortfolio.dbo.Nashvillehousing

Select SaleDateConverted,CONVERT(Date,SaleDate)
FROM SQLPortfolio.dbo.Nashvillehousing


Update Nashvillehousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE Nashvillehousing
Add SaleDateConverted Date;

Update Nashvillehousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

/* Populate Property Address data */
SELECT PropertyAddress
FROM SQLPortfolio.dbo.Nashvillehousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.Nashvillehousing a
JOIN SQLPortfolio.dbo.Nashvillehousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.Nashvillehousing a
JOIN SQLPortfolio.dbo.Nashvillehousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

/* Breaking out Address into individual Columns(Address,City,State)*/
SELECT *
FROM SQLPortfolio.dbo.Nashvillehousing
--Where PropertyAddress is null

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))as Address

FROM SQLPortfolio.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashvillehousing
Add PropertySplitCity Nvarchar(255);

Update Nashvillehousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
FROM SQLPortfolio.dbo.Nashvillehousing


Select 
PARSENAME(REPLACE (OwnerAddress,',','.'),3)
,PARSENAME(REPLACE (OwnerAddress,',','.'),2)
,PARSENAME(REPLACE (OwnerAddress,',','.'),1)
FROM SQLPortfolio.dbo.Nashvillehousing

ALTER TABLE SQLPortfolio.dbo.Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update SQLPortfolio.dbo.Nashvillehousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE SQLPortfolio.dbo.Nashvillehousing
Add OwnerSplitCity Nvarchar(255);

Update SQLPortfolio.dbo.Nashvillehousing
SET OwnerSplitCity=PARSENAME(REPLACE (OwnerAddress,',','.'),2)

ALTER TABLE SQLPortfolio.dbo.Nashvillehousing
Add OwnerSplitState Nvarchar(255);

Update SQLPortfolio.dbo.Nashvillehousing
SET OwnerSplitState=PARSENAME(REPLACE (OwnerAddress,',','.'),1)

SELECT * FROM SQLPortfolio.dbo.Nashvillehousing

/* Change Y and N to Yes and No in "Sold as Vacant"field" */

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
 FROM SQLPortfolio.dbo.Nashvillehousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant
 ,CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM SQLPortfolio.dbo.Nashvillehousing

Update SQLPortfolio.dbo.Nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END

/*Removing Duplicatesa */
with RowCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

FROM SQLPortfolio.dbo.Nashvillehousing
--ORDER BY ParcelID
)
SELECT *
FROM RowCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

 /*Delete unused columns */
 ALTER TABLE SQLPortfolio.dbo.Nashvillehousing
 DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

 SELECT *
 FROM SQLPortfolio.dbo.Nashvillehousing

  ALTER TABLE SQLPortfolio.dbo.Nashvillehousing
 DROP COLUMN SaleDate
