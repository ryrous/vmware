Get-VmfsDatastoreInfo -Datastore VMHostingDataStore-01 | Export-Csv .\DataStoreReport.csv -NoTypeInformation
Get-VmfsDatastoreIncrease -Datastore VMHostingDataStore-01 | Export-Csv .\DataStoreExpandReport.csv -NoTypeInformation
