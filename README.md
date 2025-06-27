- frontend
  - how to run 
    0. (cd frontend)
    1. flutter pub get
    2. flutter run
  - reminder
    - 準備一隻andriod手機
    - download andriod studio 
- backend
  - how to run 
    0. downloa and open docker
    1.  docker build -t my-app .
    2. docker run -d -p 8000:8000 --name fastapi_container my-app
    3. go to localhost:8000
- others
  - for .env
    - cp -n .env.example .env
    - or copy .env.example and rename it into .env