<?php
 
include_once "inc/header.php";
require_once "config/config.php";

// Establish database connection
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($mysqli->connect_error) {
    die("Database connection failed: " . $mysqli->connect_error);
}

if (isset($_GET['loan_id'])) {
    $loan_id = intval($_GET['loan_id']);  
    
    // Update query to clear only the name
    $query = "UPDATE tbl_loan_application SET name = '' WHERE id = ?";
    $stmt = $mysqli->prepare($query);
    
    if (!$stmt) {
        die("Error preparing statement: " . $mysqli->error);
    }

    $stmt->bind_param("i", $loan_id);
    $result = $stmt->execute();

    // Check if the update was successful
    if ($result) {
        echo "<script>alert('Borrower name removed successfully!'); window.location.href='loan_application.php';</script>";
    } else {
        echo "<script>alert('Failed to remove borrower name.'); window.location.href='loan_application.php';</script>";
    }
} else {
    // If no loan_id is passed, show an error message
    echo "<script>alert('Invalid request. Loan ID is missing.'); window.location.href='loan_application.php';</script>";
}

include_once "inc/footer.php";
?>
