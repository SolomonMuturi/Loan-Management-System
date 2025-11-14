<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="container-fluid mt-4">
  <!-- Total Reduced Amount -->
  <div class="row">
    <div class="col-12">
      <div class="card shadow-sm w-100">
        <div class="card-header bg-white text-primary">
          <h5 class="mb-0">Reduced Amount</h5>
        </div>
        <div class="card-body">
          <h6 class="bold-text text-secondary">Total Reduced Amount:</h6>
          <h2 class="font-weight-bold text-primary">
            <?php 
              $monthlyResults = $ml->getAmountForMonthlyIntervals();
              $totalAnnualAmount = array_sum(array_column($monthlyResults, 'totalamount')); // Calculate total before displaying
              echo number_format($totalAnnualAmount, 2); 
            ?> Ksh
          </h2>
        </div>
      </div>
    </div>
  </div>

  <!-- Weekly Reduced Amount Section -->
  <div class="row mt-4">
    <div class="col-12">
      <div class="card card-statistics shadow-sm w-100">
        <div class="card-body">
          <p class="card-text text-dark" style="font-size: 1.2rem;">Reduced Amount Per Week</p>

          <div class="mt-3">
            <?php
            $weeklyResults = $ml->getAmountForWeeklyIntervals();
            $totalReducedForFourWeeks = 0;
            $currentWeek = date('W'); // Get current week number

            if (!empty($weeklyResults)) {
                echo "<table class='table table-bordered'>";
                echo "<thead class='thead-light'><tr><th>Week</th><th>Amount Reduced (Ksh)</th></tr></thead><tbody>";

                foreach ($weeklyResults as $result) {
                    $weekNumber = date('W', strtotime($result['interval'])); // Get week number from interval
                    $isCurrentWeek = ($weekNumber == $currentWeek); // Check if it's the current week

                    echo "<tr " . ($isCurrentWeek ? "style='font-size: 1.2rem; font-weight: bold; color: #007bff;'" : "") . ">";
                    echo "<td>{$result['interval']}</td>";
                    echo "<td class='text-success'>" . number_format($result['totalamount'], 2) . " Ksh</td>";
                    echo "</tr>";

                    $totalReducedForFourWeeks += $result['totalamount'];
                }

                echo "</tbody></table>";

                echo "<div class='total-reduced mt-3'>";
                echo "<h6 class='bold-text'>Total for 4 Weeks: <span class='text-primary'>" . number_format($totalReducedForFourWeeks, 2) . " Ksh</span></h6>";
                echo "</div>";
            } else {
                echo "<p class='text-danger'>No reduced amount data available.</p>";
            }
            ?>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Monthly Reduced Amount Section -->
  <div class="row mt-4">
    <div class="col-12">
      <div class="card card-statistics shadow-sm w-100">
        <div class="card-body">
          <p class="card-text text-dark" style="font-size: 1.2rem;">Amount Reduced Per Month</p>

          <div class="mt-3">
            <?php
            $currentMonth = date('F'); // Get current month

            echo "<table class='table table-bordered'>";
            echo "<thead class='thead-light'><tr><th>Month</th><th>Amount Reduced (Ksh)</th></tr></thead><tbody>";

            foreach ($monthlyResults as $result) {
                $monthName = date('F', strtotime($result['month'])); // Full month name
                $isCurrentMonth = ($monthName == $currentMonth); // Check if it's the current month

                echo "<tr " . ($isCurrentMonth ? "style='font-size: 1.2rem; font-weight: bold; color: #007bff;'" : "") . ">";
                echo "<td>{$monthName}</td>";
                echo "<td class='text-success'>" . number_format($result['totalamount'], 2) . " Ksh</td>";
                echo "</tr>";
            }

            echo "</tbody></table>";
            ?>
          </div>

          <!-- Total Annual Amount -->
          <div class="total-annual-amount mt-3">
            <h6 class="bold-text">Total for the Year: 
              <span class="text-primary">
                <?php echo number_format($totalAnnualAmount, 2); ?> Ksh
              </span>
            </h6>
          </div>

        </div>
      </div>
    </div>
  </div>

</div>

<?php
include_once "inc/footer.php";
?>
