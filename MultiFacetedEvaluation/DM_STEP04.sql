USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP04;
DELIMITER $$
Create Procedure DM_STEP04(IN PROCESSINDEX INTEGER)
##### 집단구분 구하기
BEGIN
   DECLARE MARYMONDYUM INTEGER;

INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP04_START');

# 설정 select 작업 필요
# 피평가자
SELECT DM_option.MARYMONDYUM
INTO MARYMONDYUM
FROM DM_option WHERE idx = PROCESSINDEX;

DELETE FROM DM_analysisDM_step04_appraisee_no WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step04_appraisee_no
    (idx, groupIdx, itemIdx, itemIdxValue, appraisee_no)
    SELECT PROCESSINDEX
           ,B.groupIdx
           ,B.itemIdx
           ,A.data_val
           ,C.data_val
           FROM DM_analysisDM_step01 A
           INNER JOIN DM_group B ON A.idx = B.idx AND A.quiz_no = B.itemIdx
#변수 PROCESSINDEX
           INNER JOIN(SELECT data_no, data_val FROM DM_analysisDM_step01
#변수 PROCESSINDEX
           WHERE idx = PROCESSINDEX
#피평가자 2 MARYMONDYUM
                AND quiz_no = MARYMONDYUM)C ON A.data_no = C.data_no
           WHERE A.idx = PROCESSINDEX
           group by B.itemIdx,B.groupIdx,C.data_val;

DELETE FROM DM_analysisDM_step04 WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step04
   (idx, appraisee_no, groupIdx, itemIdx, itemIdxValue, middle_model_index, quiz_no, data_val )
   SELECT PROCESSINDEX
         ,A.appraisee_no
         ,A.groupIdx
         ,A.itemIdx
         ,A.itemIdxValue
         ,B.middle_model_index
         ,B.quiz_no
         ,B.data_val
         FROM DM_analysisDM_step04_appraisee_no A
         INNER JOIN DM_analysisDM_step03 B ON A.idx = B.idx AND A.appraisee_no = B.appraisee_no
#변수
         WHERE A.idx = PROCESSINDEX
         GROUP BY  A.groupIdx, A.appraisee_no, A.itemIdx, A.itemIdxValue, B.quiz_no;

DELETE FROM DM_analysisDM_step04_middle_model WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step04_middle_model
    (idx, appraisee_no, groupIdx, itemIdx, itemIdxValue, middle_model_index, sum_data_val)
    SELECT PROCESSINDEX, A.appraisee_no, B.groupIdx, B.itemIdx, B.itemIdxValue, A.middle_model_index, A.sum_data_val
        FROM( SELECT appraisee_no, middle_model_index, sum_data_val FROM DM_analysisDM_step03_middle_model WHERE idx =PROCESSINDEX )A
        INNER JOIN ( SELECT groupIdx, itemIdx, itemIdxValue, appraisee_no FROM DM_analysisDM_step04_appraisee_no WHERE idx =PROCESSINDEX )B
        ON A.appraisee_no = B.appraisee_no

;

INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP04_END');

UPDATE analysis_report SET stCode ='PE' WHERE idx = PROCESSINDEX;

END $$
DECLARE;