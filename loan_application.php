<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="card">
  <div class="card-header">
    All Loan Applications
  </div>
  <div class="card-body">
    <h5 class="card-title">Loan Details</h5>
    <table id="loanTable" class="table table-striped table-bordered table-hover" cellspacing="0" width="100%">
      <thead>
        <tr>
          <th>#</th> <!-- New column for numbering -->
          <th>Name</th>
          <th>ID</th>
          <th>Application Date</th>
          <th>Payment Date</th> <!-- Payment Date Column -->
          <th>Expected Loan</th>
          <th>Percentage</th>
          <th>Inst</th>
          <th>Total Loan</th>
          <th>Weekly Pay</th>
          <th>Weekly Interest</th>
          <th>Bank Name</th>
          <th>Documents</th>
          <th>Report</th>
          <th>Status</th>
          <th>Actions</th> <!-- Column for Edit/Delete -->
        </tr>
      </thead>

      <tbody>
        <?php 
          $all = $ml->viewLoanApplication();
          if ($all) {
            $i = 1; // Initialize counter
            while ($row = $all->fetch_assoc()) {
                // Skip the row if the name is empty
                if (empty(trim($row['name']))) continue;
        ?>
        <tr>
          <td><?php echo $i; ?></td> <!-- Display numbering -->
          <td><?php echo htmlspecialchars($row['name']); ?></td>
          <td><?php echo htmlspecialchars($row['nid']); ?></td>
          <td><?php echo htmlspecialchars($row['dob']); ?></td>
          <td><?php echo htmlspecialchars($row['payment_date']); ?></td> <!-- Payment Date -->
          <td><?php echo htmlspecialchars($row['expected_loan']); ?> Ksh</td>
          <td><?php echo htmlspecialchars($row['loan_percentage']); ?>%</td>
          <td><?php echo htmlspecialchars($row['installments']); ?></td>
          <td><?php echo htmlspecialchars($row['total_loan']); ?> Ksh</td>
          <td><?php echo htmlspecialchars($row['emi_loan']); ?> Ksh/week</td>
          <td><?php echo htmlspecialchars($row['weekly_interest']); ?> Ksh/week</td>
          <td><?php echo htmlspecialchars($row['bank_name']); ?></td>
          <td><a href="<?php echo htmlspecialchars($row['files']); ?>">Download</a></td>
          <td><a target="_blank" href="loan_app_report.php?loan_id=<?php echo $row['id']; ?>">Report</a></td>
          <td>
            <?php 
              if ($row['status'] == 3) {
                echo "<label class='badge badge-success'>Approved</label>";
              } else {
                echo "<label class='badge badge-warning'>Pending</label>";
              }
            ?>
          </td>
          <td>
            <a href="edit_loan_application.php?loan_id=<?php echo $row['id']; ?>" class="btn btn-primary btn-sm">Edit</a>
            <a href="delete_loan_application.php?loan_id=<?php echo $row['id']; ?>" 
               class="btn btn-danger btn-sm" 
               onclick="return confirm('Are you sure you want to delete this loan application?');">Delete</a>
          </td>
        </tr>
        <?php 
            $i++; // Increment counter
            }
          }
        ?>
      </tbody>
    </table>
  </div>
</div>

<?php
include_once "inc/footer.php";
?>

<!-- DataTables Initialization Script -->
<script>
    $(document).ready(function() {
        // Initialize the DataTable
        if (!$.fn.dataTable.isDataTable('#loanTable')) {
            $('#loanTable').DataTable({
                "paging": false,  // Disable pagination (show all rows)
                "info": false,    // Disable information display (e.g., "Showing 1 to 10 of 100 entries")
                "searching": true, // Enable search functionality
                "order": [],      // Disable default sorting
                "responsive": true, // Make the table responsive for mobile devices
                "lengthChange": false // Disable the length change option (to hide page size selection)
            });
        }
    });
</script>

<!-- Add DataTables CSS & JS -->
<!-- DataTables CSS -->
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">

<!-- Responsive DataTables CSS -->
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.9/css/responsive.dataTables.min.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- DataTables JS -->
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>

<!-- Responsive DataTables JS -->
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/responsive/2.2.9/js/dataTables.responsive.min.js"></script>
