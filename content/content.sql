-- 코드봄바 초기 콘텐츠. content/build_content.py 가 생성한다. 직접 고치지 말 것.
-- 여러 번 실행해도 같은 결과가 된다 (ON DUPLICATE KEY UPDATE).
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO problem_category (category_id, category_name, description, status) VALUES
(3001, '정처기 프로그래밍 언어', '정보처리기사 실기의 파이썬 출력 예측, 기초 코딩, 알고리즘 구현 문제 분야입니다.', 'ACTIVE'),
(3002, '정처기 SQL', '정보처리기사 실기의 SELECT, GROUP BY, JOIN 등 SQL 작성 문제 분야입니다.', 'ACTIVE'),
(3003, '정처기 핵심 이론', '응집도, 결합도, OSI 7계층, 정규화 등 반복 출제되는 핵심 용어 문제 분야입니다.', 'ACTIVE'),
(3004, 'pandas 데이터 분석', 'CSV 데이터를 pandas로 불러와 크기 확인, 필터링, 그룹 집계를 연습하는 분야입니다.', 'ACTIVE')
ON DUPLICATE KEY UPDATE category_name = VALUES(category_name), description = VALUES(description), status = VALUES(status);

INSERT INTO course (course_id, instructor_id, course_category_id, title, description, thumbnail_url, status, created_at, updated_at) VALUES
(2000, 8, 1002, '정보처리기사 실기 대비: 파이썬 프로그래밍', '정보처리기사 실기의 프로그래밍 언어 활용 영역을 파이썬으로 준비합니다. 출력 결과 예측부터 기초 알고리즘 구현까지 단계별로 연습합니다.', 'https://placehold.co/640x360?text=Python+for+Exam', 'ACTIVE', NOW(), NOW()),
(2001, 8, 1003, '정보처리기사 실기 대비: SQL과 핵심 이론', 'SELECT, GROUP BY, JOIN 등 SQL 작성 문제와 응집도, 결합도, OSI 7계층 같은 단골 이론을 함께 정리합니다.', 'https://placehold.co/640x360?text=SQL+and+Theory', 'ACTIVE', NOW(), NOW()),
(2002, 8, 1000, '처음 시작하는 pandas 데이터 분석', 'Python pandas로 CSV 데이터를 불러오고, 기본 탐색과 그룹 집계까지 실습하는 입문 강좌입니다.', 'https://placehold.co/640x360?text=Pandas+Data+Analysis', 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE instructor_id = VALUES(instructor_id), course_category_id = VALUES(course_category_id), title = VALUES(title), description = VALUES(description), thumbnail_url = VALUES(thumbnail_url), status = VALUES(status), updated_at = VALUES(updated_at);

INSERT INTO lecture (lecture_id, course_id, lecture_order, title, description, video_url, problem_category_id, status, created_at, updated_at) VALUES
(2101, 2000, 1, '정처기 실기, 어디부터 어떻게 공부할까', '실기 시험의 출제 경향과 과목별 학습 전략을 먼저 잡습니다.', 'https://www.youtube.com/watch?v=GwFUPOH4K2s', 3001, 'ACTIVE', NOW(), NOW()),
(2102, 2000, 2, '실기 핵심 정리: Python', '실기에 나오는 파이썬 문법을 핵심만 정리합니다. 수강 후 출력 결과 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=DkgiPJczxJk', 3001, 'ACTIVE', NOW(), NOW()),
(2103, 2000, 3, '파이썬, 정확히 알아야 합격한다', '객체, 리스트 등 헷갈리기 쉬운 파이썬 개념을 짚습니다. 수강 후 기초 코딩 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=PY5W1tDSpN0', 3001, 'ACTIVE', NOW(), NOW()),
(2104, 2000, 4, '기출문제 코드 해설', '실제 기출 코드를 한 줄씩 따라가며 해설합니다. 수강 후 알고리즘 구현 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=57xTwjIs8lg', 3001, 'ACTIVE', NOW(), NOW()),
(2111, 2001, 1, 'SQL 기본 문법: SELECT ~ FROM ~ WHERE', 'SELECT 문의 기본 형식과 조건 검색을 배웁니다.', 'https://www.youtube.com/watch?v=_JURyg_KzHE', 3002, 'ACTIVE', NOW(), NOW()),
(2112, 2001, 2, 'ORDER BY와 GROUP BY', '정렬과 그룹 집계를 배웁니다.', 'https://www.youtube.com/watch?v=6qkPy7RfLqQ', 3002, 'ACTIVE', NOW(), NOW()),
(2113, 2001, 3, '두 테이블을 묶는 JOIN', 'INNER JOIN, OUTER JOIN 등 조인을 배웁니다. 수강 후 SQL 작성 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=tuQFkzjqEGw', 3002, 'ACTIVE', NOW(), NOW()),
(2114, 2001, 4, '5분 특강: OSI 7계층', '자주 출제되는 OSI 7계층을 짧게 정리합니다. 수강 후 핵심 용어 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=66lp--WeGpc', 3003, 'ACTIVE', NOW(), NOW()),
(2115, 2001, 5, '시험장 가기 전 꼭 알아야 할 5가지', '실기 시험 직전에 점검할 내용을 정리합니다.', 'https://www.youtube.com/watch?v=03SCIdM-IBs', 3003, 'ACTIVE', NOW(), NOW()),
(2121, 2002, 1, '파이썬 데이터 분석 한 번에 훑어보기', 'pandas와 시각화의 전체 흐름을 한 영상으로 살펴봅니다.', 'https://www.youtube.com/watch?v=PjhlUzp_cU0', 3004, 'ACTIVE', NOW(), NOW()),
(2122, 2002, 2, 'DataFrame과 Series 기초', '행과 열을 선택하는 방법과 DataFrame의 구조를 익힙니다. 수강 후 카페 주문 데이터 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=zmdjNSmRXF4', 3004, 'ACTIVE', NOW(), NOW()),
(2123, 2002, 3, '그룹화와 집계', 'groupby로 데이터를 묶고 합계와 평균을 계산합니다. 수강 후 쇼핑몰 주문 데이터 문제를 풀어 보세요.', 'https://www.youtube.com/watch?v=txMdrV1Ut64', 3004, 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id), lecture_order = VALUES(lecture_order), title = VALUES(title), description = VALUES(description), video_url = VALUES(video_url), problem_category_id = VALUES(problem_category_id), status = VALUES(status), updated_at = VALUES(updated_at);

INSERT INTO problem_set (problem_set_id, category_id, title, description, difficulty, status, total_problem_count, completed_user_count, started_user_count, created_by, created_at) VALUES
(4001, 3001, '정처기 실기: 파이썬 출력 결과 맞히기', '정보처리기사 실기에 자주 나오는 파이썬 코드의 실행 결과를 예측합니다. 슬라이싱, 리스트, 집합, 반복문, 함수를 다룹니다.', 'EASY', 'ACTIVE', 5, 0, 0, 8, NOW()),
(4002, 3001, '정처기 실기: 파이썬 기초 코딩', '반복문, 조건문, 리스트, 문자열, 딕셔너리를 이용해 짧은 함수를 직접 작성합니다.', 'EASY', 'ACTIVE', 5, 0, 0, 8, NOW()),
(4003, 3001, '정처기 실기: 기초 알고리즘 구현', '최대공약수, 소수 판별, 진법 변환, 정렬, 피보나치처럼 정처기 단골 알고리즘을 함수로 구현합니다.', 'MEDIUM', 'ACTIVE', 5, 0, 0, 8, NOW()),
(4004, 3002, '정처기 실기: SQL 작성', '학생, 수강 테이블을 대상으로 WHERE, ORDER BY, GROUP BY, HAVING, JOIN을 사용하는 SELECT 문을 작성합니다.', 'EASY', 'ACTIVE', 5, 0, 0, 8, NOW()),
(4005, 3003, '정처기 핵심 이론: 용어 단답', '응집도, 결합도, OSI 7계층, 트랜잭션, 정규화처럼 필기와 실기에 반복 출제되는 핵심 용어를 단답형으로 확인합니다.', 'EASY', 'ACTIVE', 5, 0, 0, 8, NOW()),
(4006, 3004, '카페 주문 데이터로 시작하는 pandas', '카페 주문 400건으로 DataFrame의 크기 확인, 고유값 세기, 그룹 집계, 파생 계산을 연습합니다.', 'EASY', 'ACTIVE', 4, 0, 0, 8, NOW()),
(4007, 3004, '온라인 쇼핑몰 주문 데이터 매출 분석', '쇼핑몰 주문 600건으로 조건 필터링, 파생 컬럼 만들기, 카테고리별 집계를 연습합니다.', 'EASY', 'ACTIVE', 4, 0, 0, 8, NOW())
ON DUPLICATE KEY UPDATE category_id = VALUES(category_id), title = VALUES(title), description = VALUES(description), difficulty = VALUES(difficulty), status = VALUES(status), total_problem_count = VALUES(total_problem_count), created_by = VALUES(created_by);

INSERT INTO problem (problem_id, problem_set_id, title, content, problem_type, difficulty, explanation, point, attempt_limit, is_retriable, status, problem_order) VALUES
(5011, 4001, '문자열 슬라이싱', '다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.

[코드]
a = "REMEMBER NOVEMBER"
b = a[:3] + a[12:16]
c = "R AND %s" % "STR"
print(b + c)

[제출 방법]
출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.
코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.', 'CODE', 'EASY', '슬라이싱 a[시작:끝]은 끝 인덱스를 포함하지 않습니다. a[:3]은 REM, a[12:16]은 EMBE이고, 포맷 문자열 결과 R AND STR을 이어 붙입니다.

출력 결과: REMEMBER AND STR

[모범 답안]
result = ''REMEMBER AND STR''', 10, 999, 1, 'ACTIVE', 1),
(5012, 4001, '리스트와 map', '다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.

[코드]
a = [1, 2, 3, 4, 5]
a = list(map(lambda num: num + 100, a))
print(a)

[제출 방법]
출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.
코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.', 'CODE', 'EASY', 'map(함수, 리스트)는 각 요소에 함수를 적용한 결과를 만들고, list()로 다시 리스트로 바꿉니다. 리스트 출력 형식은 [값, 값, ...] 입니다.

출력 결과: [101, 102, 103, 104, 105]

[모범 답안]
result = ''[101, 102, 103, 104, 105]''', 10, 999, 1, 'ACTIVE', 2),
(5013, 4001, '집합(set) 연산', '다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.

[코드]
asia = {''한국'', ''중국'', ''일본''}
asia.add(''베트남'')
asia.add(''중국'')
asia.remove(''일본'')
asia.update({''홍콩'', ''한국'', ''태국''})
print(len(asia))

[제출 방법]
출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.
코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.', 'CODE', 'EASY', '집합은 중복을 저장하지 않습니다. 한국, 중국, 베트남에 홍콩과 태국이 더해져 5개가 됩니다. 중국과 한국은 이미 있어 추가되지 않습니다.

출력 결과: 5

[모범 답안]
result = ''5''', 10, 999, 1, 'ACTIVE', 3),
(5014, 4001, '반복문과 조건문', '다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.

[코드]
total = 0
for i in range(1, 11):
    if i % 3 == 0:
        total += i
print(total)

[제출 방법]
출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.
코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.', 'CODE', 'EASY', 'range(1, 11)은 끝값 11을 포함하지 않아 1~10을 순회합니다. 3으로 나눈 나머지가 0인 3, 6, 9만 더해집니다.

출력 결과: 18

[모범 답안]
result = ''18''', 10, 999, 1, 'ACTIVE', 4),
(5015, 4001, '함수의 기본 매개변수', '다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.

[코드]
def func(num1, num2=2):
    print(''a ='', num1, ''b ='', num2)

func(20)

[제출 방법]
출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.
코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.', 'CODE', 'EASY', 'num2를 생략하면 기본값 2가 쓰입니다. print는 쉼표로 구분한 값 사이에 공백을 넣어 출력합니다.

출력 결과: a = 20 b = 2

[모범 답안]
result = ''a = 20 b = 2''', 10, 999, 1, 'ACTIVE', 5),
(5021, 4002, '1부터 n까지의 합', '정수 n이 주어질 때 1부터 n까지의 합을 반환하는 함수를 작성하세요.
예) n이 10이면 55

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(n):
    ...', 'CODE', 'EASY', 'range의 끝값은 포함되지 않으므로 n + 1까지 지정합니다. sum(range(1, n + 1))로도 구할 수 있습니다.

[모범 답안]
def solution(n):
    total = 0
    for i in range(1, n + 1):
        total += i
    return total', 10, 999, 1, 'ACTIVE', 1),
(5022, 4002, '짝수만 골라내기', '정수 리스트 nums가 주어질 때, 짝수만 원래 순서대로 담은 리스트를 반환하는 함수를 작성하세요.
예) [1, 2, 3, 4, 6] 이면 [2, 4, 6]

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(nums):
    ...', 'CODE', 'EASY', '나머지 연산자 %로 짝수를 판별하고 append로 모읍니다. 리스트 컴프리헨션 [n for n in nums if n % 2 == 0]도 같은 결과입니다.

[모범 답안]
def solution(nums):
    result = []
    for n in nums:
        if n % 2 == 0:
            result.append(n)
    return result', 10, 999, 1, 'ACTIVE', 2),
(5023, 4002, '문자열 뒤집기', '문자열 s가 주어질 때 글자 순서를 거꾸로 뒤집은 문자열을 반환하는 함수를 작성하세요.
예) "python" 이면 "nohtyp"

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(s):
    ...', 'CODE', 'EASY', '슬라이싱의 세 번째 값은 간격입니다. s[::-1]은 끝에서부터 한 글자씩 읽어 뒤집힌 문자열을 만듭니다.

[모범 답안]
def solution(s):
    return s[::-1]', 10, 999, 1, 'ACTIVE', 3),
(5024, 4002, '최댓값과 최솟값의 차', '정수 리스트 nums가 주어질 때 가장 큰 값과 가장 작은 값의 차를 반환하는 함수를 작성하세요. nums에는 값이 하나 이상 들어 있습니다.
예) [3, 9, 1, 7] 이면 8

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(nums):
    ...', 'CODE', 'EASY', 'max와 min은 리스트에서 가장 큰 값과 작은 값을 돌려줍니다. 값이 하나뿐이면 차는 0입니다.

[모범 답안]
def solution(nums):
    return max(nums) - min(nums)', 10, 999, 1, 'ACTIVE', 4),
(5025, 4002, '글자별 등장 횟수 세기', '문자열 s가 주어질 때 각 글자가 몇 번 나오는지 딕셔너리로 반환하는 함수를 작성하세요.
예) "banana" 이면 {"b": 1, "a": 3, "n": 2}

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(s):
    ...', 'CODE', 'MEDIUM', '딕셔너리의 get(키, 기본값)을 쓰면 처음 나온 글자도 오류 없이 셀 수 있습니다. 대문자와 소문자는 서로 다른 글자입니다.

[모범 답안]
def solution(s):
    counts = {}
    for ch in s:
        counts[ch] = counts.get(ch, 0) + 1
    return counts', 15, 999, 1, 'ACTIVE', 5),
(5031, 4003, '최대공약수 구하기', '양의 정수 a, b의 최대공약수를 반환하는 함수를 작성하세요.
예) 12와 18의 최대공약수는 6

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(a, b):
    ...', 'CODE', 'EASY', '유클리드 호제법은 gcd(a, b) = gcd(b, a % b) 성질을 이용합니다. 나머지가 0이 되면 그때의 a가 최대공약수입니다.

[모범 답안]
def solution(a, b):
    while b != 0:
        a, b = b, a % b
    return a', 10, 999, 1, 'ACTIVE', 1),
(5032, 4003, '소수 판별하기', '정수 n이 소수이면 True, 아니면 False를 반환하는 함수를 작성하세요. 1 이하의 수는 소수가 아닙니다.
예) 7은 True, 9는 False

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(n):
    ...', 'CODE', 'MEDIUM', '2부터 차례로 나누어 보며 약수가 있는지 확인합니다. 약수는 제곱근 이하에서 반드시 하나 발견되므로 제곱근까지만 검사해도 됩니다. 1과 0은 소수가 아닙니다.

[모범 답안]
def solution(n):
    if n < 2:
        return False
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0:
            return False
    return True', 15, 999, 1, 'ACTIVE', 2),
(5033, 4003, '10진수를 2진수로 바꾸기', '0 이상의 정수 n을 2진수 문자열로 바꿔 반환하는 함수를 작성하세요.
예) 10 이면 "1010", 0 이면 "0"

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(n):
    ...', 'CODE', 'MEDIUM', '2로 나눈 나머지를 앞쪽에 붙여 가며 몫이 0이 될 때까지 반복합니다. 내장 함수 bin(n)[2:]로도 같은 결과를 얻을 수 있습니다.

[모범 답안]
def solution(n):
    if n == 0:
        return "0"
    digits = ""
    while n > 0:
        digits = str(n % 2) + digits
        n //= 2
    return digits', 15, 999, 1, 'ACTIVE', 3),
(5034, 4003, '오름차순 정렬하기', '정수 리스트 nums를 오름차순으로 정렬한 새 리스트를 반환하는 함수를 작성하세요.
예) [5, 2, 9, 1] 이면 [1, 2, 5, 9]
버블 정렬을 직접 구현해 보는 것을 권장합니다.

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(nums):
    ...', 'CODE', 'MEDIUM', '버블 정렬은 이웃한 값을 비교하고 교환하는 과정을 반복합니다. 바깥 반복이 한 번 끝날 때마다 뒤쪽 자리가 하나씩 확정됩니다. 시간 복잡도는 O(n²)입니다.

[모범 답안]
def solution(nums):
    arr = list(nums)
    n = len(arr)
    for i in range(n - 1):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr', 15, 999, 1, 'ACTIVE', 4),
(5035, 4003, '피보나치 수 구하기', '피보나치 수열은 1, 1, 2, 3, 5, 8, ... 처럼 앞의 두 수를 더해 만듭니다. n번째 피보나치 수를 반환하는 함수를 작성하세요.
예) n이 1이면 1, n이 6이면 8

[제출 방법]
아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.

def solution(n):
    ...', 'CODE', 'MEDIUM', 'a, b = b, a + b 로 두 변수를 동시에 갱신하면 임시 변수 없이 다음 항으로 넘어갈 수 있습니다. 재귀로도 풀 수 있지만 반복문이 훨씬 빠릅니다.

[모범 답안]
def solution(n):
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return a', 15, 999, 1, 'ACTIVE', 5),
(5041, 4004, '조건에 맞는 행 조회 (WHERE)', '학생 테이블에서 학과가 ''컴퓨터공학''인 학생의 이름과 점수를 조회하는 SQL을 작성하세요. 컬럼 순서는 이름, 점수입니다.

[학생 테이블]
학번 | 이름 | 학과 | 학년 | 점수
1001 | 김민준 | 컴퓨터공학 | 3 | 88
1002 | 이서연 | 컴퓨터공학 | 2 | 95
1003 | 박지호 | 전자공학 | 4 | 72
1004 | 최유진 | 전자공학 | 1 | 81
1005 | 정하준 | 경영학 | 2 | 67
1006 | 강서윤 | 경영학 | 3 | 79
1007 | 조은우 | 컴퓨터공학 | 1 | 76
1008 | 윤지아 | 통계학 | 4 | 91

[수강 테이블]
학번 | 과목명 | 학점
1001 | 데이터베이스 | 3
1001 | 운영체제 | 3
1002 | 데이터베이스 | 3
1003 | 회로이론 | 3
1005 | 회계원리 | 3
1007 | 자료구조 | 3
1008 | 데이터베이스 | 3
1008 | 통계학개론 | 2

[제출 방법]
SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"
작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.', 'CODE', 'EASY', 'SELECT 뒤에 조회할 컬럼을, WHERE 뒤에 조건을 씁니다. 문자열 리터럴은 작은따옴표를 사용합니다.

정답 SQL: SELECT 이름, 점수 FROM 학생 WHERE 학과 = ''컴퓨터공학''

[모범 답안]
result = "SELECT 이름, 점수 FROM 학생 WHERE 학과 = ''컴퓨터공학''"', 10, 999, 1, 'ACTIVE', 1),
(5042, 4004, '정렬해서 조회 (ORDER BY)', '학생 테이블에서 모든 학생의 이름과 점수를 점수가 높은 순서로 조회하는 SQL을 작성하세요. 컬럼 순서는 이름, 점수입니다.

[학생 테이블]
학번 | 이름 | 학과 | 학년 | 점수
1001 | 김민준 | 컴퓨터공학 | 3 | 88
1002 | 이서연 | 컴퓨터공학 | 2 | 95
1003 | 박지호 | 전자공학 | 4 | 72
1004 | 최유진 | 전자공학 | 1 | 81
1005 | 정하준 | 경영학 | 2 | 67
1006 | 강서윤 | 경영학 | 3 | 79
1007 | 조은우 | 컴퓨터공학 | 1 | 76
1008 | 윤지아 | 통계학 | 4 | 91

[수강 테이블]
학번 | 과목명 | 학점
1001 | 데이터베이스 | 3
1001 | 운영체제 | 3
1002 | 데이터베이스 | 3
1003 | 회로이론 | 3
1005 | 회계원리 | 3
1007 | 자료구조 | 3
1008 | 데이터베이스 | 3
1008 | 통계학개론 | 2

[제출 방법]
SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"
작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.', 'CODE', 'EASY', 'ORDER BY 컬럼 DESC는 큰 값부터 정렬합니다. 생략하면 오름차순(ASC)입니다.

정답 SQL: SELECT 이름, 점수 FROM 학생 ORDER BY 점수 DESC

[모범 답안]
result = ''SELECT 이름, 점수 FROM 학생 ORDER BY 점수 DESC''', 10, 999, 1, 'ACTIVE', 2),
(5043, 4004, '그룹별 개수 세기 (GROUP BY)', '학생 테이블에서 학과별 학생 수를 조회하는 SQL을 작성하세요. 컬럼 순서는 학과, 학생 수입니다.

[학생 테이블]
학번 | 이름 | 학과 | 학년 | 점수
1001 | 김민준 | 컴퓨터공학 | 3 | 88
1002 | 이서연 | 컴퓨터공학 | 2 | 95
1003 | 박지호 | 전자공학 | 4 | 72
1004 | 최유진 | 전자공학 | 1 | 81
1005 | 정하준 | 경영학 | 2 | 67
1006 | 강서윤 | 경영학 | 3 | 79
1007 | 조은우 | 컴퓨터공학 | 1 | 76
1008 | 윤지아 | 통계학 | 4 | 91

[수강 테이블]
학번 | 과목명 | 학점
1001 | 데이터베이스 | 3
1001 | 운영체제 | 3
1002 | 데이터베이스 | 3
1003 | 회로이론 | 3
1005 | 회계원리 | 3
1007 | 자료구조 | 3
1008 | 데이터베이스 | 3
1008 | 통계학개론 | 2

[제출 방법]
SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"
작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.', 'CODE', 'EASY', 'GROUP BY 학과는 학과가 같은 행을 한 그룹으로 묶고, COUNT(*)는 그룹마다 행 수를 셉니다.

정답 SQL: SELECT 학과, COUNT(*) FROM 학생 GROUP BY 학과

[모범 답안]
result = ''SELECT 학과, COUNT(*) FROM 학생 GROUP BY 학과''', 15, 999, 1, 'ACTIVE', 3),
(5044, 4004, '그룹에 조건 걸기 (HAVING)', '학생 테이블에서 학과별 평균 점수가 80점 이상인 학과만 조회하는 SQL을 작성하세요. 컬럼 순서는 학과, 평균 점수입니다.

[학생 테이블]
학번 | 이름 | 학과 | 학년 | 점수
1001 | 김민준 | 컴퓨터공학 | 3 | 88
1002 | 이서연 | 컴퓨터공학 | 2 | 95
1003 | 박지호 | 전자공학 | 4 | 72
1004 | 최유진 | 전자공학 | 1 | 81
1005 | 정하준 | 경영학 | 2 | 67
1006 | 강서윤 | 경영학 | 3 | 79
1007 | 조은우 | 컴퓨터공학 | 1 | 76
1008 | 윤지아 | 통계학 | 4 | 91

[수강 테이블]
학번 | 과목명 | 학점
1001 | 데이터베이스 | 3
1001 | 운영체제 | 3
1002 | 데이터베이스 | 3
1003 | 회로이론 | 3
1005 | 회계원리 | 3
1007 | 자료구조 | 3
1008 | 데이터베이스 | 3
1008 | 통계학개론 | 2

[제출 방법]
SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"
작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.', 'CODE', 'MEDIUM', 'WHERE는 그룹으로 묶기 전의 행에, HAVING은 묶은 뒤의 그룹에 조건을 겁니다. 집계 함수 조건은 HAVING에만 쓸 수 있습니다.

정답 SQL: SELECT 학과, AVG(점수) FROM 학생 GROUP BY 학과 HAVING AVG(점수) >= 80

[모범 답안]
result = ''SELECT 학과, AVG(점수) FROM 학생 GROUP BY 학과 HAVING AVG(점수) >= 80''', 15, 999, 1, 'ACTIVE', 4),
(5045, 4004, '두 테이블 묶기 (JOIN)', '''데이터베이스'' 과목을 수강한 학생의 이름을 조회하는 SQL을 작성하세요. 학생 테이블과 수강 테이블은 학번으로 연결됩니다. 조회 컬럼은 이름 하나입니다.

[학생 테이블]
학번 | 이름 | 학과 | 학년 | 점수
1001 | 김민준 | 컴퓨터공학 | 3 | 88
1002 | 이서연 | 컴퓨터공학 | 2 | 95
1003 | 박지호 | 전자공학 | 4 | 72
1004 | 최유진 | 전자공학 | 1 | 81
1005 | 정하준 | 경영학 | 2 | 67
1006 | 강서윤 | 경영학 | 3 | 79
1007 | 조은우 | 컴퓨터공학 | 1 | 76
1008 | 윤지아 | 통계학 | 4 | 91

[수강 테이블]
학번 | 과목명 | 학점
1001 | 데이터베이스 | 3
1001 | 운영체제 | 3
1002 | 데이터베이스 | 3
1003 | 회로이론 | 3
1005 | 회계원리 | 3
1007 | 자료구조 | 3
1008 | 데이터베이스 | 3
1008 | 통계학개론 | 2

[제출 방법]
SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"
작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.', 'CODE', 'MEDIUM', 'JOIN ... ON 으로 두 테이블의 학번이 같은 행을 연결한 뒤, 과목명 조건으로 거릅니다. 서브쿼리 WHERE 학번 IN (SELECT 학번 FROM 수강 WHERE ...)로도 풀 수 있습니다.

정답 SQL: SELECT 학생.이름 FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번 WHERE 수강.과목명 = ''데이터베이스''

[모범 답안]
result = "SELECT 학생.이름 FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번 WHERE 수강.과목명 = ''데이터베이스''"', 20, 999, 1, 'ACTIVE', 5),
(5051, 4005, '가장 바람직한 응집도', '모듈 내부의 모든 기능 요소가 단일한 목적을 위해 수행되는 경우로, 응집도가 가장 높은 단계의 이름을 쓰세요.

[제출 방법]
답을 문자열로 result에 담으세요. 예)  result = "정답"
띄어쓰기와 영문 대소문자는 구분하지 않습니다.', 'CODE', 'EASY', '응집도는 모듈 내부 요소들의 관련 정도입니다. 높을수록 좋으며, 가장 높은 단계는 모든 요소가 하나의 기능을 수행하는 기능적 응집도입니다.

정답: 기능적 응집도

[모범 답안]
result = ''기능적 응집도''', 10, 999, 1, 'ACTIVE', 1),
(5052, 4005, '가장 바람직한 결합도', '모듈 간 인터페이스로 단순한 자료 요소(매개변수)만 전달되는 경우로, 결합도가 가장 낮은 단계의 이름을 쓰세요.

[제출 방법]
답을 문자열로 result에 담으세요. 예)  result = "정답"
띄어쓰기와 영문 대소문자는 구분하지 않습니다.', 'CODE', 'EASY', '결합도는 모듈 사이의 의존 정도입니다. 낮을수록 좋으며, 가장 낮은 단계는 단순 자료만 전달하는 자료 결합도입니다.

정답: 자료 결합도

[모범 답안]
result = ''자료 결합도''', 10, 999, 1, 'ACTIVE', 2),
(5053, 4005, '경로를 설정하는 OSI 계층', 'OSI 7계층 중 패킷의 경로 설정(라우팅)과 논리 주소(IP) 지정을 담당하는 계층의 이름을 쓰세요.

[제출 방법]
답을 문자열로 result에 담으세요. 예)  result = "정답"
띄어쓰기와 영문 대소문자는 구분하지 않습니다.', 'CODE', 'EASY', '네트워크 계층(3계층)은 IP 주소를 기반으로 목적지까지의 경로를 정합니다. 대표 장비는 라우터, 대표 프로토콜은 IP입니다.

정답: 네트워크 계층

[모범 답안]
result = ''네트워크 계층''', 10, 999, 1, 'ACTIVE', 3),
(5054, 4005, '트랜잭션의 특성', '트랜잭션의 연산은 데이터베이스에 모두 반영되거나 전혀 반영되지 않아야 한다는 특성의 이름을 쓰세요.

[제출 방법]
답을 문자열로 result에 담으세요. 예)  result = "정답"
띄어쓰기와 영문 대소문자는 구분하지 않습니다.', 'CODE', 'EASY', 'ACID는 원자성(Atomicity), 일관성(Consistency), 독립성(Isolation), 영속성(Durability)입니다. 전부 수행되거나 전혀 수행되지 않는 성질이 원자성입니다.

정답: 원자성

[모범 답안]
result = ''원자성''', 10, 999, 1, 'ACTIVE', 4),
(5055, 4005, '부분 함수 종속을 제거하는 정규형', '제1정규형을 만족하는 릴레이션에서 부분 함수적 종속을 제거해 만드는 정규형의 이름을 쓰세요.

[제출 방법]
답을 문자열로 result에 담으세요. 예)  result = "정답"
띄어쓰기와 영문 대소문자는 구분하지 않습니다.', 'CODE', 'MEDIUM', '정규화는 ''도부이결다조''로 외웁니다. 도메인 원자값(1NF), 부분 함수 종속 제거(2NF), 이행 함수 종속 제거(3NF), 결정자이면서 후보키가 아닌 것 제거(BCNF), 다치 종속 제거(4NF), 조인 종속 제거(5NF).

정답: 제2정규형

[모범 답안]
result = ''제2정규형''', 15, 999, 1, 'ACTIVE', 5),
(5061, 4006, '데이터 크기 확인하기', '카페 주문 데이터의 행 개수와 열 개수를 (행, 열) 튜플로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', 'df.shape 속성은 DataFrame의 (행 개수, 열 개수)를 튜플로 돌려줍니다. 괄호 없이 속성으로 접근합니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

result = df.shape', 10, 999, 1, 'ACTIVE', 1),
(5062, 4006, '메뉴 종류 세기', 'menu 컬럼에 서로 다른 메뉴가 몇 가지 있는지 정수로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', 'nunique()는 컬럼에서 중복을 제외한 고유값의 개수를 돌려줍니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

result = df["menu"].nunique()', 10, 999, 1, 'ACTIVE', 2),
(5063, 4006, '가장 많이 팔린 메뉴 찾기', 'quantity(판매 수량) 합계가 가장 큰 메뉴의 이름을 문자열로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', 'groupby("menu")로 메뉴별로 묶고 quantity 합계를 구한 뒤, idxmax()로 합계가 가장 큰 메뉴 이름을 얻습니다. 주문 건수가 아니라 수량 합계 기준이라는 점에 주의합니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

result = df.groupby("menu")["quantity"].sum().idxmax()', 15, 999, 1, 'ACTIVE', 3),
(5064, 4006, '총 매출 계산하기', 'price는 1잔(1개)의 가격이고 quantity는 수량입니다. 전체 주문의 총 매출(price × quantity의 합)을 정수로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', '컬럼끼리 곱하면 행마다 계산된 Series가 만들어지고, sum()으로 전체 합계를 구합니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

result = (df["price"] * df["quantity"]).sum()', 15, 999, 1, 'ACTIVE', 4),
(5071, 4007, '회원 주문 건수 세기', 'is_member 컬럼은 회원 주문이면 "Y", 비회원이면 "N"입니다. 회원 주문 건수를 정수로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', 'df["is_member"] == "Y"는 불리언 Series를 만들고, sum()은 True의 개수를 셉니다. len(df[조건])으로도 구할 수 있습니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

result = (df["is_member"] == "Y").sum()', 10, 999, 1, 'ACTIVE', 1),
(5072, 4007, '주문 금액 컬럼 만들기', '주문 금액은 unit_price × quantity × (1 - discount_rate) 입니다. 이 값을 amount 컬럼으로 추가한 뒤, amount의 평균을 소수 둘째 자리까지 반올림해 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'EASY', 'df["amount"] = ... 형태로 파생 컬럼을 만들고 mean()으로 평균을 구합니다. 할인율은 (1 - discount_rate)로 반영합니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

df["amount"] = df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])
result = round(df["amount"].mean(), 2)', 15, 999, 1, 'ACTIVE', 2),
(5073, 4007, '카테고리별 매출 합계', 'amount(주문 금액 = unit_price × quantity × (1 - discount_rate))를 구한 뒤, category별 amount 합계를 Series로 result에 담으세요. 인덱스는 카테고리 이름이어야 합니다.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'MEDIUM', 'groupby로 카테고리별로 묶고 amount 합계를 구하면 카테고리 이름을 인덱스로 갖는 Series가 됩니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

df["amount"] = df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])
result = df.groupby("category")["amount"].sum()', 15, 999, 1, 'ACTIVE', 3),
(5074, 4007, '매출 1위 지역 찾기', 'region별 amount(주문 금액) 합계가 가장 큰 지역 이름을 문자열로 result에 담으세요.

[데이터 불러오기]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

[제출 방법]
답을 result 변수에 담으면 채점됩니다.', 'CODE', 'MEDIUM', '지역별 amount 합계를 구하고 idxmax()로 1위 지역을 얻습니다. sort_values(ascending=False).index[0]도 같은 결과입니다.

[모범 답안]
import os
import pandas as pd

df = pd.read_csv(os.environ["DATASET_PATH"])

df["amount"] = df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])
result = df.groupby("region")["amount"].sum().idxmax()', 15, 999, 1, 'ACTIVE', 4)
ON DUPLICATE KEY UPDATE problem_set_id = VALUES(problem_set_id), title = VALUES(title), content = VALUES(content), problem_type = VALUES(problem_type), difficulty = VALUES(difficulty), explanation = VALUES(explanation), point = VALUES(point), attempt_limit = VALUES(attempt_limit), is_retriable = VALUES(is_retriable), status = VALUES(status), problem_order = VALUES(problem_order);

INSERT INTO problem_test_case (test_case_id, problem_id, test_code, test_order, is_hidden, timeout_ms, status, created_at, updated_at) VALUES
(50111, 5011, 'assert result is not None, "result에 출력 결과를 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50112, 5011, 'assert str(result).strip() == ''REMEMBER AND STR'', "출력 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50121, 5012, 'assert result is not None, "result에 출력 결과를 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50122, 5012, 'assert str(result).strip() == ''[101, 102, 103, 104, 105]'', "출력 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50131, 5013, 'assert result is not None, "result에 출력 결과를 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50132, 5013, 'assert str(result).strip() == ''5'', "출력 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50141, 5014, 'assert result is not None, "result에 출력 결과를 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50142, 5014, 'assert str(result).strip() == ''18'', "출력 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50151, 5015, 'assert result is not None, "result에 출력 결과를 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50152, 5015, 'assert str(result).strip() == ''a = 20 b = 2'', "출력 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50211, 5021, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution(10) == 55, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50212, 5021, 'assert solution(1) == 1, "숨겨진 입력에서 결과가 다릅니다"
assert solution(100) == 5050, "숨겨진 입력에서 결과가 다릅니다"
assert solution(37) == 703, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50221, 5022, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution([1, 2, 3, 4, 6]) == [2, 4, 6], "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50222, 5022, 'assert solution([1, 3, 5]) == [], "숨겨진 입력에서 결과가 다릅니다"
assert solution([10, 7, 8, 0, -2]) == [10, 8, 0, -2], "숨겨진 입력에서 결과가 다릅니다"
assert solution([]) == [], "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50231, 5023, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution("python") == ''nohtyp'', "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50232, 5023, 'assert solution("a") == ''a'', "숨겨진 입력에서 결과가 다릅니다"
assert solution("정보처리기사") == ''사기리처보정'', "숨겨진 입력에서 결과가 다릅니다"
assert solution("level up") == ''pu level'', "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50241, 5024, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution([3, 9, 1, 7]) == 8, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50242, 5024, 'assert solution([5]) == 0, "숨겨진 입력에서 결과가 다릅니다"
assert solution([-4, 10, 0]) == 14, "숨겨진 입력에서 결과가 다릅니다"
assert solution([2, 2, 2, 3]) == 1, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50251, 5025, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution("banana") == {''b'': 1, ''a'': 3, ''n'': 2}, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50252, 5025, 'assert solution("") == {}, "숨겨진 입력에서 결과가 다릅니다"
assert solution("aAbB") == {''a'': 1, ''A'': 1, ''b'': 1, ''B'': 1}, "숨겨진 입력에서 결과가 다릅니다"
assert solution("mississippi") == {''m'': 1, ''i'': 4, ''s'': 4, ''p'': 2}, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50311, 5031, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution(12, 18) == 6, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50312, 5031, 'assert solution(7, 13) == 1, "숨겨진 입력에서 결과가 다릅니다"
assert solution(100, 75) == 25, "숨겨진 입력에서 결과가 다릅니다"
assert solution(9, 9) == 9, "숨겨진 입력에서 결과가 다릅니다"
assert solution(1, 50) == 1, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50321, 5032, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution(7) == True, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50322, 5032, 'assert solution(9) == False, "숨겨진 입력에서 결과가 다릅니다"
assert solution(1) == False, "숨겨진 입력에서 결과가 다릅니다"
assert solution(2) == True, "숨겨진 입력에서 결과가 다릅니다"
assert solution(97) == True, "숨겨진 입력에서 결과가 다릅니다"
assert solution(91) == False, "숨겨진 입력에서 결과가 다릅니다"
assert solution(0) == False, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50331, 5033, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution(10) == ''1010'', "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50332, 5033, 'assert solution(0) == ''0'', "숨겨진 입력에서 결과가 다릅니다"
assert solution(1) == ''1'', "숨겨진 입력에서 결과가 다릅니다"
assert solution(255) == ''11111111'', "숨겨진 입력에서 결과가 다릅니다"
assert solution(37) == ''100101'', "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50341, 5034, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution([5, 2, 9, 1]) == [1, 2, 5, 9], "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50342, 5034, 'assert solution([]) == [], "숨겨진 입력에서 결과가 다릅니다"
assert solution([3]) == [3], "숨겨진 입력에서 결과가 다릅니다"
assert solution([4, 4, 1, -7, 0]) == [-7, 0, 1, 4, 4], "숨겨진 입력에서 결과가 다릅니다"
assert solution([9, 8, 7, 6, 5]) == [5, 6, 7, 8, 9], "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50351, 5035, 'assert callable(solution), "solution 함수를 정의해야 합니다"
assert solution(6) == 8, "예시 입력의 결과가 다릅니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50352, 5035, 'assert solution(1) == 1, "숨겨진 입력에서 결과가 다릅니다"
assert solution(2) == 1, "숨겨진 입력에서 결과가 다릅니다"
assert solution(10) == 55, "숨겨진 입력에서 결과가 다릅니다"
assert solution(20) == 6765, "숨겨진 입력에서 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50411, 5041, 'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50412, 5041, 'import sqlite3
_con = sqlite3.connect(":memory:")
_con.executescript("""CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, ''김민준'', ''컴퓨터공학'', 3, 88), (1002, ''이서연'', ''컴퓨터공학'', 2, 95),
 (1003, ''박지호'', ''전자공학'', 4, 72), (1004, ''최유진'', ''전자공학'', 1, 81),
 (1005, ''정하준'', ''경영학'', 2, 67), (1006, ''강서윤'', ''경영학'', 3, 79),
 (1007, ''조은우'', ''컴퓨터공학'', 1, 76), (1008, ''윤지아'', ''통계학'', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, ''데이터베이스'', 3), (1001, ''운영체제'', 3), (1002, ''데이터베이스'', 3), (1003, ''회로이론'', 3),
 (1005, ''회계원리'', 3), (1007, ''자료구조'', 3), (1008, ''데이터베이스'', 3), (1008, ''통계학개론'', 2);""")
def _rows(sql):
    cur = _con.execute(str(sql).strip().rstrip(";"))
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]
_expected = [(''김민준'', 88), (''이서연'', 95), (''조은우'', 76)]
_actual = _rows(result)
assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"
assert sorted(_actual, key=repr) == sorted(_expected, key=repr), "조회 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50421, 5042, 'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50422, 5042, 'import sqlite3
_con = sqlite3.connect(":memory:")
_con.executescript("""CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, ''김민준'', ''컴퓨터공학'', 3, 88), (1002, ''이서연'', ''컴퓨터공학'', 2, 95),
 (1003, ''박지호'', ''전자공학'', 4, 72), (1004, ''최유진'', ''전자공학'', 1, 81),
 (1005, ''정하준'', ''경영학'', 2, 67), (1006, ''강서윤'', ''경영학'', 3, 79),
 (1007, ''조은우'', ''컴퓨터공학'', 1, 76), (1008, ''윤지아'', ''통계학'', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, ''데이터베이스'', 3), (1001, ''운영체제'', 3), (1002, ''데이터베이스'', 3), (1003, ''회로이론'', 3),
 (1005, ''회계원리'', 3), (1007, ''자료구조'', 3), (1008, ''데이터베이스'', 3), (1008, ''통계학개론'', 2);""")
def _rows(sql):
    cur = _con.execute(str(sql).strip().rstrip(";"))
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]
_expected = [(''이서연'', 95), (''윤지아'', 91), (''김민준'', 88), (''최유진'', 81), (''강서윤'', 79), (''조은우'', 76), (''박지호'', 72), (''정하준'', 67)]
_actual = _rows(result)
assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"
assert _actual == _expected, "조회 결과 또는 행 순서가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50431, 5043, 'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50432, 5043, 'import sqlite3
_con = sqlite3.connect(":memory:")
_con.executescript("""CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, ''김민준'', ''컴퓨터공학'', 3, 88), (1002, ''이서연'', ''컴퓨터공학'', 2, 95),
 (1003, ''박지호'', ''전자공학'', 4, 72), (1004, ''최유진'', ''전자공학'', 1, 81),
 (1005, ''정하준'', ''경영학'', 2, 67), (1006, ''강서윤'', ''경영학'', 3, 79),
 (1007, ''조은우'', ''컴퓨터공학'', 1, 76), (1008, ''윤지아'', ''통계학'', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, ''데이터베이스'', 3), (1001, ''운영체제'', 3), (1002, ''데이터베이스'', 3), (1003, ''회로이론'', 3),
 (1005, ''회계원리'', 3), (1007, ''자료구조'', 3), (1008, ''데이터베이스'', 3), (1008, ''통계학개론'', 2);""")
def _rows(sql):
    cur = _con.execute(str(sql).strip().rstrip(";"))
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]
_expected = [(''경영학'', 2), (''전자공학'', 2), (''컴퓨터공학'', 3), (''통계학'', 1)]
_actual = _rows(result)
assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"
assert sorted(_actual, key=repr) == sorted(_expected, key=repr), "조회 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50441, 5044, 'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50442, 5044, 'import sqlite3
_con = sqlite3.connect(":memory:")
_con.executescript("""CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, ''김민준'', ''컴퓨터공학'', 3, 88), (1002, ''이서연'', ''컴퓨터공학'', 2, 95),
 (1003, ''박지호'', ''전자공학'', 4, 72), (1004, ''최유진'', ''전자공학'', 1, 81),
 (1005, ''정하준'', ''경영학'', 2, 67), (1006, ''강서윤'', ''경영학'', 3, 79),
 (1007, ''조은우'', ''컴퓨터공학'', 1, 76), (1008, ''윤지아'', ''통계학'', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, ''데이터베이스'', 3), (1001, ''운영체제'', 3), (1002, ''데이터베이스'', 3), (1003, ''회로이론'', 3),
 (1005, ''회계원리'', 3), (1007, ''자료구조'', 3), (1008, ''데이터베이스'', 3), (1008, ''통계학개론'', 2);""")
def _rows(sql):
    cur = _con.execute(str(sql).strip().rstrip(";"))
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]
_expected = [(''컴퓨터공학'', 86.33), (''통계학'', 91.0)]
_actual = _rows(result)
assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"
assert sorted(_actual, key=repr) == sorted(_expected, key=repr), "조회 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50451, 5045, 'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50452, 5045, 'import sqlite3
_con = sqlite3.connect(":memory:")
_con.executescript("""CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, ''김민준'', ''컴퓨터공학'', 3, 88), (1002, ''이서연'', ''컴퓨터공학'', 2, 95),
 (1003, ''박지호'', ''전자공학'', 4, 72), (1004, ''최유진'', ''전자공학'', 1, 81),
 (1005, ''정하준'', ''경영학'', 2, 67), (1006, ''강서윤'', ''경영학'', 3, 79),
 (1007, ''조은우'', ''컴퓨터공학'', 1, 76), (1008, ''윤지아'', ''통계학'', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, ''데이터베이스'', 3), (1001, ''운영체제'', 3), (1002, ''데이터베이스'', 3), (1003, ''회로이론'', 3),
 (1005, ''회계원리'', 3), (1007, ''자료구조'', 3), (1008, ''데이터베이스'', 3), (1008, ''통계학개론'', 2);""")
def _rows(sql):
    cur = _con.execute(str(sql).strip().rstrip(";"))
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]
_expected = [(''김민준'',), (''이서연'',), (''윤지아'',)]
_actual = _rows(result)
assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"
assert sorted(_actual, key=repr) == sorted(_expected, key=repr), "조회 결과가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50511, 5051, 'assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50512, 5051, 'assert str(result).replace(" ", "").lower() in [''functional'', ''functionalcohesion'', ''기능응집도'', ''기능적'', ''기능적응집도''], "정답이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50521, 5052, 'assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50522, 5052, 'assert str(result).replace(" ", "").lower() in [''data'', ''datacoupling'', ''데이터'', ''데이터결합도'', ''자료'', ''자료결합도''], "정답이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50531, 5053, 'assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50532, 5053, 'assert str(result).replace(" ", "").lower() in [''3계층'', ''network'', ''networklayer'', ''네트워크'', ''네트워크계층''], "정답이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50541, 5054, 'assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50542, 5054, 'assert str(result).replace(" ", "").lower() in [''atomicity'', ''원자성''], "정답이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50551, 5055, 'assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50552, 5055, 'assert str(result).replace(" ", "").lower() in [''2nf'', ''2정규형'', ''secondnormalform'', ''제2정규형'', ''제2정규화''], "정답이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50611, 5061, 'assert isinstance(result, tuple) and len(result) == 2, "result는 (행, 열) 형태의 튜플이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50612, 5061, 'assert tuple(int(v) for v in result) == (400, 9), "행 또는 열 개수가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50621, 5062, 'assert not isinstance(result, bool) and int(result) == result, "result는 정수여야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50622, 5062, 'assert int(result) == 10, "메뉴 종류 수가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50631, 5063, 'assert isinstance(result, str), "result는 메뉴 이름(문자열)이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50632, 5063, 'assert result == ''아메리카노'', "판매 수량 합계가 가장 큰 메뉴가 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50641, 5064, 'assert not isinstance(result, bool) and float(result) == int(result), "result는 정수 금액이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50642, 5064, 'assert int(result) == 3454300, "총 매출이 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50711, 5071, 'assert not isinstance(result, bool) and int(result) == result, "result는 정수여야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50712, 5071, 'assert int(result) == 368, "회원 주문 건수가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50721, 5072, 'assert "amount" in df.columns, "df에 amount 컬럼을 추가해야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50722, 5072, 'assert abs(float(result) - 60639.0) < 0.01, "평균 주문 금액이 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50731, 5073, 'assert hasattr(result, "index") and len(result) == 5, "result는 카테고리 5개를 인덱스로 갖는 Series여야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50732, 5073, 'expected = {''도서'': 2678700.0, ''생활용품'': 3509650.0, ''식품'': 3000950.0, ''의류'': 10161550.0, ''전자기기'': 17032550.0}
actual = dict(result)
assert set(actual) == set(expected), "카테고리 이름이 다릅니다"
assert all(abs(float(actual[k]) - expected[k]) < 1 for k in expected), "카테고리별 합계가 다릅니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW()),
(50741, 5074, 'assert isinstance(result, str), "result는 지역 이름(문자열)이어야 합니다"', 1, 0, 5000, 'ACTIVE', NOW(), NOW()),
(50742, 5074, 'assert result == ''서울'', "매출 합계가 가장 큰 지역이 아닙니다"', 2, 1, 5000, 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE problem_id = VALUES(problem_id), test_code = VALUES(test_code), test_order = VALUES(test_order), is_hidden = VALUES(is_hidden), timeout_ms = VALUES(timeout_ms), status = VALUES(status), updated_at = VALUES(updated_at);

INSERT INTO problem_hint (hint_id, problem_id, hint_order, hint_content, created_at) VALUES
(50111, 5011, 1, 'a[:3]은 앞에서 3글자, a[12:16]은 인덱스 12부터 15까지입니다.', NOW()),
(50112, 5011, 2, '"R AND %s" % "STR" 은 %s 자리에 STR이 들어갑니다.', NOW()),
(50121, 5012, 1, 'map은 리스트의 모든 요소에 함수를 적용합니다.', NOW()),
(50122, 5012, 2, '리스트를 print 하면 대괄호와 쉼표, 공백이 함께 출력됩니다.', NOW()),
(50131, 5013, 1, '집합은 중복을 허용하지 않습니다.', NOW()),
(50132, 5013, 2, '이미 있는 값을 add 하거나 update 해도 개수는 늘지 않습니다.', NOW()),
(50141, 5014, 1, 'range(1, 11)은 1부터 10까지입니다.', NOW()),
(50142, 5014, 2, '3의 배수만 더합니다: 3, 6, 9', NOW()),
(50151, 5015, 1, '인자를 하나만 넘기면 num2는 기본값을 씁니다.', NOW()),
(50152, 5015, 2, 'print에 쉼표로 여러 값을 넘기면 사이에 공백이 하나씩 들어갑니다.', NOW()),
(50211, 5021, 1, 'range(1, n + 1)로 1부터 n까지 순회할 수 있습니다.', NOW()),
(50212, 5021, 2, '누적할 변수를 0으로 두고 하나씩 더하세요.', NOW()),
(50221, 5022, 1, '2로 나눈 나머지가 0이면 짝수입니다.', NOW()),
(50222, 5022, 2, '빈 리스트를 만들고 조건에 맞는 값만 append 하세요.', NOW()),
(50231, 5023, 1, '슬라이싱은 [시작:끝:간격] 형태로 쓸 수 있습니다.', NOW()),
(50232, 5023, 2, '간격을 -1로 주면 거꾸로 읽습니다: s[::-1]', NOW()),
(50241, 5024, 1, '내장 함수 max와 min을 쓸 수 있습니다.', NOW()),
(50242, 5024, 2, 'max(nums) - min(nums)', NOW()),
(50251, 5025, 1, '빈 딕셔너리를 만들고 글자를 하나씩 살펴보세요.', NOW()),
(50252, 5025, 2, 'counts.get(ch, 0)은 키가 없으면 0을 돌려줍니다.', NOW()),
(50311, 5031, 1, '유클리드 호제법: a를 b로 나눈 나머지를 이용합니다.', NOW()),
(50312, 5031, 2, 'b가 0이 될 때까지 (a, b)를 (b, a % b)로 바꿉니다.', NOW()),
(50321, 5032, 1, '소수는 1과 자기 자신으로만 나누어떨어지는 2 이상의 수입니다.', NOW()),
(50322, 5032, 2, '2부터 n-1까지 나누어 보고, 나누어떨어지는 수가 있으면 소수가 아닙니다.', NOW()),
(50331, 5033, 1, '2로 나눈 나머지를 거꾸로 이어 붙이면 2진수가 됩니다.', NOW()),
(50332, 5033, 2, '몫이 0이 될 때까지 n을 2로 나누세요. n이 0인 경우를 따로 처리해야 합니다.', NOW()),
(50341, 5034, 1, '버블 정렬은 이웃한 두 값을 비교해 큰 값을 뒤로 보냅니다.', NOW()),
(50342, 5034, 2, '한 번 훑을 때마다 가장 큰 값이 맨 뒤에 자리 잡으므로, 다음에는 그 앞까지만 비교합니다.', NOW()),
(50351, 5035, 1, '첫 번째와 두 번째 수는 모두 1입니다.', NOW()),
(50352, 5035, 2, '두 변수에 연속한 두 수를 담고, 한 칸씩 앞으로 옮겨 가세요.', NOW()),
(50411, 5041, 1, '조건은 WHERE 절에 씁니다.', NOW()),
(50412, 5041, 2, '문자열 값은 작은따옴표로 감쌉니다: 학과 = ''컴퓨터공학''', NOW()),
(50421, 5042, 1, '정렬은 ORDER BY 절로 합니다.', NOW()),
(50422, 5042, 2, '내림차순은 DESC, 오름차순은 ASC(기본값)입니다.', NOW()),
(50431, 5043, 1, '같은 학과끼리 묶으려면 GROUP BY를 씁니다.', NOW()),
(50432, 5043, 2, '묶인 그룹의 행 수는 COUNT(*)로 셉니다.', NOW()),
(50441, 5044, 1, '그룹에 대한 조건은 WHERE가 아니라 HAVING에 씁니다.', NOW()),
(50442, 5044, 2, '평균은 AVG(점수)로 구합니다.', NOW()),
(50451, 5045, 1, '두 테이블을 학번이 같은 행끼리 연결해야 합니다.', NOW()),
(50452, 5045, 2, 'FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번 형태로 묶은 뒤 WHERE로 과목명을 거르세요.', NOW()),
(50511, 5051, 1, '응집도는 우연적 → 논리적 → 시간적 → 절차적 → 통신적 → 순차적 → 기능적 순으로 높아집니다.', NOW()),
(50512, 5051, 2, '단일 ''기능''을 수행한다는 점에 주목하세요.', NOW()),
(50521, 5052, 1, '결합도는 내용 → 공통 → 외부 → 제어 → 스탬프 → 자료 순으로 낮아집니다.', NOW()),
(50522, 5052, 2, '단순 ''자료''만 주고받는 경우입니다.', NOW()),
(50531, 5053, 1, 'OSI 7계층은 물리 → 데이터링크 → 네트워크 → 전송 → 세션 → 표현 → 응용 순입니다.', NOW()),
(50532, 5053, 2, '라우터가 동작하는 계층입니다.', NOW()),
(50541, 5054, 1, '트랜잭션의 4가지 특성은 ACID라고 부릅니다.', NOW()),
(50542, 5054, 2, '더 쪼갤 수 없는 단위라는 뜻입니다. All or Nothing.', NOW()),
(50551, 5055, 1, '정규화 과정: 도메인 원자값(1NF) → 부분 함수 종속 제거 → 이행 함수 종속 제거 → 결정자가 후보키(BCNF)', NOW()),
(50552, 5055, 2, '1NF 바로 다음 단계입니다.', NOW()),
(50611, 5061, 1, 'DataFrame에는 크기를 알려주는 속성이 있습니다.', NOW()),
(50612, 5061, 2, 'df.shape는 (행 개수, 열 개수) 튜플을 돌려줍니다.', NOW()),
(50621, 5062, 1, '중복을 제거한 값의 개수를 세는 메서드를 찾아보세요.', NOW()),
(50622, 5062, 2, 'df["menu"].nunique() 또는 len(df["menu"].unique())를 쓸 수 있습니다.', NOW()),
(50631, 5063, 1, '메뉴별로 묶은 뒤 quantity를 더해야 합니다.', NOW()),
(50632, 5063, 2, 'groupby 결과에 sum()을 적용하고 idxmax()로 가장 큰 값의 인덱스를 구하세요.', NOW()),
(50641, 5064, 1, '두 컬럼을 곱하면 주문별 금액 Series가 됩니다.', NOW()),
(50642, 5064, 2, '(df["price"] * df["quantity"]).sum()', NOW()),
(50711, 5071, 1, '조건식의 결과는 True/False Series입니다.', NOW()),
(50712, 5071, 2, 'True는 1로 계산되므로 조건식에 sum()을 쓰면 개수가 됩니다.', NOW()),
(50721, 5072, 1, '여러 컬럼을 연산한 결과를 새 컬럼 이름에 대입하면 컬럼이 추가됩니다.', NOW()),
(50722, 5072, 2, '할인율이 0.1이면 실제 금액은 0.9배입니다.', NOW()),
(50731, 5073, 1, '먼저 amount 컬럼이 있어야 합니다.', NOW()),
(50732, 5073, 2, 'df.groupby("category")["amount"].sum()', NOW()),
(50741, 5074, 1, '앞 문제의 groupby를 region에 적용해 보세요.', NOW()),
(50742, 5074, 2, '합계 Series에서 idxmax()는 가장 큰 값의 인덱스를 돌려줍니다.', NOW())
ON DUPLICATE KEY UPDATE problem_id = VALUES(problem_id), hint_order = VALUES(hint_order), hint_content = VALUES(hint_content);

INSERT INTO problem_dataset (dataset_id, problem_set_id, original_file_name, stored_file_name, file_url, file_path, file_size, meta_data, status, created_at, updated_at) VALUES
(8006, 4006, 'cafe_orders.csv', 'cafe_orders.csv', 'https://codebomba-lms-379959319287.s3.ap-northeast-2.amazonaws.com/problem_dataset/seed/cafe_orders.csv', 'problem_dataset/seed/cafe_orders.csv', 24241, '{"columns": [{"name": "order_id", "examples": ["1", "2", "3", "4", "5"]}, {"name": "order_date", "examples": ["2026-04-04", "2026-03-19", "2026-03-11", "2026-04-10", "2026-04-11"]}, {"name": "menu", "examples": ["바닐라라떼", "아메리카노", "카페라떼", "치즈케이크", "녹차라떼"]}, {"name": "category", "examples": ["커피", "디저트", "논커피"]}, {"name": "size", "examples": ["S", "M", "L"]}, {"name": "quantity", "examples": ["3", "1", "2", "4"]}, {"name": "price", "examples": ["5000", "4500", "6500", "5800", "5200"]}, {"name": "customer_type", "examples": ["단골", "신규"]}, {"name": "payment", "examples": ["앱", "카드", "현금"]}]}', 'ACTIVE', NOW(), NOW()),
(8007, 4007, 'shop_orders.csv', 'shop_orders.csv', 'https://codebomba-lms-379959319287.s3.ap-northeast-2.amazonaws.com/problem_dataset/seed/shop_orders.csv', 'problem_dataset/seed/shop_orders.csv', 39097, '{"columns": [{"name": "order_id", "examples": ["O00001", "O00002", "O00003", "O00004", "O00005"]}, {"name": "order_date", "examples": ["2026-03-02", "2026-04-19", "2026-03-08", "2026-04-17", "2026-02-04"]}, {"name": "category", "examples": ["생활용품", "전자기기", "식품", "의류", "도서"]}, {"name": "product", "examples": ["수건 세트", "웹캠", "그래놀라", "반팔 티셔츠", "데님 팬츠"]}, {"name": "unit_price", "examples": ["21000", "48000", "9500", "19000", "49000"]}, {"name": "quantity", "examples": ["1", "2", "5", "3"]}, {"name": "discount_rate", "examples": ["0.0", "0.1", "0.05", "0.2"]}, {"name": "region", "examples": ["서울", "경기", "광주", "대전", "부산"]}, {"name": "is_member", "examples": ["Y", "N"]}]}', 'ACTIVE', NOW(), NOW())
ON DUPLICATE KEY UPDATE problem_set_id = VALUES(problem_set_id), original_file_name = VALUES(original_file_name), stored_file_name = VALUES(stored_file_name), file_url = VALUES(file_url), file_path = VALUES(file_path), file_size = VALUES(file_size), meta_data = VALUES(meta_data), status = VALUES(status), updated_at = VALUES(updated_at);

INSERT INTO lecture_problem_set (lecture_problem_set_id, course_id, lecture_id, problem_set_id, role, display_order) VALUES
(9002, 2000, 2102, 4001, 'MAIN', 1),
(9003, 2000, 2103, 4002, 'MAIN', 1),
(9004, 2000, 2104, 4003, 'MAIN', 1),
(9007, 2001, 2113, 4004, 'MAIN', 1),
(9008, 2001, 2114, 4005, 'MAIN', 1),
(9011, 2002, 2122, 4006, 'MAIN', 1),
(9012, 2002, 2123, 4007, 'MAIN', 1)
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id), lecture_id = VALUES(lecture_id), problem_set_id = VALUES(problem_set_id), role = VALUES(role), display_order = VALUES(display_order);

COMMIT;
