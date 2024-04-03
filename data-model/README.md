# Expense Tracker Data Model 
This Ballerina package contains the data model of the Expense Tracker pplication. 

### Commands 
#### Initialized the package for persistence 
```shell
bal persist init --datastore mysql
```

#### Generate Client and the database schema

```shell
bal persist generate
```

#### Generate migration scripts 
```shell

```

#### Publish the library to the local repository 
```shell
bal pack;bal push --repository=local
```