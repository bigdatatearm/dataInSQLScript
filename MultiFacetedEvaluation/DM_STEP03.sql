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

DELETE FROM DM_analysisDM_step03 WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step03
    (idx, appraisee_no, middle_model_index, quiz_no, data_val, distribution, sum_distribution)
    SELECT A.idx, A.appraisee_no, A.middle_model_index, A.quiz_no, A.sumData/B.sum_weight, A.distribution, A.sum_distribution FROM
    (SELECT A.idx, A.appraisee_no, A.middle_model_index, A.quiz_no, SUM(sumData) AS sumData, distribution, A.sum_distribution
        FROM( SELECT A.idx, A.appraisee_no, A.middle_model_index, A.quiz_no, A.data_val* B.DM_weight AS sumData, A.distribution , A.sum_distribution
                FROM DM_analysisDM_step02 A
                INNER JOIN DM_weight B ON A.idx = B.idx AND A.middle_model_index = B.middle_model_index AND A.appraiseeGrade = B.appraisee_grade
#변수
                WHERE A.idx = PROCESSINDEX
        ) A
    GROUP BY A.idx,  A.appraisee_no, A.middle_model_index,  A.quiz_no, A.distribution, A.sum_distribution)A
    INNER JOIN  (SELECT A.appraisee_no , A.middle_model_index,  SUM(B.DM_weight) AS sum_weight
                    FROM (SELECT appraisee_no, middle_model_index, appraiseeGrade FROM DM_analysisDM_step02
#변수
                        WHERE idx = PROCESSINDEX
                        GROUP BY appraisee_no, middle_model_index, appraiseeGrade)A
                    INNER JOIN (SELECT appraisee_grade, middle_model_index, DM_weight FROM DM_weight B
#변수
                                WHERE idx= PROCESSINDEX
                                )B ON A.middle_model_index = B.middle_model_index AND A.appraiseeGrade = B.appraisee_grade
                    group by A.appraisee_no , A.middle_model_index
                ) B ON A.appraisee_no = B.appraisee_no AND A.middle_model_index = B.middle_model_index
    ;

DELETE FROM DM_analysisDM_step03_middle_model WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step03_middle_model
    (idx, appraisee_no, middle_model_index, sum_data_val)
    SELECT idx, appraisee_no, middle_model_index, SUM(A.DATA)
        FROM(
            SELECT idx, appraisee_no, middle_model_index, data_val*distribution/sum_distribution AS DATA
            from DM_analysisDM_step03
#변수
            WHERE idx = PROCESSINDEX
            )A
        GROUP BY A.idx, A.appraisee_no, A.middle_model_index
;
END $$
DECLARE;
