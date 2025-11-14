<?php
ob_start();
//code for cache-control
  header("Cache-Control: no-cache, must-revalidate");
  header("Pragma: no-cache"); 
  header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); 
  header("Cache-Control: max-age=2592000");

  include_once "libs/Session.php";
  Session::init();
  Session::checkSession();
  include_once "helpers/Format.php";
  spl_autoload_register(function($class){
      include_once "classes/".$class.".php";
    });


  $ml = new ManageLoan();
  $emp = new Employee();

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Dunster Credit Management</title>
  <link rel="stylesheet" type="text/css" href="assets/font-awesome/font-awesome.min.css">
  <link rel="stylesheet" type="text/css" href="assets/perfect-scrollbar/dist/css/perfect-scrollbar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/flag-icon-css/css/flag-icon.min.css">
  <!-- DataTables CSS -->
  <link href="assets/css/dataTables.bootstrap4.min.css" rel="stylesheet">
  <link href="assets/css/dataTables.responsive.css" rel="stylesheet">
  <!-- main  + bootstrap css -->
  <link rel="stylesheet" type="text/css" href="assets/css/style.css">
  <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.css">
  <!-- custom css -->
  <link rel="stylesheet" type="text/css" href="assets/css/main.css">

  <link rel="shortcut icon" href="images/logodc.jpg" />

</head>

<body>
  <!-- start scroller container -->
  <div class=" container-scroller">
    <!-- partial:partials/_navbar.html -->
    <nav class="navbar navbar-default navbar-expand-lg col-lg-12 col-12 p-0 fixed-top d-flex flex-row">
  <!-- Navbar toggler for smaller screens -->
  <button class="navbar-toggler navbar-dark d-lg-none align-self-center" type="button" data-toggle="offcanvas">
    <span class="navbar-toggler-icon"></span>
  </button>

  <!-- Navbar brand section -->
  <div class="bg-white text-center navbar-brand-wrapper">
    <a class="navbar-brand brand-logo" href="index.php">
      <img src="images/brac.png" alt="Brand Logo" class="img-fluid">
    </a>
    <a class="navbar-brand brand-logo-mini" href="index.php">
      <img src="images/logo_star_mini.jpg" alt="Mini Logo" class="img-fluid">
    </a>
  </div>

  <!-- Navbar menu -->
  <div class="navbar-menu-wrapper d-flex align-items-center justify-content-between flex-grow-1">
    <!-- Secondary navbar toggler for minimizing -->
    <button class="navbar-toggler d-none d-lg-block navbar-dark align-self-center mr-3" type="button" data-toggle="minimize">
      <span class="navbar-toggler-icon"></span>
    </button>

    <!-- Navbar items -->
    <ul class="navbar-nav ml-auto d-flex align-items-center">
      <!-- User name display -->
      <li class="nav-item">
        <a class="nav-link" href="#">
          <i class="fa fa-user"></i> <?php echo Session::get("name"); ?>
        </a>
      </li>

      <!-- Logout functionality -->
      <?php
        if (isset($_GET['action']) && $_GET['action'] == "logout") {
          Session::destroy();
          header("Location: signin.php");
        }
      ?>
      <li class="nav-item">
        <a class="nav-link" href="?action=logout">
          <i class="fa fa-sign-out"></i> Logout
        </a>
      </li>
    </ul>
  </div>
</nav>
