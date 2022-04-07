USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP03;
DELIMITER $$
Create Procedure DM_STEP03(IN PROCESSINDEX INTEGER)
##### 평균값 구하기
##### 1.피평가자
##### 2.평가기준(1.상사 2.부하 3.동료 4.자신)
##### 3.중분류(EX. 핵심 리더쉽 업무역량)
##### 4.각문항 번호(선택된문항)
##### 6.문항별 값(평균) => 모든값 / 갯수
##### 7.배점
##### 8.중분류 총합
BEGIN

INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP03_START');

DELETE FROM DM_analysisDM_step03 WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step03
    (idx, appraisee_no, middle_model_index, quiz_no, data_val)
    (SELECT  PROCESSINDEX , appraisee_no, middle_model_index, quiz_no,SUM(data)/SUM(DM_weight)
        FROM (
                SELECT A.appraisee_no, A.middle_model_index, A.quiz_no, data_val * DM_weight AS data, DM_weight
                FROM (
                        SELECT appraisee_no, appraiseeGrade, middle_model_index, quiz_no, data_val
                        FROM DM_analysisDM_step02
                        WHERE idx = PROCESSINDEX
                      ) A
                          LEFT JOIN (
                     SELECT middle_model_index, appraisee_grade, DM_weight
                     FROM DM_weight
                     WHERE idx = PROCESSINDEX
                 ) B ON A.middle_model_index = B.middle_model_index AND A.appraiseeGrade = B.appraisee_grade
             )A GROUP BY appraisee_no,middle_model_index,quiz_no)
;

DELETE FROM DM_analysisDM_step03_middle_model WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step03_middle_model
    (idx, appraisee_no, middle_model_index, sum_data_val)
    (SELECT  PROCESSINDEX, appraisee_no, middle_model_index, SUM(data)/SUM(DM_weight)
        FROM(
            SELECT A.appraisee_no, A.middle_model_index, sum_data_val*DM_weight AS data, DM_weight
                FROM(
                    SELECT appraisee_no, appraiseeGrade, middle_model_index , sum_data_val FROM DM_analysisDM_step02_middle_model
                    WHERE idx = PROCESSINDEX
                ) A
                LEFT JOIN (
                    SELECT middle_model_index, appraisee_grade, DM_weight FROM  DM_weight
                    WHERE idx = PROCESSINDEX
                ) B  ON  A.middle_model_index = B.middle_model_index AND A.appraiseeGrade = B.appraisee_grade
            GROUP BY A.appraisee_no, A.middle_model_index, A.appraiseeGrade, sum_data_val, DM_weight
        )A GROUP BY appraisee_no,middle_model_index)
;

INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP02_END');

call DM_STEP04(PROCESSINDEX);
END $$
DECLARE;
