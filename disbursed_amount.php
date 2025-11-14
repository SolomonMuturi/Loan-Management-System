<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="card">
  <div class="card-header">
    Loans Disbursed
  </div>
  <div class="card-body">
    <h5 class="card-title">All Loans Disbursed</h5>

    <!-- Loan Application List Section -->
    <div class="list-group">
      <?php 
        $totalRemaining = 0; // Initialize variable to store total remaining amount
        // Fetch all loan applications using the viewLoanApplication method
        $all = $ml->viewLoanApplication();
        if ($all) {
          $i = 1; // Initialize counter for numbering
          while ($row = $all->fetch_assoc()) { // Loop through the results
            // Accumulate the remaining amount
            $totalRemaining += $row['amount_remain'];
      ?>
        <div class="list-group-item list-group-item-action">
          <div class="row">
            <!-- Numbering Column -->
            <div class="col-md-1">
              <strong><?php echo $i++; ?>.</strong> <!-- Displaying number -->
            </div>

            <!-- Borrower ID Column -->
            <div class="col-md-3">
              <strong>ID:</strong> <?php echo $row['nid']; ?>
            </div>
            
            <!-- Borrower Name Column -->
            <div class="col-md-4">
              <strong>Name:</strong> <?php echo $row['name']; ?>
            </div>
            
            <!-- Remaining Amount Column -->
            <div class="col-md-3">
              <strong>Remaining Amount:</strong> <?php echo number_format($row['amount_remain']); ?> Ksh
            </div>

            <!-- Action Button for Viewing Details -->
            <div class="col-md-1 text-right">
              <a href="individual_loan.php?loan_id=<?php echo $row['id']; ?>&b_id=<?php echo $row['b_id'];?>" class="btn btn-info btn-sm">View</a>
            </div>
          </div>
        </div>
      <?php 
          }
        } else {
          echo "<div class='list-group-item'>No loan applications found.</div>"; // If no data
        }
      ?>
    </div>

    <!-- Display the Total Remaining Amount -->
    <div class="mt-4 text-center">
      <h5>Total Disbursed Amount:<br> <strong><?php echo number_format($totalRemaining); ?> Ksh</h5> </strong>
    </div>

  </div>
</div>

<?php
include_once "inc/footer.php";
?>
