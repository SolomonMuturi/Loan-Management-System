<?php
include_once "inc/header.php";
include_once "inc/sidebar.php";

$crud = new CrudOperation();

// ========== USER MANAGEMENT ==========
// Handle delete user
if(isset($_GET['delete_id'])){
  $delete_id = $_GET['delete_id'];
  $query = "DELETE FROM tbl_user WHERE id = $delete_id";
  $d = $crud->delete($query);
  if($d){
    echo "<script>alert('User deleted successfully'); window.location='manage_users.php';</script>";
  } else {
    echo "<script>alert('Failed to delete user');</script>";
  }
}

// Handle add/update user
if(isset($_POST['submit_user'])){
  $name = $crud->link->real_escape_string($_POST['name']);
  $email = $crud->link->real_escape_string($_POST['email']);
  $designation = $crud->link->real_escape_string($_POST['designation']);
  $role = (int)$_POST['role'];
  
  if(isset($_POST['user_id']) && $_POST['user_id'] != ''){
    $user_id = (int)$_POST['user_id'];
    if(isset($_POST['password']) && $_POST['password'] != ''){
      $password = md5($_POST['password']);
      $query = "UPDATE tbl_user SET name='$name', email='$email', pass='$password', designation='$designation', role=$role WHERE id=$user_id";
    } else {
      $query = "UPDATE tbl_user SET name='$name', email='$email', designation='$designation', role=$role WHERE id=$user_id";
    }
    $update = $crud->update($query);
    if($update){
      echo "<script>alert('User updated successfully'); window.location='manage_users.php';</script>";
    } else {
      echo "<script>alert('Failed to update user');</script>";
    }
  } else {
    if(!isset($_POST['password']) || $_POST['password'] == ''){
      echo "<script>alert('Password is required for new users'); window.history.back();</script>";
      exit;
    }
    $password = md5($_POST['password']);
    $query = "INSERT INTO tbl_user(name, email, pass, designation, role) VALUES('$name', '$email', '$password', '$designation', $role)";
    $insert = $crud->insert($query);
    if($insert){
      echo "<script>alert('User added successfully'); window.location='manage_users.php';</script>";
    } else {
      echo "<script>alert('Failed to add user');</script>";
    }
  }
}

// Get all users
$query = "SELECT * FROM tbl_user ORDER BY id DESC";
$get_users = $crud->select($query);

// ========== ROLE MANAGEMENT ==========
// Handle delete role
if(isset($_GET['delete_role_id'])){
  $role_id = $_GET['delete_role_id'];
  $query = "DELETE FROM tbl_roles WHERE id = $role_id";
  $d = $crud->delete($query);
  if($d){
    echo "<script>alert('Role deleted successfully'); window.location='manage_users.php?tab=roles';</script>";
  }
}

// Handle add/update role
if(isset($_POST['submit_role'])){
  $role_name = $crud->link->real_escape_string($_POST['role_name']);
  $role_description = $crud->link->real_escape_string($_POST['role_description']);
  
  if(isset($_POST['role_id']) && $_POST['role_id'] != ''){
    $role_id = (int)$_POST['role_id'];
    $query = "UPDATE tbl_roles SET role_name='$role_name', role_description='$role_description' WHERE id=$role_id";
    $update = $crud->update($query);
    if($update){
      echo "<script>alert('Role updated successfully'); window.location='manage_users.php?tab=roles';</script>";
    }
  } else {
    $query = "INSERT INTO tbl_roles(role_name, role_description) VALUES('$role_name', '$role_description')";
    $insert = $crud->insert($query);
    if($insert){
      echo "<script>alert('Role created successfully'); window.location='manage_users.php?tab=roles';</script>";
    }
  }
}

// Get all roles
$query_roles = "SELECT * FROM tbl_roles ORDER BY id DESC";
$get_roles = $crud->select($query_roles);

// ========== PERMISSION MANAGEMENT ==========
// Handle delete permission
if(isset($_GET['delete_perm_id'])){
  $perm_id = $_GET['delete_perm_id'];
  $query = "DELETE FROM tbl_permissions WHERE id = $perm_id";
  $d = $crud->delete($query);
  if($d){
    echo "<script>alert('Permission deleted successfully'); window.location='manage_users.php?tab=permissions';</script>";
  }
}

// Handle add/update permission
if(isset($_POST['submit_permission'])){
  $perm_name = $crud->link->real_escape_string($_POST['perm_name']);
  $perm_description = $crud->link->real_escape_string($_POST['perm_description']);
  
  if(isset($_POST['perm_id']) && $_POST['perm_id'] != ''){
    $perm_id = (int)$_POST['perm_id'];
    $query = "UPDATE tbl_permissions SET perm_name='$perm_name', perm_description='$perm_description' WHERE id=$perm_id";
    $update = $crud->update($query);
    if($update){
      echo "<script>alert('Permission updated successfully'); window.location='manage_users.php?tab=permissions';</script>";
    }
  } else {
    $query = "INSERT INTO tbl_permissions(perm_name, perm_description) VALUES('$perm_name', '$perm_description')";
    $insert = $crud->insert($query);
    if($insert){
      echo "<script>alert('Permission created successfully'); window.location='manage_users.php?tab=permissions';</script>";
    }
  }
}

// Get all permissions
$query_perms = "SELECT * FROM tbl_permissions ORDER BY id DESC";
$get_permissions = $crud->select($query_perms);

// ========== ROLE PERMISSIONS ==========
// Handle assign permission to role
if(isset($_POST['submit_role_perm'])){
  $role_id = (int)$_POST['role_id'];
  $perm_id = (int)$_POST['perm_id'];
  
  $query = "INSERT INTO tbl_role_permissions(role_id, perm_id) VALUES($role_id, $perm_id)";
  $insert = $crud->insert($query);
  if($insert){
    echo "<script>alert('Permission assigned to role successfully'); window.location='manage_users.php?tab=role_permissions';</script>";
  }
}

// Get role permissions
$query_role_perms = "SELECT rp.*, r.role_name, p.perm_name FROM tbl_role_permissions rp 
                     LEFT JOIN tbl_roles r ON rp.role_id = r.id 
                     LEFT JOIN tbl_permissions p ON rp.perm_id = p.id 
                     ORDER BY rp.id DESC";
$get_role_permissions = $crud->select($query_role_perms);

// Handle delete role permission
if(isset($_GET['delete_role_perm_id'])){
  $role_perm_id = $_GET['delete_role_perm_id'];
  $query = "DELETE FROM tbl_role_permissions WHERE id = $role_perm_id";
  $d = $crud->delete($query);
  if($d){
    echo "<script>alert('Permission removed from role'); window.location='manage_users.php?tab=role_permissions';</script>";
  }
}

// ========== USER PERMISSIONS ==========
// Handle assign permission to user
if(isset($_POST['submit_user_perm'])){
  $user_id = (int)$_POST['user_id'];
  $perm_id = (int)$_POST['perm_id'];
  
  $query = "INSERT INTO tbl_user_permissions(user_id, perm_id) VALUES($user_id, $perm_id)";
  $insert = $crud->insert($query);
  if($insert){
    echo "<script>alert('Permission assigned to user successfully'); window.location='manage_users.php?tab=user_permissions';</script>";
  }
}

// Get user permissions
$query_user_perms = "SELECT up.*, u.name, p.perm_name FROM tbl_user_permissions up 
                     LEFT JOIN tbl_user u ON up.user_id = u.id 
                     LEFT JOIN tbl_permissions p ON up.perm_id = p.id 
                     ORDER BY up.id DESC";
$get_user_permissions = $crud->select($query_user_perms);

// Handle delete user permission
if(isset($_GET['delete_user_perm_id'])){
  $user_perm_id = $_GET['delete_user_perm_id'];
  $query = "DELETE FROM tbl_user_permissions WHERE id = $user_perm_id";
  $d = $crud->delete($query);
  if($d){
    echo "<script>alert('Permission removed from user'); window.location='manage_users.php?tab=user_permissions';</script>";
  }
}

?>

          <h3 class="page-heading mb-4">Access Control Management</h3>
          
          <div class="row">
            <div class="col-lg-12 grid-margin stretch-card">
              <div class="card">
                <div class="card-body">
                  <!-- Tab Navigation -->
                  <ul class="nav nav-tabs mb-4" id="managementTabs" role="tablist">
                    <li class="nav-item">
                      <a class="nav-link active" id="users-tab" data-toggle="tab" href="#users" role="tab"><i class="fa fa-users"></i> Users</a>
                    </li>
                    <li class="nav-item">
                      <a class="nav-link" id="roles-tab" data-toggle="tab" href="#roles" role="tab"><i class="fa fa-shield"></i> Roles</a>
                    </li>
                    <li class="nav-item">
                      <a class="nav-link" id="permissions-tab" data-toggle="tab" href="#permissions" role="tab"><i class="fa fa-lock"></i> Permissions</a>
                    </li>
                    <li class="nav-item">
                      <a class="nav-link" id="role-perms-tab" data-toggle="tab" href="#role-permissions" role="tab"><i class="fa fa-tasks"></i> Role Permissions</a>
                    </li>
                    <li class="nav-item">
                      <a class="nav-link" id="user-perms-tab" data-toggle="tab" href="#user-permissions" role="tab"><i class="fa fa-key"></i> User Permissions</a>
                    </li>
                  </ul>

                  <!-- Tab Content -->
                  <div class="tab-content" id="managementTabsContent">
                    
                    <!-- ========== USERS TAB ========== -->
                    <div class="tab-pane fade show active" id="users" role="tabpanel">
                      <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5><i class="fa fa-users"></i> Manage Users</h5>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addUserModal" onclick="resetUserForm()">
                          <i class="fa fa-plus"></i> Add New User
                        </button>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-hover table-striped">
                          <thead class="bg-light">
                            <tr>
                              <th>ID</th>
                              <th>Name</th>
                              <th>Email</th>
                              <th>Designation</th>
                              <th>Role</th>
                              <th>Actions</th>
                            </tr>
                          </thead>
                          <tbody>
                            <?php
                              if($get_users){
                                while($user = $get_users->fetch_assoc()){
                                  $role_name = '';
                                  switch($user['role']){
                                    case 1: $role_name = 'Verifier'; $badge = 'badge-info'; break;
                                    case 2: $role_name = 'Branch Officer'; $badge = 'badge-warning'; break;
                                    case 3: $role_name = 'Head Officer'; $badge = 'badge-success'; break;
                                    default: $role_name = 'Unknown'; $badge = 'badge-secondary';
                                  }
                            ?>
                            <tr>
                              <td><strong><?php echo $user['id']; ?></strong></td>
                              <td><?php echo htmlspecialchars($user['name']); ?></td>
                              <td><?php echo htmlspecialchars($user['email']); ?></td>
                              <td><?php echo htmlspecialchars($user['designation']); ?></td>
                              <td><span class="badge <?php echo $badge; ?>"><?php echo $role_name; ?></span></td>
                              <td>
                                <button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#addUserModal" onclick="editUser(<?php echo $user['id']; ?>, '<?php echo addslashes($user['name']); ?>', '<?php echo $user['email']; ?>', '<?php echo addslashes($user['designation']); ?>', <?php echo $user['role']; ?>)">
                                  <i class="fa fa-edit"></i> Edit
                                </button>
                                <a href="manage_users.php?delete_id=<?php echo $user['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this user?');">
                                  <i class="fa fa-trash"></i> Delete
                                </a>
                              </td>
                            </tr>
                            <?php
                                }
                              } else {
                                echo '<tr><td colspan="6" class="text-center text-muted py-3">No users found</td></tr>';
                              }
                            ?>
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <!-- ========== ROLES TAB ========== -->
                    <div class="tab-pane fade" id="roles" role="tabpanel">
                      <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5><i class="fa fa-shield"></i> Manage Roles</h5>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addRoleModal" onclick="resetRoleForm()">
                          <i class="fa fa-plus"></i> Add New Role
                        </button>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-hover table-striped">
                          <thead class="bg-light">
                            <tr>
                              <th>ID</th>
                              <th>Role Name</th>
                              <th>Description</th>
                              <th>Actions</th>
                            </tr>
                          </thead>
                          <tbody>
                            <?php
                              if($get_roles){
                                while($role = $get_roles->fetch_assoc()){
                            ?>
                            <tr>
                              <td><strong><?php echo $role['id']; ?></strong></td>
                              <td><?php echo htmlspecialchars($role['role_name']); ?></td>
                              <td><?php echo htmlspecialchars($role['role_description']); ?></td>
                              <td>
                                <button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#addRoleModal" onclick="editRole(<?php echo $role['id']; ?>, '<?php echo addslashes($role['role_name']); ?>', '<?php echo addslashes($role['role_description']); ?>')">
                                  <i class="fa fa-edit"></i> Edit
                                </button>
                                <a href="manage_users.php?delete_role_id=<?php echo $role['id']; ?>&tab=roles" class="btn btn-sm btn-danger" onclick="return confirm('Delete this role?');">
                                  <i class="fa fa-trash"></i> Delete
                                </a>
                              </td>
                            </tr>
                            <?php
                                }
                              } else {
                                echo '<tr><td colspan="4" class="text-center text-muted py-3">No roles found. Create one first.</td></tr>';
                              }
                            ?>
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <!-- ========== PERMISSIONS TAB ========== -->
                    <div class="tab-pane fade" id="permissions" role="tabpanel">
                      <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5><i class="fa fa-lock"></i> Manage Permissions</h5>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addPermissionModal" onclick="resetPermissionForm()">
                          <i class="fa fa-plus"></i> Add New Permission
                        </button>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-hover table-striped">
                          <thead class="bg-light">
                            <tr>
                              <th>ID</th>
                              <th>Permission Name</th>
                              <th>Description</th>
                              <th>Actions</th>
                            </tr>
                          </thead>
                          <tbody>
                            <?php
                              if($get_permissions){
                                while($perm = $get_permissions->fetch_assoc()){
                            ?>
                            <tr>
                              <td><strong><?php echo $perm['id']; ?></strong></td>
                              <td><?php echo htmlspecialchars($perm['perm_name']); ?></td>
                              <td><?php echo htmlspecialchars($perm['perm_description']); ?></td>
                              <td>
                                <button class="btn btn-sm btn-warning" data-toggle="modal" data-target="#addPermissionModal" onclick="editPermission(<?php echo $perm['id']; ?>, '<?php echo addslashes($perm['perm_name']); ?>', '<?php echo addslashes($perm['perm_description']); ?>')">
                                  <i class="fa fa-edit"></i> Edit
                                </button>
                                <a href="manage_users.php?delete_perm_id=<?php echo $perm['id']; ?>&tab=permissions" class="btn btn-sm btn-danger" onclick="return confirm('Delete this permission?');">
                                  <i class="fa fa-trash"></i> Delete
                                </a>
                              </td>
                            </tr>
                            <?php
                                }
                              } else {
                                echo '<tr><td colspan="4" class="text-center text-muted py-3">No permissions found. Create one first.</td></tr>';
                              }
                            ?>
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <!-- ========== ROLE PERMISSIONS TAB ========== -->
                    <div class="tab-pane fade" id="role-permissions" role="tabpanel">
                      <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5><i class="fa fa-tasks"></i> Assign Permissions to Roles</h5>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addRolePermModal" onclick="resetRolePermForm()">
                          <i class="fa fa-plus"></i> Assign Permission
                        </button>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-hover table-striped">
                          <thead class="bg-light">
                            <tr>
                              <th>ID</th>
                              <th>Role</th>
                              <th>Permission</th>
                              <th>Actions</th>
                            </tr>
                          </thead>
                          <tbody>
                            <?php
                              if($get_role_permissions){
                                while($rp = $get_role_permissions->fetch_assoc()){
                            ?>
                            <tr>
                              <td><strong><?php echo $rp['id']; ?></strong></td>
                              <td><span class="badge badge-info"><?php echo htmlspecialchars($rp['role_name']); ?></span></td>
                              <td><?php echo htmlspecialchars($rp['perm_name']); ?></td>
                              <td>
                                <a href="manage_users.php?delete_role_perm_id=<?php echo $rp['id']; ?>&tab=role_permissions" class="btn btn-sm btn-danger" onclick="return confirm('Remove this permission from role?');">
                                  <i class="fa fa-trash"></i> Remove
                                </a>
                              </td>
                            </tr>
                            <?php
                                }
                              } else {
                                echo '<tr><td colspan="4" class="text-center text-muted py-3">No role permissions assigned yet.</td></tr>';
                              }
                            ?>
                          </tbody>
                        </table>
                      </div>
                    </div>

                    <!-- ========== USER PERMISSIONS TAB ========== -->
                    <div class="tab-pane fade" id="user-permissions" role="tabpanel">
                      <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5><i class="fa fa-key"></i> Assign Permissions to Users</h5>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addUserPermModal" onclick="resetUserPermForm()">
                          <i class="fa fa-plus"></i> Assign Permission
                        </button>
                      </div>
                      <div class="table-responsive">
                        <table class="table table-hover table-striped">
                          <thead class="bg-light">
                            <tr>
                              <th>ID</th>
                              <th>User</th>
                              <th>Permission</th>
                              <th>Actions</th>
                            </tr>
                          </thead>
                          <tbody>
                            <?php
                              if($get_user_permissions){
                                while($up = $get_user_permissions->fetch_assoc()){
                            ?>
                            <tr>
                              <td><strong><?php echo $up['id']; ?></strong></td>
                              <td><span class="badge badge-success"><?php echo htmlspecialchars($up['name']); ?></span></td>
                              <td><?php echo htmlspecialchars($up['perm_name']); ?></td>
                              <td>
                                <a href="manage_users.php?delete_user_perm_id=<?php echo $up['id']; ?>&tab=user_permissions" class="btn btn-sm btn-danger" onclick="return confirm('Remove this permission from user?');">
                                  <i class="fa fa-trash"></i> Remove
                                </a>
                              </td>
                            </tr>
                            <?php
                                }
                              } else {
                                echo '<tr><td colspan="4" class="text-center text-muted py-3">No user permissions assigned yet.</td></tr>';
                              }
                            ?>
                          </tbody>
                        </table>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
          </div>

      <!-- ========== MODALS ========== -->

      <!-- Add/Edit User Modal -->
      <div class="modal fade" id="addUserModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title" id="userModalTitle"><i class="fa fa-user-plus"></i> Add New User</h5>
              <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" id="userForm">
              <div class="modal-body">
                <input type="hidden" id="user_id" name="user_id" value="">
                <div class="form-group">
                  <label><strong>Full Name</strong> <span style="color:red;">*</span></label>
                  <input type="text" class="form-control" id="user_name" name="name" required>
                </div>
                <div class="form-group">
                  <label><strong>Email</strong> <span style="color:red;">*</span></label>
                  <input type="email" class="form-control" id="user_email" name="email" required>
                </div>
                <div class="form-group">
                  <label><strong>Password</strong> <span id="user_pwd_req" style="color:red;">*</span></label>
                  <input type="password" class="form-control" id="user_password" name="password" required>
                </div>
                <div class="form-group">
                  <label><strong>Designation</strong> <span style="color:red;">*</span></label>
                  <input type="text" class="form-control" id="user_designation" name="designation" required>
                </div>
                <div class="form-group">
                  <label><strong>Role</strong> <span style="color:red;">*</span></label>
                  <select class="form-control" id="user_role" name="role" required>
                    <option value="">Select Role</option>
                    <option value="1">Verifier</option>
                    <option value="2">Branch Officer</option>
                    <option value="3">Head Officer</option>
                  </select>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="submit" name="submit_user" class="btn btn-primary"><i class="fa fa-save"></i> Save</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Add/Edit Role Modal -->
      <div class="modal fade" id="addRoleModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title" id="roleModalTitle"><i class="fa fa-shield"></i> Add New Role</h5>
              <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" id="roleForm">
              <div class="modal-body">
                <input type="hidden" id="role_id" name="role_id" value="">
                <div class="form-group">
                  <label><strong>Role Name</strong> <span style="color:red;">*</span></label>
                  <input type="text" class="form-control" id="role_name" name="role_name" placeholder="e.g., Admin, Moderator" required>
                </div>
                <div class="form-group">
                  <label><strong>Description</strong></label>
                  <textarea class="form-control" id="role_description" name="role_description" rows="3" placeholder="Role description..."></textarea>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="submit" name="submit_role" class="btn btn-primary"><i class="fa fa-save"></i> Save</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Add/Edit Permission Modal -->
      <div class="modal fade" id="addPermissionModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title" id="permModalTitle"><i class="fa fa-lock"></i> Add New Permission</h5>
              <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" id="permForm">
              <div class="modal-body">
                <input type="hidden" id="perm_id" name="perm_id" value="">
                <div class="form-group">
                  <label><strong>Permission Name</strong> <span style="color:red;">*</span></label>
                  <input type="text" class="form-control" id="perm_name" name="perm_name" placeholder="e.g., view_users, edit_loans" required>
                </div>
                <div class="form-group">
                  <label><strong>Description</strong></label>
                  <textarea class="form-control" id="perm_description" name="perm_description" rows="3" placeholder="Permission description..."></textarea>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="submit" name="submit_permission" class="btn btn-primary"><i class="fa fa-save"></i> Save</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Assign Role Permission Modal -->
      <div class="modal fade" id="addRolePermModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title"><i class="fa fa-tasks"></i> Assign Permission to Role</h5>
              <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" id="rolePermForm">
              <div class="modal-body">
                <div class="form-group">
                  <label><strong>Select Role</strong> <span style="color:red;">*</span></label>
                  <select class="form-control" name="role_id" required>
                    <option value="">-- Choose a Role --</option>
                    <?php
                      $query_roles2 = "SELECT * FROM tbl_roles ORDER BY role_name";
                      $roles_list = $crud->select($query_roles2);
                      if($roles_list){
                        while($r = $roles_list->fetch_assoc()){
                          echo '<option value="'.$r['id'].'">'.$r['role_name'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
                <div class="form-group">
                  <label><strong>Select Permission</strong> <span style="color:red;">*</span></label>
                  <select class="form-control" name="perm_id" required>
                    <option value="">-- Choose a Permission --</option>
                    <?php
                      $query_perms2 = "SELECT * FROM tbl_permissions ORDER BY perm_name";
                      $perms_list = $crud->select($query_perms2);
                      if($perms_list){
                        while($p = $perms_list->fetch_assoc()){
                          echo '<option value="'.$p['id'].'">'.$p['perm_name'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="submit" name="submit_role_perm" class="btn btn-primary"><i class="fa fa-save"></i> Assign</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Assign User Permission Modal -->
      <div class="modal fade" id="addUserPermModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title"><i class="fa fa-key"></i> Assign Permission to User</h5>
              <button type="button" class="close text-white" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <form method="POST" id="userPermForm">
              <div class="modal-body">
                <div class="form-group">
                  <label><strong>Select User</strong> <span style="color:red;">*</span></label>
                  <select class="form-control" name="user_id" required>
                    <option value="">-- Choose a User --</option>
                    <?php
                      $query_users2 = "SELECT * FROM tbl_user ORDER BY name";
                      $users_list = $crud->select($query_users2);
                      if($users_list){
                        while($u = $users_list->fetch_assoc()){
                          echo '<option value="'.$u['id'].'">'.$u['name'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
                <div class="form-group">
                  <label><strong>Select Permission</strong> <span style="color:red;">*</span></label>
                  <select class="form-control" name="perm_id" required>
                    <option value="">-- Choose a Permission --</option>
                    <?php
                      $query_perms3 = "SELECT * FROM tbl_permissions ORDER BY perm_name";
                      $perms_list3 = $crud->select($query_perms3);
                      if($perms_list3){
                        while($p = $perms_list3->fetch_assoc()){
                          echo '<option value="'.$p['id'].'">'.$p['perm_name'].'</option>';
                        }
                      }
                    ?>
                  </select>
                </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="submit" name="submit_user_perm" class="btn btn-primary"><i class="fa fa-save"></i> Assign</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <script>
        function resetUserForm(){
          document.getElementById('user_id').value = '';
          document.getElementById('userForm').reset();
          document.getElementById('userModalTitle').innerHTML = '<i class="fa fa-user-plus"></i> Add New User';
          document.getElementById('user_password').required = true;
          document.getElementById('user_pwd_req').innerHTML = '<span style="color:red;">*</span>';
        }

        function editUser(id, name, email, designation, role){
          document.getElementById('user_id').value = id;
          document.getElementById('user_name').value = name;
          document.getElementById('user_email').value = email;
          document.getElementById('user_designation').value = designation;
          document.getElementById('user_role').value = role;
          document.getElementById('user_password').value = '';
          document.getElementById('user_password').required = false;
          document.getElementById('userModalTitle').innerHTML = '<i class="fa fa-user-edit"></i> Edit User';
          document.getElementById('user_pwd_req').innerHTML = '(Optional)';
        }

        function resetRoleForm(){
          document.getElementById('role_id').value = '';
          document.getElementById('roleForm').reset();
          document.getElementById('roleModalTitle').innerHTML = '<i class="fa fa-shield"></i> Add New Role';
        }

        function editRole(id, name, desc){
          document.getElementById('role_id').value = id;
          document.getElementById('role_name').value = name;
          document.getElementById('role_description').value = desc;
          document.getElementById('roleModalTitle').innerHTML = '<i class="fa fa-shield"></i> Edit Role';
        }

        function resetPermissionForm(){
          document.getElementById('perm_id').value = '';
          document.getElementById('permForm').reset();
          document.getElementById('permModalTitle').innerHTML = '<i class="fa fa-lock"></i> Add New Permission';
        }

        function editPermission(id, name, desc){
          document.getElementById('perm_id').value = id;
          document.getElementById('perm_name').value = name;
          document.getElementById('perm_description').value = desc;
          document.getElementById('permModalTitle').innerHTML = '<i class="fa fa-lock"></i> Edit Permission';
        }

        function resetRolePermForm(){
          document.getElementById('rolePermForm').reset();
        }

        function resetUserPermForm(){
          document.getElementById('userPermForm').reset();
        }

        // Set active tab from URL parameter
        document.addEventListener('DOMContentLoaded', function() {
          const urlParams = new URLSearchParams(window.location.search);
          const tab = urlParams.get('tab');
          if(tab){
            document.querySelector(`#${tab}-tab`).click();
          }
        });
      </script>

<?php include_once "inc/footer.php"; ?>
