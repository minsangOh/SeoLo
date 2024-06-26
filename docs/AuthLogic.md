# 인증로직 과정

## 시퀀스 다이어그램
![seq1.PNG](images%2FCORE%2Fseq1.PNG) <br>
![seq2.PNG](images%2FCORE%2Fseq2.PNG) <br>
![seq3.PNG](images%2FCORE%2Fseq3.PNG) <br>
![seq4.PNG](images%2FCORE%2Fseq4.PNG)

## 자격검정
- 사용자는 ID/PW 를 입력해 로그인하고 세션을 발급받는다.
- 잠근 자물쇠가 없는 사용자는 행동코드 ‘INIT’을 담고있는다.

1. 사용자는 휴대폰/워치를 잠겨있는 자물쇠에 태그한다.
2. 태그 과정에서 행동코드와 앱에 등록된 회사코드를 자물쇠에 전송한다.
3. 자물쇠는 코드에 따라 아래와 같은 로직을 수행한다.

### 블루투스 페이지로 이동해서 태그하는 경우

| 경우의 수 | 잠겨진 자물쇠                                                                                            | 열려있는 자물쇠                                                                                                               |
| --- |----------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| 해당 자물쇠를 잠근 사람 | 태그시 자물쇠 UNLOCK <br/> ![R1C1.PNG](images%2FCORE%2FR1C1.PNG)                                         | 경우의 수 없음                                                                                                               |
| 해당 자물쇠를 잠근 적 없는 사람 (→ 어떠한 자물쇠도 잠그지 않았다) | 태그시 정보 조회 <br/> ![R2C1.PNG](images%2FCORE%2FR2C1.PNG)                                              | 태그시 LOTO 일지 페이지로 리다이렉트 후 잠금 <br/> ![R2C2-1.PNG](images%2FCORE%2FR2C2-1.PNG)<br/> ![R2C2-2.PNG](images%2FCORE%2FR2C2-2.PNG) |
| 해당 자물쇠는 잠그지 않았지만 다른 자물쇠를 잠그고 있는 사람 | 태그시 정보 조회 <br/>![R3C1.PNG](images%2FCORE%2FR3C1.PNG)  | 태그시 2개 이상의 자물쇠를 잠굴 수 없습니다 경고 <br/>  ![R3C2.PNG](images%2FCORE%2FR3C2.PNG)  |
| 관리자(마스터키 소지자) | 태그시 자물쇠 UNLOCK <br/> ![R4C1.PNG](images%2FCORE%2FR4C1.PNG)| 현재 고려안함                                                                                                                |


### 사용자가 일지작성하고 자물쇠 태그하려는 경우

|     | 잠겨진 자물쇠                                        | 열려있는 자물쇠                                                              |
|-----------------------------------------|------------------------------------------------|-----------------------------------------------------------------------|
| 자물쇠를 잠구고 있지 않은 경우 | 태그시 자물쇠 <br> ’이미 잠겨져있는 자물쇠는 잠글 수 없습니다 오류’ <br> | 태그시 자물쇠 LOCK                                                          |
| 다른 자물쇠를 잠구고 있는 경우 | 일지 작성 불가  <br/>  ![TWOR1C1.PNG](images%2FCORE%2FTWOR1C1.PNG) | 일지 작성 불가 <br/> ![TWOR1C2-1.PNG](images%2FCORE%2FTWOR1C2-1.PNG) <br/> ![TWOR1C2-2.PNG](images%2FCORE%2FTWOR1C2-2.PNG) |
| 관리자인 경우(마스터키) | 일지 작성 불가                                       | 일지 작성 불가                                                              |


### **코드**

- 상태코드
    - INIT
    - LOCKED
- 행동코드
    - CHECK
    - LOCK
    - UNLOCK
    - WRITE
    - ALERT

## 모듈화
### 토큰발급모듈
![1.PNG](images%2FCORE%2F1.PNG)
![2.PNG](images%2FCORE%2F2.PNG)
![3.PNG](images%2FCORE%2F3.PNG)

### 코드 별 프론트모듈
![4.PNG](images%2FCORE%2F4.PNG)
![5.PNG](images%2FCORE%2F5.PNG)
![7.PNG](images%2FCORE%2F7.PNG)

### 코드 별 백엔드모듈
![6.PNG](images%2FCORE%2F6.PNG)
![8.PNG](images%2FCORE%2F8.PNG)

### 토큰 생성
![9.PNG](images%2FCORE%2F9.PNG)
![10.PNG](images%2FCORE%2F10.PNG)