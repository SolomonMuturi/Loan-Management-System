<?php

class LoanManagement {
    private $db;

    //  initialize the database connection
    public function __construct($mysqli) {
        $this->db = $mysqli;
    }
}

   
?>
