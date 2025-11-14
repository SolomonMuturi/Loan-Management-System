<!-- Inside notification.php -->

<h5 class="card-title p-3 bg-info text-white rounded">Notifications</h5><br>
<div class="row">
    <div class="col-xl-10 col-lg-10 col-md-10 col-sm-10 mb-4">
        <div id="accordion">
            <?php
            // Initialize the NotificationManager with the database connection
            $ml = new NotificationManager($dbConnection);

            // Fetch notifications for payments due today or overdue
            $notify = $ml->getNotificationDueTodayAndOverdue();

            // Check if notifications were found
            if ($notify) {
                // Loop through the results and display each notification
                while ($result = $notify->fetch_assoc()) {
                    if ($result['next_date']) {
                        $current_date = date('Y-m-d');
                        $next_payment_date = date('Y-m-d', strtotime($result['next_date']));
                        
                        // Check if payment is due today
                        if ($next_payment_date == $current_date && $result['amount_paid'] < $result['total_loan']) {  
            ?>
                        <!-- Display borrower with payment due today -->
                        <div class="card">
                            <div class="card-header" id="headingToday">
                                <h5 class="mb-0">
                                    <button class="btn btn-link" data-toggle="collapse" data-target="#collapseToday" aria-expanded="true" aria-controls="collapseToday">
                                        <?php echo $result['name'] . ' | ' . 'ID: ' . $result['nid'] . " payment due today (Due Date: " . $result['next_date'] . ")"; ?>
                                    </button>
                                </h5>
                            </div>

                            <div id="collapseToday" class="collapse show" aria-labelledby="headingToday" data-parent="#accordion">
                                <div class="card-body">
                                    <div class="list-group">
                                        <a class="list-group-item">Name: <?php echo $result['name']; ?></a>
                                        <a class="list-group-item">ID: <?php echo $result['nid']; ?></a>
                                        <a class="list-group-item">Phone: <?php echo $result['mobile']; ?></a>
                                        <a class="list-group-item">Address: <?php echo $result['address']; ?></a>
                                        <a class="list-group-item">Last Payment Date: <?php echo $result['next_date']; ?></a>
                                        <a class="list-group-item">Total Paid: <?php echo $result['amount_paid']; ?> Ksh</a>
                                        <a class="list-group-item">Remaining: <?php echo $result['amount_remain']; ?> Ksh</a>
                                    </div>
                                </div>
                            </div>
                        </div>
            <?php  
                        } elseif ($next_payment_date == date('Y-m-d', strtotime('-1 day', strtotime($current_date))) && $result['amount_paid'] < $result['total_loan']) {
                            // If payment is 1 day overdue
            ?>
                        <!-- Display borrower with overdue payment -->
                        <div class="card">
                            <div class="card-header" id="headingOverdue">
                                <h5 class="mb-0">
                                    <button class="btn btn-link" data-toggle="collapse" data-target="#collapseOverdue" aria-expanded="true" aria-controls="collapseOverdue">
                                        <?php echo $result['name'] . ' | ' . 'ID: ' . $result['nid'] . " missed their payment yesterday (Due Date: " . $result['next_date'] . ")"; ?>
                                    </button>
                                </h5>
                            </div>

                            <div id="collapseOverdue" class="collapse show" aria-labelledby="headingOverdue" data-parent="#accordion">
                                <div class="card-body">
                                    <div class="list-group">
                                        <a class="list-group-item">Name: <?php echo $result['name']; ?></a>
                                        <a class="list-group-item">ID: <?php echo $result['nid']; ?></a>
                                        <a class="list-group-item">Phone: <?php echo $result['mobile']; ?></a>
                                        <a class="list-group-item">Address: <?php echo $result['address']; ?></a>
                                        <a class="list-group-item">Last Payment Date: <?php echo $result['next_date']; ?></a>
                                        <a class="list-group-item">Total Paid: <?php echo $result['amount_paid']; ?> Ksh</a>
                                        <a class="list-group-item">Remaining: <?php echo $result['amount_remain']; ?> Ksh</a>
                                    </div>
                                </div>
                            </div>
                        </div>
            <?php  
                        }
                    }
                }
            } else {
                echo "No notifications found for today or overdue payments.";
            }
            ?>
        </div>
    </div>
</div>
