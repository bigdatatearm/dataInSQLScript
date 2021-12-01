USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP01_CASE_0;
DELIMITER $$
Create Procedure DM_STEP01_CASE_0(IN PROCESSINDEX INTEGER, IN DATAININDEX INTEGER)
BEGIN
    INSERT INTO DM_analysisDM_step01
    (idx, data_no, quiz_no, data_val)
    SELECT PROCESSINDEX, data_no, quiz_no,
           CASE
                WHEN data_val IS NULL THEN -1
                WHEN data_val = ''    THEN -1
                ELSE CAST(data_val as INTEGER )
            END
        FROM wise_analysis_data
        WHERE analysis_idx = DATAININDEX;
END $$
DECLARE;

