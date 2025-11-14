<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="card">
  <div class="card-header">
    All Loan Details
  </div>
  <div class="card-body">
    <h5 class="card-title">Loan details</h5>
    <table id="loanTable" class="table table-striped table-bordered table-hover" cellspacing="0" width="100%">
      <thead>
        <tr>
          <th>Name</th>
          <th>Remaining Amount</th>
          <th>ID</th>
          <th>Insts</th>
          <th>EMI</th>
          <th>Amount Paid</th>
          <th>Total Loan</th>
          <th>Current Inst.</th>
          <th>Remaining Inst.</th>
          <th>Next Pay Date</th>
          <th>Bank Name</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <?php 
          $all = $ml->viewLoanApplication();
          if ($all) {
            while ($row = $all->fetch_assoc()) {
              // Skip if name is blank or only whitespace
              if (trim($row['name']) === '') {
                continue;
              }
        ?>
        <tr>
          <td><?php echo htmlspecialchars($row['name']); ?></td>
          <td><?php echo htmlspecialchars($row['amount_remain']); ?> Ksh</td>
          <td><?php echo htmlspecialchars($row['nid']); ?></td>
          <td><?php echo htmlspecialchars($row['installments']); ?></td>
          <td><?php echo htmlspecialchars($row['emi_loan']); ?> Ksh/week</td>
          <td><?php echo htmlspecialchars($row['amount_paid']); ?> Ksh</td>
          <td><?php echo htmlspecialchars($row['total_loan']); ?> Ksh</td>
          <td><?php echo htmlspecialchars($row['current_inst']); ?></td>
          <td><?php echo htmlspecialchars($row['remain_inst']); ?></td>
          <td><?php echo htmlspecialchars($row['payment_date']); ?></td>
          <td><?php echo htmlspecialchars($row['bank_name']); ?></td>
          <td>
            <div>
              <a class="btn btn-info" href="individual_loan.php?loan_id=<?php echo $row['id']; ?>&b_id=<?php echo $row['b_id']; ?>">View</a>
            </div>
          </td>
        </tr>
        <?php 
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
    if (!$.fn.dataTable.isDataTable('#loanTable')) {
      $('#loanTable').DataTable({
        "paging": false,
        "info": false,
        "searching": true,
        "order": [],
        "responsive": true
      });
    }
  });
</script>

<!-- DataTables CSS -->
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.9/css/responsive.dataTables.min.css">

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- DataTables JS -->
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/responsive/2.2.9/js/dataTables.responsive.min.js"></script>
