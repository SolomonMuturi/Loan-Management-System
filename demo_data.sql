-- =====================================================================
--  demo_data.sql  -  FICTIONAL DEMONSTRATION DATA
--  Target schema : brac_loan  (MySQL / MariaDB on XAMPP)
--  Generated     : 2026-09-26
--  Random seed   : mt_srand(20260926)  -  change the seed to reshuffle
--
--  SCOPE
--    * 40 fictional Kenyan borrowers (ids continue after the existing max)
--    * 69 loan applications spread over 40 borrowers
--    * 568 repayments, 8 collateral settlements
--    * portfolio principal KES 4,000,000 in total: KES 3,400,000 disbursed
--      and KES 600,000 still undisbursed (awaiting verification),
--      so disbursed + remaining = 4,000,000 exactly
--    * a validation suite at the end; every integrity gate must report 0
--
--  TABLES WRITTEN   : tbl_borrower, tbl_loan_application, tbl_payment, tbl_liability
--  TABLES UNTOUCHED : tbl_user, tbl_roles, tbl_permissions,
--                     tbl_role_permissions, tbl_user_permissions
--  Statement types  : INSERT and SELECT only. No CREATE, ALTER, DROP,
--                     TRUNCATE, DELETE or UPDATE of any kind.
--
--  SCHEMA NOTES (verified against the live brac_loan database)
--    * There is NO application_date / approval_date / disbursement_date
--      column and NO reference-number column anywhere in brac_loan. The
--      workflow only persists `status` (0=new 1=verified-L1 2=verified-L2
--      3=approved) plus `next_date`. Those three lifecycle dates and the
--      reference number are therefore recorded in the comment line above
--      each INSERT instead of in invented columns. The reference also rides
--      inside the existing `files` / `property_name` text columns.
--    * tbl_borrower needs image, photo AND pic (all NOT NULL, no default).
--    * tbl_liability.id has no AUTO_INCREMENT, so ids are assigned manually.
--    * tbl_borrower.id and tbl_loan_application.id are AUTO_INCREMENT, but
--      they are referenced by child rows, so they are seeded from
--      COALESCE(MAX(id),0). That keeps the script re-runnable and guarantees
--      it never collides with rows already in the database.
--      tbl_payment.id is left to AUTO_INCREMENT: nothing references it.
--    * working_status is restricted to the five values offered by
--      addborrower.php:81-85 - Employee, Owner, Student, Unemployed, other.
--    * There is no branch column and no branches table, so loans cannot be
--      grouped by branch without changing the structure. V16 groups by the
--      county that is already stored in `address` instead.
--
--  FINANCIAL MODEL (identical to apply_for_loan.php:22-27)
--    total_loan   = expected_loan + (expected_loan * loan_percentage/100 * months)
--    installments = months * 4
--    emi_loan     = ROUND(total_loan / installments)   [column is int(11)]
--    cycle        = 30 days (ManageLoan.php:251, payloan.php:129)
--
--  DATE RANGE
--    Every stored date lies in 2024-01-20 .. 2026-09-26. The only
--    future values are next_date of loans still running, and the app itself
--    caps those at last payment + 30 days, so they never pass 2026-09-26
--    + 30. No future disbursement and no future repayment exists (max
--    pay_date = 2026-09-26).
--    Chronology per loan: applied <= approved <= disbursed <= payment 1 ..
--    payment N < next_date, and approvals precede disbursement by 2-9 days.
-- =====================================================================

SET NAMES utf8mb4;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET AUTOCOMMIT = 0;
START TRANSACTION;

-- ---------------------------------------------------------------------
-- 1. BORROWERS - 40 fictional people
--    Every name, national ID, phone number, e-mail, date of birth and
--    address below is invented. Phone numbers use the Kenyan 07XXXXXXXX
--    format and are unique. E-mails use the IANA-reserved example.com
--    domain, so nothing can ever reach a real mailbox. No real person's
--    data has been used or reproduced.
--
--    `working_status` can only hold the five values from the add-borrower
--    form, so the more specific trade is documented here for reference:
--
--    BRW-0001  Brian Ochieng          other      Lorry driver
--    BRW-0002  Kevin Otieno           other      Street food vendor
--    BRW-0003  Collins Mwangi         Unemployed Community health worker
--    BRW-0004  Evans Njoroge          Employee   Fish trader
--    BRW-0005  Dennis Kamau           Employee   Accounts clerk
--    BRW-0006  Eric Wanjala           Student    Café owner
--    BRW-0007  Francis Mutua          Owner      Grocer
--    BRW-0008  George Kiptoo          Student    Cattle rancher
--    BRW-0009  Anthony Sang           Owner      Solar installer
--    BRW-0010  Peter Kosgei           Unemployed Rice farmer
--    BRW-0011  Samuel Wekesa          Employee   Mama mboga shop owner
--    BRW-0012  David Odhiambo         Owner      Motorcycle taxi operator
--    BRW-0013  Michael Onyango        other      Salaried civil servant
--    BRW-0014  Joseph Kimani          Owner      Nail technician
--    BRW-0015  Daniel Rotich          Student    Secondary school teacher
--    BRW-0016  Patrick Kiprotich      Unemployed Tourism guide
--    BRW-0017  Moses Barasa           other      Small-scale trader
--    BRW-0018  Isaac Omollo           Employee   Boda boda mechanic
--    BRW-0019  Emmanuel Wafula        Employee   Pastoralist
--    BRW-0020  Victor Maina           other      Dairy farmer
--    BRW-0021  Mary Njenga            Unemployed Poultry farmer
--    BRW-0022  Grace Kariuki          Student    Tailor (jersey)
--    BRW-0023  Jane Macharia          Employee   Truck operator
--    BRW-0024  Ann Mureithi           Unemployed Sales agent
--    BRW-0025  Lucy Njuguna           Owner      Butchery owner
--    BRW-0026  Catherine Waweru       Owner      Betting shop attendant
--    BRW-0027  Faith Githinji         Unemployed Carpenter
--    BRW-0028  Esther Mutuma          Employee   Building mason
--    BRW-0029  Rose Kilonzo           Owner      Registered nurse
--    BRW-0030  Alice Musyoka          Unemployed Barber
--    BRW-0031  Caroline Kiprono       other      Motor mechanic
--    BRW-0032  Betty Chege            Student    Cottage industry worker
--    BRW-0033  Dorcas Mbugua          Student    Hairdresser
--    BRW-0034  Elizabeth Ndungu       other      Boda boda rider
--    BRW-0035  Hellen Kirui           Student    Phone accessories dealer
--    BRW-0036  Irene Tanui            Student    Tailor
--    BRW-0037  Joyce Bett             Employee   Kiosk owner
--    BRW-0038  Lilian Koech           Unemployed Betting agent
--    BRW-0039  Millicent Yego         Owner      Clinic administrator
--    BRW-0040  Nancy Rono             other      Maize farmer
-- ---------------------------------------------------------------------
SET @b0 := (SELECT COALESCE(MAX(id), 0) FROM tbl_borrower);

INSERT INTO `tbl_borrower`
  (`id`,`name`,`nid`,`rejected`,`gender`,`mobile`,`email`,`dob`,`address`,`working_status`,`image`,`photo`,`pic`) VALUES
  (@b0 + 1,'Brian Ochieng','4308084708',0,'Male','0760524024','brian.ochieng61@example.com','2001-12-15','Kibera, Nairobi','other','admin/uploads/demo/BRW-0001.jpg','admin/uploads/demo/BRW-0001.jpg','admin/uploads/demo/BRW-0001.jpg'),
  (@b0 + 2,'Kevin Otieno','4613854196',0,'Male','0760498808','kevin.otieno70@example.com','1971-05-15','Bunda Street, Kisumu','other','admin/uploads/demo/BRW-0002.jpg','admin/uploads/demo/BRW-0002.jpg','admin/uploads/demo/BRW-0002.jpg'),
  (@b0 + 3,'Collins Mwangi','4274322533',0,'Male','0760191730','collins.mwangi23@example.com','1974-09-17','Mumias, Kakamega','Unemployed','admin/uploads/demo/BRW-0003.jpg','admin/uploads/demo/BRW-0003.jpg','admin/uploads/demo/BRW-0003.jpg'),
  (@b0 + 4,'Evans Njoroge','3178477489',0,'Male','0700572355','evans.njoroge15@example.com','1993-01-19','Nakuru Town, Nakuru','Employee','admin/uploads/demo/BRW-0004.jpg','admin/uploads/demo/BRW-0004.jpg','admin/uploads/demo/BRW-0004.jpg'),
  (@b0 + 5,'Dennis Kamau','3581046574',0,'Male','0760368184','dennis.kamau82@example.com','1976-07-10','Kakamega Town, Kakamega','Employee','admin/uploads/demo/BRW-0005.jpg','admin/uploads/demo/BRW-0005.jpg','admin/uploads/demo/BRW-0005.jpg'),
  (@b0 + 6,'Eric Wanjala','3724026905',0,'Male','0750857247','eric.wanjala95@example.com','1998-08-30','Thika, Kiambu','Student','admin/uploads/demo/BRW-0006.jpg','admin/uploads/demo/BRW-0006.jpg','admin/uploads/demo/BRW-0006.jpg'),
  (@b0 + 7,'Francis Mutua','3562704729',0,'Male','0700360058','francis.mutua40@example.com','2002-04-22','Nyeri Town, Nyeri','Owner','admin/uploads/demo/BRW-0007.jpg','admin/uploads/demo/BRW-0007.jpg','admin/uploads/demo/BRW-0007.jpg'),
  (@b0 + 8,'George Kiptoo','3644823920',0,'Male','0750482319','george.kiptoo46@example.com','1988-03-09','Embu, Embu','Student','admin/uploads/demo/BRW-0008.jpg','admin/uploads/demo/BRW-0008.jpg','admin/uploads/demo/BRW-0008.jpg'),
  (@b0 + 9,'Anthony Sang','3808947869',0,'Male','0700378236','anthony.sang65@example.com','1980-10-26','Busia Town, Busia','Owner','admin/uploads/demo/BRW-0009.jpg','admin/uploads/demo/BRW-0009.jpg','admin/uploads/demo/BRW-0009.jpg'),
  (@b0 + 10,'Peter Kosgei','3718844291',0,'Male','0720513045','peter.kosgei42@example.com','1988-05-20','Machakos Town, Machakos','Unemployed','admin/uploads/demo/BRW-0010.jpg','admin/uploads/demo/BRW-0010.jpg','admin/uploads/demo/BRW-0010.jpg'),
  (@b0 + 11,'Samuel Wekesa','4427259347',0,'Male','0700824439','samuel.wekesa52@example.com','1979-05-25','Naivasha, Nakuru','Employee','admin/uploads/demo/BRW-0011.jpg','admin/uploads/demo/BRW-0011.jpg','admin/uploads/demo/BRW-0011.jpg'),
  (@b0 + 12,'David Odhiambo','4997656777',0,'Male','0750894130','david.odhiambo71@example.com','1979-10-16','Kisii, Kisii','Owner','admin/uploads/demo/BRW-0012.jpg','admin/uploads/demo/BRW-0012.jpg','admin/uploads/demo/BRW-0012.jpg'),
  (@b0 + 13,'Michael Onyango','3631255885',0,'Male','0740337190','michael.onyango86@example.com','1987-12-05','Kericho, Kericho','other','admin/uploads/demo/BRW-0013.jpg','admin/uploads/demo/BRW-0013.jpg','admin/uploads/demo/BRW-0013.jpg'),
  (@b0 + 14,'Joseph Kimani','3698501028',0,'Male','0720978361','joseph.kimani95@example.com','1972-08-13','Voi, Tana River','Owner','admin/uploads/demo/BRW-0014.jpg','admin/uploads/demo/BRW-0014.jpg','admin/uploads/demo/BRW-0014.jpg'),
  (@b0 + 15,'Daniel Rotich','4642082109',0,'Male','0750310692','daniel.rotich22@example.com','1994-10-17','Garissa, Garissa','Student','admin/uploads/demo/BRW-0015.jpg','admin/uploads/demo/BRW-0015.jpg','admin/uploads/demo/BRW-0015.jpg'),
  (@b0 + 16,'Patrick Kiprotich','4696365647',0,'Male','0720773300','patrick.kiprotich17@example.com','1974-02-05','Wajir, Wajir','Unemployed','admin/uploads/demo/BRW-0016.jpg','admin/uploads/demo/BRW-0016.jpg','admin/uploads/demo/BRW-0016.jpg'),
  (@b0 + 17,'Moses Barasa','4516903171',0,'Male','0720549426','moses.barasa85@example.com','1969-12-31','Marsabit, Marsabit','other','admin/uploads/demo/BRW-0017.jpg','admin/uploads/demo/BRW-0017.jpg','admin/uploads/demo/BRW-0017.jpg'),
  (@b0 + 18,'Isaac Omollo','3422692713',0,'Male','0720432099','isaac.omollo84@example.com','1972-04-18','Kitale, Trans Nzoia','Employee','admin/uploads/demo/BRW-0018.jpg','admin/uploads/demo/BRW-0018.jpg','admin/uploads/demo/BRW-0018.jpg'),
  (@b0 + 19,'Emmanuel Wafula','4785810347',0,'Male','0700912477','emmanuel.wafula27@example.com','2000-04-18','Eldoret, Uasin Gishu','Employee','admin/uploads/demo/BRW-0019.jpg','admin/uploads/demo/BRW-0019.jpg','admin/uploads/demo/BRW-0019.jpg'),
  (@b0 + 20,'Victor Maina','4232546457',0,'Male','0700748981','victor.maina81@example.com','1974-02-26','Nanyuki, Laikipia','other','admin/uploads/demo/BRW-0020.jpg','admin/uploads/demo/BRW-0020.jpg','admin/uploads/demo/BRW-0020.jpg'),
  (@b0 + 21,'Mary Njenga','4355576176',0,'Female','0740836052','mary.njenga73@example.com','1970-06-16','Homa Bay, Homa Bay','Unemployed','admin/uploads/demo/BRW-0021.jpg','admin/uploads/demo/BRW-0021.jpg','admin/uploads/demo/BRW-0021.jpg'),
  (@b0 + 22,'Grace Kariuki','4346673968',0,'Female','0740195328','grace.kariuki90@example.com','2001-01-31','Bomet, Bomet','Student','admin/uploads/demo/BRW-0022.jpg','admin/uploads/demo/BRW-0022.jpg','admin/uploads/demo/BRW-0022.jpg'),
  (@b0 + 23,'Jane Macharia','3811179498',0,'Female','0760515760','jane.macharia39@example.com','1978-10-18','Kapenguria, Turkana','Employee','admin/uploads/demo/BRW-0023.jpg','admin/uploads/demo/BRW-0023.jpg','admin/uploads/demo/BRW-0023.jpg'),
  (@b0 + 24,'Ann Mureithi','3305311677',0,'Female','0750230281','ann.mureithi34@example.com','1980-11-14','Chuka, Tharaka Nithi','Unemployed','admin/uploads/demo/BRW-0024.jpg','admin/uploads/demo/BRW-0024.jpg','admin/uploads/demo/BRW-0024.jpg'),
  (@b0 + 25,'Lucy Njuguna','4571811586',0,'Female','0700839132','lucy.njuguna53@example.com','1980-03-25','Nkubu, Meru','Owner','admin/uploads/demo/BRW-0025.jpg','admin/uploads/demo/BRW-0025.jpg','admin/uploads/demo/BRW-0025.jpg'),
  (@b0 + 26,'Catherine Waweru','4271665768',0,'Female','0750297954','catherine.waweru73@example.com','1998-05-27','Limuru, Kiambu','Owner','admin/uploads/demo/BRW-0026.jpg','admin/uploads/demo/BRW-0026.jpg','admin/uploads/demo/BRW-0026.jpg'),
  (@b0 + 27,'Faith Githinji','4937974991',0,'Female','0720924345','faith.githinji85@example.com','1977-12-05','Ruiru, Kiambu','Unemployed','admin/uploads/demo/BRW-0027.jpg','admin/uploads/demo/BRW-0027.jpg','admin/uploads/demo/BRW-0027.jpg'),
  (@b0 + 28,'Esther Mutuma','3805542833',0,'Female','0760884524','esther.mutuma93@example.com','1975-11-09','Mumias Sugar, Kakamega','Employee','admin/uploads/demo/BRW-0028.jpg','admin/uploads/demo/BRW-0028.jpg','admin/uploads/demo/BRW-0028.jpg'),
  (@b0 + 29,'Rose Kilonzo','3227257183',0,'Female','0750929474','rose.kilonzo19@example.com','1968-10-05','Makutani, Trans Nzoia','Owner','admin/uploads/demo/BRW-0029.jpg','admin/uploads/demo/BRW-0029.jpg','admin/uploads/demo/BRW-0029.jpg'),
  (@b0 + 30,'Alice Musyoka','3218561637',0,'Female','0750511465','alice.musyoka20@example.com','1992-02-09','Kilifi, Kilifi','Unemployed','admin/uploads/demo/BRW-0030.jpg','admin/uploads/demo/BRW-0030.jpg','admin/uploads/demo/BRW-0030.jpg'),
  (@b0 + 31,'Caroline Kiprono','3228029236',0,'Female','0750129263','caroline.kiprono33@example.com','2001-12-06','Malindi, Kilifi','other','admin/uploads/demo/BRW-0031.jpg','admin/uploads/demo/BRW-0031.jpg','admin/uploads/demo/BRW-0031.jpg'),
  (@b0 + 32,'Betty Chege','4671741283',0,'Female','0750129804','betty.chege70@example.com','1992-01-27','Ukunda, Kwale','Student','admin/uploads/demo/BRW-0032.jpg','admin/uploads/demo/BRW-0032.jpg','admin/uploads/demo/BRW-0032.jpg'),
  (@b0 + 33,'Dorcas Mbugua','3173949331',0,'Female','0710743409','dorcas.mbugua94@example.com','1984-09-22','Voi Bridge, Tana River','Student','admin/uploads/demo/BRW-0033.jpg','admin/uploads/demo/BRW-0033.jpg','admin/uploads/demo/BRW-0033.jpg'),
  (@b0 + 34,'Elizabeth Ndungu','3318700342',0,'Female','0710276674','elizabeth.ndungu57@example.com','1993-07-13','Wanguru, Kirinyaga','other','admin/uploads/demo/BRW-0034.jpg','admin/uploads/demo/BRW-0034.jpg','admin/uploads/demo/BRW-0034.jpg'),
  (@b0 + 35,'Hellen Kirui','4269301753',0,'Female','0760679676','hellen.kirui94@example.com','1971-01-31','Mwea, Kirinyaga','Student','admin/uploads/demo/BRW-0035.jpg','admin/uploads/demo/BRW-0035.jpg','admin/uploads/demo/BRW-0035.jpg'),
  (@b0 + 36,'Irene Tanui','3155290914',0,'Female','0720347469','irene.tanui11@example.com','1985-03-31','Ol Kalou, Nyandarua','Student','admin/uploads/demo/BRW-0036.jpg','admin/uploads/demo/BRW-0036.jpg','admin/uploads/demo/BRW-0036.jpg'),
  (@b0 + 37,'Joyce Bett','3227556403',0,'Female','0760006115','joyce.bett56@example.com','1996-02-03','Kangema, Muranga','Employee','admin/uploads/demo/BRW-0037.jpg','admin/uploads/demo/BRW-0037.jpg','admin/uploads/demo/BRW-0037.jpg'),
  (@b0 + 38,'Lilian Koech','3651263216',0,'Female','0760027906','lilian.koech96@example.com','1986-04-13','Othaya, Muranga','Unemployed','admin/uploads/demo/BRW-0038.jpg','admin/uploads/demo/BRW-0038.jpg','admin/uploads/demo/BRW-0038.jpg'),
  (@b0 + 39,'Millicent Yego','3249928466',0,'Female','0700853458','millicent.yego61@example.com','1977-05-31','Kigumo, Muranga','Owner','admin/uploads/demo/BRW-0039.jpg','admin/uploads/demo/BRW-0039.jpg','admin/uploads/demo/BRW-0039.jpg'),
  (@b0 + 40,'Nancy Rono','3190752502',0,'Female','0740610818','nancy.rono16@example.com','1985-04-14','Githurai, Kiambu','other','admin/uploads/demo/BRW-0040.jpg','admin/uploads/demo/BRW-0040.jpg','admin/uploads/demo/BRW-0040.jpg');

-- ---------------------------------------------------------------------
-- 2. LOAN APPLICATIONS - 69 records
--
--    `status` follows getLoanVerificationStatus() (ManageLoan.php:121-141):
--      0 = submitted, awaiting verification
--      1 = verified by role 1 (verifier)
--      2 = verified by role 2 (branch officer)
--      3 = approved and disbursed - only these can carry repayments
--
--    Mixture: 25% completed | 25% active | 15% overdue | 15% pending
--             10% approved-not-yet-due | 10% settled by collateral sale
--    "completed", "active" and "overdue" are DERIVED, never stored:
--      completed = status 3 AND amount_paid >= total_loan
--      overdue   = status 3 AND amount_remain > 0 AND next_date <= CURDATE()
--      active    = status 3 AND amount_remain > 0 AND next_date >  CURDATE()
--      (NotificationManager.php:19-29 and ManageLoan.php:206-217)
--
--    Principal  KES 5,000 - 150,000, interest 5-15% monthly, term 1-12
--    months. Every amount, rate, term and date is randomised per record.
-- ---------------------------------------------------------------------
SET @a0 := (SELECT COALESCE(MAX(id), 0) FROM tbl_loan_application);

-- LN-2026-10069 | BRW-0040 | applied 2026-04-18 | approved            -- | disbursed             -- | 1m @ 7% = KES 86189 over 4 instalments of KES 21547
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 1,@b0 + 40,0,'NANCY RONO',80550,7,4,86189,21547,0,86189,0,4,NULL,'admin/uploads/documents/demo/LN-2026-10069.pdf');

-- LN-2026-10054 | BRW-0033 | applied 2026-05-15 | approved 2026-05-30 | disbursed 2026-06-03 | 1m @ 10% = KES 5610 over 4 instalments of KES 1403
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 2,@b0 + 33,3,'DORCAS MBUGUA',5100,10,4,5610,1403,2806,2804,2,2,'2026-09-01','admin/uploads/documents/demo/LN-2026-10054.pdf');

-- LN-2026-10003 | BRW-0001 | applied 2024-10-25 | approved 2024-11-10 | disbursed 2024-11-19 | 1m @ 10% = KES 69795 over 4 instalments of KES 17449
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 3,@b0 + 1,3,'BRIAN OCHIENG',63450,10,4,69795,17449,69795,0,4,0,NULL,'admin/uploads/documents/demo/LN-2026-10003.pdf');

-- LN-2025-10044 | BRW-0028 | applied 2025-07-18 | approved 2025-07-28 | disbursed 2025-08-03 | 1m @ 10% = KES 117205 over 4 instalments of KES 29301
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 4,@b0 + 28,3,'ESTHER MUTUMA',106550,10,4,117205,29301,117205,0,4,0,NULL,'admin/uploads/documents/demo/LN-2025-10044.pdf');

-- LN-2026-10048 | BRW-0030 | applied 2024-08-09 | approved 2024-08-15 | disbursed 2024-08-17 | 6m @ 8% = KES 86580 over 24 instalments of KES 3608
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 5,@b0 + 30,3,'ALICE MUSYOKA',58500,8,24,86580,3608,86580,0,24,0,NULL,'admin/uploads/documents/demo/LN-2026-10048.pdf');

-- LN-2025-10038 | BRW-0026 | applied 2024-09-10 | approved 2024-09-24 | disbursed 2024-10-02 | 6m @ 12% = KES 153080 over 24 instalments of KES 6378
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 6,@b0 + 26,3,'CATHERINE WAWERU',89000,12,24,153080,6378,153080,0,24,0,NULL,'admin/uploads/documents/demo/LN-2025-10038.pdf');

-- LN-2025-10041 | BRW-0027 | applied 2024-01-20 | approved            -- | disbursed             -- | 12m @ 15% = KES 244020 over 48 instalments of KES 5084
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 7,@b0 + 27,0,'FAITH GITHINJI',87150,15,48,244020,5084,0,244020,0,48,NULL,'admin/uploads/documents/demo/LN-2025-10041.pdf');

-- LN-2025-10047 | BRW-0029 | applied 2025-10-16 | approved            -- | disbursed             -- | 2m @ 15% = KES 48295 over 8 instalments of KES 6037
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 8,@b0 + 29,2,'ROSE KILONZO',37150,15,8,48295,6037,0,48295,0,8,NULL,'admin/uploads/documents/demo/LN-2025-10047.pdf');

-- LN-2026-10066 | BRW-0039 | applied 2025-11-18 | approved 2025-11-25 | disbursed 2025-12-03 | 1m @ 15% = KES 40538 over 4 instalments of KES 10135
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 9,@b0 + 39,3,'MILLICENT YEGO',35250,15,4,40538,10135,40538,0,4,0,NULL,'admin/uploads/documents/demo/LN-2026-10066.pdf');

-- LN-2025-10008 | BRW-0005 | applied 2026-03-13 | approved 2026-03-31 | disbursed 2026-04-07 | 2m @ 15% = KES 101790 over 8 instalments of KES 12724
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 10,@b0 + 5,3,'DENNIS KAMAU',78300,15,8,101790,12724,101790,0,8,0,NULL,'admin/uploads/documents/demo/LN-2025-10008.pdf');

-- LN-2024-10040 | BRW-0027 | applied 2024-07-08 | approved 2024-07-15 | disbursed 2024-07-22 | 12m @ 12% = KES 79910 over 48 instalments of KES 1665
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 11,@b0 + 27,3,'FAITH GITHINJI',32750,12,48,79910,1665,43290,36620,26,22,'2026-10-11','admin/uploads/documents/demo/LN-2024-10040.pdf');

-- LN-2026-10012 | BRW-0006 | applied 2025-11-01 | approved 2025-11-15 | disbursed 2025-11-20 | 3m @ 5% = KES 21160 over 12 instalments of KES 1763
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 12,@b0 + 6,3,'ERIC WANJALA',18400,5,12,21160,1763,15074,6086,9,3,'2026-09-17','admin/uploads/documents/demo/LN-2026-10012.pdf');

-- LN-2024-10004 | BRW-0002 | applied 2026-05-13 | approved 2026-05-24 | disbursed 2026-05-31 | 1m @ 7% = KES 48525 over 4 instalments of KES 12131
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 13,@b0 + 2,3,'KEVIN OTIENO',45350,7,4,48525,12131,22806,25719,2,2,'2026-08-29','admin/uploads/documents/demo/LN-2024-10004.pdf');

-- LN-2026-10030 | BRW-0021 | applied 2024-02-11 | approved 2024-02-17 | disbursed 2024-02-26 | 4m @ 15% = KES 180320 over 16 instalments of KES 11270
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 14,@b0 + 21,3,'MARY NJENGA',112700,15,16,180320,11270,180320,0,16,0,NULL,'admin/uploads/documents/demo/LN-2026-10030.pdf');

-- LN-2024-10022 | BRW-0014 | applied 2024-06-20 | approved 2024-06-26 | disbursed 2024-06-29 | 3m @ 8% = KES 99076 over 12 instalments of KES 8256
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 15,@b0 + 14,3,'JOSEPH KIMANI',79900,8,12,99076,8256,99076,0,12,0,NULL,'admin/uploads/documents/demo/LN-2024-10022.pdf');

-- LN-2024-10028 | BRW-0020 | applied 2025-12-17 | approved 2026-01-01 | disbursed 2026-01-03 | 9m @ 8% = KES 58480 over 36 instalments of KES 1624
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 16,@b0 + 20,3,'VICTOR MAINA',34000,8,36,58480,1624,12992,45488,8,28,'2026-09-30','admin/uploads/documents/demo/LN-2024-10028.pdf');

-- LN-2024-10052 | BRW-0033 | applied 2026-06-13 | approved 2026-06-28 | disbursed 2026-06-30 | 1m @ 8% = KES 54702 over 4 instalments of KES 13676
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 17,@b0 + 33,3,'DORCAS MBUGUA',50650,8,4,54702,13676,8479,46223,1,3,'2026-08-29','admin/uploads/documents/demo/LN-2024-10052.pdf');

-- LN-2025-10002 | BRW-0001 | applied 2026-04-03 | approved 2026-04-08 | disbursed 2026-04-12 | 9m @ 5% = KES 62640 over 36 instalments of KES 1740
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 18,@b0 + 1,3,'BRIAN OCHIENG',43200,5,36,62640,1740,8700,53940,5,31,'2026-10-09','admin/uploads/documents/demo/LN-2025-10002.pdf');

-- LN-2025-10053 | BRW-0033 | applied 2026-02-05 | approved 2026-02-18 | disbursed 2026-02-22 | 4m @ 8% = KES 115104 over 16 instalments of KES 7194
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 19,@b0 + 33,3,'DORCAS MBUGUA',87200,8,16,115104,7194,50358,64746,7,9,'2026-10-24','admin/uploads/documents/demo/LN-2025-10053.pdf');

-- LN-2024-10001 | BRW-0001 | applied 2025-12-05 | approved 2025-12-17 | disbursed 2025-12-25 | 3m @ 8% = KES 96968 over 12 instalments of KES 8081
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 20,@b0 + 1,3,'BRIAN OCHIENG',78200,8,12,96968,8081,72729,24239,9,3,'2026-10-23','admin/uploads/documents/demo/LN-2024-10001.pdf');

-- LN-2026-10045 | BRW-0028 | applied 2025-06-21 | approved 2025-06-29 | disbursed 2025-07-06 | 6m @ 8% = KES 131202 over 24 instalments of KES 5467
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 21,@b0 + 28,3,'ESTHER MUTUMA',88650,8,24,131202,5467,76538,54664,14,10,'2026-09-29','admin/uploads/documents/demo/LN-2026-10045.pdf');

-- LN-2025-10068 | BRW-0040 | applied 2024-06-02 | approved            -- | disbursed             -- | 1m @ 7% = KES 85440 over 4 instalments of KES 21360
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 22,@b0 + 40,1,'NANCY RONO',79850,7,4,85440,21360,0,85440,0,4,NULL,'admin/uploads/documents/demo/LN-2025-10068.pdf');

-- LN-2024-10013 | BRW-0007 | applied 2024-02-11 | approved 2024-02-17 | disbursed 2024-02-22 | 3m @ 5% = KES 40653 over 12 instalments of KES 3388
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 23,@b0 + 7,3,'FRANCIS MUTUA',35350,5,12,40653,3388,40653,0,12,0,NULL,'admin/uploads/documents/demo/LN-2024-10013.pdf');

-- LN-2025-10059 | BRW-0036 | applied 2024-10-03 | approved 2024-10-08 | disbursed 2024-10-11 | 12m @ 10% = KES 20460 over 48 instalments of KES 426
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 24,@b0 + 36,3,'IRENE TANUI',9300,10,48,20460,426,9798,10662,23,25,'2026-10-04','admin/uploads/documents/demo/LN-2025-10059.pdf');

-- LN-2026-10021 | BRW-0014 | applied 2025-06-24 | approved 2025-07-05 | disbursed 2025-07-12 | 3m @ 12% = KES 126548 over 12 instalments of KES 10546
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 25,@b0 + 14,3,'JOSEPH KIMANI',93050,12,12,126548,10546,126548,0,12,0,NULL,'admin/uploads/documents/demo/LN-2026-10021.pdf');

-- LN-2026-10063 | BRW-0038 | applied 2024-12-06 | approved 2024-12-12 | disbursed 2024-12-15 | 6m @ 15% = KES 22705 over 24 instalments of KES 946
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 26,@b0 + 38,3,'LILIAN KOECH',11950,15,24,22705,946,22705,0,24,0,NULL,'admin/uploads/documents/demo/LN-2026-10063.pdf');

-- LN-2026-10009 | BRW-0005 | applied 2024-02-29 | approved            -- | disbursed             -- | 4m @ 15% = KES 85920 over 16 instalments of KES 5370
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 27,@b0 + 5,1,'DENNIS KAMAU',53700,15,16,85920,5370,0,85920,0,16,NULL,'admin/uploads/documents/demo/LN-2026-10009.pdf');

-- LN-2026-10036 | BRW-0026 | applied 2025-03-21 | approved 2025-03-27 | disbursed 2025-03-29 | 6m @ 8% = KES 126466 over 24 instalments of KES 5269
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 28,@b0 + 26,3,'CATHERINE WAWERU',85450,8,24,126466,5269,126466,0,24,0,NULL,'admin/uploads/documents/demo/LN-2026-10036.pdf');

-- LN-2024-10016 | BRW-0010 | applied 2024-11-08 | approved 2024-11-25 | disbursed 2024-11-28 | 12m @ 10% = KES 80520 over 48 instalments of KES 1678
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 29,@b0 + 10,3,'PETER KOSGEI',36600,10,48,80520,1678,36916,43604,22,26,'2026-10-21','admin/uploads/documents/demo/LN-2024-10016.pdf');

-- LN-2024-10055 | BRW-0034 | applied 2026-09-04 | approved 2026-09-20 | disbursed 2026-09-23 | 6m @ 12% = KES 175182 over 24 instalments of KES 7299
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 30,@b0 + 34,3,'ELIZABETH NDUNGU',101850,12,24,175182,7299,0,175182,0,24,'2026-10-23','admin/uploads/documents/demo/LN-2024-10055.pdf');

-- LN-2025-10056 | BRW-0034 | applied 2024-08-04 | approved            -- | disbursed             -- | 6m @ 8% = KES 37888 over 24 instalments of KES 1579
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 31,@b0 + 34,1,'ELIZABETH NDUNGU',25600,8,24,37888,1579,0,37888,0,24,NULL,'admin/uploads/documents/demo/LN-2025-10056.pdf');

-- LN-2024-10043 | BRW-0027 | applied 2026-08-28 | approved 2026-09-12 | disbursed 2026-09-14 | 4m @ 15% = KES 69600 over 16 instalments of KES 4350
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 32,@b0 + 27,3,'FAITH GITHINJI',43500,15,16,69600,4350,0,69600,0,16,'2026-10-14','admin/uploads/documents/demo/LN-2024-10043.pdf');

-- LN-2026-10039 | BRW-0026 | applied 2026-08-31 | approved 2026-09-06 | disbursed 2026-09-09 | 9m @ 5% = KES 73733 over 36 instalments of KES 2048
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 33,@b0 + 26,3,'CATHERINE WAWERU',50850,5,36,73733,2048,0,73733,0,36,'2026-10-09','admin/uploads/documents/demo/LN-2026-10039.pdf');

-- LN-2024-10034 | BRW-0024 | applied 2025-11-21 | approved 2025-11-27 | disbursed 2025-12-04 | 3m @ 10% = KES 29380 over 12 instalments of KES 2448
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 34,@b0 + 24,3,'ANN MUREITHI',22600,10,12,29380,2448,22032,7348,9,3,'2026-10-02','admin/uploads/documents/demo/LN-2024-10034.pdf');

-- LN-2026-10033 | BRW-0023 | applied 2024-03-10 | approved            -- | disbursed             -- | 3m @ 7% = KES 11677 over 12 instalments of KES 973
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 35,@b0 + 23,0,'JANE MACHARIA',9650,7,12,11677,973,0,11677,0,12,NULL,'admin/uploads/documents/demo/LN-2026-10033.pdf');

-- LN-2024-10037 | BRW-0026 | applied 2026-03-16 | approved 2026-03-27 | disbursed 2026-04-03 | 1m @ 15% = KES 12938 over 4 instalments of KES 3235
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 36,@b0 + 26,3,'CATHERINE WAWERU',11250,15,4,12938,3235,12938,0,4,0,NULL,'admin/uploads/documents/demo/LN-2024-10037.pdf');

-- LN-2025-10026 | BRW-0018 | applied 2024-01-12 | approved 2024-01-19 | disbursed 2024-01-22 | 3m @ 15% = KES 69963 over 12 instalments of KES 5830
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 37,@b0 + 18,3,'ISAAC OMOLLO',48250,15,12,69963,5830,69963,0,12,0,NULL,'admin/uploads/documents/demo/LN-2025-10026.pdf');

-- LN-2025-10050 | BRW-0031 | applied 2026-04-19 | approved 2026-05-05 | disbursed 2026-05-07 | 2m @ 15% = KES 10335 over 8 instalments of KES 1292
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 38,@b0 + 31,3,'CAROLINE KIPRONO',7950,15,8,10335,1292,10335,0,8,0,NULL,'admin/uploads/documents/demo/LN-2025-10050.pdf');

-- LN-2026-10006 | BRW-0003 | applied 2025-06-02 | approved 2025-06-19 | disbursed 2025-06-22 | 6m @ 5% = KES 47970 over 24 instalments of KES 1999
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 39,@b0 + 3,3,'COLLINS MWANGI',36900,5,24,47970,1999,29985,17985,15,9,'2026-10-15','admin/uploads/documents/demo/LN-2026-10006.pdf');

-- LN-2025-10032 | BRW-0022 | applied 2025-01-27 | approved 2025-02-02 | disbursed 2025-02-08 | 6m @ 10% = KES 105920 over 24 instalments of KES 4413
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 40,@b0 + 22,3,'GRACE KARIUKI',66200,10,24,105920,4413,83847,22073,19,5,'2026-10-02','admin/uploads/documents/demo/LN-2025-10032.pdf');

-- LN-2026-10018 | BRW-0011 | applied 2026-01-21 | approved 2026-02-06 | disbursed 2026-02-11 | 2m @ 10% = KES 64500 over 8 instalments of KES 8063
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 41,@b0 + 11,3,'SAMUEL WEKESA',53750,10,8,64500,8063,56441,8059,7,1,'2026-10-13','admin/uploads/documents/demo/LN-2026-10018.pdf');

-- LN-2025-10062 | BRW-0038 | applied 2026-08-30 | approved 2026-09-11 | disbursed 2026-09-17 | 6m @ 15% = KES 151810 over 24 instalments of KES 6325
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 42,@b0 + 38,3,'LILIAN KOECH',79900,15,24,151810,6325,0,151810,0,24,'2026-10-17','admin/uploads/documents/demo/LN-2025-10062.pdf');

-- LN-2026-10057 | BRW-0035 | applied 2024-05-12 | approved            -- | disbursed             -- | 2m @ 5% = KES 95810 over 8 instalments of KES 11976
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 43,@b0 + 35,0,'HELLEN KIRUI',87100,5,8,95810,11976,0,95810,0,8,NULL,'admin/uploads/documents/demo/LN-2026-10057.pdf');

-- LN-2024-10067 | BRW-0039 | applied 2024-05-25 | approved 2024-06-06 | disbursed 2024-06-11 | 2m @ 10% = KES 134460 over 8 instalments of KES 16808
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 44,@b0 + 39,3,'MILLICENT YEGO',112050,10,8,134460,16808,134460,0,8,0,NULL,'admin/uploads/documents/demo/LN-2024-10067.pdf');

-- LN-2026-10027 | BRW-0019 | applied 2026-08-25 | approved 2026-09-10 | disbursed 2026-09-16 | 9m @ 8% = KES 84452 over 36 instalments of KES 2346
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 45,@b0 + 19,3,'EMMANUEL WAFULA',49100,8,36,84452,2346,0,84452,0,36,'2026-10-16','admin/uploads/documents/demo/LN-2026-10027.pdf');

-- LN-2025-10029 | BRW-0020 | applied 2024-11-18 | approved            -- | disbursed             -- | 1m @ 8% = KES 75654 over 4 instalments of KES 18914
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 46,@b0 + 20,1,'VICTOR MAINA',70050,8,4,75654,18914,0,75654,0,4,NULL,'admin/uploads/documents/demo/LN-2025-10029.pdf');

-- LN-2024-10049 | BRW-0030 | applied 2025-01-31 | approved 2025-02-10 | disbursed 2025-02-17 | 6m @ 15% = KES 18620 over 24 instalments of KES 776
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 47,@b0 + 30,3,'ALICE MUSYOKA',9800,15,24,18620,776,13704,4916,18,6,'2026-09-12','admin/uploads/documents/demo/LN-2024-10049.pdf');

-- LN-2026-10060 | BRW-0037 | applied 2024-05-08 | approved 2024-05-15 | disbursed 2024-05-21 | 4m @ 12% = KES 23458 over 16 instalments of KES 1466
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 48,@b0 + 37,3,'JOYCE BETT',15850,12,16,23458,1466,23458,0,16,0,NULL,'admin/uploads/documents/demo/LN-2026-10060.pdf');

-- LN-2024-10058 | BRW-0036 | applied 2026-04-30 | approved 2026-05-08 | disbursed 2026-05-16 | 2m @ 10% = KES 93540 over 8 instalments of KES 11693
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 49,@b0 + 36,3,'IRENE TANUI',77950,10,8,93540,11693,93540,0,8,0,NULL,'admin/uploads/documents/demo/LN-2024-10058.pdf');

-- LN-2026-10042 | BRW-0027 | applied 2025-03-26 | approved 2025-04-05 | disbursed 2025-04-13 | 3m @ 8% = KES 37820 over 12 instalments of KES 3152
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 50,@b0 + 27,3,'FAITH GITHINJI',30500,8,12,37820,3152,37820,0,12,0,NULL,'admin/uploads/documents/demo/LN-2026-10042.pdf');

-- LN-2024-10031 | BRW-0021 | applied 2025-08-12 | approved 2025-08-17 | disbursed 2025-08-25 | 4m @ 7% = KES 36288 over 16 instalments of KES 2268
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 51,@b0 + 21,3,'MARY NJENGA',28350,7,16,36288,2268,27216,9072,12,4,'2026-09-19','admin/uploads/documents/demo/LN-2024-10031.pdf');

-- LN-2024-10064 | BRW-0038 | applied 2026-08-15 | approved 2026-08-30 | disbursed 2026-09-05 | 1m @ 8% = KES 115668 over 4 instalments of KES 28917
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 52,@b0 + 38,3,'LILIAN KOECH',107100,8,4,115668,28917,0,115668,0,4,'2026-10-05','admin/uploads/documents/demo/LN-2024-10064.pdf');

-- LN-2025-10014 | BRW-0008 | applied 2025-09-10 | approved 2025-09-17 | disbursed 2025-09-21 | 6m @ 10% = KES 146080 over 24 instalments of KES 6087
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 53,@b0 + 8,3,'GEORGE KIPTOO',91300,10,24,146080,6087,73044,73036,12,12,'2026-10-17','admin/uploads/documents/demo/LN-2025-10014.pdf');

-- LN-2025-10017 | BRW-0011 | applied 2026-02-08 | approved 2026-02-19 | disbursed 2026-02-24 | 3m @ 5% = KES 75383 over 12 instalments of KES 6282
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 54,@b0 + 11,3,'SAMUEL WEKESA',65550,5,12,75383,6282,37692,37691,6,6,'2026-09-25','admin/uploads/documents/demo/LN-2025-10017.pdf');

-- LN-2025-10011 | BRW-0005 | applied 2025-10-21 | approved 2025-11-06 | disbursed 2025-11-11 | 4m @ 8% = KES 68904 over 16 instalments of KES 4307
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 55,@b0 + 5,3,'DENNIS KAMAU',52200,8,16,68904,4307,43070,25834,10,6,'2026-10-09','admin/uploads/documents/demo/LN-2025-10011.pdf');

-- LN-2024-10025 | BRW-0017 | applied 2026-07-22 | approved 2026-07-28 | disbursed 2026-08-01 | 2m @ 5% = KES 69960 over 8 instalments of KES 8745
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 56,@b0 + 17,3,'MOSES BARASA',63600,5,8,69960,8745,8745,61215,1,7,'2026-10-02','admin/uploads/documents/demo/LN-2024-10025.pdf');

-- LN-2024-10019 | BRW-0012 | applied 2024-03-10 | approved 2024-03-18 | disbursed 2024-03-24 | 6m @ 8% = KES 140082 over 24 instalments of KES 5837
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 57,@b0 + 12,3,'DAVID ODHIAMBO',94650,8,24,140082,5837,140082,0,24,0,NULL,'admin/uploads/documents/demo/LN-2024-10019.pdf');

-- LN-2024-10061 | BRW-0037 | applied 2026-08-09 | approved 2026-08-28 | disbursed 2026-08-31 | 12m @ 10% = KES 203830 over 48 instalments of KES 4246
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 58,@b0 + 37,3,'JOYCE BETT',92650,10,48,203830,4246,0,203830,0,48,'2026-09-30','admin/uploads/documents/demo/LN-2024-10061.pdf');

-- LN-2024-10010 | BRW-0005 | applied 2026-05-13 | approved 2026-05-29 | disbursed 2026-06-05 | 2m @ 8% = KES 113100 over 8 instalments of KES 14138
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 59,@b0 + 5,3,'DENNIS KAMAU',97500,8,8,113100,14138,42414,70686,3,5,'2026-10-07','admin/uploads/documents/demo/LN-2024-10010.pdf');

-- LN-2025-10020 | BRW-0013 | applied 2025-12-28 | approved 2026-01-08 | disbursed 2026-01-15 | 2m @ 12% = KES 83018 over 8 instalments of KES 10377
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 60,@b0 + 13,3,'MICHAEL ONYANGO',66950,12,8,83018,10377,83018,0,8,0,NULL,'admin/uploads/documents/demo/LN-2025-10020.pdf');

-- LN-2026-10051 | BRW-0032 | applied 2026-02-21 | approved 2026-03-10 | disbursed 2026-03-19 | 3m @ 15% = KES 15588 over 12 instalments of KES 1299
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 61,@b0 + 32,3,'BETTY CHEGE',10750,15,12,15588,1299,7794,7794,6,6,'2026-10-18','admin/uploads/documents/demo/LN-2026-10051.pdf');

-- LN-2025-10023 | BRW-0015 | applied 2025-02-12 | approved 2025-02-28 | disbursed 2025-03-05 | 1m @ 15% = KES 70208 over 4 instalments of KES 17552
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 62,@b0 + 15,3,'DANIEL ROTICH',61050,15,4,70208,17552,70208,0,4,0,NULL,'admin/uploads/documents/demo/LN-2025-10023.pdf');

-- LN-2024-10046 | BRW-0028 | applied 2024-11-18 | approved 2024-11-24 | disbursed 2024-11-28 | 12m @ 8% = KES 184044 over 48 instalments of KES 3834
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 63,@b0 + 28,3,'ESTHER MUTUMA',93900,8,48,184044,3834,79594,104450,21,27,'2026-09-21','admin/uploads/documents/demo/LN-2024-10046.pdf');

-- LN-2025-10005 | BRW-0003 | applied 2026-05-09 | approved 2026-05-20 | disbursed 2026-05-22 | 2m @ 15% = KES 127660 over 8 instalments of KES 15958
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 64,@b0 + 3,3,'COLLINS MWANGI',98200,15,8,127660,15958,127660,0,8,0,NULL,'admin/uploads/documents/demo/LN-2025-10005.pdf');

-- LN-2026-10015 | BRW-0009 | applied 2024-05-09 | approved            -- | disbursed             -- | 6m @ 10% = KES 110720 over 24 instalments of KES 4613
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 65,@b0 + 9,1,'ANTHONY SANG',69200,10,24,110720,4613,0,110720,0,24,NULL,'admin/uploads/documents/demo/LN-2026-10015.pdf');

-- LN-2025-10065 | BRW-0039 | applied 2024-11-11 | approved 2024-11-29 | disbursed 2024-12-04 | 3m @ 7% = KES 84761 over 12 instalments of KES 7063
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 66,@b0 + 39,3,'MILLICENT YEGO',70050,7,12,84761,7063,84761,0,12,0,NULL,'admin/uploads/documents/demo/LN-2025-10065.pdf');

-- LN-2024-10007 | BRW-0004 | applied 2024-09-21 | approved 2024-09-29 | disbursed 2024-10-02 | 6m @ 7% = KES 70858 over 24 instalments of KES 2952
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 67,@b0 + 4,3,'EVANS NJOROGE',49900,7,24,70858,2952,66627,4231,23,1,'2026-09-23','admin/uploads/documents/demo/LN-2024-10007.pdf');

-- LN-2026-10024 | BRW-0016 | applied 2025-07-31 | approved 2025-08-10 | disbursed 2025-08-17 | 4m @ 10% = KES 73010 over 16 instalments of KES 4563
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 68,@b0 + 16,3,'PATRICK KIPROTICH',52150,10,16,73010,4563,73010,0,16,0,NULL,'admin/uploads/documents/demo/LN-2026-10024.pdf');

-- LN-2025-10035 | BRW-0025 | applied 2026-03-04 | approved 2026-03-10 | disbursed 2026-03-19 | 2m @ 7% = KES 8037 over 8 instalments of KES 1005
INSERT INTO `tbl_loan_application`
  (`id`,`b_id`,`status`,`name`,`expected_loan`,`loan_percentage`,`installments`,
   `total_loan`,`emi_loan`,`amount_paid`,`amount_remain`,`current_inst`,`remain_inst`,`next_date`,`files`)
VALUES (@a0 + 69,@b0 + 25,3,'LUCY NJUGUNA',7050,7,8,8037,1005,4784,3253,5,3,'2026-09-18','admin/uploads/documents/demo/LN-2025-10035.pdf');

-- ---------------------------------------------------------------------
-- 3. REPAYMENTS - tbl_payment (568 rows)
--    One row per instalment actually collected, 30 days apart with a
--    little lateness jitter. `pay_amount` is int(11), so the closing
--    instalment of a settled loan carries the rounding remainder and is
--    therefore not equal to emi_loan - exactly what the live app does.
--    Overdue loans get a partial underpayment on the latest instalment
--    and, for most of them, a `fine` penalty. `fine` is recorded but never
--    added to amount_paid (ManageLoan.php:239-243, 262-268), so no
--    repayment can ever exceed what was owed. A `fine` of 0 means
--    "not yet penalised"; NULL is never used.
--    id is left to AUTO_INCREMENT - no code path references a payment id
--    that it has not just read from a result set (payment_report.php).
-- ---------------------------------------------------------------------
-- LN-2026-10054 | BRW-0033 | 2 of 4 instalments | cash collected KES 2806 | outstanding KES 2804 | penalty KES 1350
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 33,@a0 + 2,1403,'2026-07-04',1,3,0),
  (@b0 + 33,@a0 + 2,1403,'2026-08-02',2,2,1350);

-- LN-2026-10003 | BRW-0001 | 4 of 4 instalments | cash collected KES 69795 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 1,@a0 + 3,17449,'2024-12-21',1,3,0),
  (@b0 + 1,@a0 + 3,17449,'2025-01-21',2,2,0),
  (@b0 + 1,@a0 + 3,17449,'2025-02-19',3,1,0),
  (@b0 + 1,@a0 + 3,17448,'2025-03-19',4,0,0);

-- LN-2025-10044 | BRW-0028 | 4 of 4 instalments | cash collected KES 117205 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 28,@a0 + 4,29301,'2025-09-03',1,3,0),
  (@b0 + 28,@a0 + 4,29301,'2025-10-05',2,2,0),
  (@b0 + 28,@a0 + 4,29301,'2025-11-04',3,1,0),
  (@b0 + 28,@a0 + 4,29302,'2025-12-01',4,0,0);

-- LN-2026-10048 | BRW-0030 | 24 of 24 instalments | cash collected KES 86580 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 30,@a0 + 5,3608,'2024-09-18',1,23,0),
  (@b0 + 30,@a0 + 5,3608,'2024-10-19',2,22,0),
  (@b0 + 30,@a0 + 5,3608,'2024-11-15',3,21,0),
  (@b0 + 30,@a0 + 5,3608,'2024-12-15',4,20,0),
  (@b0 + 30,@a0 + 5,3608,'2025-01-16',5,19,0),
  (@b0 + 30,@a0 + 5,3608,'2025-02-17',6,18,0),
  (@b0 + 30,@a0 + 5,3608,'2025-03-19',7,17,0),
  (@b0 + 30,@a0 + 5,3608,'2025-04-15',8,16,0),
  (@b0 + 30,@a0 + 5,3608,'2025-05-15',9,15,0),
  (@b0 + 30,@a0 + 5,3608,'2025-06-15',10,14,0),
  (@b0 + 30,@a0 + 5,3608,'2025-07-14',11,13,0),
  (@b0 + 30,@a0 + 5,3608,'2025-08-15',12,12,0),
  (@b0 + 30,@a0 + 5,3608,'2025-09-14',13,11,0),
  (@b0 + 30,@a0 + 5,3608,'2025-10-11',14,10,0),
  (@b0 + 30,@a0 + 5,3608,'2025-11-14',15,9,0),
  (@b0 + 30,@a0 + 5,3608,'2025-12-14',16,8,0),
  (@b0 + 30,@a0 + 5,3608,'2026-01-13',17,7,0),
  (@b0 + 30,@a0 + 5,3608,'2026-02-09',18,6,0),
  (@b0 + 30,@a0 + 5,3608,'2026-03-14',19,5,0),
  (@b0 + 30,@a0 + 5,3608,'2026-04-09',20,4,0),
  (@b0 + 30,@a0 + 5,3608,'2026-05-12',21,3,0),
  (@b0 + 30,@a0 + 5,3608,'2026-06-12',22,2,0),
  (@b0 + 30,@a0 + 5,3608,'2026-07-09',23,1,0),
  (@b0 + 30,@a0 + 5,3596,'2026-08-07',24,0,0);

-- LN-2025-10038 | BRW-0026 | 24 of 24 instalments | cash collected KES 153080 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 26,@a0 + 6,6378,'2024-11-04',1,23,0),
  (@b0 + 26,@a0 + 6,6378,'2024-12-01',2,22,0),
  (@b0 + 26,@a0 + 6,6378,'2025-01-02',3,21,0),
  (@b0 + 26,@a0 + 6,6378,'2025-02-02',4,20,0),
  (@b0 + 26,@a0 + 6,6378,'2025-03-04',5,19,0),
  (@b0 + 26,@a0 + 6,6378,'2025-03-31',6,18,0),
  (@b0 + 26,@a0 + 6,6378,'2025-05-03',7,17,0),
  (@b0 + 26,@a0 + 6,6378,'2025-05-31',8,16,0),
  (@b0 + 26,@a0 + 6,6378,'2025-07-01',9,15,0),
  (@b0 + 26,@a0 + 6,6378,'2025-07-31',10,14,0),
  (@b0 + 26,@a0 + 6,6378,'2025-08-31',11,13,0),
  (@b0 + 26,@a0 + 6,6378,'2025-10-01',12,12,0),
  (@b0 + 26,@a0 + 6,6378,'2025-10-29',13,11,0),
  (@b0 + 26,@a0 + 6,6378,'2025-11-29',14,10,0),
  (@b0 + 26,@a0 + 6,6378,'2025-12-30',15,9,0),
  (@b0 + 26,@a0 + 6,6378,'2026-01-25',16,8,0),
  (@b0 + 26,@a0 + 6,6378,'2026-02-28',17,7,0),
  (@b0 + 26,@a0 + 6,6378,'2026-03-28',18,6,0),
  (@b0 + 26,@a0 + 6,6378,'2026-04-29',19,5,0),
  (@b0 + 26,@a0 + 6,6378,'2026-05-26',20,4,0),
  (@b0 + 26,@a0 + 6,6378,'2026-06-27',21,3,0),
  (@b0 + 26,@a0 + 6,6378,'2026-07-26',22,2,0),
  (@b0 + 26,@a0 + 6,6378,'2026-08-25',23,1,0),
  (@b0 + 26,@a0 + 6,6386,'2026-09-22',24,0,0);

-- LN-2026-10066 | BRW-0039 | 4 of 4 instalments | cash collected KES 40538 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 39,@a0 + 9,10135,'2026-01-04',1,3,0),
  (@b0 + 39,@a0 + 9,10135,'2026-02-05',2,2,0),
  (@b0 + 39,@a0 + 9,10135,'2026-03-03',3,1,0),
  (@b0 + 39,@a0 + 9,10133,'2026-04-02',4,0,0);

-- LN-2025-10008 | BRW-0005 | 4 of 8 instalments | cash collected KES 48733 | outstanding KES 0 | KES 53057 of this still owed here, cleared by collateral KES 53057
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 5,@a0 + 10,12724,'2026-05-11',1,7,0),
  (@b0 + 5,@a0 + 10,12724,'2026-06-08',2,6,0),
  (@b0 + 5,@a0 + 10,12724,'2026-07-08',3,5,0),
  (@b0 + 5,@a0 + 10,10561,'2026-08-06',4,4,0);

-- LN-2024-10040 | BRW-0027 | 26 of 48 instalments | cash collected KES 43290 | outstanding KES 36620
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 27,@a0 + 11,1665,'2024-08-22',1,47,0),
  (@b0 + 27,@a0 + 11,1665,'2024-09-20',2,46,0),
  (@b0 + 27,@a0 + 11,1665,'2024-10-21',3,45,0),
  (@b0 + 27,@a0 + 11,1665,'2024-11-23',4,44,0),
  (@b0 + 27,@a0 + 11,1665,'2024-12-22',5,43,0),
  (@b0 + 27,@a0 + 11,1665,'2025-01-20',6,42,0),
  (@b0 + 27,@a0 + 11,1665,'2025-02-19',7,41,0),
  (@b0 + 27,@a0 + 11,1665,'2025-03-20',8,40,0),
  (@b0 + 27,@a0 + 11,1665,'2025-04-18',9,39,0),
  (@b0 + 27,@a0 + 11,1665,'2025-05-20',10,38,0),
  (@b0 + 27,@a0 + 11,1665,'2025-06-19',11,37,0),
  (@b0 + 27,@a0 + 11,1665,'2025-07-18',12,36,0),
  (@b0 + 27,@a0 + 11,1665,'2025-08-20',13,35,0),
  (@b0 + 27,@a0 + 11,1665,'2025-09-19',14,34,0),
  (@b0 + 27,@a0 + 11,1665,'2025-10-17',15,33,0),
  (@b0 + 27,@a0 + 11,1665,'2025-11-15',16,32,0),
  (@b0 + 27,@a0 + 11,1665,'2025-12-16',17,31,0),
  (@b0 + 27,@a0 + 11,1665,'2026-01-13',18,30,0),
  (@b0 + 27,@a0 + 11,1665,'2026-02-14',19,29,0),
  (@b0 + 27,@a0 + 11,1665,'2026-03-15',20,28,0),
  (@b0 + 27,@a0 + 11,1665,'2026-04-16',21,27,0),
  (@b0 + 27,@a0 + 11,1665,'2026-05-13',22,26,0),
  (@b0 + 27,@a0 + 11,1665,'2026-06-13',23,25,0),
  (@b0 + 27,@a0 + 11,1665,'2026-07-12',24,24,0),
  (@b0 + 27,@a0 + 11,1665,'2026-08-11',25,23,0),
  (@b0 + 27,@a0 + 11,1665,'2026-09-11',26,22,0);

-- LN-2026-10012 | BRW-0006 | 9 of 12 instalments | cash collected KES 15074 | outstanding KES 6086 | penalty KES 450
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 6,@a0 + 12,1763,'2025-12-22',1,11,0),
  (@b0 + 6,@a0 + 12,1763,'2026-01-22',2,10,0),
  (@b0 + 6,@a0 + 12,1763,'2026-02-20',3,9,0),
  (@b0 + 6,@a0 + 12,1763,'2026-03-23',4,8,0),
  (@b0 + 6,@a0 + 12,1763,'2026-04-20',5,7,0),
  (@b0 + 6,@a0 + 12,1763,'2026-05-22',6,6,0),
  (@b0 + 6,@a0 + 12,1763,'2026-06-19',7,5,0),
  (@b0 + 6,@a0 + 12,1763,'2026-07-18',8,4,0),
  (@b0 + 6,@a0 + 12,970,'2026-08-18',9,3,450);

-- LN-2024-10004 | BRW-0002 | 2 of 4 instalments | cash collected KES 22806 | outstanding KES 25719 | penalty KES 1500
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 2,@a0 + 13,12131,'2026-07-01',1,3,0),
  (@b0 + 2,@a0 + 13,10675,'2026-07-30',2,2,1500);

-- LN-2026-10030 | BRW-0021 | 16 of 16 instalments | cash collected KES 180320 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 21,@a0 + 14,11270,'2024-03-30',1,15,0),
  (@b0 + 21,@a0 + 14,11270,'2024-04-26',2,14,0),
  (@b0 + 21,@a0 + 14,11270,'2024-05-28',3,13,0),
  (@b0 + 21,@a0 + 14,11270,'2024-06-25',4,12,0),
  (@b0 + 21,@a0 + 14,11270,'2024-07-28',5,11,0),
  (@b0 + 21,@a0 + 14,11270,'2024-08-25',6,10,0),
  (@b0 + 21,@a0 + 14,11270,'2024-09-26',7,9,0),
  (@b0 + 21,@a0 + 14,11270,'2024-10-27',8,8,0),
  (@b0 + 21,@a0 + 14,11270,'2024-11-26',9,7,0),
  (@b0 + 21,@a0 + 14,11270,'2024-12-26',10,6,0),
  (@b0 + 21,@a0 + 14,11270,'2025-01-21',11,5,0),
  (@b0 + 21,@a0 + 14,11270,'2025-02-21',12,4,0),
  (@b0 + 21,@a0 + 14,11270,'2025-03-25',13,3,0),
  (@b0 + 21,@a0 + 14,11270,'2025-04-21',14,2,0),
  (@b0 + 21,@a0 + 14,11270,'2025-05-25',15,1,0),
  (@b0 + 21,@a0 + 14,11270,'2025-06-20',16,0,0);

-- LN-2024-10022 | BRW-0014 | 12 of 12 instalments | cash collected KES 99076 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 14,@a0 + 15,8256,'2024-08-02',1,11,0),
  (@b0 + 14,@a0 + 15,8256,'2024-08-30',2,10,0),
  (@b0 + 14,@a0 + 15,8256,'2024-09-29',3,9,0),
  (@b0 + 14,@a0 + 15,8256,'2024-10-28',4,8,0),
  (@b0 + 14,@a0 + 15,8256,'2024-11-27',5,7,0),
  (@b0 + 14,@a0 + 15,8256,'2024-12-29',6,6,0),
  (@b0 + 14,@a0 + 15,8256,'2025-01-28',7,5,0),
  (@b0 + 14,@a0 + 15,8256,'2025-02-28',8,4,0),
  (@b0 + 14,@a0 + 15,8256,'2025-03-30',9,3,0),
  (@b0 + 14,@a0 + 15,8256,'2025-04-26',10,2,0),
  (@b0 + 14,@a0 + 15,8256,'2025-05-28',11,1,0),
  (@b0 + 14,@a0 + 15,8260,'2025-06-24',12,0,0);

-- LN-2024-10028 | BRW-0020 | 8 of 36 instalments | cash collected KES 12992 | outstanding KES 45488
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 20,@a0 + 16,1624,'2026-02-03',1,35,0),
  (@b0 + 20,@a0 + 16,1624,'2026-03-07',2,34,0),
  (@b0 + 20,@a0 + 16,1624,'2026-04-03',3,33,0),
  (@b0 + 20,@a0 + 16,1624,'2026-05-03',4,32,0),
  (@b0 + 20,@a0 + 16,1624,'2026-06-06',5,31,0),
  (@b0 + 20,@a0 + 16,1624,'2026-07-05',6,30,0),
  (@b0 + 20,@a0 + 16,1624,'2026-08-03',7,29,0),
  (@b0 + 20,@a0 + 16,1624,'2026-08-31',8,28,0);

-- LN-2024-10052 | BRW-0033 | 1 of 4 instalments | cash collected KES 8479 | outstanding KES 46223 | penalty KES 1550
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 33,@a0 + 17,8479,'2026-07-30',1,3,1550);

-- LN-2025-10002 | BRW-0001 | 5 of 36 instalments | cash collected KES 8700 | outstanding KES 53940
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 1,@a0 + 18,1740,'2026-05-16',1,35,0),
  (@b0 + 1,@a0 + 18,1740,'2026-06-13',2,34,0),
  (@b0 + 1,@a0 + 18,1740,'2026-07-11',3,33,0),
  (@b0 + 1,@a0 + 18,1740,'2026-08-12',4,32,0),
  (@b0 + 1,@a0 + 18,1740,'2026-09-09',5,31,0);

-- LN-2025-10053 | BRW-0033 | 7 of 16 instalments | cash collected KES 50358 | outstanding KES 64746
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 33,@a0 + 19,7194,'2026-03-25',1,15,0),
  (@b0 + 33,@a0 + 19,7194,'2026-04-26',2,14,0),
  (@b0 + 33,@a0 + 19,7194,'2026-05-23',3,13,0),
  (@b0 + 33,@a0 + 19,7194,'2026-06-26',4,12,0),
  (@b0 + 33,@a0 + 19,7194,'2026-07-26',5,11,0),
  (@b0 + 33,@a0 + 19,7194,'2026-08-25',6,10,0),
  (@b0 + 33,@a0 + 19,7194,'2026-09-24',7,9,0);

-- LN-2024-10001 | BRW-0001 | 9 of 12 instalments | cash collected KES 72729 | outstanding KES 24239
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 1,@a0 + 20,8081,'2026-01-24',1,11,0),
  (@b0 + 1,@a0 + 20,8081,'2026-02-26',2,10,0),
  (@b0 + 1,@a0 + 20,8081,'2026-03-28',3,9,0),
  (@b0 + 1,@a0 + 20,8081,'2026-04-27',4,8,0),
  (@b0 + 1,@a0 + 20,8081,'2026-05-28',5,7,0),
  (@b0 + 1,@a0 + 20,8081,'2026-06-27',6,6,0),
  (@b0 + 1,@a0 + 20,8081,'2026-07-26',7,5,0),
  (@b0 + 1,@a0 + 20,8081,'2026-08-22',8,4,0),
  (@b0 + 1,@a0 + 20,8081,'2026-09-23',9,3,0);

-- LN-2026-10045 | BRW-0028 | 14 of 24 instalments | cash collected KES 76538 | outstanding KES 54664
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 28,@a0 + 21,5467,'2025-08-08',1,23,0),
  (@b0 + 28,@a0 + 21,5467,'2025-09-06',2,22,0),
  (@b0 + 28,@a0 + 21,5467,'2025-10-06',3,21,0),
  (@b0 + 28,@a0 + 21,5467,'2025-11-06',4,20,0),
  (@b0 + 28,@a0 + 21,5467,'2025-12-07',5,19,0),
  (@b0 + 28,@a0 + 21,5467,'2026-01-04',6,18,0),
  (@b0 + 28,@a0 + 21,5467,'2026-02-02',7,17,0),
  (@b0 + 28,@a0 + 21,5467,'2026-03-03',8,16,0),
  (@b0 + 28,@a0 + 21,5467,'2026-04-04',9,15,0),
  (@b0 + 28,@a0 + 21,5467,'2026-05-05',10,14,0),
  (@b0 + 28,@a0 + 21,5467,'2026-06-05',11,13,0),
  (@b0 + 28,@a0 + 21,5467,'2026-07-03',12,12,0),
  (@b0 + 28,@a0 + 21,5467,'2026-08-04',13,11,0),
  (@b0 + 28,@a0 + 21,5467,'2026-08-30',14,10,0);

-- LN-2024-10013 | BRW-0007 | 12 of 12 instalments | cash collected KES 40653 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 7,@a0 + 23,3388,'2024-03-27',1,11,0),
  (@b0 + 7,@a0 + 23,3388,'2024-04-22',2,10,0),
  (@b0 + 7,@a0 + 23,3388,'2024-05-24',3,9,0),
  (@b0 + 7,@a0 + 23,3388,'2024-06-24',4,8,0),
  (@b0 + 7,@a0 + 23,3388,'2024-07-21',5,7,0),
  (@b0 + 7,@a0 + 23,3388,'2024-08-24',6,6,0),
  (@b0 + 7,@a0 + 23,3388,'2024-09-20',7,5,0),
  (@b0 + 7,@a0 + 23,3388,'2024-10-22',8,4,0),
  (@b0 + 7,@a0 + 23,3388,'2024-11-22',9,3,0),
  (@b0 + 7,@a0 + 23,3388,'2024-12-20',10,2,0),
  (@b0 + 7,@a0 + 23,3388,'2025-01-17',11,1,0),
  (@b0 + 7,@a0 + 23,3385,'2025-02-16',12,0,0);

-- LN-2025-10059 | BRW-0036 | 23 of 48 instalments | cash collected KES 9798 | outstanding KES 10662
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 36,@a0 + 24,426,'2024-11-10',1,47,0),
  (@b0 + 36,@a0 + 24,426,'2024-12-10',2,46,0),
  (@b0 + 36,@a0 + 24,426,'2025-01-11',3,45,0),
  (@b0 + 36,@a0 + 24,426,'2025-02-11',4,44,0),
  (@b0 + 36,@a0 + 24,426,'2025-03-14',5,43,0),
  (@b0 + 36,@a0 + 24,426,'2025-04-10',6,42,0),
  (@b0 + 36,@a0 + 24,426,'2025-05-13',7,41,0),
  (@b0 + 36,@a0 + 24,426,'2025-06-11',8,40,0),
  (@b0 + 36,@a0 + 24,426,'2025-07-12',9,39,0),
  (@b0 + 36,@a0 + 24,426,'2025-08-11',10,38,0),
  (@b0 + 36,@a0 + 24,426,'2025-09-06',11,37,0),
  (@b0 + 36,@a0 + 24,426,'2025-10-06',12,36,0),
  (@b0 + 36,@a0 + 24,426,'2025-11-09',13,35,0),
  (@b0 + 36,@a0 + 24,426,'2025-12-06',14,34,0),
  (@b0 + 36,@a0 + 24,426,'2026-01-05',15,33,0),
  (@b0 + 36,@a0 + 24,426,'2026-02-07',16,32,0),
  (@b0 + 36,@a0 + 24,426,'2026-03-06',17,31,0),
  (@b0 + 36,@a0 + 24,426,'2026-04-05',18,30,0),
  (@b0 + 36,@a0 + 24,426,'2026-05-08',19,29,0),
  (@b0 + 36,@a0 + 24,426,'2026-06-03',20,28,0),
  (@b0 + 36,@a0 + 24,426,'2026-07-03',21,27,0),
  (@b0 + 36,@a0 + 24,426,'2026-08-02',22,26,0),
  (@b0 + 36,@a0 + 24,426,'2026-09-04',23,25,0);

-- LN-2026-10021 | BRW-0014 | 12 of 12 instalments | cash collected KES 126548 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 14,@a0 + 25,10546,'2025-08-15',1,11,0),
  (@b0 + 14,@a0 + 25,10546,'2025-09-11',2,10,0),
  (@b0 + 14,@a0 + 25,10546,'2025-10-10',3,9,0),
  (@b0 + 14,@a0 + 25,10546,'2025-11-09',4,8,0),
  (@b0 + 14,@a0 + 25,10546,'2025-12-09',5,7,0),
  (@b0 + 14,@a0 + 25,10546,'2026-01-10',6,6,0),
  (@b0 + 14,@a0 + 25,10546,'2026-02-09',7,5,0),
  (@b0 + 14,@a0 + 25,10546,'2026-03-09',8,4,0),
  (@b0 + 14,@a0 + 25,10546,'2026-04-12',9,3,0),
  (@b0 + 14,@a0 + 25,10546,'2026-05-10',10,2,0),
  (@b0 + 14,@a0 + 25,10546,'2026-06-11',11,1,0),
  (@b0 + 14,@a0 + 25,10542,'2026-07-07',12,0,0);

-- LN-2026-10063 | BRW-0038 | 20 of 24 instalments | cash collected KES 18920 | outstanding KES 0 | KES 3785 of this still owed here, cleared by collateral KES 3785
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 38,@a0 + 26,946,'2025-01-14',1,23,0),
  (@b0 + 38,@a0 + 26,946,'2025-02-16',2,22,0),
  (@b0 + 38,@a0 + 26,946,'2025-03-17',3,21,0),
  (@b0 + 38,@a0 + 26,946,'2025-04-16',4,20,0),
  (@b0 + 38,@a0 + 26,946,'2025-05-14',5,19,0),
  (@b0 + 38,@a0 + 26,946,'2025-06-13',6,18,0),
  (@b0 + 38,@a0 + 26,946,'2025-07-14',7,17,0),
  (@b0 + 38,@a0 + 26,946,'2025-08-14',8,16,0),
  (@b0 + 38,@a0 + 26,946,'2025-09-15',9,15,0),
  (@b0 + 38,@a0 + 26,946,'2025-10-13',10,14,0),
  (@b0 + 38,@a0 + 26,946,'2025-11-14',11,13,0),
  (@b0 + 38,@a0 + 26,946,'2025-12-14',12,12,0),
  (@b0 + 38,@a0 + 26,946,'2026-01-10',13,11,0),
  (@b0 + 38,@a0 + 26,946,'2026-02-11',14,10,0),
  (@b0 + 38,@a0 + 26,946,'2026-03-14',15,9,0),
  (@b0 + 38,@a0 + 26,946,'2026-04-13',16,8,0),
  (@b0 + 38,@a0 + 26,946,'2026-05-13',17,7,0),
  (@b0 + 38,@a0 + 26,946,'2026-06-08',18,6,0),
  (@b0 + 38,@a0 + 26,946,'2026-07-11',19,5,0),
  (@b0 + 38,@a0 + 26,946,'2026-08-11',20,4,0);

-- LN-2026-10036 | BRW-0026 | 17 of 24 instalments | cash collected KES 87571 | outstanding KES 0 | KES 38895 of this still owed here, cleared by collateral KES 38895
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 26,@a0 + 28,5269,'2025-04-30',1,23,0),
  (@b0 + 26,@a0 + 28,5269,'2025-05-30',2,22,0),
  (@b0 + 26,@a0 + 28,5269,'2025-07-01',3,21,0),
  (@b0 + 26,@a0 + 28,5269,'2025-07-31',4,20,0),
  (@b0 + 26,@a0 + 28,5269,'2025-08-29',5,19,0),
  (@b0 + 26,@a0 + 28,5269,'2025-09-29',6,18,0),
  (@b0 + 26,@a0 + 28,5269,'2025-10-29',7,17,0),
  (@b0 + 26,@a0 + 28,5269,'2025-11-26',8,16,0),
  (@b0 + 26,@a0 + 28,5269,'2025-12-25',9,15,0),
  (@b0 + 26,@a0 + 28,5269,'2026-01-25',10,14,0),
  (@b0 + 26,@a0 + 28,5269,'2026-02-26',11,13,0),
  (@b0 + 26,@a0 + 28,5269,'2026-03-25',12,12,0),
  (@b0 + 26,@a0 + 28,5269,'2026-04-25',13,11,0),
  (@b0 + 26,@a0 + 28,5269,'2026-05-26',14,10,0),
  (@b0 + 26,@a0 + 28,5269,'2026-06-25',15,9,0),
  (@b0 + 26,@a0 + 28,5269,'2026-07-24',16,8,0),
  (@b0 + 26,@a0 + 28,3267,'2026-08-22',17,7,0);

-- LN-2024-10016 | BRW-0010 | 22 of 48 instalments | cash collected KES 36916 | outstanding KES 43604
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 10,@a0 + 29,1678,'2024-12-30',1,47,0),
  (@b0 + 10,@a0 + 29,1678,'2025-01-29',2,46,0),
  (@b0 + 10,@a0 + 29,1678,'2025-02-28',3,45,0),
  (@b0 + 10,@a0 + 29,1678,'2025-03-30',4,44,0),
  (@b0 + 10,@a0 + 29,1678,'2025-04-29',5,43,0),
  (@b0 + 10,@a0 + 29,1678,'2025-05-28',6,42,0),
  (@b0 + 10,@a0 + 29,1678,'2025-06-27',7,41,0),
  (@b0 + 10,@a0 + 29,1678,'2025-07-28',8,40,0),
  (@b0 + 10,@a0 + 29,1678,'2025-08-25',9,39,0),
  (@b0 + 10,@a0 + 29,1678,'2025-09-24',10,38,0),
  (@b0 + 10,@a0 + 29,1678,'2025-10-28',11,37,0),
  (@b0 + 10,@a0 + 29,1678,'2025-11-27',12,36,0),
  (@b0 + 10,@a0 + 29,1678,'2025-12-23',13,35,0),
  (@b0 + 10,@a0 + 29,1678,'2026-01-22',14,34,0),
  (@b0 + 10,@a0 + 29,1678,'2026-02-23',15,33,0),
  (@b0 + 10,@a0 + 29,1678,'2026-03-23',16,32,0),
  (@b0 + 10,@a0 + 29,1678,'2026-04-24',17,31,0),
  (@b0 + 10,@a0 + 29,1678,'2026-05-26',18,30,0),
  (@b0 + 10,@a0 + 29,1678,'2026-06-23',19,29,0),
  (@b0 + 10,@a0 + 29,1678,'2026-07-23',20,28,0),
  (@b0 + 10,@a0 + 29,1678,'2026-08-21',21,27,0),
  (@b0 + 10,@a0 + 29,1678,'2026-09-21',22,26,0);

-- LN-2024-10034 | BRW-0024 | 9 of 12 instalments | cash collected KES 22032 | outstanding KES 7348
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 24,@a0 + 34,2448,'2026-01-05',1,11,0),
  (@b0 + 24,@a0 + 34,2448,'2026-02-06',2,10,0),
  (@b0 + 24,@a0 + 34,2448,'2026-03-06',3,9,0),
  (@b0 + 24,@a0 + 34,2448,'2026-04-05',4,8,0),
  (@b0 + 24,@a0 + 34,2448,'2026-05-06',5,7,0),
  (@b0 + 24,@a0 + 34,2448,'2026-06-03',6,6,0),
  (@b0 + 24,@a0 + 34,2448,'2026-07-03',7,5,0),
  (@b0 + 24,@a0 + 34,2448,'2026-08-04',8,4,0),
  (@b0 + 24,@a0 + 34,2448,'2026-09-02',9,3,0);

-- LN-2024-10037 | BRW-0026 | 4 of 4 instalments | cash collected KES 12938 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 26,@a0 + 36,3235,'2026-05-05',1,3,0),
  (@b0 + 26,@a0 + 36,3235,'2026-06-02',2,2,0),
  (@b0 + 26,@a0 + 36,3235,'2026-07-02',3,1,0),
  (@b0 + 26,@a0 + 36,3233,'2026-08-01',4,0,0);

-- LN-2025-10026 | BRW-0018 | 12 of 12 instalments | cash collected KES 69963 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 18,@a0 + 37,5830,'2024-02-23',1,11,0),
  (@b0 + 18,@a0 + 37,5830,'2024-03-24',2,10,0),
  (@b0 + 18,@a0 + 37,5830,'2024-04-25',3,9,0),
  (@b0 + 18,@a0 + 37,5830,'2024-05-25',4,8,0),
  (@b0 + 18,@a0 + 37,5830,'2024-06-23',5,7,0),
  (@b0 + 18,@a0 + 37,5830,'2024-07-24',6,6,0),
  (@b0 + 18,@a0 + 37,5830,'2024-08-23',7,5,0),
  (@b0 + 18,@a0 + 37,5830,'2024-09-18',8,4,0),
  (@b0 + 18,@a0 + 37,5830,'2024-10-20',9,3,0),
  (@b0 + 18,@a0 + 37,5830,'2024-11-21',10,2,0),
  (@b0 + 18,@a0 + 37,5830,'2024-12-18',11,1,0),
  (@b0 + 18,@a0 + 37,5833,'2025-01-16',12,0,0);

-- LN-2025-10050 | BRW-0031 | 3 of 8 instalments | cash collected KES 3876 | outstanding KES 0 | KES 6459 of this still owed here, cleared by collateral KES 6459
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 31,@a0 + 38,1292,'2026-06-07',1,7,0),
  (@b0 + 31,@a0 + 38,1292,'2026-07-10',2,6,0),
  (@b0 + 31,@a0 + 38,1292,'2026-08-07',3,5,0);

-- LN-2026-10006 | BRW-0003 | 15 of 24 instalments | cash collected KES 29985 | outstanding KES 17985
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 3,@a0 + 39,1999,'2025-07-25',1,23,0),
  (@b0 + 3,@a0 + 39,1999,'2025-08-23',2,22,0),
  (@b0 + 3,@a0 + 39,1999,'2025-09-24',3,21,0),
  (@b0 + 3,@a0 + 39,1999,'2025-10-20',4,20,0),
  (@b0 + 3,@a0 + 39,1999,'2025-11-23',5,19,0),
  (@b0 + 3,@a0 + 39,1999,'2025-12-23',6,18,0),
  (@b0 + 3,@a0 + 39,1999,'2026-01-22',7,17,0),
  (@b0 + 3,@a0 + 39,1999,'2026-02-21',8,16,0),
  (@b0 + 3,@a0 + 39,1999,'2026-03-23',9,15,0),
  (@b0 + 3,@a0 + 39,1999,'2026-04-22',10,14,0),
  (@b0 + 3,@a0 + 39,1999,'2026-05-19',11,13,0),
  (@b0 + 3,@a0 + 39,1999,'2026-06-20',12,12,0),
  (@b0 + 3,@a0 + 39,1999,'2026-07-18',13,11,0),
  (@b0 + 3,@a0 + 39,1999,'2026-08-19',14,10,0),
  (@b0 + 3,@a0 + 39,1999,'2026-09-15',15,9,0);

-- LN-2025-10032 | BRW-0022 | 19 of 24 instalments | cash collected KES 83847 | outstanding KES 22073
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 22,@a0 + 40,4413,'2025-03-11',1,23,0),
  (@b0 + 22,@a0 + 40,4413,'2025-04-10',2,22,0),
  (@b0 + 22,@a0 + 40,4413,'2025-05-13',3,21,0),
  (@b0 + 22,@a0 + 40,4413,'2025-06-09',4,20,0),
  (@b0 + 22,@a0 + 40,4413,'2025-07-08',5,19,0),
  (@b0 + 22,@a0 + 40,4413,'2025-08-07',6,18,0),
  (@b0 + 22,@a0 + 40,4413,'2025-09-07',7,17,0),
  (@b0 + 22,@a0 + 40,4413,'2025-10-07',8,16,0),
  (@b0 + 22,@a0 + 40,4413,'2025-11-05',9,15,0),
  (@b0 + 22,@a0 + 40,4413,'2025-12-06',10,14,0),
  (@b0 + 22,@a0 + 40,4413,'2026-01-08',11,13,0),
  (@b0 + 22,@a0 + 40,4413,'2026-02-03',12,12,0),
  (@b0 + 22,@a0 + 40,4413,'2026-03-07',13,11,0),
  (@b0 + 22,@a0 + 40,4413,'2026-04-08',14,10,0),
  (@b0 + 22,@a0 + 40,4413,'2026-05-08',15,9,0),
  (@b0 + 22,@a0 + 40,4413,'2026-06-04',16,8,0),
  (@b0 + 22,@a0 + 40,4413,'2026-07-05',17,7,0),
  (@b0 + 22,@a0 + 40,4413,'2026-08-04',18,6,0),
  (@b0 + 22,@a0 + 40,4413,'2026-09-02',19,5,0);

-- LN-2026-10018 | BRW-0011 | 7 of 8 instalments | cash collected KES 56441 | outstanding KES 8059
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 11,@a0 + 41,8063,'2026-03-15',1,7,0),
  (@b0 + 11,@a0 + 41,8063,'2026-04-15',2,6,0),
  (@b0 + 11,@a0 + 41,8063,'2026-05-15',3,5,0),
  (@b0 + 11,@a0 + 41,8063,'2026-06-15',4,4,0),
  (@b0 + 11,@a0 + 41,8063,'2026-07-12',5,3,0),
  (@b0 + 11,@a0 + 41,8063,'2026-08-11',6,2,0),
  (@b0 + 11,@a0 + 41,8063,'2026-09-13',7,1,0);

-- LN-2024-10067 | BRW-0039 | 8 of 8 instalments | cash collected KES 134460 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 39,@a0 + 44,16808,'2024-07-12',1,7,0),
  (@b0 + 39,@a0 + 44,16808,'2024-08-10',2,6,0),
  (@b0 + 39,@a0 + 44,16808,'2024-09-10',3,5,0),
  (@b0 + 39,@a0 + 44,16808,'2024-10-12',4,4,0),
  (@b0 + 39,@a0 + 44,16808,'2024-11-10',5,3,0),
  (@b0 + 39,@a0 + 44,16808,'2024-12-10',6,2,0),
  (@b0 + 39,@a0 + 44,16808,'2025-01-09',7,1,0),
  (@b0 + 39,@a0 + 44,16804,'2025-02-06',8,0,0);

-- LN-2024-10049 | BRW-0030 | 18 of 24 instalments | cash collected KES 13704 | outstanding KES 4916 | penalty KES 2350
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 30,@a0 + 47,776,'2025-03-19',1,23,0),
  (@b0 + 30,@a0 + 47,776,'2025-04-18',2,22,0),
  (@b0 + 30,@a0 + 47,776,'2025-05-18',3,21,0),
  (@b0 + 30,@a0 + 47,776,'2025-06-18',4,20,0),
  (@b0 + 30,@a0 + 47,776,'2025-07-19',5,19,0),
  (@b0 + 30,@a0 + 47,776,'2025-08-16',6,18,0),
  (@b0 + 30,@a0 + 47,776,'2025-09-17',7,17,0),
  (@b0 + 30,@a0 + 47,776,'2025-10-16',8,16,0),
  (@b0 + 30,@a0 + 47,776,'2025-11-18',9,15,0),
  (@b0 + 30,@a0 + 47,776,'2025-12-16',10,14,0),
  (@b0 + 30,@a0 + 47,776,'2026-01-15',11,13,0),
  (@b0 + 30,@a0 + 47,776,'2026-02-12',12,12,0),
  (@b0 + 30,@a0 + 47,776,'2026-03-15',13,11,0),
  (@b0 + 30,@a0 + 47,776,'2026-04-15',14,10,0),
  (@b0 + 30,@a0 + 47,776,'2026-05-13',15,9,0),
  (@b0 + 30,@a0 + 47,776,'2026-06-16',16,8,0),
  (@b0 + 30,@a0 + 47,776,'2026-07-15',17,7,0),
  (@b0 + 30,@a0 + 47,512,'2026-08-13',18,6,2350);

-- LN-2026-10060 | BRW-0037 | 16 of 16 instalments | cash collected KES 23458 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 37,@a0 + 48,1466,'2024-06-22',1,15,0),
  (@b0 + 37,@a0 + 48,1466,'2024-07-20',2,14,0),
  (@b0 + 37,@a0 + 48,1466,'2024-08-20',3,13,0),
  (@b0 + 37,@a0 + 48,1466,'2024-09-21',4,12,0),
  (@b0 + 37,@a0 + 48,1466,'2024-10-19',5,11,0),
  (@b0 + 37,@a0 + 48,1466,'2024-11-18',6,10,0),
  (@b0 + 37,@a0 + 48,1466,'2024-12-19',7,9,0),
  (@b0 + 37,@a0 + 48,1466,'2025-01-20',8,8,0),
  (@b0 + 37,@a0 + 48,1466,'2025-02-17',9,7,0),
  (@b0 + 37,@a0 + 48,1466,'2025-03-17',10,6,0),
  (@b0 + 37,@a0 + 48,1466,'2025-04-16',11,5,0),
  (@b0 + 37,@a0 + 48,1466,'2025-05-16',12,4,0),
  (@b0 + 37,@a0 + 48,1466,'2025-06-16',13,3,0),
  (@b0 + 37,@a0 + 48,1466,'2025-07-16',14,2,0),
  (@b0 + 37,@a0 + 48,1466,'2025-08-14',15,1,0),
  (@b0 + 37,@a0 + 48,1468,'2025-09-13',16,0,0);

-- LN-2024-10058 | BRW-0036 | 3 of 8 instalments | cash collected KES 35079 | outstanding KES 0 | KES 58461 of this still owed here, cleared by collateral KES 58461
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 36,@a0 + 49,11693,'2026-06-17',1,7,0),
  (@b0 + 36,@a0 + 49,11693,'2026-07-19',2,6,0),
  (@b0 + 36,@a0 + 49,11693,'2026-08-14',3,5,0);

-- LN-2026-10042 | BRW-0027 | 12 of 12 instalments | cash collected KES 37820 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 27,@a0 + 50,3152,'2025-05-16',1,11,0),
  (@b0 + 27,@a0 + 50,3152,'2025-06-12',2,10,0),
  (@b0 + 27,@a0 + 50,3152,'2025-07-13',3,9,0),
  (@b0 + 27,@a0 + 50,3152,'2025-08-13',4,8,0),
  (@b0 + 27,@a0 + 50,3152,'2025-09-11',5,7,0),
  (@b0 + 27,@a0 + 50,3152,'2025-10-10',6,6,0),
  (@b0 + 27,@a0 + 50,3152,'2025-11-11',7,5,0),
  (@b0 + 27,@a0 + 50,3152,'2025-12-10',8,4,0),
  (@b0 + 27,@a0 + 50,3152,'2026-01-09',9,3,0),
  (@b0 + 27,@a0 + 50,3152,'2026-02-09',10,2,0),
  (@b0 + 27,@a0 + 50,3152,'2026-03-09',11,1,0),
  (@b0 + 27,@a0 + 50,3148,'2026-04-08',12,0,0);

-- LN-2024-10031 | BRW-0021 | 12 of 16 instalments | cash collected KES 27216 | outstanding KES 9072 | penalty KES 800
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 21,@a0 + 51,2268,'2025-09-25',1,15,0),
  (@b0 + 21,@a0 + 51,2268,'2025-10-24',2,14,0),
  (@b0 + 21,@a0 + 51,2268,'2025-11-25',3,13,0),
  (@b0 + 21,@a0 + 51,2268,'2025-12-24',4,12,0),
  (@b0 + 21,@a0 + 51,2268,'2026-01-26',5,11,0),
  (@b0 + 21,@a0 + 51,2268,'2026-02-23',6,10,0),
  (@b0 + 21,@a0 + 51,2268,'2026-03-27',7,9,0),
  (@b0 + 21,@a0 + 51,2268,'2026-04-25',8,8,0),
  (@b0 + 21,@a0 + 51,2268,'2026-05-26',9,7,0),
  (@b0 + 21,@a0 + 51,2268,'2026-06-22',10,6,0),
  (@b0 + 21,@a0 + 51,2268,'2026-07-24',11,5,0),
  (@b0 + 21,@a0 + 51,2268,'2026-08-20',12,4,800);

-- LN-2025-10014 | BRW-0008 | 12 of 24 instalments | cash collected KES 73044 | outstanding KES 73036
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 8,@a0 + 53,6087,'2025-10-24',1,23,0),
  (@b0 + 8,@a0 + 53,6087,'2025-11-20',2,22,0),
  (@b0 + 8,@a0 + 53,6087,'2025-12-20',3,21,0),
  (@b0 + 8,@a0 + 53,6087,'2026-01-22',4,20,0),
  (@b0 + 8,@a0 + 53,6087,'2026-02-20',5,19,0),
  (@b0 + 8,@a0 + 53,6087,'2026-03-24',6,18,0),
  (@b0 + 8,@a0 + 53,6087,'2026-04-19',7,17,0),
  (@b0 + 8,@a0 + 53,6087,'2026-05-20',8,16,0),
  (@b0 + 8,@a0 + 53,6087,'2026-06-21',9,15,0),
  (@b0 + 8,@a0 + 53,6087,'2026-07-22',10,14,0),
  (@b0 + 8,@a0 + 53,6087,'2026-08-19',11,13,0),
  (@b0 + 8,@a0 + 53,6087,'2026-09-17',12,12,0);

-- LN-2025-10017 | BRW-0011 | 6 of 12 instalments | cash collected KES 37692 | outstanding KES 37691 | penalty KES 950
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 11,@a0 + 54,6282,'2026-03-26',1,11,0),
  (@b0 + 11,@a0 + 54,6282,'2026-04-29',2,10,0),
  (@b0 + 11,@a0 + 54,6282,'2026-05-26',3,9,0),
  (@b0 + 11,@a0 + 54,6282,'2026-06-27',4,8,0),
  (@b0 + 11,@a0 + 54,6282,'2026-07-28',5,7,0),
  (@b0 + 11,@a0 + 54,6282,'2026-08-26',6,6,950);

-- LN-2025-10011 | BRW-0005 | 10 of 16 instalments | cash collected KES 43070 | outstanding KES 25834
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 5,@a0 + 55,4307,'2025-12-15',1,15,0),
  (@b0 + 5,@a0 + 55,4307,'2026-01-14',2,14,0),
  (@b0 + 5,@a0 + 55,4307,'2026-02-12',3,13,0),
  (@b0 + 5,@a0 + 55,4307,'2026-03-12',4,12,0),
  (@b0 + 5,@a0 + 55,4307,'2026-04-10',5,11,0),
  (@b0 + 5,@a0 + 55,4307,'2026-05-14',6,10,0),
  (@b0 + 5,@a0 + 55,4307,'2026-06-10',7,9,0),
  (@b0 + 5,@a0 + 55,4307,'2026-07-13',8,8,0),
  (@b0 + 5,@a0 + 55,4307,'2026-08-08',9,7,0),
  (@b0 + 5,@a0 + 55,4307,'2026-09-09',10,6,0);

-- LN-2024-10025 | BRW-0017 | 1 of 8 instalments | cash collected KES 8745 | outstanding KES 61215
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 17,@a0 + 56,8745,'2026-09-02',1,7,0);

-- LN-2024-10019 | BRW-0012 | 24 of 24 instalments | cash collected KES 140082 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 12,@a0 + 57,5837,'2024-04-25',1,23,0),
  (@b0 + 12,@a0 + 57,5837,'2024-05-26',2,22,0),
  (@b0 + 12,@a0 + 57,5837,'2024-06-26',3,21,0),
  (@b0 + 12,@a0 + 57,5837,'2024-07-26',4,20,0),
  (@b0 + 12,@a0 + 57,5837,'2024-08-23',5,19,0),
  (@b0 + 12,@a0 + 57,5837,'2024-09-21',6,18,0),
  (@b0 + 12,@a0 + 57,5837,'2024-10-24',7,17,0),
  (@b0 + 12,@a0 + 57,5837,'2024-11-19',8,16,0),
  (@b0 + 12,@a0 + 57,5837,'2024-12-22',9,15,0),
  (@b0 + 12,@a0 + 57,5837,'2025-01-20',10,14,0),
  (@b0 + 12,@a0 + 57,5837,'2025-02-17',11,13,0),
  (@b0 + 12,@a0 + 57,5837,'2025-03-22',12,12,0),
  (@b0 + 12,@a0 + 57,5837,'2025-04-22',13,11,0),
  (@b0 + 12,@a0 + 57,5837,'2025-05-20',14,10,0),
  (@b0 + 12,@a0 + 57,5837,'2025-06-21',15,9,0),
  (@b0 + 12,@a0 + 57,5837,'2025-07-18',16,8,0),
  (@b0 + 12,@a0 + 57,5837,'2025-08-17',17,7,0),
  (@b0 + 12,@a0 + 57,5837,'2025-09-17',18,6,0),
  (@b0 + 12,@a0 + 57,5837,'2025-10-18',19,5,0),
  (@b0 + 12,@a0 + 57,5837,'2025-11-18',20,4,0),
  (@b0 + 12,@a0 + 57,5837,'2025-12-18',21,3,0),
  (@b0 + 12,@a0 + 57,5837,'2026-01-17',22,2,0),
  (@b0 + 12,@a0 + 57,5837,'2026-02-13',23,1,0),
  (@b0 + 12,@a0 + 57,5831,'2026-03-14',24,0,0);

-- LN-2024-10010 | BRW-0005 | 3 of 8 instalments | cash collected KES 42414 | outstanding KES 70686
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 5,@a0 + 59,14138,'2026-07-07',1,7,0),
  (@b0 + 5,@a0 + 59,14138,'2026-08-08',2,6,0),
  (@b0 + 5,@a0 + 59,14138,'2026-09-07',3,5,0);

-- LN-2025-10020 | BRW-0013 | 7 of 8 instalments | cash collected KES 68488 | outstanding KES 0 | KES 14530 of this still owed here, cleared by collateral KES 14530
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 13,@a0 + 60,10377,'2026-02-16',1,7,0),
  (@b0 + 13,@a0 + 60,10377,'2026-03-20',2,6,0),
  (@b0 + 13,@a0 + 60,10377,'2026-04-18',3,5,0),
  (@b0 + 13,@a0 + 60,10377,'2026-05-16',4,4,0),
  (@b0 + 13,@a0 + 60,10377,'2026-06-17',5,3,0),
  (@b0 + 13,@a0 + 60,10377,'2026-07-15',6,2,0),
  (@b0 + 13,@a0 + 60,6226,'2026-08-15',7,1,0);

-- LN-2026-10051 | BRW-0032 | 6 of 12 instalments | cash collected KES 7794 | outstanding KES 7794
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 32,@a0 + 61,1299,'2026-04-21',1,11,0),
  (@b0 + 32,@a0 + 61,1299,'2026-05-18',2,10,0),
  (@b0 + 32,@a0 + 61,1299,'2026-06-21',3,9,0),
  (@b0 + 32,@a0 + 61,1299,'2026-07-18',4,8,0),
  (@b0 + 32,@a0 + 61,1299,'2026-08-20',5,7,0),
  (@b0 + 32,@a0 + 61,1299,'2026-09-18',6,6,0);

-- LN-2025-10023 | BRW-0015 | 4 of 4 instalments | cash collected KES 70208 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 15,@a0 + 62,17552,'2025-04-07',1,3,0),
  (@b0 + 15,@a0 + 62,17552,'2025-05-08',2,2,0),
  (@b0 + 15,@a0 + 62,17552,'2025-06-03',3,1,0),
  (@b0 + 15,@a0 + 62,17552,'2025-07-03',4,0,0);

-- LN-2024-10046 | BRW-0028 | 21 of 48 instalments | cash collected KES 79594 | outstanding KES 104450
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 28,@a0 + 63,3834,'2024-12-30',1,47,0),
  (@b0 + 28,@a0 + 63,3834,'2025-01-30',2,46,0),
  (@b0 + 28,@a0 + 63,3834,'2025-03-02',3,45,0),
  (@b0 + 28,@a0 + 63,3834,'2025-04-01',4,44,0),
  (@b0 + 28,@a0 + 63,3834,'2025-04-27',5,43,0),
  (@b0 + 28,@a0 + 63,3834,'2025-05-28',6,42,0),
  (@b0 + 28,@a0 + 63,3834,'2025-06-28',7,41,0),
  (@b0 + 28,@a0 + 63,3834,'2025-07-28',8,40,0),
  (@b0 + 28,@a0 + 63,3834,'2025-08-26',9,39,0),
  (@b0 + 28,@a0 + 63,3834,'2025-09-28',10,38,0),
  (@b0 + 28,@a0 + 63,3834,'2025-10-28',11,37,0),
  (@b0 + 28,@a0 + 63,3834,'2025-11-23',12,36,0),
  (@b0 + 28,@a0 + 63,3834,'2025-12-24',13,35,0),
  (@b0 + 28,@a0 + 63,3834,'2026-01-23',14,34,0),
  (@b0 + 28,@a0 + 63,3834,'2026-02-25',15,33,0),
  (@b0 + 28,@a0 + 63,3834,'2026-03-24',16,32,0),
  (@b0 + 28,@a0 + 63,3834,'2026-04-22',17,31,0),
  (@b0 + 28,@a0 + 63,3834,'2026-05-22',18,30,0),
  (@b0 + 28,@a0 + 63,3834,'2026-06-24',19,29,0),
  (@b0 + 28,@a0 + 63,3834,'2026-07-22',20,28,0),
  (@b0 + 28,@a0 + 63,2914,'2026-08-22',21,27,0);

-- LN-2025-10005 | BRW-0003 | 3 of 8 instalments | cash collected KES 44842 | outstanding KES 0 | KES 82818 of this still owed here, cleared by collateral KES 82818
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 3,@a0 + 64,15958,'2026-06-24',1,7,0),
  (@b0 + 3,@a0 + 64,15958,'2026-07-21',2,6,0),
  (@b0 + 3,@a0 + 64,12926,'2026-08-23',3,5,0);

-- LN-2025-10065 | BRW-0039 | 12 of 12 instalments | cash collected KES 84761 | outstanding KES 0
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 39,@a0 + 66,7063,'2025-01-04',1,11,0),
  (@b0 + 39,@a0 + 66,7063,'2025-02-06',2,10,0),
  (@b0 + 39,@a0 + 66,7063,'2025-03-05',3,9,0),
  (@b0 + 39,@a0 + 66,7063,'2025-04-07',4,8,0),
  (@b0 + 39,@a0 + 66,7063,'2025-05-07',5,7,0),
  (@b0 + 39,@a0 + 66,7063,'2025-06-03',6,6,0),
  (@b0 + 39,@a0 + 66,7063,'2025-07-05',7,5,0),
  (@b0 + 39,@a0 + 66,7063,'2025-08-03',8,4,0),
  (@b0 + 39,@a0 + 66,7063,'2025-09-03',9,3,0),
  (@b0 + 39,@a0 + 66,7063,'2025-10-02',10,2,0),
  (@b0 + 39,@a0 + 66,7063,'2025-11-02',11,1,0),
  (@b0 + 39,@a0 + 66,7068,'2025-11-29',12,0,0);

-- LN-2024-10007 | BRW-0004 | 23 of 24 instalments | cash collected KES 66627 | outstanding KES 4231
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 4,@a0 + 67,2952,'2024-11-01',1,23,0),
  (@b0 + 4,@a0 + 67,2952,'2024-12-02',2,22,0),
  (@b0 + 4,@a0 + 67,2952,'2024-12-31',3,21,0),
  (@b0 + 4,@a0 + 67,2952,'2025-01-31',4,20,0),
  (@b0 + 4,@a0 + 67,2952,'2025-03-01',5,19,0),
  (@b0 + 4,@a0 + 67,2952,'2025-04-03',6,18,0),
  (@b0 + 4,@a0 + 67,2952,'2025-05-01',7,17,0),
  (@b0 + 4,@a0 + 67,2952,'2025-05-30',8,16,0),
  (@b0 + 4,@a0 + 67,2952,'2025-06-29',9,15,0),
  (@b0 + 4,@a0 + 67,2952,'2025-07-30',10,14,0),
  (@b0 + 4,@a0 + 67,2952,'2025-08-29',11,13,0),
  (@b0 + 4,@a0 + 67,2952,'2025-09-28',12,12,0),
  (@b0 + 4,@a0 + 67,2952,'2025-10-28',13,11,0),
  (@b0 + 4,@a0 + 67,2952,'2025-11-28',14,10,0),
  (@b0 + 4,@a0 + 67,2952,'2025-12-27',15,9,0),
  (@b0 + 4,@a0 + 67,2952,'2026-01-27',16,8,0),
  (@b0 + 4,@a0 + 67,2952,'2026-02-25',17,7,0),
  (@b0 + 4,@a0 + 67,2952,'2026-03-28',18,6,0),
  (@b0 + 4,@a0 + 67,2952,'2026-04-25',19,5,0),
  (@b0 + 4,@a0 + 67,2952,'2026-05-29',20,4,0),
  (@b0 + 4,@a0 + 67,2952,'2026-06-24',21,3,0),
  (@b0 + 4,@a0 + 67,2952,'2026-07-25',22,2,0),
  (@b0 + 4,@a0 + 67,1683,'2026-08-24',23,1,0);

-- LN-2026-10024 | BRW-0016 | 12 of 16 instalments | cash collected KES 53341 | outstanding KES 0 | KES 19669 of this still owed here, cleared by collateral KES 19669
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 16,@a0 + 68,4563,'2025-09-19',1,15,0),
  (@b0 + 16,@a0 + 68,4563,'2025-10-20',2,14,0),
  (@b0 + 16,@a0 + 68,4563,'2025-11-17',3,13,0),
  (@b0 + 16,@a0 + 68,4563,'2025-12-17',4,12,0),
  (@b0 + 16,@a0 + 68,4563,'2026-01-18',5,11,0),
  (@b0 + 16,@a0 + 68,4563,'2026-02-15',6,10,0),
  (@b0 + 16,@a0 + 68,4563,'2026-03-16',7,9,0),
  (@b0 + 16,@a0 + 68,4563,'2026-04-18',8,8,0),
  (@b0 + 16,@a0 + 68,4563,'2026-05-18',9,7,0),
  (@b0 + 16,@a0 + 68,4563,'2026-06-13',10,6,0),
  (@b0 + 16,@a0 + 68,4563,'2026-07-13',11,5,0),
  (@b0 + 16,@a0 + 68,3148,'2026-08-16',12,4,0);

-- LN-2025-10035 | BRW-0025 | 5 of 8 instalments | cash collected KES 4784 | outstanding KES 3253
INSERT INTO `tbl_payment`
  (`b_id`,`loan_id`,`pay_amount`,`pay_date`,`current_inst`,`remain_inst`,`fine`) VALUES
  (@b0 + 25,@a0 + 69,1005,'2026-04-20',1,7,0),
  (@b0 + 25,@a0 + 69,1005,'2026-05-20',2,6,0),
  (@b0 + 25,@a0 + 69,1005,'2026-06-19',3,5,0),
  (@b0 + 25,@a0 + 69,1005,'2026-07-19',4,4,0),
  (@b0 + 25,@a0 + 69,764,'2026-08-19',5,3,0);

-- ---------------------------------------------------------------------
-- 4. COLLATERAL REALISATION - tbl_liability (8 records)
--    For these loans the remaining balance was cleared by selling the
--    security, which is what recordsellinfo.php / propertySellDetails()
--    (ManageLoan.php:307-359) does: amount_paid rises to total_loan and
--    amount_remain drops to 0.
--    The settlement is deliberately NOT a tbl_payment row, so for exactly
--    these loans SUM(tbl_payment.pay_amount) < tbl_loan_application
--    .amount_paid. Validation query V10 reports that difference instead of
--    hiding it, and the comment above each loan states the amount.
--    tbl_liability.id has NO auto_increment, so ids come from MAX(id).
--    return_money = price - pay_remaining_loan, per ManageLoan.php:331.
-- ---------------------------------------------------------------------
SET @l0 := (SELECT COALESCE(MAX(id), 0) FROM tbl_liability);

-- LN-2025-10008 | BRW-0005 | balance KES 53057 cleared by collateral sale on 2026-08-06 | realised KES 117057 | surplus KES 64000
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 1,@b0 + 5,@a0 + 10,'LN-2025-10008 - Shop premises','Single-storey masonry shop, 4.2m x 3.6m, corrugated iron roof. Original title deed held by the society as security. Realised on 2026-08-06 at public auction against settlement reference LN-2025-10008-SETTLE. Valuation file and auction receipt held at the branch office.',117057,53057,64000);

-- LN-2026-10063 | BRW-0038 | balance KES 3785 cleared by collateral sale on 2026-08-11 | realised KES 47785 | surplus KES 44000
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 2,@b0 + 38,@a0 + 26,'LN-2026-10063 - Residential plot','Two 50 x 100 ft plots at Kapsabet, survey numbers 1268/3 and 1268/4. Title in the name of the borrower, no caveat registered. Realised on 2026-08-11 at public auction against settlement reference LN-2026-10063-SETTLE. Valuation file and auction receipt held at the branch office.',47785,3785,44000);

-- LN-2026-10036 | BRW-0026 | balance KES 38895 cleared by collateral sale on 2026-08-22 | realised KES 86395 | surplus KES 47500
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 3,@b0 + 26,@a0 + 28,'LN-2026-10036 - Motorcycle','TVS Apache 150cc, registration KDM 447T. Logbook surrendered to the society at disbursement. Realised on 2026-08-22 at public auction against settlement reference LN-2026-10036-SETTLE. Valuation file and auction receipt held at the branch office.',86395,38895,47500);

-- LN-2025-10050 | BRW-0031 | balance KES 6459 cleared by collateral sale on 2026-08-07 | realised KES 79959 | surplus KES 73500
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 4,@b0 + 31,@a0 + 38,'LN-2025-10050 - Farm tractor','Implements and a 2-row tractor planter, valued from the Makutani depot stock list. Realised on 2026-08-07 at public auction against settlement reference LN-2025-10050-SETTLE. Valuation file and auction receipt held at the branch office.',79959,6459,73500);

-- LN-2024-10058 | BRW-0036 | balance KES 58461 cleared by collateral sale on 2026-08-14 | realised KES 110961 | surplus KES 52500
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 5,@b0 + 36,@a0 + 49,'LN-2024-10058 - Salon equipment','Two barber chairs, illuminated mirrors, steriliser and a mobile phone kit seized from the premises. Realised on 2026-08-14 at public auction against settlement reference LN-2024-10058-SETTLE. Valuation file and auction receipt held at the branch office.',110961,58461,52500);

-- LN-2025-10020 | BRW-0013 | balance KES 14530 cleared by collateral sale on 2026-08-15 | realised KES 64530 | surplus KES 50000
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 6,@b0 + 13,@a0 + 60,'LN-2025-10020 - Building materials','About 14 cubic metres of river sand and 3 tonnes of building stone, sold by the loader. Realised on 2026-08-15 at public auction against settlement reference LN-2025-10020-SETTLE. Valuation file and auction receipt held at the branch office.',64530,14530,50000);

-- LN-2025-10005 | BRW-0003 | balance KES 82818 cleared by collateral sale on 2026-08-23 | realised KES 137818 | surplus KES 55000
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 7,@b0 + 3,@a0 + 64,'LN-2025-10005 - Solar system','3kVA solar inverter, four 100Ah batteries and six panels, installed on the premises roof in 2024. Realised on 2026-08-23 at public auction against settlement reference LN-2025-10005-SETTLE. Valuation file and auction receipt held at the branch office.',137818,82818,55000);

-- LN-2026-10024 | BRW-0016 | balance KES 19669 cleared by collateral sale on 2026-08-16 | realised KES 101669 | surplus KES 82000
INSERT INTO `tbl_liability`
  (`id`,`b_id`,`loan_id`,`property_name`,`property_details`,`price`,`pay_remaining_loan`,`return_money`) VALUES
  (@l0 + 8,@b0 + 16,@a0 + 68,'LN-2026-10024 - Shop stock','Sacks of maize flour, cooking oil and sugar, valued at the Bukha market rates on the day of sale. Realised on 2026-08-16 at public auction against settlement reference LN-2026-10024-SETTLE. Valuation file and auction receipt held at the branch office.',101669,19669,82000);

-- ---------------------------------------------------------------------
-- 5. AUTO_INCREMENT CHECK (informational, no DDL)
--    No ALTER TABLE is used anywhere in this file. MySQL and MariaDB
--    advance AUTO_INCREMENT past explicitly inserted primary keys by
--    themselves, so the next borrower or application created through
--    the UI cannot collide with the rows above. Run the SELECT below to
--    confirm the counters sit clear of MAX(id).
-- ---------------------------------------------------------------------
SELECT 'tbl_borrower' AS tbl_name,
       (SELECT AUTO_INCREMENT FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tbl_borrower') AS next_auto_id,
       (SELECT MAX(id) FROM tbl_borrower) AS max_id_current
UNION ALL
SELECT 'tbl_loan_application',
       (SELECT AUTO_INCREMENT FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tbl_loan_application'),
       (SELECT MAX(id) FROM tbl_loan_application)
UNION ALL
SELECT 'tbl_payment',
       (SELECT AUTO_INCREMENT FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tbl_payment'),
       (SELECT MAX(id) FROM tbl_payment);

COMMIT;

-- =====================================================================
-- 6. VALIDATION / DEMONSTRATION QUERIES
--    Run these after COMMIT. V1-V3 count records, V4-V6 reproduce the
--    status mix, V7-V10 aggregate money, V11-V16 slice by year, county
--    and borrower, and V18 is a data-quality gate where EVERY row must
--    report 0. "as of" date for the derived-state logic is 2026-09-26;
--    the running application uses CURDATE() in the same expressions.
-- =====================================================================

-- V1. Record counts added by this script
--     Legacy rows from brac_loan.sql are excluded. On the shipped database
--     those are borrower ids 1-9, application ids 1-10 and the 4 payments
--     belonging to application ids 1-10. If your database already holds
--     different data, adjust the id cut-offs in the three WHERE clauses.
SELECT 'borrowers'          AS entity, COUNT(*) AS rows_added FROM `tbl_borrower`     WHERE id > 9
UNION ALL SELECT 'loan_applications',        COUNT(*) FROM `tbl_loan_application`     WHERE id > 10
UNION ALL SELECT 'repayments',              COUNT(*) FROM `tbl_payment`     WHERE loan_id > 10
UNION ALL SELECT 'collateral_settlements', COUNT(*) FROM `tbl_liability`;

-- V2. Application status mix
SELECT la.status,
       CASE la.status WHEN 0 THEN 'Submitted - awaiting verification'
                       WHEN 1 THEN 'Verified by role 1 (verifier)'
                       WHEN 2 THEN 'Verified by role 2 (branch officer)'
                       ELSE 'Approved and disbursed' END AS status_label,
       COUNT(*) AS applications,
       ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `tbl_loan_application` WHERE id > 10), 1) AS pct,
       SUM(la.expected_loan) AS principal_requested,
       SUM(la.total_loan)    AS total_payable
FROM `tbl_loan_application` la WHERE la.id > 10
GROUP BY la.status ORDER BY la.status;

-- V3. Derived lifecycle state - what the dashboard and reports display
SELECT
  CASE WHEN la.status < 3                                          THEN 'Pending / in verification'
       WHEN la.amount_remain <= 0                                 THEN 'Completed (fully repaid)'
       WHEN la.next_date IS NOT NULL AND la.next_date <= '2026-09-26'   THEN 'Overdue'
       ELSE 'Active (current)' END AS derived_state,
  COUNT(*) AS loans,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `tbl_loan_application` WHERE id > 10), 1) AS pct_of_loans,
  SUM(la.expected_loan) AS principal,
  SUM(la.total_loan)    AS total_payable,
  SUM(la.amount_paid)   AS amount_paid,
  SUM(la.amount_remain) AS outstanding
FROM `tbl_loan_application` la WHERE la.id > 10
GROUP BY derived_state ORDER BY loans DESC;

-- V4. Active (running) loans with outstanding balance and due date
SELECT b.id AS borrower_id, b.name, b.mobile, la.id AS loan_id,
       la.expected_loan, la.loan_percentage, la.installments, la.emi_loan,
       la.amount_paid, la.amount_remain, la.current_inst, la.remain_inst,
       la.next_date, DATEDIFF(la.next_date, '2026-09-26') AS days_to_due
FROM `tbl_loan_application` la JOIN `tbl_borrower` b ON b.id = la.b_id
WHERE la.id > 10 AND la.status = 3
  AND la.amount_remain > 0 AND la.next_date > '2026-09-26'
ORDER BY la.next_date;

-- V5. Overdue loans, same predicate as
--     NotificationManager::getNotificationDueTodayAndOverdue()
SELECT b.name, b.mobile, la.id AS loan_id, la.total_loan, la.amount_paid,
       la.amount_remain, la.next_date,
       DATEDIFF('2026-09-26', la.next_date) AS days_overdue,
       (SELECT IFNULL(SUM(p.fine), 0) FROM `tbl_payment` p WHERE p.loan_id = la.id) AS penalties
FROM `tbl_loan_application` la JOIN `tbl_borrower` b ON b.id = la.b_id
WHERE la.id > 10 AND la.status = 3
  AND la.amount_remain > 0 AND la.next_date IS NOT NULL AND la.next_date <= '2026-09-26'
ORDER BY days_overdue DESC;

-- V6. Completed loans - repayments must reconcile to total_loan
SELECT b.name, la.id AS loan_id, la.expected_loan, la.loan_percentage,
       la.installments, la.total_loan, la.amount_paid, la.amount_remain,
       (SELECT COUNT(*) FROM `tbl_payment` p WHERE p.loan_id = la.id) AS payments_made,
       (SELECT MAX(p.pay_date) FROM `tbl_payment` p WHERE p.loan_id = la.id) AS settled_on,
       CASE WHEN la.amount_paid = la.total_loan THEN 'OK' ELSE 'MISMATCH' END AS reconciled
FROM `tbl_loan_application` la JOIN `tbl_borrower` b ON b.id = la.b_id
WHERE la.id > 10 AND la.status = 3 AND la.amount_paid >= la.total_loan
ORDER BY settled_on;

-- V7. Money totals (new loans only, so legacy rows do not skew the sums)
--     portfolio_principal = disbursed_principal + pending_principal,
--     and disbursed_principal is deliberately below the portfolio total
SELECT
  (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10)                AS portfolio_principal,
  (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10 AND status = 3) AS disbursed_principal,
  (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10 AND status < 3) AS pending_principal,
  (SELECT COALESCE(SUM(total_loan),0)    FROM `tbl_loan_application` WHERE id > 10 AND status = 3) AS disbursed_total_payable,
  (SELECT COALESCE(SUM(amount_paid),0)   FROM `tbl_loan_application` WHERE id > 10 AND status = 3) AS repaid_to_date,
  (SELECT COALESCE(SUM(amount_remain),0) FROM `tbl_loan_application` WHERE id > 10 AND status = 3) AS outstanding_balance,
  (SELECT COALESCE(SUM(pay_amount),0)    FROM `tbl_payment` WHERE loan_id > 10)          AS cash_collected,
  (SELECT COALESCE(SUM(pay_remaining_loan),0) FROM `tbl_liability`)                      AS cleared_by_collateral,
  (SELECT COALESCE(SUM(fine),0)          FROM `tbl_payment` WHERE loan_id > 10)          AS penalties_levied,
  (SELECT COALESCE(SUM(return_money),0)  FROM `tbl_liability`)                           AS surplus_to_borrowers;

-- V8. Loans grouped by year of disbursement, derived from the first
--     repayment because the schema stores no disbursement date
SELECT YEAR(f.d0) AS loan_year, COUNT(*) AS loans,
       SUM(f.expected_loan) AS principal, SUM(f.total_loan) AS total_payable,
       SUM(f.amount_paid)   AS repaid, SUM(f.amount_remain) AS outstanding
FROM (SELECT la.*, (SELECT MIN(p.pay_date) FROM `tbl_payment` p WHERE p.loan_id = la.id) AS d0
      FROM `tbl_loan_application` la WHERE la.id > 10) f
WHERE f.d0 IS NOT NULL
GROUP BY loan_year ORDER BY loan_year;

-- V9. Repayments grouped by year (new loans only)
SELECT YEAR(p.pay_date) AS pay_year, COUNT(*) AS repayments,
       COUNT(DISTINCT p.loan_id) AS loans_serviced,
       SUM(p.pay_amount) AS cash_collected, SUM(p.fine) AS penalties
FROM `tbl_payment` p WHERE p.loan_id > 10 GROUP BY pay_year ORDER BY pay_year;

-- V10. Reconciliation: cash + collateral settlement == amount_paid, and
--      nothing is overpaid or arithmetically inconsistent (new loans only)
SELECT
  (SELECT COALESCE(SUM(la.amount_paid),0) FROM `tbl_loan_application` la WHERE la.id > 10) AS amount_paid,
  (SELECT COALESCE(SUM(p.pay_amount),0) FROM `tbl_payment` p WHERE p.loan_id > 10)
   + (SELECT COALESCE(SUM(pay_remaining_loan),0) FROM `tbl_liability`)               AS cash_plus_collateral,
  (SELECT COALESCE(SUM(la.amount_paid),0) FROM `tbl_loan_application` la WHERE la.id > 10)
   - (SELECT COALESCE(SUM(p.pay_amount),0) FROM `tbl_payment` p WHERE p.loan_id > 10)
   - (SELECT COALESCE(SUM(pay_remaining_loan),0) FROM `tbl_liability`)               AS difference,
  (SELECT COUNT(*) FROM `tbl_loan_application` la WHERE la.id > 10
     AND la.amount_paid > la.total_loan)                                  AS overpaid_loans,
  (SELECT COUNT(*) FROM `tbl_loan_application` la WHERE la.id > 10
     AND la.amount_remain <> la.total_loan - la.amount_paid)             AS balance_errors,
  (SELECT COUNT(*) FROM `tbl_payment` p
     WHERE p.loan_id > 10
       AND p.loan_id NOT IN (SELECT id FROM `tbl_loan_application`))                        AS orphan_payments;

-- V11. Full payment history of one loan (replace 1234 with any loan id)
SELECT p.id, p.pay_date, p.pay_amount, p.current_inst, p.remain_inst, p.fine,
       la.expected_loan, la.total_loan, la.amount_paid, la.amount_remain
FROM `tbl_payment` p JOIN `tbl_loan_application` la ON la.id = p.loan_id
WHERE p.loan_id = 1234 ORDER BY p.pay_date, p.id;

-- V12. Repeat borrowers - more than one loan each
SELECT b.id, b.name, b.mobile, b.working_status, COUNT(la.id) AS loan_count,
       SUM(CASE WHEN la.status = 3 THEN 1 ELSE 0 END) AS disbursed,
       SUM(la.total_loan)    AS total_payable,
       SUM(la.amount_paid)   AS repaid,
       SUM(la.amount_remain) AS outstanding
FROM `tbl_borrower` b JOIN `tbl_loan_application` la ON la.b_id = b.id
WHERE b.id > 9
GROUP BY b.id, b.name, b.mobile, b.working_status
HAVING loan_count > 1 ORDER BY loan_count DESC, b.name;

-- V13. Loans-per-borrower distribution (expect 1, 2, 3 and 4)
SELECT loan_count, COUNT(*) AS borrowers FROM
  (SELECT b_id, COUNT(*) AS loan_count FROM `tbl_loan_application` WHERE id > 10 GROUP BY b_id) t
GROUP BY loan_count ORDER BY loan_count;

-- V14. Portfolio quality and pricing summary
SELECT COUNT(*) AS disbursed_loans,
  ROUND(100 * SUM(CASE WHEN amount_remain > 0 AND next_date <= '2026-09-26' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_overdue,
  ROUND(100 * SUM(CASE WHEN amount_remain > 0 AND next_date >  '2026-09-26' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_active,
  ROUND(100 * SUM(CASE WHEN amount_remain <= 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_completed,
  ROUND(AVG(loan_percentage), 2) AS avg_interest_pct,
  ROUND(AVG(installments), 2)   AS avg_instalments,
  ROUND(AVG(expected_loan), 0)  AS avg_principal,
  MIN(expected_loan) AS smallest_loan, MAX(expected_loan) AS largest_loan
FROM `tbl_loan_application` WHERE id > 10 AND status = 3;

-- V15. Interest-bearing summary by loan period
SELECT installments AS instalments, ROUND(installments / 4) AS loan_months,
       COUNT(*) AS loans, ROUND(AVG(loan_percentage), 1) AS avg_interest_pct,
       SUM(expected_loan) AS principal, SUM(total_loan) AS total_payable,
       SUM(total_loan - expected_loan) AS total_interest_charged
FROM `tbl_loan_application` WHERE id > 10 AND status = 3
GROUP BY installments ORDER BY installments;

-- V16. Borrowers grouped by county, taken from the stored address
--     (the schema has no branch column and no branches table)
SELECT SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(b.address, ',', -1)), ' ', 1) AS county,
       COUNT(DISTINCT b.id) AS borrowers, COUNT(la.id) AS loans,
       SUM(la.expected_loan) AS principal, SUM(la.amount_remain) AS outstanding
FROM `tbl_borrower` b JOIN `tbl_loan_application` la ON la.b_id = b.id
WHERE b.id > 9
GROUP BY county ORDER BY borrowers DESC, county;

-- V17. Borrower age and gender profile
SELECT CASE WHEN TIMESTAMPDIFF(YEAR, b.dob, '2026-09-26') BETWEEN 18 AND 25 THEN '18-25'
            WHEN TIMESTAMPDIFF(YEAR, b.dob, '2026-09-26') BETWEEN 26 AND 35 THEN '26-35'
            WHEN TIMESTAMPDIFF(YEAR, b.dob, '2026-09-26') BETWEEN 36 AND 45 THEN '36-45'
            WHEN TIMESTAMPDIFF(YEAR, b.dob, '2026-09-26') BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+' END AS age_band,
       b.gender, b.working_status, COUNT(*) AS borrowers
FROM `tbl_borrower` b WHERE b.id > 9
GROUP BY age_band, b.gender, b.working_status
ORDER BY age_band, b.gender;

-- V18. DATA-QUALITY GATE - every rows_bad value MUST be 0.
--     Scoped to the rows this script added (borrower id > 9, application id
--     > 10, payment loan_id > 10) so pre-existing rows in brac_loan.sql are
--     reported separately and are never altered. Note the 2 legacy
--     applications that predate the current formula and are left as they are.
SELECT 'borrower mobile duplicated' AS check_name, COUNT(*) AS rows_bad
FROM (SELECT mobile FROM `tbl_borrower` WHERE id > 9 GROUP BY mobile HAVING COUNT(*) > 1) x
UNION ALL SELECT 'borrower nid duplicated', COUNT(*)
  FROM (SELECT nid FROM `tbl_borrower` WHERE id > 9 GROUP BY nid HAVING COUNT(*) > 1) x
UNION ALL SELECT 'borrower email duplicated', COUNT(*)
  FROM (SELECT email FROM `tbl_borrower` WHERE id > 9 GROUP BY email HAVING COUNT(*) > 1) x
UNION ALL SELECT 'borrower missing a required field', COUNT(*) FROM `tbl_borrower`
  WHERE id > 9 AND (name IS NULL OR name = '' OR mobile IS NULL OR mobile = ''
     OR nid IS NULL OR nid = '' OR email IS NULL OR email = ''
     OR address IS NULL OR address = '' OR dob IS NULL)
UNION ALL SELECT 'application b_id orphan', COUNT(*) FROM `tbl_loan_application` la
  LEFT JOIN `tbl_borrower` b ON b.id = la.b_id WHERE la.id > 10 AND b.id IS NULL
UNION ALL SELECT 'payment b_id orphan', COUNT(*) FROM `tbl_payment` p
  LEFT JOIN `tbl_borrower` b ON b.id = p.b_id WHERE p.loan_id > 10 AND b.id IS NULL
UNION ALL SELECT 'payment loan_id orphan', COUNT(*) FROM `tbl_payment` p
  LEFT JOIN `tbl_loan_application` la ON la.id = p.loan_id WHERE p.loan_id > 10 AND la.id IS NULL
UNION ALL SELECT 'payment borrower mismatch', COUNT(*) FROM `tbl_payment` p
  JOIN `tbl_loan_application` la ON la.id = p.loan_id WHERE p.loan_id > 10 AND la.b_id <> p.b_id
UNION ALL SELECT 'liability loan_id orphan', COUNT(*) FROM `tbl_liability` l
  LEFT JOIN `tbl_loan_application` la ON la.id = l.loan_id WHERE la.id IS NULL
UNION ALL SELECT 'liability not fully settled', COUNT(*) FROM `tbl_liability` l
  JOIN `tbl_loan_application` la ON la.id = l.loan_id WHERE la.amount_remain <> 0
UNION ALL SELECT 'amount_remain inconsistent', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND amount_remain <> total_loan - amount_paid
UNION ALL SELECT 'amount_paid exceeds total', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND amount_paid > total_loan
UNION ALL SELECT 'amount_paid below zero', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND amount_paid < 0
UNION ALL SELECT 'current_inst beyond term', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND current_inst > installments
UNION ALL SELECT 'total_loan formula broken', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND total_loan <> ROUND(expected_loan
      + (expected_loan * loan_percentage/100) * (installments/4))
UNION ALL SELECT 'emi_loan inconsistent', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND emi_loan <> ROUND(total_loan / installments)
UNION ALL SELECT 'installments not months*4', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND MOD(installments, 4) <> 0
UNION ALL SELECT 'loan term above 12 months', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND installments > 48
UNION ALL SELECT 'interest percentage unsupported', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND loan_percentage NOT IN (5,7,8,10,12,15)
UNION ALL SELECT 'unsupported status value', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND status NOT IN (0,1,2,3)
UNION ALL SELECT 'unsupported working_status', COUNT(*) FROM `tbl_borrower`
  WHERE id > 9 AND working_status NOT IN ('Employee','Owner','Student','Unemployed','other')
UNION ALL SELECT 'unsupported gender', COUNT(*) FROM `tbl_borrower`
  WHERE id > 9 AND gender NOT IN ('Male','Female','other')
UNION ALL SELECT CONCAT('repayment after ', '2026-09-26'), COUNT(*) FROM `tbl_payment`
  WHERE loan_id > 10 AND pay_date > '2026-09-26'
UNION ALL SELECT 'repayment before 2024-01-01', COUNT(*) FROM `tbl_payment`
  WHERE loan_id > 10 AND pay_date < '2024-01-01'
UNION ALL SELECT 'duplicate repayment date on a loan', COUNT(*) FROM (
  SELECT loan_id, pay_date FROM `tbl_payment` WHERE loan_id > 10
  GROUP BY loan_id, pay_date HAVING COUNT(*) > 1) y
UNION ALL SELECT 'more payments than instalments', COUNT(*) FROM (
  SELECT loan_id, COUNT(*) c FROM `tbl_payment` WHERE loan_id > 10 GROUP BY loan_id HAVING c > 4) y
  JOIN `tbl_loan_application` la ON la.id = y.loan_id WHERE y.c > la.installments
UNION ALL SELECT 'payment sum exceeds amount_paid', COUNT(*) FROM (
  SELECT loan_id, SUM(pay_amount) s FROM `tbl_payment` WHERE loan_id > 10 GROUP BY loan_id) y
  JOIN `tbl_loan_application` la ON la.id = y.loan_id WHERE y.s > la.amount_paid
UNION ALL SELECT 'payment sum below amount_paid on a settled loan', COUNT(*) FROM (
  SELECT loan_id, SUM(pay_amount) s FROM `tbl_payment` WHERE loan_id > 10 GROUP BY loan_id) y
  JOIN `tbl_loan_application` la ON la.id = y.loan_id
  WHERE la.amount_remain > 0 AND y.s <> la.amount_paid
UNION ALL SELECT 'pending loan carrying a payment', COUNT(*) FROM `tbl_loan_application` la
  WHERE la.id > 10 AND la.status < 3
    AND EXISTS (SELECT 1 FROM `tbl_payment` p WHERE p.loan_id = la.id)
UNION ALL SELECT 'active loan with NULL next_date', COUNT(*) FROM `tbl_loan_application` la
  WHERE la.id > 10 AND la.status = 3 AND la.amount_remain > 0 AND la.next_date IS NULL
UNION ALL SELECT 'settled loan keeping a next_date', COUNT(*) FROM `tbl_loan_application` la
  WHERE la.id > 10 AND la.status = 3 AND la.amount_remain <= 0 AND la.next_date IS NOT NULL
UNION ALL SELECT 'next_date more than 30d after last payment', COUNT(*) FROM `tbl_loan_application` la
  JOIN (SELECT loan_id, MAX(pay_date) last_pay FROM `tbl_payment`
        WHERE loan_id > 10 GROUP BY loan_id) y ON y.loan_id = la.id
  WHERE la.next_date IS NOT NULL
    AND DATEDIFF(la.next_date, y.last_pay) <> 30
UNION ALL SELECT 'liability row on a pending loan', COUNT(*) FROM `tbl_liability` l
  JOIN `tbl_loan_application` la ON la.id = l.loan_id WHERE la.status <> 3
UNION ALL SELECT 'liability on a loan settled without it', COUNT(*) FROM `tbl_liability` l
  JOIN `tbl_loan_application` la ON la.id = l.loan_id
  WHERE NOT EXISTS (SELECT 1 FROM `tbl_payment` p WHERE p.loan_id = la.id)
UNION ALL SELECT 'portfolio principal is not 4,000,000',
  IF((SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10) = 4000000, 0, 1)
UNION ALL SELECT 'disbursed not below the portfolio total', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND status = 3
    AND (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10)
      <= (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10 AND status = 3)
UNION ALL SELECT 'portfolio <> disbursed + undisbursed', IF(
    (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10)
    <> (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10 AND status = 3)
     + (SELECT COALESCE(SUM(expected_loan),0) FROM `tbl_loan_application` WHERE id > 10 AND status < 3), 1, 0)
UNION ALL SELECT 'principal off the 50 grid', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND MOD(expected_loan, 50) <> 0
UNION ALL SELECT 'principal outside allowed range', COUNT(*) FROM `tbl_loan_application`
  WHERE id > 10 AND (expected_loan < 5000 OR expected_loan > 150000);

-- ---------------------------------------------------------------------
--  DEMONSTRATION CHECKLIST (expected after this import)
--   * 40 new borrowers, 69 loan applications, 568 repayments,
--     8 collateral settlements, existing admins/roles untouched
--   * 17 completed (reconciled) | 17 active | 10 overdue | 10 pending
--     | 7 approved-not-yet-due | 8 settled by collateral
--   * derived view therefore shows 25 completed (17+8),
--     24 active (17+7), 10 overdue and 10 pending
--   * loans per borrower: 22 x 1, 10 x 2, 5 x 3, 3 x 4
--   * portfolio principal KES 4,000,000 = KES 3,400,000 disbursed + KES 600,000 undisbursed
--   * collateral realised in this dataset: KES 277674
--     surplus returned to borrowers:  KES 468500
--   * Pages to demo: index.php (dashboard), viewborrowerlist.php,
--     viewborrower.php, loan_application.php, loanverify.php, loan_status.php,
--     activeloans.php, notification.php, payloan.php, payment_report.php,
--     loan_app_report.php, recordsellinfo.php, showsellinfo.php,
--     interest.php, disbursed.php, disbursed_amount.php
-- ---------------------------------------------------------------------
