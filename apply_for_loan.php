<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<script>
 function calculateEMI() {
    var loan_amount = parseFloat(document.myform.loan_amount.value) || 0;
    var loan_percent = parseFloat(document.myform.loan_percent.value) || 0;
    var duration_weeks = parseFloat(document.myform.duration_weeks.value) || 0;
    var application_date = document.myform.application_date.value;
    var total_amount=0;

    if(loan_amount && loan_percent && duration_weeks){
        // Calculate total interest and total amount with interest
    var total_interest = loan_amount * (loan_percent / 100) * duration_weeks;
    total_amount = loan_amount + total_interest;
    document.myform.total_amount.value = total_amount.toFixed(2);
    }

  

    // Calculate weekly installments
    if (duration_weeks > 0) {
        document.myform.borrower_emi.value = (total_amount / duration_weeks).toFixed(2);
    } else {
        document.myform.borrower_emi.value = 0;
    }

    // Calculate Date of Payment
    if (application_date) {
        var paymentDate = calculatePaymentDate(application_date, duration_weeks);
        document.myform.payment_date.value = paymentDate;
    }
    
}

// Function to calculate the payment date
function calculatePaymentDate(applicationDate, durationWeeks) {
    var appDate = new Date(applicationDate); // Convert application date to Date object
    var paymentDate = new Date(appDate);
    paymentDate.setDate(appDate.getDate() + (durationWeeks * 7)); // Add duration in weeks

    // Format the payment date as YYYY-MM-DD
    var formattedDate = paymentDate.toISOString().split('T')[0];
    return formattedDate;
}

// Function to validate file type
function validateFileType() {
    var fileInput = document.myform.borrower_files;
    var filePath = fileInput.value;
    var allowedExtensions = /(\.pdf|\.doc|\.docx)$/i;

    if (!allowedExtensions.exec(filePath)) {
        alert('Invalid file type. Only PDF, DOC, and DOCX files are allowed.');
        fileInput.value = '';
        return false;
    }
    return true;
}
</script>

<?php 
  if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['submit_loan_application'])) {
    $inserted = $ml->applyForLoan($_POST, $_FILES);
  }
?>

<h3 class="page-heading mb-4">Loan Application Form</h3>
<h5 class="card-title p-3 bg-info text-white rounded">Fill up loan details</h5>
<div class="container">
  <?php if (isset($inserted)): ?>
    <div id="successMessage" class="alert alert-success alert-dismissible">
      <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
      <?php echo $inserted; ?>
    </div>
  <?php endif; ?>

  <?php 
    $name = ""; $b_id = "";
    if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['search'])) {
      $nid = $_POST['key'];
      $br = $emp->findBorrower($nid);
      if ($br) {
        $row = $br->fetch_assoc();
        $name = $row['name'];
        $b_id = $row['id'];
      } else {
        echo "<span class='text-center' style='color:red'>Borrower ID not matched or not applicable for loan</span>";
      }
    }
  ?>

  <form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="POST">
    <div class="form-group row">
      <label for="inputBorrowerFirstName" class="text-right col-2 font-weight-bold col-form-label">Search borrower:</label>                      
      <div class="col-sm-6">
        <input type="text" name="key" class="form-control" id="inputBorrowerFirstName" placeholder="Enter ID number of borrower" required>
      </div>
      <div class="col-sm-3">
        <input type="submit" class="btn btn-info" name="search" value="Search">
      </div>  
    </div>
  </form>

  <form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post" enctype="multipart/form-data" name="myform" id="myform" onsubmit="return validateFileType()">
    <div class="form-group row">
      <label for="borrower_name" class="text-right col-2 font-weight-bold col-form-label">Borrower Name</label>                      
      <div class="col-sm-9">
        <input type="text" name="borrower_name" class="form-control" value="<?php echo $name; ?>" readonly>
      </div>
    </div>

    <div class="form-group row">
      <label for="borrower_id" class="text-right col-2 font-weight-bold col-form-label">Borrower ID</label>                      
      <div class="col-sm-9">
        <input type="text" name="b_id" class="form-control" value="<?php echo $b_id; ?>" readonly>
      </div>
    </div>

    <div class="form-group row">
      <label for="loanamount" class="text-right col-2 font-weight-bold col-form-label">Expected Loan Amount</label>                      
      <div class="col-sm-9">
        <input type="number" onkeyup="calculateEMI()" name="loan_amount" class="form-control" id="loanamount" placeholder="Enter expected loan" required>
      </div>
    </div>

    <div class="form-group row">
      <label for="loanpercentage" class="text-right col-2 font-weight-bold col-form-label">Loan Percentage (weekly)</label>                      
      <div class="col-sm-9">
        <input type="number" onkeyup="calculateEMI()" name="loan_percent" class="form-control" id="loanpercentage" placeholder="Enter loan percent per week" required>
      </div>
    </div>

    <div class="form-group row">
      <label for="application_date" class="text-right col-2 font-weight-bold col-form-label">Date of Application</label>                      
      <div class="col-sm-9">
        <input type="date" name="application_date" id="application_date" class="form-control" required onchange="calculateEMI()" value="<?php echo date('Y-m-d'); ?>">

      </div>
    </div>

    <div class="form-group row">
      <label for="duration_weeks" class="text-right col-2 font-weight-bold col-form-label">Loan Duration (weeks)</label>                      
      <div class="col-sm-9">
        <input type="number" onkeyup="calculateEMI()" name="duration_weeks" class="form-control" placeholder="Enter loan duration in weeks" required>
      </div>
    </div>

    <div class="form-group row">
      <label for="payment_date" class="text-right col-2 font-weight-bold col-form-label">Date of Payment</label>                      
      <div class="col-sm-9">
        <input type="date" name="payment_date" id="payment_date" class="form-control" readonly>
      </div>
    </div>

    <div class="form-group row">
      <label class="text-right col-2 font-weight-bold col-form-label">Total Amount (including interest)</label>                      
      <div class="col-sm-9">
        <input type="text" name="total_amount" class="form-control" readonly required>
      </div>
    </div>

    <div class="form-group row">
      <label for="inputBorrowerMobile" class="text-right col-2 font-weight-bold col-form-label">Weekly Payments</label>  
      <div class="col-sm-9">
        <input type="text" name="borrower_emi" class="form-control positive-integer" id="inputBorrowerMobile" readonly required>
      </div>
    </div>

    <hr>
   <!-- <div class="form-group row">
      <label for="borrower_files" class="text-right font-weight-bold col-2 col-form-label">Borrower Files<br>(doc, docx, and pdf only)</label>
      <div class="col-sm-9">    
        <input type="file" name="borrower_files" required>
      </div>
    </div> -->
<div class="form-group row">
  <label for="bank_name" class="text-right col-2 font-weight-bold col-form-label">Select Bank</label>
  <div class="col-sm-9">
    <select name="bank_name" id="bank_name" class="form-control" required>
      <option value="">-- Choose Bank --</option>
      <option value="Sidian Bank">Sidian Bank</option>
      <option value="Equity Bank">Equity Bank</option>
    </select>
  </div>
</div>

<div class="form-group row">
  <div class="col-md-6">
    <input type="submit" name="submit_loan_application" class="btn btn-info pull-right" value="Submit Application">
  </div>
</div>


<?php
include_once "inc/footer.php";
?>