<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="container-fluid mt-4">
  <div class="card shadow-sm">
    <div class="card-header bg-primary text-white">
      <h5 class="mb-0">Borrowers List</h5>
    </div>
    
    <div class="card-body">
      <h6 class="card-title text-secondary mb-3">All Borrowers</h6>

      <?php 
        // Fetch all borrowers
        $all = $emp->viewBorrower();
        if ($all && $all->num_rows > 0) { 
      ?>
        <div class="table-responsive">
          <table class="table table-bordered table-hover">
            <thead class="thead-dark">
              <tr>
                <th>#</th>
                <th>Name</th>
                <th>Mobile</th>
              </tr>
            </thead>
            <tbody>
              <?php 
                $i = 1; // Counter for numbering
                while ($row = $all->fetch_assoc()) { 
              ?>
                <tr>
                  <td><strong><?php echo $i++; ?>.</strong></td>
                  <td><?php echo $row['name']; ?></td>
                  <td><?php echo $row['mobile']; ?></td>
                </tr>
              <?php } ?>
            </tbody>
          </table>
        </div>
      <?php 
        } else { 
          echo "<div class='alert alert-warning'>No borrowers found.</div>";
        } 
      ?>
    </div>
  </div>
</div>

<?php
include_once "inc/footer.php";
?>
