# simple url shortener
 Exercising and learning some new technologies!
 Objective is to create a simple ULR shortener python app running in k8s, storing the data in a DB.
 POST a long URL → get a short code
 Access the short code → redirect to the original URL

 Roadmap:
 1. Build the Python App running locally ✅
    With a local db and postman
    ![alt text](images/image.png)

    Added a simple front:
    
    ![alt text](images/image-2.png)

 2. Containerize It ✅
    Added dockerfile and tested locally
    ![alt text](images/image-1.png)

 3. CI/CD (optional stretch goal) 
    Lets add some automation on image building
    Docker push on main added
    ![alt text](images/image-3.png)
    ![alt text](images/image-4.png)

 4. Infrastructure as Code
    TF with Minikube, can't use TF cloud due to deploying locally
    ![alt text](images/image-5.png)
    Running on my local minikube forwarded to port 31928
    
 5. Service as Code
 6. Secure the System
 7. Observability & Monitoring
 8. secret migration from TF cloud to aws or azure secret managers