<?php
include_once "inc/header.php";
include_once "inc/sidebar.php";
?>

<h3 class="page-heading mb-4">Dashboard</h3>
<div class="row">

  <!-- Pending Loan Applications -->
  <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
    <div class="card card-statistics">
      <div class="card-body">
        <div class="clearfix">
          <div class="float-left">
            <h4 class="text-primary">
              <i class="fa fa-bell highlight-icon" aria-hidden="true"></i>
            </h4>
          </div>
          <div class="float-right text-right">
            <p class="card-text text-dark">Pending Loan Applications</p>
            <h4 class="bold-text">
              <?php
                $all = $ml->getNotApproveLoan();
                echo $all;
              ?>
            </h4>
          </div>
        </div>
        <p class="text-muted">
          <i class="fa fa-repeat mr-1" aria-hidden="true"></i> Just Updated
        </p>
      </div>
    </div>
  </div>

  <!-- Borrowers -->
  <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
    <a href="viewborrowerlist.php" style="text-decoration: none;">
      <div class="card card-statistics">
        <div class="card-body">
          <div class="clearfix">
            <div class="float-left">
              <h4 class="text-danger">
                <i class="fa fa-users highlight-icon" aria-hidden="true"></i>
              </h4>
            </div>
            <div class="float-right">
              <p class="card-text text-dark">Borrowers</p>
              <h4 class="bold-text">
                <?php
                  $all = $emp->viewBorrower();
                  echo $all ? $all->num_rows : "0";
                ?>
              </h4>
            </div>
          </div>
        </div>
      </div>
    </a>
  </div>

  <!-- Active Loans -->
  <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
    <a href="activeloans.php" style="text-decoration: none;">
      <div class="card card-statistics">
        <div class="card-body">
          <div class="clearfix">
            <div class="float-left">
              <h4 class="text-warning">
                <i class="fa fa-shopping-cart highlight-icon" aria-hidden="true"></i>
              </h4>
            </div>
            <div class="float-right text-center">
              <p class="card-text" style="font-size: 24px; font-weight: bold; color: #4169E1; margin: 0;">
                Active Loans
              </p>
              <h4 class="bold-text">
                <?php
                  // Example placeholder
                  // echo $ml->getAllApproveLoan();
                ?>
              </h4>
            </div>
          </div>
        </div>
      </div>
    </a>
  </div>

  <!-- Disbursed Amount -->
  <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
    <a href="disbursed_amount.php" class="no-hover-effect">
      <div class="card card-statistics">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start">
            <div class="text-warning">
              <h4><i class="fa fa-money highlight-icon" aria-hidden="true"></i></h4>
            </div>
            <div class="text-right">
              <?php
                $totalSidian = 0;
                $totalEquity = 0;
                $totalAll = 0;

                $all = $ml->viewLoanApplication();
                if ($all) {
                  while ($row = $all->fetch_assoc()) {
                    $totalAll += $row['amount_remain'];
                    if ($row['bank_name'] === 'Sidian Bank') {
                      $totalSidian += $row['amount_remain'];
                    } elseif ($row['bank_name'] === 'Equity Bank') {
                      $totalEquity += $row['amount_remain'];
                    }
                  }
                }
              ?>
              <p class="card-text text-dark mb-1">Disbursed Amount <strong>(Equity)</strong></p>
              <h4 class="fw-bold text-primary mb-3"><?= number_format($totalEquity) ?> Ksh</h4>

              <p class="card-text text-dark mb-1">Disbursed Amount <strong>(Sidian)</strong></p>
              <h4 class="fw-bold text-primary mb-3"><?= number_format($totalSidian) ?> Ksh</h4>

              <p class="card-text text-dark mb-1"><strong>Total Disbursed</strong></p>
              <h4 class="fw-bold text-success"><?= number_format($totalAll) ?> Ksh</h4>
            </div>
          </div>
        </div>
      </div>
    </a>
  </div>

  <!-- Remaining Capital -->
  <div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
    <div class="card card-statistics">
      <div class="card-body">
        <div class="d-flex justify-content-between align-items-start">
          <div class="text-info">
            <h4><i class="fa fa-building highlight-icon" aria-hidden="true"></i></h4>
          </div>
          <div class="text-right">
            <?php
              $initialCapitalEquity = 300000;
              $initialCapitalSidian = 200000;

              $totalRemainingEquity = 0;
              $totalRemainingSidian = 0;

              $all = $ml->viewLoanApplication();
              if ($all) {
                while ($row = $all->fetch_assoc()) {
                  if ($row['bank_name'] === 'Sidian Bank') {
                    $totalRemainingSidian += $row['amount_remain'];
                  } elseif ($row['bank_name'] === 'Equity Bank') {
                    $totalRemainingEquity += $row['amount_remain'];
                  }
                }
              }

              $remainingCapitalEquity = $initialCapitalEquity - $totalRemainingEquity;
              $remainingCapitalSidian = $initialCapitalSidian - $totalRemainingSidian;
              $totalRemainingCapital = $remainingCapitalEquity + $remainingCapitalSidian;
            ?>
            <p class="card-text text-dark mb-1">Remaining Capital <strong>(Equity)</strong></p>
            <h4 class="fw-bold mb-3"><?= number_format($remainingCapitalEquity) ?> Ksh</h4>

            <p class="card-text text-dark mb-1">Remaining Capital <strong>(Sidian)</strong></p>
            <h4 class="fw-bold mb-3"><?= number_format($remainingCapitalSidian) ?> Ksh</h4>

            <p class="card-text text-dark mb-1"><strong>Total Remaining</strong></p>
            <h4 class="fw-bold text-success"><?= number_format($totalRemainingCapital) ?> Ksh</h4>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Loan History -->
<div class="col-xl-3 col-lg-3 col-md-3 col-sm-6 mb-4">
  <a href="loan_history.php" style="text-decoration: none;">
    <div class="card card-statistics shadow-sm">
      <div class="card-body">
        <div class="clearfix">
          <div class="float-left">
            <h4 class="text-primary">
              <i class="fa fa-history highlight-icon" aria-hidden="true"></i>
            </h4> 
          </div>
          <div class="float-right">
            <p class="card-text text-dark font-weight-bold">Loan History</p>
          </div>
        </div>
      </div>
    </div>
  </a>
</div>


</div> <!-- row end -->

<style>
.no-hover-effect {
  text-decoration: none !important;
  color: inherit !important;
}
.no-hover-effect:hover,
.no-hover-effect:focus {
  text-decoration: none !important;
  color: inherit !important;
}
.no-hover-effect .card:hover {
  box-shadow: none !important;
  transform: none !important;
}
</style>

<!-- Loans Due and Overdue -->
<h5 class="card-title p-3 bg-info text-white rounded">Loans Due and Overdue</h5><br>
<div class="row">
  <div class="col-xl-10 col-lg-10 col-md-10 col-sm-10 mb-4">
    <div id="accordion">
      <?php 
        $loans = $ml->getLoansDueAndOverdue();
        if ($loans) {
          while ($result = $loans->fetch_assoc()) {
            if (empty(trim($result['name']))) continue;

            if ($result['payment_date']) {
              $current_date = date('Y-m-d');
              $payment_date = date('Y-m-d', strtotime($result['payment_date']));

              $is_due_today = ($payment_date == $current_date);
              $is_overdue = ($payment_date < $current_date);
              $is_not_due = ($payment_date > $current_date);

              if ($is_overdue) {
                $overdue_days = (strtotime($current_date) - strtotime($payment_date)) / (60 * 60 * 24);
                $overdue_weeks = ceil($overdue_days / 7);
              }

              $card_color = $is_overdue ? 'bg-danger text-white' : ($is_due_today ? 'bg-success text-white' : 'bg-secondary text-white');
              $status_text = $is_overdue ? "Overdue" : ($is_due_today ? "Due Today" : "Upcoming");
      ?>
              <div class="card <?php echo $card_color; ?> mb-3">
                <div class="card-header" id="heading<?php echo $result['nid']; ?>">
                  <h5 class="mb-0">
                    <button class="btn btn-link text-white text-left w-100" style="white-space: normal;" 
                            data-toggle="collapse" 
                            data-target="#collapse<?php echo $result['nid']; ?>" 
                            aria-expanded="true" 
                            aria-controls="collapse<?php echo $result['nid']; ?>">
                      <?php 
                        echo $result['name'];
                        if ($result['bank_name'] === 'Sidian Bank') { 
                          echo ' <span style="color: lime;">✅</span>'; 
                        }
                        echo ' | ID: ' . $result['nid'] . 
                             " | Payment $status_text (Due Date: " . $result['payment_date'] . ")";
                      ?>
                    </button>
                  </h5>
                </div>

                <div id="collapse<?php echo $result['nid']; ?>" class="collapse" aria-labelledby="heading<?php echo $result['nid']; ?>" data-parent="#accordion">
                  <div class="card-body" style="background-color: #f8f9fa; color: black; padding: 15px; border-radius: 5px;">
                    <?php if ($is_overdue): ?>
                      <div id="overdue-notification-<?php echo $result['nid']; ?>" class="alert alert-warning">
                        This loan is overdue by <?php echo $overdue_weeks; ?> week<?php echo $overdue_weeks > 1 ? 's' : ''; ?>!
                      </div>
                    <?php endif; ?>

                    <input type="hidden" id="payment_date_<?php echo $result['nid']; ?>" value="<?php echo $payment_date; ?>">

                    <div class="list-group">
                      <a class="list-group-item">Name: <?php echo $result['name']; ?></a>
                      <a class="list-group-item">ID: <?php echo $result['nid']; ?></a>
                      <a class="list-group-item">Phone: <?php echo $result['mobile']; ?></a>
                      <a class="list-group-item">Address: <?php echo $result['address']; ?></a>
                      <a class="list-group-item">Loan Issued: <?php echo $result['expected_loan']; ?></a>
                      <a class="list-group-item">Total Loan: <?php echo number_format($result['total_loan']); ?> Ksh</a>
                      <a class="list-group-item">Amount Paid: <?php echo number_format($result['amount_paid']); ?> Ksh</a>
                      <a class="list-group-item">Remaining: <?php echo number_format($result['amount_remain']); ?> Ksh</a>
                      <a class="list-group-item">Payment Date: <?php echo $result['payment_date']; ?></a>
                      <a class="list-group-item">Bank Name: <?php echo $result['bank_name']; ?></a>
                      <a href="payloan.php?nid=<?php echo urlencode($result['nid']); ?>" class="btn btn-success">Pay Now</a>
                    </div>
                  </div>
                </div>
              </div>
      <?php
            }
          }
        } else {
          echo "<p>No due or overdue loans found.</p>";
        }
      ?>
    </div>
  </div>
</div>

<script>
function checkAndHideNotifications(loanId, paymentDateFieldId) {
  var paymentDateField = document.getElementById(paymentDateFieldId);
  var paymentDate = new Date(paymentDateField.value);
  var today = new Date();
  today.setHours(0, 0, 0, 0);

  if (paymentDate > today) {
    var overdueNotification = document.getElementById('overdue-notification-' + loanId);
    if (overdueNotification) overdueNotification.style.display = 'none';

    var dueNotification = document.getElementById('due-notification-' + loanId);
    if (dueNotification) dueNotification.style.display = 'none';
  }
}
</script>

<?php
include_once "inc/footer.php";
?>
