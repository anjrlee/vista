FROM python:3.11-slim

# 設定工作目錄
WORKDIR /app

COPY requirements.txt .
# 安裝依賴
RUN pip install --no-cache-dir -r requirements.txt

# 複製檔案
COPY . /app



# 複製啟動腳本並給權限
RUN chmod +x /app/start.sh

# 開放埠口
EXPOSE 8000

# 容器啟動執行腳本
CMD ["/app/start.sh"]
