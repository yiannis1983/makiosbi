create or replace PACKAGE etl_pkg AS

	--Load Dimensions
	PROCEDURE dim_customer(x_return_status out varchar2);

	PROCEDURE dim_branch(x_return_status out varchar2);

	PROCEDURE dim_product(x_return_status out VARCHAR2);

	PROCEDURE dim_supplier(x_return_status out varchar2);

	PROCEDURE dim_route_expense(x_return_status out varchar2);

	PROCEDURE dim_route_category(x_return_status out VARCHAR2);

	PROCEDURE dim_transportation(x_return_status out VARCHAR2);

	PROCEDURE dim_trailer(x_return_status out varchar2);

    --Load Staging Facts
    PROCEDURE fact_final_routes_exp_rep(x_return_status out varchar2);

    PROCEDURE fact_final_routes_rec_rep(x_return_status out varchar2);

    PROCEDURE fact_final_routes_rep(x_return_status out varchar2);

    PROCEDURE fact_final_routes_senders_rep(x_return_status OUT VARCHAR2);

    PROCEDURE fact_final_routes_docs_rep(x_return_status OUT VARCHAR2); 

	--Load Facts
	PROCEDURE fact_final_route(x_return_status out varchar2);

	--Run ETL
	PROCEDURE etl_run;


END;