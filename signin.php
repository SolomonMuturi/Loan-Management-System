<?php
include_once "classes/Employee.php";
include_once "libs/Session.php";
Session::checkLogin();
$emp = new Employee();

$remembered_email = isset($_COOKIE['dunster_remember_email']) ? $_COOKIE['dunster_remember_email'] : '';
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="images/brac.jpg">

    <title></title>

    <!-- Bootstrap core CSS -->
    <link href="assets/css/bootstrap.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="assets/css/signin.css" rel="stylesheet">
  </head>

  <body>
      <?php 
        if (isset($_POST['submit']) && $_SERVER['REQUEST_METHOD'] == 'POST') {
          if (isset($_POST['remember_me'])) {
            setcookie('dunster_remember_email', $_POST['email'], time() + (86400 * 30), '/');
          } else {
            setcookie('dunster_remember_email', '', time() - 3600, '/');
          }
          $inserted = $emp->employeeLogin($_POST);
        } 
      ?>
  <div class="container">
    <form class="form-signin" action="" method="POST">
      <div class="text-center mb-4">
        <img class="mb-2" src="images/brac.png" alt="" width="220" height="72">

      </div>
      <div class="text-center mb-4">
        <?php if (isset($inserted)) {
          echo $inserted;
        }?>
      </div>
      <div class="form-label-group">
        <input type="email" id="inputEmail" class="form-control" name="email" value="<?php echo htmlspecialchars($remembered_email, ENT_QUOTES, 'UTF-8'); ?>" placeholder="Email address" required autofocus>
        <label for="inputEmail">Email address</label>
      </div>

      <div class="form-label-group">
         <input type="password" id="inputPassword" class="form-control" name="pass" placeholder="Password" required>
        <label for="inputPassword">Password</label>
      </div>

      <div class="mb-3">
        <div class="custom-control custom-checkbox">
          <input type="checkbox" class="custom-control-input" id="rememberMe" name="remember_me" <?php echo $remembered_email !== '' ? 'checked' : ''; ?>>
          <label class="custom-control-label" for="rememberMe">Remember me</label>
         <div>
      </div>

      <input class="btn btn-lg btn-primary btn-block" type="submit" name="submit" value="submit">
    </form>

      <div class="col-md-12 ">
        <p class="text-muted text-center">Developed by Solitech</p></div>
    </div>
    </div>
  </body>
</html>