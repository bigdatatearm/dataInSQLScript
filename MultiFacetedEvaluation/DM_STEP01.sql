USE dataIn;
DROP PROCEDURE IF EXISTS DM_STEP01;
DELIMITER $$
Create Procedure DM_STEP01()
#평가자 기준
#CASE 갯수에 맞는 데이터 1차 데이터 정제
#CASE 갯수는 최대 2개이며
#CASE갯수 : 0 => 모든데이터 가져옴   DM_STEP01_CASE_0
#CASE갯수 : 1 => INNER JOIN을 이용하여 가져옴   DM_STEP01_CASE_1
#CASE갯수 : 2 => 이중 INNER JOIN을 이용하여 가져옴   DM_STEP01_CASE_2
#
#이슈
#mariaDB 에서 wwith as 문과 insert문을 동시에 사용 할수 없음
BEGIN
   DECLARE PROCESSINDEX INTEGER;
   DECLARE DATAININDEX INTEGER;
   DECLARE CASECOUNT INTEGER;
select * from analysis_report;
   SELECT  idx
        ,  dataInIdx
   INTO PROCESSINDEX, DATAININDEX FROM analysis_report
   WHERE analysis_type = 'DM' AND stCode ='ED' ORDER BY updateTime LIMIT  1;

   UPDATE analysis_report SET stCode ='PS' WHERE idx = PROCESSINDEX;

   INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_START');

   DELETE FROM DM_analysisDM_step01 WHERE idx = PROCESSINDEX;

   SELECT  count(distinct groupIdx) into CASECOUNT FROM DM_sample_case
   WHERE idx = PROCESSINDEX;
   IF CASECOUNT = 2 THEN
       call DM_STEP01_CASE_2(PROCESSINDEX, DATAININDEX);
   ELSEIF CASECOUNT = 1 THEN
       call DM_STEP01_CASE_1(PROCESSINDEX, DATAININDEX);
   ELSE
       call DM_STEP01_CASE_0(PROCESSINDEX, DATAININDEX);
   END IF;

   INSERT INTO DM_log (idx, log) VALUE (PROCESSINDEX, 'DM_STEP01_END');

   call DM_STEP02(PROCESSINDEX);
END $$
DECLARE;
