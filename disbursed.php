<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="container-fluid mt-4">
  <div class="row">
    <div class="col-12">
      <div class="card shadow-sm w-100">
        <div class="card-header bg-white text-primary">
          <h5 class="mb-0">Total Credit Issued</h5>
        </div>
        <div class="card-body text-left">
          <h6 class="bold-text text-secondary">Total Credit Issued:</h6>
          <h2 class="font-weight-bold text-primary">
        <?php
          // Initialize total remaining amount variable
          $totalRemaining = 0;

          // Fetch all loan applications using the viewLoanApplication method
          $all = $ml->viewLoanApplication();
          if ($all) {
            // Loop through each loan application and add the remaining amount to the total
            while ($row = $all->fetch_assoc()) {
              $totalRemaining += $row['expected_loan']; // Accumulate the remaining amount
            }
          }

          // Display the total remaining amount, formatted with thousands separator
          echo number_format($totalRemaining);
        ?> Ksh
      </h2>
        </div>
      </div>
    </div>
  </div>

 <!-- Weekly Disbursed Amount Section -->
  <div class="row mt-4">
    <div class="col-12">
      <div class="card card-statistics shadow-sm w-100">
        <div class="card-body">
          <p class="card-text text-dark" style="font-size: 1.2rem;">Total Credited Amount Per Week</p>

          <div class="mt-3">
            <?php
            $weeklyResults = $ml->getDisbursedForWeeklyIntervals();
            $totalDisbursedForFourWeeks = 0;
            $currentWeek = date('W'); // Get current week number

            if (!empty($weeklyResults)) {
                echo "<table class='table table-bordered'>";
                echo "<thead class='thead-light'><tr><th>Week</th><th>Amount Credited (Ksh)</th></tr></thead><tbody>";

                foreach ($weeklyResults as $result) {
                    $weekNumber = date('W', strtotime($result['interval'])); // Get week number from interval
                    $isCurrentWeek = ($weekNumber == $currentWeek); // Check if it's the current week

                    echo "<tr " . ($isCurrentWeek ? "style='font-size: 1.2rem; font-weight: bold; color: #007bff;'" : "") . ">";
                    echo "<td>{$result['interval']}</td>";
                    echo "<td class='text-success'>" . number_format($result['totalamount'], 2) . " Ksh</td>";
                    echo "</tr>";

                    $totalDisbursedForFourWeeks += $result['totalamount'];
                }

                echo "</tbody></table>";

                echo "<div class='total-reduced mt-3'>";
                echo "<h6 class='bold-text'>Total for 4 Weeks: <span class='text-primary'>" . number_format($totalDisbursedForFourWeeks, 2) . " Ksh</span></h6>";
                echo "</div>";
            } else {
                echo "<p class='text-danger'>No credited amount data available.</p>";
            }
            ?>
          </div>
        </div>
      </div>
    </div>
  </div>
<!-- Monthly Disbursed Amount Section -->
<div class="row mt-4">
  <div class="col-12">
    <div class="card card-statistics shadow-sm w-100">
      <div class="card-body">
        <p class="card-text text-dark" style="font-size: 1.2rem;">Amount Credited Per Month</p>

        <div class="mt-3">
          <?php
          $monthlyDisbursed = $ml->getDisbursedForMonthlyIntervals();
          $currentMonth = date('F');
          $totalYearlyDisbursed = 0;

          echo "<table class='table table-bordered'>";
          echo "<thead class='thead-light'><tr><th>Month</th><th>Amount Credited (Ksh)</th></tr></thead><tbody>";

          foreach ($monthlyDisbursed as $result) {
              $monthName = date('F', strtotime($result['month']));
              $isCurrentMonth = ($monthName == $currentMonth);
              $totalYearlyDisbursed += $result['totalamount'];

              echo "<tr " . ($isCurrentMonth ? "style='font-weight: bold; color: #007bff; font-size: 1.1rem;'" : "") . ">";
              echo "<td>{$monthName}</td>";
              echo "<td class='text-success'>" . number_format($result['totalamount'], 2) . " Ksh</td>";
              echo "</tr>";
          }

          echo "</tbody></table>";
          ?>

          <!-- Total Yearly Disbursed -->
          <div class="mt-3">
            <h6 class="bold-text">Total for the Year: 
              <span class="text-primary"><?php echo number_format($totalYearlyDisbursed, 2); ?> Ksh</span>
            </h6>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

</div>


<?php
include_once "inc/footer.php";
?>



<?php
include_once "inc/footer.php";
?>
