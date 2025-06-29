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
    - 或是josn
- backend
  - how to run 
    1. download and open docker
    2. (cd backend)
    3. docker build -t my-app .
    4. docker run -d -p 8000:8000 --name fastapi_container my-app
    5. go to localhost:8000
- others
  - for .env
    - cp -n .env.example .env
    - or copy .env.example and rename it into .env