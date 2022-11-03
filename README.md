# Практическая работа

## Шаг №1
Запускаем практическую работу прошлого семестра в docker. 

## Шаг №2
Добавляем чат поддержки.
- SignalR используется для real-time коммуникации.
- REST для загрузки истории.
- In-memory очередь на основе MassTransit для записи истории в БД.
- Background Service хостится вместе с web-проектом, для доступа к in-memory очереди.

### Паттерны
- Observer

## Шаг №3
- Меняем раеализацию очереди на RabbitMQ.
- Запускаем кролика в докере.
- Сервис уезжает в отдельный проект.

## Шаг №4
- Добавляем Zenko (S3-совместимое файловое хранилище) в docker
- Добавляем загрузку в файловое хранилище

## Шаг №5 поддержка метаданных (Event-Driven)
Реализовать сценарий «загрузка файла и метаданных». Метаданные могут отличаться в зависимости от типа файлов, например:
- Для .mp3 - это "исполнитель», "альбом», «название трека», «продолжительность композиции», ...
- Для видео (.mov, .avi и т.д.) - это «название фильма», «студиям», «режиссер», «актерский состав», ... 
- Придумайте еще как минимум 3 типа других типа файла

### Техническая реализация
<mark>**Смотри диаграмму в папке file-and-metadata-upload. Эта реализация - учебный пример. Не делайте так в production-коде. Пример специально излишне усложнен, чтобы продемонстрировать состояние
гонки в распределенных системах**</mark>.

Фронтенд создает GUID/UUID операции и отправляет || запросы на загрузку файла и метаданных. Методы API используют Redis и 
Temp Bucket (retention сутки или меньше) для временного хранения загруженных файлов и метаданных. Команда [incr](https://redis.io/commands/incr/)
используется в качестве атомарной операции. Как только счетчик поднимается до 2 (загружены и файл и метаданные) отправляется событие на перенос данных
в БД и постоянное хранилище. После окончательного сохранения данных API оповещает фронтенд через шину и SignalR.

### Паттерны
- Command

## Шаг №6 Декораторы

### Паттерны
- Декоратор

## Шаг №7 Декораторы -> Middleware

### Паттерны
- Chain of responsibility

## Шаг №7 MediatR
- Mediator

## Structurizr configs for Rider
### 1
database
existing
read
write

### 2
->
branding
component
containerinstance
custom
deployment
deploymentenvironment
deploymentgroup
deploymentnode
dynamic
element
enterprise
filtered
group
infrastructurenode
person
relationship
softwaresystem
softwaresysteminstance
styles
systemcontext
systemlandscape
terminology
theme
themes

### 3
animation
autolayout
background
color
configuration
fontsize
include
kotlin
model
shape
views

### 4
!adrs
!constant
!docs
!identifiers
!impliedrelationships
!include
!ref
!script
container
cylinder
folder
hexagon
legacy
mobiledevicelandscape
mobiledeviceportrait
pipe
robot
webbrowser
workspace