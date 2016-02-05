# PO Receiving SSOY

These files create a report requested by Fairfield Finance, so that they can review the date that services were rendered or products were provided (in the "voucher" column) for invoices paid since SOY (Jan 1 of current year).

To install, run setup_view.sql  against the desired MUNIS 6-11 database.

To generate the file, edit runner.ps1, replace "OUTPUT_DIR" and "SERVERNAME" as appropriate, then execute runner.ps1.
