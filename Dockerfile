# Python image
FROM python:3.11-slim
WORKDIR /app

# Install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#Copy code
COPY . .

# Expose port (Flask default is 5000)
EXPOSE 5000

# Run the app
CMD ["python", "./app/fast_api_shortener.py"]