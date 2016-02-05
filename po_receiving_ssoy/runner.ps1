function Get-MUData{
   param([string]$query=$(throw 'query is required.'))
   $conn = New-Object System.Data.Odbc.OdbcConnection
   $conn.ConnectionString = "Driver={SQL Server};Server=SERVERNAME;Database=mu_live;Integrated Security=SSPI"
   $conn.open()
   $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
   $ds = New-Object system.Data.DataSet
   (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null
   $conn.close()
   $ds.Tables[0]
}

$output_dir = "OUTPUT_DIR"
$output_result = Get-MUData "SELECT * FROM [custom].[po_receiving_ssoy]"
$output_result | select "a_vendor_number" , "a_invoice_number" , "a_invoice" , "i_voucher_number" , "i_invoice_status" , "i_invoice_desc" , "i_invoice_date" , "a_check_date" , "a_check_number" , "i_invoice_total" , "a_vendor_alph_sort" , "a_fund_seg1" , "a_line_item_desc" , "a_org" , "a_object" , "a_line_item_amount" , "a_purch_order_no" , "pptx_data" , "po_fiscal_year" , "a_requisition_no" , "po_type_of_po_code" , "po_prep_date" , "po_expiration_date" , "po_status_code" , "po_a_vendor_number" , "po_request_dept_cd" , "po_total_amount" | export-csv ($output_dir + "\output.csv") -notypeinformation -force
