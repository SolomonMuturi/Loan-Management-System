<?php
include_once "inc/header.php";
include_once "inc/sidebar.php";

$activity_log_file = file_exists('error_log.txt') ? 'error_log.txt' : 'error_log';
$activity_logs = file_exists($activity_log_file) ? file($activity_log_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) : array();
?>

          <h3 class="page-heading mb-4">Security Center</h3>
          <div class="row">
            <div class="col-12 grid-margin stretch-card">
              <div class="card">
                <div class="card-body">
                  <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="card-title mb-0"><i class="fa fa-history text-danger"></i> Activity Logs</h4>
                    <span class="text-muted"><?php echo count($activity_logs); ?> entries</span>
                  </div>
                  <div class="table-responsive">
                    <table class="table table-striped table-hover">
                      <thead class="bg-light">
                        <tr>
                          <th>#</th>
                          <th>Activity</th>
                        </tr>
                      </thead>
                      <tbody>
                        <?php if(count($activity_logs) > 0){
                          foreach($activity_logs as $log_number => $log_entry){ ?>
                            <tr>
                              <td><?php echo $log_number + 1; ?></td>
                              <td><?php echo htmlspecialchars($log_entry, ENT_QUOTES, 'UTF-8'); ?></td>
                            </tr>
                        <?php }
                        } else { ?>
                          <tr>
                            <td colspan="2" class="text-center text-muted py-4">No activity logs found.</td>
                          </tr>
                        <?php } ?>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>

<?php include_once "inc/footer.php"; ?>
