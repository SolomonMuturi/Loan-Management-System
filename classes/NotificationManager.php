<?php
// Include the Database class
// Include the Database class
include_once "Database.php";

class NotificationManager {
    private $db;

    // Constructor accepts a Database object
    public function __construct(Database $db) {
        $this->db = $db;
    }

    // Method to get loans due today or overdue, excluding NULL dates
    public function getNotificationDueTodayAndOverdue() {
        try {
            // SQL query to fetch loans that are due today or overdue and exclude NULL next_date
            $sql = "
                SELECT 
                    b_id AS nid, 
                    name, 
                    total_loan, 
                    IFNULL(amount_paid, 0) AS amount_paid, 
                    IFNULL(next_date, 'N/A') AS next_date, 
                    IFNULL(payment_date, 'N/A') AS payment_date, 
                    (total_loan - IFNULL(amount_paid, 0)) AS amount_remain
                FROM tbl_loan_application
                WHERE next_date IS NOT NULL
                AND (next_date <= CURDATE() OR payment_date = CURDATE())
                ORDER BY next_date ASC
            ";

            $result = $this->db->query($sql);

            // Check for query execution success
            if (!$result) {
                throw new Exception("Database query failed: " . $this->db->getError());
            }

            return $result;
        } catch (Exception $e) {
            // Log the error and return false
            error_log($e->getMessage());
            return false;
        }
    }
}



?>
