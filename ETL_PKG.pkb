create or replace PACKAGE BODY etl_pkg AS
   
    g_success_status CONSTANT VARCHAR2(1):='S';
    g_error_status CONSTANT VARCHAR2(1):='E';


	--Load Dimensions

    PROCEDURE dim_customer(x_return_status out varchar2)
        IS
    BEGIN

        x_return_status := g_error_status;

        MERGE INTO wc_customer_d c USING
            ( SELECT tt.code,
                   tt.name,
                   tt.afm,
                   TO_CHAR(tt.id) integration_id
            FROM customer@makiosroutes_bi tt
            WHERE nvl(
                        tt.zshowinrouteapp,
                        0
                    ) = 1
                AND tt.comid = 1
            )
        x ON (
            c.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET c.code = x.code,
            c.name = x.name,
            c.afm = x.afm,
            C.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, code, NAME, afm ) 
        VALUES ( wc_customer_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.code, x.name, x.afm );

        x_return_status := g_success_status;

    END;

PROCEDURE dim_branch(x_return_status out varchar2) IS
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_branch_d b USING
          (SELECT cu.id,
                       cu.code,
                       cu.descr,
                       cu.perid,
                       TO_CHAR(cu.id) integration_id
                FROM custaddress@makiosroutes_bi cu,
                          customer@makiosroutes_bi c
                WHERE cu.perid = c.id
                    AND nvl(
                            c.zshowinrouteapp,
                            0
                        ) = 1
                    AND cu.isactive = 1
            )
        x ON (
            b.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET b.code = x.code,
            b.ID = x.ID,
            b.DESCR = x.DESCR,
            b.perid = x.perid,
            b.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, ID, code, DESCR, perid ) 
        VALUES ( wc_branch_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.id, x.code, x.descr, x.perid );

        x_return_status := g_success_status;
END;

PROCEDURE dim_product(x_return_status out varchar2) IS
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_material_d m USING
          (SELECT x.id,
                       x.code,
                       x.description,
                       TO_CHAR(x.id) integration_id
                FROM material@makiosroutes_bi x
                WHERE x.zdepartmentid IS NOT NULL
            )
        x ON (
            m.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET M.code = x.code,
            M.ID = x.ID,
            m.description = x.description,
            m.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, ID, code, description) 
        VALUES ( wc_material_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.id, x.code, x.description );

        x_return_status := g_success_status;
end;

PROCEDURE dim_supplier(x_return_status out varchar2) IS
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_supplier_d s USING
            ( SELECT x.code,
                           x.name,
                           x.afm,
                           TO_CHAR(x.id) integration_id
                    FROM supplier@makiosroutes_bi x
                    WHERE x.comid = 1
            )
        x ON (
            s.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET s.code = x.code,
            s.name = x.name,
            s.afm = x.afm,
            s.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, code, NAME, afm ) 
        VALUES ( wc_supplier_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.code, x.name, x.afm );

        x_return_status := g_success_status;
end;

PROCEDURE dim_route_expense(x_return_status out varchar2) IS
BEGIN
 x_return_status := g_error_status;

        MERGE INTO wc_routeexpenses_d e USING
          (SELECT x.codeid,
                       x.descr,
                       x.ptype,
                       TO_CHAR(x.codeid) integration_id
                FROM zroutesexpenses@makiosroutes_bi x
            )
        x ON (
            e.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET e.codeid = x.codeid,
            e.DESCR = x.DESCR,
            e.ptype = x.ptype,
            e.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, codeid, DESCR, ptype ) 
        VALUES ( wc_routeexpenses_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.codeid, x.descr, x.ptype );

        x_return_status := g_success_status;
end;

PROCEDURE dim_route_category(x_return_status out varchar2) is
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_routecategory_d r USING
          (SELECT x.id,
                       x.code,
                       x.descr,
                       TO_CHAR(x.id) integration_id
                FROM zroutescategories@makiosroutes_bi x
            )
        x ON (
            r.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET r.code = x.code,
            r.ID = x.ID,
            r.DESCR = x.DESCR,
            r.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, ID, code, DESCR ) 
        VALUES ( wc_routecategory_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.id, x.code, x.descr);

        x_return_status := g_success_status;
end;

PROCEDURE dim_transportation(x_return_status out VARCHAR2) IS
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_transportation_d t USING
          (SELECT x.codeid,
                       x.shortcut,
                       x.descr,
                       TO_CHAR(x.codeid) integration_id,
                        to_char(x.p_vehicletype)
                FROM transportation@makiosroutes_bi x
                WHERE x.comid = 1
                    AND x.isactive = 1
            )
        x ON (
            t.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET T.codeid = x.codeid,
            t.shortcut = x.shortcut,
            t.DESCR = x.DESCR,
            T.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, shortcut, codeid, DESCR ) 
        VALUES ( wc_transportation_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.shortcut, x.codeid, x.descr);

        x_return_status := g_success_status;
end;

PROCEDURE dim_trailer(x_return_status out VARCHAR2) IS
BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_trailer_d t USING
          (SELECT x.id,
                       x.code,
                       x.description,
                       TO_CHAR(x.id) integration_id
                FROM zassets@makiosroutes_bi x
                WHERE x.isactive = 1
                    AND ( x.issiromeno = 1
                        OR x.isbox = 1
                    )
            )
        x ON (
            t.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
        SET t.code = x.code,
            t.ID = x.ID,
            t.description = x.description,
            t.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT ( row_wid, integration_id, w_datasource_num_id, w_insert_dt, w_update_dt, ID, code, description) 
        VALUES ( wc_trailer_d_seq.NEXTVAL, x.integration_id, 20, SYSDATE, SYSDATE, x.id, x.code, x.description );

        x_return_status := g_success_status;
end;

    --Load Staging Facts
    PROCEDURE fact_final_routes_exp_rep(x_return_status OUT VARCHAR2) IS
    BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_final_routes_exp_rep_fs fs USING
          (SELECT final_route_id,
                        FINAL_ROUTE_CUSTOMER_ID,
                        final_route_receiver_id,
                        EXPID,
                        expdescr,
                        salesvalue,
                        PURCHASESVALUE,
                        quantityvalue,
                        SALESCALC,
                        PURCHASESCALC,
                        QUANTITYCALC,
                       TO_CHAR(x.final_route_receiver_id)
                     || '-'
                     || TO_CHAR(x.expid) integration_id
                FROM wc_final_routes_exp_rep_v@makiosroutes_bi x
            )
        x ON (
            fs.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            set fs.final_route_id = x.final_route_id
            ,final_route_customer_id = x.final_route_customer_id
            ,final_route_receiver_id = x.final_route_receiver_id
            ,expid = x.expid
            ,expdescr = x.expdescr
            ,salesvalue = x.salesvalue
            ,PURCHASESVALUE = x.PURCHASESVALUE
            ,quantityvalue = x.quantityvalue
            ,salescalc = x.salescalc
            ,purchasescalc = x.purchasescalc
            ,quantitycalc = x.quantitycalc
            ,fs.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT (final_route_id
                                                            ,FINAL_ROUTE_CUSTOMER_ID
                                                            ,FINAL_ROUTE_RECEIVER_ID
                                                            ,EXPID
                                                            ,EXPDESCR
                                                            ,salesvalue
                                                            ,PURCHASESVALUE
                                                            ,QUANTITYVALUE
                                                            ,SALESCALC
                                                            ,PURCHASESCALC
                                                            ,QUANTITYCALC
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,W_DATASOURCE_NUM_ID
                                                            ,integration_id) 
        VALUES (x.final_route_id
                    ,x.FINAL_ROUTE_CUSTOMER_ID
                    ,x.final_route_receiver_id
                    ,x.expid
                    ,x.EXPDESCR
                    ,x.salesvalue
                    ,x.PURCHASESVALUE
                    ,x.quantityvalue
                    ,x.salescalc
                    ,x.purchasescalc
                    ,x.quantitycalc
                    ,sysdate
                    ,sysdate
                    ,20
                    ,x.INTEGRATION_ID );

        x_return_status := g_success_status;
    END;

    PROCEDURE fact_final_routes_rec_rep(x_return_status out varchar2) IS
    BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_final_routes_recs_rep_fs fs USING
          (SELECT FINAL_ROUTE_ID,
                        final_routes_customer_id,
                        FINAL_ROUTES_RECEIVER_ID,
                        RECEIVERID,
                        receivercode,
                        RECEIVERDESCR,
                        delivery_date,
                        DELIVERY_TIME,
                        DELIVERY_NOTE,
                       to_char(x.final_routes_customer_id)||'-'||to_char(x.final_routes_receiver_id) integration_id,
                       geoid,
                       GEODESCR GEODESC
                FROM final_routes_receivers_rep@makiosroutes_bi x
            )
        x ON (
            fs.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            SET final_route_id = x.final_route_id
                    ,final_routes_customer_id = x.final_routes_customer_id
                    ,final_routes_receiver_id = x.FINAL_ROUTES_RECEIVER_ID
                    ,receiverid = x.receiverid
                    ,receivercode = x.receivercode
                    ,receiverdescr = x.receiverdescr
                    ,delivery_date = x.delivery_date
                    ,delivery_time = x.delivery_time
                    ,DELIVERY_NOTE = x.DELIVERY_NOTE
                    ,fs.w_update_dt = sysdate
                    ,fs.geoid = x.geoid
                    ,geodesc = x.geodesc
        WHEN NOT MATCHED THEN INSERT (final_route_id
                                                            ,FINAL_ROUTES_CUSTOMER_ID
                                                            ,final_routes_receiver_id
                                                            ,RECEIVERID
                                                            ,receivercode
                                                            ,RECEIVERDESCR
                                                            ,delivery_date
                                                            ,DELIVERY_TIME
                                                            ,delivery_note
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,W_DATASOURCE_NUM_ID
                                                            ,INTEGRATION_ID
                                                            ,geoid
                                                            ,geodesc) 
        VALUES (x.final_route_id
                                                            ,x.FINAL_ROUTES_CUSTOMER_ID
                                                            ,x.final_routes_receiver_id
                                                            ,x.receiverid
                                                            ,x.receivercode
                                                            ,x.receiverdescr
                                                            ,x.delivery_date
                                                            ,x.delivery_time
                                                            ,x.delivery_note
                    ,sysdate
                    ,sysdate
                    ,20
                    ,x.integration_id 
                    ,x.geoid
                    ,x.geodesc);

        x_return_status := g_success_status;
    END;

    PROCEDURE fact_final_routes_rep(x_return_status out varchar2) IS
    BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_final_routes_rep_fs fs USING
          (SELECT ID
                        ,ROUTE_DATE
                        ,supid
                        ,supplier
                        ,route_cusid
                        ,ROUTE_CUSTOMER
                        ,email
                        ,TRANSPORTATION_ID
                        ,tractor
                        ,TRAILER_ID
                        ,trailer
                        ,ROUTE
                        ,route_category_id
                        ,ROUTE_CATEGORY
                        ,webroute
                        ,WEBSTATUS
                        ,execution_flag
                        ,material_id
                        ,ITEM
                        ,COST_CENTER
                        ,paragogi
                        ,POLISI
                        ,DEPARTMENT
                        ,customer_id
                        ,CUSCODE
                        ,CUSNAME
                        ,senders
                        ,FINAL_ROUTES_CUSTOMER_ID
                        ,combined_id
                        ,COMBINED_DATE
                        ,combined_route
                       ,TO_CHAR(x.id)||'-'||to_char(x.final_routes_customer_id) integration_id
                       ,x.groupagenumber
                       ,null origin
                       ,TRANSPORTATION_TYPE
                       ,ASSET_TYPE
                       , (select sum(primaryqty) from ztransportation_oil_rep@makiosroutes_bi tr where tr.ftrdate = x.route_date and tr.trsid = x.transportation_id) oil_qty
                FROM FINAL_ROUTES_REP@makiosroutes_bi x
            )
        x ON (
            fs.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            SET ID = x.ID
                        ,route_date = x.route_date
                        ,supid = x.supid
                        ,supplier = x.supplier
                        ,route_cusid = x.route_cusid
                        ,route_customer = x.route_customer
                        ,email = x.email
                        ,transportation_id = x.transportation_id
                        ,tractor = x.tractor
                        ,trailer_id = x.trailer_id
                        ,trailer = x.trailer
                        ,route = x.route
                        ,route_category_id = x.route_category_id
                        ,route_category = x.route_category
                        ,webroute = x.webroute
                        ,webstatus = x.webstatus
                        ,execution_flag = x.execution_flag
                        ,material_id = x.material_id
                        ,item = x.item
                        ,cost_center = x.cost_center
                        ,paragogi = x.paragogi
                        ,polisi = x.polisi
                        ,department = x.department
                        ,customer_id = x.customer_id
                        ,cuscode = x.cuscode
                        ,cusname = x.cusname
                        ,senders = x.senders
                        ,final_routes_customer_id = x.final_routes_customer_id
                        ,combined_id = x.combined_id
                        ,combined_date = x.combined_date
                        ,combined_route = x.combined_route
                    ,fs.w_update_dt = sysdate
                    ,groupagenumber = x.groupagenumber
                    ,origin = x.origin
                    ,TRANSPORTATION_TYPE = x.TRANSPORTATION_TYPE
                    ,ASSET_TYPE = x.ASSET_TYPE
                    ,oil_qty = x.oil_qty
        WHEN NOT MATCHED THEN INSERT (ID
                                                            ,ROUTE_DATE
                                                            ,supid
                                                            ,supplier
                                                            ,route_cusid
                                                            ,ROUTE_CUSTOMER
                                                            ,email
                                                            ,TRANSPORTATION_ID
                                                            ,tractor
                                                            ,TRAILER_ID
                                                            ,trailer
                                                            ,ROUTE
                                                            ,route_category_id
                                                            ,ROUTE_CATEGORY
                                                            ,webroute
                                                            ,WEBSTATUS
                                                            ,execution_flag
                                                            ,material_id
                                                            ,ITEM
                                                            ,COST_CENTER
                                                            ,paragogi
                                                            ,POLISI
                                                            ,DEPARTMENT
                                                            ,customer_id
                                                            ,CUSCODE
                                                            ,CUSNAME
                                                            ,senders
                                                            ,FINAL_ROUTES_CUSTOMER_ID
                                                            ,combined_id
                                                            ,COMBINED_DATE
                                                            ,combined_route
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,W_DATASOURCE_NUM_ID
                                                            ,integration_id
                                                            ,groupagenumber
                                                            ,origin
                                                            ,TRANSPORTATION_TYPE
                                                            ,ASSET_TYPE
                                                            ,oil_qty) 
        VALUES (x.ID
                        ,x.route_date
                        ,x.supid
                        ,x.supplier
                        ,x.route_cusid
                        ,x.route_customer
                        ,x.email
                        ,x.transportation_id
                        ,x.tractor
                        ,x.trailer_id
                        ,x.trailer
                        ,x.route
                        ,x.route_category_id
                        ,x.route_category
                        ,x.webroute
                        ,x.webstatus
                        ,x.execution_flag
                        ,x.material_id
                        ,x.item
                        ,x.cost_center
                        ,x.paragogi
                        ,x.polisi
                        ,x.DEPARTMENT
                        ,x.customer_id
                        ,x.cuscode
                        ,x.cusname
                        ,x.senders
                        ,x.final_routes_customer_id
                        ,x.combined_id
                        ,x.combined_date
                        ,x.combined_route
                    ,sysdate
                    ,sysdate
                    ,20
                    ,x.INTEGRATION_ID 
                    ,x.groupagenumber
                    ,x.origin
                    ,x.TRANSPORTATION_TYPE
                   ,x.ASSET_TYPE
                   ,x.oil_qty);

        x_return_status := g_success_status;
    END;

     PROCEDURE fact_final_routes_docs_rep(x_return_status OUT VARCHAR2) IS
    BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_dummies_d fs USING
          (SELECT FINAL_ROUTE_ID
                        ,document_source
                        ,GREEK_DUMMY_ID
                        ,GREEK_DUMMY_TRADECODE
                        ,greek_dummy_date
                        ,GREEK_INVOICE_ID
                        ,greek_invoice_tradecode
                        ,GREEK_INVOICE_DATE
                        ,BULG_DUMMY_ID
                        ,BULG_DUMMY_TRADECODE
                        ,bulg_dummy_date
                        ,BULG_INVOICE_ID
                        ,bulg_invoice_tradecode
                        ,BULG_INVOICE_DATE
                       ,to_char(x.final_route_id)||'-'||to_char(x.greek_dummy_id)||'-'||to_char(x.greek_invoice_id)||'-'||to_char(x.bulg_dummy_id)||'-'||to_char(x.bulg_invoice_id) integration_id
                FROM final_routes_documents_rep@makiosroutes_bi x
            )
        x ON (
            fs.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            SET final_route_id = x.final_route_id
                        ,document_source = x.document_source
                        ,greek_dummy_id = x.greek_dummy_id
                        ,greek_dummy_tradecode = x.greek_dummy_tradecode
                        ,greek_dummy_date = x.greek_dummy_date
                        ,greek_invoice_id = x.greek_invoice_id
                        ,greek_invoice_tradecode = x.greek_invoice_tradecode
                        ,greek_invoice_date = x.greek_invoice_date
                        ,bulg_dummy_id = x.bulg_dummy_id
                        ,bulg_dummy_tradecode = x.bulg_dummy_tradecode
                        ,bulg_dummy_date = x.bulg_dummy_date
                        ,bulg_invoice_id = x.bulg_invoice_id
                        ,bulg_invoice_tradecode = x.bulg_invoice_tradecode
                        ,BULG_INVOICE_DATE = x.BULG_INVOICE_DATE
            ,fs.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT (row_wid
                                                            ,FINAL_ROUTE_ID
                                                            ,document_source
                                                            ,GREEK_DUMMY_ID
                                                            ,GREEK_DUMMY_TRADECODE
                                                            ,greek_dummy_date
                                                            ,GREEK_INVOICE_ID
                                                            ,greek_invoice_tradecode
                                                            ,GREEK_INVOICE_DATE
                                                            ,BULG_DUMMY_ID
                                                            ,BULG_DUMMY_TRADECODE
                                                            ,bulg_dummy_date
                                                            ,BULG_INVOICE_ID
                                                            ,bulg_invoice_tradecode
                                                            ,BULG_INVOICE_DATE
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,W_DATASOURCE_NUM_ID
                                                            ,integration_id) 
        VALUES (WC_DUMMIES_D_SEQ.nextval
                        ,x.FINAL_ROUTE_ID
                        ,x.document_source
                        ,x.GREEK_DUMMY_ID
                        ,x.GREEK_DUMMY_TRADECODE
                        ,x.greek_dummy_date
                        ,x.GREEK_INVOICE_ID
                        ,x.greek_invoice_tradecode
                        ,x.greek_invoice_date
                        ,x.BULG_DUMMY_ID
                        ,x.BULG_DUMMY_TRADECODE
                        ,x.bulg_dummy_date
                        ,x.BULG_INVOICE_ID
                        ,x.bulg_invoice_tradecode
                        ,x.BULG_INVOICE_DATE
                    ,sysdate
                    ,sysdate
                    ,20
                    ,x.INTEGRATION_ID );

        x_return_status := g_success_status;
    END;

    PROCEDURE fact_final_routes_senders_rep(x_return_status OUT VARCHAR2) IS
    BEGIN
        x_return_status := g_error_status;

        MERGE INTO wc_final_routes_senders_rep_fs fs USING
          (SELECT final_route_id
                        ,final_routes_customer_id
                        ,FINAL_ROUTES_SENDER_ID
                        ,senderid
                        ,SENDERCODE
                        ,SENDERDESCR
                       ,to_char(x.final_routes_customer_id)||'-'||to_char(x.final_routes_sender_id) integration_id
                FROM final_routes_senders_rep@makiosroutes_bi x
            )
        x ON (
            fs.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            SET final_route_id = x.final_route_id
                        ,final_routes_customer_id = x.final_routes_customer_id
                        ,final_routes_sender_id = x.final_routes_sender_id
                        ,senderid = x.senderid
                        ,sendercode = x.sendercode
                        ,SENDERDESCR = x.SENDERDESCR
                    ,fs.w_update_dt = sysdate
        WHEN NOT MATCHED THEN INSERT (final_route_id
                                                            ,final_routes_customer_id
                                                            ,FINAL_ROUTES_SENDER_ID
                                                            ,senderid
                                                            ,SENDERCODE
                                                            ,SENDERDESCR
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,W_DATASOURCE_NUM_ID
                                                            ,integration_id) 
        VALUES (x.final_route_id
                        ,x.final_routes_customer_id
                        ,x.FINAL_ROUTES_SENDER_ID
                        ,x.senderid
                        ,x.sendercode
                        ,x.SENDERDESCR
                    ,sysdate
                    ,sysdate
                    ,20
                    ,x.INTEGRATION_ID );

        x_return_status := g_success_status;
    END;

	--Load Facts

 PROCEDURE fact_final_route(x_return_status out varchar2) IS
 BEGIN
 x_return_status := g_error_status;

        MERGE INTO wc_final_routes_exp_fs F USING
          (select fre.INTEGRATION_ID||'-'||fr.INTEGRATION_ID||'-'||frs.integration_id||'-'||frr.integration_id/*||'-'||frd.integration_id*/ INTEGRATION_ID
                        ,20 DATASOURCE_NUM_ID
                        ,sysdate W_UPDATE_DT
                        ,sysdate W_INSERT_DT
                        ,QUANTITYCALC
                        ,PURCHASESCALC
                        ,SALESCALC SALESCALC
                        ,QUANTITYVALUE
                        ,PURCHASESVALUE
                        ,SALESVALUE
                        ,nvl(s.ROW_WID,0) SUPLIER_WID
                        ,nvl(c.ROW_WID,0) CUSTOMER_WID
                        ,nvl(br.ROW_WID,0) RECEIVER_WID
                        ,nvl(tr.ROW_WID,0) TRAILER_WID
                        ,nvl(t.ROW_WID,0) TRANSPORTAION_WID
                        ,nvl(d.DAY_KEY,0) ROUTE_DATE_WID
                        ,nvl(m.ROW_WID,0) MATERIAL_WID
                        ,nvl(rc.ROW_WID,0) ROUTE_CATEGORY_WID
                        ,nvl(re.ROW_WID,0) ROUTE_EXP_WID
                        ,fr.ROUTE ROUTE
                        ,fr.TRACTOR TRACTOR
                        ,fr.ROUTE_CUSID
                        ,fr.ROUTE_CUSTOMER
                        ,fr.EMAIL
                        ,fr.WEBROUTE
                        ,fr.WEBSTATUS
                        ,fr.EXECUTION_FLAG
                        ,fr.COST_CENTER
                        ,fr.PARAGOGI
                        ,fr.POLISI
                        ,fr.DEPARTMENT
                        ,fr.SENDERS
                        ,fr.COMBINED_ID
                        ,fr.COMBINED_DATE
                        ,fr.COMBINED_ROUTE
                        ,nvl(br1.row_wid,0) sender_wid
                        ,frr.geodesc
                        ,null document_source
                        ,0/*nvl(frd.row_wid,0)*/ dummie_wid
                        ,fre.FINAL_ROUTE_ID
                        ,fr.groupagenumber
                        ,fr.origin
                        ,fr.TRANSPORTATION_TYPE
                       ,fr.ASSET_TYPE
                       ,fr.oil_qty
            from WC_FINAL_ROUTES_EXP_REP_FS fre
                    ,WC_FINAL_ROUTES_RECS_REP_FS frr
                    ,WC_ROUTEEXPENSES_D re
                    ,WC_FINAL_ROUTES_REP_FS fr
                     ,WC_ROUTECATEGORY_D rc
                    ,WC_MATERIAL_D m
                    ,WC_TIME_DAY_D d
                    ,WC_TRANSPORTATION_D t
                    ,WC_TRAILER_D tr
                    ,WC_SUPPLIER_D s
                    ,WC_CUSTOMER_D c
                    ,WC_BRANCH_D br
                    ,WC_FINAL_ROUTES_SENDERS_REP_FS frs
                    ,wc_branch_d br1
                 --   ,wc_dummies_d  frd
            where fre.FINAL_ROUTE_RECEIVER_ID = frr.FINAL_ROUTES_RECEIVER_ID
                and fre.EXPID = re.CODEID
                and fre.FINAL_ROUTE_ID = fr.ID
                and fre.FINAL_ROUTE_CUSTOMER_ID = fr.FINAL_ROUTES_CUSTOMER_ID
                and fr.ROUTE_CATEGORY_ID = rc.ID(+)
                and fr.MATERIAL_ID = m.ID(+)
                and fr.ROUTE_DATE = d.CALENDAR_DATE(+)
                and fr.TRANSPORTATION_ID = t.CODEID(+)
                and fr.TRAILER_ID = tr.ID(+)
                and fr.SUPID = s.CODE(+)
                and fr.CUSCODE = c.CODE(+)
                and frr.RECEIVERID = br.ID(+)
                AND frs.final_routes_customer_id = fr.final_routes_customer_id
                AND frs.senderid = br1.ID
              --  and fre.final_route_id = frd.final_route_id (+)
            )
        x ON (
            f.integration_id = x.integration_id
        ) WHEN MATCHED THEN
            UPDATE
            SET quantitycalc = x.quantitycalc
                    ,purchasescalc = x.purchasescalc
                    ,salescalc = x.salescalc
                    ,QUANTITYVALUE = x.QUANTITYVALUE
                    ,purchasesvalue = x.purchasesvalue
                    ,salesvalue = x.salesvalue
                    ,suplier_wid = x.suplier_wid
                    ,customer_wid = x.customer_wid
                    ,RECEIVER_WID = x.RECEIVER_WID
                    ,trailer_wid = x.trailer_wid
                    ,transportaion_wid = x.transportaion_wid
                    ,route_date_wid = x.route_date_wid
                    ,material_wid = x.material_wid
                    ,route_category_wid = x.route_category_wid
                    ,route_exp_wid = x.route_exp_wid
                    ,route = x.route
                    ,tractor = x.tractor
                    ,route_cusid = x.route_cusid
                    ,route_customer = x.route_customer
                    ,email = x.email
                    ,webroute = x.webroute
                    ,webstatus = x.webstatus
                    ,execution_flag = x.execution_flag
                    ,cost_center = x.cost_center
                    ,paragogi = x.paragogi
                    ,polisi = x.polisi
                    ,department = x.department
                    ,senders = x.senders
                    ,combined_id = x.combined_id
                    ,combined_date = x.combined_date
                    ,combined_route = x.combined_route
                    ,SENDER_WID = x.SENDER_WID
                    ,F.w_update_dt = sysdate
                    ,geodesc = x.geodesc
                    ,document_source = x.document_source
                    ,dummie_wid = x.dummie_wid
                    ,final_route_id = x.final_route_id
                    ,groupagenumber = x.groupagenumber
                    ,origin = x.origin
                    ,TRANSPORTATION_TYPE = x.TRANSPORTATION_TYPE
                    ,ASSET_TYPE = x.ASSET_TYPE
                    ,oil_qty = x.oil_qty
        WHEN NOT MATCHED THEN INSERT (QUANTITYCALC
                                                            ,PURCHASESCALC
                                                            ,SALESCALC
                                                            ,QUANTITYVALUE
                                                            ,PURCHASESVALUE
                                                            ,SALESVALUE
                                                            ,SUPLIER_WID
                                                            ,CUSTOMER_WID
                                                            ,RECEIVER_WID
                                                            ,TRAILER_WID
                                                            ,TRANSPORTAION_WID
                                                            ,ROUTE_DATE_WID
                                                            ,MATERIAL_WID
                                                            ,ROUTE_CATEGORY_WID
                                                            ,ROUTE_EXP_WID
                                                            ,ROUTE
                                                            ,TRACTOR
                                                            ,ROUTE_CUSID
                                                            ,ROUTE_CUSTOMER
                                                            ,EMAIL
                                                            ,WEBROUTE
                                                            ,WEBSTATUS
                                                            ,EXECUTION_FLAG
                                                            ,COST_CENTER
                                                            ,PARAGOGI
                                                            ,POLISI
                                                            ,DEPARTMENT
                                                            ,SENDERS
                                                            ,COMBINED_ID
                                                            ,combined_date
                                                            ,COMBINED_ROUTE
                                                            ,SENDER_WID
                                                            ,W_INSERT_DT
                                                            ,w_update_dt
                                                            ,DATASOURCE_NUM_ID
                                                            ,integration_id
                                                            ,GEODESC
                                                            ,document_source
                                                            ,dummie_wid
                                                            ,final_route_id
                                                            ,groupagenumber
                                                            ,origin
                                                            ,TRANSPORTATION_TYPE
                                                            ,ASSET_TYPE
                                                            ,oil_qty) 
        VALUES (x.quantitycalc
                                                            ,x.PURCHASESCALC
                                                            ,x.salescalc
                                                            ,x.QUANTITYVALUE
                                                            ,x.purchasesvalue
                                                            ,x.SALESVALUE
                                                            ,x.suplier_wid
                                                            ,x.CUSTOMER_WID
                                                            ,x.RECEIVER_WID
                                                            ,x.trailer_wid
                                                            ,x.TRANSPORTAION_WID
                                                            ,x.route_date_wid
                                                            ,x.MATERIAL_WID
                                                            ,x.route_category_wid
                                                            ,x.ROUTE_EXP_WID
                                                            ,x.route
                                                            ,x.TRACTOR
                                                            ,x.route_cusid
                                                            ,x.route_customer
                                                            ,x.email
                                                            ,x.webroute
                                                            ,x.webstatus
                                                            ,x.EXECUTION_FLAG
                                                            ,x.cost_center
                                                            ,x.PARAGOGI
                                                            ,x.polisi
                                                            ,x.DEPARTMENT
                                                            ,x.senders
                                                            ,x.COMBINED_ID
                                                            ,x.combined_date
                                                            ,x.combined_route
                                                            ,x.SENDER_WID
                                                            ,sysdate
                                                            ,sysdate
                                                            ,20
                                                            ,x.integration_id
                                                            ,x.geodesc
                                                            ,x.DOCUMENT_SOURCE
                                                            ,x.dummie_wid
                                                            ,x.final_route_id
                                                            ,x.groupagenumber
                                                            ,x.origin
                                                            ,x.TRANSPORTATION_TYPE
                                                            ,x.ASSET_TYPE
                                                            ,x.oil_qty);

       for i in (SELECT COUNT(*) cnt, suplier_wid
                 ,CUSTOMER_WID
                 ,RECEIVER_WID
                 ,TRAILER_WID
                 ,TRANSPORTAION_WID
                 ,ROUTE_DATE_WID
                 ,MATERIAL_WID
                 ,route_category_wid
                 ,ROUTE_EXP_WID
                 ,salesvalue
                 ,salescalc
                 ,quantityvalue
                 ,quantitycalc
                 ,purchasesvalue
                 ,purchasescalc
                 ,final_route_id
                 ,ROUTE_CUSID
                 ,null receivers
                 ,null routes
                 ,null greek_dummies
                 ,null greek_invoices
                -- ,sum(case when salescalc = 1 then salesvalue else 0 end) salesvalue
FROM wc_final_routes_exp_fs
group by suplier_wid
                 ,CUSTOMER_WID
                 ,RECEIVER_WID
                 ,TRAILER_WID
                 ,TRANSPORTAION_WID
                 ,ROUTE_DATE_WID
                 ,MATERIAL_WID
                 ,route_category_wid
                 ,route_exp_wid
                 ,salesvalue
                 ,salescalc
                 ,quantityvalue
                 ,quantitycalc
                 ,purchasesvalue
                 ,purchasescalc
                 ,final_route_id
                 ,ROUTE_CUSID)
        loop

            UPDATE wc_final_routes_exp_fs
            SET quantityvalue = round(quantityvalue/I.cnt,2)
                ,purchasesvalue = round(purchasesvalue/I.cnt,2)
                ,SALESVALUE = round(SALESVALUE/i.cnt,2)
                ,oil_qty = round(oil_qty/i.cnt,2)
            WHERE suplier_wid = I.suplier_wid
                 and customer_wid = I.customer_wid
                 and receiver_wid = I.receiver_wid
                 and trailer_wid = I.trailer_wid
                 and transportaion_wid = I.transportaion_wid
                 and route_date_wid = I.route_date_wid
                 and MATERIAL_WID = i.MATERIAL_WID
                 and route_exp_wid = i.route_exp_wid
                 and salesvalue = i.salesvalue
                 and salescalc = i.salescalc
                 and quantityvalue = i.quantityvalue
                 and quantitycalc = i.quantitycalc
                 and purchasesvalue = i.purchasesvalue
                 and purchasescalc = i.purchasescalc
                 and final_route_id = i.final_route_id
                 and ROUTE_CUSID = i.ROUTE_CUSID;

        END LOOP;

        FOR i IN (select distinct final_route_id from wc_final_routes_exp_fs)
        LOOP
            update wc_final_routes_exp_fs
            set receivers =  (select rtrim(xmlagg(xmlelement(e, recs, ',')).extract('//text()').getclobval(), ',') receivers
                                     from
                                     (select distinct br.descr recs
                                     from wc_branch_d br
                                            ,wc_final_routes_exp_fs v
                                    where br.row_wid = v.receiver_wid
                                    and v.final_route_id = i.final_route_id))
                ,routes =(select rtrim(xmlagg(xmlelement(e, route, ',')).extract('//text()').getclobval(), ',') receivers
                                     from
                                     (select distinct route
                                     from wc_final_routes_exp_fs v
                                    where v.final_route_id = i.final_route_id))
                ,greek_dummies = (select rtrim(xmlagg(xmlelement(e, GREEK_DUMMY_TRADECODE, ',')).extract('//text()').getclobval(), ',') receivers
                                     from
                                     (select distinct GREEK_DUMMY_TRADECODE
                                     from wc_dummies_d gd
                                    where gd.final_route_id = i.final_route_id))
                ,greek_invoices = (select rtrim(xmlagg(xmlelement(e, GREEK_INVOICE_TRADECODE, ',')).extract('//text()').getclobval(), ',') receivers
                                     from
                                     (select distinct GREEK_INVOICE_TRADECODE
                                     from wc_dummies_d gd
                                    where gd.final_route_id = i.final_route_id))
            where final_route_id = i.final_route_id;
        END LOOP;
        
        --Full Load
        delete from wc_final_routes_exp_rep_f;
        
        insert into wc_final_routes_exp_rep_f
       select FINAL_ROUTE_ID||'-'||SENDER_WID||'-'||RECEIVER_WID||'-'||x.DOCUMENT_SOURCE||'-'||x.ROUTE INTEGRATION_ID
        ,x.DATASOURCE_NUM_ID
        ,sysdate W_UPDATE_DT
        ,sysdate W_INSERT_DT
        ,sum(x.QUANTITYVALUE) QUANTITYVALUE
        ,sum(x.PURCHASESVALUE) PURCHASESVALUE
        ,sum(x.SALESVALUE) SALESVALUE
        ,sum(case when x.codeid = '12' then x.QUANTITYVALUE else 0 end) km
        ,sum(case when (x.department = 1 and x.codeid = '14') or x.codeid = '23'  then x.QUANTITYVALUE else 0 end) kg
        ,sum(case when x.codeid = '15' then x.QUANTITYVALUE else 0 end) paletes
        ,sum(case when x.codeid = '7' and x.QUANTITYCALC =1 then x.QUANTITYVALUE else 0 end) stalies
        ,sum(case when x.SALESCALC =1 then x.SALESVALUE else 0 end) sales_amount
        ,sum(case when x.PURCHASESCALC =1 then x.PURCHASESVALUE else 0 end) purchase_amount
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '1' then x.PURCHASESVALUE else 0 end) value_fixed_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '1' then x.SALESVALUE else 0 end) value_fixed_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '2' then x.PURCHASESVALUE else 0 end) eisithria_pliwn_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '2' then x.SALESVALUE else 0 end) eisithria_pliwn_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '3' then x.PURCHASESVALUE else 0 end) misthotirio_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '3' then x.SALESVALUE else 0 end) misthotirio_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '17' then x.PURCHASESVALUE else 0 end) dianomi_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '17' then x.SALESVALUE else 0 end) dianomi_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '18' then x.PURCHASESVALUE else 0 end) promithia_stratos_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '18' then x.SALESVALUE else 0 end) promithia_stratos_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '19' then x.PURCHASESVALUE else 0 end) extra_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '19' then x.SALESVALUE else 0 end) extra_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '20' then x.PURCHASESVALUE else 0 end) plasm_timi_agoras_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '20' then x.SALESVALUE else 0 end) plasm_timi_agoras_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '21' then x.PURCHASESVALUE else 0 end) prokatavoli_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '21' then x.SALESVALUE else 0 end) prokatavoli_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '22' then x.PURCHASESVALUE else 0 end) plisimata_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '22' then x.SALESVALUE else 0 end) plisimata_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '23' then x.PURCHASESVALUE else 0 end) kila_xima_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '23' then x.SALESVALUE else 0 end) kila_xima_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '4' then x.PURCHASESVALUE else 0 end) imerargia_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '4' then x.SALESVALUE else 0 end) imerargia_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '5' then x.PURCHASESVALUE else 0 end) adeia_xlm_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '5' then x.SALESVALUE else 0 end) adeia_xlm_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '6' then x.PURCHASESVALUE else 0 end) plasmatika_xlm_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '6' then x.SALESVALUE else 0 end) plasmatika_xlm_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '7' then x.PURCHASESVALUE else 0 end) stalia_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '7' then x.SALESVALUE else 0 end) stalia_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '8' then x.PURCHASESVALUE else 0 end) extra_cost_petrel_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '8' then x.SALESVALUE else 0 end) extra_cost_petrel_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '9' then x.PURCHASESVALUE else 0 end) kteo_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '9' then x.SALESVALUE else 0 end) kteo_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '10' then x.PURCHASESVALUE else 0 end) kostos_taxinomisis_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '10' then x.SALESVALUE else 0 end) kostos_taxinomisis_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '11' then x.PURCHASESVALUE else 0 end) kostos_stasewn_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '11' then x.SALESVALUE else 0 end) kostos_stasewn_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '12' then x.PURCHASESVALUE else 0 end) sinolika_xlm_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '12' then x.SALESVALUE else 0 end) sinolika_xlm_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '13' then x.PURCHASESVALUE else 0 end) fortoekfortika_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '13' then x.SALESVALUE else 0 end) fortoekfortika_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '14' then x.PURCHASESVALUE else 0 end) sinolo_kilwn_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '14' then x.SALESVALUE else 0 end) sinolo_kilwn_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '15' then x.PURCHASESVALUE else 0 end) sinolo_paletwn_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '15' then x.SALESVALUE else 0 end) sinolo_paletwn_inc
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '16' then x.PURCHASESVALUE else 0 end) exrta_cost_odigwn_exp
        ,sum(case when (x.codeid = '1' or (x.SALESCALC = 1 and x.ptype = 2)) and x.codeid = '16' then x.SALESVALUE else 0 end) exrta_cost_odigwn_inc   
        ,count(distinct final_route_id) route_counter
        ,count(distinct x.COMBINED_ID) combine_counter
        ,x.COST_CENTER
        ,x.SUPLIER_WID
        ,x.CUSTOMER_WID
        ,x.RECEIVER_WID
        ,x.TRAILER_WID
        ,x.TRANSPORTAION_WID
        ,x.ROUTE_DATE_WID
        ,x.MATERIAL_WID
        ,x.ROUTE_CATEGORY_WID
        ,x.ROUTE
        ,x.TRACTOR
        ,x.ROUTE_CUSID
        ,x.ROUTE_CUSTOMER
        ,x.EMAIL
        ,x.WEBROUTE
        ,x.WEBSTATUS
        ,x.EXECUTION_FLAG
        ,x.PARAGOGI
        ,x.POLISI
        ,x.DEPARTMENT
        ,x.SENDERS
        ,x.COMBINED_ID
        ,x.COMBINED_DATE
        ,x.COMBINED_ROUTE
        ,x.SENDER_WID
        ,x.GEODESC
        ,x.DOCUMENT_SOURCE
        ,x.FINAL_ROUTE_ID
        ,x.GROUPAGENUMBER
        ,x.RECEIVERS
        ,x.ROUTES
        ,x.GREEK_INVOICES
        ,x.GREEK_DUMMIES
        ,x.ORIGIN
        ,x.TRANSPORTATION_TYPE
        ,x.ASSET_TYPE
        ,sum(x.oil_qty) oil_qty
  from (
select x.INTEGRATION_ID
        ,x.DATASOURCE_NUM_ID
        ,x.W_UPDATE_DT
        ,x.W_INSERT_DT
        ,re.ptype
        ,re.codeid
        ,x.QUANTITYCALC
        ,x.PURCHASESCALC
        ,x.SALESCALC
        ,x.QUANTITYVALUE
        ,x.PURCHASESVALUE
        ,x.SALESVALUE
        ,x.SUPLIER_WID
        ,x.CUSTOMER_WID
        ,x.RECEIVER_WID
        ,x.TRAILER_WID
        ,x.TRANSPORTAION_WID
        ,x.ROUTE_DATE_WID
        ,x.MATERIAL_WID
        ,x.ROUTE_CATEGORY_WID
        ,x.ROUTE_EXP_WID
        ,x.ROUTE
        ,x.TRACTOR
        ,x.ROUTE_CUSID
        ,x.ROUTE_CUSTOMER
        ,x.EMAIL
        ,x.WEBROUTE
        ,x.WEBSTATUS
        ,x.EXECUTION_FLAG
        ,x.COST_CENTER
        ,x.PARAGOGI
        ,x.POLISI
        ,x.DEPARTMENT
        ,x.SENDERS
        ,x.COMBINED_ID
        ,x.COMBINED_DATE
        ,x.COMBINED_ROUTE
        ,x.SENDER_WID
        ,x.GEODESC
        ,x.DOCUMENT_SOURCE
        ,x.FINAL_ROUTE_ID
        ,x.GROUPAGENUMBER
        ,x.RECEIVERS
        ,x.ROUTES
        ,x.GREEK_INVOICES
        ,x.GREEK_DUMMIES
        ,x.ORIGIN
        ,x.TRANSPORTATION_TYPE
        ,x.ASSET_TYPE
        ,x.oil_qty
from wc_final_routes_exp_fs x
       ,wc_routeexpenses_d re
where x.ROUTE_EXP_WID = re.row_wid) x
group by x.DATASOURCE_NUM_ID
        ,x.COST_CENTER
        ,x.SUPLIER_WID
        ,x.CUSTOMER_WID
        ,x.RECEIVER_WID
        ,x.TRAILER_WID
        ,x.TRANSPORTAION_WID
        ,x.ROUTE_DATE_WID
        ,x.MATERIAL_WID
        ,x.ROUTE_CATEGORY_WID
        ,x.ROUTE
        ,x.TRACTOR
        ,x.ROUTE_CUSID
        ,x.ROUTE_CUSTOMER
        ,x.EMAIL
        ,x.WEBROUTE
        ,x.WEBSTATUS
        ,x.EXECUTION_FLAG
        ,x.PARAGOGI
        ,x.POLISI
        ,x.DEPARTMENT
        ,x.SENDERS
        ,x.COMBINED_ID
        ,x.COMBINED_DATE
        ,x.COMBINED_ROUTE
        ,x.SENDER_WID
        ,x.GEODESC
        ,x.DOCUMENT_SOURCE
        ,x.FINAL_ROUTE_ID
        ,x.GROUPAGENUMBER
        ,x.RECEIVERS
        ,x.ROUTES
        ,x.GREEK_INVOICES
        ,x.GREEK_DUMMIES
        ,x.ORIGIN
        ,x.TRANSPORTATION_TYPE
        ,x.ASSET_TYPE;


        x_return_status := g_success_status;
 end;

	--Run ETL

 PROCEDURE etl_run IS
    l_status varchar2(1);
 BEGIN

    --Load Dimensions
    dim_customer(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_customer: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_branch(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_branch: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_product(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_product: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_supplier(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_supplier: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_route_expense(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_route_expense: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_route_category(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_route_category: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_transportation(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_transportation: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	dim_trailer(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'dim_trailer: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

    --Load Staging Facts
    fact_final_routes_exp_rep(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_routes_exp_rep: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

    fact_final_routes_rec_rep(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_routes_rec_rep: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

    fact_final_routes_rep(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_routes_rep: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

    fact_final_routes_senders_rep(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_routes_senders_rep: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

    fact_final_routes_docs_rep(l_status);

     IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_routes_docs_rep: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;

	--Load Facts
	fact_final_route(l_status);

    IF l_status = g_error_status THEN

        ROLLBACK;

        raise_application_error(-20000, 'fact_final_route: '||sqlerrm);

    ELSE

        COMMIT;

    END IF;



 END; 

 END;