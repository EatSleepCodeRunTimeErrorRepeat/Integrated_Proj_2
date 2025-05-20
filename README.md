# 🌟 **PeakSmart TH — Real-Time Peak Hour Tracking Notifier** 🌟

> **“Real-Time Peak Hour Tracking Notifier for Energy Savings in Thailand”**  
> **Product:** _PeakSmart TH_  
> **Group:** **Integrated Project II Project Profile (Grp. 7)**

---

## 📱 **What Is PeakSmart TH?**

PeakSmart TH is a **Flutter-based** web/mobile app that helps residents in Thailand save on electric bills by showing **real-time** peak vs. off-peak hours, countdown timers, and gentle notifications.  
Users select their provider (MEA or PEA), see a **color-coded** status card, and can plan appliance usage via an integrated calendar.  
Non-intrusive ads (AdMob) fund the service—**no direct subscription**.

---

## 🛠️ **Tech Stack**

- **Frontend:** **Flutter** (web)  
- **Backend:** **Node.js** + **Express**  
- **Database:** **PostgreSQL**  
- **Platform Separation:** Each tier runs in its own **Docker** container, hosted inside a separate **Vagrant VM** (Ubuntu 20.04).

---

## 🚀 **Quickstart** (Windows & macOS)

1. **Clone the repo**  
   ```bash (git bash into the desired folder you want to clone the repo into)
   git clone <your-repo-url> Integrated_Proj_2
   cd Integrated_Proj_2

2. **Verify folders**
  ├─ Vagrantfile  
  ├─ frontend/  
  ├─ backend/  
  └─ database/
3. **Install prerequisites on host**
- Git
- Vagrant
- VirtualBox
- Postman

4. **Bring up VMs & install Docker**
  ```bash (use any command terminal "powershell, Vscode terminal, git bash etc." and navigate to the folder with your Vagrantfile then run this command)
  - vagrant up --provision
```
This creates three VMs:
- frontend at 192.168.56.11
- backend at 192.168.56.12
- database at 192.168.56.13

#🐳 **Container Setup & Test**
*1. Database VM*
After the VMs have been created run these commands one by one to check whether installation is succesful for each VM. Any errors can be debugged via Chatgpt or Google
  ```bash 
vagrant ssh database
cd /home/vagrant/database
docker-compose up -d
docker ps
psql -h localhost -U peaksmart -d peaksmart -c "\dt"
exit
```
*2. Backend VM*
 ```bash 
vagrant ssh backend
cd /home/vagrant/backend
docker build -t peaksmart-backend .
docker run -d --name peaksmart-backend -p 3000:3000 peaksmart-backend
docker ps
# Test register:
curl -X POST http://localhost:3000/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123"}'
exit
```
*3. Frontend VM*
 ```bash 
vagrant ssh frontend
cd /home/vagrant/frontend
docker build -t peaksmart-frontend .
docker run -d --name peaksmart-frontend -p 8080:8080 peaksmart-frontend
docker ps
exit
```
#🔍 **Testing with Postman**
NOTE: Body is in JSON format select that option in postman
*1. Register*
POST http://192.168.56.12:3000/register
Body: { "email": "...", "password": "..." }
→ Response: { "User created" }

*2. Login*
POST http://192.168.56.12:3000/login
Body: { "email": "...", "password": "..." }
→ Response: { "token": "…" }

*3. Delete Account*
DELETE http://192.168.56.12:3000/delete
Header: Authorization: Bearer <token>
Frontend UI
Open your browser at http://localhost:8080 to exercise the form.


