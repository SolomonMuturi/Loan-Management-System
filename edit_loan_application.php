<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

include_once "inc/header.php";  // Assuming you have a header included
require_once "config/config.php"; // Include database config

// Establish database connection
$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($mysqli->connect_error) {
    die("Database connection failed: " . $mysqli->connect_error);
}

// Fetch loan details by ID
function getLoanApplicationById($db, $id) {
    $query = "SELECT * FROM tbl_loan_application WHERE id = ?";
    $stmt = $db->prepare($query);
    if (!$stmt) {
        die("Error preparing statement: " . $db->error);
    }
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        die("<p>No loan application found for ID: $id</p>");
    }
    return $result->fetch_assoc();
}

// Calculate values based on expected loan and percentage
function calculateLoanValues($expected_loan, $loan_percentage) {
    // Assuming installments and other values are constants, or can be calculated.
    $installments = 52; // Weekly payments for a year
    $total_loan = $expected_loan + ($expected_loan * ($loan_percentage / 100));
    $emi_loan = $total_loan / $installments; // Weekly Pay
    $weekly_interest = ($expected_loan * ($loan_percentage / 100)) / $installments; // Weekly Interest

    return [
        'total_loan' => $total_loan,
        'emi_loan' => $emi_loan,
        'weekly_interest' => $weekly_interest,
        'installments' => $installments
    ];
}

// Calculate remaining loan amount (this could be updated to reflect actual payments)
function calculateAmountRemain($total_loan) {
    // Assuming the amount remain is equal to total loan for now
    // You can adjust this based on actual payments (if available in your DB)
    return $total_loan;
}

// Check if loan_id is provided in the URL
if (isset($_GET['loan_id']) && is_numeric($_GET['loan_id'])) {
    $loan_id = intval($_GET['loan_id']);
    $loan = getLoanApplicationById($mysqli, $loan_id);
} else {
    die("<p>Invalid request. Loan ID is missing or invalid.</p>");
}

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update'])) {
    // Check if all fields are set
    if (!isset($_POST['loan_id'], $_POST['name'], $_POST['expected_loan'], $_POST['loan_percentage'])) {
        die("<p>Form data is incomplete.</p>");
    }

    // Get and sanitize user inputs
    $loan_id = intval($_POST['loan_id']);
    $name = trim($_POST['name']);
    $expected_loan = floatval($_POST['expected_loan']);
    $loan_percentage = floatval($_POST['loan_percentage']);

    // Ensure values are valid
    if (empty($name) || $expected_loan <= 0 || $loan_percentage <= 0) {
        die("<p>Invalid input data. Please enter valid values.</p>");
    }

    // Recalculate loan values based on new expected loan and percentage
    $calculated_values = calculateLoanValues($expected_loan, $loan_percentage);
    $amount_remain = calculateAmountRemain($calculated_values['total_loan']); // New field calculation

    // Update query
    $query = "UPDATE tbl_loan_application 
              SET name = ?, expected_loan = ?, loan_percentage = ?, total_loan = ?, emi_loan = ?, 
                  weekly_interest = ?, installments = ?, amount_remain = ? 
              WHERE id = ?";
    $stmt = $mysqli->prepare($query);
    if (!$stmt) {
        die("Error preparing statement: " . $mysqli->error);
    }

    // Bind parameters and execute the update query
    $stmt->bind_param("siiiididi", $name, $expected_loan, $loan_percentage, $calculated_values['total_loan'], 
                      $calculated_values['emi_loan'], $calculated_values['weekly_interest'], 
                      $calculated_values['installments'], $amount_remain, $loan_id);
    $result = $stmt->execute();

    if ($result) {
        echo "<script>alert('Loan application updated successfully!'); window.location.href='loan_application.php';</script>";
        exit;
    } else {
        echo "<p>Failed to update loan application: " . $stmt->error . "</p>";
    }
}
?>

<!-- HTML for editing loan application -->
<div class="container mt-5">
    <h2>Edit Loan Application</h2>
    <form method="POST">
        <!-- Hidden field for Loan ID -->
        <input type="hidden" name="loan_id" value="<?php echo htmlspecialchars($loan_id); ?>">

        <div class="mb-3">
            <label for="name" class="form-label">Name</label>
            <input type="text" class="form-control" id="name" name="name" 
                   value="<?php echo htmlspecialchars($loan['name']); ?>" required>
        </div>

        <div class="mb-3">
            <label for="expected_loan" class="form-label">Expected Loan</label>
            <input type="number" class="form-control" id="expected_loan" name="expected_loan" 
                   value="<?php echo $loan['expected_loan']; ?>" required>
        </div>

        <div class="mb-3">
            <label for="loan_percentage" class="form-label">Loan Percentage</label>
            <input type="number" class="form-control" id="loan_percentage" name="loan_percentage" 
                   value="<?php echo $loan['loan_percentage']; ?>" required>
        </div>

        <button type="submit" name="update" class="btn btn-primary">Update Loan</button>
    </form>
</div>

<?php
include_once "inc/footer.php";  // Assuming you have a footer included
?>
