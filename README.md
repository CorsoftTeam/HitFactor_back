# README

Этот репозиторий хранит в себе сервер приложения HitFactor. Его можно развернуть самостоятельно, включая анализ выстрелов (нужный для учёта настрела каждого из оружий). Инструкция по установке:

```
git clone https://github.com/CorsoftTeam/HitFactor_back.git
git clone https://github.com/CorsoftTeam/shot_analysis.git
cd HitFactor_back
docker compose build
docker compose up -d
docker exec -it server bash
# в открывшейся консоли:
rails db:create db:migrate
```