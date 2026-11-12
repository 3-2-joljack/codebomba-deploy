#!/usr/bin/env python3
"""코드봄바 초기 콘텐츠 생성기.

만드는 것
  content/datasets/*.csv   문제세트별 데이터셋 (고정 시드로 항상 같은 내용)
  content/content.sql      강좌, 강의, 문제 카테고리/세트/문제, 테스트케이스, 힌트, 데이터셋 행

검증하는 것
  문제마다 모범 답안 + 테스트케이스를 실제로 실행해 통과하는지,
  틀린 답안은 실패하는지 확인한다. 하나라도 어긋나면 파일을 쓰지 않고 종료한다.

실행: pandas 2.2.3 / numpy 2.1.3 / scikit-learn 1.5.2 (채점 러너와 같은 버전) 환경에서
  python content/build_content.py
"""
import csv
import json
import os
import random
import subprocess
import sys
import tempfile
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent
DATASET_DIR = HERE / "datasets"
BUCKET = os.environ.get("S3_BUCKET", "codebomba-lms-379959319287")
REGION = os.environ.get("AWS_REGION", "ap-northeast-2")
S3_PREFIX = "problem_dataset/seed"
OPERATOR_ID = 8  # 시드 계정 op@test.com (OPERATOR)

LOAD = 'import os\nimport pandas as pd\n\ndf = pd.read_csv(os.environ["DATASET_PATH"])\n'
HOWTO = (
    "\n\n[데이터 불러오기]\n"
    "import os\n"
    "import pandas as pd\n\n"
    'df = pd.read_csv(os.environ["DATASET_PATH"])\n\n'
    "[제출 방법]\n"
    "답을 result 변수에 담으면 채점됩니다."
)


# ----------------------------------------------------------------------------
# 데이터셋
# ----------------------------------------------------------------------------
def write_csv(name, header, rows):
    DATASET_DIR.mkdir(parents=True, exist_ok=True)
    path = DATASET_DIR / name
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    return path


def gen_cafe():
    r = random.Random(101)
    menus = [
        ("아메리카노", "커피", 4500, 30), ("카페라떼", "커피", 5000, 20), ("바닐라라떼", "커피", 5500, 12),
        ("콜드브루", "커피", 5200, 9), ("녹차라떼", "논커피", 5800, 7), ("자몽에이드", "논커피", 6000, 6),
        ("초코스무디", "논커피", 6300, 4), ("치즈케이크", "디저트", 6500, 6), ("크루아상", "디저트", 4200, 4),
        ("마카롱", "디저트", 3000, 2),
    ]
    weights = [m[3] for m in menus]
    start = datetime(2026, 3, 1)
    rows = []
    for i in range(1, 401):
        name, cat, price, _ = r.choices(menus, weights)[0]
        size = r.choices(["S", "M", "L"], [2, 5, 3])[0] if cat != "디저트" else "M"
        unit = price + {"S": -500, "M": 0, "L": 700}[size]
        rows.append([
            i, (start + timedelta(days=r.randrange(60))).strftime("%Y-%m-%d"), name, cat, size,
            r.choices([1, 2, 3, 4], [60, 25, 10, 5])[0], unit,
            r.choices(["신규", "단골"], [4, 6])[0], r.choices(["카드", "앱", "현금"], [6, 3, 1])[0],
        ])
    return write_csv("cafe_orders.csv",
                     ["order_id", "order_date", "menu", "category", "size", "quantity", "price",
                      "customer_type", "payment"], rows)


def gen_shop():
    r = random.Random(202)
    products = {
        "전자기기": [("무선 이어폰", 89000), ("보조배터리", 32000), ("블루투스 스피커", 65000), ("웹캠", 48000)],
        "의류": [("후드 집업", 59000), ("데님 팬츠", 49000), ("반팔 티셔츠", 19000)],
        "식품": [("원두 1kg", 24000), ("견과류 세트", 18000), ("그래놀라", 9500)],
        "생활용품": [("텀블러", 23000), ("디퓨저", 28000), ("수건 세트", 21000)],
        "도서": [("파이썬 입문서", 27000), ("데이터 분석 실무", 32000)],
    }
    cats = list(products)
    regions = ["서울", "경기", "부산", "대구", "광주", "대전"]
    start = datetime(2026, 1, 1)
    rows = []
    for i in range(1, 601):
        cat = r.choices(cats, [30, 25, 20, 15, 10])[0]
        prod, price = r.choice(products[cat])
        rows.append([
            f"O{i:05d}", (start + timedelta(days=r.randrange(120))).strftime("%Y-%m-%d"), cat, prod, price,
            r.choices([1, 2, 3, 5], [55, 28, 12, 5])[0], r.choice([0.0, 0.0, 0.0, 0.05, 0.1, 0.2]),
            r.choices(regions, [34, 26, 14, 10, 8, 8])[0], r.choices(["Y", "N"], [62, 38])[0],
        ])
    return write_csv("shop_orders.csv",
                     ["order_id", "order_date", "category", "product", "unit_price", "quantity",
                      "discount_rate", "region", "is_member"], rows)


# ----------------------------------------------------------------------------
# 문제 정의 도우미
# ----------------------------------------------------------------------------
def problem(title, body, difficulty, point, solution, tests, hints, explain, wrong, timeout=5000, data=True):
    """data=True 면 데이터셋을 쓰는 문제 — 불러오기 코드와 안내를 자동으로 붙인다."""
    prefix = LOAD + "\n" if data else ""
    return dict(title=title, content=body + (HOWTO if data else ""), difficulty=difficulty, point=point,
                solution=prefix + solution, tests=tests, hints=hints,
                explanation=explain + "\n\n[모범 답안]\n" + prefix + solution,
                wrong=[prefix + w for w in wrong], timeout=timeout)


def captured_output(code):
    """코드 조각을 실행해 표준 출력을 돌려준다 (출력 예측 문제의 정답을 직접 계산)."""
    import contextlib
    import io
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        exec(code, {})
    return buf.getvalue().strip()


def output_problem(title, code, difficulty, point, hints, explain, wrong_outputs):
    expected = captured_output(code)
    assert "\n" not in expected, title
    body = ("다음 파이썬 코드를 실행했을 때 출력되는 결과를 문자열로 result에 담으세요.\n\n"
            "[코드]\n" + code + "\n\n"
            "[제출 방법]\n"
            '출력 결과가 abc 라면  result = "abc"  처럼 작성합니다. 공백과 대소문자까지 같아야 합니다.\n'
            "코드를 직접 실행해 확인해도 좋지만, 먼저 손으로 따라가 보세요.")
    return problem(title, body, difficulty, point, f"result = {expected!r}",
                   ['assert result is not None, "result에 출력 결과를 담아야 합니다"',
                    f'assert str(result).strip() == {expected!r}, "출력 결과가 다릅니다"'],
                   hints, explain + f"\n\n출력 결과: {expected}", [f"result = {w!r}" for w in wrong_outputs],
                   data=False)


def function_problem(title, body, signature, difficulty, point, solution, calls, hints, explain, wrong):
    """solution 함수를 작성하는 문제. calls 는 호출식 문자열 목록이고, 기대값은 모범 답안을 실행해 얻는다."""
    scope = {}
    exec(solution, scope)
    expected = [(c, eval(c, scope)) for c in calls]
    body = (body + "\n\n[제출 방법]\n" + f"아래 형태의 함수를 완성하세요. 함수 이름과 매개변수는 바꾸지 마세요.\n\n{signature}\n    ...")
    visible = f'assert callable(solution), "solution 함수를 정의해야 합니다"\nassert solution{calls[0][8:]} == {expected[0][1]!r}, "예시 입력의 결과가 다릅니다"'
    hidden = "\n".join(f'assert {c} == {v!r}, "숨겨진 입력에서 결과가 다릅니다"' for c, v in expected[1:])
    return problem(title, body, difficulty, point, solution, [visible, hidden], hints, explain, wrong, data=False)


SQL_SCHEMA = """CREATE TABLE 학생 (학번 INTEGER PRIMARY KEY, 이름 TEXT, 학과 TEXT, 학년 INTEGER, 점수 INTEGER);
INSERT INTO 학생 VALUES
 (1001, '김민준', '컴퓨터공학', 3, 88), (1002, '이서연', '컴퓨터공학', 2, 95),
 (1003, '박지호', '전자공학', 4, 72), (1004, '최유진', '전자공학', 1, 81),
 (1005, '정하준', '경영학', 2, 67), (1006, '강서윤', '경영학', 3, 79),
 (1007, '조은우', '컴퓨터공학', 1, 76), (1008, '윤지아', '통계학', 4, 91);
CREATE TABLE 수강 (학번 INTEGER, 과목명 TEXT, 학점 INTEGER);
INSERT INTO 수강 VALUES
 (1001, '데이터베이스', 3), (1001, '운영체제', 3), (1002, '데이터베이스', 3), (1003, '회로이론', 3),
 (1005, '회계원리', 3), (1007, '자료구조', 3), (1008, '데이터베이스', 3), (1008, '통계학개론', 2);"""

SQL_TABLES = """[학생 테이블]
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
1008 | 통계학개론 | 2"""

SQL_HARNESS = ('import sqlite3\n'
               '_con = sqlite3.connect(":memory:")\n'
               f'_con.executescript("""{SQL_SCHEMA}""")\n'
               'def _rows(sql):\n'
               '    cur = _con.execute(str(sql).strip().rstrip(";"))\n'
               '    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in cur.fetchall()]\n')


def sql_rows(sql):
    import sqlite3
    con = sqlite3.connect(":memory:")
    con.executescript(SQL_SCHEMA)
    return [tuple(round(v, 2) if isinstance(v, float) else v for v in r) for r in con.execute(sql).fetchall()]


def sql_problem(title, ask, difficulty, point, solution_sql, ordered, hints, explain, wrong_sqls):
    expected = sql_rows(solution_sql)
    assert expected, title
    body = (ask + "\n\n" + SQL_TABLES + "\n\n"
            "[제출 방법]\n"
            'SQL 문을 문자열로 result에 담으세요. 예)  result = "SELECT 이름 FROM 학생"\n'
            "작성한 SQL은 위 데이터가 들어 있는 DB에서 실제로 실행되어 결과로 채점됩니다.")
    compare = "_actual == _expected" if ordered else "sorted(_actual, key=repr) == sorted(_expected, key=repr)"
    order_msg = "조회 결과 또는 행 순서가 다릅니다" if ordered else "조회 결과가 다릅니다"
    tests = [
        'assert isinstance(result, str) and result.strip().upper().startswith("SELECT"), "result는 SELECT로 시작하는 SQL 문자열이어야 합니다"',
        SQL_HARNESS + f"_expected = {expected!r}\n_actual = _rows(result)\n"
        f'assert len(_actual) == len(_expected), "조회된 행의 개수가 다릅니다"\n'
        f'assert {compare}, "{order_msg}"',
    ]
    return problem(title, body, difficulty, point, f"result = {solution_sql!r}", tests, hints,
                   explain + "\n\n정답 SQL: " + solution_sql, [f"result = {w!r}" for w in wrong_sqls], data=False)


def term_problem(title, ask, difficulty, point, answer, aliases, hints, explain, wrong_terms):
    accepted = sorted({a.replace(" ", "").lower() for a in [answer] + aliases})
    body = (ask + "\n\n[제출 방법]\n"
            '답을 문자열로 result에 담으세요. 예)  result = "정답"\n띄어쓰기와 영문 대소문자는 구분하지 않습니다.')
    tests = ['assert isinstance(result, str) and result.strip(), "result에 답을 문자열로 담아야 합니다"',
             f'assert str(result).replace(" ", "").lower() in {accepted!r}, "정답이 아닙니다"']
    return problem(title, body, difficulty, point, f"result = {answer!r}", tests, hints,
                   explain + f"\n\n정답: {answer}", [f"result = {w!r}" for w in wrong_terms], data=False)


# ----------------------------------------------------------------------------
# 문제세트
# ----------------------------------------------------------------------------
def build_exam_sets():
    sets = []

    # ---- 4001 출력 결과 맞히기 ---------------------------------------------
    sets.append(dict(
        id=4001, category=3001, file=None, difficulty="EASY",
        title="정처기 실기: 파이썬 출력 결과 맞히기",
        description="정보처리기사 실기에 자주 나오는 파이썬 코드의 실행 결과를 예측합니다. 슬라이싱, 리스트, 집합, 반복문, 함수를 다룹니다.",
        problems=[
            output_problem("문자열 슬라이싱",
                           'a = "REMEMBER NOVEMBER"\nb = a[:3] + a[12:16]\nc = "R AND %s" % "STR"\nprint(b + c)',
                           "EASY", 10,
                           ["a[:3]은 앞에서 3글자, a[12:16]은 인덱스 12부터 15까지입니다.", '"R AND %s" % "STR" 은 %s 자리에 STR이 들어갑니다.'],
                           "슬라이싱 a[시작:끝]은 끝 인덱스를 포함하지 않습니다. a[:3]은 REM, a[12:16]은 EMBE이고, 포맷 문자열 결과 R AND STR을 이어 붙입니다.",
                           ["REMEMBER NOVEMBER", "REMEMBR AND STR"]),
            output_problem("리스트와 map",
                           "a = [1, 2, 3, 4, 5]\na = list(map(lambda num: num + 100, a))\nprint(a)",
                           "EASY", 10,
                           ["map은 리스트의 모든 요소에 함수를 적용합니다.", "리스트를 print 하면 대괄호와 쉼표, 공백이 함께 출력됩니다."],
                           "map(함수, 리스트)는 각 요소에 함수를 적용한 결과를 만들고, list()로 다시 리스트로 바꿉니다. 리스트 출력 형식은 [값, 값, ...] 입니다.",
                           ["[1, 2, 3, 4, 5]", "101 102 103 104 105"]),
            output_problem("집합(set) 연산",
                           "asia = {'한국', '중국', '일본'}\nasia.add('베트남')\nasia.add('중국')\nasia.remove('일본')\n"
                           "asia.update({'홍콩', '한국', '태국'})\nprint(len(asia))",
                           "EASY", 10,
                           ["집합은 중복을 허용하지 않습니다.", "이미 있는 값을 add 하거나 update 해도 개수는 늘지 않습니다."],
                           "집합은 중복을 저장하지 않습니다. 한국, 중국, 베트남에 홍콩과 태국이 더해져 5개가 됩니다. 중국과 한국은 이미 있어 추가되지 않습니다.",
                           ["6", "7"]),
            output_problem("반복문과 조건문",
                           "total = 0\nfor i in range(1, 11):\n    if i % 3 == 0:\n        total += i\nprint(total)",
                           "EASY", 10,
                           ["range(1, 11)은 1부터 10까지입니다.", "3의 배수만 더합니다: 3, 6, 9"],
                           "range(1, 11)은 끝값 11을 포함하지 않아 1~10을 순회합니다. 3으로 나눈 나머지가 0인 3, 6, 9만 더해집니다.",
                           ["55", "30"]),
            output_problem("함수의 기본 매개변수",
                           "def func(num1, num2=2):\n    print('a =', num1, 'b =', num2)\n\nfunc(20)",
                           "EASY", 10,
                           ["인자를 하나만 넘기면 num2는 기본값을 씁니다.", "print에 쉼표로 여러 값을 넘기면 사이에 공백이 하나씩 들어갑니다."],
                           "num2를 생략하면 기본값 2가 쓰입니다. print는 쉼표로 구분한 값 사이에 공백을 넣어 출력합니다.",
                           ["a = 20 b = 20", "a=20 b=2"]),
        ]))

    # ---- 4002 기초 코딩 -----------------------------------------------------
    sets.append(dict(
        id=4002, category=3001, file=None, difficulty="EASY",
        title="정처기 실기: 파이썬 기초 코딩",
        description="반복문, 조건문, 리스트, 문자열, 딕셔너리를 이용해 짧은 함수를 직접 작성합니다.",
        problems=[
            function_problem("1부터 n까지의 합",
                             "정수 n이 주어질 때 1부터 n까지의 합을 반환하는 함수를 작성하세요.\n예) n이 10이면 55",
                             "def solution(n):", "EASY", 10,
                             "def solution(n):\n    total = 0\n    for i in range(1, n + 1):\n        total += i\n    return total",
                             ["solution(10)", "solution(1)", "solution(100)", "solution(37)"],
                             ["range(1, n + 1)로 1부터 n까지 순회할 수 있습니다.", "누적할 변수를 0으로 두고 하나씩 더하세요."],
                             "range의 끝값은 포함되지 않으므로 n + 1까지 지정합니다. sum(range(1, n + 1))로도 구할 수 있습니다.",
                             ["def solution(n):\n    return sum(range(1, n))", "def solution(n):\n    return n"]),
            function_problem("짝수만 골라내기",
                             "정수 리스트 nums가 주어질 때, 짝수만 원래 순서대로 담은 리스트를 반환하는 함수를 작성하세요.\n예) [1, 2, 3, 4, 6] 이면 [2, 4, 6]",
                             "def solution(nums):", "EASY", 10,
                             "def solution(nums):\n    result = []\n    for n in nums:\n        if n % 2 == 0:\n            result.append(n)\n    return result",
                             ["solution([1, 2, 3, 4, 6])", "solution([1, 3, 5])", "solution([10, 7, 8, 0, -2])", "solution([])"],
                             ["2로 나눈 나머지가 0이면 짝수입니다.", "빈 리스트를 만들고 조건에 맞는 값만 append 하세요."],
                             "나머지 연산자 %로 짝수를 판별하고 append로 모읍니다. 리스트 컴프리헨션 [n for n in nums if n % 2 == 0]도 같은 결과입니다.",
                             ["def solution(nums):\n    return [n for n in nums if n % 2 == 1]", "def solution(nums):\n    return nums"]),
            function_problem("문자열 뒤집기",
                             "문자열 s가 주어질 때 글자 순서를 거꾸로 뒤집은 문자열을 반환하는 함수를 작성하세요.\n예) \"python\" 이면 \"nohtyp\"",
                             "def solution(s):", "EASY", 10,
                             "def solution(s):\n    return s[::-1]",
                             ['solution("python")', 'solution("a")', 'solution("정보처리기사")', 'solution("level up")'],
                             ["슬라이싱은 [시작:끝:간격] 형태로 쓸 수 있습니다.", "간격을 -1로 주면 거꾸로 읽습니다: s[::-1]"],
                             "슬라이싱의 세 번째 값은 간격입니다. s[::-1]은 끝에서부터 한 글자씩 읽어 뒤집힌 문자열을 만듭니다.",
                             ["def solution(s):\n    return s", "def solution(s):\n    return s[1:] + s[:1]"]),
            function_problem("최댓값과 최솟값의 차",
                             "정수 리스트 nums가 주어질 때 가장 큰 값과 가장 작은 값의 차를 반환하는 함수를 작성하세요. nums에는 값이 하나 이상 들어 있습니다.\n예) [3, 9, 1, 7] 이면 8",
                             "def solution(nums):", "EASY", 10,
                             "def solution(nums):\n    return max(nums) - min(nums)",
                             ["solution([3, 9, 1, 7])", "solution([5])", "solution([-4, 10, 0])", "solution([2, 2, 2, 3])"],
                             ["내장 함수 max와 min을 쓸 수 있습니다.", "max(nums) - min(nums)"],
                             "max와 min은 리스트에서 가장 큰 값과 작은 값을 돌려줍니다. 값이 하나뿐이면 차는 0입니다.",
                             ["def solution(nums):\n    return max(nums)", "def solution(nums):\n    return nums[-1] - nums[0]"]),
            function_problem("글자별 등장 횟수 세기",
                             "문자열 s가 주어질 때 각 글자가 몇 번 나오는지 딕셔너리로 반환하는 함수를 작성하세요.\n예) \"banana\" 이면 {\"b\": 1, \"a\": 3, \"n\": 2}",
                             "def solution(s):", "MEDIUM", 15,
                             "def solution(s):\n    counts = {}\n    for ch in s:\n        counts[ch] = counts.get(ch, 0) + 1\n    return counts",
                             ['solution("banana")', 'solution("")', 'solution("aAbB")', 'solution("mississippi")'],
                             ["빈 딕셔너리를 만들고 글자를 하나씩 살펴보세요.", "counts.get(ch, 0)은 키가 없으면 0을 돌려줍니다."],
                             "딕셔너리의 get(키, 기본값)을 쓰면 처음 나온 글자도 오류 없이 셀 수 있습니다. 대문자와 소문자는 서로 다른 글자입니다.",
                             ["def solution(s):\n    return {ch: 1 for ch in s}", "def solution(s):\n    return len(s)"]),
        ]))

    # ---- 4003 기초 알고리즘 -------------------------------------------------
    sets.append(dict(
        id=4003, category=3001, file=None, difficulty="MEDIUM",
        title="정처기 실기: 기초 알고리즘 구현",
        description="최대공약수, 소수 판별, 진법 변환, 정렬, 피보나치처럼 정처기 단골 알고리즘을 함수로 구현합니다.",
        problems=[
            function_problem("최대공약수 구하기",
                             "양의 정수 a, b의 최대공약수를 반환하는 함수를 작성하세요.\n예) 12와 18의 최대공약수는 6",
                             "def solution(a, b):", "EASY", 10,
                             "def solution(a, b):\n    while b != 0:\n        a, b = b, a % b\n    return a",
                             ["solution(12, 18)", "solution(7, 13)", "solution(100, 75)", "solution(9, 9)", "solution(1, 50)"],
                             ["유클리드 호제법: a를 b로 나눈 나머지를 이용합니다.", "b가 0이 될 때까지 (a, b)를 (b, a % b)로 바꿉니다."],
                             "유클리드 호제법은 gcd(a, b) = gcd(b, a % b) 성질을 이용합니다. 나머지가 0이 되면 그때의 a가 최대공약수입니다.",
                             ["def solution(a, b):\n    return min(a, b)", "def solution(a, b):\n    return a * b"]),
            function_problem("소수 판별하기",
                             "정수 n이 소수이면 True, 아니면 False를 반환하는 함수를 작성하세요. 1 이하의 수는 소수가 아닙니다.\n예) 7은 True, 9는 False",
                             "def solution(n):", "MEDIUM", 15,
                             "def solution(n):\n    if n < 2:\n        return False\n    for i in range(2, int(n ** 0.5) + 1):\n        if n % i == 0:\n            return False\n    return True",
                             ["solution(7)", "solution(9)", "solution(1)", "solution(2)", "solution(97)", "solution(91)", "solution(0)"],
                             ["소수는 1과 자기 자신으로만 나누어떨어지는 2 이상의 수입니다.", "2부터 n-1까지 나누어 보고, 나누어떨어지는 수가 있으면 소수가 아닙니다."],
                             "2부터 차례로 나누어 보며 약수가 있는지 확인합니다. 약수는 제곱근 이하에서 반드시 하나 발견되므로 제곱근까지만 검사해도 됩니다. 1과 0은 소수가 아닙니다.",
                             ["def solution(n):\n    return n % 2 == 1", "def solution(n):\n    for i in range(2, n):\n        if n % i == 0:\n            return False\n    return True"]),
            function_problem("10진수를 2진수로 바꾸기",
                             "0 이상의 정수 n을 2진수 문자열로 바꿔 반환하는 함수를 작성하세요.\n예) 10 이면 \"1010\", 0 이면 \"0\"",
                             "def solution(n):", "MEDIUM", 15,
                             "def solution(n):\n    if n == 0:\n        return \"0\"\n    digits = \"\"\n    while n > 0:\n        digits = str(n % 2) + digits\n        n //= 2\n    return digits",
                             ["solution(10)", "solution(0)", "solution(1)", "solution(255)", "solution(37)"],
                             ["2로 나눈 나머지를 거꾸로 이어 붙이면 2진수가 됩니다.", "몫이 0이 될 때까지 n을 2로 나누세요. n이 0인 경우를 따로 처리해야 합니다."],
                             "2로 나눈 나머지를 앞쪽에 붙여 가며 몫이 0이 될 때까지 반복합니다. 내장 함수 bin(n)[2:]로도 같은 결과를 얻을 수 있습니다.",
                             ["def solution(n):\n    return bin(n)", "def solution(n):\n    return str(n)"]),
            function_problem("오름차순 정렬하기",
                             "정수 리스트 nums를 오름차순으로 정렬한 새 리스트를 반환하는 함수를 작성하세요.\n예) [5, 2, 9, 1] 이면 [1, 2, 5, 9]\n버블 정렬을 직접 구현해 보는 것을 권장합니다.",
                             "def solution(nums):", "MEDIUM", 15,
                             "def solution(nums):\n    arr = list(nums)\n    n = len(arr)\n    for i in range(n - 1):\n        for j in range(n - 1 - i):\n            if arr[j] > arr[j + 1]:\n                arr[j], arr[j + 1] = arr[j + 1], arr[j]\n    return arr",
                             ["solution([5, 2, 9, 1])", "solution([])", "solution([3])", "solution([4, 4, 1, -7, 0])", "solution([9, 8, 7, 6, 5])"],
                             ["버블 정렬은 이웃한 두 값을 비교해 큰 값을 뒤로 보냅니다.", "한 번 훑을 때마다 가장 큰 값이 맨 뒤에 자리 잡으므로, 다음에는 그 앞까지만 비교합니다."],
                             "버블 정렬은 이웃한 값을 비교하고 교환하는 과정을 반복합니다. 바깥 반복이 한 번 끝날 때마다 뒤쪽 자리가 하나씩 확정됩니다. 시간 복잡도는 O(n²)입니다.",
                             ["def solution(nums):\n    return sorted(nums, reverse=True)", "def solution(nums):\n    return nums"]),
            function_problem("피보나치 수 구하기",
                             "피보나치 수열은 1, 1, 2, 3, 5, 8, ... 처럼 앞의 두 수를 더해 만듭니다. n번째 피보나치 수를 반환하는 함수를 작성하세요.\n예) n이 1이면 1, n이 6이면 8",
                             "def solution(n):", "MEDIUM", 15,
                             "def solution(n):\n    a, b = 1, 1\n    for _ in range(n - 1):\n        a, b = b, a + b\n    return a",
                             ["solution(6)", "solution(1)", "solution(2)", "solution(10)", "solution(20)"],
                             ["첫 번째와 두 번째 수는 모두 1입니다.", "두 변수에 연속한 두 수를 담고, 한 칸씩 앞으로 옮겨 가세요."],
                             "a, b = b, a + b 로 두 변수를 동시에 갱신하면 임시 변수 없이 다음 항으로 넘어갈 수 있습니다. 재귀로도 풀 수 있지만 반복문이 훨씬 빠릅니다.",
                             ["def solution(n):\n    return n", "def solution(n):\n    a, b = 1, 1\n    for _ in range(n):\n        a, b = b, a + b\n    return a"]),
        ]))

    # ---- 4004 SQL -----------------------------------------------------------
    sets.append(dict(
        id=4004, category=3002, file=None, difficulty="EASY",
        title="정처기 실기: SQL 작성",
        description="학생, 수강 테이블을 대상으로 WHERE, ORDER BY, GROUP BY, HAVING, JOIN을 사용하는 SELECT 문을 작성합니다.",
        problems=[
            sql_problem("조건에 맞는 행 조회 (WHERE)",
                        "학생 테이블에서 학과가 '컴퓨터공학'인 학생의 이름과 점수를 조회하는 SQL을 작성하세요. 컬럼 순서는 이름, 점수입니다.",
                        "EASY", 10, "SELECT 이름, 점수 FROM 학생 WHERE 학과 = '컴퓨터공학'", False,
                        ["조건은 WHERE 절에 씁니다.", "문자열 값은 작은따옴표로 감쌉니다: 학과 = '컴퓨터공학'"],
                        "SELECT 뒤에 조회할 컬럼을, WHERE 뒤에 조건을 씁니다. 문자열 리터럴은 작은따옴표를 사용합니다.",
                        ["SELECT 이름, 점수 FROM 학생", "SELECT 이름 FROM 학생 WHERE 학과 = '컴퓨터공학'"]),
            sql_problem("정렬해서 조회 (ORDER BY)",
                        "학생 테이블에서 모든 학생의 이름과 점수를 점수가 높은 순서로 조회하는 SQL을 작성하세요. 컬럼 순서는 이름, 점수입니다.",
                        "EASY", 10, "SELECT 이름, 점수 FROM 학생 ORDER BY 점수 DESC", True,
                        ["정렬은 ORDER BY 절로 합니다.", "내림차순은 DESC, 오름차순은 ASC(기본값)입니다."],
                        "ORDER BY 컬럼 DESC는 큰 값부터 정렬합니다. 생략하면 오름차순(ASC)입니다.",
                        ["SELECT 이름, 점수 FROM 학생 ORDER BY 점수", "SELECT 이름, 점수 FROM 학생"]),
            sql_problem("그룹별 개수 세기 (GROUP BY)",
                        "학생 테이블에서 학과별 학생 수를 조회하는 SQL을 작성하세요. 컬럼 순서는 학과, 학생 수입니다.",
                        "EASY", 15, "SELECT 학과, COUNT(*) FROM 학생 GROUP BY 학과", False,
                        ["같은 학과끼리 묶으려면 GROUP BY를 씁니다.", "묶인 그룹의 행 수는 COUNT(*)로 셉니다."],
                        "GROUP BY 학과는 학과가 같은 행을 한 그룹으로 묶고, COUNT(*)는 그룹마다 행 수를 셉니다.",
                        ["SELECT 학과, COUNT(*) FROM 학생", "SELECT 학과, SUM(점수) FROM 학생 GROUP BY 학과"]),
            sql_problem("그룹에 조건 걸기 (HAVING)",
                        "학생 테이블에서 학과별 평균 점수가 80점 이상인 학과만 조회하는 SQL을 작성하세요. 컬럼 순서는 학과, 평균 점수입니다.",
                        "MEDIUM", 15, "SELECT 학과, AVG(점수) FROM 학생 GROUP BY 학과 HAVING AVG(점수) >= 80", False,
                        ["그룹에 대한 조건은 WHERE가 아니라 HAVING에 씁니다.", "평균은 AVG(점수)로 구합니다."],
                        "WHERE는 그룹으로 묶기 전의 행에, HAVING은 묶은 뒤의 그룹에 조건을 겁니다. 집계 함수 조건은 HAVING에만 쓸 수 있습니다.",
                        ["SELECT 학과, AVG(점수) FROM 학생 GROUP BY 학과", "SELECT 학과, AVG(점수) FROM 학생 WHERE 점수 >= 80 GROUP BY 학과"]),
            sql_problem("두 테이블 묶기 (JOIN)",
                        "'데이터베이스' 과목을 수강한 학생의 이름을 조회하는 SQL을 작성하세요. 학생 테이블과 수강 테이블은 학번으로 연결됩니다. 조회 컬럼은 이름 하나입니다.",
                        "MEDIUM", 20, "SELECT 학생.이름 FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번 WHERE 수강.과목명 = '데이터베이스'", False,
                        ["두 테이블을 학번이 같은 행끼리 연결해야 합니다.", "FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번 형태로 묶은 뒤 WHERE로 과목명을 거르세요."],
                        "JOIN ... ON 으로 두 테이블의 학번이 같은 행을 연결한 뒤, 과목명 조건으로 거릅니다. 서브쿼리 WHERE 학번 IN (SELECT 학번 FROM 수강 WHERE ...)로도 풀 수 있습니다.",
                        ["SELECT 이름 FROM 학생", "SELECT 학생.이름 FROM 학생 JOIN 수강 ON 학생.학번 = 수강.학번"]),
        ]))

    # ---- 4005 핵심 용어 -----------------------------------------------------
    sets.append(dict(
        id=4005, category=3003, file=None, difficulty="EASY",
        title="정처기 핵심 이론: 용어 단답",
        description="응집도, 결합도, OSI 7계층, 트랜잭션, 정규화처럼 필기와 실기에 반복 출제되는 핵심 용어를 단답형으로 확인합니다.",
        problems=[
            term_problem("가장 바람직한 응집도",
                         "모듈 내부의 모든 기능 요소가 단일한 목적을 위해 수행되는 경우로, 응집도가 가장 높은 단계의 이름을 쓰세요.",
                         "EASY", 10, "기능적 응집도", ["기능적", "기능 응집도", "functional cohesion", "functional"],
                         ["응집도는 우연적 → 논리적 → 시간적 → 절차적 → 통신적 → 순차적 → 기능적 순으로 높아집니다.", "단일 '기능'을 수행한다는 점에 주목하세요."],
                         "응집도는 모듈 내부 요소들의 관련 정도입니다. 높을수록 좋으며, 가장 높은 단계는 모든 요소가 하나의 기능을 수행하는 기능적 응집도입니다.",
                         ["우연적 응집도", "순차적 응집도"]),
            term_problem("가장 바람직한 결합도",
                         "모듈 간 인터페이스로 단순한 자료 요소(매개변수)만 전달되는 경우로, 결합도가 가장 낮은 단계의 이름을 쓰세요.",
                         "EASY", 10, "자료 결합도", ["자료", "데이터 결합도", "데이터", "data coupling", "data"],
                         ["결합도는 내용 → 공통 → 외부 → 제어 → 스탬프 → 자료 순으로 낮아집니다.", "단순 '자료'만 주고받는 경우입니다."],
                         "결합도는 모듈 사이의 의존 정도입니다. 낮을수록 좋으며, 가장 낮은 단계는 단순 자료만 전달하는 자료 결합도입니다.",
                         ["내용 결합도", "스탬프 결합도"]),
            term_problem("경로를 설정하는 OSI 계층",
                         "OSI 7계층 중 패킷의 경로 설정(라우팅)과 논리 주소(IP) 지정을 담당하는 계층의 이름을 쓰세요.",
                         "EASY", 10, "네트워크 계층", ["네트워크", "network layer", "network", "3계층"],
                         ["OSI 7계층은 물리 → 데이터링크 → 네트워크 → 전송 → 세션 → 표현 → 응용 순입니다.", "라우터가 동작하는 계층입니다."],
                         "네트워크 계층(3계층)은 IP 주소를 기반으로 목적지까지의 경로를 정합니다. 대표 장비는 라우터, 대표 프로토콜은 IP입니다.",
                         ["전송 계층", "데이터링크 계층"]),
            term_problem("트랜잭션의 특성",
                         "트랜잭션의 연산은 데이터베이스에 모두 반영되거나 전혀 반영되지 않아야 한다는 특성의 이름을 쓰세요.",
                         "EASY", 10, "원자성", ["atomicity"],
                         ["트랜잭션의 4가지 특성은 ACID라고 부릅니다.", "더 쪼갤 수 없는 단위라는 뜻입니다. All or Nothing."],
                         "ACID는 원자성(Atomicity), 일관성(Consistency), 독립성(Isolation), 영속성(Durability)입니다. 전부 수행되거나 전혀 수행되지 않는 성질이 원자성입니다.",
                         ["일관성", "영속성"]),
            term_problem("부분 함수 종속을 제거하는 정규형",
                         "제1정규형을 만족하는 릴레이션에서 부분 함수적 종속을 제거해 만드는 정규형의 이름을 쓰세요.",
                         "MEDIUM", 15, "제2정규형", ["2정규형", "2NF", "제2정규화", "second normal form"],
                         ["정규화 과정: 도메인 원자값(1NF) → 부분 함수 종속 제거 → 이행 함수 종속 제거 → 결정자가 후보키(BCNF)", "1NF 바로 다음 단계입니다."],
                         "정규화는 '도부이결다조'로 외웁니다. 도메인 원자값(1NF), 부분 함수 종속 제거(2NF), 이행 함수 종속 제거(3NF), 결정자이면서 후보키가 아닌 것 제거(BCNF), 다치 종속 제거(4NF), 조인 종속 제거(5NF).",
                         ["제3정규형", "제1정규형"]),
        ]))
    return sets


def build_sets():
    sets = build_exam_sets()

    # ---- 4006 카페 ---------------------------------------------------------
    df = pd.read_csv(gen_cafe())
    qty = df.groupby("menu")["quantity"].sum().sort_values(ascending=False)
    assert qty.iloc[0] > qty.iloc[1]
    total = int((df["price"] * df["quantity"]).sum())
    sets.append(dict(
        id=4006, category=3004, file="cafe_orders.csv", difficulty="EASY",
        title="카페 주문 데이터로 시작하는 pandas",
        description="카페 주문 400건으로 DataFrame의 크기 확인, 고유값 세기, 그룹 집계, 파생 계산을 연습합니다.",
        problems=[
            problem("데이터 크기 확인하기",
                    "카페 주문 데이터의 행 개수와 열 개수를 (행, 열) 튜플로 result에 담으세요.",
                    "EASY", 10, "result = df.shape",
                    ['assert isinstance(result, tuple) and len(result) == 2, "result는 (행, 열) 형태의 튜플이어야 합니다"',
                     f'assert tuple(int(v) for v in result) == {tuple(df.shape)}, "행 또는 열 개수가 다릅니다"'],
                    ["DataFrame에는 크기를 알려주는 속성이 있습니다.", "df.shape는 (행 개수, 열 개수) 튜플을 돌려줍니다."],
                    "df.shape 속성은 DataFrame의 (행 개수, 열 개수)를 튜플로 돌려줍니다. 괄호 없이 속성으로 접근합니다.",
                    ["result = len(df)", "result = (df.shape[1], df.shape[0])"]),
            problem("메뉴 종류 세기",
                    "menu 컬럼에 서로 다른 메뉴가 몇 가지 있는지 정수로 result에 담으세요.",
                    "EASY", 10, 'result = df["menu"].nunique()',
                    ['assert not isinstance(result, bool) and int(result) == result, "result는 정수여야 합니다"',
                     f'assert int(result) == {int(df["menu"].nunique())}, "메뉴 종류 수가 다릅니다"'],
                    ["중복을 제거한 값의 개수를 세는 메서드를 찾아보세요.", 'df["menu"].nunique() 또는 len(df["menu"].unique())를 쓸 수 있습니다.'],
                    "nunique()는 컬럼에서 중복을 제외한 고유값의 개수를 돌려줍니다.",
                    ['result = len(df["menu"])', 'result = df["category"].nunique()']),
            problem("가장 많이 팔린 메뉴 찾기",
                    "quantity(판매 수량) 합계가 가장 큰 메뉴의 이름을 문자열로 result에 담으세요.",
                    "EASY", 15, 'result = df.groupby("menu")["quantity"].sum().idxmax()',
                    ['assert isinstance(result, str), "result는 메뉴 이름(문자열)이어야 합니다"',
                     f'assert result == {qty.index[0]!r}, "판매 수량 합계가 가장 큰 메뉴가 아닙니다"'],
                    ["메뉴별로 묶은 뒤 quantity를 더해야 합니다.", "groupby 결과에 sum()을 적용하고 idxmax()로 가장 큰 값의 인덱스를 구하세요."],
                    "groupby(\"menu\")로 메뉴별로 묶고 quantity 합계를 구한 뒤, idxmax()로 합계가 가장 큰 메뉴 이름을 얻습니다. "
                    "주문 건수가 아니라 수량 합계 기준이라는 점에 주의합니다.",
                    [f'result = {qty.index[1]!r}', 'result = df["quantity"].max()']),
            problem("총 매출 계산하기",
                    "price는 1잔(1개)의 가격이고 quantity는 수량입니다. 전체 주문의 총 매출(price × quantity의 합)을 정수로 result에 담으세요.",
                    "EASY", 15, 'result = (df["price"] * df["quantity"]).sum()',
                    ['assert not isinstance(result, bool) and float(result) == int(result), "result는 정수 금액이어야 합니다"',
                     f'assert int(result) == {total}, "총 매출이 다릅니다"'],
                    ["두 컬럼을 곱하면 주문별 금액 Series가 됩니다.", '(df["price"] * df["quantity"]).sum()'],
                    "컬럼끼리 곱하면 행마다 계산된 Series가 만들어지고, sum()으로 전체 합계를 구합니다.",
                    ['result = df["price"].sum()', 'result = df["price"].sum() * df["quantity"].sum()']),
        ]))

    # ---- 4007 쇼핑몰 -------------------------------------------------------
    df = pd.read_csv(gen_shop())
    df["amount"] = df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])
    by_cat = {k: round(float(v), 1) for k, v in df.groupby("category")["amount"].sum().items()}
    by_region = df.groupby("region")["amount"].sum().sort_values(ascending=False)
    assert by_region.iloc[0] - by_region.iloc[1] > 1000
    sol_amount = 'df["amount"] = df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])\n'
    sets.append(dict(
        id=4007, category=3004, file="shop_orders.csv", difficulty="EASY",
        title="온라인 쇼핑몰 주문 데이터 매출 분석",
        description="쇼핑몰 주문 600건으로 조건 필터링, 파생 컬럼 만들기, 카테고리별 집계를 연습합니다.",
        problems=[
            problem("회원 주문 건수 세기",
                    "is_member 컬럼은 회원 주문이면 \"Y\", 비회원이면 \"N\"입니다. 회원 주문 건수를 정수로 result에 담으세요.",
                    "EASY", 10, 'result = (df["is_member"] == "Y").sum()',
                    ['assert not isinstance(result, bool) and int(result) == result, "result는 정수여야 합니다"',
                     f'assert int(result) == {int((df["is_member"] == "Y").sum())}, "회원 주문 건수가 다릅니다"'],
                    ["조건식의 결과는 True/False Series입니다.", "True는 1로 계산되므로 조건식에 sum()을 쓰면 개수가 됩니다."],
                    "df[\"is_member\"] == \"Y\"는 불리언 Series를 만들고, sum()은 True의 개수를 셉니다. len(df[조건])으로도 구할 수 있습니다.",
                    ['result = len(df)', 'result = (df["is_member"] == "N").sum()']),
            problem("주문 금액 컬럼 만들기",
                    "주문 금액은 unit_price × quantity × (1 - discount_rate) 입니다. 이 값을 amount 컬럼으로 추가한 뒤, "
                    "amount의 평균을 소수 둘째 자리까지 반올림해 result에 담으세요.",
                    "EASY", 15, sol_amount + 'result = round(df["amount"].mean(), 2)',
                    ['assert "amount" in df.columns, "df에 amount 컬럼을 추가해야 합니다"',
                     f'assert abs(float(result) - {round(float(df["amount"].mean()), 2)}) < 0.01, "평균 주문 금액이 다릅니다"'],
                    ["여러 컬럼을 연산한 결과를 새 컬럼 이름에 대입하면 컬럼이 추가됩니다.", "할인율이 0.1이면 실제 금액은 0.9배입니다."],
                    "df[\"amount\"] = ... 형태로 파생 컬럼을 만들고 mean()으로 평균을 구합니다. 할인율은 (1 - discount_rate)로 반영합니다.",
                    ['df["amount"] = df["unit_price"] * df["quantity"]\nresult = round(df["amount"].mean(), 2)',
                     'result = round((df["unit_price"] * df["quantity"] * (1 - df["discount_rate"])).mean(), 2)']),
            problem("카테고리별 매출 합계",
                    "amount(주문 금액 = unit_price × quantity × (1 - discount_rate))를 구한 뒤, category별 amount 합계를 "
                    "Series로 result에 담으세요. 인덱스는 카테고리 이름이어야 합니다.",
                    "MEDIUM", 15, sol_amount + 'result = df.groupby("category")["amount"].sum()',
                    ['assert hasattr(result, "index") and len(result) == 5, "result는 카테고리 5개를 인덱스로 갖는 Series여야 합니다"',
                     f'expected = {by_cat!r}\nactual = dict(result)\n'
                     'assert set(actual) == set(expected), "카테고리 이름이 다릅니다"\n'
                     'assert all(abs(float(actual[k]) - expected[k]) < 1 for k in expected), "카테고리별 합계가 다릅니다"'],
                    ["먼저 amount 컬럼이 있어야 합니다.", 'df.groupby("category")["amount"].sum()'],
                    "groupby로 카테고리별로 묶고 amount 합계를 구하면 카테고리 이름을 인덱스로 갖는 Series가 됩니다.",
                    [sol_amount + 'result = df.groupby("category")["amount"].mean()',
                     'result = df.groupby("category")["unit_price"].sum()']),
            problem("매출 1위 지역 찾기",
                    "region별 amount(주문 금액) 합계가 가장 큰 지역 이름을 문자열로 result에 담으세요.",
                    "MEDIUM", 15, sol_amount + 'result = df.groupby("region")["amount"].sum().idxmax()',
                    ['assert isinstance(result, str), "result는 지역 이름(문자열)이어야 합니다"',
                     f'assert result == {by_region.index[0]!r}, "매출 합계가 가장 큰 지역이 아닙니다"'],
                    ["앞 문제의 groupby를 region에 적용해 보세요.", "합계 Series에서 idxmax()는 가장 큰 값의 인덱스를 돌려줍니다."],
                    "지역별 amount 합계를 구하고 idxmax()로 1위 지역을 얻습니다. sort_values(ascending=False).index[0]도 같은 결과입니다.",
                    [f'result = {by_region.index[1]!r}', 'result = df["region"].value_counts().idxmin()']),
        ]))
    return sets


# ----------------------------------------------------------------------------
# 검증: 실제로 실행해 본다 (채점기와 같은 방식 — 사용자 코드 뒤에 테스트 코드를 붙인다)
# ----------------------------------------------------------------------------
def run(code, dataset):
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "solution.py"
        path.write_text(code, encoding="utf-8")
        env = {"PATH": os.environ.get("PATH", "")}
        if dataset:
            env["DATASET_PATH"] = str(dataset)
        res = subprocess.run([sys.executable, str(path)], cwd=tmp, env=env, capture_output=True, text=True, timeout=60)
        return res.returncode == 0, res.stderr.strip().splitlines()[-1:] or [""]


def verify(sets):
    ok = True
    for s in sets:
        dataset = DATASET_DIR / s["file"] if s.get("file") else None
        for p in s["problems"]:
            for n, test in enumerate(p["tests"], 1):
                passed, err = run(p["solution"] + "\n\n" + test, dataset)
                if not passed:
                    ok = False
                    print(f"FAIL 모범답안이 테스트 {n} 실패: [{s['id']}] {p['title']} :: {err[0]}")
            for n, wrong in enumerate(p["wrong"], 1):
                if all(run(wrong + "\n\n" + test, dataset)[0] for test in p["tests"]):
                    ok = False
                    print(f"FAIL 오답 {n}이 전부 통과: [{s['id']}] {p['title']}")
            if all(run("result = None\n\n" + test, dataset)[0] for test in p["tests"]):
                ok = False
                print(f"FAIL 빈 답안이 통과: [{s['id']}] {p['title']}")
    return ok


# ----------------------------------------------------------------------------
# SQL
# ----------------------------------------------------------------------------
def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("\\", "\\\\").replace("'", "''") + "'"


def insert(table, cols, rows, key_cols):
    lines = [f"INSERT INTO {table} ({', '.join(cols)}) VALUES"]
    lines.append(",\n".join("(" + ", ".join(q(v) if not (isinstance(v, str) and v == "NOW()") else "NOW()" for v in r) + ")" for r in rows))
    updates = [c for c in cols if c not in key_cols and c != "created_at"]
    lines.append("ON DUPLICATE KEY UPDATE " + ", ".join(f"{c} = VALUES({c})" for c in updates) + ";")
    return "\n".join(lines) + "\n"


def metadata(path):
    with open(path, encoding="utf-8") as f:
        rows = list(csv.reader(f))
    cols = []
    for i, name in enumerate(rows[0]):
        seen = []
        for r in rows[1:201]:
            if r[i].strip() and r[i] not in seen:
                seen.append(r[i])
            if len(seen) == 5:
                break
        cols.append({"name": name, "examples": seen})
    return json.dumps({"columns": cols}, ensure_ascii=False)


CATEGORIES = [
    (3001, "정처기 프로그래밍 언어", "정보처리기사 실기의 파이썬 출력 예측, 기초 코딩, 알고리즘 구현 문제 분야입니다."),
    (3002, "정처기 SQL", "정보처리기사 실기의 SELECT, GROUP BY, JOIN 등 SQL 작성 문제 분야입니다."),
    (3003, "정처기 핵심 이론", "응집도, 결합도, OSI 7계층, 정규화 등 반복 출제되는 핵심 용어 문제 분야입니다."),
    (3004, "pandas 데이터 분석", "CSV 데이터를 pandas로 불러와 크기 확인, 필터링, 그룹 집계를 연습하는 분야입니다."),
]

COURSES = [
    (2000, 1002, "정보처리기사 실기 대비: 파이썬 프로그래밍",
     "정보처리기사 실기의 프로그래밍 언어 활용 영역을 파이썬으로 준비합니다. 출력 결과 예측부터 기초 알고리즘 구현까지 단계별로 연습합니다.",
     "https://placehold.co/640x360?text=Python+for+Exam"),
    (2001, 1003, "정보처리기사 실기 대비: SQL과 핵심 이론",
     "SELECT, GROUP BY, JOIN 등 SQL 작성 문제와 응집도, 결합도, OSI 7계층 같은 단골 이론을 함께 정리합니다.",
     "https://placehold.co/640x360?text=SQL+and+Theory"),
    (2002, 1000, "처음 시작하는 pandas 데이터 분석",
     "Python pandas로 CSV 데이터를 불러오고, 기본 탐색과 그룹 집계까지 실습하는 입문 강좌입니다.",
     "https://placehold.co/640x360?text=Pandas+Data+Analysis"),
]

# (lecture_id, course_id, order, title, description, youtube_id, problem_category_id, main_problem_set_id)
LECTURES = [
    (2101, 2000, 1, "정처기 실기, 어디부터 어떻게 공부할까", "실기 시험의 출제 경향과 과목별 학습 전략을 먼저 잡습니다.", "GwFUPOH4K2s", 3001, None),
    (2102, 2000, 2, "실기 핵심 정리: Python", "실기에 나오는 파이썬 문법을 핵심만 정리합니다. 수강 후 출력 결과 문제를 풀어 보세요.", "DkgiPJczxJk", 3001, 4001),
    (2103, 2000, 3, "파이썬, 정확히 알아야 합격한다", "객체, 리스트 등 헷갈리기 쉬운 파이썬 개념을 짚습니다. 수강 후 기초 코딩 문제를 풀어 보세요.", "PY5W1tDSpN0", 3001, 4002),
    (2104, 2000, 4, "기출문제 코드 해설", "실제 기출 코드를 한 줄씩 따라가며 해설합니다. 수강 후 알고리즘 구현 문제를 풀어 보세요.", "57xTwjIs8lg", 3001, 4003),
    (2111, 2001, 1, "SQL 기본 문법: SELECT ~ FROM ~ WHERE", "SELECT 문의 기본 형식과 조건 검색을 배웁니다.", "_JURyg_KzHE", 3002, None),
    (2112, 2001, 2, "ORDER BY와 GROUP BY", "정렬과 그룹 집계를 배웁니다.", "6qkPy7RfLqQ", 3002, None),
    (2113, 2001, 3, "두 테이블을 묶는 JOIN", "INNER JOIN, OUTER JOIN 등 조인을 배웁니다. 수강 후 SQL 작성 문제를 풀어 보세요.", "tuQFkzjqEGw", 3002, 4004),
    (2114, 2001, 4, "5분 특강: OSI 7계층", "자주 출제되는 OSI 7계층을 짧게 정리합니다. 수강 후 핵심 용어 문제를 풀어 보세요.", "66lp--WeGpc", 3003, 4005),
    (2115, 2001, 5, "시험장 가기 전 꼭 알아야 할 5가지", "실기 시험 직전에 점검할 내용을 정리합니다.", "03SCIdM-IBs", 3003, None),
    (2121, 2002, 1, "파이썬 데이터 분석 한 번에 훑어보기", "pandas와 시각화의 전체 흐름을 한 영상으로 살펴봅니다.", "PjhlUzp_cU0", 3004, None),
    (2122, 2002, 2, "DataFrame과 Series 기초", "행과 열을 선택하는 방법과 DataFrame의 구조를 익힙니다. 수강 후 카페 주문 데이터 문제를 풀어 보세요.", "zmdjNSmRXF4", 3004, 4006),
    (2123, 2002, 3, "그룹화와 집계", "groupby로 데이터를 묶고 합계와 평균을 계산합니다. 수강 후 쇼핑몰 주문 데이터 문제를 풀어 보세요.", "txMdrV1Ut64", 3004, 4007),
]


def build_sql(sets):
    out = ["-- 코드봄바 초기 콘텐츠. content/build_content.py 가 생성한다. 직접 고치지 말 것.",
           "-- 여러 번 실행해도 같은 결과가 된다 (ON DUPLICATE KEY UPDATE).",
           "SET NAMES utf8mb4;", "START TRANSACTION;", ""]
    out.append(insert("problem_category", ["category_id", "category_name", "description", "status"],
                      [(i, n, d, "ACTIVE") for i, n, d in CATEGORIES], ["category_id"]))
    out.append(insert("course", ["course_id", "instructor_id", "course_category_id", "title", "description",
                                 "thumbnail_url", "status", "created_at", "updated_at"],
                      [(i, OPERATOR_ID, c, t, d, th, "ACTIVE", "NOW()", "NOW()") for i, c, t, d, th in COURSES],
                      ["course_id"]))
    out.append(insert("lecture", ["lecture_id", "course_id", "lecture_order", "title", "description", "video_url",
                                  "problem_category_id", "status", "created_at", "updated_at"],
                      [(i, c, o, t, d, f"https://www.youtube.com/watch?v={v}", pc, "ACTIVE", "NOW()", "NOW()")
                       for i, c, o, t, d, v, pc, _ in LECTURES], ["lecture_id"]))

    set_rows, prob_rows, test_rows, hint_rows, data_rows = [], [], [], [], []
    for s in sets:
        assert len(s["description"]) <= 255, s["title"]
        set_rows.append((s["id"], s["category"], s["title"], s["description"], s["difficulty"], "ACTIVE",
                         len(s["problems"]), 0, 0, OPERATOR_ID, "NOW()"))
        if s.get("file"):
            path = DATASET_DIR / s["file"]
            key = f"{S3_PREFIX}/{s['file']}"
            data_rows.append((8000 + s["id"] - 4000, s["id"], s["file"], s["file"],
                              f"https://{BUCKET}.s3.{REGION}.amazonaws.com/{key}", key, path.stat().st_size,
                              metadata(path), "ACTIVE", "NOW()", "NOW()"))
        for order, p in enumerate(s["problems"], 1):
            pid = 5000 + (s["id"] - 4000) * 10 + order
            prob_rows.append((pid, s["id"], p["title"], p["content"], "CODE", p["difficulty"], p["explanation"],
                              p["point"], 999, True, "ACTIVE", order))
            for n, test in enumerate(p["tests"], 1):
                test_rows.append((pid * 10 + n, pid, test, n, n > 1, p["timeout"], "ACTIVE", "NOW()", "NOW()"))
            for n, hint in enumerate(p["hints"], 1):
                hint_rows.append((pid * 10 + n, pid, n, hint, "NOW()"))

    out.append(insert("problem_set", ["problem_set_id", "category_id", "title", "description", "difficulty", "status",
                                      "total_problem_count", "completed_user_count", "started_user_count",
                                      "created_by", "created_at"], set_rows,
                      ["problem_set_id", "completed_user_count", "started_user_count"]))
    out.append(insert("problem", ["problem_id", "problem_set_id", "title", "content", "problem_type", "difficulty",
                                  "explanation", "point", "attempt_limit", "is_retriable", "status", "problem_order"],
                      prob_rows, ["problem_id"]))
    out.append(insert("problem_test_case", ["test_case_id", "problem_id", "test_code", "test_order", "is_hidden",
                                            "timeout_ms", "status", "created_at", "updated_at"], test_rows,
                      ["test_case_id"]))
    out.append(insert("problem_hint", ["hint_id", "problem_id", "hint_order", "hint_content", "created_at"], hint_rows,
                      ["hint_id"]))
    out.append(insert("problem_dataset", ["dataset_id", "problem_set_id", "original_file_name", "stored_file_name",
                                          "file_url", "file_path", "file_size", "meta_data", "status", "created_at",
                                          "updated_at"], data_rows, ["dataset_id"]))
    lps = [(9000 + n, c, i, ps, "MAIN", 1) for n, (i, c, o, t, d, v, pc, ps) in enumerate(LECTURES, 1) if ps]
    out.append(insert("lecture_problem_set", ["lecture_problem_set_id", "course_id", "lecture_id", "problem_set_id",
                                              "role", "display_order"], lps, ["lecture_problem_set_id"]))
    out.append("COMMIT;\n")
    return "\n".join(out)


def main():
    sets = build_sets()
    if not verify(sets):
        sys.exit("검증 실패 — 파일을 쓰지 않았습니다.")
    (HERE / "content.sql").write_text(build_sql(sets), encoding="utf-8")
    n_prob = sum(len(s["problems"]) for s in sets)
    n_test = sum(len(p["tests"]) for s in sets for p in s["problems"])
    print(f"OK: 문제세트 {len(sets)}개, 문제 {n_prob}개, 테스트케이스 {n_test}개, 강의 {len(LECTURES)}개 검증 완료")


if __name__ == "__main__":
    main()
