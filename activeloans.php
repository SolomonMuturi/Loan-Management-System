<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="container-fluid mt-4">
  <div class="card shadow-sm">
    <div class="card-header bg-primary text-white">
      <h5 class="mb-0">All Loan Applications</h5>
    </div>
    
    <div class="card-body">
      <h6 class="card-title text-secondary mb-3">Loan Application Details</h6>

      <?php 
        // Fetch all loan applications
        $all = $ml->viewLoanApplication();
        if ($all && $all->num_rows > 0) { 
      ?>
        <div class="table-responsive">
          <table class="table table-bordered table-hover">
            <thead class="thead-dark">
              <tr>
                <th>#</th>
                <th>Name</th>
                <th>ID</th>
              </tr>
            </thead>
            <tbody>
              <?php 
                $i = 1; // Counter for numbering
                $count = 0; // Initialize a counter for valid loans
                while ($row = $all->fetch_assoc()) { 
                  // Skip entries with empty or whitespace-only names
                  if (trim($row['name']) === '') {
                    continue;
                  }

                  // Increment the counter for valid loans
                  $count++;
              ?>
                <tr>
                  <td><?php echo $i++; ?>.</td>
                  <td><?php echo htmlspecialchars($row['name']); ?></td>
                  <td><?php echo htmlspecialchars($row['nid']); ?></td>
                </tr>
              <?php } ?>
            </tbody>
          </table>
        </div>
        <!-- Display Total -->
        <div class="text-right">
          <p><strong>Total Loan Applications: <?php echo $count; ?></strong></p>
        </div>
      <?php 
        } else { 
          echo "<div class='alert alert-warning'>No loan applications found.</div>";
        } 
      ?>
    </div>
  </div>
</div>

<?php
include_once "inc/footer.php";
?>
