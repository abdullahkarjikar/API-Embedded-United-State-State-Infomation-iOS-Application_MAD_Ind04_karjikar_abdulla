<?php

// DatabaseConnection class will establish conneciton with database.
class DatabaseConnection
{
    // Defining parameters
    private $databaseHostName = "cs.okstate.edu";
    private $databaseName = "akarjik";
    private $databaseUserName = "akarjik";
    private $databasePassword = "blueC@r42";
    private $link;

    // Creating a PDO object setting parameters.
    public function __construct()
    {
        try {
            $this->link = new PDO(
                "mysql:host=$this->databaseHostName;dbname=$this->databaseName",
                $this->databaseUserName,
                $this->databasePassword
            );
            $this->link->setAttribute(
                PDO::ATTR_ERRMODE,
                PDO::ERRMODE_EXCEPTION
            );
        } catch (PDOException $error) {
            echo "Failed to connect to database. Please check the parameters again! : " .
                $error->getMessage();
        }
    }
    // This returns a connection object
    public function connectToDatabase()
    {
        return $this->link;
    }
}

// Class API retrieves all the rows from the "states" table.
class API
{
    // Creating column names.
    protected $databaseConnectionObject;
    private $name_;
    private $nickname_;

    // Setting name to object.
    public function setName($name_)
    {
        $this->name_ = $name_;
    }
    
    // Setting nick name to object.
    public function setNickName($nickname_)
    {
        $this->nickname_ = $nickname_;
    }
    
    // Establishing connection with database in constructor so we are ready to fetch rows from table.
    public function __construct()
    {
        $this->databaseConnectionObject = new DatabaseConnection();
        $this->databaseConnectionObject = $this->databaseConnectionObject->connectToDatabase();
    }

    // Retrieving all rows from table with "SELECT *" SQL query
    public function retrieveRowsFromStateTable()
    {
        try {
            $query = "SELECT * FROM states";
            $preparedQuery = $this->databaseConnectionObject->prepare($query);

            $preparedQuery->execute();
            $results = $preparedQuery->fetchAll(\PDO::FETCH_ASSOC);
            return $results;
        } catch (Exception $error) {
            die("Query failed to execute. Please check the query again...");
        }
    }
}

// Creating API class object
$api = new API();

// Retrieving details from "states" table
$stateDetails = $api->retrieveRowsFromStateTable();

// If there are rows in table, script will return all rows within the table.
if (!empty($stateDetails)) {
    $convertToJSON = json_encode(
        ["allDataRetrieved" => true, "stateDetails" => $stateDetails],
        true
    );
} 
// If no rows found in table, then message with below text is returned.
else {
    $convertToJSON = json_encode(
        ["allDataRetrieved" => false, "message" => "There is no record yet."],
        true
    );
}
header("Content-Type: application/json");
echo $convertToJSON;
header("HTTP/1.0 405 Method Not Allowed");

?>
