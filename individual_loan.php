<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";

    if (isset($_GET['loan_id']) && isset($_GET['b_id'])) {
        $loan_id = $_GET['loan_id'];
        $b_id = $_GET['b_id'];
    }
?>  

<?php 
  $borrower = $emp->findBorrowerById($b_id);
  if ($borrower) {
    while ($row = $borrower->fetch_assoc()) {
?>
   <div class="list-group">
       <a class="list-group-item">Name: <?php echo $row['name']; ?></a>
       <a class="list-group-item">ID: <?php echo $row['nid']; ?></a>
       <a class="list-group-item">Date of Application: <?php echo $row['dob']; ?></a>
       <a class="list-group-item">Phone: <?php echo $row['mobile']; ?></a>
       <a class="list-group-item">Address: <?php echo $row['address']; ?></a>
   </div>
<?php
    }
  } 
?>

<hr>
<div class="row mb-4">
  <a href="loan_status.php" class="btn btn-primary ml-4">Back to loan status</a>
</div>

<div class="card-body">
  <h5 class="card-title mb-4">Loan Payment history</h5>

  <div class="payment-history">
    <?php 
    $payment = $ml->findPayment($b_id, $loan_id);
    $i = 0;
    $sum = 0;
    $inst = 0;

    if ($payment) {
      while ($pay = $payment->fetch_assoc()) {
        $i++;
        $sum = $sum + $pay['pay_amount'];
        $inst = $inst + $pay['current_inst'];
    ?>
    
    <div class="payment-entry">
      <div class="payment-header" data-toggle="collapse" data-target="#payment-info-<?php echo $pay['id']; ?>">
        <strong>Pay Date:</strong> <?php echo $pay['pay_date']; ?>
      </div>

      <div id="payment-info-<?php echo $pay['id']; ?>" class="collapse payment-details">
        <div class="payment-info">
          <p><strong>Amount Paid:</strong> <?php echo $pay['pay_amount']; ?></p>
          <p><strong>Amount Reduced:</strong> <?php echo $pay['amount']; ?></p>
          <p><strong>Paid Interest:</strong> <?php echo $pay['Interest']; ?></p>
          <p><strong>Installment:</strong> <?php echo $pay['current_inst']; ?></p>
          <p><strong>Fine:</strong> <?php echo $pay['fine']; ?></p>
          <p><strong>Payment Report:</strong> <a target="_blank" href="payment_report.php?loan_id=<?php echo $pay['loan_id']; ?>&pay_id=<?php echo $pay['id']; ?>&b_id=<?php echo $pay['b_id']; ?>">View Report</a></p>
        </div>
      </div>
    </div>

    <?php
      }
    } 
    ?>
  </div>
</div>

<?php
include_once "inc/footer.php";
?>

<!-- Add necessary JS for Bootstrap collapse functionality -->
<script>
  $(document).ready(function() {
    // Toggle collapse functionality when clicking on the date row
    $('.payment-header').click(function() {
      var target = $(this).data('target');
      $(target).collapse('toggle');
    });
  });
</script>

<!-- Optional CSS for styling -->
<style>
  .payment-history {
    margin-top: 20px;
  }

  .payment-entry {
    border: 1px solid #ddd;
    margin-bottom: 10px;
    border-radius: 5px;
    padding: 10px;
  }

  .payment-header {
    background-color: #f8f9fa;
    padding: 10px;
    font-size: 1.1em;
    cursor: pointer;
    border-radius: 4px;
  }

  .payment-details {
    margin-top: 10px;
    background-color: #f1f1f1;
    padding: 10px;
    border-radius: 4px;
  }

  .payment-info p {
    margin: 5px 0;
  }

  /* Make payment details hidden by default on mobile */
  @media (max-width: 768px) {
    .payment-details {
      display: none;
    }

    .payment-header:after {
      content: " ▼";
    }

    .payment-header.collapsed:after {
      content: " ►";
    }
  }
</style>
