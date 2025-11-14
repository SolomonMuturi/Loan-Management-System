<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<h3 class="page-heading mb-4">Loan History</h3>

<div class="row">
  
  <!-- Disbursed Amount -->
  <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12 mb-4">
    <a href="disbursed.php" style="text-decoration: none;">
      <div class="card card-statistics shadow-sm">
        <div class="card-body text-center">
          <h4 class="text-primary">
            <i class="fa fa-money"></i> <!-- Works in FA4 -->
              <!-- Money Hand Icon -->
          </h4>
          <p class="card-text text-dark font-weight-bold">Disbursed Amount</p>
        </div>
      </div>
    </a>
  </div>

  <!-- Reduced Amount -->
  <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12 mb-4">
    <a href="reduced.php" style="text-decoration: none;">
      <div class="card card-statistics shadow-sm">
        <div class="card-body text-center">
          <h4 class="text-danger">
            <i class="fa fa-line-chart"></i> <!-- Works in FA4 -->
                         <!-- Declining Graph Icon -->
          </h4>
          <p class="card-text text-dark font-weight-bold">Reduced Amount</p>
        </div>
      </div>
    </a>
  </div>

  <!-- Interest Earned -->
  <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12 mb-4">
    <a href="interest.php" style="text-decoration: none;">
      <div class="card card-statistics shadow-sm">
        <div class="card-body text-center">
          <h4 class="text-success">
            <i class="fa fa-line-chart highlight-icon"></i> <!-- Old FA4 icon for banks -->
          </h4>
          <p class="card-text text-dark font-weight-bold">Interest Earned</p>
        </div>
      </div>
    </a>
  </div>

</div>

<?php
include_once "inc/footer.php";
?>
