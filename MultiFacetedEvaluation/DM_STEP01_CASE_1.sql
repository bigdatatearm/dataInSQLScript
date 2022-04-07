USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP01_CASE_1;
DELIMITER $$
Create Procedure DM_STEP01_CASE_1(IN PROCESSINDEX INTEGER, IN DATAININDEX INTEGER)
BEGIN
    INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_CASE_1_START');

    INSERT INTO DM_analysisDM_step01
    (idx, data_no, quiz_no, data_val)
    SELECT PROCESSINDEX, A.data_no, quiz_no,
           CASE
                WHEN data_val IS NULL THEN -1
                WHEN data_val = ''    THEN -1
                ELSE CAST(data_val as INTEGER )
            END
        FROM wise_analysis_data A
        INNER JOIN (SELECT distinct data_no
            FROM wise_analysis_data A
            INNER JOIN DM_sample_case B on A.quiz_no = B.groupIdx and A.data_val = B.itemDetailsIndex
            WHERE A.analysis_idx = DATAININDEX
              AND B.idx = PROCESSINDEX) B on A.data_no = B.data_no
        WHERE A.analysis_idx = DATAININDEX;

    INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_CASE_1_END');
END $$
DECLARE;

