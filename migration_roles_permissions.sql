-- Create Roles Table
CREATE TABLE IF NOT EXISTS `tbl_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(100) NOT NULL UNIQUE,
  `role_description` text,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create Permissions Table
CREATE TABLE IF NOT EXISTS `tbl_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `perm_name` varchar(100) NOT NULL UNIQUE,
  `perm_description` text,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create Role Permissions Table (Junction Table)
CREATE TABLE IF NOT EXISTS `tbl_role_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `perm_id` int(11) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`role_id`) REFERENCES `tbl_roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`perm_id`) REFERENCES `tbl_permissions`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_role_perm` (`role_id`, `perm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Create User Permissions Table (Direct Permissions)
CREATE TABLE IF NOT EXISTS `tbl_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `perm_id` int(11) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `tbl_user`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`perm_id`) REFERENCES `tbl_permissions`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_user_perm` (`user_id`, `perm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Insert default roles
INSERT IGNORE INTO `tbl_roles` (`id`, `role_name`, `role_description`) VALUES
(1, 'Verifier', 'Can verify loan applications and borrower information'),
(2, 'Branch Officer', 'Can manage borrowers and process loan applications'),
(3, 'Head Officer', 'Can manage all operations and generate reports'),
(4, 'Administrator', 'Full system access');

-- Insert default permissions
INSERT IGNORE INTO `tbl_permissions` (`id`, `perm_name`, `perm_description`) VALUES
(1, 'view_dashboard', 'Access to dashboard'),
(2, 'manage_borrowers', 'Add, edit, delete borrowers'),
(3, 'view_borrowers', 'View borrower information'),
(4, 'apply_loan', 'Apply for loan'),
(5, 'view_loans', 'View loan applications'),
(6, 'verify_loans', 'Verify loan applications'),
(7, 'approve_loans', 'Approve loan applications'),
(8, 'manage_payments', 'Manage loan payments'),
(9, 'view_reports', 'Generate and view reports'),
(10, 'manage_users', 'Add, edit, delete users'),
(11, 'manage_roles', 'Manage roles'),
(12, 'manage_permissions', 'Manage permissions');
