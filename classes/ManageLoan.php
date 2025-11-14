<?php
$filepath = realpath(dirname(__FILE__));
include_once ($filepath."/../libs/CrudOperation.php");
include_once ($filepath."/../helpers/Format.php");

/**
* Sample Class for photo uploading, insert data, update data and others.
*/
class ManageLoan
{
	private $db;
	private $fm;
	function __construct()
	{
		$this->db = new CrudOperation();
		$this->fm = new Format();
	}

	function showPath(){
		return realpath(dirname(__FILE__));
	}
	function dbcon(){
		return $this->db->link;
	}
public function applyForLoan($data)
{
    // Validate input fields
    $b_id = $this->fm->validation($data['b_id']);
    $borrower_name = $this->fm->validation($data['borrower_name']);
    $loan_amount = $this->fm->validation($data['loan_amount']);
    $loan_percent = $this->fm->validation($data['loan_percent']);
    $installments = isset($data['duration_weeks']) ? $data['duration_weeks'] : 0;
    $total_amount = $this->fm->validation($data['total_amount']);
    $borrower_emi = $this->fm->validation($data['borrower_emi']);
    $application_date = $this->fm->validation($data['application_date']);
    $payment_date = $this->fm->validation($data['payment_date']);
    $bank_name = $this->fm->validation($data['bank_name']);

    // Check for empty fields and provide specific error messages
    if (empty($b_id)) {
        return "<span class='error'>Borrower ID is required!</span>";
    }

    if (empty($borrower_name)) {
        return "<span class='error'>Borrower name is required!</span>";
    }

    if (empty($loan_amount)) {
        return "<span class='error'>Loan amount is required!</span>";
    }

    if ($loan_amount <= 0) {
        return "<span class='error'>Loan amount must be greater than zero.</span>";
    }

    if (empty($loan_percent)) {
        return "<span class='error'>Loan percentage is required!</span>";
    }

    if ($loan_percent <= 0 || $loan_percent > 100) {
        return "<span class='error'>Loan percentage must be a positive number between 0 and 100.</span>";
    }

    if (empty($installments)) {
        return "<span class='error'>Installments are required!</span>";
    }

    if (empty($total_amount)) {
        return "<span class='error'>Total amount is required!</span>";
    }

    if (empty($borrower_emi)) {
        return "<span class='error'>Borrower EMI is required!</span>";
    }

    if (empty($payment_date)) {
        return "<span class='error'>Payment date is required!</span>";
    }
    
    if (empty($bank_name)) {
        return "<span class='error'>Bank selection is required!</span>";
    }

    // Insert Data into the database
    $query = "INSERT INTO tbl_loan_application(
        b_id, 
        name, 
        expected_loan, 
        loan_percentage, 
        installments, 
        total_loan, 
        emi_loan, 
        amount_remain, 
        remain_inst, 
        application_date,
        payment_date,
        bank_name
    ) 
    VALUES (
        '$b_id',
        '$borrower_name',
        '$loan_amount',
        '$loan_percent',
        '$installments',
        '$total_amount',
        '$borrower_emi',
        '$total_amount',
        '$installments',
        '$application_date',
        '$payment_date',
        '$bank_name'
    )";

    $inserted = $this->db->insert($query);
    if ($inserted) {
        return "<span class='success'>Loan Application submitted successfully.</span>";
    } else {
        return "<span class='error'>Failed to submit loan application.</span>";
    }
}


	public function viewLoanApplication()
	{
		//get all borrower data
		$sql = "SELECT tbl_borrower.*, tbl_loan_application.*
			    FROM tbl_borrower
				INNER JOIN tbl_loan_application
				ON tbl_borrower.id = tbl_loan_application.b_id
		 		ORDER BY tbl_loan_application.id DESC";
		$result = $this->db->select($sql);
		return $result;
	}
	
	

	public function viewLoanApplicationNotVerified()
	{
		//get all borrower data
		$sql = "SELECT tbl_borrower.*, tbl_loan_application.*
			    FROM tbl_borrower
				INNER JOIN tbl_loan_application
				ON tbl_borrower.id = tbl_loan_application.b_id
				WHERE tbl_loan_application.status != 3
		 		ORDER BY tbl_loan_application.id";
		$result = $this->db->select($sql);
		return $result;
	}

	public function getLoanById($loan_id)
	{
		$sql = "SELECT * FROM tbl_loan_application WHERE id='$loan_id' ";
		$result = $this->db->select($sql);
		return $result;	
	}


	public function getLoanVerificationStatus($loan_id, $role_id)
	{	
		if ($role_id == 1) {
			$sql = "UPDATE tbl_loan_application SET status = 3 WHERE id = '$loan_id' ";

		}else if($role_id == 1){
			$sql = "UPDATE tbl_loan_application SET status = 3 WHERE id = '$loan_id' ";
			
		}else{
			$sql = "UPDATE tbl_loan_application SET status = 3 WHERE id = '$loan_id' ";
		}
		
		$updated = $this->db->update($sql);
		if ($updated) {
			$msg = "<span style='color:green'>Successfully verified!</span>";
			return $msg;
		}else{
			$msg = "<span style='color:red'>Failed to verify!</span>";
			return $msg;
		}
	}


	public function getApprovedLoan($b_id)
	{
		//get all borrower data
		$sql = "SELECT tbl_borrower.*, tbl_loan_application.*
			    FROM tbl_borrower
				INNER JOIN tbl_loan_application
				ON tbl_borrower.id = tbl_loan_application.b_id
				WHERE tbl_loan_application.status = 3 AND tbl_loan_application.b_id = '$b_id'
		 		ORDER BY tbl_loan_application.id DESC";
		$result = $this->db->select($sql);
		return $result;
	}

	//get upapproved loan
	public function getNotApproveLoan()
	{
		$sql = "SELECT * FROM tbl_loan_application WHERE status != 3 ";
		$result = $this->db->select($sql);
		if ($result) {
			$result = $result->num_rows;
			return $result;
		}else{
			return 0;
		}
		
			
	}

public function getAllApproveLoan()
{
    $sql = "SELECT * FROM tbl_loan_application 
            INNER JOIN tbl_borrower ON tbl_loan_application.b_id = tbl_borrower.id 
            WHERE tbl_loan_application.status = 3 
            AND (TRIM(tbl_borrower.name) != '' AND tbl_borrower.name IS NOT NULL)";
    $result = $this->db->select($sql);
    if ($result) {
        return $result->num_rows;  // Returns the number of approved loans with non-blank borrower names
    } else {
        return 0;  // No results found
    }
}


public function totalPaidLoanAmount()
{
    $sql = "SELECT SUM(amount) AS total_money FROM tbl_payment";
    $result = $this->db->select($sql);
    
    return $result;
}
public function totalPaidLoanAmountError()
{
    $sql = "SELECT SUM(GREATEST(pay_amount - Interest, 0)) as total_money FROM tbl_payment";
    $result = $this->db->select($sql);
    
    return $result;
}



public function getTotalLoanAmount() {
    $query = "SELECT SUM(expected_loan) AS expected_loan_amount FROM tbl_loan_application"; // Adjust table name accordingly

    // Execute the query
    $result = $this->db->select($query); // Use your database class method to execute the query

    if ($result) {
        $row = $result->fetch_assoc(); // Fetch the associative array
        return (float) $row['expected_loan_amount'] ?? 0; // Return the value as a float, defaulting to 0
    }
    return 0; // Return 0 if there’s no result
}
	//get loan not paid
	public function getApprovedLoanNotPaid($b_id)
	{
		//get all borrower data
		$sql = "SELECT tbl_borrower.*, tbl_loan_application.*
			    FROM tbl_borrower
				INNER JOIN tbl_loan_application
				ON tbl_borrower.id = tbl_loan_application.b_id
				WHERE tbl_loan_application.status = 3 AND tbl_loan_application.b_id = '$b_id' AND tbl_loan_application.total_loan > tbl_loan_application.amount_paid
		 		ORDER BY tbl_loan_application.id DESC";
		$result = $this->db->select($sql);
		return $result;	
	}

public function payLoan($data)
{
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    $b_id = $this->fm->validation($data['b_id']);
    $loan_id = $this->fm->validation($data['loan_id']);
    $payment = $this->fm->validation($data['pay']);
    $pay_date = $this->fm->validation($data['pay_date']);
    $current_inst = $this->fm->validation($data['current_inst']);
    $remain_inst = $this->fm->validation($data['remain_inst']);
    $fine = isset($data['fine_amount']) ? $data['fine_amount'] : 0;

    // Fetch the current amounts and interest from the database
    $loanDetails = $this->db->select("SELECT amount_paid, amount_remain, interest FROM tbl_loan_application WHERE id='$loan_id'");
    $loan = $loanDetails->fetch_assoc();
    $interest = $loan['interest']; // Fetch the interest amount

    // Calculate the next payment date
    $next_date = isset($data['next_date']) ? $data['next_date'] : date('Y-m-d', strtotime('+7 days', strtotime($pay_date)));
    $paymentDate = date('Y-m-d', strtotime($pay_date . " + " . ($remain_inst * 7) . " days"));

    // Check for required fields
    if (empty($b_id) || empty($loan_id) || empty($payment) || empty($pay_date) || empty($current_inst)) {
        return "<span style='color:red'>Error....!</span>";
    } else {
        // If the payment is less than interest
        if ($payment <= $interest) {
            $remain_amount = $loan['amount_remain'] - $payment;
            // Calculate the amount to be saved in tbl_payment (0 in this case)
            $amount = 0;
            
            // Insert the payment, including interest
            $query = "INSERT INTO tbl_payment(b_id, loan_id, pay_date, current_inst, remain_inst, fine, interest, amount) 
                      VALUES('$b_id', '$loan_id', '$pay_date', '$current_inst', '$remain_inst', '$fine', '$payment', '$amount')";
            $inserted = $this->db->insert($query);

            if ($inserted) {
                // Update the loan application with the new amounts
                $updateSql = "UPDATE tbl_loan_application 
                              SET amount_remain = '$remain_amount', 
                                  current_inst = '$current_inst', 
                                  remain_inst = '$remain_inst', 
                                  next_date = '$next_date',
                                  payment_date='$paymentDate' 
                              WHERE id = '$loan_id'";
                $this->db->update($updateSql);

                return "<span class='success'>Loan payment submitted successfully.</span>";
            } else {
                return "<span class='error'>Failed to submit.</span>";
            }

        } else {
            // If the payment is enough to cover the interest
            $paymentTowardsPrincipal = $payment - $interest;
            // Calculate the new paid amount and remaining amount
            $new_paid_amount = $loan['amount_paid'] + $paymentTowardsPrincipal;
            $remain_amount = $loan['amount_remain'] - $paymentTowardsPrincipal;

            // Calculate the amount to be saved in tbl_payment
            $amount = $payment - $interest;
            
            // Insert the payment, including interest
            $query = "INSERT INTO tbl_payment(b_id, loan_id, pay_amount, pay_date, current_inst, remain_inst, fine, interest, amount) 
                      VALUES('$b_id', '$loan_id', '$payment', '$pay_date', '$current_inst', '$remain_inst', '$fine', '$interest', '$amount')";
            $inserted = $this->db->insert($query);

            if ($inserted) {
                // Update the loan application with the new amounts
                $updateSql = "UPDATE tbl_loan_application 
                              SET amount_paid = '$new_paid_amount', 
                                  amount_remain = '$remain_amount', 
                                  current_inst = '$current_inst', 
                                  remain_inst = '$remain_inst', 
                                  next_date = '$next_date' 
                              WHERE id = '$loan_id'";
                $this->db->update($updateSql);

                return "<span class='success'>Loan payment submitted successfully.</span>";
            } else {
                return "<span class='error'>Failed to submit.</span>";
            }
        }
    }
}

	//find payment info

	public function findPayment($b_id, $loan_id)
	{
		//get all borrower data by nid
		$sql = "SELECT * FROM tbl_payment WHERE b_id='$b_id' AND loan_id ='$loan_id' ";
		$result = $this->db->select($sql);
		return $result;
	}

	//generate payment report
	public function paymentReport($loan_id, $pay_id, $b_id)
	{
		$sql = "SELECT tbl_payment.*, tbl_loan_application.*
		    FROM tbl_payment
			INNER JOIN tbl_loan_application
			ON tbl_payment.loan_id = tbl_loan_application.id
			WHERE tbl_payment.b_id = '$b_id' AND tbl_payment.loan_id = '$loan_id' AND tbl_payment.id = '$pay_id' ";
		$result = $this->db->select($sql);
		return $result;	
	}

	//property sell details
	public function propertySellDetails($data)
	{
		$b_id = $this->fm->validation($data['b_id']);
		
		$loan_id = $this->fm->validation($data['loan_id']);

		$property_name = $this->fm->validation($data['property_name']);

		$property_details = $this->fm->validation($data['property_details']);
		
		$price = $this->fm->validation($data['price']);

		$pay_remaining_loan = $this->fm->validation($data['pay_remaining_loan']);
		
		$return_money = $price - $pay_remaining_loan;

		$amount_paid = $this->fm->validation($data['amount_paid']);

		$amount_paid = $amount_paid + $pay_remaining_loan;

		if (empty($price) or empty($property_name) or empty($property_details) or empty($pay_remaining_loan) or empty($amount_paid) )
		{
			$msg = "<span style='color:red'>Empty field !</span>";
			return $msg;
		}else{
			$query = "INSERT INTO tbl_liability(b_id,loan_id,property_name,property_details,price,pay_remaining_loan, return_money) 
				VALUES('$b_id','$loan_id','$property_name','$property_details','$price','$pay_remaining_loan','$return_money')";

			$inserted = $this->db->insert($query);
			if ($inserted) {

				$updateSql = "UPDATE tbl_loan_application SET amount_paid = '$amount_paid', amount_remain = 0 WHERE id = '$loan_id' ";

				$up = $this->db->update($updateSql);

				$msg = "<span class='success'>Due loan paid and property selling details saved !</span>";
				return $msg;
			}else{
				$msg = "<span class='error'>Failed to insert.</span>";
				return $msg;
			}
		}
	}

	//view liabiility details

	public function viewLiabilityDetails()
	{
		//get all borrower data
		$sql = "SELECT tbl_borrower.*, tbl_liability.*
			    FROM tbl_borrower
				INNER JOIN tbl_liability
				ON tbl_borrower.id = tbl_liability.b_id
		 		ORDER BY tbl_liability.id DESC";
		$result = $this->db->select($sql);
		return $result;
	}
// Get Weekly Profit
public function getWeeklyProfit() {
    // Query to get the total paid in the last week and total disbursed amount
    $query = "SELECT 
                SUM(pay_amount) - la.total_loan AS weekly_profit
              FROM tbl_loan_application la
              LEFT JOIN tbl_payment p ON p.loan_id = la.id
              WHERE p.pay_date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)";
    $result = $this->db->select($query);
    $row = $result->fetch_assoc();
    return (float) $row['weekly_profit'] ?? 0;
}
public function getMonthlyProfit() {
    // Query to get the total paid in the last month and total disbursed amount
    $query = "SELECT 
                SUM(pay_amount) - la.total_loan AS monthly_profit
              FROM tbl_loan_application la
              LEFT JOIN tbl_payment p ON p.loan_id = la.id
              WHERE p.pay_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)";
    $result = $this->db->select($query);
    $row = $result->fetch_assoc();
    return (float) $row['monthly_profit'] ?? 0;
}
public function getTotalProfit() {
    // SQL query to sum the interest from tbl_payment
    $query = "SELECT SUM(interest) AS total_interest FROM tbl_payment";

    // Execute the query
    $result = $this->db->select($query);

    // Fetch the result
    $row = $result->fetch_assoc();

    // Return the total interest
    return (float) $row['total_interest'] ?? 0;
}



public function getTotalInterestEarned() {
    $query = "SELECT SUM(Interest) AS Interest_amount FROM tbl_payment"; 

    // Execute the query
    $result = $this->db->select($query); // Use your database class method to execute the query

    if ($result) {
        $row = $result->fetch_assoc(); // Fetch the associative array
        return (float) $row['Interest_amount'] ?? 0; // Return the value as a float, defaulting to 0
    }
    return 0; // Return 0 if there’s no result
}


public function getTotalDisbursedAmount() {
    $query = "SELECT SUM(Interest) AS Interest_amount FROM tbl_payment"; 

    // Execute the query
    $result = $this->db->select($query); // Use your database class method to execute the query

    if ($result) {
        $row = $result->fetch_assoc(); // Fetch the associative array
        return (float) $row['Interest_amount'] ?? 0; // Return the value as a float, defaulting to 0
    }
    return 0; // Return 0 if there’s no result
}
public function getInterestForIntervals() {
    // Get the current month and year
    $currentMonth = date('m');
    $currentYear = date('Y');

    // Get the first day of the current month
    $startDate = date('Y-m-01', strtotime("$currentYear-$currentMonth"));
    $lastDayOfMonth = date('Y-m-t', strtotime($startDate)); // Last day of the month

    // Initialize an array to hold the results for each interval
    $results = [];

    // Loop through the month in weekly intervals
    while (strtotime($startDate) <= strtotime($lastDayOfMonth)) {
        // Calculate the end date for the current interval (6 days after start)
        $endDate = date('Y-m-d', strtotime('+6 days', strtotime($startDate)));

        // If the end date exceeds the last day of the month, adjust it
        if (strtotime($endDate) > strtotime($lastDayOfMonth)) {
            $endDate = $lastDayOfMonth;
        }

        // SQL query to sum the interest for the given interval
        $query = "SELECT SUM(Interest) AS Interest_amount 
                  FROM tbl_payment 
                  WHERE pay_date BETWEEN '$startDate' AND '$endDate'";

        // Execute the query
        $result = $this->db->select($query); // Use your database class method to execute the query

        // Fetch the result and store it in the results array
        if ($result) {
            $row = $result->fetch_assoc(); // Fetch the associative array
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalInterest' => (float) $row['Interest_amount'] ?? 0
            ];
        } else {
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalInterest' => 0
            ];
        }

        // Move to the next interval (start date of the next week)
        $startDate = date('Y-m-d', strtotime('+7 days', strtotime($startDate)));
    }

    // Return the results for all intervals
    return $results;
}

public function getInterestForMonthlyIntervals() {
    // Get the current year
    $currentYear = date('Y');

    // Initialize an array to hold the results for each month
    $results = [];

    // Loop through each month of the year
    for ($month = 1; $month <= 12; $month++) {
        // Format the start and end dates for the current month
        $startDate = date('Y-m-01', strtotime("$currentYear-$month-01"));
        $endDate = date('Y-m-t', strtotime($startDate)); // Last day of the month

        // SQL query to sum the interest for the given month
        $query = "SELECT SUM(Interest) AS Interest_amount 
                  FROM tbl_payment 
                  WHERE pay_date BETWEEN '$startDate' AND '$endDate'";

        // Execute the query
        $result = $this->db->select($query); // Use your database class method to execute the query

        // Fetch the result and store it in the results array
        if ($result) {
            $row = $result->fetch_assoc(); // Fetch the associative array
            $results[] = [
                'month' => date('F', strtotime($startDate)), // Convert month number to name
                'totalInterest' => (float) $row['Interest_amount'] ?? 0
            ];
        } else {
            $results[] = [
                'month' => date('F', strtotime($startDate)),
                'totalInterest' => 0
            ];
        }
    }

    // Return the results for all months
    return $results;
}

public function getAmountForWeeklyIntervals() {
    // Get the current month and year
    $currentMonth = date('m');
    $currentYear = date('Y');

    // Get the first and last day of the month
    $startDate = date('Y-m-01', strtotime("$currentYear-$currentMonth"));
    $lastDayOfMonth = date('Y-m-t', strtotime($startDate));

    // Initialize an array to hold the results for each week
    $results = [];

    // Loop through the month in weekly intervals
    while (strtotime($startDate) <= strtotime($lastDayOfMonth)) {
        // Calculate the end date for the current interval (6 days after start)
        $endDate = date('Y-m-d', strtotime('+6 days', strtotime($startDate)));

        // If the end date exceeds the last day of the month, adjust it
        if (strtotime($endDate) > strtotime($lastDayOfMonth)) {
            $endDate = $lastDayOfMonth;
        }

        // SQL query to sum the reduced amount for the given week
        $query = "SELECT SUM(amount) AS Reduced_amount 
                  FROM tbl_payment 
                  WHERE pay_date BETWEEN '$startDate' AND '$endDate'";

        // Execute the query
        $result = $this->db->select($query); // Use your database class method to execute the query

        // Fetch the result and store it in the results array
        if ($result) {
            $row = $result->fetch_assoc();
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalamount' => (float) $row['Reduced_amount'] ?? 0
            ];
        } else {
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalamount' => 0
            ];
        }

        // Move to the next week (7 days forward)
        $startDate = date('Y-m-d', strtotime('+7 days', strtotime($startDate)));
    }

    // Return the results for all weeks
    return $results;
}

public function getAmountForMonthlyIntervals() {
    // Get the current year
    $currentYear = date('Y');

    // Initialize an array to hold the results for each month
    $results = [];

    // Loop through each month of the year
    for ($month = 1; $month <= 12; $month++) {
        // Format the start and end dates for the current month
        $startDate = date('Y-m-01', strtotime("$currentYear-$month-01"));
        $endDate = date('Y-m-t', strtotime($startDate)); // Last day of the month

        // SQL query to sum the interest for the given month
        $query = "SELECT SUM(amount) AS Reduced_amount 
                  FROM tbl_payment 
                  WHERE pay_date BETWEEN '$startDate' AND '$endDate'";

        // Execute the query
        $result = $this->db->select($query); // Use your database class method to execute the query

        // Fetch the result and store it in the results array
        if ($result) {
            $row = $result->fetch_assoc(); // Fetch the associative array
            $results[] = [
                'month' => date('F', strtotime($startDate)), // Convert month number to name
                'totalamount' => (float) $row['Reduced_amount'] ?? 0
            ];
        } else {
            $results[] = [
                'month' => date('F', strtotime($startDate)),
                'totalamount' => 0
            ];
        }
    }

    // Return the results for all months
    return $results;
}
public function getDisbursedForWeeklyIntervals() {
    // Get the current month and year
    $currentMonth = date('m');
    $currentYear = date('Y');

    // Get the first and last day of the month
    $startDate = date('Y-m-01', strtotime("$currentYear-$currentMonth"));
    $lastDayOfMonth = date('Y-m-t', strtotime($startDate));

    // Initialize an array to hold the results for each week
    $results = [];

    // Loop through the month in weekly intervals
    while (strtotime($startDate) <= strtotime($lastDayOfMonth)) {
        // Calculate the end date for the current interval (6 days after start)
        $endDate = date('Y-m-d', strtotime('+6 days', strtotime($startDate)));

        // If the end date exceeds the last day of the month, adjust it
        if (strtotime($endDate) > strtotime($lastDayOfMonth)) {
            $endDate = $lastDayOfMonth;
        }

        // SQL query to sum the reduced amount for the given week
        $query = "SELECT SUM(expected_loan) AS disbursed_amount 
                  FROM tbl_loan_application 
                  WHERE application_date BETWEEN '$startDate' AND '$endDate'";

        // Execute the query
        $result = $this->db->select($query); // Use your database class method to execute the query

        // Fetch the result and store it in the results array
        if ($result) {
            $row = $result->fetch_assoc();
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalamount' => (float) $row['disbursed_amount'] ?? 0
            ];
        } else {
            $results[] = [
                'interval' => "$startDate to $endDate",
                'totalamount' => 0
            ];
        }

        // Move to the next week (7 days forward)
        $startDate = date('Y-m-d', strtotime('+7 days', strtotime($startDate)));
    }

    // Return the results for all weeks
    return $results;
}
public function getDisbursedForMonthlyIntervals() {
    $currentYear = date('Y');
    $results = [];

    for ($month = 1; $month <= 12; $month++) {
        $startDate = date('Y-m-01', strtotime("$currentYear-$month-01"));
        $endDate = date('Y-m-t', strtotime($startDate));

        $query = "SELECT SUM(expected_loan) AS totalamount
                  FROM tbl_loan_application
                  WHERE application_date BETWEEN '$startDate' AND '$endDate'";

        $result = $this->db->select($query);

        if ($result) {
            $row = $result->fetch_assoc();
            $results[] = [
                'month' => $startDate,
                'totalamount' => (float) ($row['totalamount'] ?? 0)
            ];
        } else {
            $results[] = [
                'month' => $startDate,
                'totalamount' => 0
            ];
        }
    }

    return $results;
}




	//Renew loan
public function renewLoan($data)
{
    $b_id = $this->fm->validation($data['b_id']);
    $loan_id = $this->fm->validation($data['loan_id']);
    $payment = $this->fm->validation($data['pay']);
    $pay_date = $this->fm->validation($data['pay_date']);
    $current_inst = $this->fm->validation($data['current_inst']);
    $remain_inst = $this->fm->validation($data['remain_inst']);
    $fine = isset($data['fine_amount']) ? $data['fine_amount'] : 0;

    // Fetch the current amounts from the database
    $loanDetails = $this->db->select("SELECT amount_paid, amount_remain FROM tbl_loan_application WHERE id='$loan_id'");
    $loan = $loanDetails->fetch_assoc();


    // Calculate the new paid amount and remaining amount
    // $new_paid_amount = $loan['interest'] + $payment;
    $remain_amount = $loan['amount_remain'];

    $next_date = isset($data['next_date']) ? $data['next_date'] : date('Y-m-d', strtotime('+7 days', strtotime($pay_date)));
    $paymentDate = date('Y-m-d', strtotime($pay_date . " + " . ($remain_inst * 7) . " days"));
    

    // Check for required fields
    if (empty($b_id) || empty($loan_id) || empty($payment) || empty($pay_date) || empty($current_inst)) {
        return "<span style='color:red'>Error....!</span>";
    } else {
        // Insert the payment
        $query = "INSERT INTO tbl_payment(b_id, loan_id, Interest, pay_date, current_inst, remain_inst, fine) 
                  VALUES('$b_id', '$loan_id', ' $payment', '$pay_date', '$current_inst', '$remain_inst', '$fine')";
        $inserted = $this->db->insert($query);

        if ($inserted) {
            // Update the loan application with the new amounts
            $updateSql = "UPDATE tbl_loan_application 
                           SET  
                               amount_remain = '$remain_amount', 
                               current_inst = '$current_inst', 
                               remain_inst = '$remain_inst', 
                               next_date = '$next_date',
                               payment_date='$paymentDate'
                           WHERE id = '$loan_id'";
            $this->db->update($updateSql);

            return "<span class='success'>Loan renewed successfully.</span>";
        } else {
            return "<span class='error'>Failed to renew.</span>";
        }
    }
}
public function getLoansDueAndOverdue()
{
    $sql = "
        SELECT tbl_borrower.*, tbl_loan_application.*
        FROM tbl_borrower
        INNER JOIN tbl_loan_application
        ON tbl_borrower.id = tbl_loan_application.b_id
        WHERE tbl_loan_application.payment_date <= CURDATE()
          AND tbl_loan_application.status = 3
    ";
    $result = $this->db->select($sql);
    return $result;
}

public function reduceLoan($data)
{
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    $b_id = $this->fm->validation($data['b_id']);
    $loan_id = $this->fm->validation($data['loan_id']);
    $payment = $this->fm->validation($data['pay']);
    $pay_date = $this->fm->validation($data['pay_date']);
    $current_inst = $this->fm->validation($data['current_inst']);
    $remain_inst = $this->fm->validation($data['remain_inst']);
    $fine = isset($data['fine_amount']) ? $data['fine_amount'] : 0;

    // Fetch the current amounts and interest from the database
    $loanDetails = $this->db->select("SELECT amount_paid, amount_remain, interest FROM tbl_loan_application WHERE id='$loan_id'");
    $loan = $loanDetails->fetch_assoc();
    // $interest = $loan['interest']; // Fetch the interest amount

    // Calculate the next payment date
    $next_date = isset($data['next_date']) ? $data['next_date'] : date('Y-m-d', strtotime('+7 days', strtotime($pay_date)));
    $paymentDate = date('Y-m-d', strtotime($pay_date . " + " . ($remain_inst * 7) . " days"));

    // Check for required fields
    if (empty($b_id) || empty($loan_id) || empty($payment) || empty($pay_date) || empty($current_inst)) {
        return "<span style='color:red'>Error....!</span>";
       

        } else {
            // Calculate the new paid amount and remaining amount
            $new_paid_amount = $loan['amount_paid'] + $payment;
            $remain_amount = $loan['amount_remain'] - $payment;

            // Calculate the amount to be saved in tbl_payment
            $amount = $payment;
            
            // Insert the payment, including interest
            $query = "INSERT INTO tbl_payment(b_id, loan_id, pay_amount, pay_date, current_inst, remain_inst, fine, amount) 
                      VALUES('$b_id', '$loan_id', '$payment', '$pay_date', '$current_inst', '$remain_inst', '$fine', '$amount')";
            $inserted = $this->db->insert($query);

            if ($inserted) {
                // Update the loan application with the new amounts
                $updateSql = "UPDATE tbl_loan_application 
                              SET amount_paid = '$new_paid_amount', 
                                  amount_remain = '$remain_amount', 
                                  current_inst = '$current_inst', 
                                  remain_inst = '$remain_inst', 
                                  next_date = '$next_date' 
                              WHERE id = '$loan_id'";
                $this->db->update($updateSql);

                return "<span class='success'>Loan reduced successfully.</span>";
            } else {
                return "<span class='error'>Failed to reduce Loan.</span>";
            }
        }
    }


//end of ManageLoan class
}
?>