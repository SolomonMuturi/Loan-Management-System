<?php
// Include your database connection or necessary files
include_once 'db_connection.php'; // Example file, change according to your setup

// Check if the required data is sent
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $borrowerName = isset($_POST['borrower_name']) ? $_POST['borrower_name'] : null;
    $amountPaid = isset($_POST['amount_paid']) ? $_POST['amount_paid'] : null;

    if ($borrowerName && $amountPaid !== null) {
        // Perform the renewal process
        // Query to get the loan information using the borrower's name
        $sql = "SELECT * FROM loans WHERE borrower_name = ? AND status = 'approved' LIMIT 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $borrowerName);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Loan found, update the renewal process
            $loan = $result->fetch_assoc();
            $loanId = $loan['id'];
            $newAmountPaid = $loan['amount_paid'] + $amountPaid; // Add the new paid amount

            // Update the loan status and amount paid
            $updateSql = "UPDATE loans SET amount_paid = ?, renewal_date = NOW(), status = 'renewed' WHERE id = ?";
            $updateStmt = $conn->prepare($updateSql);
            $updateStmt->bind_param("di", $newAmountPaid, $loanId);

            if ($updateStmt->execute()) {
                // Success response
                echo json_encode(['success' => true, 'message' => 'Loan successfully renewed.']);
            } else {
                // Failure response
                echo json_encode(['success' => false, 'message' => 'Error updating loan status.']);
            }
        } else {
            // No loan found for the borrower name
            echo json_encode(['success' => false, 'message' => 'No loan found for this borrower.']);
        }
    } else {
        // Missing required data
        echo json_encode(['success' => false, 'message' => 'Missing required data.']);
    }
} else {
    // Invalid request method
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}
?>
