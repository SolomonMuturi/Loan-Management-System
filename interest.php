<?php
  include_once "inc/header.php";
  include_once "inc/sidebar.php";
?>

<div class="container-fluid mt-4">
  <!-- Total Interest Earned -->
  <div class="row">
    <div class="col-12">
      <div class="card shadow-sm w-100">
        <div class="card-header bg-white text-primary">
          <h5 class="mb-0">Interest Amount Earned</h5>
        </div>
        <div class="card-body text-left">
          <h6 class="bold-text text-secondary">Total Interest Earned:</h6>
          <h2 class="font-weight-bold text-primary">
            <?php echo number_format($ml->getTotalProfit(), 2); ?> Ksh
          </h2>
        </div>
      </div>
    </div>
  </div>

  <!-- Weekly Interest (Full Width) -->
  <div class="row mt-4">
    <div class="col-12">
      <div class="card card-statistics shadow-sm w-100">
        <div class="card-body">
          <h6 class="bold-text">Weekly Interest</h6>

          <div class="mt-3">
            <?php
            $intervalResults = $ml->getInterestForIntervals();
            $totalInterestForFourWeeks = 0;
            $currentWeek = date('W'); // Get current week number

            if (!empty($intervalResults)) {
                echo "<table class='table table-bordered'>";
                echo "<thead class='thead-light'><tr><th>Week</th><th>Interest Earned (Ksh)</th></tr></thead><tbody>";

                foreach ($intervalResults as $result) {
                    $weekNumber = date('W', strtotime($result['interval'])); // Get week number from interval
                    $isCurrentWeek = ($weekNumber == $currentWeek); // Check if it's the current week

                    echo "<tr " . ($isCurrentWeek ? "style='font-size: 1.2rem; font-weight: bold; color: #007bff;'" : "") . ">";
                    echo "<td>{$result['interval']}</td>";
                    echo "<td class='text-success'>" . number_format($result['totalInterest'], 2) . " Ksh</td>";
                    echo "</tr>";

                    $totalInterestForFourWeeks += $result['totalInterest'];
                }

                echo "</tbody></table>";

                echo "<div class='total-interest mt-3'>";
                echo "<h6 class='bold-text'>Total for 4 Weeks: <span class='text-primary'>" . number_format($totalInterestForFourWeeks, 2) . " Ksh</span></h6>";
                echo "</div>";
            } else {
                echo "<p class='text-danger'>No interest data available.</p>";
            }
            ?>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Monthly Interest Card (Full Width) -->
  <div class="row mt-4">
    <div class="col-12">
      <div class="card card-statistics shadow-sm">
        <div class="card-body">
          <h6 class="bold-text">Monthly Interest</h6>

          <div class="mt-3">
            <?php
            $monthlyResults = $ml->getInterestForMonthlyIntervals();
            $totalAnnualInterest = 0;
            $currentMonth = date('F'); // Get current month name

            if (!empty($monthlyResults)) {
                echo "<table class='table table-bordered'>";
                echo "<thead class='thead-light'><tr><th>Month</th><th>Interest Earned (Ksh)</th></tr></thead><tbody>";

                foreach ($monthlyResults as $result) {
                    $isCurrentMonth = ($result['month'] == $currentMonth); // Check if it's the current month

                    echo "<tr " . ($isCurrentMonth ? "style='font-size: 1.2rem; font-weight: bold; color: #007bff;'" : "") . ">";
                    echo "<td>{$result['month']}</td>";
                    echo "<td class='text-success'>" . number_format($result['totalInterest'], 2) . " Ksh</td>";
                    echo "</tr>";

                    $totalAnnualInterest += $result['totalInterest'];
                }

                echo "</tbody></table>";

                echo "<div class='total-annual-interest mt-3'>";
                echo "<h6 class='bold-text'>Total for the Year: <span class='text-primary'>" . number_format($totalAnnualInterest, 2) . " Ksh</span></h6>";
                echo "</div>";
            } else {
                echo "<p class='text-danger'>No monthly interest data available.</p>";
            }
            ?>
          </div>
        </div>
      </div>
    </div>
  </div>

</div>

<?php
include_once "inc/footer.php";
?>
