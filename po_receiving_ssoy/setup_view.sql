USE [mu_live]
GO

/****** Object:  View [custom].[po_receiving_ssoy]    Script Date: 2/4/2016 1:23:18 PM ******/
DROP VIEW [custom].[po_receiving_ssoy]
GO

/****** Object:  View [custom].[po_receiving_ssoy]    Script Date: 2/4/2016 1:23:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [custom].[po_receiving_ssoy] AS
SELECT 
  ap_invoice.a_vendor_number
, ap_invoice.a_invoice_number
, ap_invoice.a_invoice
, ap_invoice.i_voucher_number
, ap_invoice.i_invoice_type
, ap_invoice.i_invoice_status
, ap_invoice.i_batch_number
, ap_invoice.i_clerk
, ap_invoice.a_warrant_number
, ap_invoice.i_department_no
, ap_invoice.i_entity_code
, REPLACE(REPLACE(ISNULL( ap_invoice.i_invoice_desc, ''), CHAR(13), ''), CHAR(10), ' ') AS i_invoice_desc
, ap_invoice.j_jrnl_entry_year
, ap_invoice.j_jrnl_entry_per
, isnull(convert(varchar, ap_invoice.i_invoice_date, 101),'') AS i_invoice_date
, isnull(convert(varchar, ap_invoice.i_inv_due_date, 101),'') AS i_inv_due_date
, isnull(convert(varchar, ap_invoice.i_inv_entry_date, 101),'') AS i_inv_entry_date
, isnull(convert(varchar, ap_invoice.a_check_date, 101),'') AS a_check_date
, ap_invoice.a_check_number
, ap_invoice.i_invoice_total
, ap_invoice.a_vendor_alph_sort
, ap_invoice.i_wire_xfr
, ap_invoice.i_released_y_n
, isnull(convert(varchar, ap_invoice.i_gl_eff_date, 101),'') AS i_gl_eff_date
, ap_invoice.id_line_number
, ap_invoice.a_fund_seg1
, REPLACE(REPLACE(ISNULL( ap_invoice.a_line_item_desc, ''), CHAR(13), ''), CHAR(10), ' ') AS a_line_item_desc
, ap_invoice.a_org
, ap_invoice.a_object
, ap_invoice.a_line_item_amount
, ap_invoice.a_purch_order_no
, isnull(userdata_pptx.pptx_data, '') AS pptx_data
, isnull(cast(po_stuff.po_fiscal_year as varchar),'') AS po_fiscal_year
, isnull(cast(po_stuff.a_requisition_no as varchar),'') AS a_requisition_no
, isnull(po_stuff.po_type_of_po_code,'') AS po_type_of_po_code
, isnull(convert(varchar, po_stuff.po_prep_date, 101),'') AS po_prep_date
, isnull(convert(varchar, po_stuff.po_expiration_date, 101),'') AS po_expiration_date
, isnull(po_stuff.po_status_code,'') AS po_status_code
, isnull(cast(po_stuff.a_vendor_number as varchar),'') AS po_a_vendor_number
, isnull(po_stuff.po_request_dept_cd,'') AS po_request_dept_cd
, isnull(cast(po_stuff.po_total_amount as varchar),'') AS po_total_amount
FROM dbo.ap_invoice
LEFT OUTER JOIN (
	SELECT ud_key_value, ud_data_text AS pptx_data
	FROM dbo.sp_user_data
	WHERE a_application_id = 'apinvoic'
	AND a_field_number = 1
) userdata_pptx ON (cast(ap_invoice.a_vendor_number as varchar)+ rtrim(ap_invoice.a_invoice_number)) = userdata_pptx.ud_key_value
LEFT OUTER JOIN 
(
	SELECT DISTINCT
	 ap_purch_orders.a_purch_order_no
	, ap_purch_orders.po_fiscal_year
	, ap_purch_orders.a_requisition_no
	, ap_purch_orders.po_type_of_po_code
	, ap_purch_orders.po_prep_date
	, ap_purch_orders.po_expiration_date
	, ap_purch_orders.po_status_code
	, ap_purch_orders.a_vendor_number
	, ap_purch_orders.po_request_dept_cd
	, ap_purch_orders.po_total_amount
	FROM dbo.ap_purch_orders
) po_stuff ON ap_invoice.a_purch_order_no = po_stuff.a_purch_order_no
WHERE ap_invoice.a_check_date >= DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)

GO


