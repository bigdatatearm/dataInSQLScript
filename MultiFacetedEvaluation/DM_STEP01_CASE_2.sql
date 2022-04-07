USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP01_CASE_2;
DELIMITER $$
Create Procedure DM_STEP01_CASE_2(IN PROCESSINDEX INTEGER, IN DATAININDEX INTEGER)
BEGIN
    INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_CASE_2_START');

    INSERT INTO DM_analysisDM_step01
    (idx, data_no, quiz_no, data_val)
    SELECT PROCESSINDEX, A.data_no, quiz_no,
           CASE
                WHEN data_val IS NULL THEN -1
                WHEN data_val = ''    THEN -1
                ELSE CAST(data_val as INTEGER )
            END
        FROM wise_analysis_data A
        INNER JOIN (
            SELECT distinct A1111.data_no FROM
                #CASE 1 DATA_NO 값###########################################################################################################################################################
                (SELECT distinct data_no
                FROM wise_analysis_data A111
                INNER JOIN(SELECT A11.groupIdx, A11.itemDetailsIndex
                        FROM DM_sample_case A11
                        INNER JOIN
                            (SELECT idx,
                                    groupIdx
                                FROM(
                                    SELECT idx,
                                           groupIdx
                                        FROM

                            #변수
                                        WHERE idx = PROCESSINDEX
                                        GROUP BY groupIdx
                                        ORDER BY groupIdx
                                    )A1
                            limit  1)B11 ON A11.groupIdx = B11.groupIdx AND A11.idx = B11.idx)B111 ON A111.quiz_no = B111.groupIdx AND A111.data_val = B111.itemDetailsIndex
                #변수
                WHERE A111.analysis_idx = DATAININDEX)A1111
                #CASE 2 DATA_NO 값###########################################################################################################################################################
                INNER JOIN(SELECT distinct data_no
                FROM wise_analysis_data A111
                INNER JOIN(SELECT A11.groupIdx, A11.itemDetailsIndex
                        FROM DM_sample_case A11
                        INNER JOIN
                            (SELECT idx,
                                    groupIdx
                                FROM(
                                    SELECT idx,
                                           groupIdx
                                        FROM DM_sample_case
                            #변수
                                        WHERE idx = PROCESSINDEX
                                        GROUP BY groupIdx
                                    )A1
                            limit  1, 1)B11 ON A11.groupIdx = B11.groupIdx AND A11.idx = B11.idx)B111 ON A111.quiz_no = B111.groupIdx AND A111.data_val = B111.itemDetailsIndex
                #변수
                WHERE A111.analysis_idx = DATAININDEX)B1111
                ON A1111.data_no = B1111.data_no
            ) B on A.data_no = B.data_no
        WHERE A.analysis_idx = DATAININDEX;

    INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_CASE_2_END');
END $$
DECLARE;