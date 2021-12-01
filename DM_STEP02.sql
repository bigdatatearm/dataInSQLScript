USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP02;
DELIMITER $$
Create Procedure DM_STEP02(IN PROCESSINDEX INTEGER)
##### 평균값 구하기
##### 1.피평가자
##### 2.평가기준(1.상사 2.부하 3.동료 4.자신)
##### 3.중분류(EX. 핵심 리더쉽 업무역량)
##### 4.각문항 번호(선택된문항)
##### 6.문항별 값(평균) => 모든값 / 갯수
##### 7.배점
##### 8.중분류 총합
BEGIN
   DECLARE APPRAISER INTEGER;
   DECLARE MARYMONDYUM INTEGER;
   DECLARE 100YN INTEGER;
   DECLARE indexValue INTEGER;

# 설정 select 작업 필요
# 평가자
   SET APPRAISER = 3;
# 피평가자
   SET MARYMONDYUM = 2;
# 점변환
   SET 100YN = 1;
# 척도최대값
   SET indexValue = 5;



DELETE FROM DM_analysisDM_step02 WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step02
    (idx, appraisee_no, appraiseeGrade, middle_model_index, quiz_no, data_val, distribution, sum_distribution)
    SELECT PROCESSINDEX,
           appraisee,
           appraiseeGrade,
           middle_model_index,
           quiz_no,
           SUM(data_val)/SUM(cnt) AS value,
           distribution,
           sum_distribution
    #################################
        FROM(SELECT C.data_val AS appraisee, A.data_no,
                                                B.data_val AS appraiseeGrade,
                                                D.middle_model_index,
                                                A.quiz_no,
                                                A.data_val,
                                                A.cnt,
                                                D.distribution,
                                                D.sum_distribution
            FROM
                 (SELECT data_no, quiz_no,  IF(data_val >0 , data_val, 0) AS  data_val,  IF(data_val >0 , 1, 0) AS cnt
                 FROM DM_analysisDM_step01
                             WHERE
#변수
                                idx = PROCESSINDEX) A
            #B - 변수 평가자 구분######################
            INNER JOIN(SELECT data_val,#평가자 구분 (1-상사 2-부하 3-동료 4-자신)
                              data_no
                            FROM DM_analysisDM_step01
                             WHERE
#변수
                                idx = PROCESSINDEX
#변수 평가자 구분
                                and quiz_no = APPRAISER) B ON A.data_no = B.data_no
            #B끝 - 변수 평가자 구분######################
            #C - 피평가자 구분######################
            INNER JOIN(SELECT data_no, data_val FROM DM_analysisDM_step01
#변수
                    WHERE idx = PROCESSINDEX
#피평가자 2
                    AND quiz_no = MARYMONDYUM)C ON A.data_no = C.data_no
            #C끝 - 피평가자 구분######################
            #D - 중분류 인덱스 및 배점, 배점합 ######################
            INNER JOIN(SELECT A.middle_model_index, A.appraisee_grade, A.quiz_no, A.distribution, B.sum_distribution FROM DM_middle_model_sub A
                            LEFT JOIN (SELECT middle_model_index, appraisee_grade, SUM(distribution) AS sum_distribution
                                        FROM DM_middle_model_sub
                                        WHERE
#변수
                                        idx = PROCESSINDEX
                                        GROUP BY middle_model_index, appraisee_grade)B ON A.middle_model_index = B.middle_model_index AND A.appraisee_grade = B.appraisee_grade
#변수
                        WHERE idx = PROCESSINDEX
                        )D ON A.quiz_no = D.quiz_no AND  B.data_val = D.appraisee_grade
               #D끝 - 중분류 인덱스 및 배점, 배점합 ######################
                )A
    WHERE A.cnt = 1
     GROUP BY  appraisee,
            appraiseeGrade,
            middle_model_index,
            quiz_no,
            distribution,
            sum_distribution
    ;


#100 점 변환
IF 100YN = 1 THEN
    UPDATE DM_analysisDM_step02
        SET data_val = (data_val - 1)/(indexValue-1)*100
       WHERE idx = PROCESSINDEX;
END IF;


DELETE FROM DM_analysisDM_step02_middle_model WHERE idx = PROCESSINDEX;

INSERT INTO DM_analysisDM_step02_middle_model
    (idx, appraisee_no, appraiseeGrade, middle_model_index, sum_data_val)
    SELECT idx, appraisee_no, appraiseeGrade, middle_model_index, SUM(A.DATA)
        FROM(
            SELECT idx, appraisee_no, appraiseeGrade, middle_model_index, data_val*distribution/sum_distribution AS DATA
            from DM_analysisDM_step02
#변수
            WHERE idx = PROCESSINDEX
            )A
        GROUP BY A.idx, A.appraisee_no, A.appraiseeGrade, A.middle_model_index
;
END $$
DECLARE;