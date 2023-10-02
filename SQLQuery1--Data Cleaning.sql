select *
from [Portfolio Project ].dbo.NashvilleHousing 

--standardize date format 
select SaleDateConverted, convert(Date, SaleDate)
from [Portfolio Project ].dbo.NashvilleHousing 

alter table [Portfolio Project ].dbo.NashvilleHousing
Add SaleDateConverted Date;

update[Portfolio Project ].dbo.NashvilleHousing
set SaleDateConverted=convert (Date, SaleDate)

---populate property address data
select *
from [Portfolio Project ].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--have to do self join (shortcut name a and b)
--parcel number is the same but not the same row
--so, 2 of same address listed, make into just one row
--isnull, if a. is null, then replace with b. address)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project ].dbo.NashvilleHousing a
join [Portfolio Project ].dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--run this and then rerun top to check there are no more null
update a
set PropertyAddress= isnull (a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project ].dbo.NashvilleHousing a
join [Portfolio Project ].dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--breaking out address into individual columns (address, city, state)
select PropertyAddress
from [Portfolio Project ].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--charindex when looking for something specific, in this case ,
-- the minus 1 is for getting rid of ,
--so charindex gets the address until reach , and then -1 takes away ,

--add second substring and take away 1 because want to start at the , not first position
-- +1 is to go to the ,
--len means the length of whatever you named it...PropertyAddress
select 
substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEn(PropertyAddress)) as address
from [Portfolio Project ].dbo.NashvilleHousing

--splitting into just address and just city
--added columns to end of table 

alter table [Portfolio Project ].dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update [Portfolio Project ].dbo.NashvilleHousing
set PropertySplitAddress=substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


alter table [Portfolio Project ].dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

update [Portfolio Project ].dbo.NashvilleHousing
set PropertySplitCity=substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEn(PropertyAddress))

select *
from [Portfolio Project ].dbo.NashvilleHousing

--owner address column 
--not using substrings this time
--parsemane looks for . so change the , in address to . by using replace
--but separates backwards so change numbers to 3,2,1

select owneraddress
from [Portfolio Project ].dbo.NashvilleHousing

select
parsename (replace(owneraddress, ',', '.') ,3)
,parsename (replace(owneraddress, ',', '.') ,2)
,parsename (replace(owneraddress, ',', '.') ,1)
from [Portfolio Project ].dbo.NashvilleHousing

--add columns 

alter table [Portfolio Project ].dbo.NashvilleHousing
Add  ownerSplitAddress nvarchar(255);

update [Portfolio Project ].dbo.NashvilleHousing
set ownerSplitAddress=parsename (replace(owneraddress, ',', '.') ,3)


--executive one code chunk at a time

alter table [Portfolio Project ].dbo.NashvilleHousing
Add ownerSplitCity nvarchar(255);

update [Portfolio Project ].dbo.NashvilleHousing
set ownerSplitCity=parsename (replace(owneraddress, ',', '.') ,2)

alter table [Portfolio Project ].dbo.NashvilleHousing
Add  ownerSplitstate nvarchar(255);

update [Portfolio Project ].dbo.NashvilleHousing
set ownerSplitstate=parsename (replace(owneraddress, ',', '.') ,1)

--double check the new columns 
select *
from [Portfolio Project ].dbo.NashvilleHousing

--change Y and N to Yes and No in "sold as vacant" field 

--this to see how many yes versus y
select distinct(soldasvacant), count (soldasvacant)
from [Portfolio Project ].dbo.NashvilleHousing
group by soldasvacant
order by 2

--to change so all are the same wording
select soldasvacant,
case when soldasvacant ='Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from [Portfolio Project ].dbo.NashvilleHousing


update[Portfolio Project ].dbo.NashvilleHousing
set soldasvacant = case when soldasvacant ='Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

--remove duplicates
--make into CTE for temp table
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
PropertyAddress, SalePrice, SaleDate,LegalReference
order by
uniqueID )
row_num
from [Portfolio Project ].dbo.NashvilleHousing)

--do this code first to find duplicates
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress
--after this shows all the duplicates

--replace with this code for second part to delete
Delete 
from RowNumCTE
where row_num > 1


--delete unused columns 

select *
from [Portfolio Project ].dbo.NashvilleHousing

alter table [Portfolio Project ].dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
