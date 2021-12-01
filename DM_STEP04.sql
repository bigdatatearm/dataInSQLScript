USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP04;
DELIMITER $$
Create Procedure DM_STEP04(IN PROCESSINDEX INTEGER)
##### 집단구분 구하기
BEGIN
   DECLARE MARYMONDYUM INTEGER;

# 설정 select 작업 필요
# 피평가자
   SET MARYMONDYUM = 2;

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
   (idx, groupIdx, itemIdx, itemIdxValue, middle_model_index, quiz_no, data_val, distribution, sum_distribution )
   SELECT PROCESSINDEX
         ,A.groupIdx
         ,A.itemIdx
         ,A.itemIdxValue
         ,B.middle_model_index
         ,B.quiz_no
         ,SUM(data_val)/COUNT(*)
         ,B.distribution
         ,B.sum_distribution
         FROM DM_analysisDM_step04_appraisee_no A
         INNER JOIN DM_analysisDM_step03 B ON A.idx = B.idx AND A.appraisee_no = B.appraisee_no
#변수
         WHERE A.idx = PROCESSINDEX
         GROUP BY  A.groupIdx, A.itemIdx, A.itemIdxValue, B.quiz_no, B.distribution, B.sum_distribution;

DELETE FROM DM_analysisDM_step04_middle_model WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step04_middle_model
    (idx, groupIdx, itemIdx, itemIdxValue, middle_model_index, sum_data_val)
    SELECT idx, groupIdx, itemIdx, itemIdxValue, middle_model_index, SUM(A.DATA)
        FROM(
            SELECT idx, groupIdx, itemIdx, itemIdxValue, middle_model_index, data_val*distribution/sum_distribution AS DATA
            from DM_analysisDM_step04
#변수
            WHERE idx = PROCESSINDEX
            )A
        GROUP BY A.idx, A.groupIdx, A.itemIdx, A.itemIdxValue, A.middle_model_index
;

END $$
DECLARE;