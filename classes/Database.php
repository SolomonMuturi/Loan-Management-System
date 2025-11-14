<?php
class Database {
    private $host = 'localhost';  // Database host
    private $username = 'dunsterc_root';   // Database username
    private $password = 'Kenya@2024#';       // Database password
    private $database = 'dunsterc_data'; // Database name
    private $connection;

    // Constructor to establish a connection
    public function __construct() {
        $this->connection = new mysqli($this->host, $this->username, $this->password, $this->database);

        if ($this->connection->connect_error) {
            die("Connection failed: " . $this->connection->connect_error);
        }
    }

    // Method to execute a query
    public function query($sql) {
        return $this->connection->query($sql);
    }

    // Method to fetch a single row
    public function fetchAssoc($result) {
        return $result->fetch_assoc();
    }

    // Method to get the last inserted ID
    public function getLastInsertedId() {
        return $this->connection->insert_id;
    }

    // Method to get the last error message
    public function getError() {
        return $this->connection->error;
    }

    // Method to close the connection
    public function close() {
        $this->connection->close();
    }
}
?>
