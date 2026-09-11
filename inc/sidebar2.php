<!-- partial -->
    <div class="container-fluid mt-5">
      <div class="row row-offcanvas row-offcanvas-left">
        <!-- partial:partials/_sidebar.html -->
        <nav class="bg-white sidebar sidebar-offcanvas" id="sidebar">
          <div class="user-info">
            <img src="images/user.png" alt="">
            <p class="name"><?php echo Session::get("name");?></p>
            <p class="designation"><?php echo Session::get("designation");?></p>
            <span class="online"></span>
          </div>
          <ul class="nav">
            <li class="nav-item active">
              <a class="nav-link" href="index.php">
                <i class="fa fa-dashboard icon-dashboard" aria-hidden="true"></i>
                <span class="menu-title">Dashboard</span>
              </a>
            </li>

          <?php if(Session::get("role") == 2){?>
          <!-- borrower option -->
            <li class="nav-item">
              <a class="nav-link" data-toggle="collapse" href="#borrower-pages" aria-expanded="false" aria-controls="borrower-pages">
                <i class="fa fa-user icon-borrower" aria-hidden="true"></i>
                <span class="menu-title">Borrower<i class="fa fa-sort-down"></i></span>
              </a>
              <div class="collapse" id="borrower-pages">
                <ul class="nav flex-column sub-menu">
                  <li class="nav-item">
                    <a class="nav-link" href="addborrower.php">Add Borrower</a>
                  </li>
                  <li class="nav-item">
                    <a class="nav-link" href="viewborrower.php">View Borrower</a>
                  </li>
                </ul>
              </div>
            </li>
            <!-- end borrower option -->
            <li class="nav-item">
              <a class="nav-link" href="apply_for_loan.php">
                <i class="fa fa-file-text icon-apply" aria-hidden="true"></i>
                <span class="menu-title">Apply for loan</span>
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="loan_application.php">
                <i class="fa fa-list-alt icon-applications" aria-hidden="true"></i>
                <span class="menu-title">Loan applications</span>
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="payloan.php">
                <i class="fa fa-money icon-payment" aria-hidden="true"></i>
                <span class="menu-title">Loan Payment</span>
              </a>
            </li>
             <li class="nav-item">
              <a class="nav-link" href="loan_status.php">
                <i class="fa fa-bar-chart icon-status" aria-hidden="true"></i>
                <span class="menu-title">Loan Status</span>
              </a>
            </li>
           
            <!-- liability option -->
            <li class="nav-item">
              <a class="nav-link" data-toggle="collapse" href="#liability-pages" aria-expanded="false" aria-controls="liability-pages">
                <i class="fa fa-briefcase icon-liability" aria-hidden="true"></i>
                <span class="menu-title">Liability<i class="fa fa-sort-down"></i></span>
              </a>
              <div class="collapse" id="liability-pages">
                <ul class="nav flex-column sub-menu">
                  <li class="nav-item">
                    <a class="nav-link" href="recordsellinfo.php">Record property sell</a>
                  </li>
                  <li class="nav-item">
                    <a class="nav-link" href="showsellinfo.php">View Property info</a>
                  </li>
                </ul>
              </div>
            </li>
        <?php } ?>
             <li class="nav-item">
              <a class="nav-link" href="loanverify.php">
                <i class="fa fa-check-circle icon-verification" aria-hidden="true"></i>
                <span class="menu-title">Loan Verification</span>
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="manage_users.php">
                <i class="fa fa-users icon-users" aria-hidden="true"></i>
                <span class="menu-title">User Accounts</span>
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="security_center.php">
                <i class="fa fa-shield icon-security" aria-hidden="true"></i>
                <span class="menu-title">Security Center</span>
              </a>
            </li>
          </ul>
        </nav>

        <!-- partial -->
        <div class="content-wrapper">