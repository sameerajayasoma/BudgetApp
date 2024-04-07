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

#### Update the generated client 
Replate the generate Client's init function signature with the following. This is due to a limitation in the generated code.
```ballerina
    public isolated function init(string host = "localhost", string? user = "root", string? password = (), string? database = (),
            int port = 3306, mysql:Options? options = (), sql:ConnectionPool? connectionPool = ()) returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port, options = options);
```

#### Generate migration scripts 
```shell
bal persist migrate "lable_goes_here"
```

#### Publish the library to the local repository 
```shell
bal pack;bal push --repository=local
```

#### Publish the library to Ballerina Central 
```shell
bal pack;bal push
```