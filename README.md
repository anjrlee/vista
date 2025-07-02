- 要裝的東西
  - flutter sdk
  - andriod studio
  - docker
- frontend
  - how to run 
    1. (cd frontend)
    2. flutter pub get
    3. flutter run
  - reminder
    - 準備一隻andriod手機
    - download andriod studio 
  - assets
    - 放一些照片or logo啥的
    - 或是json
- backend
  - how to run 
    1. download and open docker
    2. (在root)docker compose up --build
  - routes
    - 多一個route file in routes記得在main.py import和註冊
  - 有多pip install => 到requirement.txt加
  
- others
  - for .env
    - cp -n .env.example .env
    - or copy .env.example and rename it into .env
    - 改了.env也要改.env.example不然不會推上去
  - firebase key
    - 塞到backend/config裡
    - 改了key要改backend的.env和.env.example
  - 新增資料夾到assets記得到pubspec.yaml裡面加
  - 

- 注意
  - post/get 後端用baseUrl = dotenv.env['API_BASE_URL']/xxxx, 這樣到時候架上去改一行就好
  - 有加model到backend在調用的時候先寫在.env再從.env調，因為上雲應該會分開，如果直接寫死在裡面會很麻煩
  

- 需要你們幫忙接的地方!(感恩)
  - 劉威佑
    - backend/routes/aestheticScore.py
  - 趙以婷
    - backend/services/remove_portrait.py
